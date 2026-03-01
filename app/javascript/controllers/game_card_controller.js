import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    faceUp: Boolean,
    orientation: Number
  }

  connect() {
    // Track state
    this.isFaceUp = this.faceUpValue
    this.cumulativeRotation = this.orientationValue * 90

    // Apply initial transform
    this.applyTransform()
  }

  applyTransform() {
    const inner = this.element.querySelector('.card-inner');
    if (!inner) return;

    const flipY = this.isFaceUp ? 180 : 0;
    // rotateZ for orientation; rotateY for flip
    inner.style.transform = `rotateZ(${this.cumulativeRotation}deg) rotateY(${flipY}deg)`;
  }

  async flip(event) {
    event.preventDefault()

    const button = event.target
    const form = button.closest('form')
    if (!form) return

    // Update state immediately (optimistic)
    this.isFaceUp = form.action.includes('face_up=true')
    this.applyTransform()

    // Submit in background (don't wait)
    form.requestSubmit()
  }

  async rotate(event) {
    event.preventDefault()

    const button = event.target
    const form = button.closest('form')
    if (!form) return

    const direction = form.action.includes('direction=cw') ? 'cw' : 'ccw'

    // Update immediately (optimistic)
    if (direction === 'cw') {
      this.cumulativeRotation += 90
    } else {
      this.cumulativeRotation -= 90
    }

    this.applyTransform()

    // Submit in background
    form.requestSubmit()
  }

  async move(event) {
    event.preventDefault()

    const button = event.target
    const form = button.closest('form')
    if (!form) return

    const card = this.element.querySelector('.playing-card')
    card.classList.add('animating-move-out')

    // Wait for animation, then submit
    await this.delay(400)
    form.requestSubmit()
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}
