// Hero Stats (Stars + Visits)
export async function initStats() {
  const STAR_CACHE_KEY = 'puase_star_cache';
  const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

  function formatCount(num) {
    if (num >= 1000) return (num / 1000).toFixed(1).replace(/\.0$/, '') + 'k';
    return String(num);
  }

  async function loadStarCount() {
    const starEl = document.getElementById('star-count');
    if (!starEl) return;

    // Check cache first
    try {
      const cached = localStorage.getItem(STAR_CACHE_KEY);
      if (cached) {
        const { count, timestamp } = JSON.parse(cached);
        if (Date.now() - timestamp < CACHE_TTL) {
          starEl.textContent = formatCount(count);
          return;
        }
      }
    } catch (e) { console.warn('[PuaSE] Star cache parse failed:', e); }

    try {
      const res = await fetch('https://api.github.com/repos/zeekling/PuaSE');
      if (!res.ok) throw new Error('GitHub API error');
      const data = await res.json();
      const count = data.stargazers_count || 0;
      starEl.textContent = formatCount(count);
      localStorage.setItem(STAR_CACHE_KEY, JSON.stringify({ count, timestamp: Date.now() }));
    } catch (e) { console.warn('[PuaSE] Failed to load star count:', e.message); }
  }

  async function loadVisitCount() {
    const visitEl = document.getElementById('visit-count');
    if (!visitEl) return;

    try {
      const res = await fetch('https://countapi.mileshilliard.com/api/v1/hit/PuaSE-visits');
      if (!res.ok) throw new Error('CountAPI error');
      const data = await res.json();
      if (data && data.value !== undefined) {
        visitEl.textContent = formatCount(data.value);
      }
    } catch (e) { console.warn('[PuaSE] Failed to load visit count:', e.message); }
  }

  await Promise.allSettled([loadStarCount(), loadVisitCount()]);
}
