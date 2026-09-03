# Neovim 設定ドキュメント（blink.cmp + skk.nvim 版）

- **プラグインマネージャー:** [lazy.nvim](https://github.com/folke/lazy.nvim)
- **補完エンジン:** [blink.cmp](https://github.com/Saghen/blink.cmp)（v1系固定）+ [blink.compat](https://github.com/Saghen/blink.compat)（旧 nvim-cmp ソース互換レイヤー、calc/emoji/latex_symbols/spell/rg 用）
- **日本語入力:** [skk.nvim](https://github.com/nabehan/skk.nvim)（denops 非依存・Lua 実装、blink.cmp ネイティブソース同梱）
- **対象バージョン:** NVIM v0.12 以降
- **OS:** Manjaro Linux (x86_64)
- **由来:** この設定は [nvim-config-blink-skkeleton](https://github.com/nabehan/nvim-config-blink-skkeleton) をベースに改変
  - 日本語入力を skkeleton から自作の skk.nvim へ置き換え、SKK 関連の設定・連携部分のみ作り直した。
  - lazy.nvim・blink.cmp まわりの構成やその他のプラグインは元設定を踏襲した。

---

## ディレクトリ構成

```
~/.config/nvim-blink-skknvim/
├── init.lua                        # エントリーポイント
├── onkey_debug.lua                 # skk.nvim/nvim-autopairs 相性問題の診断用一時スクリプト（後述）
├── search_test.md                  # 検索・移動・正規表現の動作確認用サンプルテキスト
└── lua/
    ├── plugins/                    # プラグイン定義（lazy.nvim）
    │   ├── 01-base.lua             # 操作補助・快適化
    │   ├── 02-colorschemes.lua     # カラースキーム
    │   ├── 03-ui.lua               # UI 関連
    │   ├── 04-treesitter.lua       # Treesitter
    │   ├── 05-telescope.lua        # Telescope
    │   ├── 06-lsp.lua              # LSP・補完（blink.cmp）
    │   ├── 07-markdown.lua         # Markdown・Typst・LaTeX
    │   ├── 08-migemo.lua           # Migemo 検索
    │   ├── 09-notify-skk.lua       # Noice・SKK（skk.nvim）
    │   └── 10-lisp.lua             # Common Lisp 開発環境（conjure）
    └── my/                         # カスタム設定
        ├── autocommand.lua         # オートコマンド（LSP keymap・保存時整形・改行コード変換等）
        ├── keymap.lua              # グローバルキーマップ
        ├── cmp/
        │   ├── blink.lua           # blink.cmp 設定本体（skk.nvim 連携もここ）
        │   ├── keymap.lua          # blink.cmp トグルキーマップ
        │   ├── LuaSnipCustom.lua   # オリジナルスニペット（today/now/dw）
        │   ├── regex_source.lua    # 正規表現補完ソース（cmdline 専用・blink ネイティブ実装）
        │   └── luasnip_source.lua  # LuaSnip トリガー文字列を出すだけのネイティブソース（展開・ジャンプは <Tab> が担当）
        ├── markdown/
        │   ├── keymap.lua          # Markdown キーマップ（<leader>m*）
        │   ├── list.lua            # 箇条書き・番号付きリスト・チェックボックス・引用のオリジナルコマンド
        │   └── table.lua           # テキストブロック → Markdown テーブル変換のオリジナルコマンド
        ├── telescope/
        │   ├── config.lua          # Telescope 設定・拡張
        │   ├── keymap.lua          # Telescope キーマップ
        │   └── tabpicker.lua       # タブ選択ピッカー
        ├── ui/
        │   └── statusline.lua      # lualine ステータスライン
        └── utils/
            ├── skk.lua             # SKK（skk.nvim）日本語入力設定
            ├── clean_blank_lines.lua # 空行整理
            ├── ranger.lua          # Ranger ファイル選択（toggleterm 経由）
            ├── stable.lua          # 列揃えユーティリティ
            └── yank_insert.lua     # Yank 履歴挿入
```

- **`onkey_debug.lua` と `search_test.md` について**
  - skk.nvim と nvim-autopairs の相性問題を調査した際の診断用ファイル
    - 詳細は [skk.nvim README](https://github.com/nabehan/skk.nvim#nvim-autopairs-との相性問題実機で発見重要) 参照
  - 問題（挿入位置の割り込み・カーソル位置のずれ）は skk.nvim v0.1.1 で解決済み。
  - その後発見された abbrev モードでの別の相性問題（既知のハマりどころ10番参照）の調査でも、実機でのキー入力ログ採取に再利用した。この問題は skk.nvim 本体ではなく `blink.lua` 側の対応（`SkkHenkanChanged` での `nvim-autopairs` の enable/disable 切り替え）で解決済みのため、いずれも通常の利用では不要だが、記録として残してある。

---

## セットアップ手順

### 初回インストール

```bash
# 1. 設定を配置
git clone git@github.com:nabehan/nvim-config-blink-skknvim.git ~/.config/nvim-blink-skknvim

# 2. NVIM_APPNAME を指定して nvim を起動（lazy.nvim が自動インストール・プラグイン同期）
NVIM_APPNAME=nvim-blink-skknvim nvim
```

- `~/.bashrc`/`~/.zshrc` 等に alias（例: `alias nvim-skk="NVIM_APPNAME=nvim-blink-skknvim nvim"`）を用意しておくと便利。
- blink.cmp は Rust 製フュージーマッチャーのプリビルドバイナリを GitHub Releases から取得する
- そのため、初回起動時にネットワーク接続が必要
  - `fuzzy.implementation = "prefer_rust_with_warning"` を指定
  - 目的は取得に失敗した場合に自動的に純 Lua 実装にフォールバックするため

### 初回起動後の追加作業

```vim
" noice で cmdline の正規表現ハイライトを有効にする
:TSInstall regex
```

- skk.nvim 側の辞書・skkserv（yaskkserv2）の準備は [skk.nvim README](https://github.com/nabehan/skk.nvim) 参照。
- `:checkhealth skk` でセットアップ状態を診断できる。

---

## プラグイン一覧

### 01-base.lua — 操作補助・快適化

| プラグイン               | 概要                                                      |
| ------------------------ | --------------------------------------------------------- |
| vim-denops/denops.vim    | Deno ベースのプラグイン基盤 （`lazy=false` で即時ロード） |
| h-hg/fcitx.nvim          | IME 状態自動切換                                          |
| farmergreg/vim-lastplace | 前回カーソル位置を復元                                    |
| kana/vim-smartword       | 日本語対応の単語移動                                      |
| akinsho/toggleterm.nvim  | フローティングターミナル（ranger 起動にも使用）           |
| windwp/nvim-autopairs    | 括弧・クォートの自動補完（InsertEnter）                   |
| kylechui/nvim-surround   | テキストオブジェクトの囲み操作（VeryLazy）                |
| numToStr/Comment.nvim    | コメントアウト（VeryLazy）                                |
| stevearc/oil.nvim        | バッファ感覚のファイラー                                  |
| swaits/scratch.nvim      | スクラッチバッファ                                        |

> **注意（重要）:**
>
> - `vim-denops/denops.vim` は `lazy=false` を明示的に設定すること。skk.nvim 自体は denops 非依存だが、他のプラグイン（markdown-preview.nvim 等）が denops に依存しているため引き続き必要。
> - `nvim-autopairs` は **`map_cr = false` を必ず指定すること**。
>   - `true` のままだと `InsertEnter` のたびに autopairs が挿入モードの `<CR>` を上書きし、blink.cmp の補完確定キーマップが機能しなくなる。
>   - その代わり、関数呼び出し確定時の括弧自動補完は `lua/my/cmp/blink.lua` 側の `completion.accept.auto_brackets.enabled = true` で担っている。
> - nvim-autopairs と skk.nvim の日本語入力（ひらがな/カタカナ/全角英数モード）との相性問題（挿入位置の割り込み・カーソル位置のずれ）は、skk.nvim v0.1.1 で解決済み。それ以前のバージョンでは既知の不具合があった。
> - abbrev モード（`/` から始める見出し入力）で見出しが空・候補0件のまま記号を打鍵すると、プレエディットが即座に確定してしまう別の相性問題があった。skk.nvim 本体の修正ではなく、`lua/my/cmp/blink.lua` の `SkkHenkanChanged` ハンドラで henkan（▽/▼/abbrev）アクティブ中は `require("nvim-autopairs").disable()`、`idle` に戻ったら `enable()` を呼ぶ方式で解決した（詳細は下記「既知のハマりどころ」10番、および [skk.nvim README](https://github.com/nabehan/skk.nvim#abbrev-モードでのオートペア相性問題と推奨される回避策実機で発見重要) 参照）。

### 02-colorschemes.lua — カラースキーム

- 現在の使用テーマ: **kanagawa**
  - `lazy=false, priority=1000` で最優先ロード。
- 切り替えは `init.lua` 末尾の `vim.cmd[[colorscheme <name>]]` を変更する。

### 03-ui.lua — UI 関連

| プラグイン                          | event       | 概要                                     |
| ----------------------------------- | ----------- | ---------------------------------------- |
| HiPhish/rainbow-delimiters.nvim     | start       | 括弧の虹色ハイライト                     |
| chentoast/marks.nvim                | VeryLazy    | マークの可視化                           |
| lukas-reineke/indent-blankline.nvim | BufReadPost | インデントガイド                         |
| nvim-tree/nvim-web-devicons         | start       | ファイルアイコン                         |
| echasnovski/mini.icons              | start       | アイコン補完                             |
| nvim-lualine/lualine.nvim           | start       | ステータスライン                         |
| petertriho/nvim-scrollbar           | start       | スクロールバー（gitsigns・hlslens 連携） |
| kevinhwang91/nvim-hlslens           | BufReadPost | 検索マッチ数・位置表示                   |
| lewis6991/gitsigns.nvim             | BufReadPost | Git 差分サインカラム                     |
| stevearc/dressing.nvim              | start       | `vim.ui.input` / `vim.ui.select` の強化  |
| gen740/SmoothCursor.nvim            | start       | スムーズカーソル                         |
| karb94/neoscroll.nvim               | start       | スムーズスクロール                       |
| NvChad/nvim-colorizer.lua           | BufReadPost | カラーコードのインラインプレビュー       |

### 04-treesitter.lua — Treesitter

- 自動インストール対象パーサー:
  - lua / vim / vimdoc / query / bash / python / json / yaml / toml / markdown / markdown_inline / latex / typst / r / julia / commonlisp
- `nvim-treesitter` の `main` ブランチ（新API）に対応済み。
- 旧 `master` ブランチの `require("nvim-treesitter.configs")` は Neovim 0.12 系では非対応
- そのため、`vim.treesitter.start()` を `FileType` autocmd で自前で呼び出す方式に書き換えてある（詳細は `04-treesitter.lua` 冒頭のコメント参照）。

### 05-telescope.lua — ファジーファインダー

| プラグイン                    | 概要                                           |
| ----------------------------- | ---------------------------------------------- |
| nvim-telescope/telescope.nvim | ファジーファインダー本体（tag/branch指定なし） |
| telescope-fzf-native.nvim     | fzf ネイティブソーター                         |
| telescope-ui-select.nvim      | `vim.ui.select` を Telescope で表示            |
| telescope-file-browser.nvim   | ファイルブラウザ                               |
| telescope-frecency.nvim       | 頻度＋最近のファイル検索                       |
| telescope-undo.nvim           | undo ツリーを Telescope で表示                 |
| telescope-live-grep-args.nvim | ripgrep 引数付き grep                          |
| telescope-all-recent.nvim     | 全 Telescope ピッカーに recency 重み付け       |
| gbprod/yanky.nvim             | yank 履歴管理                                  |
| kkharji/sqlite.lua            | frecency 用 SQLite                             |

> **注意:**
>
> - telescope.nvim は `tag`/`branch` 指定なしで使用する。
> - `tag = "0.1.8"` は Neovim 0.12 で廃止 API によりエラーになる。
> - プロンプト（`buftype="prompt"`）で skk.nvim を使えるよう、`lua/my/telescope/config.lua` の
>   `FileType TelescopePrompt` オートコマンドでバッファローカルに `enter_key`（現在 `<C-\>`）を
>   `:SkkEnable` に上書きしている（Telescope 本体が既定で `<C-j>` を無害化=`actions.nop` して
>   おり、`enter_key` にこのキーを使う場合はそちらが優先されるため）。候補一覧のフォーカス
>   移動は `<C-n>`/`<C-p>` ではなく `extra_candidate_next_key`/`extra_candidate_prev_key`
>   （上記 09-notify-skk.lua 参照、現在値・注意点は同節参照）。

### 06-lsp.lua — LSP・補完

#### **LSP 管理:**

| プラグイン                        | 概要                                                |
| --------------------------------- | --------------------------------------------------- |
| neovim/nvim-lspconfig             | LSP クライアント設定                                |
| mason-org/mason.nvim              | LSP サーバー自動インストール（UI border: single）   |
| williamboman/mason-lspconfig.nvim | mason と lspconfig の橋渡し・自動ハンドラ           |
| jay-babu/mason-null-ls.nvim       | フォーマッタ・リンター管理（automatic_setup: true） |

- **自動インストール LSP サーバー:**
  - bashls / julials / lua_ls / markdown_oxide / pyright / r_language_server / texlab / tinymist / vimls
- **自動インストール フォーマッタ・リンター（mason-null-ls）:**
  - beautysh / shellcheck / stylua / ruff / prettier

#### 補完エンジン: blink.cmp

- `hrsh7th/nvim-cmp` から `saghen/blink.cmp` に移行済み。
- 設定本体は `lua/my/cmp/blink.lua`（`06-lsp.lua` の `config()` から `require("my.cmp.blink")` として読み込まれる）。

#### **プラグイン構成の要点（`06-lsp.lua`）:**

- `saghen/blink.cmp` は **`version = "1.*"` に固定**する。v2 は開発中で設定スキーマに破壊的変更が入るため、`version = "*"`（最新タグ追従）にすると意図せず互換性のない版を掴む可能性がある。
- `calc` / `emoji` / `latex_symbols` / `spell` / `rg` は blink.cmp にネイティブ実装が無いため、`saghen/blink.compat` 経由で旧 nvim-cmp 用ソースをそのまま利用する。
- `skk`（skk.nvim）は本体同梱のネイティブ blink.cmp ソース（`skk.blink_source`）を使う。`blink.compat` は経由しない。
- `require("skk").setup({ blink = {...} })` を呼ぶだけでソースの登録・実装が完結しており、skkeleton 時代のような専用ソースファイルや nvim-cmp 偽装シムは一切不要（後述）。
- `blink.compat` の `opts.impersonate_nvim_cmp = true` を指定すること。nvim-cmp 本体をインストールしていないため、各ソース内部にある `require("cmp")`（`cmp.lsp.CompletionItemKind` 等の参照）をシムして解決する必要がある。

#### **`sources.providers.*.name` の注意点（ハマりどころ）:**

- `blink.compat` は `providers.<id>.name` を **「nvim-cmp 側での登録名」として使って実体モジュール（`cmp_calc` 等）を解決する**。
- そのため `name` に表示用のラベル（`"[CALC]"` など）を入れてしまうと、実体を解決できずに候補が一切表示されなくなる。
- 表示上のブラケット付きラベルは `completion.menu.draw.components.source_name.text` 関数側で付与しており、`calc` / `emoji` / `latex_symbols` / `spell` / `rg` の `name` フィールドはソースの実名のまま変更しないこと。（`skk` はネイティブソースのためこの制約は無関係。`name` は自由に `"[SKK]"` のような表示用ラベルにしてよい。）

#### **source 構成（`lua/my/cmp/blink.lua` の `default_sources()`）:**

```
common          = skk / snippets(LuaSnip) / lsp / path / calc / emoji / latex_symbols / buffer / spell
prog_sources    = common + rg        ← プログラミング / スクリプト言語
writing_sources = common - buffer    ← markdown / text / mdx
それ以外        = common のみ
```

- cmdline（`:` `/` `?`）補完は別途 `cmdline.sources` で定義しており、`:` では `cmdline` / `path` / `buffer` / `regex`、`/` `?` では `buffer` / `regex` を使用する。

| ソース                                          | 表示ラベル | 概要                                                    |
| ----------------------------------------------- | ---------- | ------------------------------------------------------- |
| lsp（blink 組み込み）                           | `[LSP]`    | LSP 補完                                                |
| snippets（ネイティブ: luasnip_source.lua）      | `[SNIP]`   | スニペットのトリガー文字列（展開自体は `<Tab>` が担当） |
| buffer（blink 組み込み）                        | `[BUF]`    | バッファ内単語（3文字以上）                             |
| path（blink 組み込み）                          | `[PATH]`   | ファイルパス                                            |
| rg（compat: cmp-rg）                            | `[rGREP]`  | ripgrep（プログラミング言語のみ）                       |
| spell（compat: cmp-spell）                      | `[SPELL]`  | スペル補完（英字4文字以上で発火）                       |
| calc（compat: cmp-calc）                        | `[CALC]`   | 計算機                                                  |
| emoji（compat: cmp-emoji）                      | `[EMOJI]`  | 絵文字                                                  |
| latex_symbols（compat）                         | `[LATEX]`  | LaTeX 記号                                              |
| skk（ネイティブ: skk.blink_source）             | `[SKK]`    | SKK 変換候補（score_offset:100 で最優先表示）           |
| regex（カスタム・blinkネイティブ、cmdline専用） | `[REGEX]`  | Vim 正規表現キーワード                                  |

#### **SKK（skk.nvim）との連携（`lua/my/utils/skk.lua` + `lua/my/cmp/blink.lua`）:**

- `require("skk").setup({...})` は `lua/my/utils/skk.lua` で行う。
  - 内部で `skk.blink_source.setup()` を自動的に呼ぶため、blink.cmp 側の `setup()` が完了した**後**に呼ぶ必要がある（呼び出し順は `init.lua` のコメント参照）。
- 補完候補は `sources.providers.skk`（`module = "skk.blink_source"`）が skk.nvim 内部の変換候補を直接返す。
  - `▽`/`▼` の表示は skk.nvim 自身の extmark（仮想テキスト）で行われ実バッファは変化しないため、`SkkHenkanChanged`（`User` autocmd）で phase の変化を検知し、`▽`/`abbrev` 中だけ `blink.show({ providers = { "skk" } })` を呼んで手動でメニューを更新している。
  - `providers` を省略すると、読みが伸びても2回目以降の `show()` が無視され候補が更新されないまま止まるので注意（skk.nvim README「実装上の既知のクセ」参照）。
- **`<CR>` の egg_like_newline 対策:**
  - skk.nvim は `<CR>` に独自のキーマップを持たず `vim.on_key()`（観測専用）のみで確定処理を行うため、素のままでは blink.cmp 側の `<CR>` キーマップの `fallback`（素の改行挿入）が確定後も必ず実行されてしまう。
  - `SkkHenkanChanged` が `phase="idle"` になった直後の1回だけ `require("skk").confirm_henkan()` の戻り値を見てこの `fallback` をスキップするガードを入れてある（`blink.lua` 冒頭 `my_skk_cr_fallback_guard` 周辺のコメント参照）。
- **`vim.g.my_skk_suppress_blink_on_select`（デバッグ用スイッチ、既定 `false`）:**
  - skkeleton 版では「▼（変換候補選択）状態では blink.cmp 全体を無効化する」設計だったが、この設定では表示の重複が発生しないことを確認済みのため、既定では無効化せず `hide()`/`show()` の切り替えのみで対応している。
  - 実機固有の問題かどうかを切り分けたくなった場合は `true` にすると skkeleton 版と同じ「▼状態で blink.cmp 全体を止める」動作に戻せる。
- **skkeleton 版との違い:** nvim-cmp を偽装する必要がない。
  - blink.cmp を nvim-cmp として認識させるシム（`skkeleton_cmp_shim.lua`）は不要。
  - skk.nvim は `capture.lua` の `passthrough_guard`（blink.cmp の `is_visible()` を見て自身の自動確定ロジックを止める仕組み）で外部UIとのキー競合に対処しており、`setup({ blink = {...} })` 内部で自動的に登録される。

#### **スニペット（`LuaSnipCustom.lua` / `luasnip_source.lua`）:**

- 補完メニューには `lua/my/cmp/luasnip_source.lua`（ネイティブソース）がトリガー文字列（`dw`・`today` 等）をプレーンテキストの候補として出す。
- **実際のスニペット展開・ノード間ジャンプは行わない**。
- 展開・ジャンプは `lua/my/cmp/blink.lua` の `<Tab>` キーマップが `luasnip.expand_or_jump()`（安定版の公開 API）を呼ぶことで行う。
  - 旧 nvim-cmp + `saadparwaiz1/cmp_luasnip` と同じ設計。
- 組み込みの `snippets = { preset = "luasnip" }` を使わない理由は既知のハマりどころ7番参照）。

登録されているオリジナルスニペット（`lua/my/cmp/LuaSnipCustom.lua`）:

| トリガー   | 出力例                       | 備考                                                                                        |
| ---------- | ---------------------------- | ------------------------------------------------------------------------------------------- |
| `today_jp` | `2026-08-27 木曜日`          | 今日の日付＋曜日（日本語）                                                                  |
| `today`    | `2026-08-27 Thu`             | 今日の日付＋曜日（英略）                                                                    |
| `now_jp`   | `2026-08-27 木曜日 14:30:00` | 現在日時＋曜日（日本語）                                                                    |
| `now`      | `2026-08-27 Thu 14:30:00`    | 現在日時＋曜日（英略）                                                                      |
| `dw`       | `2026-08-27 木曜日` 等       | 任意の日付を入力すると曜日を自動算出して付加。日本語/英略/英語を `<C-l>`/`<C-h>` で切り替え |

##### `dw` スニペットの操作手順:

- `dw` と入力 → `<Tab>` で展開 → `YYYY-MM-DD` 形式で日付を入力 → `<Tab>` で曜日ノードへジャンプ → `<C-l>`/`<C-h>` で `土曜日` → `Sat` → `Saturday` を切り替え → `<Tab>` で確定。
- 日付から曜日は `calc_weekday()`（`os.time`/`os.date` ベース）で自動算出しているため、存在しない日付（`2026-02-30` 等）を入力すると `(??)` と表示される。

#### **`[SNIP]` ソースの確定と展開の関係について:**

- `<C-n>`/`<C-p>` は補完候補一覧から選ぶための操作。
  - 入力途中の文字列が複数のスニペットに部分一致していて、どれを選ぶか確定させたい場合に使う。
- `<CR>` は選んだ候補の**トリガー文字列をプレーンテキストとして挿入するだけ**で、その時点ではまだ**展開されない**
  - `luasnip_source.lua` は `execute()` を持たないため、確定＝素のテキスト挿入で終わる。
- 実際にスニペットへ展開するのは別操作の `<Tab>` である。
  - バッファ上にトリガー文字列（例: `dw`）が存在する状態で `<Tab>` を押すと `luasnip.expand_or_jump()` が呼ばれ、そこで初めて展開される。
- そのため、`dw` のようにトリガー文字列を過不足なく正確にタイプできている場合は、候補一覧から明示的に選ばなくても、その場で `<Tab>` を押すだけで展開できる。
  - `<C-n>`/`<C-p>` → `<CR>` が必要になるのは、あくまで複数候補から選びたい場合のみ。

### 07-markdown.lua — Markdown・Typst・LaTeX

| プラグイン                       | 概要                                                    |
| -------------------------------- | ------------------------------------------------------- |
| iamcco/markdown-preview.nvim     | ブラウザプレビュー（ft: markdown）                      |
| godlygeek/tabular                | テキスト整列                                            |
| preservim/vim-markdown           | Markdown 機能拡張                                       |
| mzlogin/vim-markdown-toc         | 目次自動生成                                            |
| Kicamon/markdown-table-mode.nvim | テーブル自動整形                                        |
| bullets-vim/bullets.vim          | 箇条書き・チェックリスト管理                            |
| kaarmu/typst.vim                 | Typst サポート                                          |
| chomosuke/typst-preview.nvim     | Typst プレビュー（`TypstAutoWatch` augroup で自動起動） |
| lervag/vimtex                    | LaTeX サポート（PDF ビュワー: zathura）                 |
| jakewvincent/texmagic.nvim       | LaTeX ビルドエンジン管理                                |

### 08-migemo.lua — Migemo 検索

| プラグイン                      | 概要                              |
| ------------------------------- | --------------------------------- |
| lambdalisue/kensaku.vim         | Migemo ベースの日本語あいまい検索 |
| lambdalisue/kensaku-search.vim  | `/` 検索に Migemo を統合          |
| lambdalisue/vim-kensaku-command | `:Kensaku` コマンド               |
| yuki-yano/fuzzy-motion.vim      | Migemo × fuzzy のジャンプ移動     |

- `S` キーで FuzzyMotion を起動。

### 09-notify-skk.lua — 通知・日本語入力

| プラグイン           | 概要                                                                                     |
| -------------------- | ---------------------------------------------------------------------------------------- |
| folke/noice.nvim     | コマンドライン・通知 UI の強化                                                           |
| rcarriga/nvim-notify | 通知ポップアップ                                                                         |
| MunifTanjim/nui.nvim | UI コンポーネントライブラリ                                                              |
| nabehan/skk.nvim     | SKK 日本語入力（本体・詳細は[skk.nvim README](https://github.com/nabehan/skk.nvim)参照） |

- `setup()` は `lua/my/utils/skk.lua` で行う。
  - `init.lua` から blink.cmp の `setup()` 完了後に `require` される。
- blink.cmp ネイティブソース（`skk.blink_source`）も本体に同梱のため、skkeleton 版で必要だった `skkeleton_indicator.nvim` や `skkeleton_cmp_shim.lua` 相当の追加プラグイン・ブリッジコードは不要。

#### **SKK 設定（`lua/my/utils/skk.lua`）の要点:**

- `enter_key = "<C-\>"`。挿入モード・コマンドラインモードをカバー。
  - 元は既定の `<C-j>` を使っていたが、後述の `extra_candidate_next_key`/`extra_candidate_prev_key` に `<C-j>`/`<C-k>` を割り当てるため、`enter_key` 側を `<C-\>` に変更して空けている（現在試用中、下記「既知のハマりどころ」12番も参照）。
  - Normal モードから `<C-\>` で挿入モードに入りつつ有効化する合成キーマップも別途定義（`vim.cmd("startinsert")` + `skk.enable()`）。Telescope 側（`05-telescope.lua`）の `<C-j>`→`SkkEnable` 上書きも `<C-\>` に合わせて変更済み。
- `sticky_shift_enabled = true`（`;` キー）、`egg_like_newline = true`。
- `extra_candidate_next_key = "<C-j>"`/`extra_candidate_prev_key = "<C-k>"`（**現在試用中、既知のリスクあり**。下記「既知のハマりどころ」12番参照）。
  - Telescope 等、自身が `<C-n>`/`<C-p>` をバッファローカルな実キーマップで占有する外部UIのプロンプト内では、既定の `<C-n>`/`<C-p>` による候補フォーカス移動が機能しないため、それらの環境向けの追加キー（詳細は後述「既知のハマりどころ」11番、および [skk.nvim README](https://github.com/nabehan/skk.nvim#telescope-等外部uiとの-c-nc-p-競合と-extra_candidate_next_keyextra_candidate_prev_key実機で発見重要) 参照）。
  - 当初 `<C-Up>`/`<C-Down>` で実機確認していたが、ホームポジションに近い代替を求めて `<M-n>`/`<M-p>`（端末依存でESCと分割され誤動作）、`<C-.>`/`<C-,>`（Alacrittyでは動作・Konsoleでは不動作）を試し、いずれも見送った。現在は `enter_key` を空けた `<C-j>`/`<C-k>` を試用中だが、これらはVim/Neovim組み込みの意味（`<C-j>`=改行、`<C-k>`=ダイグラフ入力）を▼状態以外で素通ししてしまうリスクが判明している（12番参照）。安定志向であれば `<C-Right>`/`<C-Left>` 等、CSIシーケンス系のキーに戻すのが無難。
- 候補選択ウィンドウ（`candidate_window`）・見出し語/候補の配色をカスタマイズ済み。
- 個人辞書は skkeleton 版と同じパス（`~/.local/share/skk/SKK-JISYO.user`）を指定しており、学習内容も引き継がれる。
- SKKサーバー（yaskkserv2、`127.0.0.1:1178`、`euc-jp`）・ローカル辞書4種（jawiki/edict2/emoji/emoji-ja）を設定済み。
- 句読点は既定（`period="。"`, `comma="、"`）のまま。

### 10-lisp.lua — Common Lisp 開発環境

| プラグイン             | 概要                                                 |
| ---------------------- | ---------------------------------------------------- |
| Olical/conjure         | REPL 駆動開発（SBCL と通信し、式をリアルタイム評価） |
| gpanders/nvim-parinfer | 括弧の自動バランス補正                               |

---

## キーマップ一覧

### グローバル（keymap.lua）

| キー                      | モード | 動作                                                     |
| ------------------------- | ------ | -------------------------------------------------------- |
| `<Space>`                 | n/v    | `<leader>` キー                                          |
| `<Esc><Esc>`              | n      | 検索ハイライト消去                                       |
| `<leader>c`               | n      | cursorline/cursorcolumn トグル                           |
| `<leader>w`               | n      | 折り返しトグル                                           |
| `j` / `k`                 | n      | 折り返し行単位移動（`gj`/`gk`）                          |
| `w`/`b`/`e`/`ge`          | n      | vim-smartword 単語移動                                   |
| `p`/`P`/`gp`/`gP`         | n/x    | yanky.nvim 貼り付け                                      |
| `<C-p>`/`<C-n>`           | n      | yanky 履歴前後                                           |
| `<CR>`                    | c      | Migemo 検索（kensaku-search）                            |
| `<leader>tf`/`tv`/`th`    | n      | ToggleTerm フロート/縦分割/横分割                        |
| `<leader>z`               | n      | ウィンドウ全画面化                                       |
| `S`                       | n      | FuzzyMotion                                              |
| `jk`                      | i      | ノーマルモードに戻る（`<Esc>` の代替）                   |
| `<C-j>`                   | i/c    | SKK トグル（skk.nvim。ターミナルでは不安定なので不使用） |
| `<C-j>`                   | n      | 挿入モードに移行し、SKK かな入力を有効化                 |
| `<leader>r`               | n      | Ranger ファイル選択（toggleterm 経由）                   |
| `<leader>at`/`as`         | n      | TAB/スペース区切りで列揃え                               |
| `<leader>cl`              | n      | 空行整理                                                 |
| `n`/`N`/`*`/`#`/`g*`/`g#` | n      | 検索（hlslens でスクロールバーに反映）                   |

### Markdown（markdown/keymap.lua）— オリジナルコマンド

- `lua/my/markdown/list.lua`・`table.lua` で定義したオリジナルのユーザーコマンドに対するキーマップ。
- bullets.vim と連携しつつ、より柔軟な記号選択・変換をカバーする独自実装。

| キー         | モード | コマンド                   | 動作                                                                                                                                                          |
| ------------ | ------ | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<leader>mp` | n      | `:MarkdownPreview`         | ブラウザプレビューを開く                                                                                                                                      |
| `<leader>mg` | n      | `:GenTocGFM`               | 目次を生成                                                                                                                                                    |
| `<leader>mu` | n      | `:UpdateToc`               | 目次を更新                                                                                                                                                    |
| `<leader>mr` | n/v    | `<Plug>(bullets-renumber)` | 番号付きリストを振り直す                                                                                                                                      |
| `<leader>mt` | n      | `:MarkdownTableBlock`      | カーソル位置の、空行で挟まれたブロックを Markdown テーブルに変換。区切り文字（空白/タブ/カンマ/セミコロン/コロン/パイプ/アンパサンド/ハッシュ）を選択して実行 |
| `<leader>mb` | n      | `:BulletizeLine`           | カーソル行を選択した記号（`-`/`+`/`*`/カスタム1文字）の箇条書きに変換                                                                                         |
| `<leader>mB` | n      | `:BulletizeLineInstant`    | カーソル行を即座に `-` の箇条書きに変換（記号選択なし）                                                                                                       |
| `<leader>mb` | v      | `:BulletizeRange`          | 選択範囲の各行を選択した記号の箇条書きに変換                                                                                                                  |
| `<leader>mB` | v      | `:BulletizeRangeInstant`   | 選択範囲を即座に `-` の箇条書きに変換                                                                                                                         |
| `<leader>mn` | n      | `:NumberizeLine`           | カーソル行を番号付きリストに変換                                                                                                                              |
| `<leader>mn` | v      | `:NumberizeRange`          | 選択範囲の各行を番号付きリストに変換                                                                                                                          |
| `<leader>mc` | n      | `:CheckboxLine`            | カーソル行がチェックボックスなら bullets.vim でトグル、それ以外は `+ [ ] ` を付加してチェックリスト化                                                         |
| `<leader>mc` | v      | `:CheckboxRange`           | 選択範囲の各行をチェックリスト化（既にチェックボックスがある行はスキップ・維持）                                                                              |
| `<leader>m>` | n      | `:QuoteLine`               | カーソル行の Markdown 引用を1段増やす（`>` を先頭に付加、既にあれば `>>` に）                                                                                 |
| `<leader>m>` | v      | `:QuoteRange`              | 選択範囲の引用を1段増やす                                                                                                                                     |
| `<leader>m<` | n      | `:UnquoteLine`             | カーソル行の Markdown 引用を1段減らす（`>` が無くなれば解除）                                                                                                 |
| `<leader>m<` | v      | `:UnquoteRange`            | 選択範囲の引用を1段減らす                                                                                                                                     |

補足：

- `BulletizeLine`/`NumberizeLine`/`CheckboxLine`/`QuoteLine` 系はいずれも、既存の箇条書き記号・番号・チェックボックス・引用記号・インデントを一度取り除いてから変換するため、リスト種別の変換や引用の増段・減段を繰り返しても記号が二重に付くことはない。
- `MyTableFormat`（キーマップなし、`:MyTableFormat` で直接実行）はカーソル位置を含む空行で囲まれたブロックに対して `TableFormat`（tabular.vim）を実行したうえで、`|` で始まる行の行頭空白を削除する。
  - `MarkdownTableBlock` と異なり、既に `|` で区切られた Markdown テーブルの整形専用。

### Telescope（telescope/keymap.lua）

| キー              | モード | 動作                                         |
| ----------------- | ------ | -------------------------------------------- |
| `<leader>ff`      | n      | ファイル検索（高速）                         |
| `<leader>fF`      | n      | ファイル検索（全スキャン・隠しファイル含む） |
| `<leader>fg`      | n      | Live grep（プロジェクト）                    |
| `<leader>fG`      | n      | Live grep（全スキャン）                      |
| `<leader>fa`      | n      | Live grep with args                          |
| `<leader>fb`      | n/v    | バッファ内 grep                              |
| `<leader>fs`/`fS` | n      | カーソル下の単語で grep                      |
| `<leader>fr`      | n      | 最近開いたファイル                           |
| `<leader>fc`      | n      | 現在バッファ内 fuzzy 検索                    |
| `<leader>fw`      | n      | バッファ一覧                                 |
| `<leader>fh`      | n      | ヘルプタグ                                   |
| `<leader>fe`      | n      | シンボル（絵文字等）                         |
| `<leader>fn`      | n      | ファイルブラウザ                             |
| `<leader>fp`      | n      | yank 履歴                                    |
| `<leader>fu`      | n      | undo ツリー                                  |
| `<leader>ft`      | n      | タブ選択                                     |
| `<leader>f.`      | n      | 前回の Telescope を再開                      |

### LSP（autocommand.lua — LspAttach 時に設定）

| キー                         | 動作                                                                     |
| ---------------------------- | ------------------------------------------------------------------------ |
| `gd`/`gr`/`gi`/`gD`          | 定義/参照/実装/宣言へジャンプ                                            |
| `K`                          | ホバードキュメント                                                       |
| `<C-k>`                      | シグネチャヘルプ                                                         |
| `g[`/`g]`                    | 前/次の診断                                                              |
| `g/`                         | 診断一覧（Telescope）                                                    |
| `\D`/`\gs`/`\gS`/`\gi`/`\go` | 型定義/ドキュメントシンボル/ワークスペースシンボル/呼び出し元/呼び出し先 |
| `\rn`                        | リネーム                                                                 |
| `\ca`                        | コードアクション                                                         |
| `\F`                         | フォーマット                                                             |
| `\q`                         | 診断をロケーションリストへ                                               |
| `\wa`/`\wr`/`\wl`            | ワークスペースフォルダ 追加/削除/一覧                                    |

### blink.cmp（`lua/my/cmp/blink.lua` / `lua/my/cmp/keymap.lua`）

| キー              | 動作                                                                            |
| ----------------- | ------------------------------------------------------------------------------- |
| `<C-n>` / `<C-p>` | 次/前候補を選択（skk.nvim の▼変換候補選択中はそちらのフォーカス移動を優先）     |
| `<CR>`            | 補完確定（`accept`、未選択時は skk.nvim の確定処理→通常の改行にフォールバック） |
| `<Tab>`           | LuaSnip 展開・ジャンプ（対象がなければ通常の Tab）                              |
| `<S-Tab>`         | LuaSnip 逆ジャンプ                                                              |
| `<C-l>` / `<C-h>` | choice_node 次/前の選択肢に切り替え（スニペット内のみ。`dw` 等）                |
| `<C-Space>`       | 補完を明示的に呼び出す                                                          |
| `<C-e>`           | 補完を閉じる                                                                    |
| `<C-f>` / `<C-b>` | ドキュメントをスクロール                                                        |
| `<C-q>`           | blink.cmp 自体の有効/無効をトグル（n/i）                                        |

- コマンドラインモード（`:` `/` `?`）でも blink.cmp の補完が有効。
- `<CR>` は挿入のみ（`accept`）を割り当てており、実行するにはもう一度 `<CR>` を押す
  - 詳細は既知のハマりどころ5番参照。

---

## 既知のハマりどころ（トラブルシューティング）

過去に実際に発生した不具合とその原因・対処をまとめる。同種の問題が再発した際の切り分けに使うこと。

1. **`<CR>` で候補を確定しても本文に反映されない（挿入モード）**

- `nvim-autopairs` の `map_cr` が `true` になっており、挿入モードの `<CR>` を横取りしていないか確認する。
  - `01-base.lua` で `map_cr = false` を指定済みか）。
- それでも直らない場合は `<CR>` を `{ "accept", function(cmp) return cmp.accept({ force = true }) end, "fallback" }` にして、blink 自身の範囲検証を強制的にバイパスしてみる。

3. **calc / emoji / latex_symbols / spell / rg などの候補が一切出ない**

- `sources.providers.<id>.name` を表示用のラベル（`"[CALC]"` など）に書き換えていないか確認する。
- `blink.compat` はこの `name` を nvim-cmp 側の登録名として実体解決に使うため、変更すると候補ゼロになる。
- 表示上のラベルは `completion.menu.draw.components.source_name.text` 側で付与する。
  - `skk` はネイティブソースなのでこの制約は無関係。

4. **compat 経由のソースがエラーで動かない**

- `blink.compat` の `opts.impersonate_nvim_cmp = true` を確認する。
- nvim-cmp 本体をアンインストールしているため、各ソース内部の `require("cmp")` 参照をシムする必要がある。

5. **コマンドライン補完で候補を選んで `<CR>` しても、選んでいない生の文字列で実行されてしまう**

- 例: `:laz` と入力 → `C-n` で `Lazy` を選択 → `<CR>` → `E492: Not an editor command: laz`
- `cmdline.keymap` に `<CR>` が明示的に定義されているか確認する
  - 既定プリセットの `<CR>` は `accept` 系にバインドされておらず、素の `<CR>` に落ちる。
- 挿入と実行を両方行いたい場合は `accept_and_enter` を割り当てる。
  - 現在の設定は「挿入のみ」の `accept` を採用しており、実行にはもう一度 `<CR>` が必要。理由は `blink.lua` のコメント参照。

6. **コマンドライン/検索で、何も選んでいないのに先頭候補が勝手にコマンドラインへ反映されてしまう**

- 例: `:w` と打っただけで `:wq` になってしまう。
- `cmdline.completion.list.selection` の `preselect`/`auto_insert` が `true` になっていないか確認する。
- 両方 `false` にし、`<C-n>`/`<C-p>` で明示的に選んだときだけ反映されるようにする。

7. **`dw` スニペットで日付を入力後、`<Tab>` で曜日ノードへジャンプしようとすると反応しない、または `E5108: Lua: .../luasnip/init.lua:625: E565: Not allowed to change text or change window` エラーが出る**

- `<Tab>`/`<C-l>`/`<C-h>` のカスタム関数が成功時に `return true` しているか確認する。
  - blink.cmp のキーマップは関数が `nil`/`false` を返すと次のアクション＝`fallback` へ進む仕様。
- 組み込みの `snippets = { preset = "luasnip" }` は使わないこと。
  - 未マージの LuaSnip PR に依存した実験的実装で、確定直後に LuaSnip 内部のセッション追跡が壊れる不具合が確認されている。
- `luasnip_source.lua` + `<Tab>` キーマップでの `expand_or_jump()` に一本化してある。
- `<Tab>`/`<S-Tab>`/`<C-l>`/`<C-h>` の実際の `nvim_buf_set_text` 呼び出しは `vim.schedule` で1ティック遅延させてあるか確認する
  - blink.cmp のキーマップ実行コンテキスト内で直接呼ぶと E565 になる。

8. **skk.nvim のひらがな/カタカナ・全角英数モードで、nvim-autopairs 併用時に文字化けやカーソル位置のずれが起きる**

- skk.nvim を v0.1.1 以降に更新する。
  - `git -C ~/.local/share/nvim-blink-skknvim/lazy/skk.nvim pull` 等。
- v0.1.0 系にはこの相性問題が存在した。詳細な原因・修正内容は [skk.nvim README](https://github.com/nabehan/skk.nvim#nvim-autopairs-との相性問題実機で発見重要) の「nvim-autopairs との相性問題」参照。

9. **原因不明の挙動変化があった場合**

- `06-lsp.lua` の `saghen/blink.cmp` が `version = "1.*"` に固定されているか確認する。
- バージョン指定を `"*"` にすると、開発中の v2（設定スキーマに破壊的変更あり）を意図せず取得する可能性がある。
- skk.nvim 側の不具合が疑われる場合は `:checkhealth skk` でセットアップ状態を確認し、[skk.nvim リポジトリ](https://github.com/nabehan/skk.nvim)の CHANGELOG・既知の制限も合わせて確認する。

10. **abbrev モード（`/` から始める見出し入力）で `"` `'` `` ` `` `(` `[` `{` を打鍵すると、プレエディットが解除され閉じ記号ごと即座に確定してしまう**

- 例: `<C-j>/(` のように `/` の直後に `(` を打つと、`▽(` のままのはずが `()` として即座に確定してしまう。
- 原因は nvim-autopairs 等が生成する合成キー列（`<C-g>u()<C-g>U<Left><C-g>u`）が、blink.cmp のライブ補完がまだ一度も表示されていない間に skk.nvim 側の「外部UIが見えていなければ見出しを確定する」フォールバックを誤発火させてしまうこと（詳細調査は [skk.nvim README](https://github.com/nabehan/skk.nvim#abbrev-モードでのオートペア相性問題と推奨される回避策実機で発見重要) 参照）。
- `capture.lua` 側の合成キー列を解釈するパッチも試したが、ヘッドレス環境では解消したにもかかわらず実機では解消せず、原因未特定のまま revert した。
- 最終的に `lua/my/cmp/blink.lua` の `SkkHenkanChanged` ハンドラで、henkan（▽/▼/abbrev）アクティブ中は `require("nvim-autopairs").disable()`、`idle` に戻ったら `enable()` を呼ぶ方式で解決した（skk.nvim 本体は無変更）。この設定は現在の `blink.lua` に反映済みなので、通常の利用では追加の対応は不要。
- 副次的に、見出しに開き文字だけでなく自動挿入された閉じ文字まで混入してしまう問題（`(` を打っても見出しが `"("` ではなく `"()"` になる）も同時に解消している。

11. **Telescope のプロンプト内で、henkan の候補一覧（▼）表示中に `<C-n>`/`<C-p>` を押すと、候補移動ではなく即座に確定してしまい Telescope 本来の結果一覧移動が始まる**

- Telescope はプロンプトバッファ（`buftype="prompt"`）に `<C-n>`/`<C-p>` をバッファローカルな実キーマップ（結果一覧の選択移動）として持っており、Neovim の仕様上バッファローカルは常にグローバルより優先される。skk.nvim 本体の `<C-n>`/`<C-p>`（`candidate_navigation`）はグローバルなキーマップのため、Telescope のプロンプト内では事実上機能しない。
- Telescope 側（この設定リポジトリ）のバッファローカルな上書き＋委譲だけでは解決しない。skk.nvim の ▼状態キー処理は CTRL_N/CTRL_P/space/x/ホームポジション選択以外のキーを無条件で自動確定するフォールバックを持ち、`vim.on_key()` が実キーマップの解決より先に発火するため、Telescope 側の上書きが実行される前に確定が起きてしまう（詳細な経緯・原因は [skk.nvim README](https://github.com/nabehan/skk.nvim#telescope-等外部uiとの-c-nc-p-競合と-extra_candidate_next_keyextra_candidate_prev_key実機で発見重要) 参照）。
- 対処として、`<C-n>`/`<C-p>` 自体には手を加えず、skk.nvim 本体に追加した `extra_candidate_next_key`/`extra_candidate_prev_key` オプション（`vim.on_key()` 自身が CTRL_N/CTRL_P と同格の追加キーとして認識する）を使い、`lua/my/utils/skk.lua` で追加キーを割り当てて解決した（実機確認済み）。skk.nvim は v0.1.1 以降（このオプションを含むバージョン）に更新すること。具体的にどのキーを割り当てるかは、下記12番参照。
- `lua/my/telescope/config.lua` 側の `<C-n>`/`<C-p>` 上書きは不要になったため削除済み。同ファイルに残っているのは `enter_key`（現在 `<C-\>`、→`:SkkEnable`）の上書きのみ。

12. **`extra_candidate_next_key`/`extra_candidate_prev_key` にどのキーを指定するかで、複数の落とし穴を踏んだ（実機で発見・重要）**

- **Alt修飾キー（`<M-n>`/`<A-n>` 等）**: ホームポジションに近く一見良さそうだが、実機では機能しなかった。例: 「人」を選択中に `<M-n>` を押すと、候補移動ではなく「人」がそのまま確定し、直後に `n` が新しいローマ字入力として処理され「人n」のような結果になった。多くの端末はAlt+文字を「ESCを送ってから元の文字を送る」という2バイト方式（ESCプレフィックス）で表現しており、タイミングや端末の実装によっては ESC と文字が別々のキー入力として skk.nvim 側に届いてしまうことがある。ESC 単体は ▼状態の「未対応キーは無条件で確定」フォールバックに落ちて即座に確定し、続く文字は確定後の新しい入力として処理されてしまう。
- **Ctrl+記号（`<C-.>`/`<C-,>` 等）**: 端末によって結果が割れた（Alacrittyでは動作、Konsoleでは動作せず）。Ctrl+印字可能文字の符号化はKittyキーボードプロトコル対応の有無等、端末依存の部分が大きい。
- **Vim/Neovim組み込みの意味を持つキー（`<C-j>`/`<C-k>` 等）**: `enter_key` を既定の `<C-j>` から他のキー（`<C-\>` 等）に変更し、空いた `<C-j>` を `extra_candidate_next_key` に、`<C-k>` を `extra_candidate_prev_key` に転用する構成を試用中だが、これには別種のリスクがあると判明した。`extra_candidate_next_key`/`extra_candidate_prev_key` は `vim.on_key()` 経由の処理であり、henkan の ▼状態（候補選択中）でしか認識されない。それ以外の場面（henkan非アクティブ、または ▽状態）で `<C-j>`/`<C-k>` を押すと、Neovim組み込みの既定動作へそのまま素通りしてしまう——`<C-j>` は挿入モードで `<CR>`（改行）と等価に扱われる組み込み動作、`<C-k>` はダイグラフ入力（例: `<C-k>a:` → `ä`）を起動する組み込みキーである（いずれもヘッドレス環境で実際の動作を確認済み）。以前 `enter_key = "<C-j>"` だった頃はこの組み込み動作を実キーマップが常時覆い隠していたため問題化しなかったが、今の構成では `<C-j>`/`<C-k>` はどの実キーマップにも占有されておらず、候補選択中でない時にうっかり押すと、無警告の改行挿入や、次のキー入力がダイグラフ待ちに吸われてしまう不具合につながりうる。
- **結論**: `<C-Up>`/`<C-Down>`/`<C-Left>`/`<C-Right>` のような矢印キー＋Ctrlは、CSIエスケープシーケンスという「1つの決まった塊」で送られるため符号化面での分割が起きず、かつVim/Neovim組み込みの意味も持たないため、`extra_candidate_next_key`/`extra_candidate_prev_key` にはこの系統のキーを指定するのが最も安全（実機確認済み）。ホームポジションに近いキーを試す場合は、①符号化が1つの塊で届くか（Alt修飾・Ctrl+記号は避ける）、②Neovim組み込みの意味を持たないか、の両方を確認すること。
