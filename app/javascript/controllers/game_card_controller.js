import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    faceUp: Boolean,
    orientation: Number
  }

  connect() {
    this.isAnimating = false
  }

  // Intercept flip action
  async flip(event) {
    if (this.isAnimating) {
      event.preventDefault()
      return
    }

    event.preventDefault() // Stop the form submission
    this.isAnimating = true

    // Find the form - button_to creates a form around the button
    const button = event.target
    const form = button.closest('form')
    
    if (!form) {
      console.error('No form found for flip button')
      this.isAnimating = false
      return
    }

    const willBeFaceUp = form.action.includes('face_up=true')
    const currentlyFaceUp = this.faceUpValue

    if (currentlyFaceUp === willBeFaceUp) {
      this.isAnimating = false
      form.requestSubmit()
      return
    }

    // Animate the card-frame, not the whole card
    const cardFrame = this.element.querySelector('.card-frame')
    
    // Add animation class
    if (willBeFaceUp) {
      cardFrame.classList.add('animating-flip')
    } else {
      cardFrame.classList.add('animating-unflip')
    }

    // Wait for animation to complete BEFORE submitting
    await this.delay(600)

    // Now submit the form
    form.requestSubmit()
    
    // Clean up
    setTimeout(() => {
      cardFrame.classList.remove('animating-flip', 'animating-unflip')
      this.isAnimating = false
    }, 100)
  }

  // Intercept rotate action
  async rotate(event) {
    if (this.isAnimating) {
      event.preventDefault()
      return
    }

    event.preventDefault() // Stop the form submission
    this.isAnimating = true

    const button = event.target
    const form = button.closest('form')
    
    if (!form) {
      console.error('No form found for rotate button')
      this.isAnimating = false
      return
    }

    const direction = form.action.includes('direction=cw') ? 'cw' : 'ccw'
    const card = this.element.querySelector('.playing-card')
    const cardImage = card.querySelector('.card-image')
    const currentRotation = this.orientationValue * 90

    let toRotation
    if (direction === 'cw') {
      toRotation = ((this.orientationValue + 1) % 4) * 90
    } else {
      toRotation = ((this.orientationValue - 1 + 4) % 4) * 90
    }

    // Hide controls during animation to prevent visual glitch
    const controls = card.querySelector('.card-controls')
    if (controls) {
      controls.style.opacity = '0'
      controls.style.pointerEvents = 'none'
    }

    // Animate the IMAGE only, not the controls
    cardImage.style.transition = 'transform 0.4s ease-in-out'
    cardImage.style.transform = `rotate(${toRotation}deg)`

    // Wait for animation to complete
    await this.delay(400)

    // Now submit the form
    form.requestSubmit()
    
    // Clean up
    setTimeout(() => {
      if (controls) {
        controls.style.opacity = ''
        controls.style.pointerEvents = ''
      }
      cardImage.style.transition = ''
      this.isAnimating = false
    }, 100)
  }

  // Intercept move action
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

    // Wait for animation
    await this.delay(400)

    // Now submit
    form.requestSubmit()
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}
