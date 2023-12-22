/** @type {import('tailwindcss').Config} */

const plugin = require('tailwindcss/plugin')
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

const deprecatedColors = ['lightBlue', 'warmGray', 'trueGray', 'coolGray', 'blueGray']
deprecatedColors.forEach(color => delete colors[color])

const styles = ['bg', 'text', 'placeholder', 'border', 'ring']
const scales = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]

const colorMap = {
  primary: 'indigo',
  success: 'green',
  danger: 'red',
  warning: 'yellow',
  info: 'blue',
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
  jit: true,
  darkMode: 'media',

  content: [
    './components/**/*.{js,vue,ts}',
    './layouts/**/*.vue',
    './pages/**/*.vue',
    './plugins/**/*.{js,ts}',
    './app.vue',
    './error.vue',
  ],

  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
    colors: {
      ...colors,
      ...Object.keys(colorMap).map((color) => {
        const kvp = {}
        kvp[color] = colorMap[color]
        return kvp
      }),
    },
  },

  plugins: [
    plugin(simple),
  ],
}
