import type { Options } from 'tsup'

import { defineConfig } from 'tsup'

export default defineConfig((options: Options) => ({
  clean: true,
  dts: true,
  entry: ['src/**/*.tsx'],
  external: ['react'],
  format: ['esm'],
  minify: true,
  splitting: true,
  treeshake: true,
  ...options,
}))
