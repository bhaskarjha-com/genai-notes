(function () {
  const canvas = document.getElementById("knowledge-graph-canvas");
  if (!canvas) {
    return;
  }

  const ctx = canvas.getContext("2d");
  const folderSelect = document.getElementById("knowledge-graph-folder");
  const difficultySelect = document.getElementById("knowledge-graph-difficulty");
  const trackSelect = document.getElementById("knowledge-graph-track");
  const searchInput = document.getElementById("knowledge-graph-search");
  const summary = document.getElementById("knowledge-graph-summary");
  const siteRoot = new URL("../", window.location.href);
  const dataUrl = new URL("../assets/data/knowledge-graph.json", window.location.href);
  const colors = [
    "#0f766e",
    "#0ea5e9",
    "#c2410c",
    "#7c3aed",
    "#dc2626",
    "#059669",
    "#1d4ed8",
    "#9333ea",
    "#b45309",
    "#4f46e5",
    "#0891b2",
    "#be123c",
    "#15803d",
    "#a16207"
  ];

  const state = {
    data: null,
    nodes: [],
    links: [],
    hoverNode: null,
    draggedNode: null,
    dragMoved: false,
    pointerX: 0,
    pointerY: 0,
    animationFrame: null
  };

  function setCanvasSize() {
    const parentWidth = canvas.parentElement.clientWidth;
    const width = Math.max(720, parentWidth);
    const height = Math.max(520, Math.round(width * 0.62));
    canvas.width = width;
    canvas.height = height;
  }

  function seedNodes(nodes) {
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const radius = Math.min(canvas.width, canvas.height) * 0.28;

    nodes.forEach(function (node, index) {
      const angle = (Math.PI * 2 * index) / Math.max(nodes.length, 1);
      node.x = centerX + Math.cos(angle) * radius;
      node.y = centerY + Math.sin(angle) * radius;
      node.vx = 0;
      node.vy = 0;
    });
  }

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

  function buildControls(data) {
    populateSelect(
      folderSelect,
      [{ value: "all", label: "All folders" }].concat(
        data.Folders.map(function (folder) {
          return { value: folder, label: folder };
        })
      ),
      "all"
    );

    populateSelect(
      difficultySelect,
      [{ value: "all", label: "All difficulties" }].concat(
        data.Difficulties.map(function (difficulty) {
          return { value: difficulty, label: difficulty };
        })
      ),
      "all"
    );

    populateSelect(
      trackSelect,
      [{ value: "all", label: "All tracks" }].concat(
        data.Tracks.map(function (track) {
          return { value: track, label: track };
        })
      ),
      "all"
    );
  }

  function nodeMatchesFilters(node) {
    const folderValue = folderSelect.value;
    const difficultyValue = difficultySelect.value;
    const trackValue = trackSelect.value;
    const searchValue = searchInput.value.trim().toLowerCase();

    if (folderValue !== "all" && node.Folder !== folderValue) {
      return false;
    }

    if (difficultyValue !== "all" && node.Difficulty !== difficultyValue) {
      return false;
    }

    if (trackValue !== "all" && !node.Tracks.includes(trackValue)) {
      return false;
    }

    if (searchValue && node.Title.toLowerCase().indexOf(searchValue) === -1) {
      return false;
    }

    return true;
  }

  function getVisibleGraph() {
    const visibleNodes = state.nodes.filter(nodeMatchesFilters);
    const visibleIds = new Set(
      visibleNodes.map(function (node) {
        return node.Id;
      })
    );

    const visibleLinks = state.links.filter(function (link) {
      return visibleIds.has(link.Source) && visibleIds.has(link.Target);
    });

    return {
      nodes: visibleNodes,
      links: visibleLinks
    };
  }

  function getFolderColor(folder) {
    const folders = state.data ? state.data.Folders : [];
    const index = folders.indexOf(folder);
    return colors[index % colors.length];
  }

  function drawNode(node, hovered) {
    const radius = 6 + Math.min(node.Degree || 0, 10);
    ctx.beginPath();
    ctx.arc(node.x, node.y, radius, 0, Math.PI * 2);
    ctx.fillStyle = getFolderColor(node.Folder);
    ctx.fill();

    if (hovered) {
      ctx.lineWidth = 3;
      ctx.strokeStyle = "rgba(245, 158, 11, 0.9)";
      ctx.stroke();
    }

    if (hovered || radius >= 12) {
      ctx.font = "13px var(--md-text-font, sans-serif)";
      ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue("--genai-ink-soft") || "#475569";
      if(hovered) ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue("--genai-teal") || "#0d9488";
      ctx.fillText(node.Title, node.x + radius + 6, node.y + 4);
    }
  }

  function drawGraph() {
    const visible = getVisibleGraph();
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    visible.links.forEach(function (link) {
      const source = state.nodeMap.get(link.Source);
      const target = state.nodeMap.get(link.Target);
      if (!source || !target) {
        return;
      }

      ctx.beginPath();
      ctx.moveTo(source.x, source.y);
      ctx.lineTo(target.x, target.y);
      ctx.lineWidth = link.Relation === "related" ? 1.5 : 1;
      ctx.strokeStyle = "rgba(100, 116, 139, 0.26)";
      ctx.stroke();
    });

    visible.nodes.forEach(function (node) {
      drawNode(node, state.hoverNode && state.hoverNode.Id === node.Id);
    });

    const summaryText = visible.nodes.length + " notes, " + visible.links.length + " relationships";
    summary.textContent = summaryText;
  }

  function tick() {
    const visible = getVisibleGraph();
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;

    for (let i = 0; i < visible.nodes.length; i += 1) {
      const nodeA = visible.nodes[i];

      if (state.draggedNode && state.draggedNode.Id === nodeA.Id) {
        nodeA.x = state.pointerX;
        nodeA.y = state.pointerY;
        nodeA.vx = 0;
        nodeA.vy = 0;
        continue;
      }

      nodeA.vx += (centerX - nodeA.x) * 0.0009;
      nodeA.vy += (centerY - nodeA.y) * 0.0009;

      for (let j = i + 1; j < visible.nodes.length; j += 1) {
        const nodeB = visible.nodes[j];
        const dx = nodeB.x - nodeA.x;
        const dy = nodeB.y - nodeA.y;
        const distance = Math.max(26, Math.sqrt(dx * dx + dy * dy));
        const force = 3000 / (distance * distance);
        const fx = (dx / distance) * force;
        const fy = (dy / distance) * force;
        nodeA.vx -= fx;
        nodeA.vy -= fy;
        nodeB.vx += fx;
        nodeB.vy += fy;
      }
    }

    visible.links.forEach(function (link) {
      const source = state.nodeMap.get(link.Source);
      const target = state.nodeMap.get(link.Target);
      if (!source || !target) {
        return;
      }

      const dx = target.x - source.x;
      const dy = target.y - source.y;
      const distance = Math.max(12, Math.sqrt(dx * dx + dy * dy));
      const desired = 90 + ((source.Degree + target.Degree) * 0.8);
      const spring = (distance - desired) * 0.0022;
      const fx = (dx / distance) * spring;
      const fy = (dy / distance) * spring;
      source.vx += fx;
      source.vy += fy;
      target.vx -= fx;
      target.vy -= fy;
    });

    visible.nodes.forEach(function (node) {
      if (state.draggedNode && state.draggedNode.Id === node.Id) {
        return;
      }

      node.vx *= 0.85;
      node.vy *= 0.85;
      node.x = Math.min(canvas.width - 22, Math.max(22, node.x + node.vx));
      node.y = Math.min(canvas.height - 22, Math.max(22, node.y + node.vy));
    });

    drawGraph();
    state.animationFrame = window.requestAnimationFrame(tick);
  }

  function getPointerPosition(event) {
    const rect = canvas.getBoundingClientRect();
    return {
      x: ((event.clientX - rect.left) / rect.width) * canvas.width,
      y: ((event.clientY - rect.top) / rect.height) * canvas.height
    };
  }

  function findNodeAt(position) {
    const visible = getVisibleGraph().nodes.slice().reverse();
    return (
      visible.find(function (node) {
        const radius = 6 + Math.min(node.Degree || 0, 10);
        const dx = position.x - node.x;
        const dy = position.y - node.y;
        return Math.sqrt(dx * dx + dy * dy) <= radius + 3;
      }) || null
    );
  }

  function bindEvents() {
    [folderSelect, difficultySelect, trackSelect].forEach(function (element) {
      element.addEventListener("change", function () {
        state.hoverNode = null;
        drawGraph();
      });
    });

    searchInput.addEventListener("input", function () {
      state.hoverNode = null;
      drawGraph();
    });

    canvas.addEventListener("pointerdown", function (event) {
      const position = getPointerPosition(event);
      state.pointerX = position.x;
      state.pointerY = position.y;
      state.draggedNode = findNodeAt(position);
      state.dragMoved = false;
    });

    canvas.addEventListener("pointermove", function (event) {
      const position = getPointerPosition(event);
      state.pointerX = position.x;
      state.pointerY = position.y;

      if (state.draggedNode) {
        state.dragMoved = true;
        return;
      }

      state.hoverNode = findNodeAt(position);
      canvas.style.cursor = state.hoverNode ? "pointer" : "default";
      drawGraph();
    });

    canvas.addEventListener("pointerup", function () {
      const releasedNode = state.draggedNode;
      const moved = state.dragMoved;
      state.draggedNode = null;

      if (releasedNode && !moved) {
        window.location.href = new URL(releasedNode.SitePath, siteRoot).href;
      }
    });

    canvas.addEventListener("pointerleave", function () {
      state.hoverNode = null;
      state.draggedNode = null;
      canvas.style.cursor = "default";
      drawGraph();
    });

    window.addEventListener("resize", function () {
      setCanvasSize();
      drawGraph();
    });
  }

  fetch(dataUrl)
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      state.data = data;
      state.nodes = data.Nodes.map(function (node) {
        return Object.assign({}, node);
      });
      state.links = data.Links;
      state.nodeMap = new Map(
        state.nodes.map(function (node) {
          return [node.Id, node];
        })
      );

      setCanvasSize();
      seedNodes(state.nodes);
      buildControls(data);
      bindEvents();
      drawGraph();
      tick();
    })
    .catch(function () {
      summary.textContent = "Unable to load the graph data for this page.";
    });
})();
