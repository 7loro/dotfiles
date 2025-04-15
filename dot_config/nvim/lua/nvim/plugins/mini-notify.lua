return {
  'echasnovski/mini.notify',
  version = false,
  config = function()
    local notify = require("mini.notify")

    notify.setup({
      ERROR = { duration = 5000, hl_group = "DiagnosticError" },
      WARN  = { duration = 5000, hl_group = "DiagnosticWarn" },
      INFO  = { duration = 5000, hl_group = "DiagnosticInfo" },
      DEBUG = { duration = 0,    hl_group = "DiagnosticHint" },
      TRACE = { duration = 0,    hl_group = "DiagnosticOk" },
      OFF   = { duration = 0,    hl_group = "MiniNotifyNormal" },
    })

    -- 기본 notify 교체
    vim.notify = notify.make_notify()
  end,

  keys = {
    {
      "<leader>nc",
      function() require("mini.notify").clear() end,
      desc = "Clear all notifications",
      silent = true,
    },
    {
      "<leader>nh",
      function() require("mini.notify").show_history() end,
      desc = "Replay all notifications",
      silent = true,
    },
  }
}
