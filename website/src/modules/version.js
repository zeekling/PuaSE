// Version Switcher
export async function initVersionSwitcher() {
  const BASE_URL = import.meta.env.BASE_URL;

  function detectCurrentVersion() {
    const basePath = BASE_URL.replace(/\/$/, '');
    const regex = new RegExp(`^${basePath}/versions/(v[\\d.]+)`);
    const match = window.location.pathname.match(regex);
    return match ? match[1] : 'latest';
  }

  const select = document.getElementById('version-select');
  if (!select) return;

  const current = detectCurrentVersion();

  try {
    const res = await fetch(BASE_URL + 'versions/versions.json');
    if (!res.ok) throw new Error('versions.json not found');
    const manifest = await res.json();

    // Build ordered version list: latest first, then all other versions
    select.innerHTML = '';
    const allVersions = [
      { tag: 'latest', label: manifest.latest + ' (latest)', url: BASE_URL },
      ...manifest.versions
        .filter(v => v.tag !== manifest.latest)
        .map(v => ({ tag: v.tag, label: v.tag, url: v.url }))
    ];

    allVersions.forEach(v => {
      const opt = document.createElement('option');
      opt.value = v.tag;
      opt.textContent = v.label;
      if (v.tag === current) opt.selected = true;
      select.appendChild(opt);
    });

    // Switch version on change
    select.addEventListener('change', () => {
      const selected = allVersions.find(v => v.tag === select.value);
      const currentPath = window.location.pathname.replace(/\/$/, '');
      if (selected && selected.url !== currentPath) {
        window.location.href = selected.url;
      }
    });
  } catch (e) {
    console.warn('[PuaSE] Failed to load version manifest:', e.message);
    // Silent fallback — keep default "latest" option, hide if fetch fails
    select.style.display = 'none';
  }
}
