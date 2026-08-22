-- lua/plugins/04-treesitter.lua
--
-- 【2026-08 変更】nvim-treesitter のフルリライト（デフォルトブランチが
-- master → main に変更）に伴う書き換え。main ブランチには旧 API の
-- require("nvim-treesitter.configs") が存在せず、以前の設定はそのままでは
-- 動作しない（Failed to run `config` for nvim-treesitter エラーの原因）。
-- 旧 master ブランチは凍結されており Neovim 0.12 系では非対応のため、
-- ここでは main ブランチの新 API に合わせて書き直している。
--
-- 新 API の要点:
--   - require('nvim-treesitter').setup({...}) はパーサーの管理設定のみ。
--   - ハイライト/インデントの有効化はこのプラグインの責務ではなくなり、
--     Neovim 組み込みの vim.treesitter.start() / indentexpr を
--     FileType autocmd で自前で呼び出す必要がある。
--   - ensure_installed / auto_install 相当の設定項目は廃止。
--     明示的に require('nvim-treesitter').install({...}) を呼ぶ。
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      ts.setup({})

      -- 旧 ensure_installed 相当：起動時に未インストールのパーサーだけ入れる
      local ensure_installed = {
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
      }

      local installed_ok, installed = pcall(function()
        return ts.get_installed("parsers")
      end)
      local installed_set = {}
      if installed_ok and installed then
        for _, lang in ipairs(installed) do
          installed_set[lang] = true
        end
      end

      local to_install = {}
      for _, lang in ipairs(ensure_installed) do
        if not installed_set[lang] then
          table.insert(to_install, lang)
        end
      end
      if #to_install > 0 then
        ts.install(to_install)
      end

      -- filetype 名 → tree-sitter 言語名の対応（一致しないもののみ明示）。
      -- 「対応パーサーの有無」で汎用的に判定する方式は、noice.nvim/nvim-notify
      -- の通知フロート（filetype="notify"）のような管理対象外の一時バッファにも
      -- 反応してクラッシュを引き起こしたため廃止し、ensure_installed に
      -- 含まれる言語だけを対象にする方式に変更した。
      local ft_to_lang = {
        help = "vimdoc",
        tex = "latex",
        plaintex = "latex",
        lisp = "commonlisp",
      }

      -- 旧 highlight.enable / indent.enable 相当：
      -- ensure_installed に含まれる言語の filetype でのみ、
      -- vim.treesitter.start() と treesitter ベースの indentexpr を有効化する。
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("my-treesitter-start", { clear = true }),
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if ft == "" then
            return
          end

          local lang = ft_to_lang[ft] or ft
          if not vim.tbl_contains(ensure_installed, lang) then
            -- 管理対象外の filetype（notify 等）には一切手を出さない
            return
          end

          local function enable()
            pcall(vim.treesitter.start, args.buf, lang)
            -- indent: プラグイン側が experimental と明記している機能
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end

          if pcall(vim.treesitter.language.add, lang) then
            enable()
          else
            -- 対応パーサー未インストール。追加インストールを試み、
            -- 完了後にあらためて有効化する。
            ts.install({ lang }):await(function()
              if pcall(vim.treesitter.language.add, lang) then
                enable()
              end
            end)
          end
        end,
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
