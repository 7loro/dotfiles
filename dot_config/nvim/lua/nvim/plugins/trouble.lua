-- ── trouble.nvim (진단·목록 뷰어) ───────────────────────

vim.pack.add({
  { src = "https://github.com/folke/trouble.nvim", name = "trouble" },
})

require("trouble").setup({})
