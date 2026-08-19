-- lua/plugins/04-treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "query",

          "bash",
          "python",
          "json",
          "yaml",
          "toml",

          "markdown",
          "markdown_inline",
          "latex",
          "typst",
          "r",
          "julia",
          "commonlisp",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          -- disable                           = { "markdown", "markdown_inline", "latex" },
        },
        indent = {
          enable = true,
          -- disable = { "markdown", "markdown_inline", "latex" },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 3,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "outer",
        mode = "cursor",
        -- disable_filetype    = { "latex", "markdown", "text" },
      })
    end,
  },
}
