local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- remap leader key
keymap("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- move text up and down
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- call vscode commands from neovim

-- general keymaps
keymap({ "n", "v" }, "<leader>t", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
keymap({ "n", "v" }, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
keymap({ "n", "v" }, "<leader>d", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
keymap({ "n", "v" }, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
keymap({ "n", "v" }, "<leader>sp", "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>")
keymap({ "n", "v" }, "<leader>cn", "<cmd>lua require('vscode').action('notifications.clearAll')<CR>")
keymap({ "n", "v" }, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
keymap({ "n", "v" }, "<leader>cp", "<cmd>lua require('vscode').action('workbench.action.showCommands')<CR>")
keymap({ "n", "v" }, "<leader>pr", "<cmd>lua require('vscode').action('code-runner.run')<CR>")
keymap({ "n", "v" }, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")
keymap({ "n" }, "[e", "<cmd>lua require('vscode').action('editor.action.marker.prev')<CR>")
keymap({ "n" }, "]e", "<cmd>lua require('vscode').action('editor.action.marker.next')<CR>")
keymap({ "n" }, "[b", "<cmd>lua require('vscode').action('workbench.action.previousEditor')<CR>")
keymap({ "n" }, "]b", "<cmd>lua require('vscode').action('workbench.action.nextEditor')<CR>")
keymap({ "n" }, "[c", "<cmd>lua require('vscode').action('workbench.action.editor.previousChange')<CR>")
keymap({ "n" }, "]c", "<cmd>lua require('vscode').action('workbench.action.editor.nextChange')<CR>")
keymap({ "n" }, "<leader>ca", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
keymap({ "n" }, "<leader>cf", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")
keymap({ "v" }, "<leader>cf", "<cmd>lua require('vscode').action('editor.action.formatSelection')<CR>")
keymap({ "n" }, "<leader>gr", "<cmd>lua require('vscode').action('references-view.findReferences')<CR>")
keymap({ "n" }, "<leader>rn", "<cmd>lua require('vscode').action('editor.action.rename')<CR>")
keymap({ "n" }, "<leader>gs", "<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<CR>")
keymap({ "n" }, "<leader>gS", "<cmd>lua require('vscode').action('workbench.action.showAllSymbols')<CR>")

-- harpoon keymaps
keymap({ "n", "v" }, "<leader>ha", "<cmd>lua require('vscode').action('vscode-harpoon.addEditor')<CR>")
keymap({ "n", "v" }, "<leader>ho", "<cmd>lua require('vscode').action('vscode-harpoon.editorQuickPick')<CR>")
keymap({ "n", "v" }, "<leader>he", "<cmd>lua require('vscode').action('vscode-harpoon.editEditors')<CR>")
keymap({ "n", "v" }, "<leader>h1", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor1')<CR>")
keymap({ "n", "v" }, "<leader>h2", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor2')<CR>")
keymap({ "n", "v" }, "<leader>h3", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor3')<CR>")
keymap({ "n", "v" }, "<leader>h4", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor4')<CR>")
keymap({ "n", "v" }, "<leader>h5", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor5')<CR>")
keymap({ "n", "v" }, "<leader>h6", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor6')<CR>")
keymap({ "n", "v" }, "<leader>h7", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor7')<CR>")
keymap({ "n", "v" }, "<leader>h8", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor8')<CR>")
keymap({ "n", "v" }, "<leader>h9", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor9')<CR>")

-- 간단한 메시지 출력 테스트 (VSCode 내에서 Neovim이 로드되었는지 확인)
vim.cmd([[autocmd VimEnter * echom "VSCode Neovim 설정이 로드되었습니다."]])
