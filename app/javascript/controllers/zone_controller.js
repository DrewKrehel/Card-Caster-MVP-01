import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Animate new cards that are added to this zone
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === 1 && node.classList.contains('card-slot')) {
            const card = node.querySelector('.playing-card')
            if (card) {
              card.classList.add('animating-move-in')
              setTimeout(() => {
                card.classList.remove('animating-move-in')
              }, 400)
            }
          }
        })
      })
    })

    observer.observe(this.element, { childList: true })
    this.observer = observer
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}
