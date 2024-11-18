local logo = [[╔═╗╔╗╔╦ ╦╦═╗
║ ║║║║║ ║╠╦╝
╚═╝╝╚╝╚═╝╩╚═]]
logo = string.rep("\n", 8) .. logo .. "\n\n"

return {
  "nvimdev/dashboard-nvim",
  lazy = false,
  opts = {
    config = {
      header = vim.split(logo, "\n"),
    },
  },
}
