return {
  "folke/snacks.nvim",
  opts = {
    notifier = {
      filter = function(notif)
        -- Hide ClaudeCode WebSocket errors
        if notif.msg and notif.msg:match("ClaudeCode") and notif.msg:match("WebSocket") then
          return false
        end
        return true
      end,
    },
    explorer = {
      replace_netrw = true,
    },
    picker = {
      sources = {
        explorer = {
          layout = {
            layout = {
              width = 30,
            },
          },
        },
      },
    },
  },
}
