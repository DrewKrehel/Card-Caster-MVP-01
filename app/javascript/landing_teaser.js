document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".js-rotatable-card").forEach(card => {
    card.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();

      const current = parseInt(card.dataset.rotation || "0", 10);
      const next = (current + 90) % 360;

      card.dataset.rotation = next.toString();
    });
  });
});
