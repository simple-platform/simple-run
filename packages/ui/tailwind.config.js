/** @type {import('tailwindcss').Config} */

const plugin = require('tailwindcss/plugin')
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

const deprecatedColors = ['lightBlue', 'warmGray', 'trueGray', 'coolGray', 'blueGray']
deprecatedColors.forEach(color => delete colors[color])

const styles = ['bg', 'text', 'placeholder', 'border', 'ring']
const scales = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]

const colorMap = {
  danger: 'red',
  info: 'blue',
  primary: 'indigo',
  success: 'green',
  warning: 'yellow',
}

function simple({ addComponents }) {
  const components = {}

  const colors = ['primary', 'success', 'danger', 'warning', 'info']

  scales.forEach((scale) => {
    colors.forEach((color) => {
      styles.forEach((style) => {
        const s = `.${style}-${color}-${scale}`

        components[s] = {}
        components[s][`@apply ${style}-${colorMap[color]}-${scale}`] = {}
      })
    })
  })

  addComponents(components)
}

module.exports = {
  content: [
    './components/**/*.{js,vue,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './plugins/**/*.{js,ts}',
    './app.vue',
    './error.vue',
    'node_modules/flowbite-vue/**/*.{js,jsx,ts,tsx,vue}',
    'node_modules/flowbite/**/*.{js,jsx,ts,tsx}',
    'node_modules/@simple-flow/ui/components/**/*.{js,vue,ts}',
  ],

  darkMode: 'media',

  jit: true,

  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('flowbite/plugin'),
    plugin(simple),
  ],

  theme: {
    colors: {
      ...colors,
      ...Object.keys(colorMap).map((color) => {
        const kvp = {}
        kvp[color] = colorMap[color]
        return kvp
      }),
    },

    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
}
