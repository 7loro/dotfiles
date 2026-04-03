-- ── 리더 키 ─────────────────────────────────────────────
-- 플러그인보다 먼저 설정해야 올바르게 적용됨
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- ── 표시 ────────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.showmode = false
vim.opt.scrolloff = 10
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'

-- ── 편집 ────────────────────────────────────────────────
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.breakindent = true
vim.opt.undofile = true

-- ── 검색 ────────────────────────────────────────────────
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ── 창 분할 ─────────────────────────────────────────────
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ── 성능 ────────────────────────────────────────────────
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- ── 자동완성 ────────────────────────────────────────────
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }

-- ── 클립보드 (UI 진입 후 설정하여 시작 속도 유지) ──────
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- ── 배경 투명화 ─────────────────────────────────────────
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- ── Visual 모드 삭제 시 레지스터 보호 ───────────────────
vim.keymap.set('x', 'd', '"_d')

-- ── 진단 표시 ───────────────────────────────────────────
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
      [vim.diagnostic.severity.HINT] = '󰌵',
    },
    numhl = {
      [vim.diagnostic.severity.WARN] = 'WarningMsg',
    },
  },
})

-- ── 복사 시 하이라이트 ──────────────────────────────────
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
