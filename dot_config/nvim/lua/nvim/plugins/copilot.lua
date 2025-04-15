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
  -- blink.cmp 에서 copilot 사용
  {
    "giuxtaposition/blink-cmp-copilot",
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    config = function()
      require("CopilotChat").setup({
        highlight_headers = false,
        separator = '---',
        error_header = '> [!ERROR] Error',
        system_prompty = 'You are a expert code assistant, answer correctly and use in Korean.',
      })
      -- CopilotChat 에서 fzf-lua UI 선택기 사용
      require('fzf-lua').register_ui_select()
    end,
    -- See Commands section for default commands if you want to lazy load on them
  },
}
