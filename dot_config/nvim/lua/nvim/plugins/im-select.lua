-- ── vim-im-select (입력 언어 자동 전환) ─────────────────

vim.pack.add({
  { src = "https://github.com/brglng/vim-im-select", name = "vim-im-select" },
})

local default_im = "com.apple.keylayout.UnicodeHexInput"

vim.g.im_select_get_im_cmd = "['im-select']"
vim.g.im_select_default = default_im

-- Command-line 모드 진입 시 영문 전환
vim.api.nvim_create_autocmd("CmdlineEnter", {
  callback = function()
    vim.fn.system({ "im-select", default_im })
  end,
})
