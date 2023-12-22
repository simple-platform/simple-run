import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'
import { defineNuxtModule } from '@nuxt/kit'

const __dirname = dirname(fileURLToPath(import.meta.url))

export default defineNuxtModule({
  hooks: {
    'components:dirs': (dirs) => {
      dirs.push({
        path: join(__dirname, 'components'),
      })
    },
  },
})
