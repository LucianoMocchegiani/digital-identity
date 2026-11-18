import { defineConfig } from 'vitest/config'

export default defineConfig({
  base: '/',
  server: {
    allowedHosts: ['wallet.lucianomocchegiani.xyz'],
  },
  test: {
    environment: 'node',
  },
})
