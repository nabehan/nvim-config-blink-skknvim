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
-- Telescope 入力ウィンドウで<C-n>/<C-p>を、henkan（▼）アクティブ時は
-- skk.nvimの候補フォーカス移動へ、そうでない時はTelescope本来の結果一覧
-- 移動へ、という形で使い分ける
--
-- 【背景】skk.nvim 本体の候補フォーカス移動（lua/skk/init.lua の
-- candidate_navigation、既定 <C-n>/<C-p>）はグローバルな vim.keymap.set()
-- で実装されているが、Telescope自身も<C-n>/<C-p>にバッファローカルな実
-- キーマップ（move_selection_next/previous、TelescopeResultsの選択移動）を
-- 持っており、Neovimの仕様上バッファローカルは常にグローバルより優先される
-- ため、Telescopeプロンプト内ではskk.nvim側のグローバルマッピングは
-- 事実上発火しない（実機で確認）。
-- <C-n>/<C-p>自体（手癖）は変えたくないので、Telescopeバッファに限り
-- バッファローカルで上書きし、henkanアクティブ時はskk.nvim側
-- （M.focus_next_candidate()/M.focus_prev_candidate()、henkan非アクティブ
-- なら false を返すのみで何もしない）を優先し、henkan非アクティブ時は
-- Telescope本来のmove_selection_next/previousへフォールバックする。
-- -------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function(args)
    vim.keymap.set("i", "<C-j>", "<Cmd>SkkEnable<CR>", {
      buffer = args.buf,
      silent = true,
    })
    vim.keymap.set("i", "<C-n>", function()
      if not require("skk").focus_next_candidate() then
        require("telescope.actions").move_selection_next(args.buf)
      end
    end, {
      buffer = args.buf,
      silent = true,
    })
    vim.keymap.set("i", "<C-p>", function()
      if not require("skk").focus_prev_candidate() then
        require("telescope.actions").move_selection_previous(args.buf)
      end
    end, {
      buffer = args.buf,
      silent = true,
    })
  end,
})
