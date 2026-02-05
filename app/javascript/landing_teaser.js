document.addEventListener("DOMContentLoaded", () => {
  const cards = Array.from(document.querySelectorAll(".js-rotatable-card"));
  const shuffleButton = document.querySelector(".landing-teaser button");

  // Click to rotate 90°
  cards.forEach(card => {
    card.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();

      const current = parseInt(card.dataset.rotation || "0", 10);
      const next = (current + 90) % 360;
      card.dataset.rotation = next.toString();
    });
  });

  // Shuffle cards
  shuffleButton?.addEventListener("click", () => {
    const container = document.querySelector(".teaser-cards");
    if (!container) return;

    // Randomize the array
    const shuffled = cards
      .map(value => ({ value, sort: Math.random() }))
      .sort((a, b) => a.sort - b.sort)
      .map(({ value }) => value);

    // Re-append in shuffled order
    shuffled.forEach(card => container.appendChild(card));
  });
});
