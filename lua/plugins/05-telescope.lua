-- lua/plugins/05-telescope.lua
return {
  { "nvim-lua/plenary.nvim", lazy = true },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },

  {
    "nvim-telescope/telescope.nvim",
    -- tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "debugloop/telescope-undo.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "prochri/telescope-all-recent.nvim",
    },
    -- config は require("my.telescope.config") で行う（init.lua）
  },

  { "nvim-telescope/telescope-ui-select.nvim", lazy = true },
  { "debugloop/telescope-undo.nvim", lazy = true },
  { "nvim-telescope/telescope-file-browser.nvim", lazy = true },
  { "nvim-telescope/telescope-frecency.nvim", lazy = true },
  { "kkharji/sqlite.lua", lazy = true },
  { "nvim-telescope/telescope-symbols.nvim", lazy = true },
  { "nvim-telescope/telescope-live-grep-args.nvim", lazy = true },
  { "prochri/telescope-all-recent.nvim", lazy = true },

  {
    "gbprod/yanky.nvim",
    config = function()
      require("yanky").setup({
        highlight = {
          on_put = true,
          on_yank = true,
          timer = 255,
        },
        preserve_cursor_position = { enabled = true },
      })
    end,
  },
}
