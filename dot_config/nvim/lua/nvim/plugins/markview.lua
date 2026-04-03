-- ── markview.nvim (마크다운 실시간 렌더링) ──────────────

vim.pack.add({
  { src = "https://github.com/OXY2DEV/markview.nvim", name = "markview" },
})

require("markview").setup({})
