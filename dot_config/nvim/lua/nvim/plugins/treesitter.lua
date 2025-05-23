return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      auto_install = true,
      ensure_installed = {
        "bash",
        "css",
        "dockerfile",
        "go",
        "gomod",
        "gowork",
        "gotmpl",
        "gohtmltmpl",
        "gotexttmpl",
        "html",
        "javascript",
        "tsx",
        "lua",
        "scss",
        "typescript",
        "jsonc",
        "ruby",
        "vim",
        "yaml",
        "markdown",
        "markdown_inline",
      },
      ignore_install = { "dart" },
      sync_install = false,
      playground = {
        enable = true,
      },
      autotag = {
        enable = true,
      },
      highlight = {
        enable = true,
        disable = { "yaml", "dart" },
        additional_vim_regex_highlighting = { "yaml", "jack", "haskell", "dart" },
      },
      incremental_selection = { enable = true },
      indent = {
        enable = true,
        -- disable = { "dart" },
      },
      autopairs = { enable = false },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
    },
  },
}
