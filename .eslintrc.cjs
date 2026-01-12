/** @type {import("eslint").Linter.Config} */
module.exports = {
  extends: ["next/core-web-vitals"],
  rules: {
    "no-restricted-imports": [
      "error",
      {
        patterns: [
          {
            group: ["@/cert_intel/*", "@/cert_intel/**"],
            message:
              "Do not import from cert_intel inside app/. Runtime routes must import from '@/lib/...'.",
          },
        ],
      },
    ],
  },
  overrides: [
    {
      files: ["app/**/*.{ts,tsx,js,jsx}"],
      rules: {
        "no-restricted-imports": [
          "error",
          {
            patterns: [
              {
                group: ["@/cert_intel/*", "@/cert_intel/**"],
                message:
                  "app/ cannot import cert_intel. Use '@/lib/lessonloader' (runtime).",
              },
            ],
          },
        ],
      },
    },
  ],
};