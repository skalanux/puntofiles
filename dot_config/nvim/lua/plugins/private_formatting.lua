return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      ruff_format = {},
    },
    formatters_by_ft = {
      python = { "ruff_format" },
    },
  },
}
