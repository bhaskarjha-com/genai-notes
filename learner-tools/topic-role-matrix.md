# Topic x Role Matrix

This page is the interactive companion to the static [generated role matrix](../generated/topic-role-relevance-matrix.md).

<div class="tool-shell">
  <div class="tool-toolbar">
    <label><span>Role</span><select id="role-matrix-role"></select></label>
    <label><span>Status</span><select id="role-matrix-status"></select></label>
    <label class="tool-search"><span>Search</span><input id="role-matrix-search" type="search" placeholder="Filter by topic title" /></label>
  </div>
  <div class="stats-strip compact" id="role-matrix-summary"></div>
  <div class="matrix-table-wrap">
    <table class="matrix-table">
      <thead>
        <tr>
          <th>Topic</th>
          <th>Folder</th>
          <th>Difficulty</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody id="role-matrix-body"></tbody>
    </table>
  </div>
</div>

## Reading The Labels

- `Must` means the note is on the universal foundation or explicitly core in the dedicated role guide.
- `Good` means it is an advanced differentiator for that role.
- `Optional` means it lives on the role's main learning track but is not called out as core.
- `Not Relevant` means it is outside the role's current priority path.
