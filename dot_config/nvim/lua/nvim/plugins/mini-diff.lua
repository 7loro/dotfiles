return {
  'echasnovski/mini.diff',
  version = false,
  config = function()
    require('mini.diff').setup({})

    vim.keymap.set('n', '<leader>ho', function()
      require('mini.diff').toggle_overlay()
    end, { desc = 'Toggle mini.diff overlay' })
  end
}
