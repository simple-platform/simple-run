import type { Config } from 'tailwindcss'

import twc from 'tailwindcss/colors'
import defaultTheme from 'tailwindcss/defaultTheme'

// eslint-disable-next-line unused-imports/no-unused-vars
const { blueGray, coolGray, lightBlue, trueGray, warmGray, ...colors } = twc

const colorMap: any = {
  danger: 'red',
  info: 'blue',
  primary: 'indigo',
  success: 'green',
  warning: 'yellow',
}

// We want each package to be responsible for its own content.
const config: Omit<Config, 'content'> = {
  jit: true,

  plugins: [],

  theme: {
    colors: {
      ...colors,
      ...Object.keys(colorMap).map((color) => {
        const kvp: any = {}
        kvp[color] = colorMap[color]
        return kvp
      }),
    },

    extend: {
      fontFamily: {
        sans: ['InterVariable', ...defaultTheme.fontFamily.sans],
      },
    },
  },
}

export default config
