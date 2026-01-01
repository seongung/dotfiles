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

    -- Daily notes configuration
    daily_notes = {
      folder = "10_Daily_Notes",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      default_tags = { "daily" },
      template = "Daily Note",
    },

    -- Templates configuration
    templates = {
      folder = "Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {
        yesterday = function()
          return os.date("%Y-%m-%d", os.time() - 86400)
        end,
        tomorrow = function()
          return os.date("%Y-%m-%d", os.time() + 86400)
        end,
      },
    },

    -- Note settings
    new_notes_location = "current_dir",
    preferred_link_style = "wiki",

    -- Use readable note titles as filenames
    note_id_func = function(title)
      if title ~= nil then
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      end
      return tostring(os.time())
    end,

    -- Picker integration (snacks.picker)
    picker = {
      name = "snacks.pick",
    },

  },
  keys = {
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
    { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search vault" },
    { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
    { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's note" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
    { "<leader>ol", "<cmd>Obsidian follow_link<cr>", desc = "Follow link" },
    { "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Insert template" },
    { "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Toggle checkbox" },
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
    { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
  },
}
