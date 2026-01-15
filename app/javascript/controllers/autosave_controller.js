import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
export default class extends Controller {
  static targets = ["form", "status"]
  static values = {
    url: String,
    interval: { type: Number, default: 5000 } // Default: auto-save every 5 seconds
  }

  connect() {
    this.timeout = null
    this.lastSavedContent = this.getFormData()
    this.setupAutoSave()
  }

  disconnect() {
    this.stopAutoSave()
  }

  setupAutoSave() {
    // Listen to input changes in the form
    this.formTarget.addEventListener("input", this.scheduleAutoSave.bind(this))
    // Also listen to trix-change for rich text editor
    this.formTarget.addEventListener("trix-change", this.scheduleAutoSave.bind(this))
  }

  scheduleAutoSave() {
    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Schedule new auto-save
    this.timeout = setTimeout(() => {
      this.save()
    }, this.intervalValue)
  }

  stopAutoSave() {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }

  async save() {
    const formData = this.getFormData()

    // Don't save if nothing changed
    if (formData === this.lastSavedContent) {
      return
    }

    try {
      this.updateStatus("Saving...")

      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify({
          chapter: this.getFormDataAsObject()
        })
      })

      if (response.ok) {
        this.lastSavedContent = formData
        this.updateStatus("All changes saved", "success")
      } else {
        this.updateStatus("Failed to save", "error")
      }
    } catch (error) {
      console.error("Auto-save error:", error)
      this.updateStatus("Failed to save", "error")
    }
  }

  getFormData() {
    // Get form data as a string for comparison
    const formData = new FormData(this.formTarget)
    return Array.from(formData.entries()).map(([key, value]) => `${key}=${value}`).join("&")
  }

  getFormDataAsObject() {
    const formData = new FormData(this.formTarget)
    const object = {}

    formData.forEach((value, key) => {
      // Remove the 'chapter[' prefix and ']' suffix from field names
      const cleanKey = key.replace(/^chapter\[/, '').replace(/\]$/, '')
      object[cleanKey] = value
    })

    return object
  }

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }

  updateStatus(message, type = "info") {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.className = `autosave-status autosave-status--${type}`

      // Clear success/error messages after 3 seconds
      if (type === "success" || type === "error") {
        setTimeout(() => {
          this.statusTarget.textContent = ""
          this.statusTarget.className = "autosave-status"
        }, 3000)
      }
    }
  }

  // Manual save action (for when user explicitly saves)
  manualSave(event) {
    event.preventDefault()
    this.stopAutoSave()
    this.save()
    this.setupAutoSave()
  }
}
