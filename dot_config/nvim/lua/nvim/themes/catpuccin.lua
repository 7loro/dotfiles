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
          }
        end
      }
      vim.cmd.colorscheme 'catppuccin' -- 테마 적용
      vim.cmd.hi 'Comment gui=none' -- 하이라이트 커스터마이징
    end,
  }
