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

-- 열려있는 버퍼에서 탐색 (Show All Editors By Most Recently Used)
keymap("n", "<leader><leader>", "<cmd>lua require('vscode').action('workbench.action.showAllEditorsByMostRecentlyUsed')<CR>", { desc = "VSCode: Show all editors (MRU)" })

-- 파일 검색 (Television File Finder)
keymap("n", "<leader>sf", "<cmd>lua require('vscode').action('television.ToggleFileFinder')<CR>", { desc = "VSCode: Toggle File Finder" })

-- Git status 파일 검색 (Television)
keymap("n", "<leader>gs", "<cmd>lua require('vscode').action('television.ToggleGitStatus')<CR>", { desc = "VSCode: Toggle Git Status" })

-- Text Grep (Television Text Finder)
keymap("n", "<leader>sg", "<cmd>lua require('vscode').action('television.ToggleTextFinder')<CR>", { desc = "VSCode: Toggle Text Finder" })

-- Text Grep with current selection (Television Text Finder)
keymap("v", "<leader>sg", "<cmd>lua require('vscode').action('television.ToggleTextFinderWithSelection')<CR>", { desc = "VSCode: Toggle Text Finder" })

-- Git status (SCM view) 일단 ctrl+shift+g vscode 기본 단축키로 사용
-- keymap("n", "<leader>gs", "<cmd>lua require('vscode').action('workbench.view.scm')<CR>", { desc = "VSCode: Show Git SCM View" })

-- Lazygit
keymap("n", "<leader>lg", "<cmd>lua require('vscode').action('lazygit.openLazygit')<CR>", { desc = "VSCode: Open Lazygit" })

-- Quick fix (Code action)
keymap({ "n", "v" }, "<leader>ca", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>", { desc = "VSCode: Quick Fix / Code Action" })

-- Revert selected ranges (Git)
keymap({ "n", "v" }, "<leader>hr", "<cmd>lua require('vscode').action('git.revertSelectedRanges')<CR>", { desc = "VSCode: Git Revert Selected Ranges" })

-- Problems (Focus problems view)
keymap("n", "<leader>q", "<cmd>lua require('vscode').action('workbench.action.problems.focus')<CR>", { desc = "VSCode: Focus Problems View" })

-- Trigger Suggest (Insert mode)
keymap("i", "<C-j>", "<cmd>lua require('vscode').action('editor.action.triggerSuggest')<CR>", { desc = "VSCode: Trigger Suggest" })

-- VS Code UI Navigation (using Neovim normal mode keys)
keymap("n", "<C-h>", "<cmd>lua require('vscode').action('workbench.action.navigateLeft')<CR>", { desc = "VSCode: UI Navigate Left" })
keymap("n", "<C-l>", "<cmd>lua require('vscode').action('workbench.action.navigateRight')<CR>", { desc = "VSCode: UI Navigate Right" })
keymap("n", "<C-k>", "<cmd>lua require('vscode').action('workbench.action.navigateUp')<CR>", { desc = "VSCode: UI Navigate Up" })
keymap("n", "<C-j>", "<cmd>lua require('vscode').action('workbench.action.navigateDown')<CR>", { desc = "VSCode: UI Navigate Down" })

-- Show Call Hierarchy
keymap({ "n", "v" }, "<leader>gh", "<cmd>lua require('vscode').action('references-view.showCallHierarchy')<CR>", { desc = "VSCode: Show Call Hierarchy" })

-- References
keymap({ "n", "v" }, "gr", "<cmd>lua require('vscode').action('editor.action.goToReferences')<CR>", { desc = "VSCode: Find References" })

-- Go to implementations
keymap({ "n", "v" }, "gI", "<cmd>lua require('vscode').action('editor.action.goToImplementation')<CR>", { desc = "VSCode: Go to implemetations" })

-- Peek hierarchy
keymap({ "n", "v" }, "gH", "<cmd>lua require('vscode').action('editor.showCallHierarchy')<CR>", { desc = "VSCode: Peek Call Hierarchy" })

-- Magit status
keymap("n", "<leader>ms", "<cmd>lua require('vscode').action('magit.status')<CR>", { desc = "VSCode: Show Magit status" })

-- Show github view
keymap("n", "<leader>gH", "<cmd>lua require('vscode').action('workbench.view.extension.github-pull-requests')<CR>", { desc = "VSCode: Show GitHub view" })

-- File explorer
keymap("n", "<leader>e", "<cmd>lua require('vscode').action('workbench.view.explorer')<CR>", { desc = "VSCode: Toggle File Explorer" })

-- Terminal
keymap("n", "<leader>t", "<cmd>lua require('vscode').action('terminal.focus')<CR>", { desc = "VSCode: Focus terminal" })

-- Rename symbol
keymap("n", "<leader>grn", "<cmd>lua require('vscode').action('editor.action.rename')<CR>", { desc = "VSCode: Rename Symbol" })

-- Clear vscode-neovim search results (highlight)
keymap({ "n", "v", "c" }, "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight & ESC" })

-- Open vscode neovim config file (Example path)
keymap("n", "<leader>ce", "<cmd>e ~/.config/nvim/lua/vscode-neovim/config.lua<CR>", { desc = "Edit VSCode-Neovim user config" }) -- 경로 확인 필요

-- Document symbol
keymap("n", "<leader>ds", "<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<CR>", { desc = "VSCode: Go to Symbol in Document" })

-- Workspace symbol
keymap("n", "<leader>ws", "<cmd>lua require('vscode').action('workbench.action.showAllSymbols')<CR>", { desc = "VSCode: Show All Symbols in Workspace" })

-- Format document
keymap("n", "<leader>df", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>", { desc = "VSCode: Format Document" })

-- Toggle git blame
keymap("n", "<leader>tb", "<cmd>lua require('vscode').action('gitlens.toggleFileBlame')<CR>", { desc = "VSCode: Toggle Git Blame" })

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
-- Edit locations
keymap({ "n", "v" }, "[C", "<cmd>lua require('vscode').action('workbench.action.navigateBackInEditLocations')<CR>", opts)
keymap({ "n", "v" }, "]C", "<cmd>lua require('vscode').action('workbench.action.navigateForwardInEditLocations')<CR>", opts)
-- Search
keymap({ "n", "v" }, "<leader>sw", "<cmd>lua require('vscode').action('workbench.action.findInFiles')<CR>", opts)

-- antigravity, cursor 설정
-- Agent hunk (수정사항 제안 다음/이전)
-- keymap({ "n", "v" }, "[h", "<cmd>lua require('vscode').action('antigravity.prioritized.agentFocusPreviousHunk')<CR>", opts)
keymap({ "n", "v" }, "[h", "<cmd>lua require('vscode').action('editor.action.inlineDiffs.previousChange')<CR>", opts)
-- keymap({ "n", "v" }, "]h", "<cmd>lua require('vscode').action('antigravity.prioritized.agentFocusNextHunk')<CR>", opts)
keymap({ "n", "v" }, "]h", "<cmd>lua require('vscode').action('editor.action.inlineDiffs.nextChange')<CR>", opts)

-- Agent file (수정사항 제안 파일 다음/이전)
-- keymap({ "n", "v" }, "[f", "<cmd>lua require('vscode').action('antigravity.prioritized.agentFocusPreviousFile')<CR>", opts)
keymap({ "n", "v" }, "[f", "<cmd>lua require('vscode').action('editor.action.inlineDiffs.previousDiffFile')<CR>", opts)
-- keymap({ "n", "v" }, "]f", "<cmd>lua require('vscode').action('antigravity.prioritized.agentFocusNextFile')<CR>", opts)
keymap({ "n", "v" }, "]f", "<cmd>lua require('vscode').action('editor.action.inlineDiffs.nextDiffFile')<CR>", opts)

-- 간단한 메시지 출력 테스트 (VSCode 내에서 Neovim이 로드되었는지 확인)
vim.cmd([[autocmd VimEnter * echom "VSCode Neovim 설정이 로드되었습니다."]])
