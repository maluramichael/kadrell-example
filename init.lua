-- kadrell-example: a tour of the Kadrell Lua extension API.
-- Docs: https://kadrell.malura.de/extensions
--
-- Host calls (exec, http, run, sessions, storage) must run inside a handler
-- (kadrell.on, kadrell.every, kadrell.after); at the top level they would error.

local ticks = 0
local lastFocus = "(none)"

-- Build the right-sidebar panel (section > item with actions, text, buttons).
-- kadrell.panel.set replaces the whole tree; colors are theme names: accent, muted, ok, warn, err.
local function render()
  kadrell.panel.set{
    title = kadrell.config.title or "Example",
    children = {
      { type = "section", title = "State", children = {
        { type = "item", text = "Focused session", detail = lastFocus, color = "accent",
          actions = { { id = "hello", label = "Say hello" } } },
        { type = "item", text = "Ticks", detail = tostring(ticks), color = "muted" },
      }},
      { type = "text", text = "Greeting: " .. (kadrell.config.greeting or "hi"), color = "muted" },
      { type = "button", label = "Say hello", action = "hello" },
      { type = "button", label = "List sessions", action = "sessions" },
    },
  }
  -- One entry in the bottom status bar; clicking it fires ui.action with this id.
  kadrell.status.set{ text = "ex " .. ticks, color = "ok", action = "hello" }
end

-- React to Kadrell session events.
-- data.session = { key, title, cwd, branch, sessionId, state, group }
kadrell.on("session.focus", function(data)
  lastFocus = (data.session and data.session.title) or "(none)"
  render()
end)

kadrell.on("session.new", function(data)
  kadrell.log("new session: " .. ((data.session and data.session.title) or "?"))
end)

kadrell.on("session.status", function(data)
  kadrell.log("status: " .. tostring(data.state))
end)

-- UI actions from panel buttons/items and the status entry.
kadrell.on("ui.action", function(data)
  if data.id == "hello" then
    kadrell.log(kadrell.config.greeting or "hello from the example extension")
  elseif data.id == "sessions" then
    local list = kadrell.sessions()                 -- same as `kadrell ls --json`, as a Lua table
    kadrell.log("sessions open: " .. tostring(#list))
    if list[1] then
      local res = kadrell.run("select", "-t", list[1].key)  -- drive Kadrell like the CLI
      kadrell.log("selected first session, status " .. tostring(res.status))
    end
  else
    kadrell.warn("unknown action: " .. tostring(data.id))
  end
end)

-- app.ready fires once after init; a good place for first-run setup and one-off I/O.
kadrell.on("app.ready", function()
  -- storage is a JSON file in storageDir and survives reload and restart.
  local runs = (kadrell.storage.get("runs") or 0) + 1
  kadrell.storage.set("runs", runs)
  kadrell.log("example started, run #" .. runs)

  if kadrell.config.verbose then kadrell.warn("verbose logging is on") end

  -- JSON helpers.
  kadrell.log("json: " .. kadrell.json.encode({ runs = runs, ok = true }))

  -- Run a command on the host.
  local r = kadrell.exec({ "date", "+%H:%M:%S" })
  if r.status == 0 then kadrell.log("host time: " .. (r.stdout:gsub("%s+$", ""))) end

  -- Call an HTTP endpoint.
  local resp = kadrell.http{ url = "https://api.github.com/zen",
                             headers = { ["User-Agent"] = "kadrell-example" } }
  if resp.status == 200 then kadrell.log("github zen: " .. resp.body) end

  -- A secret setting lives in the keychain, never in a file.
  local token = kadrell.config.token
  if token and #token > 0 then kadrell.log("token is set (" .. #token .. " chars)") end

  render()
end)

-- A one-shot timer.
kadrell.after(1, function() kadrell.log("one-shot timer fired") end)

-- A repeating timer; every() returns a handle with handle:cancel().
kadrell.every(5, function()
  ticks = ticks + 1
  render()
end)
