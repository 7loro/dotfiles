return {}
-- return {
--   'saghen/blink.cmp',
--   -- optional: provides snippets for the snippet source
--   dependencies = { 'rafamadriz/friendly-snippets' },
--
--   -- use a release tag to download pre-built binaries
--   version = '1.*',
--   -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
--   -- build = 'cargo build --release',
--   -- If you use nix, you can build from source using latest nightly rust with:
--   -- build = 'nix run .#build-plugin',
--
--   ---@module 'blink.cmp'
--   ---@type blink.cmp.Config
--   opts = {
--     -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
--     -- 'super-tab' for mappings similar to vscode (tab to accept)
--     -- 'enter' for enter to accept
--     -- 'none' for no mappings
--     --
--     -- All presets have the following mappings:
--     -- C-space: Open menu or open docs if already open
--     -- C-n/C-p or Up/Down: Select next/previous item
--     -- C-e: Hide menu
--     -- C-k: Toggle signature help (if signature.enabled = true)
--     --
--     -- See :h blink-cmp-config-keymap for defining your own keymap
--     keymap = {
--       preset = 'default',
--
--       -- show with a list of providers
--       ['<C-j>'] = {
--         function(cmp)
--           cmp.show({ providers = {'lsp', 'path', 'snippets', 'buffer', 'copilot' } })
--         end
--       },
--       ["<Tab>"] = {
--         function(cmp)
--           return cmp.select_next()
--         end,
--         "snippet_forward",
--         "fallback",
--       },
--       ["<S-Tab>"] = {
--         function(cmp)
--           return cmp.select_prev()
--         end,
--         "snippet_backward",
--         "fallback",
--       },
--     },
--
--     signature = {
--       enabled = true,
--       window = { border = "rounded" },
--     },
--
--     appearance = {
--       -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
--       -- Adjusts spacing to ensure icons are aligned
--       nerd_font_variant = 'Nerd Font Mono',
--       -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
--       kind_icons = {
--         Copilot = "",
--         Text = '󰉿',
--         Method = '󰊕',
--         Function = '󰊕',
--         Constructor = '󰒓',
--
--         Field = '󰜢',
--         Variable = '󰆦',
--         Property = '󰖷',
--
--         Class = '󱡠',
--         Interface = '󱡠',
--         Struct = '󱡠',
--         Module = '󰅩',
--
--         Unit = '󰪚',
--         Value = '󰦨',
--         Enum = '󰦨',
--         EnumMember = '󰦨',
--
--         Keyword = '󰻾',
--         Constant = '󰏿',
--
--         Snippet = '󱄽',
--         Color = '󰏘',
--         File = '󰈔',
--         Reference = '󰬲',
--         Folder = '󰉋',
--         Event = '󱐋',
--         Operator = '󰪚',
--         TypeParameter = '󰬛',
--       },
--     },
--
--     -- (Default) Only show the documentation popup when manually triggered
--     completion = {
--       trigger = {
--         -- 입력 도중 특정 "트리거 문자"를 입력했을 때 자동 완성 창이 나타나는 것을 막는 역할
--         -- 공백, 줄 바꿈, 탭, 점(.), 슬래시(/)를 입력해도 자동 완성 창이 자동으로 뜨지 않습니다.
--         show_on_blocked_trigger_characters = {' ', '\n', '\t', '.', '/'},
--
--         -- 특정 상황에서 커서가 특정 "트리거 문자" 뒤에 놓일 때 자동 완성 창이 나타나는 것을 막는 역할
--         -- 입력 모드 진입 시: 입력 모드로 처음 들어갔을 때 커서가 이 옵션에 지정된 문자 바로 뒤에 있는 경우.
--         -- 자동 완성 아이템 수락 후: 자동 완성 아이템을 선택하여 삽입한 후 커서가 이 옵션에 지정된 문자 바로 뒤에 있는 경우.
--         show_on_x_blocked_trigger_characters = {"'", '"', '(', '['},
--
--         -- 입력 모드 진입 시 자동 Prefetch 비활성화
--         prefetch_on_insert = false,
--         -- 스니펫 내에서 자동 표시 비활성화 (원하는 경우 true 유지)
--         show_in_snippet = false,
--         -- 키워드 입력 시 자동 표시 비활성화
--         show_on_keyword = false,
--         -- 트리거 문자 입력 시 자동 표시 활성화 (수동 트리거를 위한 핵심 설정)
--         show_on_trigger_character = true,
--         -- 자동 완성 아이템 수락 후 트리거 문자 뒤에 자동 표시 비활성화
--         show_on_accept_on_trigger_character = false,
--         -- 입력 모드 진입 시 트리거 문자 뒤에 자동 표시 비활성화
--         show_on_insert_on_trigger_character = false,
--       },
--       documentation = {
--         auto_show = true,
--         auto_show_delay_ms = 250,
--         update_delay_ms = 50,
--         treesitter_highlighting = true,
--         window = { border = "rounded" },
--       },
--       list = {
--         selection = {
--           preselect = false,
--           auto_insert = false,
--         },
--       },
--       menu = {
--         border = "rounded",
--         draw = {
--           columns = {
--             { "label", "label_description", gap = 1 },
--             { "kind_icon", "kind" },
--           },
--           treesitter = { "lsp" },
--         },
--       },
--       -- ghost_text = { enabled = true },
--     },
--
--     -- Default list of enabled providers defined so that you can extend it
--     -- elsewhere in your config, without redefining it, due to `opts_extend`
--     sources = {
--       default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
--       providers = {
--         copilot = {
--           name = "copilot",
--           module = "blink-cmp-copilot",
--           score_offset = 100,
--           async = true,
--           transform_items = function(_, items)
--             local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
--             local kind_idx = #CompletionItemKind + 1
--             CompletionItemKind[kind_idx] = "Copilot"
--             for _, item in ipairs(items) do
--               item.kind = kind_idx
--             end
--             return items
--           end,
--         },
--       },
--     },
--
--     -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
--     -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
--     -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
--     --
--     -- See the fuzzy documentation for more information
--     fuzzy = { implementation = "prefer_rust_with_warning" }
--   },
--   opts_extend = { "sources.default" }
-- }
