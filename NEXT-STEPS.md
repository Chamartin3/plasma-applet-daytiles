# Next Steps

## Status

The plasmoid is functional and published with a README. Targets KDE Plasma 5.27 / Qt 5.15.

What works today:

- Daytiles SVG renders in the full representation; compact representation works in panel mode.
- Configuration UI covers general layout, appearance (colors, highlights, heatmap), and events.
- Quick-add panel and per-day event list.
- Events import/export.
- Highlight rules form for weekends and arbitrary day-of-week patterns.
- Tooltip with configurable date format and matching events.
- Defaults centralized in `defaults.js`; UI split into `config/`, `fields/`, `panels/`.

Repo layout is conventional Plasma 5: `package/metadata.json`, `package/contents/{ui,config}`, vendored upstream library at `vendor/daytiles/`.

## To do now

1. **Commit `LICENSE`** — currently untracked. The plasmoid metadata declares MIT but the file is not in the repo.
2. **Push to GitHub.** Repo currently has no remote. Suggested name: `plasma-applet-daytiles`.
3. **Install locally** to verify the published package:
   ```sh
   make install
   ```
   Then add the widget from the Plasma "Add Widgets" panel and confirm rendering, config persistence, and event interactions.

## Later

- Decide whether to move pure JS libs (`defaults.js`, `daytilesRunner.js`) into `package/contents/code/` to match the Plasma::Package spec strictly.
- Submit to [store.kde.org](https://store.kde.org) once stable.
- Translations (`package/contents/locale/`).
- Plasma 6 / Qt 6 port — APIs differ; will need a separate branch.
