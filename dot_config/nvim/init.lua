if vim.g.vscode then
  require("vscode-neovim.configs")
else
  require("nvim.configs")
  require("nvim.themes")
  require("nvim.lsp")

  -- plugins 폴더의 모든 lua 파일을 자동 로드
  local plugins_path = vim.fn.stdpath("config") .. "/lua/nvim/plugins"
  for _, file in ipairs(vim.fn.readdir(plugins_path)) do
    if file:match("%.lua$") then
      require("nvim.plugins." .. file:gsub("%.lua$", ""))
    end
  end

  require("nvim.keymaps")
end
