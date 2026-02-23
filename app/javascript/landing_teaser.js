document.addEventListener("turbo:load", () => {
  const container = document.querySelector(".teaser-cards");
  if (!container) return;

  const cards = Array.from(container.querySelectorAll(".js-rotatable-card"));
  const shuffleBtn = document.getElementById("teaserShuffle");
  if (!cards.length || !shuffleBtn) return;

  const rotationMap = new Map();

  // Initialize
  cards.forEach(card => {
    rotationMap.set(card, 0);

    card.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();

      let current = rotationMap.get(card);
      current += 90; // always clockwise
      rotationMap.set(card, current);

      applyTransform(card);
    });

    card.addEventListener("mouseenter", () => {
      card.classList.toggle("is-flipped");
    });
  });

  function applyTransform(card, extra = { x: 0, y: 0, r: 0 }) {
    const baseRotation = rotationMap.get(card) || 0;

    card.style.transform = `
      translate(${extra.x}px, ${extra.y}px)
      rotate(${baseRotation + extra.r}deg)
    `;
  }

  shuffleBtn.addEventListener("click", () => {
    let shuffled = [...cards];

    // Fisher-Yates
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }

    shuffled.forEach((card, index) => {
      const x = Math.random() * 40 - 20;
      const y = Math.random() * 20 - 10;
      const r = Math.random() * 20 - 10;

      applyTransform(card, { x, y, r });

      setTimeout(() => {
        applyTransform(card); // restore original rotation
        container.appendChild(card);
      }, 400 + index * 50);
    });
  });
});
