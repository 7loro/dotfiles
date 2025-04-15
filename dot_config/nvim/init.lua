require("options")
require("autocmds")

if vim.g.vscode then
  print("VSCode extension")
  require("vscode.keymaps")
else
  print("Neovim extension")
  require("nvim.keymaps")
  require("nvim.lazy")
  require("nvim.lsp")

  -- 입력 언어 자동 전환
  vim.g.im_select_get_im_cmd = "['im-select']"
  vim.g.im_select_default = "com.apple.keylayout.UnicodeHexInput"
end
