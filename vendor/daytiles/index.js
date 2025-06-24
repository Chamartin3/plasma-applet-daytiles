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

// src/colors.ts
var DATE_BOX_CLASS = "dateBox";
var FUTURE_DAY_CLASS = "future-day";
var PRESENT_DAY_CLASS = "present-day";
var PAST_DAY_CLASS = "past-day";
function getColor(dateContext, colorSettings) {
  const { current: currentColor, dayColor, alternation } = colorSettings;
  const weekdayColors = colorSettings.highlight?.weekdays ?? {};
  const monthColors = colorSettings.highlight?.months ?? {};
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

// src/dates.ts
function stringToDate(datestring, year, last = false) {
  const [month, day] = datestring.split("-");
  const monthNum = parseInt(month ?? "1");
  const dayNum = parseInt(day ?? "") || !last ? 1 : null;
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
      return new Date(y, (m ?? 1) - 1, d ?? 1);
    }
    return stringToDate(value, fallbackYear, last);
  }
  throw new Error("Unsupported date value");
}
function getRangeDates(initial, final, year = null) {
  const dateYear = year ?? (/* @__PURE__ */ new Date()).getFullYear();
  return {
    startDate: toDate(initial, dateYear, false),
    endDate: toDate(final, dateYear, true)
  };
}
function getEvent(date, events) {
  const y = String(date.getFullYear()).padStart(4, "0");
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return events[`${y}-${m}-${d}`] ?? {};
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
    highlight: {
      weekdays: {},
      months: {}
    }
  }
};

// src/tooltip.ts
var TOOLTIP_ID = "daytiles-tooltip";
var TOOLTIP_CLASS = "tooltip-box";
var DATA_DATE_ATTR = "data-date";
var DATA_NOTE_ATTR = "data-note";
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
  const el = ensureTooltip();
  el.innerHTML = "";
  const dateLine = document.createElement("div");
  dateLine.textContent = date;
  el.appendChild(dateLine);
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

// src/draw.ts
var SVG_NS2 = "http://www.w3.org/2000/svg";
var ROW_LABEL_CLASS = "row-label";
var ROW_LABEL_GAP = 8;
function drawDateTile(dateToDraw, { x, y, size, shape, overwrites, colorSettings, onClick }) {
  const dateContext = getDateContext(dateToDraw);
  const tile = createTile(shape, x, y, size);
  const dayColor = overwrites.color || getColor(dateContext, colorSettings);
  const dayClasses = getClasses(dateContext);
  tile.setAttribute("fill", dayColor);
  const fade = dateContext.isPresent ? void 0 : dateContext.isPast ? colorSettings.pastFade : colorSettings.futureFade;
  if (typeof fade === "number" && fade !== 1) {
    tile.style.filter = `brightness(${fade})`;
  }
  tile.setAttribute("data-date", dateToDraw.toDateString());
  if (overwrites.note) tile.setAttribute("data-note", overwrites.note);
  tile.addEventListener("mouseover", showDateTooltip);
  tile.addEventListener("mouseout", hideDateTooltip);
  if (onClick) {
    tile.style.cursor = "pointer";
    tile.addEventListener("click", (domEvent) => {
      onClick({ date: new Date(dateToDraw), event: overwrites, domEvent });
    });
  }
  dayClasses.forEach((c) => tile.classList.add(c));
  return tile;
}
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
  switch (layout) {
    case "month" /* Month */:
      return `${MONTH_NAMES[date.getMonth()]} ${date.getFullYear()}`;
    case "week" /* Week */:
      return `W${isoWeek(date)}`;
    case "weekday" /* Weekday */:
      return DAY_NAMES[date.getDay()] ?? "";
    case "custom" /* Custom */:
      return `${rowIndex * daysPerRow + 1}`;
    default:
      return "";
  }
}
function drawCalendar(svgElement, settings, onTileClick) {
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
  for (const { date, row: r, col: c } of cells) {
    svgElement.appendChild(
      drawDateTile(date, {
        x: offsetX + c * (squareSize + gap),
        y: r * (squareSize + gap),
        size: squareSize,
        shape,
        overwrites: getEvent(date, events),
        colorSettings,
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
    return new Date(y, (m ?? 1) - 1, d ?? 1);
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
  settings;
  events = [];
  tileClickHandler;
  constructor(options = {}) {
    this.settings = this.mergeSettings(BaseCalendarSettings, options);
  }
  update(options) {
    this.settings = this.mergeSettings(this.settings, options);
  }
  onTileClick(handler) {
    this.tileClickHandler = handler;
  }
  addEvent(event) {
    const stamped = { ...event, id: generateId() };
    this.events.push(stamped);
    return stamped.id;
  }
  addEvents(events) {
    return events.map((e) => this.addEvent(e));
  }
  prependEvent(event) {
    const stamped = { ...event, id: generateId() };
    this.events.unshift(stamped);
    return stamped.id;
  }
  prependEvents(events) {
    const stamped = events.map((e) => ({ ...e, id: generateId() }));
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
    const events = this.flattenEvents(defaultEventColor, eventTypeColors ?? {});
    drawCalendar(
      svgElement,
      { ...this.settings, events },
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
    const { colors, ...rest } = overrides;
    return {
      ...base,
      ...rest,
      colors: { ...base.colors, ...colors ?? {} },
      events: {}
    };
  }
  flattenEvents(defaultColor, typeColors) {
    const out = {};
    for (const entry of this.events) {
      const start = toDate2(entry.start);
      const end = entry.end ? toDate2(entry.end) : start;
      const cursor = new Date(start);
      const typeColor = entry.type ? typeColors[entry.type] : void 0;
      const color = entry.color ?? typeColor ?? defaultColor;
      while (cursor.getTime() <= end.getTime()) {
        const key = dateKey(cursor);
        const note = entry.note ?? key;
        const existing = out[key];
        out[key] = {
          color: existing?.color ?? color,
          note: existing?.note ? `${existing.note} \u2022 ${note}` : note,
          wiki: existing?.wiki ?? entry.wiki
        };
        cursor.setTime(cursor.getTime() + MS_PER_DAY2);
      }
    }
    return out;
  }
};
export {
  AlternationMode,
  BaseCalendarSettings,
  Daytiles,
  Layout,
  Shape
};
//# sourceMappingURL=index.js.map
