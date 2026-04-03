-- ── blink.cmp (고성능 자동완성) ─────────────────────────

vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", name = "blink.cmp" },
})

-- 네이티브 바이너리 자동 빌드
local blink_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"
local build_path = blink_path .. "/target/release/libblink_cmp_fuzzy.dylib"

if vim.fn.filereadable(build_path) == 0 then
  vim.notify("blink.cmp 빌드 중...", vim.log.levels.INFO)
  vim.fn.jobstart("cd " .. blink_path .. " && cargo build --release", {
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("blink.cmp 빌드 완료! Neovim을 재시작하세요.", vim.log.levels.INFO)
      end
    end,
  })
end

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-n>"] = { "show", "select_next", "fallback" },
    ["<C-p>"] = { "show", "select_prev", "fallback" },
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },

  signature = {
    enabled = true,
    window = { border = "rounded" },
  },

  appearance = {
    nerd_font_variant = "normal",
    kind_icons = {
      Text = "󰉿", Method = "󰊕", Function = "󰊕", Constructor = "󰒓",
      Field = "󰜢", Variable = "󰆦", Property = "󰖷", Class = "󱡠",
      Interface = "󱡠", Struct = "󱡠", Module = "󰅩", Unit = "󰪚",
      Value = "󰦨", Enum = "󰦨", EnumMember = "󰦨", Keyword = "󰻾",
      Constant = "󰏿", Snippet = "󱄽", Color = "󰏘", File = "󰈔",
      Reference = "󰬲", Folder = "󰉋", Event = "󱐋", Operator = "󰪚",
      TypeParameter = "󰬛",
    },
  },

  completion = {
    trigger = {
      show_on_insert_on_trigger_character = false,
      show_on_keyword = false,
      show_on_trigger_character = true,
      show_on_blocked_trigger_characters = { " ", "\n", "\t", ".", "/" },
    },
    menu = {
      border = "rounded",
      draw = {
        columns = {
          { "kind_icon", gap = 1 },
          { "label", "label_description", gap = 3 },
        },
      },
    },
    documentation = {
      auto_show = true,
      window = { border = "rounded" },
    },
    list = {
      selection = { preselect = false, auto_insert = false },
    },
  },

  sources = {
    default = { "lsp", "path", "buffer" },
  },

  cmdline = {
    sources = { "path", "cmdline" },
  },
})
