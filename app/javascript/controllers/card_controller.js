import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number,
    rotation: Number,
    faceUp: Boolean
  }

  connect() {
    this.applyRotation()
    this.applyFlip()
  }

  // CLICK CARD → ROTATE
  rotate(event) {
    event.preventDefault()
    event.stopPropagation()

    this.rotationValue = (this.rotationValue + 90) % 360
    this.applyRotation()

    if (this.hasIdValue) {
      this.persist("rotate", { direction: "cw" })
    }
  }

  // BUTTON → FLIP
  flip(event) {
    event.preventDefault()
    event.stopPropagation()

    this.faceUpValue = !this.faceUpValue
    this.applyFlip()

    if (this.hasIdValue) {
      this.persist("flip", { face_up: this.faceUpValue })
    }
  }

  // BUTTON → MOVE
  move(event) {
    event.preventDefault()
    const zone = event.currentTarget.dataset.cardZoneValue

    fetch(`/playing_cards/${this.idValue}/move`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ zone_name: zone })
    })
  }

  applyRotation() {
    this.element.style.transform = `rotate(${this.rotationValue}deg)`
  }

  applyFlip() {
    const inner = this.element.querySelector(".card-inner")
    if (!inner) return

    inner.classList.add("flipping")
    if (this.faceUpValue) inner.classList.add("flipped")
    else inner.classList.remove("flipped")

    setTimeout(() => inner.classList.remove("flipping"), 400)
  }

  persist(action, body) {
    fetch(`/playing_cards/${this.idValue}/${action}`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json"
      },
      body: JSON.stringify(body)
    })
  }
}
