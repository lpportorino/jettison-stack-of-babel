// Locale configuration
export const sourceLocale = 'en';
export const targetLocales = ['es', 'fr', 'de', 'ja'] as const;
export const allLocales = ['en', ...targetLocales] as const;
