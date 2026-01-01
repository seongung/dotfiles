return {
  "folke/which-key.nvim",
  opts = {
    delay = function(ctx)
      -- Longer delay for visual mode - 2 seconds
      if ctx.mode == "v" or ctx.mode == "x" then
        return 2000
      end
      -- Default delay for other keys
      return 200
    end,
  },
}
