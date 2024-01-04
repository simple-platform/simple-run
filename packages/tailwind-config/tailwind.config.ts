import type { Config } from 'tailwindcss'

import forms from '@tailwindcss/forms'
import typography from '@tailwindcss/typography'
import daisyui from 'daisyui'
import twc from 'tailwindcss/colors'
import defaultTheme from 'tailwindcss/defaultTheme'

// eslint-disable-next-line unused-imports/no-unused-vars
const { blueGray, coolGray, lightBlue, trueGray, warmGray, ...colors } = twc

// We want each package to be responsible for its own content.
const config: Omit<Config, 'content'> = {
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
    daisyui,
    typography,
    forms,
  ],

  theme: {
    colors,

    extend: {
      fontFamily: {
        sans: ['InterVariable', ...defaultTheme.fontFamily.sans],
      },
    },
  },
}

export default config
