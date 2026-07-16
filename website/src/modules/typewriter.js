// Typewriter Effect
export function typeWriter(el, text, speed = 40) {
  let i = 0;
  el.textContent = '';
  const timer = setInterval(() => {
    if (i < text.length) {
      el.textContent += text.charAt(i);
      i++;
    } else {
      clearInterval(timer);
    }
  }, speed);
}
