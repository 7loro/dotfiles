local mapKey = require("utils.keyMapper").mapKey

return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup()

      mapKey("]c", ":Gitsigns next_hunk<CR>")
      mapKey("[c", ":Gitsigns prev_hunk<CR>")

      mapKey("<leader>hp", gitsigns.preview_hunk)
      mapKey("<leader>hr", gitsigns.reset_hunk)
      mapKey("<leader>hr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "v")
      mapKey("<leader>tb", gitsigns.toggle_current_line_blame)
      mapKey("<leader>hd", gitsigns.diffthis)
      mapKey("<leader>hD", function()
        gitsigns.diffthis("~")
      end)
    end,
  },
  {
    "tpope/vim-fugitive",
  },
}
