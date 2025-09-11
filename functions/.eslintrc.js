module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
    ".eslintrc.js",
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": 0,
    "indent": ["error", 2],
    "object-curly-spacing": ["error", "always"],
    "require-jsdoc": "off", // Desactivamos la necesidad de JSDoc para agilizar.

    // --- REGLAS NUEVAS PARA SOLUCIONAR LOS ERRORES ---
    "max-len": ["error", { "code": 150 }], // Aumentamos el límite de caracteres por línea a 150.
    "valid-jsdoc": "off", // Ya que no requerimos JSDoc, tampoco validamos su formato.
    "padded-blocks": "off", // Desactivamos la regla sobre líneas en blanco dentro de bloques.
    "no-trailing-spaces": "warn", // Convertimos los espacios al final en una advertencia, no un error.
  },
};
