return {
  "nvim-neo-tree/neo-tree.nvim",

  init = function()
    vim.g.neotree = {
      auto_close = true,
      auto_open = false,
      auto_update = true,
      update_to_buf_dir = true,
    }
  end,
}
