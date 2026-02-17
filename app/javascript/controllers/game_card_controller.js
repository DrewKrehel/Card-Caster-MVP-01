import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    faceUp: Boolean,
    orientation: Number
  }

  connect() {
    this.isAnimating = false
  }

  // Flip just toggles the class - CSS handles animation
  async flip(event) {
    if (this.isAnimating) {
      event.preventDefault()
      return
    }

    event.preventDefault()
    this.isAnimating = true

    const button = event.target
    const form = button.closest('form')
    
    if (!form) {
      console.error('No form found for flip button')
      this.isAnimating = false
      return
    }

    const card = this.element.querySelector('.playing-card')
    const willBeFaceUp = form.action.includes('face_up=true')

    // Toggle flip class - CSS animation happens automatically
    if (willBeFaceUp) {
      card.classList.remove('face-down')
      card.classList.add('face-up')
    } else {
      card.classList.remove('face-up')
      card.classList.add('face-down')
    }

    // Wait for CSS animation to complete
    await this.delay(600)

    // Submit form
    form.requestSubmit()
    
    this.isAnimating = false
  }

  // Rotate updates data attribute - CSS handles animation
  async rotate(event) {
    if (this.isAnimating) {
      event.preventDefault()
      return
    }

    event.preventDefault()
    this.isAnimating = true

    const button = event.target
    const form = button.closest('form')
    
    if (!form) {
      console.error('No form found for rotate button')
      this.isAnimating = false
      return
    }

    const card = this.element.querySelector('.playing-card')
    const direction = form.action.includes('direction=cw') ? 'cw' : 'ccw'
    const currentRotation = this.orientationValue

    let newRotation
    if (direction === 'cw') {
      newRotation = (currentRotation + 1) % 4
    } else {
      newRotation = (currentRotation - 1 + 4) % 4
    }

    // Hide controls during rotation
    const controls = card.querySelector('.card-controls')
    if (controls) {
      controls.style.opacity = '0'
      controls.style.pointerEvents = 'none'
    }

    // Update data attribute - CSS transition handles the rotation
    card.dataset.rotation = newRotation.toString()

    // Wait for transition
    await this.delay(600)

    // Submit form
    form.requestSubmit()
    
    // Restore controls after Turbo updates
    setTimeout(() => {
      if (controls) {
        controls.style.opacity = ''
        controls.style.pointerEvents = ''
      }
      this.isAnimating = false
    }, 100)
  }

  // Move animation
  async move(event) {
    if (this.isAnimating) {
      event.preventDefault()
      return
    }

    event.preventDefault()
    this.isAnimating = true

    const button = event.target
    const form = button.closest('form')
    
    if (!form) {
      console.error('No form found for move button')
      this.isAnimating = false
      return
    }

    const card = this.element.querySelector('.playing-card')
    card.classList.add('animating-move-out')

    await this.delay(400)

    form.requestSubmit()
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}
