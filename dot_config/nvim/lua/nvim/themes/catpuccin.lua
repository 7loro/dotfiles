return {
    'catppuccin/nvim',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        transparent_background = true, -- 배경 투명하게 설정
        custom_highlights = function(colors)
          return {
            -- Visual 영역 색상 커스터마이징 (Visual: 원하는 색상으로 설정)
            Visual = { bg = colors.surface2, style = { 'bold' } },
            LineNr = { fg = colors.rosewater }, -- 줄 번호 색상 커스터마이징
            CursorLineNr = { fg = colors.pink, style = { 'bold' } }, -- 현재 줄 번호 색상 커스터마이징

            -- MiniTablineModifiedCurrent에 밑줄 스타일 추가
            -- fg와 bg를 설정하지 않으면 catppuccin의 기본 색상이 적용됩니다.
            -- style 테이블에 원하는 스타일 (bold, italic 등)과 함께 'underline'을 추가합니다.
            MiniTablineModifiedCurrent = { style = { 'bold', 'italic', 'underline' } }, -- 예시: 기존 볼드, 이탤릭에 밑줄 추가
          }
        end
      }
      vim.cmd.colorscheme 'catppuccin' -- 테마 적용
      vim.cmd.hi 'Comment gui=none' -- 하이라이트 커스터마이징
    end,
  }
