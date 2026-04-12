(function () {
  const roleSelect = document.getElementById("role-matrix-role");
  if (!roleSelect) {
    return;
  }

  const statusSelect = document.getElementById("role-matrix-status");
  const searchInput = document.getElementById("role-matrix-search");
  const summary = document.getElementById("role-matrix-summary");
  const body = document.getElementById("role-matrix-body");
  const siteRoot = new URL("../", window.location.href);
  const dataUrl = new URL("../assets/data/topic-role-matrix.json", window.location.href);
  const statusOrder = ["Must", "Good", "Optional", "Not Relevant"];

  function populateSelect(select, options, defaultValue) {
    select.innerHTML = "";
    options.forEach(function (option) {
      const element = document.createElement("option");
      element.value = option.value;
      element.textContent = option.label;
      if (option.value === defaultValue) {
        element.selected = true;
      }
      select.appendChild(element);
    });
  }

  function badgeClass(status) {
    return "status-pill status-" + status.toLowerCase().replace(/[^a-z]+/g, "-");
  }

  function renderSummary(role) {
    summary.innerHTML = "";
    [
      ["Must", role.MustCount],
      ["Good", role.GoodCount],
      ["Optional", role.OptionalCount],
      ["Not Relevant", role.NotRelevantCount]
    ].forEach(function (entry) {
      const card = document.createElement("div");
      card.className = "stat-card";
      card.innerHTML = "<strong>" + entry[1] + "</strong><span>" + entry[0] + "</span>";
      summary.appendChild(card);
    });
  }

  function renderRows(data) {
    const roleId = roleSelect.value;
    const role = data.Roles.find(function (item) {
      return item.Id === roleId;
    });
    const searchValue = searchInput.value.trim().toLowerCase();
    const statusValue = statusSelect.value;

    renderSummary(role);
    body.innerHTML = "";

    data.Topics
      .filter(function (topic) {
        const status = topic.Statuses[roleId];
        if (statusValue !== "all" && status !== statusValue) {
          return false;
        }
        if (searchValue && topic.Title.toLowerCase().indexOf(searchValue) === -1) {
          return false;
        }
        return true;
      })
      .sort(function (left, right) {
        const statusDelta =
          statusOrder.indexOf(left.Statuses[roleId]) - statusOrder.indexOf(right.Statuses[roleId]);
        if (statusDelta !== 0) {
          return statusDelta;
        }
        return left.Title.localeCompare(right.Title);
      })
      .forEach(function (topic) {
        const row = document.createElement("tr");
        row.innerHTML =
          '<td><a href="' +
          new URL(topic.SitePath, siteRoot).href +
          '">' +
          topic.Title +
          "</a></td>" +
          "<td>" +
          topic.Folder +
          "</td>" +
          "<td>" +
          topic.Difficulty +
          "</td>" +
          '<td><span class="' +
          badgeClass(topic.Statuses[roleId]) +
          '">' +
          topic.Statuses[roleId] +
          "</span></td>";
        body.appendChild(row);
      });
  }

  fetch(dataUrl)
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      populateSelect(
        roleSelect,
        data.Roles.map(function (role) {
          return { value: role.Id, label: role.Title };
        }),
        "ai-engineer"
      );

      populateSelect(
        statusSelect,
        [{ value: "all", label: "All statuses" }].concat(
          statusOrder.map(function (status) {
            return { value: status, label: status };
          })
        ),
        "Must"
      );

      roleSelect.addEventListener("change", function () {
        renderRows(data);
      });
      statusSelect.addEventListener("change", function () {
        renderRows(data);
      });
      searchInput.addEventListener("input", function () {
        renderRows(data);
      });

      renderRows(data);
    })
    .catch(function () {
      summary.textContent = "Unable to load the role matrix data for this page.";
    });
})();
