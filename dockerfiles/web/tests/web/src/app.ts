// Main application entry point
import './components/hello-world';
import './components/localized-component';
import { configureLocalization } from '@lit/localize';
import { sourceLocale, targetLocales } from './locales/locale-codes';

// Configure localization
export const { getLocale, setLocale } = configureLocalization({
  sourceLocale,
  targetLocales,
  loadLocale: (locale: string) => import(`./locales/${locale}.js`),
});

// Initialize the application
async function initApp() {
  console.log('Jon-Babylon Web Test Application');
  console.log('Testing: TypeScript, Lit, esbuild, localization, and more...');

  // Set locale based on browser preference
  const browserLocale = navigator.language.split('-')[0];
  if (targetLocales.includes(browserLocale as any)) {
    await setLocale(browserLocale);
  }

  // Create test components
  const app = document.getElementById('app');
  if (app) {
    app.innerHTML = `
      <h1>Jon-Babylon Web Test Suite</h1>
      <hello-world name="Jon-Babylon"></hello-world>
      <localized-component></localized-component>
    `;
  }
}

// Run when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initApp);
} else {
  initApp();
}
