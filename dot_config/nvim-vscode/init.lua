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

-- move text up and down
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- call vscode commands from neovim

-- general keymaps
-- 터미널 토글
keymap({ "n", "v" }, "<leader>t", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
-- 브레이크포인트 토글
keymap({ "n", "v" }, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
-- 호버 정보 표시
keymap({ "n", "v" }, "<leader>d", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
-- 퀵 픽스 액션
keymap({ "n", "v" }, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
-- 알림 모두 지우기
keymap({ "n", "v" }, "<leader>cn", "<cmd>lua require('vscode').action('notifications.clearAll')<CR>")
-- 파일 검색 (퀵 오픈)
keymap({ "n", "v" }, "<leader>sf", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
-- 문제점 보기
keymap({ "n", "v" }, "<leader>sq", "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>")
-- 심볼로 이동
keymap({ "n" }, "<leader>ss", "<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<CR>")
-- 모든 심볼 보기
keymap({ "n" }, "<leader>sS", "<cmd>lua require('vscode').action('workbench.action.showAllSymbols')<CR>")
-- 명령어 팔레트 열기
keymap({ "n", "v" }, "<leader>cp", "<cmd>lua require('vscode').action('workbench.action.showCommands')<CR>")
-- 코드 실행
keymap({ "n", "v" }, "<leader>pr", "<cmd>lua require('vscode').action('code-runner.run')<CR>")
-- 이전 에러로 이동
keymap({ "n" }, "[e", "<cmd>lua require('vscode').action('editor.action.marker.prev')<CR>")
-- 다음 에러로 이동
keymap({ "n" }, "]e", "<cmd>lua require('vscode').action('editor.action.marker.next')<CR>")
-- 이전 편집기(탭)로 이동
keymap({ "n" }, "[b", "<cmd>lua require('vscode').action('workbench.action.previousEditor')<CR>")
-- 다음 편집기(탭)로 이동
keymap({ "n" }, "]b", "<cmd>lua require('vscode').action('workbench.action.nextEditor')<CR>")
-- 이전 변경사항으로 이동
keymap({ "n" }, "[c", "<cmd>lua require('vscode').action('workbench.action.editor.previousChange')<CR>")
-- 다음 변경사항으로 이동
keymap({ "n" }, "]c", "<cmd>lua require('vscode').action('workbench.action.editor.nextChange')<CR>")
-- 코드 액션 실행
keymap({ "n" }, "<leader>ca", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
-- 문서 포맷팅
keymap({ "n" }, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")
-- 선택 영역 포맷팅
keymap({ "v" }, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatSelection')<CR>")
-- 참조 보기
keymap({ "n" }, "gr", "<cmd>lua require('vscode').action('references-view.findReferences')<CR>")
-- 이름 변경
keymap({ "n" }, "<leader>rn", "<cmd>lua require('vscode').action('editor.action.rename')<CR>")
-- revert
keymap({ "n" }, "<leader>hr", "<cmd>lua require('vscode').action('git.revertSelectedRanges')<CR>")
-- Lazygit
keymap({ "n" }, "<leader>lg", "<cmd>lua require('vscode').action('lazygit.openLazygit')<CR>")

-- harpoon keymaps
-- 현재 파일을 하푼에 추가
keymap({ "n", "v" }, "<leader>ha", "<cmd>lua require('vscode').action('vscode-harpoon.addEditor')<CR>")
-- 하푼 퀵픽 메뉴 열기
keymap({ "n", "v" }, "<leader>ho", "<cmd>lua require('vscode').action('vscode-harpoon.editorQuickPick')<CR>")
-- 하푼 에디터 설정 편집
keymap({ "n", "v" }, "<leader>he", "<cmd>lua require('vscode').action('vscode-harpoon.editEditors')<CR>")
-- 하푼 파일로 이동
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
