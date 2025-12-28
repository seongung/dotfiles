return {
  "github/copilot.vim",
  lazy = false,
  init = function()
    vim.g.copilot_filetypes = {
      markdown = true,
      text = true,
      gitcommit = true,
    }
    vim.g.copilot_no_tab_map = true
  end,
  config = function()
    -- Accept full suggestion
    vim.keymap.set("i", "<M-(>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })

    -- Next/previous suggestion
    vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { remap = true })
    vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { remap = true })

    -- Partial accept: word/line
    vim.keymap.set("i", "<M-{>", "<Plug>(copilot-accept-word)", { remap = true })
    vim.keymap.set("i", "<M-}>", "<Plug>(copilot-accept-line)", { remap = true })

    -- Dismiss
    vim.keymap.set("i", "<M-)>", "<Plug>(copilot-dismiss)", { remap = true })
  end,
}
