import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    index: { type: Number, default: -1 }
  }

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    this.element.addEventListener("keydown", this.handleKeydown)

    if (this.indexValue < 0 || this.indexValue >= this.tabTargets.length) {
      this.indexValue = this.initialActiveIndex()
    }
    this.updateState()
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeydown)
  }

  initialActiveIndex() {
    const selectedIdx = this.tabTargets.findIndex(
      (tab) => tab.getAttribute("aria-selected") === "true" || tab.classList.contains("active")
    )
    return selectedIdx >= 0 ? selectedIdx : 0
  }

  select(event) {
    if (event) {
      event.preventDefault()
    }
    const clickedTab = event.currentTarget
    const idx = this.tabTargets.indexOf(clickedTab)
    if (idx >= 0) {
      this.activateTab(idx, { focus: false })
    }
  }

  activateTab(idx, { focus = true } = {}) {
    if (idx < 0 || idx >= this.tabTargets.length) {
      return
    }
    const previousIndex = this.renderedIndex
    this.indexValue = idx
    this.updateState()

    if (focus && this.tabTargets[idx]) {
      this.tabTargets[idx].focus()
    }

    if (previousIndex !== undefined && previousIndex !== idx) {
      const activeTab = this.tabTargets[idx]
      const activePanel = this.panelForTab(activeTab, idx)
      this.dispatch("changed", {
        detail: { index: idx, tab: activeTab, panel: activePanel }
      })
    }
  }

  indexValueChanged(value) {
    if (value < 0 || value >= this.tabTargets.length) {
      return
    }
    this.updateState()
  }

  updateState() {
    if (this.tabTargets.length === 0) {
      return
    }

    const activeIdx = Math.max(0, Math.min(this.indexValue, this.tabTargets.length - 1))

    this.tabTargets.forEach((tab, idx) => {
      const isActive = idx === activeIdx
      tab.setAttribute("aria-selected", isActive.toString())
      tab.setAttribute("tabindex", isActive ? "0" : "-1")
      tab.classList.toggle("active", isActive)

      const activeClasses = (tab.dataset.tabsActiveClass || "").split(/\s+/).filter(Boolean)
      const inactiveClasses = (tab.dataset.tabsInactiveClass || "").split(/\s+/).filter(Boolean)

      if (isActive) {
        if (inactiveClasses.length > 0) tab.classList.remove(...inactiveClasses)
        if (activeClasses.length > 0) tab.classList.add(...activeClasses)
      } else {
        if (activeClasses.length > 0) tab.classList.remove(...activeClasses)
        if (inactiveClasses.length > 0) tab.classList.add(...inactiveClasses)
      }

      const countPill = tab.querySelector("[data-tabs-count]")
      if (countPill) {
        const pillActiveClasses = (countPill.dataset.tabsActiveClass || "").split(/\s+/).filter(Boolean)
        const pillInactiveClasses = (countPill.dataset.tabsInactiveClass || "").split(/\s+/).filter(Boolean)

        if (isActive) {
          if (pillInactiveClasses.length > 0) countPill.classList.remove(...pillInactiveClasses)
          if (pillActiveClasses.length > 0) countPill.classList.add(...pillActiveClasses)
        } else {
          if (pillActiveClasses.length > 0) countPill.classList.remove(...pillActiveClasses)
          if (pillInactiveClasses.length > 0) countPill.classList.add(...pillInactiveClasses)
        }
      }

      const panel = this.panelForTab(tab, idx)
      if (panel) {
        const hiddenClass = panel.dataset.tabsHiddenClass
        panel.classList.toggle("show", isActive)
        panel.classList.toggle("active", isActive)

        if (isActive) {
          if (hiddenClass) panel.classList.remove(hiddenClass)
          panel.removeAttribute("hidden")
        } else if (hiddenClass) {
          panel.classList.add(hiddenClass)
        }
      }
    })

    this.renderedIndex = activeIdx
  }

  panelForTab(tab, idx) {
    const controlsId = tab.getAttribute("aria-controls")
    if (controlsId) {
      const controlled = this.panelTargets.find((panel) => panel.id === controlsId)
      if (controlled) {
        return controlled
      }
    }
    return this.panelTargets[idx] || null
  }

  enabledTabIndices() {
    return this.tabTargets
      .map((tab, idx) => (!tab.disabled && tab.getAttribute("aria-disabled") !== "true" ? idx : -1))
      .filter((idx) => idx >= 0)
  }

  handleKeydown(event) {
    const currentTab = event.target.closest("[role='tab']")
    if (!currentTab || !this.tabTargets.includes(currentTab)) {
      return
    }

    const enabled = this.enabledTabIndices()
    if (enabled.length === 0) {
      return
    }

    const currentIdx = this.tabTargets.indexOf(currentTab)
    const currentPos = enabled.indexOf(currentIdx)

    if (event.key === "ArrowRight") {
      event.preventDefault()
      const nextPos = currentPos < 0 ? 0 : (currentPos + 1) % enabled.length
      this.activateTab(enabled[nextPos], { focus: true })
    } else if (event.key === "ArrowLeft") {
      event.preventDefault()
      const prevPos = currentPos <= 0 ? enabled.length - 1 : currentPos - 1
      this.activateTab(enabled[prevPos], { focus: true })
    } else if (event.key === "Home") {
      event.preventDefault()
      this.activateTab(enabled[0], { focus: true })
    } else if (event.key === "End") {
      event.preventDefault()
      this.activateTab(enabled[enabled.length - 1], { focus: true })
    }
  }
}
