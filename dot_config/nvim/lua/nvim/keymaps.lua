-- ── 기본 ────────────────────────────────────────────────
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = '검색 하이라이트 제거' })
vim.keymap.set('n', '<C-s>', '<cmd>write<CR>', { desc = '파일 저장' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = '터미널 모드 종료' })

-- ── 편집 ────────────────────────────────────────────────
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv', { desc = '선택 텍스트 아래로 이동' })
vim.keymap.set('v', 'p', 'P', { desc = '붙여넣기 (레지스터 유지)' })
vim.keymap.set('v', '<', '<gv', { noremap = true, silent = true, desc = '내어쓰기 (선택 유지)' })
vim.keymap.set('v', '>', '>gv', { noremap = true, silent = true, desc = '들여쓰기 (선택 유지)' })

-- ── 진단 ────────────────────────────────────────────────
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = '진단 Quickfix 목록 열기' })
vim.keymap.set('n', ']q', ':cnext<CR>', { desc = '다음 Quickfix 항목' })
vim.keymap.set('n', '[q', ':cprev<CR>', { desc = '이전 Quickfix 항목' })

-- ── LSP ─────────────────────────────────────────────────
-- 기본 LSP 키맵 제거
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'gra')
vim.keymap.del('v', 'gra')

vim.keymap.set('n', 'K', function()
  vim.lsp.buf.hover { border = "rounded", max_height = 25, max_width = 150 }
end, { desc = 'Hover 문서 표시' })

-- ── fzf-lua (검색) ──────────────────────────────────────
local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '파일 검색' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = 'Grep 검색' })
vim.keymap.set('n', '<leader>sb', fzf.buffers, { desc = '버퍼 검색' })
vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = '도움말 검색' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '이전 검색 이어하기' })
vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '커서 단어 검색' })

-- ── Mini.files (파일 탐색) ──────────────────────────────
vim.keymap.set('n', '<leader>e', function()
  require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
end, { desc = '파일 탐색기 열기' })

-- ── Mini.diff (Git 변경) ────────────────────────────────
vim.keymap.set('n', ']c', function()
  if vim.wo.diff then
    vim.cmd.normal { ']c', bang = true }
  else
    MiniDiff.goto_hunk('next')
  end
end, { desc = '다음 Git 변경으로 이동' })

vim.keymap.set('n', '[c', function()
  if vim.wo.diff then
    vim.cmd.normal { '[c', bang = true }
  else
    MiniDiff.goto_hunk('prev')
  end
end, { desc = '이전 Git 변경으로 이동' })

vim.keymap.set('n', '<leader>hs', 'ghgh', { remap = true, desc = 'Hunk 스테이지' })
vim.keymap.set('x', '<leader>hs', 'gh', { remap = true, desc = '선택 영역 스테이지' })
vim.keymap.set('n', '<leader>hr', 'gHgh', { remap = true, desc = 'Hunk 리셋' })
vim.keymap.set('x', '<leader>hr', 'gH', { remap = true, desc = '선택 영역 리셋' })
vim.keymap.set('n', '<leader>hS', 'ggghG', { remap = true, desc = '버퍼 전체 스테이지' })
vim.keymap.set('n', '<leader>hR', 'gggHG', { remap = true, desc = '버퍼 전체 리셋' })
vim.keymap.set('n', '<leader>hp', MiniDiff.toggle_overlay, { desc = 'Git diff 오버레이 토글' })

-- ── Trouble (진단 패널) ─────────────────────────────────
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = '전체 진단 토글' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = '현재 버퍼 진단 토글' })
vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = '심볼 목록 토글' })
vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP 정의/참조 토글' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List 토글' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List 토글' })

-- ── LazyGit ─────────────────────────────────────────────
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'LazyGit 열기' })

-- ── Markview (마크다운) ─────────────────────────────────
vim.keymap.set('n', '<leader>mt', '<cmd>Markview toggle<cr>', { desc = '마크다운 미리보기 토글' })


