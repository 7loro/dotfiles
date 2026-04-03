-- ── fzf-lua (고속 파일·텍스트 검색) ─────────────────────

vim.pack.add({
  { src = "https://github.com/ibhagwan/fzf-lua", name = "fzf-lua" },
})

require("fzf-lua").setup({
  "default",
  winopts = {
    height = 0.85,
    width = 0.80,
    preview = { layout = "vertical" },
  },
})
