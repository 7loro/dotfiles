local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- remap leader key
keymap("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- 탭 대신 스페이스로 들여쓰기
vim.opt.expandtab = true

-- 줄 바꿀 때도 들여쓰기 유지
vim.opt.smartindent = true

vim.opt.tabstop = 2

vim.opt.shiftwidth = 2

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Highlight on yank
vim.api.nvim_exec([[
  augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=250}
  augroup END
]], false)

-- better indent handling
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- paste preserves primal yanked piece
keymap("v", "p", '"_dP', opts)

-- move text up and down
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- vscode-neovim 설정
-- Buffer navigation
keymap({ "n", "v" }, "[b", "<cmd>lua require('vscode').action('workbench.action.previousEditor')<CR>", opts)
keymap({ "n", "v" }, "]b", "<cmd>lua require('vscode').action('workbench.action.nextEditor')<CR>", opts)
-- Change
keymap({ "n", "v" }, "[c", "<cmd>lua require('vscode').action('workbench.action.editor.previousChange')<CR>", opts)
keymap({ "n", "v" }, "]c", "<cmd>lua require('vscode').action('workbench.action.editor.nextChange')<CR>", opts)
-- Search result
keymap({ "n", "v" }, "[s", "<cmd>lua require('vscode').action('search.action.focusPreviousSearchResult')<CR>", opts)
keymap({ "n", "v" }, "]s", "<cmd>lua require('vscode').action('search.action.focusNextSearchResult')<CR>", opts)
-- References
keymap({ "n", "v" }, "[r", "<cmd>lua require('vscode').action('references-view.prev')<CR>", opts)
keymap({ "n", "v" }, "]r", "<cmd>lua require('vscode').action('references-view.next')<CR>", opts)
-- Diagnostics
keymap({ "n", "v" }, "[q", "<cmd>lua require('vscode').action('editor.action.marker.prev')<CR>", opts)
keymap({ "n", "v" }, "]q", "<cmd>lua require('vscode').action('editor.action.marker.next')<CR>", opts)

-- 간단한 메시지 출력 테스트 (VSCode 내에서 Neovim이 로드되었는지 확인)
vim.cmd([[autocmd VimEnter * echom "VSCode Neovim 설정이 로드되었습니다."]])
