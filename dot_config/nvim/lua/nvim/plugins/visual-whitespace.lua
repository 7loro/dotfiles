-- ── visual-whitespace (비주얼 모드 공백 표시) ───────────

vim.pack.add({
  { src = "https://github.com/mcauley-penney/visual-whitespace.nvim", name = "visual-whitespace" },
})

require("visual-whitespace").setup()
