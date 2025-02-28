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
            enablesnippets = true,
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          register_configurations = function(paths)
            local dap = require 'dap'
            -- See also: https://github.com/akinsho/flutter-tools.nvim/pull/292
            dap.adapters.dart = {
              type = 'executable',
              command = paths.flutter_bin,
              args = { 'debug-adapter' },
            }
            dap.configurations.dart = {
              {
                type = 'dart',
                request = 'launch',
                name = 'Launch flutter',
                dartSdkPath = '/Users/casper/fvm/default/bin/',
                flutterSdkPath = '/Users/casper/fvm/default/bin/flutter',
                program = '${workspaceFolder}/lib/main.dart',
                cwd = '${workspaceFolder}',
              },
            }
            require('dap.ext.vscode').load_launchjs()
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
      vim.g.dart_trailing_comma_indent = true
      -- keymap 추가: <leader>df -> DartFmt 실행
      vim.api.nvim_set_keymap('n', '<leader>df', ':DartFmt<CR>', { noremap = true, silent = true })
    end,
    ft = 'dart',
  },
}
