import antfu from '@antfu/eslint-config'
import perfectionist from 'eslint-plugin-perfectionist'
import perfectionistNatural from 'eslint-plugin-perfectionist/configs/recommended-natural'

export default antfu({
  formatters: {
    css: true,
    html: true,
    markdown: 'prettier',
  },

  ignores: ['./node_modules'],

  plugins: {
    perfectionist,
  },

  rules: {
    ...perfectionistNatural.rules,

    'import/order': ['off'],
  },

  typescript: true,
  vue: true,
})
