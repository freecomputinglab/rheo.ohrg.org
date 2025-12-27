const toggle = document.querySelector('.sidebar-toggle');
const sidebar = document.querySelector('.sidebar');
const topbar = document.querySelector('.topbar');

// Create backdrop element
const backdrop = document.createElement('div');
backdrop.className = 'sidebar-backdrop';
document.body.appendChild(backdrop);

function isMobile() {
  return window.innerWidth <= 768;
}

function closeSidebar() {
  sidebar.classList.add('hidden');
  topbar.classList.remove('sidebar-open');
  backdrop.classList.remove('visible');
}

function openSidebar() {
  sidebar.classList.remove('hidden');
  topbar.classList.add('sidebar-open');
  if (isMobile()) {
    backdrop.classList.add('visible');
  }
}

function initSidebar() {
  if (isMobile()) {
    sidebar.classList.add('hidden');
    topbar.classList.remove('sidebar-open');
    topbar.classList.remove('sidebar-closed');
    backdrop.classList.remove('visible');
  } else {
    sidebar.classList.remove('hidden');
    topbar.classList.remove('sidebar-open');
    topbar.classList.remove('sidebar-closed');
    backdrop.classList.remove('visible');
  }
}

toggle.addEventListener('click', () => {
  const isHidden = sidebar.classList.contains('hidden');

  if (isMobile()) {
    if (isHidden) {
      openSidebar();
    } else {
      closeSidebar();
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

// Close sidebar when clicking backdrop (mobile only)
backdrop.addEventListener('click', () => {
  if (isMobile()) {
    closeSidebar();
  }
});

initSidebar();

let resizeTimeout;
window.addEventListener('resize', () => {
  clearTimeout(resizeTimeout);
  resizeTimeout = setTimeout(initSidebar, 150);
});

// Wait for DOM to be fully loaded before moving arrows
document.addEventListener('DOMContentLoaded', () => {
  // Move navigation arrows after endnotes if they exist
  const endnotes = document.querySelector('[role="doc-endnotes"]');
  if (endnotes) {
    const desktopNav = document.querySelector('.nav-arrows.desktop-nav');
    const mobileNav = document.querySelector('.nav-arrows.mobile-nav');
    // Insert in reverse order so they end up in the right order
    if (mobileNav) endnotes.parentNode.insertBefore(mobileNav, endnotes.nextSibling);
    if (desktopNav) endnotes.parentNode.insertBefore(desktopNav, endnotes.nextSibling);
  }
});

// Keyboard navigation
document.addEventListener('keydown', (e) => {
  // Left arrow key - previous page
  if (e.key === 'ArrowLeft') {
    const prevLink = document.querySelector('.prev-arrow');
    if (prevLink) prevLink.click();
  }
  // Right arrow key - next page
  if (e.key === 'ArrowRight') {
    const nextLink = document.querySelector('.next-arrow');
    if (nextLink) nextLink.click();
  }
});
