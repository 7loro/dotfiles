return {
  {
    'akinsho/flutter-tools.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
    },
    config = function()
      require('flutter-tools').setup {
        flutter_path = '/Users/casper/fvm/default/bin/flutter',
        flutter_lookup_cmd = nil,
        fvm = false,
        widget_guides = { enabled = true },
        lsp = {
          color = { -- show the derived colours for dart variables
            enabled = true, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
            background = false, -- highlight the background
            background_color = nil, -- required, when background is transparent (i.e. background_color = { r = 19, g = 17, b = 24},)
            foreground = false, -- highlight the foreground
            virtual_text = true, -- show the highlight using virtual text
            virtual_text_str = '■', -- the virtual text character to highlight
          },
          settings = {
            showtodos = true,
            completefunctioncalls = true,
            analysisexcludedfolders = {
              vim.fn.expand '$Home/.pub-cache',
            },
            renamefileswithclasses = 'prompt',
            updateimportsonrename = true,
            enablesnippets = false,
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          fvm = true,
          dev_log = {
            enabled = false,
            filter = nil, -- optional callback to filter the log
            -- takes a log_line as string argument; returns a boolean or nil;
            -- the log_line is only added to the output if the function returns true
            notify_errors = false, -- if there is an error whilst running then notify the user
            open_cmd = "15split", -- command to use to open the log buffer
            focus_on_open = true, -- focus on the newly opened log window
          },
          register_configurations = function(paths)
            local dap = require 'dap'
            -- See also: https://github.com/akinsho/flutter-tools.nvim/pull/292
            dap.adapters.dart = {
              type = 'executable',
              command = paths.flutter_bin,
              args = { 'debug-adapter' },
            }
            -- dap.configurations.dart = {
            --   {
            --     type = 'dart',
            --     request = 'launch',
            --     name = 'Launch flutter',
            --     dartSdkPath = '/Users/casper/fvm/default/bin/',
            --     flutterSdkPath = '/Users/casper/fvm/default/bin/flutter',
            --     program = '${workspaceFolder}/lib/main.dart',
            --     cwd = '${workspaceFolder}',
            --   },
            -- }
          end,
        },
      }
    end,
  },
  -- for dart syntax hightling
  {
    'dart-lang/dart-vim-plugin',
    config = function()
      vim.g.dart_format_on_save = false
      vim.g.dart_style_guide = 2
      vim.g.dart_html_in_string = true
      -- vim.g.dart_trailing_comma_indent = true 이거 키면 파라메터 들여쓰기가 2칸이 안 되고 4칸이 되는 문제 있음
      vim.g.dartfmt_options = { '--line-length', '150' } -- 라인 길이 설정
      -- keymap 추가: <leader>df -> DartFmt 실행
      vim.api.nvim_set_keymap('n', '<leader>df', ':DartFmt<CR>', { noremap = true, silent = true, desc = '[d]art [f]ormat' })
      vim.api.nvim_set_keymap('v', '<leader>df', ":'<,'>DartFmt<CR>", {
        noremap = true,
        silent = true,
        desc = '[d]art [f]ormat'
      })
    end,
    ft = 'dart',
  },
}
