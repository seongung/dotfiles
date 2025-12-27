return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "My Vault",
        path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/My Vault",
      },
    },
  },
}
