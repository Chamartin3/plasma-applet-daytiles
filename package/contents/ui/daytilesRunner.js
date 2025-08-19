.pragma library

function ShimElement(tag, ns) {
    this.tag = tag;
    this.ns = ns || null;
    this.attrs = {};
    this.children = [];
    this.text = "";
    this._classList = [];
    this.style = {};
    var self = this;
    this.classList = {
        add:    function(c) { if (self._classList.indexOf(c) < 0) self._classList.push(c); },
        remove: function(c) { var i = self._classList.indexOf(c); if (i >= 0) self._classList.splice(i, 1); },
        contains: function(c) { return self._classList.indexOf(c) >= 0; },
    };
}
ShimElement.prototype.setAttribute = function(k, v) { this.attrs[k] = String(v); };
ShimElement.prototype.getAttribute = function(k)    { return this.attrs[k]; };
ShimElement.prototype.appendChild  = function(c)    { this.children.push(c); return c; };
ShimElement.prototype.removeChild  = function(c)    {
    var i = this.children.indexOf(c);
    if (i >= 0) this.children.splice(i, 1);
    return c;
};
ShimElement.prototype.addEventListener = function() {};
ShimElement.prototype.removeEventListener = function() {};
ShimElement.prototype.getBoundingClientRect = function() {
    return { x: 0, y: 0, width: 0, height: 0, top: 0, left: 0, right: 0, bottom: 0 };
};
ShimElement.prototype.getBBox = function() {
    if (this.tag === "text") {
        var w = (this.text || "").length * 7;
        return { x: 0, y: 0, width: w, height: 14 };
    }
    var maxX = 0, maxY = 0;
    function num(el, name) { var v = el.attrs && el.attrs[name]; return v == null ? 0 : parseFloat(v) || 0; }
    function visit(el) {
        if (!el) return;
        if (el.tag === "rect") {
            var x = num(el, "x"), y = num(el, "y"), w = num(el, "width"), h = num(el, "height");
            if (x + w > maxX) maxX = x + w;
            if (y + h > maxY) maxY = y + h;
        } else if (el.tag === "circle") {
            var cx = num(el, "cx"), cy = num(el, "cy"), r = num(el, "r");
            if (cx + r > maxX) maxX = cx + r;
            if (cy + r > maxY) maxY = cy + r;
        } else if (el.tag === "polygon" || el.tag === "polyline") {
            var pts = (el.attrs && el.attrs.points) || "";
            var nums = pts.split(/[ ,]+/).map(parseFloat);
            for (var i = 0; i + 1 < nums.length; i += 2) {
                if (nums[i]   > maxX) maxX = nums[i];
                if (nums[i+1] > maxY) maxY = nums[i+1];
            }
        } else if (el.tag === "text") {
            var tx = num(el, "x"), ty = num(el, "y");
            var tw = (el.text || "").length * 7;
            if (tx + tw > maxX) maxX = tx + tw;
            if (ty + 4  > maxY) maxY = ty + 4;
        }
        if (el.children) for (var j = 0; j < el.children.length; ++j) visit(el.children[j]);
    }
    visit(this);
    return { x: 0, y: 0, width: maxX, height: maxY };
};
Object.defineProperty(ShimElement.prototype, "innerHTML", {
    get: function() { return ""; },
    set: function(v) { if (!v) { this.children = []; this.text = ""; } },
});
Object.defineProperty(ShimElement.prototype, "textContent", {
    get: function() { return this.text; },
    set: function(v) { this.text = String(v); this.children = []; },
});

function escapeXml(s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function styleObjToString(s) {
    var out = "";
    for (var k in s) {
        if (!Object.prototype.hasOwnProperty.call(s, k)) continue;
        var v = s[k];
        if (v === undefined || v === null || v === "") continue;
        var dashed = k.replace(/[A-Z]/g, function(m) { return "-" + m.toLowerCase(); });
        out += dashed + ":" + v + ";";
    }
    return out;
}

function serialize(el) {
    if (!el || !el.ns) return "";
    var s = "<" + el.tag;
    for (var k in el.attrs) {
        if (Object.prototype.hasOwnProperty.call(el.attrs, k))
            s += " " + k + "=\"" + escapeXml(el.attrs[k]) + "\"";
    }
    var styleStr = styleObjToString(el.style);
    if (styleStr) s += " style=\"" + escapeXml(styleStr) + "\"";
    if (el._classList.length) s += " class=\"" + escapeXml(el._classList.join(" ")) + "\"";
    if (!el.children.length && !el.text) return s + "/>";
    s += ">";
    if (el.text) s += escapeXml(el.text);
    for (var i = 0; i < el.children.length; ++i) s += serialize(el.children[i]);
    return s + "</" + el.tag + ">";
}

var document = {
    body: { appendChild: function() {}, removeChild: function() {} },
    createElement:    function(tag)     { return new ShimElement(tag, null); },
    createElementNS:  function(ns, tag) { return new ShimElement(tag, ns); },
    getElementById:   function()        { return null; },
};

"use strict";
var DTLib = (() => {
  var __defProp = Object.defineProperty;
  var __defProps = Object.defineProperties;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropDescs = Object.getOwnPropertyDescriptors;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __getOwnPropSymbols = Object.getOwnPropertySymbols;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __propIsEnum = Object.prototype.propertyIsEnumerable;
  var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
  var __spreadValues = (a, b) => {
    for (var prop in b || (b = {}))
      if (__hasOwnProp.call(b, prop))
        __defNormalProp(a, prop, b[prop]);
    if (__getOwnPropSymbols)
      for (var prop of __getOwnPropSymbols(b)) {
        if (__propIsEnum.call(b, prop))
          __defNormalProp(a, prop, b[prop]);
      }
    return a;
  };
  var __spreadProps = (a, b) => __defProps(a, __getOwnPropDescs(b));
  var __objRest = (source, exclude) => {
    var target = {};
    for (var prop in source)
      if (__hasOwnProp.call(source, prop) && exclude.indexOf(prop) < 0)
        target[prop] = source[prop];
    if (source != null && __getOwnPropSymbols)
      for (var prop of __getOwnPropSymbols(source)) {
        if (exclude.indexOf(prop) < 0 && __propIsEnum.call(source, prop))
          target[prop] = source[prop];
      }
    return target;
  };
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
  var __publicField = (obj, key, value) => __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);

  // src/index.ts
  var index_exports = {};
  __export(index_exports, {
    AlternationMode: () => AlternationMode,
    BaseCalendarSettings: () => BaseCalendarSettings,
    Daytiles: () => Daytiles,
    Layout: () => Layout,
    Shape: () => Shape
  });

  // src/dates.ts
  function stringToDate(datestring, year, last = false) {
    const [month, day] = datestring.split("-");
    const monthNum = parseInt(month != null ? month : "1");
    const dayNum = parseInt(day != null ? day : "") || !last ? 1 : null;
    if (dayNum) {
      return new Date(year, monthNum - 1, dayNum);
    }
    return new Date(year, monthNum, 0);
  }
  function toDate(value, fallbackYear, last) {
    if (value instanceof Date) return new Date(value);
    if (typeof value === "string") {
      const parts = value.split("-");
      if (parts.length === 3) {
        const [y, m, d] = parts.map((n) => parseInt(n));
        return new Date(y, (m != null ? m : 1) - 1, d != null ? d : 1);
      }
      return stringToDate(value, fallbackYear, last);
    }
    throw new Error("Unsupported date value");
  }
  function getRangeDates(initial, final, year = null) {
    const dateYear = year != null ? year : (/* @__PURE__ */ new Date()).getFullYear();
    return {
      startDate: toDate(initial, dateYear, false),
      endDate: toDate(final, dateYear, true)
    };
  }
  function getEvents(date, events) {
    var _a;
    const y = String(date.getFullYear()).padStart(4, "0");
    const m = String(date.getMonth() + 1).padStart(2, "0");
    const d = String(date.getDate()).padStart(2, "0");
    return (_a = events[`${y}-${m}-${d}`]) != null ? _a : [];
  }
  var MS_PER_DAY = 864e5;
  function dayOfYear(date) {
    const start = new Date(date.getFullYear(), 0, 1);
    return Math.floor((date.getTime() - start.getTime()) / MS_PER_DAY);
  }
  function isoWeekOfYear(date) {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const day = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - day);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil(((d.getTime() - yearStart.getTime()) / MS_PER_DAY + 1) / 7);
  }
  function getDateContext(date, today = /* @__PURE__ */ new Date()) {
    return {
      isPresent: date.toDateString() === today.toDateString(),
      isPast: date < today,
      isFuture: date > today,
      dayOfWeek: date.getDay(),
      month: date.getMonth(),
      year: date.getFullYear(),
      dayOfYear: dayOfYear(date),
      weekOfYear: isoWeekOfYear(date)
    };
  }

  // src/shapes.ts
  var Shape = /* @__PURE__ */ ((Shape3) => {
    Shape3["Rect"] = "rect";
    Shape3["RoundedRect"] = "roundedRect";
    Shape3["Circle"] = "circle";
    Shape3["Diamond"] = "diamond";
    return Shape3;
  })(Shape || {});
  var SVG_NS = "http://www.w3.org/2000/svg";
  var ROUNDED_RECT_RADIUS_RATIO = 0.25;
  function makeRect(x, y, size, radius = 0) {
    const rect = document.createElementNS(SVG_NS, "rect");
    rect.setAttribute("x", String(x));
    rect.setAttribute("y", String(y));
    rect.setAttribute("width", String(size));
    rect.setAttribute("height", String(size));
    if (radius > 0) {
      rect.setAttribute("rx", String(radius));
      rect.setAttribute("ry", String(radius));
    }
    return rect;
  }
  function makeCircle(x, y, size) {
    const circle = document.createElementNS(SVG_NS, "circle");
    const r = size / 2;
    circle.setAttribute("cx", String(x + r));
    circle.setAttribute("cy", String(y + r));
    circle.setAttribute("r", String(r));
    return circle;
  }
  function makeDiamond(x, y, size) {
    const polygon = document.createElementNS(SVG_NS, "polygon");
    const half = size / 2;
    const cx = x + half;
    const cy = y + half;
    const points = [
      `${cx},${y}`,
      `${x + size},${cy}`,
      `${cx},${y + size}`,
      `${x},${cy}`
    ].join(" ");
    polygon.setAttribute("points", points);
    return polygon;
  }
  function createTile(shape, x, y, size) {
    switch (shape) {
      case "roundedRect" /* RoundedRect */:
        return makeRect(x, y, size, size * ROUNDED_RECT_RADIUS_RATIO);
      case "circle" /* Circle */:
        return makeCircle(x, y, size);
      case "diamond" /* Diamond */:
        return makeDiamond(x, y, size);
      case "rect" /* Rect */:
      default:
        return makeRect(x, y, size);
    }
  }

  // src/alternation.ts
  var AlternationMode = /* @__PURE__ */ ((AlternationMode3) => {
    AlternationMode3["None"] = "none";
    AlternationMode3["Day"] = "day";
    AlternationMode3["Week"] = "week";
    AlternationMode3["Month"] = "month";
    AlternationMode3["Year"] = "year";
    AlternationMode3["Custom"] = "custom";
    return AlternationMode3;
  })(AlternationMode || {});
  function alternationBucket(ctx, mode, size) {
    switch (mode) {
      case "day" /* Day */:
        return ctx.dayOfYear;
      case "week" /* Week */:
        return ctx.weekOfYear;
      case "month" /* Month */:
        return ctx.month;
      case "year" /* Year */:
        return ctx.year;
      case "custom" /* Custom */:
        return Math.floor(ctx.dayOfYear / Math.max(1, size));
      case "none" /* None */:
      default:
        return -1;
    }
  }
  function shouldAlternate(ctx, alternation) {
    if (alternation.mode === "none" /* None */) return false;
    const bucket = alternationBucket(ctx, alternation.mode, alternation.size);
    return bucket >= 0 && bucket % 2 === 0;
  }

  // src/settings.ts
  var Layout = /* @__PURE__ */ ((Layout2) => {
    Layout2["Month"] = "month";
    Layout2["Week"] = "week";
    Layout2["Weekday"] = "weekday";
    Layout2["Custom"] = "custom";
    return Layout2;
  })(Layout || {});
  var BaseCalendarSettings = {
    layout: "weekday" /* Weekday */,
    startDate: "03-01",
    endDate: "06",
    year: null,
    daySize: 16,
    gap: 4,
    startDayOfWeek: 1,
    daysPerRow: 21,
    showLabels: false,
    labelWidth: 56,
    shape: "rect" /* Rect */,
    events: {},
    colors: {
      current: "#FFD700",
      dayColor: "#eee",
      pastFade: 0.6,
      alternation: {
        mode: "month" /* Month */,
        color: "#d2f0fa",
        size: 7
      },
      defaultEventColor: "#ff5577",
      heatmap: false,
      heatmapLow: 0.2,
      heatmapHigh: 0.35,
      highlight: {
        weekdays: {},
        months: {}
      }
    }
  };

  // src/colors.ts
  var DATE_BOX_CLASS = "DayTiles--day";
  var FUTURE_DAY_CLASS = "DayTiles--day--future";
  var PRESENT_DAY_CLASS = "DayTiles--day--present";
  var PAST_DAY_CLASS = "DayTiles--day--past";
  function getColor(dateContext, colorSettings) {
    var _a, _b, _c, _d;
    const { current: currentColor, dayColor, alternation } = colorSettings;
    const weekdayColors = (_b = (_a = colorSettings.highlight) == null ? void 0 : _a.weekdays) != null ? _b : {};
    const monthColors = (_d = (_c = colorSettings.highlight) == null ? void 0 : _c.months) != null ? _d : {};
    const highlightCurrent = colorSettings.highlightCurrent !== false;
    if (highlightCurrent && dateContext.isPresent) return currentColor;
    const weekdayMatch = weekdayColors[dateContext.dayOfWeek];
    if (weekdayMatch) return weekdayMatch;
    const monthMatch = monthColors[dateContext.month];
    if (monthMatch) return monthMatch;
    if (shouldAlternate(dateContext, alternation)) {
      return alternation.color;
    }
    return dayColor;
  }
  function parseHex(hex) {
    let h = hex.trim().replace(/^#/, "");
    if (h.length === 3) h = h.split("").map((c) => c + c).join("");
    if (h.length !== 6) return null;
    const n = parseInt(h, 16);
    if (Number.isNaN(n)) return null;
    return [n >> 16 & 255, n >> 8 & 255, n & 255];
  }
  function toHex(rgb) {
    return "#" + rgb.map((v) => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, "0")).join("");
  }
  function lerpHex(a, b, t) {
    const ca = parseHex(a);
    const cb = parseHex(b);
    if (!ca || !cb) return b;
    const k = Math.max(0, Math.min(1, t));
    return toHex([
      ca[0] + (cb[0] - ca[0]) * k,
      ca[1] + (cb[1] - ca[1]) * k,
      ca[2] + (cb[2] - ca[2]) * k
    ]);
  }
  function getClasses(ctx) {
    const classList = [DATE_BOX_CLASS];
    if (ctx.isFuture) classList.push(FUTURE_DAY_CLASS);
    if (ctx.isPresent) {
      classList.push(PRESENT_DAY_CLASS);
    } else if (ctx.isPast) {
      classList.push(PAST_DAY_CLASS);
    }
    return classList;
  }

  // src/tooltip.ts
  var TOOLTIP_ID = "daytiles-tooltip";
  var TOOLTIP_CLASS = "DayTiles--tooltip";
  var DATA_DATE_ATTR = "data-date";
  var DATA_NOTE_ATTR = "data-note";
  var DATA_COUNT_ATTR = "data-count";
  var DATA_WEIGHT_ATTR = "data-weight";
  function ensureTooltip() {
    let el = document.getElementById(TOOLTIP_ID);
    if (!el) {
      el = document.createElement("div");
      el.id = TOOLTIP_ID;
      el.className = TOOLTIP_CLASS;
      Object.assign(el.style, {
        position: "fixed",
        pointerEvents: "none",
        zIndex: "9999",
        display: "none",
        background: "#222",
        color: "#fff",
        border: "1px solid #000",
        borderRadius: "5px",
        padding: "4px 8px",
        fontFamily: "Arial, sans-serif",
        fontSize: "12px",
        whiteSpace: "nowrap",
        boxShadow: "0 2px 6px rgba(0,0,0,0.25)"
      });
      document.body.appendChild(el);
    }
    return el;
  }
  function showDateTooltip(event) {
    const target = event.target;
    const date = target.getAttribute(DATA_DATE_ATTR);
    const note = target.getAttribute(DATA_NOTE_ATTR);
    const count = target.getAttribute(DATA_COUNT_ATTR);
    const weight = target.getAttribute(DATA_WEIGHT_ATTR);
    const el = ensureTooltip();
    el.innerHTML = "";
    const dateLine = document.createElement("div");
    dateLine.textContent = date;
    el.appendChild(dateLine);
    if (count) {
      const countLine = document.createElement("div");
      countLine.textContent = `${count} events`;
      countLine.style.opacity = "0.85";
      countLine.style.marginTop = "2px";
      el.appendChild(countLine);
    }
    if (weight) {
      const weightLine = document.createElement("div");
      weightLine.textContent = `weight: ${weight}`;
      weightLine.style.opacity = "0.85";
      weightLine.style.marginTop = "2px";
      el.appendChild(weightLine);
    }
    if (note) {
      const noteLine = document.createElement("div");
      noteLine.textContent = note;
      noteLine.style.opacity = "0.85";
      noteLine.style.fontStyle = "italic";
      noteLine.style.marginTop = "2px";
      el.appendChild(noteLine);
    }
    el.style.display = "block";
    const rect = target.getBoundingClientRect();
    el.style.left = `${rect.right + 8}px`;
    el.style.top = `${rect.top}px`;
  }
  function hideDateTooltip() {
    const el = document.getElementById(TOOLTIP_ID);
    if (el) el.style.display = "none";
  }

  // src/tile.ts
  function sumWeights(events) {
    var _a;
    let total = 0;
    for (const e of events) total += (_a = e.weight) != null ? _a : 1;
    return total;
  }
  function dominantTypeCount(events) {
    var _a;
    const counts = /* @__PURE__ */ new Map();
    for (const e of events) counts.set(e.type, ((_a = counts.get(e.type)) != null ? _a : 0) + 1);
    let dom;
    let max = 0;
    for (const [t, c] of counts) {
      if (c > max) {
        max = c;
        dom = t;
      }
    }
    return { type: dom, count: max };
  }
  function resolveTileFill(events, baseColor, colorSettings, maxWeight) {
    var _a, _b, _c, _d;
    if (events.length === 0) return baseColor;
    const typeColors = (_a = colorSettings.eventTypeColors) != null ? _a : {};
    if (!colorSettings.heatmap) {
      const first = events[0];
      return first.color || (first.type ? typeColors[first.type] : void 0) || colorSettings.defaultEventColor;
    }
    const { type } = dominantTypeCount(events);
    const typeColor = (_b = type ? typeColors[type] : void 0) != null ? _b : colorSettings.defaultEventColor;
    const low = (_c = colorSettings.heatmapLow) != null ? _c : 0.2;
    const high = (_d = colorSettings.heatmapHigh) != null ? _d : 0.35;
    const lowEnd = lerpHex("#ffffff", typeColor, low);
    const highEnd = lerpHex(typeColor, "#000000", high);
    const w = sumWeights(events);
    const t = maxWeight > 1 ? (w - 1) / (maxWeight - 1) : 1;
    return lerpHex(lowEnd, highEnd, t);
  }
  function drawDateTile(dateToDraw, { x, y, size, shape, events, colorSettings, maxWeight, onClick }) {
    const dateContext = getDateContext(dateToDraw);
    const tile = createTile(shape, x, y, size);
    const baseColor = getColor(dateContext, colorSettings);
    const dayColor = resolveTileFill(events, baseColor, colorSettings, maxWeight);
    const dayClasses = getClasses(dateContext);
    tile.setAttribute("fill", dayColor);
    const fade = dateContext.isPresent ? void 0 : dateContext.isPast ? colorSettings.pastFade : colorSettings.futureFade;
    if (typeof fade === "number" && fade !== 1) {
      tile.style.filter = `brightness(${fade})`;
    }
    tile.setAttribute("data-date", dateToDraw.toDateString());
    const joinedNote = events.map((e) => e.note).filter((n) => Boolean(n)).join(" \u2022 ");
    if (joinedNote) tile.setAttribute("data-note", joinedNote);
    if (events.length > 1) tile.setAttribute("data-count", String(events.length));
    const total = sumWeights(events);
    if (events.length > 0 && total !== events.length) {
      tile.setAttribute("data-weight", String(total));
    }
    tile.addEventListener("mouseover", showDateTooltip);
    tile.addEventListener("mouseout", hideDateTooltip);
    if (onClick) {
      tile.style.cursor = "pointer";
      tile.addEventListener("click", (domEvent) => {
        onClick({ date: new Date(dateToDraw), events, domEvent });
      });
    }
    dayClasses.forEach((c) => tile.classList.add(c));
    return tile;
  }

  // src/labels.ts
  var ROW_LABEL_CLASS = "DayTiles--rowLabel";
  var ROW_LABEL_GAP = 8;
  var MONTH_NAMES = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  var DAY_NAMES = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  function isoWeek(date) {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const day = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - day);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil(((d.getTime() - yearStart.getTime()) / 864e5 + 1) / 7);
  }
  function rowLabel(layout, date, rowIndex, daysPerRow) {
    var _a;
    switch (layout) {
      case "month" /* Month */:
        return `${MONTH_NAMES[date.getMonth()]} ${date.getFullYear()}`;
      case "week" /* Week */:
        return `W${isoWeek(date)}`;
      case "weekday" /* Weekday */:
        return (_a = DAY_NAMES[date.getDay()]) != null ? _a : "";
      case "custom" /* Custom */:
        return `${rowIndex * daysPerRow + 1}`;
      default:
        return "";
    }
  }

  // src/draw.ts
  var SVG_NS2 = "http://www.w3.org/2000/svg";
  var CONTAINER_CLASS = "DayTilesContainer";
  function drawCalendar(svgElement, settings, onTileClick) {
    var _a;
    const {
      layout,
      daysPerRow,
      daySize: squareSize,
      gap,
      startDayOfWeek,
      showLabels,
      labelWidth,
      shape,
      events,
      startDate: begin,
      endDate: end,
      year,
      colors: colorSettings
    } = settings;
    svgElement.classList.add(CONTAINER_CLASS);
    svgElement.innerHTML = "";
    const { startDate, endDate } = getRangeDates(begin, end, year);
    const currentDate = new Date(startDate);
    let row = 0;
    let col = 0;
    let dayIndex = 0;
    const adjustedColumn = (date) => (7 + date.getDay() - startDayOfWeek) % 7;
    const cells = [];
    const labels = [];
    const labeledRows = /* @__PURE__ */ new Set();
    while (currentDate <= endDate) {
      let newRow = false;
      switch (layout) {
        case "week" /* Week */:
          col = adjustedColumn(currentDate);
          newRow = col === 0 && currentDate > startDate;
          break;
        case "weekday" /* Weekday */:
          row = adjustedColumn(currentDate);
          newRow = true;
          if (row === 0) col++;
          break;
        case "month" /* Month */:
          if (currentDate.getDate() === 1 || currentDate.getTime() === startDate.getTime()) {
            col = adjustedColumn(currentDate);
            newRow = true;
          } else {
            col++;
          }
          break;
        case "custom" /* Custom */:
          col = dayIndex % daysPerRow;
          newRow = col === 0 && dayIndex !== 0;
          dayIndex++;
          break;
      }
      if (newRow) row++;
      if (showLabels && !labeledRows.has(row)) {
        labeledRows.add(row);
        labels.push({
          row,
          text: rowLabel(layout, currentDate, row, daysPerRow)
        });
      }
      cells.push({ date: new Date(currentDate), row, col });
      currentDate.setDate(currentDate.getDate() + 1);
    }
    let offsetX = 0;
    if (showLabels) {
      const labelEls = labels.map(({ row: r, text }) => {
        const el = document.createElementNS(SVG_NS2, "text");
        el.setAttribute("x", "0");
        el.setAttribute("y", String(r * (squareSize + gap) + squareSize * 0.7));
        el.setAttribute("class", ROW_LABEL_CLASS);
        el.setAttribute("font-size", String(Math.max(8, Math.round(squareSize * 0.55))));
        el.textContent = text;
        svgElement.appendChild(el);
        return el;
      });
      let maxWidth = labelWidth;
      for (const el of labelEls) {
        const w = el.getBBox().width;
        if (w > maxWidth) maxWidth = w;
      }
      offsetX = maxWidth + ROW_LABEL_GAP;
    }
    let maxWeight = 0;
    for (const { date } of cells) {
      const list = getEvents(date, events);
      let w = 0;
      for (const e of list) w += (_a = e.weight) != null ? _a : 1;
      if (w > maxWeight) maxWeight = w;
    }
    for (const { date, row: r, col: c } of cells) {
      svgElement.appendChild(
        drawDateTile(date, {
          x: offsetX + c * (squareSize + gap),
          y: r * (squareSize + gap),
          size: squareSize,
          shape,
          events: getEvents(date, events),
          colorSettings,
          maxWeight,
          onClick: onTileClick
        })
      );
    }
  }

  // src/daytiles.ts
  var MS_PER_DAY2 = 864e5;
  function toDate2(value) {
    if (value instanceof Date) return new Date(value);
    const parts = value.split("-").map((n) => parseInt(n, 10));
    if (parts.length === 3) {
      const [y, m, d] = parts;
      return new Date(y, (m != null ? m : 1) - 1, d != null ? d : 1);
    }
    throw new Error(`Unsupported date value: ${value}`);
  }
  function dateKey(date) {
    const y = String(date.getFullYear()).padStart(4, "0");
    const m = String(date.getMonth() + 1).padStart(2, "0");
    const d = String(date.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  }
  function generateId() {
    if (typeof crypto !== "undefined" && "randomUUID" in crypto) {
      return crypto.randomUUID();
    }
    return `evt_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 10)}`;
  }
  var Daytiles = class {
    constructor(options = {}) {
      __publicField(this, "settings");
      __publicField(this, "events", []);
      __publicField(this, "tileClickHandler");
      this.settings = this.mergeSettings(BaseCalendarSettings, options);
    }
    update(options) {
      this.settings = this.mergeSettings(this.settings, options);
    }
    onTileClick(handler) {
      this.tileClickHandler = handler;
    }
    addEvent(event) {
      const stamped = __spreadProps(__spreadValues({}, event), { id: generateId() });
      this.events.push(stamped);
      return stamped.id;
    }
    addEvents(events) {
      return events.map((e) => this.addEvent(e));
    }
    prependEvent(event) {
      const stamped = __spreadProps(__spreadValues({}, event), { id: generateId() });
      this.events.unshift(stamped);
      return stamped.id;
    }
    prependEvents(events) {
      const stamped = events.map((e) => __spreadProps(__spreadValues({}, e), { id: generateId() }));
      this.events.unshift(...stamped);
      return stamped.map((e) => e.id);
    }
    removeEvent(id) {
      const idx = this.events.findIndex((e) => e.id === id);
      if (idx === -1) return false;
      this.events.splice(idx, 1);
      return true;
    }
    clearEvents() {
      this.events = [];
    }
    listEvents() {
      return [...this.events];
    }
    getSettings() {
      return this.settings;
    }
    render(svgElement) {
      const { defaultEventColor, eventTypeColors } = this.settings.colors;
      const events = this.flattenEvents(defaultEventColor, eventTypeColors != null ? eventTypeColors : {});
      drawCalendar(
        svgElement,
        __spreadProps(__spreadValues({}, this.settings), { events }),
        this.tileClickHandler
      );
      const bbox = svgElement.getBBox();
      const w = Math.ceil(bbox.x + bbox.width);
      const h = Math.ceil(bbox.y + bbox.height);
      svgElement.setAttribute("viewBox", `0 0 ${w} ${h}`);
      svgElement.setAttribute("preserveAspectRatio", "xMidYMin meet");
      svgElement.setAttribute("width", String(w));
      svgElement.setAttribute("height", String(h));
      if (!svgElement.style.maxWidth) svgElement.style.maxWidth = "100%";
      if (!svgElement.style.height) svgElement.style.height = "auto";
    }
    mergeSettings(base, overrides) {
      const _a = overrides, { colors } = _a, rest = __objRest(_a, ["colors"]);
      return __spreadProps(__spreadValues(__spreadValues({}, base), rest), {
        colors: __spreadValues(__spreadValues({}, base.colors), colors != null ? colors : {}),
        events: {}
      });
    }
    flattenEvents(defaultColor, typeColors) {
      var _a, _b, _c, _d;
      const out = {};
      for (const entry of this.events) {
        const start = toDate2(entry.start);
        const end = entry.end ? toDate2(entry.end) : start;
        const cursor = new Date(start);
        const typeColor = entry.type ? typeColors[entry.type] : void 0;
        const color = (_b = (_a = entry.color) != null ? _a : typeColor) != null ? _b : defaultColor;
        while (cursor.getTime() <= end.getTime()) {
          const key = dateKey(cursor);
          const note = (_c = entry.note) != null ? _c : key;
          const list = (_d = out[key]) != null ? _d : out[key] = [];
          list.push({
            color,
            note,
            wiki: entry.wiki,
            type: entry.type,
            weight: entry.weight
          });
          cursor.setTime(cursor.getTime() + MS_PER_DAY2);
        }
      }
      return out;
    }
  };
  return __toCommonJS(index_exports);
})();

function _isoDate(s) {
    return /^\d{4}-\d{2}-\d{2}$/.test(s) ? s : "";
}

function _collectTiles(el, out) {
    if (!el) return;
    var dateAttr = el.attrs && el.attrs["data-date"];
    if (dateAttr) {
        var bx = 0, by = 0, bw = 0, bh = 0;
        function num(name) { var v = el.attrs[name]; return v == null ? 0 : parseFloat(v) || 0; }
        if (el.tag === "rect") {
            bx = num("x"); by = num("y"); bw = num("width"); bh = num("height");
        } else if (el.tag === "circle") {
            var cx = num("cx"), cy = num("cy"), r = num("r");
            bx = cx - r; by = cy - r; bw = 2 * r; bh = 2 * r;
        } else if (el.tag === "polygon") {
            var pts = (el.attrs.points || "").split(/[ ,]+/).map(parseFloat);
            var minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
            for (var i = 0; i + 1 < pts.length; i += 2) {
                if (pts[i]   < minX) minX = pts[i];
                if (pts[i+1] < minY) minY = pts[i+1];
                if (pts[i]   > maxX) maxX = pts[i];
                if (pts[i+1] > maxY) maxY = pts[i+1];
            }
            bx = minX; by = minY; bw = maxX - minX; bh = maxY - minY;
        }
        out.push({
            date: _isoDate(dateAttr),
            rawDate: dateAttr,
            note: (el.attrs["data-note"] || ""),
            x: bx, y: by, w: bw, h: bh,
        });
    }
    if (el.children) for (var j = 0; j < el.children.length; ++j) _collectTiles(el.children[j], out);
}

var _origToDateString = Date.prototype.toDateString;
Date.prototype.toDateString = function() {
    var y = this.getFullYear();
    var m = this.getMonth() + 1;
    var d = this.getDate();
    return y + "-" + (m < 10 ? "0" + m : m) + "-" + (d < 10 ? "0" + d : d);
};

function _parseHexColor(s) {
    if (!s || typeof s !== "string") return null;
    var m = s.trim();
    if (m.charAt(0) === "#") m = m.substring(1);
    if (m.length === 3) m = m.charAt(0)+m.charAt(0)+m.charAt(1)+m.charAt(1)+m.charAt(2)+m.charAt(2);
    if (!/^[0-9a-fA-F]{6}$/.test(m)) return null;
    return { r: parseInt(m.substring(0,2),16), g: parseInt(m.substring(2,4),16), b: parseInt(m.substring(4,6),16) };
}
function _hex2(n) { var h = Math.max(0, Math.min(255, Math.round(n))).toString(16); return h.length < 2 ? "0"+h : h; }
function _scaleColor(hex, factor) {
    var c = _parseHexColor(hex);
    if (!c) return hex;
    return "#" + _hex2(c.r * factor) + _hex2(c.g * factor) + _hex2(c.b * factor);
}
function _bakeFilterFade(el) {
    if (!el) return;
    if (el.style && el.style.filter) {
        var m = /brightness\(\s*([0-9.]+)\s*\)/.exec(el.style.filter);
        if (m) {
            var f = parseFloat(m[1]);
            if (!isNaN(f) && f !== 1) {
                var fill = el.attrs && el.attrs.fill;
                if (fill) el.attrs.fill = _scaleColor(fill, f);
            }
            delete el.style.filter;
        }
    }
    if (el.children) for (var i = 0; i < el.children.length; ++i) _bakeFilterFade(el.children[i]);
}

function _renderInternal(cfg, events) {
    if (!cfg || !cfg.startDate || !cfg.endDate) return { svg: "", tiles: [], width: 0, height: 0 };
    var palette = cfg.palette || {};
    var L = DTLib.Layout, S = DTLib.Shape;
    var layoutMap = { Month: L.Month, Week: L.Week, Weekday: L.Weekday, Custom: L.Custom };
    var shapeMap  = { Rectangle: S.Rect, Rect: S.Rect, RoundedRect: S.RoundedRect, Circle: S.Circle, Diamond: S.Diamond };
    var settings = {
        layout:    layoutMap[cfg.layout] || L.Month,
        shape:     shapeMap[cfg.shape]   || S.RoundedRect,
        startDate: cfg.startDate,
        endDate:   cfg.endDate,
        daySize:   cfg.daySize || 16,
        gap:       cfg.gap != null ? cfg.gap : 2,
        colors: (function() {
            var c = {
                dayColor:          palette.base    || cfg.themeFg || "#3a3a3a",
                current:           palette.current || "#FFD700",
                defaultEventColor: palette.event   || "#ff5577",
                highlight: {
                    weekdays: palette.weekend ? { 0: palette.weekend, 6: palette.weekend } : {},
                    months:   {},
                },
            };
            var altMode = (cfg.alternationMode || "month").toLowerCase();
            if (altMode !== "none" && palette.alternation) {
                c.alternation = {
                    mode: altMode,
                    color: palette.alternation,
                    size: (typeof cfg.alternationSize === "number" && cfg.alternationSize > 0) ? cfg.alternationSize : 7,
                };
            }
            if (typeof cfg.pastFade === "number")        c.pastFade = cfg.pastFade;
            if (typeof cfg.futureFade === "number")      c.futureFade = cfg.futureFade;
            if (cfg.highlightCurrent === false)          c.highlightCurrent = false;
            if (cfg.eventTypeColors && typeof cfg.eventTypeColors === "object")
                c.eventTypeColors = cfg.eventTypeColors;
            if (cfg.heatmap) {
                c.heatmap = true;
                if (typeof cfg.heatmapLow === "number")  c.heatmapLow  = cfg.heatmapLow;
                if (typeof cfg.heatmapHigh === "number") c.heatmapHigh = cfg.heatmapHigh;
            }
            return c;
        })(),
    };
    if (typeof cfg.daysPerRow === "number" && cfg.daysPerRow > 0) settings.daysPerRow = cfg.daysPerRow;
    if (typeof cfg.startDayOfWeek === "number") settings.startDayOfWeek = cfg.startDayOfWeek;
    if (cfg.showLabels) {
        settings.showLabels = true;
        if (typeof cfg.labelWidth === "number") settings.labelWidth = cfg.labelWidth;
    }
    var dt = new DTLib.Daytiles(settings);
    if (Array.isArray(events) && events.length) dt.addEvents(events);
    var root = new ShimElement("svg", "http://www.w3.org/2000/svg");
    root.setAttribute("xmlns", "http://www.w3.org/2000/svg");
    dt.render(root);
    _bakeFilterFade(root);
    var tiles = [];
    _collectTiles(root, tiles);
    var w = parseInt(root.attrs.width || "0") || 0;
    var h = parseInt(root.attrs.height || "0") || 0;
    return { svg: serialize(root), tiles: tiles, width: w, height: h };
}

function renderToSvgWithTiles(cfg, events) {
    return _renderInternal(cfg, events);
}

function renderToSvg(cfg, events) {
    return _renderInternal(cfg, events).svg;
}
