// For importing tailwind styles from phlex_ui/phlex_ui_pro gem
const execSync = require('child_process').execSync;

// Import phlex_ui gem path
const outputPhlexUI = execSync('bundle show phlex_ui', { encoding: 'utf-8' });
const phlex_ui_path = outputPhlexUI.trim() + '/**/*.rb';

// Import phlex_ui_pro gem path
const outputPhlexUIPro = execSync('bundle show phlex_ui_pro', { encoding: 'utf-8' });
const phlex_ui_pro_path = outputPhlexUIPro.trim() + '/**/*.rb';

const colors = require('tailwindcss/colors')
const { createThemes } = require('tw-colors'); // For color theme to accomodate dark mode more easily (https://www.npmjs.com/package/tw-colors)
const defaultTheme = require('tailwindcss/defaultTheme')

const gray = colors.neutral // Set gray to neutral color palette. Select between [slate, gray, zinc, neutral, stone]. See https://tailwindcss.com/docs/customizing-colors

module.exports = {
  darkMode: ["class"],
  content: [
    './app/views/**/*.rb',
    './app/components/**/*rb',
    './app/views/**/*.{erb,haml,html,slim,rb}',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    phlex_ui_path,
    phlex_ui_pro_path
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      fontFamily: {
        sans: ['General Sans', ...defaultTheme.fontFamily.sans],
      }
    },
  },
  plugins: [
    require("tailwindcss-animate"),
    createThemes({
      light: {
        primary: {
          DEFAULT: gray[900],
          text: colors.white,
          ...gray,
        },
        destructive: {
          DEFAULT: colors.rose[500],
          ...colors.rose,
        },
        success: {
          DEFAULT: colors.lime[500],
          ...colors.lime,
        },
        warning: {
          DEFAULT: colors.amber[500],
          ...colors.amber,
        },
        background: colors.white,
        text: gray[900],
        muted: {
          background: gray[100],
          text: gray[500],
        },
        accent: {
          background: gray[100],
          text: gray[900],
        },
        ring: gray[900],
        border: gray[200]
      },
      dark: {
        primary: {
          DEFAULT: colors.white,
          text: gray[900],
          50: 'rgb(255 255 255 / 5%)',
          100: 'rgb(255 255 255 / 10%)',
          200: 'rgb(255 255 255 / 20%)',
          300: 'rgb(255 255 255 / 30%)',
          400: 'rgb(255 255 255 / 40%)',
          500: 'rgb(255 255 255 / 50%)',
          600: 'rgb(255 255 255 / 60%)',
          700: 'rgb(255 255 255 / 70%)',
          800: 'rgb(255 255 255 / 80%)',
          900: 'rgb(255 255 255 / 90%)',
          950: 'rgb(255 255 255 / 95%)',
        },
        destructive: {
          DEFAULT: colors.rose[500],
          ...colors.rose,
        },
        success: {
          DEFAULT: colors.lime[500],
          ...colors.lime,
        },
        warning: {
          DEFAULT: colors.amber[500],
          ...colors.amber,
        },
        background: gray[950],
        text: colors.white,
        muted: {
          background: 'rgb(255 255 255 / 7%)',
          text: 'rgb(255 255 255 / 50%)',
        },
        accent: {
          background: 'rgb(255 255 255 / 7%)',
          text: 'rgb(255 255 255 / 90%)',
        },
        ring: colors.white,
        border: 'rgb(255 255 255 / 20%)'
      }
    })
  ],
}