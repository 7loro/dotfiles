return {
  "ibhagwan/fzf-lua",
  -- 아이콘 지원을 위한 선택적 의존성
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- fzf-lua 설정 (선택 사항, 필요시 여기에 추가)
    require('fzf-lua').setup({{"telescope",winopts={preview={default="bat"}}}})

    -- 키맵 설정
    local map = vim.keymap.set
    local builtin = require('fzf-lua')

    -- 기존 Telescope 키맵을 fzf-lua 함수로 매핑
    map('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    map('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    map('n', '<leader>sf', builtin.files, { desc = '[S]earch [F]iles' })
    map('n', '<leader>sw', builtin.grep_cword, { desc = '[S]earch current [W]ord' })
    -- fzf-lua의 주요 기능 목록을 보여주고 선택 실행
    map('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect fzf-lua Action' })
    map('n', '<leader>sg', function() builtin.live_grep_native({ command = "rg --color=always --line-number --no-heading --smart-case --hidden" }) end, { desc = '[S]earch by [G]rep (Native)' })
    map('n', '<leader>sG', function() builtin.live_grep_glob({ command = "rg --color=always --line-number --no-heading --smart-case --hidden" }) end, { desc = '[S]earch by [G]rep (Glob)' })
    map('n', '<leader>sd', builtin.diagnostics_workspace, { desc = '[S]earch [D]iagnostics (Workspace)' }) -- 또는 diagnostics_document()
    map('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    map('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    map('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- Flutter Commands: fzf-lua에는 내장된 Flutter 확장 기능이 없습니다.
    -- 해당 기능이 필요하면 별도의 플러그인이나 커스텀 함수를 고려해야 합니다.
    -- map('n', '<leader>Fc', "<cmd>lua require('telescope').extensions.flutter.commands()<cr>", { desc = 'Flutter [c]ommands' }) -- 이 줄은 제거하거나 주석 처리

    map('n', '<leader>gs', builtin.git_status, { desc = '[G]it [S]tatus' })

    -- 현재 버퍼에서 퍼지 검색
    map('n', '<leader>/', builtin.blines, { desc = '[/] Fuzzily search in current buffer' })

    -- 모든 파일에서 grep (live_grep과 유사)
    map('n', '<leader>s/', function() builtin.grep({ search = "" }) end, { desc = '[S]earch [/] in Project (Grep)' }) -- live_grep 대신 일반 grep 사용 예시

    -- Neovim 설정 파일 검색
    map('n', '<leader>sn', function() builtin.files({ cwd = vim.fn.stdpath('config') }) end, { desc = '[S]earch [N]eovim files' })

    -- 참고: fzf-lua는 다양한 다른 함수들을 제공합니다.
    -- :lua require('fzf-lua').COMMAND_NAME() 형태로 직접 실행해보거나 문서를 참고하세요.
    -- 예: :lua require('fzf-lua').git_commits()
    -- 예: :lua require('fzf-lua').lsp_references()

  end
}
