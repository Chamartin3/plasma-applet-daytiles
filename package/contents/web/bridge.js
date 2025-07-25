import { Daytiles, Layout, Shape } from "./daytiles.js";

const root = document.getElementById("root");
let dt = null;

const layouts = { Month: Layout.Month, Week: Layout.Week, Weekday: Layout.Weekday, Custom: Layout.Custom };
const shapes  = { Rectangle: Shape.Rectangle, RoundedRect: Shape.RoundedRect, Circle: Shape.Circle, Diamond: Shape.Diamond };

function toOpts(cfg) {
    const palette = cfg.palette || {};
    return {
        layout:    layouts[cfg.layout]    ?? Layout.Month,
        shape:     shapes[cfg.shape]      ?? Shape.RoundedRect,
        startDate: cfg.startDate,
        endDate:   cfg.endDate,
        daySize:   cfg.daySize,
        gap:       cfg.gap,
        colors: {
            base:    palette.base    || cfg.themeFg || "#3a3a3a",
            past:    palette.past    || "#2a2a2a",
            future:  palette.future  || "#4a4a4a",
            weekend: palette.weekend || undefined,
            alt:     palette.alt     || undefined,
        },
    };
}

function applyTheme(cfg) {
    if (cfg.themeFg) document.documentElement.style.setProperty("--fg", cfg.themeFg);
    if (cfg.themeBg) document.documentElement.style.setProperty("--bg", cfg.themeBg);
}

function rebuild(cfg, events) {
    if (!cfg || !cfg.startDate || !cfg.endDate) return;
    applyTheme(cfg);
    root.innerHTML = "";
    dt = new Daytiles(toOpts(cfg));
    if (Array.isArray(events) && events.length) dt.addEvents(events);
    if (typeof dt.onTileClick === "function") {
        dt.onTileClick((info) => {
            const safe = {
                date:   info && info.date   ? String(info.date)   : "",
                events: info && info.events ? info.events         : [],
            };
            console.log("DAYTILES_CLICK " + JSON.stringify(safe));
        });
    }
    dt.render(root);
}

let lastCfg = null;

window.daytilesBridge = {
    applyConfig(cfg, events) { lastCfg = cfg; rebuild(cfg, events); },
    setEvents(events)        { if (dt) { dt.clearEvents(); dt.addEvents(events); dt.update(); } },
    refresh()                { if (lastCfg) rebuild(lastCfg, []); },
};

// Initial empty render so the page is not blank during startup.
const today = new Date().toISOString().slice(0,10);
const yearStart = today.slice(0,4) + "-01-01";
const yearEnd   = today.slice(0,4) + "-12-31";
rebuild({ layout: "Month", shape: "RoundedRect",
          startDate: yearStart, endDate: yearEnd }, []);
