local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local vscode = require('vscode')

-- ── 기본 설정 ───────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.scrolloff = 10
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- ── 복사 시 하이라이트 ──────────────────────────────────
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('vscode-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 250 })
  end,
})

-- ── 편집 ────────────────────────────────────────────────
keymap("n", "<Space>", "", opts)
keymap({ "n", "v", "c" }, "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "검색 하이라이트 제거" })
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "p", '"_dP', opts)
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- ── 파일·검색 ───────────────────────────────────────────
keymap("n", "<leader><leader>", function() vscode.action('workbench.action.showAllEditorsByMostRecentlyUsed') end, { desc = "열린 에디터 목록 (MRU)" })
keymap("n", "<leader>sf", function() vscode.action('television.ToggleFileFinder') end, { desc = "파일 검색" })
keymap("n", "<leader>sg", function() vscode.action('television.ToggleTextFinder') end, { desc = "텍스트 검색" })
keymap("v", "<leader>sg", function() vscode.action('television.ToggleTextFinderWithSelection') end, { desc = "선택 텍스트 검색" })
keymap({ "n", "v" }, "<leader>sw", function() vscode.action('workbench.action.findInFiles') end, opts)
keymap("n", "<leader>e", function() vscode.action('workbench.view.explorer') end, { desc = "파일 탐색기" })

-- ── LSP·코드 ────────────────────────────────────────────
keymap({ "n", "v" }, "<leader>ca", function() vscode.action('editor.action.quickFix') end, { desc = "코드 액션" })
keymap("n", "<leader>grn", function() vscode.action('editor.action.rename') end, { desc = "심볼 이름 변경" })
keymap("n", "<leader>ds", function() vscode.action('workbench.action.gotoSymbol') end, { desc = "문서 심볼 이동" })
keymap("n", "<leader>ws", function() vscode.action('workbench.action.showAllSymbols') end, { desc = "워크스페이스 심볼 검색" })
keymap("n", "<leader>df", function() vscode.action('editor.action.formatDocument') end, { desc = "문서 포맷" })
keymap({ "n", "v" }, "gr", function() vscode.action('editor.action.goToReferences') end, { desc = "참조 이동" })
keymap({ "n", "v" }, "gI", function() vscode.action('editor.action.goToImplementation') end, { desc = "구현 이동" })
keymap({ "n", "v" }, "<leader>gh", function() vscode.action('references-view.showCallHierarchy') end, { desc = "호출 계층 표시" })
keymap({ "n", "v" }, "gH", function() vscode.action('editor.showCallHierarchy') end, { desc = "호출 계층 미리보기" })

-- ── Git ─────────────────────────────────────────────────
keymap("n", "<leader>gs", function() vscode.action('television.ToggleGitStatus') end, { desc = "Git 상태 검색" })
keymap("n", "<leader>lg", function() vscode.action('lazygit.openLazygit') end, { desc = "LazyGit 열기" })
keymap("n", "<leader>ms", function() vscode.action('magit.status') end, { desc = "Magit 상태" })
keymap("n", "<leader>gH", function() vscode.action('workbench.view.extension.github-pull-requests') end, { desc = "GitHub PR 뷰" })
keymap({ "n", "v" }, "<leader>hr", function() vscode.action('git.revertSelectedRanges') end, { desc = "선택 영역 되돌리기" })
keymap("n", "<leader>tb", function() vscode.action('gitlens.toggleFileBlame') end, { desc = "Git Blame 토글" })

-- ── 진단 ────────────────────────────────────────────────
keymap("n", "<leader>q", function() vscode.action('workbench.action.problems.focus') end, { desc = "문제 패널 포커스" })

-- ── 자동완성 ────────────────────────────────────────────
keymap("i", "<C-j>", function() vscode.action('editor.action.triggerSuggest') end, { desc = "자동완성 트리거" })

-- ── 창 네비게이션 ───────────────────────────────────────
keymap("n", "<C-h>", function() vscode.action('workbench.action.navigateLeft') end, opts)
keymap("n", "<C-l>", function() vscode.action('workbench.action.navigateRight') end, opts)
keymap("n", "<C-k>", function() vscode.action('workbench.action.navigateUp') end, opts)
keymap("n", "<C-j>", function() vscode.action('workbench.action.navigateDown') end, opts)
keymap("n", "<leader>t", function() vscode.action('terminal.focus') end, { desc = "터미널 포커스" })
keymap("n", "<leader>ce", "<cmd>e ~/.config/nvim/lua/vscode-neovim/config.lua<CR>", { desc = "Neovim 설정 파일 열기" })

-- ── 이동 (brackets) ────────────────────────────────────
keymap({ "n", "v" }, "[b", function() vscode.action('workbench.action.previousEditor') end, opts)
keymap({ "n", "v" }, "]b", function() vscode.action('workbench.action.nextEditor') end, opts)
keymap({ "n", "v" }, "[c", function() vscode.action('workbench.action.editor.previousChange') end, opts)
keymap({ "n", "v" }, "]c", function() vscode.action('workbench.action.editor.nextChange') end, opts)
keymap({ "n", "v" }, "[s", function() vscode.action('search.action.focusPreviousSearchResult') end, opts)
keymap({ "n", "v" }, "]s", function() vscode.action('search.action.focusNextSearchResult') end, opts)
keymap({ "n", "v" }, "[r", function() vscode.action('references-view.prev') end, opts)
keymap({ "n", "v" }, "]r", function() vscode.action('references-view.next') end, opts)
keymap({ "n", "v" }, "[q", function() vscode.action('editor.action.marker.prev') end, opts)
keymap({ "n", "v" }, "]q", function() vscode.action('editor.action.marker.next') end, opts)
keymap({ "n", "v" }, "[C", function() vscode.action('workbench.action.navigateBackInEditLocations') end, opts)
keymap({ "n", "v" }, "]C", function() vscode.action('workbench.action.navigateForwardInEditLocations') end, opts)

-- ── AI 인라인 변경 이동 ────────────────────────────────
keymap({ "n", "v" }, "[h", function() vscode.action('editor.action.inlineDiffs.previousChange') end, opts)
keymap({ "n", "v" }, "]h", function() vscode.action('editor.action.inlineDiffs.nextChange') end, opts)
keymap({ "n", "v" }, "[f", function() vscode.action('editor.action.inlineDiffs.previousDiffFile') end, opts)
keymap({ "n", "v" }, "]f", function() vscode.action('editor.action.inlineDiffs.nextDiffFile') end, opts)
