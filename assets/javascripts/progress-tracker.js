(function () {
  const pathSelect = document.getElementById("progress-tracker-path");
  if (!pathSelect) {
    return;
  }

  const resetButton = document.getElementById("progress-tracker-reset");
  const summary = document.getElementById("progress-tracker-summary");
  const bar = document.getElementById("progress-tracker-bar");
  const sectionsHost = document.getElementById("progress-tracker-sections");
  const siteRoot = new URL("../", window.location.href);
  const dataUrl = new URL("../assets/data/learning-path.json", window.location.href);
  const storageKey = "genai-notes-progress-v1";

  function loadState() {
    try {
      return JSON.parse(window.localStorage.getItem(storageKey) || "{}");
    } catch (error) {
      return {};
    }
  }

  function saveState(state) {
    window.localStorage.setItem(storageKey, JSON.stringify(state));
  }

  function populatePathSelect(data) {
    pathSelect.innerHTML = "";

    [{ value: "foundation", label: "Universal Foundation" }]
      .concat(
        data.Tracks.map(function (track) {
          return { value: track.Id, label: track.Title };
        })
      )
      .forEach(function (option) {
        const element = document.createElement("option");
        element.value = option.value;
        element.textContent = option.label;
        pathSelect.appendChild(element);
      });
  }

  function buildPathModel(data, selectedValue) {
    if (selectedValue === "foundation") {
      return {
        id: "foundation",
        title: "Universal Foundation",
        sections: data.Foundation
      };
    }

    const track = data.Tracks.find(function (item) {
      return item.Id === selectedValue;
    });

    return {
      id: track.Id,
      title: track.Title,
      sections: data.Foundation.concat([track])
    };
  }

  function hoursFromText(value) {
    const match = String(value || "").match(/([0-9]+(?:\.[0-9]+)?)/);
    return match ? Number(match[1]) : 0;
  }

  function render(data) {
    const progressState = loadState();
    const model = buildPathModel(data, pathSelect.value);
    let totalNotes = 0;
    let completedNotes = 0;
    let totalHours = 0;
    let completedHours = 0;

    sectionsHost.innerHTML = "";

    model.sections.forEach(function (section) {
      const wrapper = document.createElement("section");
      wrapper.className = "progress-section";

      const heading = document.createElement("h2");
      heading.textContent = section.Title;
      wrapper.appendChild(heading);

      const list = document.createElement("div");
      list.className = "progress-list";

      section.Notes.forEach(function (note) {
        const noteKey = model.id + "::" + note.Path;
        const checked = Boolean(progressState[noteKey]);
        totalNotes += 1;
        totalHours += hoursFromText(note.EstTime);
        if (checked) {
          completedNotes += 1;
          completedHours += hoursFromText(note.EstTime);
        }

        const item = document.createElement("label");
        item.className = "progress-item" + (checked ? " completed" : "");
        item.innerHTML =
          '<input type="checkbox" data-progress-key="' +
          noteKey +
          '"' +
          (checked ? " checked" : "") +
          " />" +
          '<span><a href="' +
          new URL(note.SitePath, siteRoot).href +
          '">' +
          note.Title +
          "</a></span>" +
          '<span class="progress-time">' +
          note.EstTime +
          "</span>";
        list.appendChild(item);
      });

      wrapper.appendChild(list);
      sectionsHost.appendChild(wrapper);
    });

    const percentage = totalNotes ? Math.round((completedNotes / totalNotes) * 100) : 0;
    summary.textContent =
      completedNotes +
      " / " +
      totalNotes +
      " notes complete · " +
      percentage +
      "% · " +
      completedHours.toFixed(0) +
      " / " +
      totalHours.toFixed(0) +
      " hours";
    bar.style.width = percentage + "%";

    sectionsHost.querySelectorAll("input[type='checkbox']").forEach(function (input) {
      input.addEventListener("change", function () {
        const nextState = loadState();
        if (input.checked) {
          nextState[input.dataset.progressKey] = true;
        } else {
          delete nextState[input.dataset.progressKey];
        }
        saveState(nextState);
        render(data);
      });
    });
  }

  fetch(dataUrl)
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      populatePathSelect(data);
      pathSelect.addEventListener("change", function () {
        render(data);
      });
      resetButton.addEventListener("click", function () {
        const current = buildPathModel(data, pathSelect.value);
        const nextState = loadState();
        Object.keys(nextState).forEach(function (key) {
          if (key.indexOf(current.id + "::") === 0) {
            delete nextState[key];
          }
        });
        saveState(nextState);
        render(data);
      });
      render(data);
    })
    .catch(function () {
      summary.textContent = "Unable to load the progress tracker data for this page.";
    });
})();
