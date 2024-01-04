// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const twc = require('tailwindcss/colors')
const plugin = require('tailwindcss/plugin')
const defaultTheme = require('tailwindcss/defaultTheme')

// eslint-disable-next-line unused-imports/no-unused-vars
const { blueGray, coolGray, lightBlue, trueGray, warmGray, ...colors } = twc

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/client.ex',
    '../lib/client/**/*.*ex',
  ],

  daisyui: {
    base: true, // applies background color and foreground color for root element by default
    darkTheme: 'night', // name of one of the included themes for dark mode
    logs: true, // Shows info about daisyUI version and used config in the console when building your CSS
    prefix: '', // prefix for daisyUI classnames (components, modifiers and responsive class names. Not colors)
    styled: true, // include daisyUI colors and design decisions for all components
    themeRoot: ':root', // The element that receives theme color CSS variables
    themes: ['winter', 'night'], // false: only light + dark | true: all themes | array: specific themes like this ["light", "dark", "cupcake"]
    utils: true, // adds responsive and modifier utility classes
  },

  darkMode: 'media',

  jit: true,

  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('daisyui'),

    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant('phx-no-feedback', ['.phx-no-feedback&', '.phx-no-feedback &'])),
    plugin(({ addVariant }) => addVariant('phx-click-loading', ['.phx-click-loading&', '.phx-click-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-submit-loading', ['.phx-submit-loading&', '.phx-submit-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-change-loading', ['.phx-change-loading&', '.phx-change-loading &'])),
  ],

  theme: {
    extend: {
      colors,
      extend: {
        fontFamily: {
          sans: ['InterVariable', ...defaultTheme.fontFamily.sans],
        },
      },
    },
  },
}
