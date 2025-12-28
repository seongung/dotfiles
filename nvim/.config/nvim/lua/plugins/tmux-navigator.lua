return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", mode = { "n", "v" } },
    { "<c-j>", "<cmd>TmuxNavigateDown<cr>", mode = { "n", "v" } },
    { "<c-k>", "<cmd>TmuxNavigateUp<cr>", mode = { "n", "v" } },
    { "<c-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "v" } },
    { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", mode = { "n", "v" } },
  },
}
