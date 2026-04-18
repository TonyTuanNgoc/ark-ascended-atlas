import { ENTITY_TYPES } from "./data.js";
import {
  findEntity,
  loadState,
  resetState,
  saveState,
  updateEntity,
  updateSetting,
  upsertEntity,
} from "./store.js";

const appRoot = document.querySelector("#app");
const adminDrawer = document.querySelector("#adminDrawer");
const modalRoot = document.querySelector("#modalRoot");
const adminToggleButton = document.querySelector("#adminToggle");
const filePicker = document.querySelector("#imageFilePicker");

const collectionLabels = Object.fromEntries(
  ENTITY_TYPES.map((entry) => [entry.key, entry.label])
);

let state = loadState();

const ui = {
  editMode: false,
  editMapCards: false,
  activeBossId: null,
  mapTabs: {},
  route: parseRoute(),
  admin: {
    collectionKey: "maps",
    entityId: "the-island",
  },
  imageModal: null,
};

function parseRoute() {
  const hash = window.location.hash.replace(/^#\/?/, "");
  if (!hash) return { type: "home", section: "home" };

  const [segment, id] = hash.split("/");
  if (segment === "map" && id) {
    return { type: "map", id };
  }

  const sections = [
    "story",
    "maps",
    "route",
    "bosses",
    "tames",
    "resources",
    "settings",
    "lore",
    "rankings",
  ];

  if (sections.includes(segment)) {
    return { type: "home", section: segment };
  }

  return { type: "home", section: "home" };
}

function render() {
  ui.route = parseRoute();
  appRoot.innerHTML =
    ui.route.type === "map"
      ? renderMapPage(ui.route.id)
      : renderHomePage(ui.route.section);
  adminDrawer.innerHTML = renderAdminDrawer();
  adminDrawer.classList.toggle("is-open", ui.editMode);
  adminDrawer.setAttribute("aria-hidden", String(!ui.editMode));
  modalRoot.innerHTML = renderModal();
  adminToggleButton.classList.toggle("is-active", ui.editMode);

  requestAnimationFrame(() => {
    if (ui.route.type === "home" && ui.route.section !== "home") {
      document
        .querySelector(`#section-${ui.route.section}`)
        ?.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  });
}

function renderHomePage(section) {
  return `
    <div class="page-shell page-shell--hero-only">
      ${renderHero()}
    </div>
  `;
}

function renderHero() {
  const maps = (state.maps || []).filter(Boolean);
  const coreStoryIds = [
    "the-island",
    "scorched-earth",
    "aberration",
    "extinction",
  ];
  const canonExpansionIds = ["lost-colony"];
  const nonCanonIds = [
    "the-center",
    "ragnarok",
    "valguero",
    "astraeos",
  ];

  const groupedMaps = {
    coreStory: [],
    canonExpansion: [],
    nonCanon: [],
  };

  const lookup = new Map(maps.map((map) => [map.id, map]));

  const assignOrdered = (ids, bucket) => {
    ids.forEach((id) => {
      if (lookup.has(id)) {
        groupedMaps[bucket].push(lookup.get(id));
      }
    });
  };

  assignOrdered(coreStoryIds, "coreStory");
  assignOrdered(canonExpansionIds, "canonExpansion");
  assignOrdered(nonCanonIds, "nonCanon");

  const allOrderedIds = new Set([
    ...coreStoryIds,
    ...canonExpansionIds,
    ...nonCanonIds,
  ]);
  const extraMaps = maps.filter((map) => !allOrderedIds.has(map.id));
  groupedMaps.nonCanon = groupedMaps.nonCanon.concat(extraMaps);


  return `
    <section class="hero-panel">
      <div class="hero-panel__veil"></div>
      <div class="hero-panel__atlas"></div>
      <div class="hero-panel__content">
        <h1>${escapeHtml(state.meta.title)}</h1>
        <div class="hero-panel__actions">
          ${state.meta.heroActions
            .map(
              (action, index) => `
                <a class="${
                  index === 0 ? "hero-button hero-button--primary" : "hero-button"
                }" href="${escapeHtml(action.href)}">
                  ${escapeHtml(action.label)}
                </a>
              `
            )
            .join("")}
        </div>
        <div class="hero-map-toolbar">
          <span class="hero-map-toolbar__label">Map card media controls</span>
          <button
            class="ghost-button"
            type="button"
            data-action="toggle-map-card-edit"
          >
            ${ui.editMapCards ? "Finish editing cards" : "Edit map cards"}
          </button>
        </div>
        <div class="hero-map-groups">
          <div class="hero-map-group">
            <div class="hero-map-group__title">Core Story Route</div>
            <div class="hero-map-grid">
              ${renderHeroMapCards(groupedMaps.coreStory, "Story")}
            </div>
          </div>
          <div class="hero-map-group">
            <div class="hero-map-group__title">Canon Expansion</div>
            <div class="hero-map-grid">
              ${renderHeroMapCards(groupedMaps.canonExpansion, "Canon Expansion")}
            </div>
          </div>
          <div class="hero-map-group">
            <div class="hero-map-group__title">Non-Canon / Explore Maps</div>
            <div class="hero-map-grid">
              ${renderHeroMapCards(groupedMaps.nonCanon, "Non-Canon")}
            </div>
          </div>
        </div>
      </div>
    </section>
  `;
}

function renderHeroMapCards(maps, badgeLabel = "") {
  return (maps || [])
    .map(
      (map) => `
        <a class="hero-map-tile" href="#/map/${escapeHtml(map.id)}">
          ${renderHeroMapCardMedia(map)}
          ${
            badgeLabel
              ? `<span class="hero-map-tile__badge">${escapeHtml(
                  badgeLabel
                )}</span>`
              : ""
          }
          <span class="hero-map-tile__name">${escapeHtml(map.name)}</span>
        </a>
      `
    )
    .join("");
}

function renderHeroMapCardMedia(map) {
  const shortName = (map.name || "M").slice(0, 2);
  return renderMediaSlot("maps", map, {
    className: "hero-map-tile__media",
    label: String(map.name || "Map"),
    placeholderLabel: shortName,
    emptyLabel: "Add image",
    showActions: ui.editMapCards,
  });
}

function renderHomeQuickNav(activeSection) {
  const items = [
    { id: "story", label: "Story Route" },
    { id: "maps", label: "Explore Maps" },
    { id: "route", label: "Fastest Clear" },
    { id: "bosses", label: "Boss Planner" },
    { id: "tames", label: "Tame Planner" },
    { id: "resources", label: "Resources" },
    { id: "settings", label: "Server Settings" },
    { id: "lore", label: "Lore" },
    { id: "rankings", label: "Rankings" },
  ];

  return `
    <section class="section-rail">
      ${items
        .map(
          (item) => `
            <a class="section-rail__link ${
              activeSection === item.id ? "is-active" : ""
            }" href="#/${item.id}">
              ${escapeHtml(item.label)}
            </a>
          `
        )
        .join("")}
    </section>
  `;
}

function renderSectionShell(id, title, description, content) {
  return `
    <section id="section-${id}" class="content-section">
      <div class="section-heading">
        <p class="eyebrow">Atlas Module</p>
        <div>
          <h2>${escapeHtml(title)}</h2>
          <p>${escapeHtml(description)}</p>
        </div>
      </div>
      ${content}
    </section>
  `;
}

function renderStoryRoute() {
  const canonicalOrder = [
    "the-island",
    "scorched-earth",
    "aberration",
    "extinction",
    "lost-colony",
  ];

  return `
    <div class="timeline-grid">
      ${canonicalOrder
        .map((mapId, index) => {
          const map = getMap(mapId);
          return `
            <article class="timeline-card">
              <span class="timeline-card__step">0${index + 1}</span>
              <h3>${escapeHtml(map.name)}</h3>
              <p>${escapeHtml(map.story.place)}</p>
              <div class="timeline-card__micro">
                <span>${escapeHtml(map.story.objective)}</span>
                <span>${escapeHtml(map.story.next)}</span>
              </div>
              <a class="text-link" href="#/map/${map.id}">Open map dossier</a>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderExploreMaps() {
  return `
    <div class="poster-grid">
      ${state.maps.map((map) => renderMapPosterCard(map)).join("")}
    </div>
  `;
}

function renderMapPosterCard(map) {
  return `
    <article class="poster-card">
      ${renderMediaSlot("maps", map, {
        className: "poster-card__media",
        label: "Map Poster",
        aspect: "poster",
        showActions: ui.editMapCards,
      })}
      <div class="poster-card__body">
        <div class="chip-row">${renderTagList(map.tags)}</div>
        <h3>${escapeHtml(map.name)}</h3>
        <p>${escapeHtml(map.vibe)}</p>
        <div class="poster-card__meta">
          <span>${escapeHtml(map.classification.type)}</span>
          <span>${escapeHtml(map.classification.access)}</span>
          <span>${escapeHtml(map.role)}</span>
        </div>
        <a class="text-link" href="#/map/${map.id}">Open map dossier</a>
      </div>
    </article>
  `;
}

function renderFastestRoute() {
  return `
    <div class="phase-grid">
      ${state.fastestRoute
        .map(
          (phase) => `
            <article class="phase-card">
              <p class="eyebrow">${escapeHtml(phase.phase)}</p>
              <h3>${escapeHtml(phase.title)}</h3>
              <p>${escapeHtml(phase.focus)}</p>
              <div class="chip-row">${renderTagList(phase.priorities)}</div>
            </article>
          `
        )
        .join("")}
    </div>
  `;
}

function renderBossPlanner() {
  const featured = state.bosses.slice(0, 8);
  return `
    <div class="boss-grid">
      ${featured.map((boss) => renderBossCard(boss)).join("")}
    </div>
  `;
}

function renderBossCard(boss, compact = false) {
  const map = getMap(boss.mapId);
  return `
    <article class="boss-card ${compact ? "boss-card--compact" : ""}">
      ${renderMediaSlot("bosses", boss, {
        className: "boss-card__media",
        label: "Boss Image",
        aspect: "poster",
      })}
      <div class="boss-card__body">
        <div class="chip-row">${renderTagList(boss.tags || [])}</div>
        <h3>${escapeHtml(boss.name)}</h3>
        <p>${escapeHtml(boss.shortDescription || boss.difficultyFeel || "")}</p>
        <div class="stat-inline">
          <span>${escapeHtml(map?.name || "Unknown Map")}</span>
          <span>${escapeHtml(boss.mainDanger || "Threat notes pending")}</span>
        </div>
        <button
          class="text-link button-reset"
          type="button"
          data-action="open-boss"
          data-boss-id="${boss.id}"
        >
          Open boss dossier
        </button>
      </div>
    </article>
  `;
}

function renderGlobalTamePlanner() {
  const stageBuckets = ["early", "mid", "industrial", "boss prep", "endgame"];
  return `
    <div class="stack-grid">
      ${stageBuckets
        .map((stage) => {
          const dinos = state.dinos.filter((dino) => dino.stages.includes(stage));
          return `
            <article class="stack-panel">
              <div class="section-heading section-heading--compact">
                <div>
                  <h3>${escapeHtml(capitalize(stage))}</h3>
                  <p>${dinos.length} dino picks that pay off in this stage.</p>
                </div>
              </div>
              <div class="mini-card-grid">
                ${dinos.slice(0, 4).map((dino) => renderDinoCard(dino, true)).join("")}
              </div>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderResourcesHub() {
  const artifactCards = state.artifacts.slice(0, 8).map(renderArtifactCard).join("");
  const tributeCards = state.tributeItems.slice(0, 8).map(renderTributeCard).join("");
  const itemCards = state.items.slice(0, 6).map(renderItemCard).join("");

  return `
    <div class="resource-shell">
      <div class="resource-column">
        <div class="section-heading section-heading--compact">
          <div>
            <h3>Artifacts</h3>
            <p>Quick route cards that stay linked to boss prep.</p>
          </div>
        </div>
        <div class="mini-card-grid">${artifactCards}</div>
      </div>
      <div class="resource-column">
        <div class="section-heading section-heading--compact">
          <div>
            <h3>Tribute Items</h3>
            <p>Where each item drops and how to batch it cleanly.</p>
          </div>
        </div>
        <div class="mini-card-grid">${tributeCards}</div>
      </div>
      <div class="resource-column">
        <div class="section-heading section-heading--compact">
          <div>
            <h3>Core Gear Chain</h3>
            <p>Only the gear that changes whether the run feels rich or fragile.</p>
          </div>
        </div>
        <div class="mini-card-grid">${itemCards}</div>
      </div>
    </div>
  `;
}

function renderServerSettings() {
  return `
    <div class="setting-grid">
      ${state.serverSettings
        .map(
          (setting) => `
            <article class="setting-card">
              <span class="setting-card__label">${escapeHtml(setting.label)}</span>
              ${
                ui.editMode
                  ? `<input class="setting-card__input" data-setting-key="${setting.key}" value="${escapeHtml(
                      setting.value
                    )}" />`
                  : `<strong>${escapeHtml(setting.value)}</strong>`
              }
              <p>${escapeHtml(setting.target)}</p>
            </article>
          `
        )
        .join("")}
    </div>
  `;
}

function renderLoreRecords() {
  return `
    <div class="record-grid">
      ${state.loreRecords
        .map(
          (record) => `
            <article class="record-card">
              <h3>${escapeHtml(record.title)}</h3>
              <p>${escapeHtml(record.text)}</p>
            </article>
          `
        )
        .join("")}
    </div>
  `;
}

function renderRankings() {
  return `
    <div class="ranking-grid">
      ${state.rankings
        .map((entry) => {
          const map = getMap(entry.mapId);
          return `
            <article class="ranking-card">
              <div class="ranking-card__score">${entry.score}</div>
              <div class="ranking-card__body">
                <p class="eyebrow">${escapeHtml(entry.title)}</p>
                <h3>${escapeHtml(map?.name || entry.mapId)}</h3>
                <p>${escapeHtml(entry.summary)}</p>
                <div class="chip-row">${renderTagList(entry.badges)}</div>
              </div>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderMapPage(mapId) {
  const map = getMap(mapId);
  if (!map) {
    return `
      <div class="page-shell">
        <section class="content-section">
          <div class="empty-state">
            <h2>Map record not found</h2>
            <p>This dossier does not exist yet. Use edit mode to create it or return to the atlas.</p>
            <a class="hero-button hero-button--primary" href="#/maps">Back to maps</a>
          </div>
        </section>
      </div>
    `;
  }

  const tabs = [
    ["overview", "Overview"],
    ["story", "Story / Lore"],
    ["progression", "Fastest Progression"],
    ["tames", "Tame Planner"],
    ["resources", "Resource Route"],
    ["bases", "Base Spots"],
    ["artifacts", "Artifacts & Caves"],
    ["bosses", "Boss Prep"],
    ["transfer", "Transfer-Out Point"],
  ];
  const activeTab = ui.mapTabs[mapId] || "overview";

  return `
    <div class="page-shell page-shell--map">
      <section class="map-hero">
        <div class="map-hero__poster">
          ${renderMediaSlot("maps", map, {
            className: "map-hero__media",
            label: "Map Poster",
            aspect: "hero",
          })}
        </div>
        <div class="map-hero__content">
          <a class="text-link" href="#/maps">Back to atlas</a>
          <div class="chip-row">${renderTagList(map.tags)}</div>
          <h1>${escapeHtml(map.name)}</h1>
          <p class="map-hero__vibe">${escapeHtml(map.vibe)}</p>
          <p>${escapeHtml(map.shortDescription)}</p>
          <div class="stat-ribbon">
            <span><strong>Role</strong> ${escapeHtml(map.role)}</span>
            <span><strong>Type</strong> ${escapeHtml(map.classification.type)}</span>
            <span><strong>Access</strong> ${escapeHtml(map.classification.access)}</span>
          </div>
        </div>
      </section>

      <section class="tab-strip">
        ${tabs
          .map(
            ([key, label]) => `
              <button
                type="button"
                class="tab-button ${activeTab === key ? "is-active" : ""}"
                data-action="map-tab"
                data-map-id="${map.id}"
                data-tab="${key}"
              >
                ${escapeHtml(label)}
              </button>
            `
          )
          .join("")}
      </section>

      <section class="content-section content-section--tabbed">
        ${renderMapTab(map, activeTab)}
      </section>
    </div>
  `;
}

function renderMapTab(map, tab) {
  switch (tab) {
    case "overview":
      return `
        <div class="overview-layout">
          <article class="focus-card">
            <p class="eyebrow">Map Role</p>
            <h2>${escapeHtml(map.role)}</h2>
            <p>${escapeHtml(map.whyPlay)}</p>
          </article>
          <article class="focus-card">
            <p class="eyebrow">Vibe</p>
            <h2>${escapeHtml(map.vibe)}</h2>
            <p>${escapeHtml(map.shortDescription)}</p>
          </article>
          <article class="focus-card">
            <p class="eyebrow">Why This Map Matters</p>
            <div class="chip-row">${renderTagList(map.tags)}</div>
            <p>${escapeHtml(map.whyPlay)}</p>
          </article>
        </div>
      `;
    case "story":
      return `
        <div class="record-grid">
          <article class="record-card">
            <h3>Where You Are</h3>
            <p>${escapeHtml(map.story.place)}</p>
          </article>
          <article class="record-card">
            <h3>What You Are Doing</h3>
            <p>${escapeHtml(map.story.objective)}</p>
          </article>
          <article class="record-card">
            <h3>What Happens Next</h3>
            <p>${escapeHtml(map.story.next)}</p>
          </article>
        </div>
      `;
    case "progression":
      return `
        <div class="phase-grid">
          ${map.progression
            .map(
              (phase) => `
                <article class="phase-card">
                  <p class="eyebrow">${escapeHtml(phase.stage)}</p>
                  <h3>${escapeHtml(phase.focus)}</h3>
                  <div class="chip-row">${renderTagList(phase.bullets)}</div>
                </article>
              `
            )
            .join("")}
        </div>
      `;
    case "tames":
      return renderMapTamePlanner(map);
    case "resources":
      return `
        <div class="mini-card-grid">
          ${map.resourceRoutes
            .map(
              (route) => `
                <article class="detail-card">
                  <span class="detail-card__label">${escapeHtml(route.resource)}</span>
                  <h3>${escapeHtml(route.tool)}</h3>
                  <p>${escapeHtml(route.route)}</p>
                  <div class="chip-row">${renderTagList([`Risk ${route.risk}`])}</div>
                </article>
              `
            )
            .join("")}
        </div>
      `;
    case "bases":
      return renderBaseSpots(map.baseSpotIds);
    case "artifacts":
      return renderMapArtifacts(map);
    case "bosses":
      return renderMapBossPrep(map);
    case "transfer":
      return `
        <div class="transfer-grid">
          <article class="focus-card">
            <p class="eyebrow">Leave When</p>
            <p>${escapeHtml(map.transferOut.leaveWhen)}</p>
          </article>
          <article class="focus-card">
            <p class="eyebrow">Carry Forward</p>
            <div class="chip-row">${renderTagList(map.transferOut.carry)}</div>
          </article>
          <article class="focus-card">
            <p class="eyebrow">Keep Blueprints</p>
            <div class="chip-row">${renderTagList(map.transferOut.blueprints)}</div>
          </article>
          <article class="focus-card">
            <p class="eyebrow">Keep Bloodlines</p>
            <div class="chip-row">${renderTagList(map.transferOut.bloodline)}</div>
          </article>
        </div>
      `;
    default:
      return "";
  }
}

function renderMapTamePlanner(map) {
  const dinos = map.tameIds.map((id) => getDino(id)).filter(Boolean);
  if (!dinos.length) {
    return renderEmptyState(
      "No tame notes yet",
      "Use edit mode to add map-specific tame cards and route notes."
    );
  }

  const stageLegend = ["early", "mid", "industrial", "boss prep", "endgame"];
  const roleLegend = [
    "Berry",
    "Wood",
    "Stone",
    "Metal",
    "Weight",
    "Flyer",
    "Cave",
    "Water",
    "Boss DPS",
    "Tank",
    "Support",
    "Breeder",
    "Utility",
  ];

  return `
    <div class="legend-shell">
      <article class="legend-card">
        <p class="eyebrow">Role Filters</p>
        <div class="chip-row">${renderTagList(roleLegend)}</div>
      </article>
      <article class="legend-card">
        <p class="eyebrow">Stage Filters</p>
        <div class="chip-row">${renderTagList(stageLegend.map(capitalize))}</div>
      </article>
    </div>
    <div class="mini-card-grid">
      ${dinos.map((dino) => renderDinoCard(dino)).join("")}
    </div>
  `;
}

function renderMapArtifacts(map) {
  if (!map.caveRuns.length) {
    return renderEmptyState(
      "Field notes pending",
      "This map can hold artifact and cave routes here when you are ready to document them."
    );
  }

  return `
    <div class="mini-card-grid">
      ${map.caveRuns
        .map((run) => {
          const artifact = getArtifact(run.artifactId);
          return `
            <article class="detail-card detail-card--artifact">
              ${artifact
                ? renderMediaSlot("artifacts", artifact, {
                    className: "detail-card__media",
                    label: "Artifact",
                    aspect: "square",
                  })
                : ""}
              <span class="detail-card__label">${escapeHtml(run.cave)}</span>
              <h3>${escapeHtml(artifact?.name || run.artifactId)}</h3>
              <p>${escapeHtml(run.danger)}</p>
              <div class="stat-stack">
                <span><strong>Mount</strong> ${escapeHtml(run.mount)}</span>
                <span><strong>Gear</strong> ${escapeHtml(run.gear)}</span>
                <span><strong>Difficulty</strong> ${escapeHtml(run.difficulty)}</span>
              </div>
              <div class="chip-row">
                ${run.bossIds.map((bossId) => renderBossChip(bossId)).join("")}
              </div>
            </article>
          `;
        })
        .join("")}
    </div>
  `;
}

function renderMapBossPrep(map) {
  const bosses = map.bossIds.map((id) => getBoss(id)).filter(Boolean);
  if (!bosses.length) {
    return renderEmptyState(
      "Boss dossier not filled yet",
      "This map still has room for your own boss page or progression notes."
    );
  }

  return `
    <div class="boss-prep-grid">
      ${bosses
        .map(
          (boss) => `
            <article class="boss-prep-card">
              <div class="boss-prep-card__head">
                <div>
                  <p class="eyebrow">${escapeHtml(boss.arena)}</p>
                  <h3>${escapeHtml(boss.name)}</h3>
                </div>
                <button
                  class="ghost-button ghost-button--small"
                  type="button"
                  data-action="open-boss"
                  data-boss-id="${boss.id}"
                >
                  Open
                </button>
              </div>
              <p>${escapeHtml(boss.mainDanger)}</p>
              <div class="chip-row">${renderTagList(boss.tags || [])}</div>
              <div class="stat-stack">
                ${(boss.stats || [])
                  .slice(0, 4)
                  .map(
                    (stat) => `
                      <span><strong>${escapeHtml(stat.label)}</strong> ${escapeHtml(stat.value)}</span>
                    `
                  )
                  .join("")}
              </div>
            </article>
          `
        )
        .join("")}
    </div>
  `;
}

function renderBaseSpots(baseSpotIds) {
  const spots = baseSpotIds.map((id) => getBaseSpot(id)).filter(Boolean);
  if (!spots.length) {
    return renderEmptyState(
      "Base spots not documented yet",
      "Add main base, crafting base, forward base, breeding base, and staging base records in edit mode."
    );
  }

  return `
    <div class="mini-card-grid">
      ${spots.map((spot) => renderBaseSpotCard(spot)).join("")}
    </div>
  `;
}

function renderDinoCard(dino, compact = false) {
  return `
    <article class="dino-card ${compact ? "dino-card--compact" : ""}">
      ${renderMediaSlot("dinos", dino, {
        className: "dino-card__media",
        label: "Dino Image",
        aspect: "square",
      })}
      <div class="dino-card__body">
        <h3>${escapeHtml(dino.name)}</h3>
        <div class="chip-row">${renderTagList(dino.roleTags)}</div>
        <div class="chip-row chip-row--subtle">${renderTagList(dino.stages.map(capitalize))}</div>
        <div class="stat-stack">
          <span><strong>Tame Difficulty</strong> ${escapeHtml(dino.tameDifficulty)}</span>
          <span><strong>Time to Value</strong> ${escapeHtml(dino.timeToValue)}</span>
          <span><strong>Cost vs Payoff</strong> ${escapeHtml(dino.costPayoff)}</span>
          <span><strong>Transfer Value</strong> ${escapeHtml(dino.transferValue)}</span>
          <span><strong>Boss Relevance</strong> ${escapeHtml(dino.bossRelevance)}</span>
        </div>
        <p>${escapeHtml(dino.shortDescription || dino.notes)}</p>
      </div>
    </article>
  `;
}

function renderArtifactCard(artifact) {
  return `
    <article class="detail-card detail-card--artifact">
      ${renderMediaSlot("artifacts", artifact, {
        className: "detail-card__media",
        label: "Artifact Image",
        aspect: "square",
      })}
      <span class="detail-card__label">${escapeHtml(getMap(artifact.mapId)?.name || "")}</span>
      <h3>${escapeHtml(artifact.name)}</h3>
      <p>${escapeHtml(artifact.quickRoute)}</p>
      <div class="chip-row">${renderTagList([artifact.cave, artifact.difficulty])}</div>
    </article>
  `;
}

function renderTributeCard(tribute) {
  return `
    <article class="detail-card">
      ${renderMediaSlot("tributeItems", tribute, {
        className: "detail-card__media",
        label: "Tribute Image",
        aspect: "square",
      })}
      <span class="detail-card__label">${escapeHtml(tribute.sourceCreature)}</span>
      <h3>${escapeHtml(tribute.name)}</h3>
      <p>${escapeHtml(tribute.sourceMethod)}</p>
      <div class="chip-row">${renderTagList([tribute.where, tribute.estimate])}</div>
    </article>
  `;
}

function renderItemCard(item) {
  return `
    <article class="detail-card">
      ${renderMediaSlot("items", item, {
        className: "detail-card__media",
        label: "Item Image",
        aspect: "square",
      })}
      <div class="chip-row">${renderTagList(item.tags || [])}</div>
      <h3>${escapeHtml(item.name)}</h3>
      <p>${escapeHtml(item.shortDescription)}</p>
    </article>
  `;
}

function renderBaseSpotCard(spot) {
  return `
    <article class="detail-card">
      ${renderMediaSlot("baseSpots", spot, {
        className: "detail-card__media",
        label: "Base Spot",
        aspect: "poster",
      })}
      <span class="detail-card__label">${escapeHtml(spot.type)}</span>
      <h3>${escapeHtml(spot.title)}</h3>
      <p>${escapeHtml(spot.shortDescription)}</p>
      <div class="chip-row">${renderTagList(spot.tags)}</div>
    </article>
  `;
}

function renderBossChip(bossId) {
  const boss = getBoss(bossId);
  if (!boss) return "";
  return `
    <button
      class="chip chip--button"
      type="button"
      data-action="open-boss"
      data-boss-id="${boss.id}"
    >
      ${escapeHtml(boss.name)}
    </button>
  `;
}

function renderMediaSlot(collectionKey, entity, options = {}) {
  const aspectClass = options.aspect ? `media-slot--${options.aspect}` : "";
  const toneClass = entity.media?.tone ? `tone-${entity.media.tone}` : "tone-bronze";
  const hasImage = Boolean(entity.media?.src);
  const title = escapeHtml(entity.name || entity.title || options.label || "Image");
  const placeholderLabel = escapeHtml(options.placeholderLabel || entity.media?.alt || title);
  const emptyLabel = escapeHtml(options.emptyLabel || "No image bound yet");
  const showImageTools = options.showActions ?? ui.editMode;

  return `
    <div class="media-slot ${options.className || ""} ${aspectClass} ${toneClass}">
      ${
        hasImage
          ? `<img src="${escapeAttribute(entity.media.src)}" alt="${title}" loading="lazy" />`
          : `
            <div class="media-slot__placeholder">
              <span>${placeholderLabel}</span>
              <small>${emptyLabel}</small>
            </div>
          `
      }
      <div class="media-slot__shade"></div>
      ${
        showImageTools
          ? `
            <div class="media-slot__actions">
              <button
                class="ghost-button ghost-button--small"
                type="button"
                data-action="image-url"
                data-collection="${collectionKey}"
                data-entity-id="${entity.id}"
              >
                Add URL
              </button>
              <button
                class="ghost-button ghost-button--small"
                type="button"
                data-action="image-upload"
                data-collection="${collectionKey}"
                data-entity-id="${entity.id}"
              >
                Upload
              </button>
              ${
                hasImage
                  ? `
                    <button
                      class="ghost-button ghost-button--small"
                      type="button"
                      data-action="image-remove"
                      data-collection="${collectionKey}"
                      data-entity-id="${entity.id}"
                    >
                      Remove
                    </button>
                  `
                  : ""
              }
            </div>
          `
          : ""
      }
    </div>
  `;
}

function renderAdminDrawer() {
  const collectionKey = ui.admin.collectionKey;
  const collection = state[collectionKey] || [];
  const currentEntity =
    collection.find((entry) => entry.id === ui.admin.entityId) || collection[0] || null;
  const isNew = ui.admin.entityId === "__new__";
  const entity = isNew ? createBlankEntity(collectionKey) : currentEntity;
  const titleValue = entity.name || entity.title || "";
  const shortValue =
    entity.shortDescription ||
    entity.difficultyFeel ||
    entity.vibe ||
    entity.notes ||
    "";
  const tagsValue = (entity.tags || entity.roleTags || []).join(", ");
  const relatedValue = (entity.relatedIds || entity.artifacts || entity.tributeItems || []).join(", ");
  const auxA =
    entity.mapId ||
    entity.type ||
    entity.role ||
    entity.sourceCreature ||
    entity.classification?.type ||
    "";
  const auxB =
    entity.stages?.join(", ") ||
    entity.access ||
    entity.classification?.access ||
    entity.where ||
    entity.arena ||
    "";

  return `
    <div class="admin-drawer__inner">
      <div class="admin-drawer__header">
        <div>
          <p class="eyebrow">Edit Mode</p>
          <h2>Atlas Admin</h2>
          <p>All image slots are editable. Data saves locally in this browser profile.</p>
        </div>
        <button class="ghost-button" type="button" data-action="toggle-admin">Close</button>
      </div>

      <div class="admin-type-row">
        ${ENTITY_TYPES.map(
          (entry) => `
            <button
              type="button"
              class="chip chip--button ${
                collectionKey === entry.key ? "chip--active" : ""
              }"
              data-action="admin-collection"
              data-collection="${entry.key}"
            >
              ${escapeHtml(entry.label)}
            </button>
          `
        ).join("")}
      </div>

      <div class="admin-entity-select">
        <label>
          Existing ${escapeHtml(collectionLabels[collectionKey])}
          <select id="adminEntitySelect">
            <option value="__new__">Create New</option>
            ${collection
              .map(
                (entry) => `
                  <option value="${entry.id}" ${
                    !isNew && entry.id === entity.id ? "selected" : ""
                  }>
                    ${escapeHtml(entry.name || entry.title || entry.id)}
                  </option>
                `
              )
              .join("")}
          </select>
        </label>
      </div>

      <form id="adminForm" class="admin-form">
        <input type="hidden" name="collectionKey" value="${collectionKey}" />
        <label>
          ID
          <input name="id" value="${escapeHtml(entity.id || "")}" placeholder="the-island" required />
        </label>
        <label>
          Title / Name
          <input name="title" value="${escapeHtml(titleValue)}" placeholder="Entity title" required />
        </label>
        <label>
          Short Description
          <textarea name="shortDescription" rows="3" placeholder="Short readable summary">${escapeHtml(
            shortValue
          )}</textarea>
        </label>
        <label>
          Tags / Roles
          <input name="tags" value="${escapeHtml(tagsValue)}" placeholder="Story, Free, Boss Core" />
        </label>
        <label>
          Related Links
          <input name="relatedIds" value="${escapeHtml(
            relatedValue
          )}" placeholder="boss-id, artifact-id, dino-id" />
        </label>
        <label>
          Auxiliary Field A
          <input
            name="auxA"
            value="${escapeHtml(auxA)}"
            placeholder="${escapeHtml(getAuxPlaceholderA(collectionKey))}"
          />
        </label>
        <label>
          Auxiliary Field B
          <input
            name="auxB"
            value="${escapeHtml(auxB)}"
            placeholder="${escapeHtml(getAuxPlaceholderB(collectionKey))}"
          />
        </label>
        <div class="admin-form__media-tools">
          <span class="admin-form__media-label">Image Tools</span>
          ${
            entity.id
              ? `
                <button
                  type="button"
                  class="ghost-button ghost-button--small"
                  data-action="image-url"
                  data-collection="${collectionKey}"
                  data-entity-id="${entity.id}"
                >
                  Add image by URL
                </button>
                <button
                  type="button"
                  class="ghost-button ghost-button--small"
                  data-action="image-upload"
                  data-collection="${collectionKey}"
                  data-entity-id="${entity.id}"
                >
                  Upload local
                </button>
                <button
                  type="button"
                  class="ghost-button ghost-button--small"
                  data-action="image-remove"
                  data-collection="${collectionKey}"
                  data-entity-id="${entity.id}"
                >
                  Remove image
                </button>
              `
              : `<span class="admin-form__hint">Save the entity once to bind media tools cleanly.</span>`
          }
        </div>
        <div class="admin-form__actions">
          <button class="hero-button hero-button--primary" type="submit">Save Entry</button>
          <button class="ghost-button" type="button" data-action="reset-data">Reset Local Data</button>
        </div>
      </form>
    </div>
  `;
}

function renderModal() {
  if (ui.imageModal) {
    return renderImageUrlModal();
  }

  if (ui.activeBossId) {
    return renderBossModal(ui.activeBossId);
  }

  return "";
}

function renderImageUrlModal() {
  const { collectionKey, entityId } = ui.imageModal;
  const entity = findEntity(state, collectionKey, entityId);
  const currentUrl = entity?.media?.src || "";
  const title = entity?.name || entity?.title || entityId;

  return `
    <div class="modal-backdrop" data-action="close-modal">
      <div class="modal-panel modal-panel--image" role="dialog" aria-modal="true">
        <div class="modal-panel__header">
          <div>
            <p class="eyebrow">Image by URL</p>
            <h2>${escapeHtml(title)}</h2>
          </div>
          <button class="ghost-button" type="button" data-action="close-modal">Close</button>
        </div>
        <form id="imageUrlForm" class="image-url-form">
          <input type="hidden" name="collectionKey" value="${collectionKey}" />
          <input type="hidden" name="entityId" value="${entityId}" />
          <label>
            Paste image URL
            <input
              id="imageUrlInput"
              name="url"
              type="url"
              value="${escapeHtml(currentUrl)}"
              placeholder="https://example.com/ark-image.jpg"
              required
            />
          </label>
          <div class="image-preview-frame">
            ${
              currentUrl
                ? `<img id="imageUrlPreview" src="${escapeAttribute(currentUrl)}" alt="${escapeHtml(
                    title
                  )}" />`
                : `<div id="imageUrlPreview" class="image-preview-frame__placeholder">Preview will appear here</div>`
            }
          </div>
          <div class="modal-panel__footer">
            <button class="ghost-button" type="button" data-action="close-modal">Cancel</button>
            <button class="hero-button hero-button--primary" type="submit">Confirm</button>
          </div>
        </form>
      </div>
    </div>
  `;
}

function renderBossModal(bossId) {
  const boss = getBoss(bossId);
  if (!boss) return "";
  const map = getMap(boss.mapId);
  const artifactCards = (boss.artifacts || [])
    .map((id) => getArtifact(id))
    .filter(Boolean);
  const tributeCards = (boss.tributeItems || [])
    .map((id) => getTribute(id))
    .filter(Boolean);

  return `
    <div class="modal-backdrop" data-action="close-modal">
      <div class="modal-panel modal-panel--boss" role="dialog" aria-modal="true">
        <div class="modal-panel__header">
          <div>
            <p class="eyebrow">${escapeHtml(map?.name || "Unknown Map")}</p>
            <h2>${escapeHtml(boss.name)}</h2>
            <p>${escapeHtml(boss.difficultyFeel)}</p>
          </div>
          <button class="ghost-button" type="button" data-action="close-modal">Close</button>
        </div>
        <div class="boss-modal-grid">
          <div class="boss-modal-grid__hero">
            ${renderMediaSlot("bosses", boss, {
              className: "boss-modal-grid__media",
              label: "Boss Image",
              aspect: "hero",
            })}
            <div class="stat-ribbon">
              <span><strong>Arena</strong> ${escapeHtml(boss.arena)}</span>
              <span><strong>Main Danger</strong> ${escapeHtml(boss.mainDanger)}</span>
              <span><strong>Difficulties</strong> ${escapeHtml((boss.tags || []).join(" / "))}</span>
            </div>
          </div>

          <div class="boss-modal-grid__section">
            <h3>Required Artifacts</h3>
            <div class="mini-card-grid">
              ${
                artifactCards.length
                  ? artifactCards.map(renderArtifactCard).join("")
                  : renderInlineEmpty("No artifacts listed yet")
              }
            </div>
          </div>

          <div class="boss-modal-grid__section">
            <h3>Required Tribute Items</h3>
            <div class="mini-card-grid">
              ${
                tributeCards.length
                  ? tributeCards.map(renderTributeCard).join("")
                  : renderInlineEmpty("No tribute items listed yet")
              }
            </div>
          </div>

          <div class="boss-modal-grid__section boss-modal-grid__section--split">
            <article class="focus-card">
              <p class="eyebrow">Dino Lineup</p>
              <div class="stat-stack">
                ${(boss.lineup || [])
                  .map((entry) => {
                    const creature =
                      getDino(entry.creatureId)?.name || capitalize(entry.creatureId.replace(/-/g, " "));
                    return `
                      <span>
                        <strong>${escapeHtml(entry.role)}</strong>
                        ${escapeHtml(creature)} x ${escapeHtml(entry.quantity)}
                        <small>${escapeHtml(entry.note)}</small>
                      </span>
                    `;
                  })
                  .join("")}
              </div>
            </article>
            <article class="focus-card">
              <p class="eyebrow">Stats</p>
              <div class="stat-stack">
                ${(boss.stats || [])
                  .map(
                    (stat) => `
                      <span><strong>${escapeHtml(stat.label)}</strong> ${escapeHtml(stat.value)}</span>
                    `
                  )
                  .join("")}
              </div>
            </article>
          </div>

          <div class="boss-modal-grid__section boss-modal-grid__section--split">
            <article class="focus-card">
              <p class="eyebrow">Gear Checklist</p>
              <div class="chip-row">${renderTagList(boss.gear || [])}</div>
            </article>
            <article class="focus-card">
              <p class="eyebrow">Mistakes To Avoid</p>
              <div class="chip-row chip-row--warning">${renderTagList(boss.mistakes || [])}</div>
            </article>
          </div>

          <div class="boss-modal-grid__section">
            <h3>Strategy</h3>
            <div class="strategy-list">
              ${(boss.strategy || [])
                .map(
                  (line, index) => `
                    <article class="strategy-step">
                      <span>0${index + 1}</span>
                      <p>${escapeHtml(line)}</p>
                    </article>
                  `
                )
                .join("")}
            </div>
          </div>
        </div>
      </div>
    </div>
  `;
}

function renderEmptyState(title, text) {
  return `
    <div class="empty-state">
      <h2>${escapeHtml(title)}</h2>
      <p>${escapeHtml(text)}</p>
    </div>
  `;
}

function renderInlineEmpty(text) {
  return `<div class="inline-empty">${escapeHtml(text)}</div>`;
}

function getMap(id) {
  return state.maps.find((entry) => entry.id === id);
}

function getBoss(id) {
  return state.bosses.find((entry) => entry.id === id);
}

function getDino(id) {
  return state.dinos.find((entry) => entry.id === id);
}

function getArtifact(id) {
  return state.artifacts.find((entry) => entry.id === id);
}

function getTribute(id) {
  return state.tributeItems.find((entry) => entry.id === id);
}

function getBaseSpot(id) {
  return state.baseSpots.find((entry) => entry.id === id);
}

function createBlankEntity(collectionKey) {
  const base = {
    id: "",
    name: "",
    title: "",
    shortDescription: "",
    tags: [],
    relatedIds: [],
    media: { src: "", type: "empty", alt: "Awaiting image", tone: "bronze" },
  };

  if (collectionKey === "maps") {
    return {
      ...base,
      vibe: "",
      whyPlay: "",
      classification: { type: "Side", access: "Free" },
      role: "",
      story: { place: "", objective: "", next: "" },
      progression: [],
      tameIds: [],
      resourceRoutes: [],
      baseSpotIds: [],
      caveRuns: [],
      bossIds: [],
      transferOut: { leaveWhen: "", carry: [], blueprints: [], bloodline: [] },
    };
  }

  if (collectionKey === "bosses") {
    return {
      ...base,
      mapId: "",
      arena: "",
      difficultyFeel: "",
      mainDanger: "",
      tags: [],
      artifacts: [],
      tributeItems: [],
      lineup: [],
      stats: [],
      gear: [],
      strategy: [],
      mistakes: [],
    };
  }

  if (collectionKey === "dinos") {
    return {
      ...base,
      roleTags: [],
      stages: [],
      tameDifficulty: "",
      timeToValue: "",
      costPayoff: "",
      transferValue: "",
      bossRelevance: "",
      notes: "",
    };
  }

  if (collectionKey === "artifacts") {
    return {
      ...base,
      mapId: "",
      cave: "",
      quickRoute: "",
      difficulty: "",
      bosses: [],
    };
  }

  if (collectionKey === "tributeItems") {
    return {
      ...base,
      sourceCreature: "",
      sourceMethod: "",
      where: "",
      estimate: "",
    };
  }

  if (collectionKey === "baseSpots") {
    return {
      ...base,
      mapId: "",
      type: "",
      title: "",
    };
  }

  return base;
}

function getAuxPlaceholderA(collectionKey) {
  const map = {
    maps: "Map role",
    bosses: "Map ID or arena",
    dinos: "Primary map or main role",
    items: "Primary usage",
    artifacts: "Map ID or cave",
    tributeItems: "Source creature",
    baseSpots: "Map ID or base type",
  };
  return map[collectionKey] || "Aux field A";
}

function getAuxPlaceholderB(collectionKey) {
  const map = {
    maps: "Access type (Free / Paid)",
    bosses: "Difficulty tags or warning",
    dinos: "Stages comma separated",
    items: "Secondary usage",
    artifacts: "Difficulty or route note",
    tributeItems: "Where to farm",
    baseSpots: "Tags or travel note",
  };
  return map[collectionKey] || "Aux field B";
}

function renderTagList(tags) {
  return (tags || [])
    .filter(Boolean)
    .map((tag) => `<span class="chip">${escapeHtml(tag)}</span>`)
    .join("");
}

function capitalize(value) {
  if (!value) return "";
  return value
    .split(" ")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function escapeAttribute(value) {
  return escapeHtml(value).replaceAll("'", "&#39;");
}

function openImageUrlModal(collectionKey, entityId) {
  ui.imageModal = { collectionKey, entityId };
  render();
}

function closeModal() {
  ui.activeBossId = null;
  ui.imageModal = null;
  render();
}

function persist() {
  saveState(state);
  render();
}

function setEntityImage(collectionKey, entityId, src, type = "url") {
  updateEntity(state, collectionKey, entityId, (entity) => ({
    ...entity,
    media: {
      ...(entity.media || {
        alt: entity.name || entity.title || entityId,
        tone: entity.media?.tone || "bronze",
      }),
      src,
      type,
    },
  }));
  persist();
}

function removeEntityImage(collectionKey, entityId) {
  updateEntity(state, collectionKey, entityId, (entity) => ({
    ...entity,
    media: {
      ...(entity.media || {}),
      src: "",
      type: "empty",
    },
  }));
  persist();
}

function buildEntityFromForm(formData) {
  const collectionKey = formData.get("collectionKey");
  const id = slugify(formData.get("id"));
  const title = String(formData.get("title") || "").trim();
  const shortDescription = String(formData.get("shortDescription") || "").trim();
  const tags = toList(formData.get("tags"));
  const relatedIds = toList(formData.get("relatedIds"));
  const auxA = String(formData.get("auxA") || "").trim();
  const auxB = String(formData.get("auxB") || "").trim();
  const existing = findEntity(state, collectionKey, id) || createBlankEntity(collectionKey);
  const displayKey = collectionKey === "baseSpots" ? "title" : "name";

  const shared = {
    ...existing,
    id,
    [displayKey]: title,
    shortDescription,
    tags,
    relatedIds,
    media: existing.media || {
      src: "",
      type: "empty",
      alt: title || id,
      tone: "bronze",
    },
  };

  switch (collectionKey) {
    case "maps":
      return {
        ...shared,
        name: title,
        vibe: shortDescription || existing.vibe || "",
        whyPlay: existing.whyPlay || shortDescription || "",
        role: auxA || existing.role || "",
        classification: {
          type:
            existing.classification?.type ||
            (tags.includes("Story") ? "Story" : "Side"),
          access: auxB || existing.classification?.access || "Free",
        },
      };
    case "bosses":
      return {
        ...shared,
        name: title,
        mapId: auxA || existing.mapId || "",
        arena: auxB || existing.arena || "Arena",
        difficultyFeel: shortDescription || existing.difficultyFeel || "",
      };
    case "dinos":
      return {
        ...shared,
        name: title,
        roleTags: tags,
        stages: toList(auxB || existing.stages?.join(", ")),
        notes: shortDescription || existing.notes || "",
        mapId: auxA || existing.mapId || "",
      };
    case "artifacts":
      return {
        ...shared,
        name: title,
        mapId: auxA || existing.mapId || "",
        cave: auxB || existing.cave || "",
        quickRoute: shortDescription || existing.quickRoute || "",
      };
    case "tributeItems":
      return {
        ...shared,
        name: title,
        sourceCreature: auxA || existing.sourceCreature || "",
        where: auxB || existing.where || "",
        sourceMethod: shortDescription || existing.sourceMethod || "",
      };
    case "baseSpots":
      return {
        ...shared,
        title,
        mapId: auxA || existing.mapId || "",
        type: auxB || existing.type || "",
      };
    case "items":
    default:
      return {
        ...shared,
        name: title,
      };
  }
}

function slugify(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function toList(value) {
  return String(value || "")
    .split(",")
    .map((entry) => entry.trim())
    .filter(Boolean);
}

function syncImagePreview() {
  const input = document.querySelector("#imageUrlInput");
  const preview = document.querySelector("#imageUrlPreview");
  if (!input || !preview) return;

  const url = input.value.trim();
  if (!url) {
    preview.outerHTML =
      '<div id="imageUrlPreview" class="image-preview-frame__placeholder">Preview will appear here</div>';
    return;
  }

  const img = document.createElement("img");
  img.id = "imageUrlPreview";
  img.src = url;
  img.alt = "Image preview";
  preview.replaceWith(img);
}

window.addEventListener("hashchange", render);

document.addEventListener("click", (event) => {
  const actionTarget = event.target.closest("[data-action]");
  if (!actionTarget) return;

    const { action } = actionTarget.dataset;

  if (action === "image-url" || action === "image-upload" || action === "image-remove") {
    event.preventDefault();
    event.stopPropagation();
  }

  if (action === "toggle-admin") {
    ui.editMode = !ui.editMode;
    render();
    return;
  }

  if (action === "admin-collection") {
    ui.admin.collectionKey = actionTarget.dataset.collection;
    ui.admin.entityId = "__new__";
    render();
    return;
  }

  if (action === "open-boss") {
    ui.activeBossId = actionTarget.dataset.bossId;
    ui.imageModal = null;
    render();
    return;
  }

  if (action === "close-modal") {
    if (event.target === actionTarget) {
      closeModal();
    }
    return;
  }

  if (action === "map-tab") {
    ui.mapTabs[actionTarget.dataset.mapId] = actionTarget.dataset.tab;
    render();
    return;
  }

  if (action === "toggle-map-card-edit") {
    ui.editMapCards = !ui.editMapCards;
    render();
    return;
  }

  if (action === "image-url") {
    openImageUrlModal(
      actionTarget.dataset.collection,
      actionTarget.dataset.entityId
    );
    return;
  }

  if (action === "image-upload") {
    filePicker.dataset.collection = actionTarget.dataset.collection;
    filePicker.dataset.entityId = actionTarget.dataset.entityId;
    filePicker.click();
    return;
  }

  if (action === "image-remove") {
    removeEntityImage(
      actionTarget.dataset.collection,
      actionTarget.dataset.entityId
    );
    return;
  }

  if (action === "reset-data") {
    state = resetState();
    ui.activeBossId = null;
    ui.imageModal = null;
    render();
  }
});

document.addEventListener("change", (event) => {
  if (event.target.id === "adminEntitySelect") {
    ui.admin.entityId = event.target.value;
    render();
    return;
  }

  const settingKey = event.target.dataset.settingKey;
  if (settingKey) {
    updateSetting(state, settingKey, event.target.value);
    saveState(state);
  }
});

document.addEventListener("input", (event) => {
  if (event.target.id === "imageUrlInput") {
    syncImagePreview();
  }
});

document.addEventListener("paste", (event) => {
  if (event.target && event.target.id === "imageUrlInput") {
    window.setTimeout(syncImagePreview, 0);
  }
});

document.addEventListener("submit", async (event) => {
  if (event.target.id === "adminForm") {
    event.preventDefault();
    const formData = new FormData(event.target);
    const collectionKey = formData.get("collectionKey");
    const entity = buildEntityFromForm(formData);
    upsertEntity(state, collectionKey, entity);
    ui.admin.entityId = entity.id;
    persist();
    return;
  }

  if (event.target.id === "imageUrlForm") {
    event.preventDefault();
    const formData = new FormData(event.target);
    setEntityImage(
      formData.get("collectionKey"),
      formData.get("entityId"),
      String(formData.get("url") || "").trim(),
      "url"
    );
    ui.imageModal = null;
    render();
  }
});

filePicker.addEventListener("change", async (event) => {
  const file = event.target.files?.[0];
  const collectionKey = filePicker.dataset.collection;
  const entityId = filePicker.dataset.entityId;
  if (!file || !collectionKey || !entityId) return;

  const dataUrl = await readFileAsDataUrl(file);
  setEntityImage(collectionKey, entityId, dataUrl, "local");
  filePicker.value = "";
});

function readFileAsDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result));
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

render();
