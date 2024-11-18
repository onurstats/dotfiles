return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- change a keymap
    { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    {
      "<leader><leader>",
      "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
      desc = "Switch Buffer",
    },
  },
  opts = {
    defaults = {
      path_display = { truncate = 2 },
      file_ignore_patterns = {
        "%.bundle.js",
        "%.min.js",
        "package-lock.json",
        "%.ttf",
        "%.otf",
        "%.woff",
        "%.woff2",
        "%.eot",
        "%.png|jpeg|webp|zip",
      },
    },
  },
}
