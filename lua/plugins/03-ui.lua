-- lua/plugins/03-ui.lua
return {
  { "HiPhish/rainbow-delimiters.nvim" },

  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    config = function()
      require("marks").setup({
        sign_priority = {
          lower = 10,
          upper = 15,
          builtin = 8,
          bookmark = 20,
        },
      })
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    -- 追加: ファイルを開いた時にロード 2026-06-20 Sat 04:39:43
    config = function()
      require("ibl").setup({
        indent = {
          char = "╎",
          highlight = "NonText",
        },
        scope = { enabled = true },
        whitespace = { remove_blankline_trail = true },
        exclude = {
          filetypes = { "help", "terminal", "lazy", "dashboard" },
          buftypes = { "terminal" },
        },
      })
    end,
  },

  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },

  {
    "echasnovski/mini.icons",
    config = function()
      require("mini.icons").setup()
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "folke/noice.nvim", -- statusline で noice API を使用するため
    },
    config = function()
      require("my.ui.statusline")
    end,
  },

  {
    "petertriho/nvim-scrollbar",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "kevinhwang91/nvim-hlslens",
    },
    config = function()
      local colors = require("tokyonight.colors").setup()
      require("scrollbar").setup({
        handle = { color = colors.bg_highlight },
        marks = {
          Search = { color = colors.orange },
          Error = { color = colors.error },
          Warn = { color = colors.warning },
          Info = { color = colors.info },
          Hint = { color = colors.hint },
          Misc = { color = colors.purple },
        },
        handlers = {
          gitsigns = true,
          search = true,
        },
      })
    end,
  },

  {
    "kevinhwang91/nvim-hlslens",
    event = { "BufReadPost", "BufNewFile" },
    -- 追加: ファイルを開いた時にロード 2026-06-20 Sat 04:39:43
    config = function()
      -- build_position_cb で検索位置を scrollbar に渡す（公式推奨の連携方法）
      require("hlslens").setup({
        build_position_cb = function(plist, _, _, _)
          require("scrollbar.handlers.search").handler.show(plist.start_pos)
        end,
      })
      -- 検索コマンド終了時に scrollbar の検索マークを非表示にする
      vim.cmd([[
        augroup scrollbar_search_hide
          autocmd!
          autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
        augroup END
      ]])
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    -- 追加: ファイルを開いた時にロード 2026-06-20 Sat 04:39:43
    config = function()
      require("gitsigns").setup()
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },

  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({
        input = {
          enabled = true,
          border = "rounded",
          default_prompt = "Input:",
          win_options = { winblend = 20 },
        },
        select = {
          enabled = true,
          backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
          trim_prompt = true,
        },
      })
    end,
  },

  {
    "gen740/SmoothCursor.nvim",
    config = function()
      require("smoothcursor").setup()
    end,
  },

  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end,
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    -- 追加: ファイルを開いた時にロード 2026-06-20 Sat 04:39:43
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = true,
          css = true,
          mode = "background",
        },
      })
    end,
  },
}
