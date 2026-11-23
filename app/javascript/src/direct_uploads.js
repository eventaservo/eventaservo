// ActiveStorage direct upload progress UI.
// ActionText (Trix) also dispatches direct-upload:* events on <trix-editor>
// without an id or initialize event, so guard against missing progress elements.

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail || {}
  if (id == null || !file) return

  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename">${file.name}</span>
    </div>
  `)
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail || {}
  if (id == null) return

  const element = document.getElementById(`direct-upload-${id}`)
  if (!element) return

  element.classList.remove("direct-upload--pending")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail || {}
  if (id == null) return

  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  if (!progressElement) return

  progressElement.style.width = `${progress}%`
})

addEventListener("direct-upload:error", event => {
  const { id, error } = event.detail || {}
  if (id == null) return

  const element = document.getElementById(`direct-upload-${id}`)
  if (!element) return

  event.preventDefault()
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail || {}
  if (id == null) return

  const element = document.getElementById(`direct-upload-${id}`)
  if (!element) return

  element.classList.add("direct-upload--complete")
})
