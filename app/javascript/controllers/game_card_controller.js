import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    faceUp: Boolean,
    orientation: Number
  }

  connect() {
    this.isAnimating = false
    // Track cumulative rotation to avoid backwards animation
    this.cumulativeRotation = this.orientationValue * 90
    
    // Apply initial rotation on connect
    this.applyRotation()
  }

  applyRotation() {
    const card = this.element.querySelector('.playing-card')
    if (!card) return
    
    const cardInner = card.querySelector('.card-inner')
    if (!cardInner) return
    
    const isFaceUp = card.classList.contains('face-up')
    
    // Apply rotation with flip
    if (isFaceUp) {
      cardInner.style.transform = `rotateY(180deg) rotateZ(${-this.cumulativeRotation}deg)`
    } else {
      cardInner.style.transform = `rotateY(0deg) rotateZ(${this.cumulativeRotation}deg)`
    }
  }

  // Flip just toggles the class and reapplies rotation
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

    // Toggle flip class
    if (willBeFaceUp) {
      card.classList.remove('face-down')
      card.classList.add('face-up')
    } else {
      card.classList.remove('face-up')
      card.classList.add('face-down')
    }
    
    // Reapply rotation with new flip state
    this.applyRotation()

    // Wait for CSS animation to complete
    await this.delay(600)

    // Submit form
    form.requestSubmit()
    
    this.isAnimating = false
  }

  // Rotate with cumulative tracking
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

    // Apply the rotation
    this.applyRotation()

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
