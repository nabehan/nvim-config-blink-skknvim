-- lua/plugins/06-lsp.lua
return {
  -- ===================================================================
  -- 1. LSP 基盤 & 管理 (nvim-lspconfig / mason.nvim)
  -- ===================================================================
  { "neovim/nvim-lspconfig" },

  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "single", -- ポップアップの枠線をスッキリ表示
        },
      })
    end,
  },

  -- ===================================================================
  -- 2. LSP サーバーの自動インストール & 有効化
  -- ===================================================================
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        -- 現在インストール済みのLSPサーバー、および環境構築時に自動で入れたいサーバー一覧
        ensure_installed = {
          "bashls", -- Bash / Sh
          "julials", -- Julia
          "lua_ls", -- Lua
          "markdown_oxide", -- Markdown
          "pyright", -- Python
          "r_language_server", -- R
          "texlab", -- LaTeX
          "tinymist", -- Typst
          "vimls", -- VimL
        },

        -- インストールしたLSPサーバーを個別に require('lspconfig').xxx.setup{}
        -- と並べる手間を省き、一括で自動登録・有効化するハンドラ
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              -- 将来的に補完強化などの capabilities を設定したくなった場合はここに追記
            })
          end,
          -- 特定のLSPサーバーにだけ特殊な引数を渡したい場合は以下のように個別に書けます
          -- ["tinymist"] = function()
          --   require("lspconfig").tinymist.setup({ ... })
          -- end,
        },
      })
    end,
  },

  -- ===================================================================
  -- 3. フォーマッタ・リンター (LSP外ツール) の自動管理 & 連携
  -- ===================================================================
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "nvimtools/none-ls.nvim",
      "nvimtools/none-ls-extras.nvim",
    },
    config = function()
      local null_ls = require("null-ls")
      local mason_null_ls = require("mason-null-ls")

      -- 受け皿となる none-ls (旧 null-ls) のコアセットアップ
      null_ls.setup({
        sources = {
          -- 特別な手動登録ソースがない限り、空のままで自動注入に任せられます
        },
      })

      -- mason-null-ls の設定を行い、Mason と none-ls を仲介
      mason_null_ls.setup({
        -- 自動インストールしたいフォーマッタやリンターのリスト
        ensure_installed = {
          "beautysh", -- Bash フォーマッタ (インデント整形など)
          "shellcheck", -- Bash リンター (構文・バグチェック)
          "stylua", --  --Lua コードの自動整形
          "ruff", -- Python の超高速リンター ＋ フォーマッタ
          "prettier", -- Markdown / JSON などの万能フォーマッタ
        },
        -- 【超重要】これを true にすることで、Mason で手動/自動インストールした
        -- フォーマッタやリンターが、自動で none-ls に登録され Neovim 上で有効化されます
        automatic_setup = true,
        handlers = {},
      })
    end,
  },

  -- ===================================================================
  -- 4. 補完エンジン (blink.cmp) & 各種ソース
  -- ===================================================================
  -- blink.cmp 本体
  -- config は require("my.cmp.blink") で行う（init.lua）
  {
    "saghen/blink.cmp",
    -- v2 は開発中で config スキーマに破壊的変更が入るため、安定した v1 系に固定する
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip",
      -- nvim-cmp 用ソースを blink.cmp 上で動かすための互換レイヤー
      -- impersonate_nvim_cmp: nvim-cmp 本体を入れていないため、各ソース内部の
      -- require("cmp") 参照（cmp.lsp.CompletionItemKind 等）をシムして解決する
      -- lazy=true にしない: require("cmp") (blink.compat が同梱する偽 cmp
      -- モジュール) を起動直後から確実に使えるようにするため
      -- （skkeleton_cmp_shim.lua がこれに visible()/confirm() を生やす）
      { "saghen/blink.compat", version = "2.*", opts = { impersonate_nvim_cmp = true } },
      -- 互換レイヤー経由で使い続ける nvim-cmp ソース群
      -- (skkeleton は lua/my/cmp/skkeleton_source.lua のネイティブソースに
      -- 置き換えたため、ここには含めない)
      { "hrsh7th/cmp-calc" },
      { "hrsh7th/cmp-emoji" },
      { "f3fora/cmp-spell" },
      { "kdheepak/cmp-latex-symbols" },
      { "lukas-reineke/cmp-rg" },
    },
    config = function()
      require("my.cmp.blink")
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
  },
  { "rafamadriz/friendly-snippets" },
}
