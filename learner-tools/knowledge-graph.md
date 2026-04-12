# Interactive Knowledge Graph

This page renders the repo's topic network directly from the generated relationship data in `assets/data/knowledge-graph.json`.

<div class="tool-shell">
  <div class="tool-toolbar">
    <label><span>Folder</span><select id="knowledge-graph-folder"></select></label>
    <label><span>Difficulty</span><select id="knowledge-graph-difficulty"></select></label>
    <label><span>Track</span><select id="knowledge-graph-track"></select></label>
    <label class="tool-search"><span>Search</span><input id="knowledge-graph-search" type="search" placeholder="Filter by note title" /></label>
  </div>
  <div class="tool-summary" id="knowledge-graph-summary"></div>
  <canvas id="knowledge-graph-canvas" class="graph-canvas" width="1200" height="760"></canvas>
  <p class="tool-hint">Drag nodes, hover for detail, and click a node to open the note.</p>
</div>

## What The Graph Encodes

- `parent` and `related` frontmatter links
- note-to-note links in the `Connections` sections
- folder, difficulty, and learning-track membership for every published topic note
