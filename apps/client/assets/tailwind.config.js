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
    '../../../deps/petal_components/**/*.*ex',
  ],

  darkMode: 'media',

  jit: true,

  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),

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
      colors: {
        danger: colors.red,
        gray: colors.slate,
        info: colors.sky,
        primary: colors.indigo,
        secondary: colors.pink,
        success: colors.green,
        warning: colors.yellow,
      },

      extend: {
        fontFamily: {
          sans: ['InterVariable', ...defaultTheme.fontFamily.sans],
        },
      },
    },
  },
}
