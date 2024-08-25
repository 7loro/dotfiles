local keyMapper = function(from, to, mode, opts)
  mode = mode or "n"
  local options = {
    noremap = true, -- normal 모드
    silent = true,
  }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end

  vim.keymap.set(mode, from, to, options)
end

return { mapKey = keyMapper }
