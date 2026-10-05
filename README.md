# kadrell-example

Example extension for [Kadrell](https://kadrell.malura.de). It demonstrates the full Lua extension API in one file: a right-sidebar panel, a status-bar entry, session events, timers, running host commands, HTTP requests, persistent storage and settings.

## Install

Inside Kadrell, press `F4`, search under "Discover" for `kadrell-example` and click Install. Kadrell loads any public GitHub repository tagged with the topic `kadrell-extension`.

Or clone it by hand:

```bash
git clone https://github.com/maluramichael/kadrell-example ~/.config/kadrell/extensions/kadrell-example
```

Then enable it in the `F4` dialog.

## What it shows

- `kadrell.panel.set` / `kadrell.status.set`: sections, items with actions, text and buttons
- `kadrell.on`: `session.focus`, `session.new`, `session.status`, `ui.action`, `app.ready`
- `kadrell.every` / `kadrell.after`: repeating and one-shot timers
- `kadrell.exec`, `kadrell.http`, `kadrell.run`, `kadrell.sessions`
- `kadrell.storage`, `kadrell.config`, `kadrell.json`, `kadrell.log` / `kadrell.warn`

See [`init.lua`](init.lua) and the [documentation](https://kadrell.malura.de/extensions).
