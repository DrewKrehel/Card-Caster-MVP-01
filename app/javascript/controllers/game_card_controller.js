import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    faceUp: Boolean,
    orientation: Number
  }

  connect() {
    this.isAnimating = false
    
    // Track state
    this.isFaceUp = this.faceUpValue
    this.cumulativeRotation = this.orientationValue * 90
    
    // Apply initial transform on connect
    this.applyTransform()
  }

  applyTransform() {
    const cardInner = this.element.querySelector('.card-inner')
    if (!cardInner) return
    
    // CRITICAL: Apply rotation FIRST, then flip
    // This makes the flip axis rotate with the card
    const flipY = this.isFaceUp ? 180 : 0
    
    // When face-up, we DON'T invert rotation anymore
    // because rotation is applied before flip
    cardInner.style.transform = `rotateZ(${this.cumulativeRotation}deg) rotateY(${flipY}deg)`
  }

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

    // Toggle face up state
    this.isFaceUp = form.action.includes('face_up=true')
    
    // Apply the transform (CSS transition will animate it)
    this.applyTransform()

    // Wait for animation
    await this.delay(600)

    // Submit form
    form.requestSubmit()
    
    this.isAnimating = false
  }

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

    // Hide controls during rotation
    const controls = card.querySelector('.card-controls')
    if (controls) {
      controls.style.opacity = '0'
      controls.style.pointerEvents = 'none'
    }

    // Update cumulative rotation
    if (direction === 'cw') {
      this.cumulativeRotation += 90
    } else {
      this.cumulativeRotation -= 90
    }

    // Apply the transform (CSS transition will animate it)
    this.applyTransform()

    // Wait for transition
    await this.delay(600)

    // Submit form
    form.requestSubmit()
    
    // Restore controls
    setTimeout(() => {
      if (controls) {
        controls.style.opacity = ''
        controls.style.pointerEvents = ''
      }
      this.isAnimating = false
    }, 100)
  }

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
