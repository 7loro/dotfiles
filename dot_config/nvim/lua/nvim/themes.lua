-- ── Catppuccin 테마 ─────────────────────────────────────

vim.pack.add({ { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } })

require("catppuccin").setup({
  transparent_background = true,
  integrations = {
    blink_cmp = true,
  },
  custom_highlights = function(colors)
    return {
      Visual = { bg = colors.surface2, style = { "bold" } },
      LineNr = { fg = colors.rosewater },
      CursorLineNr = { fg = colors.pink, style = { "bold" } },
      MiniTablineModifiedCurrent = { style = { "bold", "italic", "underline" } },
    }
  end,
})

vim.cmd.colorscheme("catppuccin")
vim.cmd.hi("Comment gui=none")
