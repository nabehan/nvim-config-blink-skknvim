-- ~/.config/nvim/lua/my/telescope/config.lua
--  telescope set up
-- ===================================================================
local vim = vim
local telescope = require("telescope")
-- telescope 設定
telescope.setup({
  defaults = {
    preview = {
      treesitter = true, -- TSハイライトを無効化
    },

    -- ドロップダウン表示
    layout_strategy = "horizontal", -- 水平レイアウトにする
    layout_config = {
      prompt_position = "top",
      width = 0.94, -- 横幅を調整
      height = 0.87, -- 高さを調整
      preview_cutoff = 100, -- プレビューが切り替わる幅
      horizontal = {
        preview_width = 0.62, -- プレビューの幅を調整
      },
    },

    sorting_strategy = "ascending", -- 候補リストを上から表示
    border = true,
    winblend = 20, -- 30 以上だと境界が見えづらくなる場合あり
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    -- borderchars = { "─", "┃", "━", "│", "┌", "┒", "┛", "┕" },

    mappings = {
      i = {
        ["<C-h>"] = "which_key",
      },
      n = {
        ["<C-h>"] = "which_key",
      },
    },
  },

  pickers = {
    -- grep_string = {
    --  additional_args = function()
    --    -- return { "--hidden", "--follow", "--no-ignore" }
    --    return { "--hidden", "--follow", }
    --  end
    -- },
  },

  extensions = {
    fzf = {
      fuzzy = true, -- true: fuzzy検索を有効にする
      override_generic_sorter = true, -- Telescopeのソートを置き換える
      override_file_sorter = true,
      case_mode = "smart_case", -- smart_case / ignore_case / respect_case
    },

    file_browser = {
      hidden = true, -- ← 隠しファイルも表示
      follow_symlinks = true, -- ← シンボリックリンクをたどる
    },

    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },
  },
})

-- ===================================================================
-- Telescope extensions の初期化と設定
-- ===================================================================
local builtin = require("telescope.builtin")
-- fzf extension をロード
telescope.load_extension("fzf")
-- Frecency = frequency（頻度）+ recency（最近）に基づいてファイル検索
telescope.load_extension("frecency")
-- clipboard を telescope から呼び出す
telescope.load_extension("yank_history")
-- Undo を telescope から呼び出す
telescope.load_extension("undo")
-- telescope から File Navigater
telescope.load_extension("file_browser")
-- "live_grep_args"
telescope.load_extension("live_grep_args")
-- To get ui-select loaded and working with telescope
telescope.load_extension("ui-select")

-- -------------------------------------------------------------------
-- Visual モードの選択文字列を任意レジスタに保存し取得する汎用関数
-- @param reg string | nil 使用するレジスタ（例: "v", "a", "_" など）
--                         nil の場合は "v" をデフォルトとして使用
-- @return string 選択されたテキスト（前後の空白を除去）
-- -------------------------------------------------------------------
-- Neovim 0.10+ 推奨の書き方 2026-06-20 Sat 05:06:02
local function get_visual_selection()
  -- 現在のモード（v, V, <C-v>）を取得
  local mode = vim.fn.mode()
  -- 選択開始位置とカーソル位置から、実際のテキストの配列を取得
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })

  return table.concat(lines, "\n")
end

-- -------------------------------------------------------------------
-- ripgrep 用に特殊文字をエスケープする関数
-- @param text string 入力テキスト
-- @return string エスケープ済みのテキスト
-- -------------------------------------------------------------------
local function escape_for_rg(text)
  -- 前後の空白を除去
  return text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("([%[%]%(%)%.%+%-%*%?%^%$])", "\\%1")
  -- return text:gsub('([%[%]%(%)%.%+%-%*%?%^%$])', '\\%1') -- 前後の空白を残す
end

-- -------------------------------------------------------------------
-- 開いているバッファファイルの一覧を取得する
-- -------------------------------------------------------------------
local function get_open_buffer_paths()
  local files = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) ~= "" then
      table.insert(files, vim.api.nvim_buf_get_name(bufnr))
    end
  end
  return files
end

-- -------------------------------------------------------------------
-- 開いているバッファファイルのみを対象に grep する関数
-- -------------------------------------------------------------------
local function grep_open_buffers()
  builtin.live_grep({
    search_dirs = get_open_buffer_paths(),
    additional_args = function()
      return { "--hidden", "--follow", "--no-ignore" }
    end,
  })
end

vim.api.nvim_create_user_command("GrepOpenBuffers", grep_open_buffers, {})

-- -------------------------------------------------------------------
-- Visual 選択を使って開いているバッファから grep する関数
-- -------------------------------------------------------------------
local function grep_open_buffers_selection()
  -- local search_term = get_visual_selection("v")
  local search_term = get_visual_selection() -- 2026-06-20 Sat 05:09:27
  builtin.live_grep({
    search_dirs = get_open_buffer_paths(),
    default_text = escape_for_rg(search_term),
    additional_args = function()
      return { "--hidden", "--follow", "--no-ignore" }
    end,
  })
end

vim.api.nvim_create_user_command("GrepOpenBuffersSelection", grep_open_buffers_selection, {})

-- -------------------------------------------------------------------
-- Visual 選択を使って live_grep（通常スキャン）する関数
-- -------------------------------------------------------------------
local function live_grep_visual_selection_fast()
  -- local search_term = get_visual_selection("v")
  local search_term = get_visual_selection() -- 2026-06-20 Sat 05:09:27
  builtin.live_grep({
    default_text = escape_for_rg(search_term),
  })
end

vim.api.nvim_create_user_command("LiveGrepVisualSelectionFast", live_grep_visual_selection_fast, {})

-- -------------------------------------------------------------------
-- Visual 選択を使って live_grep（全ファイルスキャン）する関数
-- -------------------------------------------------------------------
local function live_grep_visual_selection_full()
  -- local search_term = get_visual_selection("v")
  local search_term = get_visual_selection() -- 2026-06-20 Sat 05:09:27
  builtin.live_grep({
    default_text = escape_for_rg(search_term),
    additional_args = function()
      return { "--hidden", "--follow", "--no-ignore" }
    end,
  })
end

vim.api.nvim_create_user_command("LiveGrepVisualSelectionFull", live_grep_visual_selection_full, {})

-- -------------------------------------------------------------------
require("telescope-all-recent").setup({
  -- 必要に応じて設定をカスタマイズ
  default = {
    disable_cwd_weighting = false,
    ignore_patterns = {
      "*.git/*",
      "*/tmp/*",
    },
    -- シンボリックリンクを表示する
    show_symlinks = true,
  },
})

-- -------------------------------------------------------------------
vim.api.nvim_create_user_command("TelescopeSelectTab", function()
  require("my.telescope.tabpicker").select_tab()
end, {})

-- -------------------------------------------------------------------
-- Telescope 入力ウィンドウで<C-j>でSkkEnable にする
-- -------------------------------------------------------------------
-- 【背景】skk.nvim 本体の enter_key（既定 <C-j>）は挿入モードの実キーマップ
-- （vim.keymap.set）だが、Telescope自身が<C-j>にバッファローカルで
-- actions.nop（改行誤挿入防止のための無害化、Telescope側の実質的な機能は
-- 無い）を割り当てており、Neovimの仕様上バッファローカルが優先されるため
-- 事実上発火しない。Telescopeバッファに限りバッファローカルで上書きする。
--
-- 【候補一覧（▼）のフォーカス移動（<C-n>/<C-p>）について】
-- 同じ理屈で <C-n>/<C-p> もTelescope側の実キーマップ（結果一覧の移動）に
-- 競り負ける。Telescope側でバッファローカルに上書きする対処も試したが、
-- ▼状態のキー処理は CTRL_N/CTRL_P/space/x/ホームポジション選択 以外の
-- キーを無条件で自動確定するフォールバックを持ち、これは vim.on_key() が
-- 実キーマップの解決より先に発火するため、Telescope側の上書きが実行される
-- 前に確定が起きてしまい、統合層（この設定ファイル）だけでは解決できな
-- かった（実機で確認）。そのため <C-n>/<C-p> 自体には手を入れず、
-- skk.nvim 本体の setup()（lua/my/utils/skk.lua）側で
-- extra_candidate_next_key/extra_candidate_prev_key に <C-Up>/<C-Down> を
-- 割り当てる方式に変更した。
-- -------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function(args)
    vim.keymap.set("i", "<C-j>", "<Cmd>SkkEnable<CR>", {
      buffer = args.buf,
      silent = true,
    })
  end,
})
