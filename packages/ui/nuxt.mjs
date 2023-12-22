import { defineNuxtModule } from '@nuxt/kit'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

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
