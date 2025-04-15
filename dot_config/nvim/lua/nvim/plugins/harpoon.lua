return {
  'ThePrimeagen/harpoon',
  lazy = false,
  branch = 'harpoon2',
  init = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    vim.keymap.set('n', '<leader>A', function()
      harpoon:list():add()
    end, { desc = 'Add to harpoon' })
    vim.keymap.set('n', '<leader>he', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set('n', '<leader>1', function()
      harpoon:list():select(1)
    end, { desc = 'Open harpoon 1 item' })
    vim.keymap.set('n', '<leader>2', function()
      harpoon:list():select(2)
    end, { desc = 'Open harpoon 2 item' })
    vim.keymap.set('n', '<leader>3', function()
      harpoon:list():select(3)
    end, { desc = 'Open harpoon 3 item' })
    vim.keymap.set('n', '<leader>4', function()
      harpoon:list():select(4)
    end, { desc = 'Open harpoon 4 item' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', 'hp', function()
      harpoon:list():prev()
    end, { desc = 'prev item in harpoon' })
    vim.keymap.set('n', 'hn', function()
      harpoon:list():next()
    end, { desc = 'next item in harpoon' })
  end,
  dependencies = { 'nvim-lua/plenary.nvim' },
}

