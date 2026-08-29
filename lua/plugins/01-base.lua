-- lua/plugins/01-base.lua
-- 操作補助・快適化
return {
  { "vim-denops/denops.vim", lazy = false }, -- DenopsReady イベントを確実に発火させる
  { "h-hg/fcitx.nvim" },
  { "farmergreg/vim-lastplace" },
  { "kana/vim-smartword" },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        persist_size = false,
        size = function(term)
          if term.direction == "horizontal" then
            return math.floor(vim.o.lines * 0.3)
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.3)
          end
        end,
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = {
          border = "single",
          winblend = 20,
          width = function()
            return math.floor(vim.o.columns * 0.80)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.74)
          end,
          title_pos = "center",
        },
        shade_terminals = true,
        insert_mappings = true,
        terminal_mappings = true,
        start_in_insert = true,
      })
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        -- <CR> は blink.cmp 側の確定キーマップに任せる。
        -- true のままだと InsertEnter のたびに autopairs が <CR> を
        -- 上書きし、補完メニューの確定ができなくなる。
        map_cr = false,
      })
    end,
  },

  -- {
  --   "echasnovski/mini.pairs",
  --   event = "InsertEnter",
  --   opts = {}, -- これだけでデフォルトのカッコ補完がすべて有効になります
  -- },

  -- {
  --   "m4xshen/autoclose.nvim",
  --   event = "InsertEnter",
  --   config = function()
  --     require("autoclose").setup({
  --       -- デフォルトで非常にシンプルに動作し、<CR> の競合が起きにくい設計です
  --     })
  --   end,
  -- },

  -- {
  --   "altermo/ultimate-autopair.nvim",
  --   -- インサートモードとコマンドラインモードの進入時に読み込む（公式推奨）
  --   event = { "InsertEnter", "CmdlineEnter" },
  --   branch = "v0.6",
  --   opts = {
  --     -- blink.cmp 側の確定を邪魔しないよう、改行（CR）のマッピングをオフにする
  --     cr = { enable = false },
  --   },
  -- },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
    end,
  },

  {
    "swaits/scratch.nvim",
    config = function()
      require("scratch").setup()
    end,
  },
}
