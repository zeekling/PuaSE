// PuaSE Homepage — Entry point
console.log('PuaSE — 全局编排 Agent');

import i18n from './i18n.js';
import { agentDetailsZh } from './config/agent-details-zh.js';
import { agentDetailsEn } from './config/agent-details.js';
import { typeWriter } from './modules/typewriter.js';
import { initScrollReveal } from './modules/scrollReveal.js';
import { initMobileNav } from './modules/mobileNav.js';
import { initStats } from './modules/stats.js';
import { initVersionSwitcher } from './modules/version.js';

// === State Management ===
let currentLang = localStorage.getItem('puase_lang') || 'zh';
let lastClickedAgent = null;
let lastFocusedElement = null;

// === Language Switching ===
function switchLang(lang) {
  document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';

  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.dataset.i18n;
    const text = i18n[lang]?.[key];
    if (text !== undefined) el.textContent = text;
  });

  // 切换语言时直接设置文本，不播放打字机动画
  const subtitleEl = document.getElementById('hero-subtitle');
  const subtitleText = i18n[lang]?.['hero.subtitle'];
  if (subtitleEl && subtitleText) {
    subtitleEl.textContent = subtitleText;
  }

  // Update modal content if open
  if (agentModal.classList.contains('show') && lastClickedAgent) {
    const detail = currentLang === 'zh'
      ? agentDetailsZh[lastClickedAgent]
      : agentDetailsEn[lastClickedAgent] || agentDetailsZh[lastClickedAgent];
    if (detail) {
      modalBody.innerHTML = `<h3>${detail.name}</h3><p>${detail.desc}</p>`;
    }
  }

  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.lang === lang);
  });

  localStorage.setItem('puase_lang', lang);
  currentLang = lang;
}

// Bind language toggle events
document.querySelectorAll('.lang-btn').forEach(btn => {
  btn.addEventListener('click', () => switchLang(btn.dataset.lang));
});

// === Modal ===
const agentModal = document.getElementById('agent-modal');
const modalBody = document.getElementById('modal-body');
const modalClose = document.querySelector('.modal-close');

function openModal(agentName) {
  lastClickedAgent = agentName;
  lastFocusedElement = document.activeElement;
  const detail = currentLang === 'zh'
    ? agentDetailsZh[agentName]
    : agentDetailsEn[agentName] || agentDetailsZh[agentName] || { name: agentName, desc: 'No details available.' };
  modalBody.innerHTML = `<h3>${detail.name}</h3><p>${detail.desc}</p>`;
  agentModal.classList.add('show');
  setTimeout(() => modalClose.focus(), 50);
}

function closeModal() {
  agentModal.classList.remove('show');
  if (lastFocusedElement) lastFocusedElement.focus();
}

document.querySelectorAll('.agent-card').forEach(card => {
  card.addEventListener('click', () => {
    const agentName = card.dataset.agent;
    if (agentName) openModal(agentName);
  });
});

modalClose.addEventListener('click', closeModal);
agentModal.addEventListener('click', (e) => {
  if (e.target === agentModal) closeModal();
});

// Focus trap: keep Tab cycling within modal elements
agentModal.addEventListener('keydown', (e) => {
  if (e.key !== 'Tab') return;
  const focusable = agentModal.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
  if (focusable.length === 0) return;
  const first = focusable[0];
  const last = focusable[focusable.length - 1];
  if (e.shiftKey) {
    if (document.activeElement === first) {
      e.preventDefault();
      last.focus();
    }
  } else {
    if (document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  }
});

// === Initialize All Modules ===
document.addEventListener('DOMContentLoaded', () => {
  // Initialize animations
  initScrollReveal();
  initMobileNav();

  // Initialize modules
  initVersionSwitcher();
  initStats();

  // Initialize language
  const subtitleEl = document.getElementById('hero-subtitle');
  if (subtitleEl) {
    typeWriter(subtitleEl, i18n[currentLang]?.['hero.subtitle'] || '全局编排 Agent');
  }

  // Initial language switch
  switchLang(currentLang);
});
