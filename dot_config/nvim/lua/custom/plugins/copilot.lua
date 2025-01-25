return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter', -- 입력 모드에서만 로드
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = false, -- 자동 제안 비활성화
          auto_trigger = false,
        },
        panel = {
          enabled = false, -- 패널 비활성화
          auto_refresh = false,
        },
      }
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
