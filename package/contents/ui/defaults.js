.pragma library

// Single source of truth for daytiles defaults. Keep main.xml <default> values
// in sync with these — kcfg cannot import JS, so the XML defaults are the only
// duplication. If you change a value here, mirror it in main.xml.

var Colors = {
    current:     "#FFD700",
    day:         "#3a3a3a",
    event:       "#ff5577",
    alternation: "#d2f0fa",
    weekend:     "#a5f0b6",
};

var Layout = {
    mode:           "Weekday",
    shape:          "RoundedRect",
    daySize:        16,
    gap:            2,
    daysPerRow:     21,
    startDayOfWeek: 1,
    showLabels:     false,
    dateFormat:     "yyyy-MM-dd",
    labelWidth:     56,
};

var Alternation = {
    mode: "month",
    size: 7,
};

var Fade = {
    past:   0.6,
    future: 1.0,
};

var Heatmap = {
    enabled: false,
    low:     0.2,
    high:    0.35,
};

var HighlightCurrent = true;

var WeekendHighlights = [
    { kind: "weekday", value: 0, color: Colors.weekend },
    { kind: "weekday", value: 6, color: Colors.weekend },
];

function shapeToken(s) {
    var v = (s || Layout.shape).toLowerCase();
    if (v === "rectangle")   return "rect";
    if (v === "roundedrect") return "roundedRect";
    return v;
}

function pad2(n) { return n < 10 ? "0" + n : "" + n; }
function isoFromDate(d) {
    return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate());
}
function defaultRange() {
    var now = new Date();
    var start = new Date(now.getFullYear(), now.getMonth() - 3, 1);
    var end   = new Date(now.getFullYear(), now.getMonth() + 3 + 1, 0);
    return { start: isoFromDate(start), end: isoFromDate(end) };
}
