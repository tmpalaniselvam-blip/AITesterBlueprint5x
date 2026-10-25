import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './src/tests',
  outputDir: './src/test-results/artifacts',
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 1 : 0,
  reporter: [
    ['list'],
    ['html', { outputFolder: './src/test-results/html', open: 'never' }],
    ['json', { outputFile: './src/test-results/results.json' }],
  ],
  use: {
    baseURL: process.env.BASE_URL,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
