return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
  },
  event = "VeryLazy",
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
    vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
    vim.keymap.set("n", "<leader>dn", dap.step_into, { desc = "DAP: Step into" })
    vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP: Step over" })
    vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "DAP: Step out" })
    vim.keymap.set("n", "<leader>dN", dap.step_back, { desc = "DAP: Step back" })
    vim.keymap.set("n", "<leader>gb", dap.run_to_cursor, { desc = "DAP: Run to cursor" })

    -- Eval var under cursor
    vim.keymap.set("n", "<leader>?", function()
      require("dapui").eval(nil, { enter = true })
    end, { desc = "DAP: Eval var under cursor" })

    vim.keymap.set({ "n", "x" }, "<leader>dx", function()
      require("dapui").eval()
    end, { desc = "DAP-UI: Eval" })

    vim.keymap.set("n", "<leader>dX", function()
      require("dapui").eval(vim.fn.input("expression: "), {})
    end, { desc = "DAP-UI: Eval expression" })

    require("dapui").setup({
      icons = { expanded = "▾", collapsed = "▸" },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            "breakpoints",
            "stacks",
            "watches",
          },
          size = 80,
          position = "left",
        },
      },
    })
  end,
}
