-- ~/.config/nvim/lua/plugins/conform.lua

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        html = { "djlint" },
        handlebars = { "djlint" },
        hbs = { "djlint" },
      })

      opts.format = vim.tbl_deep_extend("force", opts.format or {}, {
        timeout_ms = 30000,
        async = false,
        quiet = false,
      })
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        djlint = {
          command = "djlint",
          args = {
            "--reformat",
            "-",
            "--profile",
            "handlebars",
          },
        },
      })
    end,
  },
}
