return {
  -- for DAP support
  {
    "akinsho/flutter-tools.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>FS", ":FlutterRun <CR>", {})
      vim.keymap.set("n", "<leader>FQ", ":FlutterQuit <CR>", {})
      vim.keymap.set("n", "<leader>FR", ":FlutterRestart <CR>", {})
      vim.keymap.set("n", "<leader>LR", ":FlutterLspRestart <CR>", {})
      vim.keymap.set("n", "<leader>FD", ":FlutterDevTools <CR>", {})
      require("flutter-tools").setup({
        fvm = true,
        widget_guides = { enabled = true },
        lsp = {
          settings = {
            showtodos = true,
            completefunctioncalls = true,
            analysisexcludedfolders = {
              vim.fn.expand("$Home/.pub-cache"),
            },
            renamefileswithclasses = "prompt",
            updateimportsonrename = true,
            enablesnippets = false,
          },
        },
        debugger = {
          -- make these two params true to enable debug mode
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          register_configurations = function(paths)
            local dap = require("dap")
            -- See also: https://github.com/akinsho/flutter-tools.nvim/pull/292
            dap.adapters.dart = {
              type = "executable",
              command = paths.flutter_bin,
              args = { "debug-adapter" },
            }
            dap.configurations.dart = {
              {
                type = "dart",
                request = "launch",
                name = "Launch flutter",
                dartSdkPath = "/Users/casper/fvm/default/bin/",
                flutterSdkPath = "/Users/casper/fvm/default/bin/flutter",
                program = "${workspaceFolder}/lib/main.dart",
                cwd = "${workspaceFolder}",
              },
            }
            -- require("dap.ext.vscode").load_launchjs()
          end,
        },
        decorations = {
          statusline = {
            -- set to true to be able use the 'flutter_tools_decorations.app_version' in your statusline
            -- this will show the current version of the flutter app from the pubspec.yaml file
            app_version = true,
            -- set to true to be able use the 'flutter_tools_decorations.device' in your statusline
            -- this will show the currently running device if an application was started with a specific
            -- device
            device = true,
            -- set to true to be able use the 'flutter_tools_decorations.project_config' in your statusline
            -- this will show the currently selected project configuration
            project_config = false,
          },
        },
        dev_tools = {
          autostart = false, -- autostart devtools server if not detected
          auto_open_browser = false, -- Automatically opens devtools in the browser
        },
        dev_log = {
          -- toggle it when you run without DAP
          enabled = true,
          open_cmd = "10new", -- tabedit, 30vnew, edit, split, vsplit, new, enew
        },
      })
    end,
  },
  -- for dart syntax hightling
  {
    "dart-lang/dart-vim-plugin",
  },
}
