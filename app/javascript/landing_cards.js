function initLandingCards() {
  const deck = document.getElementById("demoDeck");
  if (!deck) return;

  const cards = Array.from(deck.querySelectorAll(".demo-card"));
  const shuffleBtn = document.getElementById("demoShuffle");
  const rotateBtn = document.getElementById("demoRotate");
  const flipBtn = document.getElementById("demoFlip");

  let deckRotation = 0;

  // SHUFFLE
  shuffleBtn.addEventListener("click", () => {
    cards.forEach(card => {
      const x = Math.random() * 60 - 30;
      const y = Math.random() * 60 - 30;
      const r = Math.random() * 30 - 15;

      card.style.transform = `translate(${x}px, ${y}px) rotate(${r}deg)`;

      setTimeout(() => {
        card.style.transform = "";
      }, 500);
    });
  });

  // ROTATE
  rotateBtn.addEventListener("click", () => {
    deckRotation = (deckRotation + 90) % 360;
    deck.style.transform = `rotate(${deckRotation}deg)`;
  });

  // FLIP (top card only)
  flipBtn.addEventListener("click", () => {
    const topCard = cards[0];
    topCard.classList.toggle("flipped");
  });
}

// Turbo-safe hook
document.addEventListener("turbo:load", initLandingCards);
