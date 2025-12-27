return {
  "coder/claudecode.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
  },
  opts = {},
}
