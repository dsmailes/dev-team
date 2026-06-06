#!/usr/bin/env python3
"""Render a static HTML dashboard for local workflow tickets."""

from __future__ import annotations

import argparse
import datetime as _datetime
import html
import os
import re
from pathlib import Path


STATES = ["Backlog", "Ready", "In Progress", "Review", "Test", "Done", "Blocked"]


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text()


def section(text: str, heading: str) -> str:
    pattern = re.compile(
        rf"^## {re.escape(heading)}\s*$\n(?P<body>.*?)(?=^## |\Z)",
        re.MULTILINE | re.DOTALL,
    )
    match = pattern.search(text)
    return match.group("body").strip() if match else ""


def plain_value(value: str) -> str:
    value = value.strip()
    value = re.sub(r"^`|`$", "", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()


def first_nonempty_line(value: str) -> str:
    for line in value.splitlines():
        line = plain_value(line)
        if line:
            return line
    return ""


def list_items(value: str) -> list[str]:
    items: list[str] = []
    for line in value.splitlines():
        match = re.match(r"^\s*[-*]\s+(.*)", line)
        if match:
            item = plain_value(match.group(1))
            if item:
                items.append(item)
    return items


def first_paragraph(value: str) -> str:
    lines: list[str] = []
    for line in value.splitlines():
        stripped = line.strip()
        if not stripped:
            if lines:
                break
            continue
        if stripped.startswith(("-", "*", "#")):
            continue
        lines.append(stripped)
    return plain_value(" ".join(lines))


def parse_checklists(text: str) -> tuple[int, int]:
    total = len(re.findall(r"^\s*-\s+\[[ xX]\]", text, re.MULTILINE))
    done = len(re.findall(r"^\s*-\s+\[[xX]\]", text, re.MULTILINE))
    return done, total


def parse_queue(queue_path: Path) -> dict[str, str]:
    if not queue_path.exists():
        return {}

    queue: dict[str, str] = {}
    current_state = ""
    for raw_line in read_text(queue_path).splitlines():
        heading = re.match(r"^##\s+(.+?)\s*$", raw_line)
        if heading:
            candidate = heading.group(1).strip()
            current_state = candidate if candidate in STATES else ""
            continue

        item = re.search(r"`([^`]+)`", raw_line)
        if current_state and item:
            queue[item.group(1)] = current_state
    return queue


def parse_ticket(path: Path, project: Path, queue_state: str | None) -> dict[str, object]:
    text = read_text(path)
    title = first_nonempty_line(section(text, "Title"))
    state = first_nonempty_line(section(text, "State"))
    ticket_id = ""

    h1 = re.search(r"^#\s+(.+?)\s*$", text, re.MULTILINE)
    if h1:
        ticket_id = plain_value(h1.group(1))
    if not ticket_id:
        ticket_id = path.stem

    acceptance = list_items(section(text, "Acceptance Criteria"))
    risks = list_items(section(text, "Risks"))
    done_checks, total_checks = parse_checklists(section(text, "Handoff Gates"))
    problem = first_paragraph(section(text, "Problem"))
    verification = first_paragraph(section(text, "Verification Plan"))
    relative_path = path.relative_to(project)

    warnings: list[str] = []
    if queue_state and state and queue_state != state:
        warnings.append(f"Queue says {queue_state}; ticket says {state}.")
    if not queue_state:
        warnings.append("Not listed in .tickets/queue.md.")
    if state and state not in STATES:
        warnings.append(f"Unknown ticket state: {state}.")
    if not title:
        warnings.append("Missing title.")

    return {
        "id": ticket_id,
        "title": title or "(Untitled ticket)",
        "state": state or "Unknown",
        "queue_state": queue_state or "",
        "problem": problem,
        "acceptance_count": len(acceptance),
        "risks": risks,
        "verification": verification,
        "checks_done": done_checks,
        "checks_total": total_checks,
        "path": relative_path.as_posix(),
        "warnings": warnings,
    }


def discover_tickets(project: Path) -> list[Path]:
    tickets_dir = project / ".tickets"
    if not tickets_dir.exists():
        return []
    ignored = {"template.md", "queue.md", "README.md"}
    return sorted(path for path in tickets_dir.glob("*.md") if path.name not in ignored)


def state_class(state: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", state.lower()).strip("-") or "unknown"


def pct(done: int, total: int) -> int:
    if total == 0:
        return 0
    return round((done / total) * 100)


def render_dashboard(project: Path, output: Path) -> str:
    queue = parse_queue(project / ".tickets" / "queue.md")
    tickets = [parse_ticket(path, project, queue.get(path.stem)) for path in discover_tickets(project)]
    for ticket in tickets:
        ticket_path = project / str(ticket["path"])
        ticket["href"] = os.path.relpath(ticket_path, output.parent).replace(os.sep, "/")

    ticket_ids = {str(ticket["id"]) for ticket in tickets}
    queue_only = sorted(ticket_id for ticket_id in queue if ticket_id not in ticket_ids)
    counts = {state: 0 for state in STATES}
    for ticket in tickets:
        state = str(ticket["state"])
        if state in counts:
            counts[state] += 1

    warnings = []
    for ticket in tickets:
        warnings.extend(f"{ticket['id']}: {warning}" for warning in ticket["warnings"])
    warnings.extend(f"{ticket_id}: listed in queue but no matching ticket file was found." for ticket_id in queue_only)

    generated_at = _datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %Z")
    total_tickets = len(tickets)
    active_count = sum(counts[state] for state in STATES if state != "Done")
    blocked_count = counts["Blocked"]

    rows = "\n".join(render_ticket_row(ticket) for ticket in tickets)
    state_filters = "\n".join(
        f'<button class="state-filter" type="button" data-state="{html.escape(state)}">'
        f"<span>{html.escape(state)}</span><strong>{counts[state]}</strong></button>"
        for state in STATES
    )
    warning_html = render_warnings(warnings)

    document = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Ticket Dashboard</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f4f7f8;
      --surface: #ffffff;
      --ink: #1e252b;
      --muted: #61707b;
      --line: #d8e0e5;
      --accent: #23746f;
      --accent-soft: #d9eeeb;
      --warn: #a94d16;
      --blocked: #a83248;
      --done: #3f7f46;
      --shadow: 0 18px 45px rgba(23, 35, 43, 0.08);
    }}

    * {{ box-sizing: border-box; }}

    body {{
      margin: 0;
      background: var(--bg);
      color: var(--ink);
      font: 15px/1.5 ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }}

    a {{ color: inherit; }}

    .page {{
      min-height: 100svh;
      display: grid;
      grid-template-columns: minmax(220px, 280px) minmax(0, 1fr);
    }}

    aside {{
      position: sticky;
      top: 0;
      height: 100svh;
      padding: 28px 22px;
      background: #17232b;
      color: #f7fafb;
      overflow: auto;
    }}

    .brand {{
      margin: 0 0 6px;
      font-size: 22px;
      line-height: 1.1;
      font-weight: 760;
      letter-spacing: 0;
    }}

    .timestamp {{
      margin: 0 0 24px;
      color: rgba(247, 250, 251, 0.72);
      font-size: 13px;
    }}

    .metric {{
      display: grid;
      grid-template-columns: 1fr auto;
      gap: 10px;
      align-items: baseline;
      padding: 12px 0;
      border-top: 1px solid rgba(247, 250, 251, 0.14);
    }}

    .metric span {{ color: rgba(247, 250, 251, 0.74); }}
    .metric strong {{ font-size: 26px; line-height: 1; }}

    .state-filters {{
      display: grid;
      gap: 4px;
      margin-top: 24px;
    }}

    .state-filter {{
      appearance: none;
      border: 0;
      border-radius: 6px;
      display: grid;
      grid-template-columns: 1fr auto;
      gap: 8px;
      width: 100%;
      padding: 10px 12px;
      background: transparent;
      color: rgba(247, 250, 251, 0.82);
      text-align: left;
      font: inherit;
      cursor: pointer;
    }}

    .state-filter:hover,
    .state-filter.active {{
      background: rgba(247, 250, 251, 0.11);
      color: #ffffff;
    }}

    main {{
      min-width: 0;
      padding: 34px min(5vw, 56px) 56px;
    }}

    header {{
      display: flex;
      justify-content: space-between;
      gap: 24px;
      align-items: end;
      margin-bottom: 28px;
    }}

    h1 {{
      margin: 0;
      font-size: clamp(28px, 4vw, 52px);
      line-height: 1;
      letter-spacing: 0;
    }}

    .subhead {{
      max-width: 680px;
      margin: 10px 0 0;
      color: var(--muted);
      font-size: 16px;
    }}

    .search {{
      min-width: min(360px, 100%);
      border: 1px solid var(--line);
      border-radius: 7px;
      padding: 12px 14px;
      background: var(--surface);
      color: var(--ink);
      font: inherit;
      box-shadow: var(--shadow);
    }}

    .warnings {{
      border-left: 4px solid var(--warn);
      background: #fff3e7;
      padding: 14px 16px;
      margin-bottom: 22px;
    }}

    .warnings h2 {{
      margin: 0 0 8px;
      font-size: 15px;
    }}

    .warnings ul {{
      margin: 0;
      padding-left: 20px;
      color: #613118;
    }}

    .table-wrap {{
      background: var(--surface);
      border: 1px solid var(--line);
      border-radius: 8px;
      box-shadow: var(--shadow);
      overflow: auto;
    }}

    table {{
      width: 100%;
      border-collapse: collapse;
      min-width: 880px;
    }}

    th, td {{
      padding: 14px 16px;
      border-bottom: 1px solid var(--line);
      text-align: left;
      vertical-align: top;
    }}

    th {{
      position: sticky;
      top: 0;
      z-index: 1;
      background: #eef3f5;
      color: var(--muted);
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }}

    tr:last-child td {{ border-bottom: 0; }}
    tr.hidden {{ display: none; }}

    .ticket-id {{
      font-weight: 760;
      white-space: nowrap;
    }}

    .ticket-title {{
      margin: 0 0 4px;
      font-weight: 700;
    }}

    .ticket-problem {{
      margin: 0;
      color: var(--muted);
      max-width: 520px;
    }}

    .badge {{
      display: inline-flex;
      align-items: center;
      min-height: 26px;
      padding: 4px 9px;
      border-radius: 999px;
      background: var(--accent-soft);
      color: #0d4f4b;
      font-size: 13px;
      font-weight: 700;
      white-space: nowrap;
    }}

    .state-blocked {{ background: #f6dce3; color: var(--blocked); }}
    .state-done {{ background: #dceedd; color: var(--done); }}
    .state-unknown {{ background: #ede5d8; color: #695a42; }}

    .progress {{
      display: grid;
      gap: 6px;
      min-width: 120px;
    }}

    .bar {{
      height: 7px;
      overflow: hidden;
      border-radius: 999px;
      background: #dce5e9;
    }}

    .bar span {{
      display: block;
      height: 100%;
      width: var(--pct);
      background: var(--accent);
    }}

    .meta {{
      color: var(--muted);
      font-size: 13px;
    }}

    .risk-list {{
      margin: 0;
      padding-left: 18px;
      color: var(--muted);
    }}

    .empty {{
      margin: 0;
      color: var(--muted);
    }}

    @media (max-width: 840px) {{
      .page {{ display: block; }}
      aside {{
        position: static;
        height: auto;
        padding: 22px 18px;
      }}
      main {{ padding: 24px 16px 42px; }}
      header {{
        display: grid;
        align-items: start;
      }}
      .search {{ min-width: 0; width: 100%; }}
      .state-filters {{
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }}
    }}
  </style>
</head>
<body>
  <div class="page">
    <aside>
      <p class="brand">Ticket Dashboard</p>
      <p class="timestamp">Generated {html.escape(generated_at)}</p>
      <div class="metric"><span>Total tickets</span><strong>{total_tickets}</strong></div>
      <div class="metric"><span>Active</span><strong>{active_count}</strong></div>
      <div class="metric"><span>Blocked</span><strong>{blocked_count}</strong></div>
      <nav class="state-filters" aria-label="Filter by state">
        <button class="state-filter active" type="button" data-state="All"><span>All</span><strong>{total_tickets}</strong></button>
        {state_filters}
      </nav>
    </aside>
    <main>
      <header>
        <div>
          <h1>Current ticket state</h1>
          <p class="subhead">A static view of local Markdown tickets, queue alignment, handoff progress, risks, and verification notes.</p>
        </div>
        <input class="search" type="search" placeholder="Search tickets" aria-label="Search tickets">
      </header>
      {warning_html}
      <section class="table-wrap" aria-label="Tickets">
        <table>
          <thead>
            <tr>
              <th>Ticket</th>
              <th>State</th>
              <th>Handoff Gates</th>
              <th>Acceptance</th>
              <th>Risks</th>
              <th>Verification</th>
            </tr>
          </thead>
          <tbody>
            {rows or '<tr><td colspan="6"><p class="empty">No ticket files found in .tickets.</p></td></tr>'}
          </tbody>
        </table>
      </section>
    </main>
  </div>
  <script>
    const filters = document.querySelectorAll(".state-filter");
    const rows = document.querySelectorAll("tbody tr[data-state]");
    const search = document.querySelector(".search");
    let selectedState = "All";

    function applyFilters() {{
      const query = search.value.trim().toLowerCase();
      rows.forEach((row) => {{
        const matchesState = selectedState === "All" || row.dataset.state === selectedState;
        const matchesSearch = !query || row.textContent.toLowerCase().includes(query);
        row.classList.toggle("hidden", !(matchesState && matchesSearch));
      }});
    }}

    filters.forEach((button) => {{
      button.addEventListener("click", () => {{
        selectedState = button.dataset.state;
        filters.forEach((item) => item.classList.toggle("active", item === button));
        applyFilters();
      }});
    }});

    search.addEventListener("input", applyFilters);
  </script>
</body>
</html>
"""

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(document, encoding="utf-8")
    return document


def render_ticket_row(ticket: dict[str, object]) -> str:
    ticket_id = str(ticket["id"])
    title = str(ticket["title"])
    state = str(ticket["state"])
    href = str(ticket["href"])
    checks_done = int(ticket["checks_done"])
    checks_total = int(ticket["checks_total"])
    risks = [str(risk) for risk in ticket["risks"]]
    risk_html = (
        "<ul class=\"risk-list\">" + "".join(f"<li>{html.escape(risk)}</li>" for risk in risks[:3]) + "</ul>"
        if risks
        else '<p class="empty">None listed.</p>'
    )
    verification = str(ticket["verification"]) or "No verification plan summary found."
    problem = str(ticket["problem"])
    percent = pct(checks_done, checks_total)

    return f"""<tr data-state="{html.escape(state)}">
  <td>
    <a class="ticket-id" href="{html.escape(href)}">{html.escape(ticket_id)}</a>
    <p class="ticket-title">{html.escape(title)}</p>
    <p class="ticket-problem">{html.escape(problem)}</p>
  </td>
  <td><span class="badge state-{state_class(state)}">{html.escape(state)}</span></td>
  <td>
    <div class="progress">
      <div class="bar" aria-hidden="true"><span style="--pct: {percent}%"></span></div>
      <span class="meta">{checks_done} of {checks_total} checks complete</span>
    </div>
  </td>
  <td><span class="meta">{ticket["acceptance_count"]} criteria</span></td>
  <td>{risk_html}</td>
  <td><span class="meta">{html.escape(verification)}</span></td>
</tr>"""


def render_warnings(warnings: list[str]) -> str:
    if not warnings:
        return ""
    items = "".join(f"<li>{html.escape(warning)}</li>" for warning in warnings)
    return f"""<section class="warnings" aria-label="Ticket warnings">
  <h2>Attention needed</h2>
  <ul>{items}</ul>
</section>"""


def main() -> int:
    parser = argparse.ArgumentParser(description="Render docs/tickets.html from .tickets/*.md.")
    parser.add_argument("--project", default=".", help="Project root containing .tickets. Defaults to current directory.")
    parser.add_argument("--output", default="docs/tickets.html", help="Output HTML path, relative to project unless absolute.")
    args = parser.parse_args()

    project = Path(args.project).resolve()
    output = Path(args.output)
    if not output.is_absolute():
        output = project / output

    render_dashboard(project, output)
    print(f"Wrote {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
