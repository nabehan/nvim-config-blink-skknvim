-- ~/.config/nvim/lua/my/utils/skk.lua
-- skk.nvim（denops非依存・Lua実装のSKK日本語入力）の設定。
--
-- 【重要・呼び出し順序】require("skk").setup({ blink = {...} }) は、
-- 内部で skk.blink_source.setup() を自動的に呼ぶ（lua/skk/init.lua 参照）。
-- そちらが登録する candidate_navigation（候補選択ウィンドウ表示中の
-- <C-n>/<C-p> フォーカス移動と blink.cmp 側のキーマップとの競合対策）は、
-- blink.cmp 自体の setup() が完了済みであることを前提にしている
-- （skk.nvim README「使い方」参照）。
-- このファイルは、lazy.nvim のプラグイン読み込み（06-lsp.lua の config()
-- 経由で lua/my/cmp/blink.lua の blink.setup() を実行する）が完了した後、
-- init.lua のトップレベルで require("my.utils.skk") される前提で書いている。
-- require の位置を変える場合はこの順序を崩さないよう注意すること。
local skk = require("skk")

skk.setup({
  -- enter_key = "<C-j>", -- 下行と排他的に指定する
  -- enter_key = "<C-\\>", -- 下行と排他的に指定する
  enter_key = "<C-;>", -- 下行と排他的に指定する
  -- buffer_enter_key = "<C-j>", cmdline_enter_key = "<C-j>",

  -- キーボード配列の都合で変えたい場合に指定する。省略時は現状通り。
  -- char_key_to_ascii = "l",         -- ひらがな/カタカナ -> 半角英数
  -- char_key_to_kata_or_hira = "q",  -- ひらがな<->カタカナの相互遷移
  -- char_key_to_zenei = "L",         -- ひらがな/カタカナ -> 全角英数
  -- abbrev_key = "/",                -- abbrevモード開始

  -- <C-j> の度に noice.nvim の通知ウィンドウが開いて煩わしいため無効化。
  -- カーソル位置のモードインジケーター表示（ひら/カタ/latn/ＬＡ）は
  -- このオプションと独立しており、そのまま出続ける。
  notify_mode_change = false,

  sticky_shift_enabled = true,
  sticky_shift_key = ";",

  egg_like_newline = true,

  -- 候補一覧（▼）のフォーカス移動（<C-n>/<C-p>相当）の追加キー。
  -- Telescope 等、自身が <C-n>/<C-p> をバッファローカルな実キーマップで
  -- 占有する外部UIのプロンプト内では skk.nvim 本体の <C-n>/<C-p>
  -- （candidate_navigation）が事実上機能しないため、それらの外部UIでは
  -- 未使用のキーをここで追加の候補送りキーとして割り当てる（詳細は
  -- lua/skk/init.lua の extra_candidate_next_key/extra_candidate_prev_key
  -- のコメント参照）。<C-n>/<C-p>自体は変更しない。
  -- extra_candidate_next_key = "<C-Down>",
  -- extra_candidate_prev_key = "<C-Up>",
  -- extra_candidate_next_key = "<C-Left>",
  -- extra_candidate_prev_key = "<C-Right>",
  extra_candidate_next_key = "<C-j>",
  extra_candidate_prev_key = "<C-k>",

  candidate_window = {
    border = "rounded", -- "rounded"/"single"/"double"/"none"/省略時 "rounded"
    annotation = true, -- 候補一覧に辞書の注釈表示 省略時 true
    page_indicator = true, -- 最下行のページ表示
    threshold = 2, -- 候補選択ウィンドウが表示されるまでの <SPC> 打鍵回数

    -- 配色 省略時はカラースキームのNormalFloat/FloatBorderのまま
    -- fg = "#d8dee9",
    -- bg = "#223249", -- 非選択の候補行
    -- border_fg = "#1b4252", -- #88c0d0 枠線
    alt_bg = "#2e3440", --  1行おきの縞模様（可読性向上、省略時は縞なし）
  },

  -- ▽/▼のインライン表示の配色（省略時はComment/IncSearch）
  -- candidate_fg/bgは候補ウィンドウの選択行のハイライトにも連動する。
  midashi_fg = "#ff9e64",
  candidate_fg = "#d8dee9", -- #2e3440
  candidate_bg = "#1b4252", -- #ebcb8b

  -- インラインのモードインジケーター（ひら/カタ/latn/ＬＡ）の配色 省略時は NormalFloat
  -- indicator_fg = "#2e3440",
  -- indicator_bg = "#ff9e64",

  -- 個人辞書（学習）。skkeleton 版と同じパスを指定しているが、
  -- ファイル形式は異なるため学習内容は引き継がれない（実質的に
  -- 空の状態から学習し直しになる）。
  user_dictionary = vim.fn.expand("~/.local/share/skk/SKK-JISYO.user"),

  -- SKKサーバー（yaskkserv2）。skkeleton 側は skkServerReqEnc/ResEnc を
  -- 変更していなかった（既定 euc-jp）ため、同じ euc-jp を明示指定する。
  skkserv = {
    host = "127.0.0.1",
    port = 1178,
    encoding = "euc-jp",
  },

  -- ローカル辞書（skkeleton の globalDictionaries 相当）。
  dictionaries = {
    { path = "/usr/local/share/skk/SKK-JISYO.jawiki", encoding = "utf-8" },
    { path = "/usr/local/share/skk/SKK-JISYO.edict2", encoding = "utf-8" },
    { path = "/usr/local/share/skk/SKK-JISYO.emoji", encoding = "utf-8" },
    { path = "/usr/local/share/skk/SKK-JISYO.emoji-ja", encoding = "utf-8" },
  },

  -- blink.cmp ネイティブソース（lua/my/cmp/blink.lua の
  -- sources.providers.skk と対）の挙動。値は skk.nvim 側の既定値と同じ
  -- （skkeleton 側に対応する個別設定は元々無かったため新規）。
  blink = {
    max_items = 50,
    skip_skkserv = false,
    skkserv_candidates = true,
    skkserv_candidate_limit = 50,
  },

  period = "。", -- デフォルトは "。"
  comma = "、", -- デフォルトは "、"
})

-- skkeleton の <Plug>(skkeleton-enable) 相当のキーマップ。
-- 挿入モード・コマンドラインモードは setup() の enter_key ("<C-j>") が
-- そのままカバーするので、ここでは旧 lua/my/utils/skkeleton.lua にあった
-- Normal モード用の合成キーマップ（i で挿入モードに入りつつ有効化）だけを
-- 移植する（skk.nvim には skkeleton の <Plug>(skkeleton-enable) に相当する
-- 既製のマッピングが無いため、enable() を直接呼ぶ）。
-- vim.keymap.set("n", "<C-j>", function()
-- vim.keymap.set("n", "<C-\\>", function()
vim.keymap.set("n", "<C-;>", function()
  vim.cmd("startinsert")
  skk.enable()
end, { silent = true, desc = "SKKを有効にして挿入モードへ" })
