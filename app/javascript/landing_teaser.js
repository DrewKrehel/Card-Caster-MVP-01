document.addEventListener("turbo:load", () => {
  const container = document.querySelector(".teaser-cards");
  const cards = Array.from(container.querySelectorAll(".js-rotatable-card"));
  const shuffleBtn = document.getElementById("teaserShuffle");

  if (!cards.length || !shuffleBtn) return;

  // Initialize rotation map
  const rotationMap = new Map();

  cards.forEach(card => {
    rotationMap.set(card, 0);

    // ROTATE on click
    card.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();

      // Increment cumulative rotation
      let currentRotation = rotationMap.get(card) || 0;
      currentRotation += 90; // always clockwise
      rotationMap.set(card, currentRotation);

      // Apply CSS transform using cumulative rotation
      card.style.transform = `rotate(${currentRotation}deg)`;
    });

    // Flip toggle on hover
    card.addEventListener("mouseenter", () => {
      card.classList.toggle("is-flipped");
    });
  });

  // SHUFFLE button
  shuffleBtn.addEventListener("click", () => {
    // Shuffle the array using Fisher-Yates
    let shuffled = [...cards];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }

    // Re-append to container in new order
    shuffled.forEach((card, index) => {
      card.style.transition = "transform 0.4s ease";
      // optional: small scatter animation
      const x = Math.random() * 40 - 20;
      const y = Math.random() * 20 - 10;
      const r = Math.random() * 20 - 10;
      card.style.transform = `translate(${x}px, ${y}px) rotate(${r}deg)`;

      // snap back and reorder in DOM
      setTimeout(() => {
        card.style.transform = "";
        container.appendChild(card); // moves card to new position
      }, 400 + index * 50); // stagger slightly
    });
  });
});
