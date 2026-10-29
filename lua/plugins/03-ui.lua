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
    },
    config = function()
      local colors = require("tokyonight.colors").setup()
      require("scrollbar").setup({
        marks = {
          Search = { highlight = { fg = colors.orange } },
          Error = { highlight = { fg = colors.error } },
          Warn = { highlight = { fg = colors.warning } },
          Info = { highlight = { fg = colors.info } },
          Hint = { highlight = { fg = colors.hint } },
          Misc = { highlight = { fg = colors.purple } },
        },
        providers = {
          gitsigns = true,
          search = true,
        },
        scrollbar = {
          thumb = { highlight = { bg = colors.bg_highlight } },
        },
      })
    end,
  },

  {
    "kevinhwang91/nvim-hlslens",
    event = { "BufReadPost", "BufNewFile" },
    -- 追加: ファイルを開いた時にロード 2026-06-20 Sat 04:39:43
    config = function()
      -- scrollbar v2 の search プロバイダはネイティブ検索を直接読むため、
      -- hlslens との連携（build_position_cb 等）は不要
      require("hlslens").setup()
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    -- 追加: ファイルを開いた時にロード 2026-06-20 Sat 04:39:43
    config = function()
      require("gitsigns").setup()
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
