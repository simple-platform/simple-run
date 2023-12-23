import type { Config } from 'tailwindcss'

import sharedConfig from '@simple-run/tailwind-config'

const config: Pick<Config, 'content' | 'prefix' | 'presets'> = {
  content: ['./src/**/*.tsx'],
  prefix: 'ui-',
  presets: [sharedConfig],
}

export default config
