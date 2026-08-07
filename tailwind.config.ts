import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        twitch: { DEFAULT: "#9146FF", dark: "#772CE8", darker: "#5C16C5" },
      },
    },
  },
  plugins: [],
};

export default config;
