-- ── mini.nvim (모듈형 플러그인 모음) ────────────────────

vim.pack.add({
  { src = "https://github.com/echasnovski/mini.nvim", name = "mini" },
})

-- ── 개별 모듈 활성화 ───────────────────────────────────
require("mini.icons").setup()
require("mini.files").setup()
require("mini.surround").setup()
require("mini.pairs").setup()
require("mini.ai").setup()
require("mini.indentscope").setup()
require("mini.cursorword").setup()
require("mini.statusline").setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

      local total = vim.fn.line("$")
      local lw = #tostring(total)
      local location = string.format("Ln %" .. lw .. "d/%d  Col %-3d", vim.fn.line("."), total, vim.fn.virtcol("."))

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
        "%<",
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
        { hl = "MiniStatuslineFileinfo", strings = { search, location } },
      })
    end,
  },
})
require("mini.tabline").setup()
require("mini.comment").setup()

require("mini.diff").setup({
  view = {
    style = 'sign',
    signs = { add = '+', change = '~', delete = '_' },
  },
})

require("mini.hipatterns").setup({
  highlighters = {
    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
  },
})

-- ── 대시보드 (mini.starter) ────────────────────────────
local starter = require("mini.starter")
starter.setup({
  evaluate_single = true,
  items = {
    starter.sections.recent_files(5, false),
    starter.sections.recent_files(5, true),
    { name = "New File", action = "enew", section = "Builtin" },
    { name = "Quit",     action = "qall", section = "Builtin" },
  },
  content_hooks = {
    starter.gen_hook.adding_bullet("» "),
    starter.gen_hook.aligning("center", "center"),
  },
  header = [[
   ____   _    ____  ____  _____ ____
  / ___| / \  / ___||  _ \| ____|  _ \
 | |    / _ \ \___ \| |_) |  _| | |_) |
 | |___/ ___ \ ___) |  __/| |___|  _ <
  \___/_/   \_\____/|_|   |_____|_| \_\

  ]],
  footer = function()
    local datetime = os.date("%Y-%m-%d %H:%M:%S")
    local stats = vim.api.nvim_list_runtime_paths()
    return "📅 " .. datetime .. " | 🛠️  Modules: " .. #stats
  end,
})

-- ── 단축키 힌트 (mini.clue) ────────────────────────────
require("mini.clue").setup({
  triggers = {
    { mode = "n", keys = "<leader>" },
    { mode = "x", keys = "<leader>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "<C-w>" },
  },
  window = { delay = 300, config = { border = "rounded", width = 50 } },
})
