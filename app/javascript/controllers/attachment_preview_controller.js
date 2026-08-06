import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

// Global helper to show the attachment modal
export function openAttachmentModal(data) {
  const modalEl = document.getElementById("attachmentModal")
  if (!modalEl) return

  const titleEl = document.getElementById("attachmentModalTitle")
  const metaEl = document.getElementById("attachmentModalMeta")
  const imgEl = document.getElementById("attachmentModalImage")
  const pdfFrameEl = document.getElementById("attachmentModalPdfFrame")
  const placeholderEl = document.getElementById("attachmentModalFilePlaceholder")
  const placeholderNameEl = document.getElementById("attachmentModalFileName")
  const placeholderSizeEl = document.getElementById("attachmentModalFileSize")
  const openTabEl = document.getElementById("attachmentModalOpenTab")
  const downloadEl = document.getElementById("attachmentModalDownload")

  const filename = data.filename || "Attachment"
  const filesize = data.filesize || ""
  const contentType = data.contentType || ""
  const fileUrl = data.fileUrl || data.previewUrl || ""
  const previewUrl = data.previewUrl || fileUrl
  const downloadUrl = data.downloadUrl || fileUrl

  if (titleEl) titleEl.textContent = filename
  if (metaEl) {
    const parts = []
    if (contentType) parts.push(contentType)
    if (filesize) parts.push(filesize)
    metaEl.textContent = parts.join(" • ")
  }

  if (openTabEl) {
    openTabEl.href = fileUrl || "#"
    openTabEl.setAttribute("target", "_blank")
  }

  if (downloadEl) {
    downloadEl.href = downloadUrl || fileUrl || "#"
    downloadEl.setAttribute("download", filename)
  }

  const isPdf = contentType === "application/pdf" ||
                filename.toLowerCase().endsWith(".pdf") ||
                fileUrl.toLowerCase().includes(".pdf")

  const isImage = !isPdf && (
    (contentType && contentType.startsWith("image/")) ||
    filename.toLowerCase().match(/\.(png|jpe?g|webp|gif|svg)$/i) ||
    data.hasImage
  )

  if (isPdf && fileUrl) {
    // Interactive full-resolution PDF viewer inside modal
    if (pdfFrameEl) {
      pdfFrameEl.src = fileUrl
      pdfFrameEl.classList.remove("d-none")
    }
    if (imgEl) {
      imgEl.src = ""
      imgEl.classList.add("d-none")
    }
    if (placeholderEl) {
      placeholderEl.classList.add("d-none")
    }
  } else if (isImage && (fileUrl || previewUrl)) {
    // High-resolution image (use original fileUrl if available for maximum clarity)
    if (imgEl) {
      imgEl.src = fileUrl || previewUrl
      imgEl.alt = filename
      imgEl.classList.remove("d-none")
    }
    if (pdfFrameEl) {
      pdfFrameEl.src = ""
      pdfFrameEl.classList.add("d-none")
    }
    if (placeholderEl) {
      placeholderEl.classList.add("d-none")
    }
  } else {
    // Non-visual generic file
    if (imgEl) {
      imgEl.src = ""
      imgEl.classList.add("d-none")
    }
    if (pdfFrameEl) {
      pdfFrameEl.src = ""
      pdfFrameEl.classList.add("d-none")
    }
    if (placeholderEl) {
      if (placeholderNameEl) placeholderNameEl.textContent = filename
      if (placeholderSizeEl) placeholderSizeEl.textContent = filesize
      placeholderEl.classList.remove("d-none")
    }
  }

  // Try Bootstrap Modal API
  const ModalClass = window.bootstrap?.Modal || bootstrap?.Modal || bootstrap?.default?.Modal
  if (ModalClass && typeof ModalClass.getOrCreateInstance === "function") {
    try {
      const modal = ModalClass.getOrCreateInstance(modalEl)
      modal.show()
      return
    } catch (e) {
      console.warn("Bootstrap modal API failed, using fallback:", e)
    }
  }

  // Fallback modal open
  modalEl.classList.add("show")
  modalEl.style.display = "block"
  modalEl.removeAttribute("aria-hidden")
  modalEl.setAttribute("aria-modal", "true")
  document.body.classList.add("modal-open")

  let backdrop = document.querySelector(".modal-backdrop")
  if (!backdrop) {
    backdrop = document.createElement("div")
    backdrop.className = "modal-backdrop fade show"
    document.body.appendChild(backdrop)
  }
}

// Global helper to close the attachment modal
export function closeAttachmentModal() {
  const modalEl = document.getElementById("attachmentModal")
  if (!modalEl) return

  // Clear media sources to prevent background memory use
  const imgEl = document.getElementById("attachmentModalImage")
  const pdfFrameEl = document.getElementById("attachmentModalPdfFrame")
  if (imgEl) imgEl.src = ""
  if (pdfFrameEl) pdfFrameEl.src = ""

  const ModalClass = window.bootstrap?.Modal || bootstrap?.Modal || bootstrap?.default?.Modal
  if (ModalClass && typeof ModalClass.getInstance === "function") {
    try {
      const modal = ModalClass.getInstance(modalEl)
      if (modal) {
        modal.hide()
        return
      }
    } catch (e) {
      // fallback
    }
  }

  modalEl.classList.remove("show")
  modalEl.style.display = "none"
  modalEl.setAttribute("aria-hidden", "true")
  modalEl.removeAttribute("aria-modal")
  document.body.classList.remove("modal-open")

  const backdrops = document.querySelectorAll(".modal-backdrop")
  backdrops.forEach(b => b.remove())
}

// Stimulus Controller
export default class extends Controller {
  static values = {
    filename: String,
    filesize: String,
    contentType: String,
    previewUrl: String,
    fileUrl: String,
    downloadUrl: String
  }

  connect() {
    this.element.style.cursor = "pointer"
  }

  open(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    const filename = this.filenameValue || this.element.getAttribute("filename") || "Attachment"
    const filesize = this.filesizeValue || ""
    const contentType = this.contentTypeValue || ""
    const fileUrl = this.fileUrlValue || this.previewUrlValue || ""
    const previewUrl = this.previewUrlValue || fileUrl
    const downloadUrl = this.downloadUrlValue || fileUrl
    const hasImage = !!this.element.querySelector("img")

    openAttachmentModal({ filename, filesize, contentType, previewUrl, fileUrl, downloadUrl, hasImage })
  }
}

// Extract attachment metadata from DOM element
function extractAttachmentData(container) {
  const figure = container.closest("figure.attachment, action-text-attachment, .attachment-card") || container
  const actionText = container.closest("action-text-attachment")
  const img = figure.querySelector("img") || actionText?.querySelector("img")
  const link = figure.querySelector("a") || actionText?.querySelector("a")
  const caption = figure.querySelector("figcaption, .attachment__caption") || actionText?.querySelector("figcaption, .attachment__caption")

  const filename = figure.getAttribute("data-attachment-preview-filename-value") ||
                   actionText?.getAttribute("filename") ||
                   figure.getAttribute("filename") ||
                   caption?.querySelector(".attachment__name")?.textContent?.trim() ||
                   img?.getAttribute("alt") ||
                   "Attachment"

  const filesize = figure.getAttribute("data-attachment-preview-filesize-value") ||
                   (actionText?.getAttribute("filesize") ? `${Math.round(actionText.getAttribute("filesize") / 1024)} KB` : "") ||
                   caption?.querySelector(".attachment__size")?.textContent?.trim() ||
                   ""

  const contentType = figure.getAttribute("data-attachment-preview-content-type-value") ||
                      actionText?.getAttribute("content-type") ||
                      figure.getAttribute("content-type") ||
                      ""

  const fileUrl = figure.getAttribute("data-attachment-preview-file-url-value") ||
                  actionText?.getAttribute("url") ||
                  link?.getAttribute("href") ||
                  img?.getAttribute("src") ||
                  ""

  const previewUrl = figure.getAttribute("data-attachment-preview-preview-url-value") ||
                     fileUrl ||
                     img?.getAttribute("src")

  const downloadUrl = figure.getAttribute("data-attachment-preview-download-url-value") ||
                      fileUrl

  const hasImage = !!img || (!contentType.includes("pdf") && !!previewUrl)

  return { filename, filesize, contentType, fileUrl, previewUrl, downloadUrl, hasImage }
}

// Global click event listener
document.addEventListener("click", (event) => {
  // Check if click was on modal dismiss button or backdrop
  const dismissBtn = event.target.closest("#attachmentModal [data-bs-dismiss='modal'], #attachmentModal .btn-close")
  if (dismissBtn) {
    event.preventDefault()
    closeAttachmentModal()
    return
  }

  const modalEl = document.getElementById("attachmentModal")
  if (event.target === modalEl) {
    closeAttachmentModal()
    return
  }

  // Check if click was on any attachment element (card, zoom button, thumbnail, caption, figure)
  const attachmentTarget = event.target.closest(
    ".attachment-card, .attachment-zoom-badge, .attachment-thumb-wrapper, figure.attachment, action-text-attachment"
  )

  if (attachmentTarget) {
    // If inside an editor and clicking a toolbar/caption editor input, don't intercept
    if (event.target.closest(".attachment__caption-editor, input, textarea")) return

    event.preventDefault()
    event.stopPropagation()

    const data = extractAttachmentData(attachmentTarget)
    openAttachmentModal(data)
  }
})

// Listen for Escape key to close modal
document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    const modalEl = document.getElementById("attachmentModal")
    if (modalEl && modalEl.classList.contains("show")) {
      closeAttachmentModal()
    }
  }
})
