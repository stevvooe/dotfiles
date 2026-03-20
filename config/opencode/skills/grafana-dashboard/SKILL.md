---
name: grafana-dashboard
description: Iterate on Grafana dashboard JSON files. Use when the user wants to create, modify, or fix Grafana dashboards — including panel layout, queries, colors, variables, and styling.
argument-hint: [dashboard-file-path]
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Agent
---

# Grafana Dashboard Iteration

You are helping the user build and iterate on Grafana dashboard JSON files.

## Workflow

1. **Always work file-first**: Edit the dashboard JSON file on disk, then copy to clipboard with `pbcopy` so the user can paste into Grafana's import UI. Never write JSON directly to clipboard without also saving to the file.

2. **Read before editing**: Always `Read` the dashboard file before making changes. Use `Edit` for targeted fixes, `Write` only for full rewrites.

3. **After every change**: Run `cat <file> | pbcopy` so the user can immediately paste and test.

## Dashboard JSON Conventions

### Template Variables
- Use `"type": "datasource"` for Prometheus source pickers
- Use `"type": "query"` with `label_values(metric, label)` for dynamic dropdowns
- Set `"refresh": 2` (on time range change) for query variables
- Always set sensible defaults in `"current": { "text": "...", "value": "..." }`

### Panel Defaults (clean style)
```json
{
  "drawStyle": "line",
  "lineInterpolation": "smooth",
  "lineWidth": 2,
  "fillOpacity": 0,
  "gradientMode": "none",
  "showPoints": "never",
  "spanNulls": false,
  "axisBorderShow": false,
  "axisLabel": "",
  "axisPlacement": "auto",
  "scaleDistribution": { "type": "linear" },
  "stacking": { "group": "A", "mode": "none" },
  "thresholdsStyle": { "mode": "off" }
}
```

### Color Theming
- To assign consistent colors per query, use field overrides with `byFrameRefID`:
```json
"overrides": [
  {
    "matcher": { "id": "byFrameRefID", "options": "A" },
    "properties": [{ "id": "color", "value": { "mode": "fixed", "fixedColor": "#5794F2" } }]
  },
  {
    "matcher": { "id": "byFrameRefID", "options": "B" },
    "properties": [{ "id": "color", "value": { "mode": "fixed", "fixedColor": "#FF9830" } }]
  }
]
```
- `byRegexp` on legend text does NOT work reliably. Always use `byFrameRefID`.

### Butterfly / Mirror Charts
To show two related values mirrored on positive/negative y-axis:
- Negate one query: `"-1 * <expr>"`
- Set `"axisCenteredZero": true` in custom field config

### Layout
- Use `gridPos` with `w` in multiples of 8 (8, 12, 24) for clean columns
- Standard row height: `h: 8`
- Use `"type": "row"` panels as section headers
- Keep y-coordinates sequential and consistent

### Common Pitfalls
- `fillOpacity > 0` causes colored shading below lines — set to 0 for clean lines
- `gradientMode: "scheme"` causes colored background bands — use `"none"`
- `stacking.mode: "normal"` on bar charts makes comparison hard — prefer lines or butterfly charts
- `"color": { "mode": "palette-classic" }` in defaults is fine alongside `byFrameRefID` overrides (overrides win)

## When Inspecting Existing Dashboards
Use `jq` to efficiently extract structure:
```bash
# Panel titles and queries
jq '[.panels[] | {title, type, targets: [.targets[]? | {expr, legendFormat}]}]' dashboard.json

# Template variables
jq '.templating.list[] | {name, label, query, type}' dashboard.json

# Unique metric names
jq -r '[.panels[] | .targets[]? | .expr // empty] | .[]' dashboard.json | grep -oE '[a-z][a-z_]+\{' | sed 's/{//' | sort -u
```

## Responding to Screenshots
When the user shares a screenshot of the dashboard, look for:
- Visual issues (fill, colors, stacking, layout)
- Whether the template variable selections suggest good defaults to save
- Missing or broken panels
