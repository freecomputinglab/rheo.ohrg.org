const toggle = document.querySelector('.sidebar-toggle');
const sidebar = document.querySelector('.sidebar');
const topbar = document.querySelector('.topbar');

function isMobile() {
  return window.innerWidth <= 768;
}

function initSidebar() {
  if (isMobile()) {
    sidebar.classList.add('hidden');
    topbar.classList.remove('sidebar-open');
    topbar.classList.remove('sidebar-closed');
  } else {
    sidebar.classList.remove('hidden');
    topbar.classList.remove('sidebar-open');
    topbar.classList.remove('sidebar-closed');
  }
}

toggle.addEventListener('click', () => {
  const isHidden = sidebar.classList.contains('hidden');

  if (isMobile()) {
    sidebar.classList.toggle('hidden');
    if (isHidden) {
      topbar.classList.add('sidebar-open');
    } else {
      topbar.classList.remove('sidebar-open');
    }
  } else {
    sidebar.classList.toggle('hidden');
    if (isHidden) {
      topbar.classList.remove('sidebar-closed');
    } else {
      topbar.classList.add('sidebar-closed');
    }
  }
});

initSidebar();

let resizeTimeout;
window.addEventListener('resize', () => {
  clearTimeout(resizeTimeout);
  resizeTimeout = setTimeout(initSidebar, 150);
});
