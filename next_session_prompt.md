# Claude Code で skk.nvim の開発再開

skk.nvim の開発の続きです。不具合報告・改善要望として、別チャットから引き継ぎます。

## 対象リポジトリ

- skk.nvim 本体: https://github.com/nabehan/skk.nvim.git
- 実機設定（nvim-skk で起動）: https://github.com/nabehan/nvim-config-blink-skknvim.git
- 検証用サンドボックス（nvim-snd で起動）: https://github.com/nabehan/nvim-skk-sandbox.git

まず対象リポジトリを clone/pull し、現状（最新タグ・最新コミット）を確認するところから始めてください。

## 現在のバージョン・状態

- 最新版: v0.1.1（2026-08-26 リリース、GitHub Releases 公開済み）。次バージョンへのタグ付けはまだ行っていない
- v0.1.1 で、nvim-autopairs との相性問題（挿入位置の割り込み・カーソル位置のずれ・`z(` の全角/半角不揃い）を根本解決済み
- v0.1.1 リリース後に新規発見・解決した課題：abbrev モード（`/` から始める見出し入力）で見出しが空・候補0件のまま `"` `'` `` ` `` `(` `[` `{` を打鍵すると、プレエディットが即座に確定してしまう不具合
  - 原因はオートペア系プラグインが生成する合成キー列（`<C-g>u()<C-g>U<Left><C-g>u` 等、Vim標準のアンドゥ境界制御イディオム）が、blink.cmp のライブ補完がまだ表示されていない間に skk.nvim 側の自動確定フォールバックを誤発火させること
  - `capture.lua` 側で合成キー列を解釈するパッチ（`pending_autopair_cursor_move`）も試したが、ヘッドレス環境（実機と同一の Neovim v0.12.4 バイナリでの `--headless --listen` + `--remote-send` によるRPC再現）では解消したにもかかわらず、実機では原因不明のまま解消しなかったため revert 済み。skk.nvim 本体はこの問題について無変更
  - 最終的に、henkan（▽/▼/abbrev）アクティブ中はオートペア側のプラグイン自体を `SkkHenkanChanged` autocmd 経由で enable/disable する方式（`nvim-config-blink-skknvim` の `lua/my/cmp/blink.lua` 側のみの変更）で解決し、実機push・確認済み
  - nvim-autopairs・mini.pairs は実機で期待通りの動作を確認済み。ultimate-autopair.nvim は別の（この問題とは無関係な）文字列処理の不具合があり、実際に使用しないため対応を見送り。autoclose.nvim は `toggle()` しか公開されておらず未対応（`blink.lua` 内にコメントで理由を記載済み）
  - skk.nvim 側 README.md/CHANGELOG.md/doc/skk.nvim.txt、nvim-config-blink-skknvim 側 README.md ともに更新・push 済み
- それ以前に解決済みの主な課題（README.md 参照、蒸し返し不要）：`<CR>` 確定時の改行二重挿入、`<DEL>`/`<F11>` での誤った▽開始、全角英数モードでの `<CR>` 後の他プラグイン由来文字列混入、句読点のカスタマイズオプション化
- 現在、上記のオートペア対応を含む現状の設定を実機で継続使用しながら、使用感・不具合を観察している段階

## 開発の進め方の前提（これまでの運用）

- 実機（Manjaro Linux、Neovim v0.12.4）での動作確認・push は私（ユーザー）が行う。そちらは clone/pull して同期し、push は行わない。
- 実際のソースを確認してから変更を提案してほしい。存在しない API・オプションを作り出さないこと。
- 新規作成・変更したファイルは、Artifacts ウィンドウに表示されるリンクとして提示してほしい（チャット内への生コード貼り付けや、ダウンロードリンクではない）。file 作成時は、実ファイルをそのままコピーして diff で完全一致を確認してから提示すること（手打ちでの再構成は絶対にしないこと。過去に手打ち再構成で実際の内容と異なる誤った成果物を提示してしまった事故があった）。
- luacheck と `test.sh`（全テストファイルの Failed/Errors 0）の実行・確認をしてから提示する。
- 新規APIを作らず、既存のソース構造・命名規約に沿って実装すること。
- タイミング依存（`vim.schedule()` の遅延実行、他プラグインが生成する合成キー列など）の不具合を疑う場合は、`nvim_feedkeys(keys, "x", false)` では正しく再現できないことが分かっている（typeahead 処理全体が終わるまで `vim.schedule()` が一切実行されないため）。代わりに `nvim --headless --listen <socket>` でサーバーを起動し、別プロセスから `nvim --server <socket> --remote-send '<keys>'` で実際のキーストロークを送り込む方式（実機と同一の Neovim v0.12.4 バイナリを使用）で再現・検証すること。1回の `--remote-send` に複数キーをまとめて渡すと「同一ティック内で複数キーが連続して来る」状況を、複数回に分けて `sleep` を挟みながら送ると「現実的な間隔でのタイピング」をそれぞれ再現できる。
- 複雑な合成キー列の挙動は、上記のヘッドレス再現で挙動を特定してから修正すること。
- **重要（今回のセッションで学んだ教訓）**：ヘッドレス環境での再現・修正確認は必要条件だが十分条件ではない。ヘッドレスで解消を確認できても実機では解消しない、という食い違いが実際に起きた（原因は最終的に特定できず）。ヘッドレスでの検証結果を「実機でも通用する」と断定せず、可能な限り実機での確認を挟むこと。
- バッチ化・アーキテクチャ変更のような大きめの設計変更に着手する場合は、着手前に一声かけてほしい。skk.nvim 本体に手を入れるのではなく、実機設定リポジトリ側の統合コード（`SkkHenkanChanged` 等の既存の公開イベント/APIを使う）で解決できないかを先に検討する視点も持つこと（今回のオートペア対応がその好例）。
- 修正が固まったら、README.md / CHANGELOG.md / doc/skk.nvim.txt の更新も忘れずに（今回のセッションで整備した記述スタイル・既知の制限セクションを踏襲）。

まずは対象リポジトリの現状把握から始めてください。具体的な不具合報告・改善要望があれば、この後のメッセージで追記します。

# 2026-08-30 日曜日 23:01:22 Caude Code が生成した

# skk.nvim の開発の続き

- 不具合報告・改善要望として、別チャットから引き継ぎます。

## 対象リポジトリ

- skk.nvim 本体: https://github.com/nabehan/skk.nvim.git
- 実機設定（nvim-skk で起動）: https://github.com/nabehan/nvim-config-blink-skknvim.git
- 検証用サンドボックス（nvim-snd で起動）: https://github.com/nabehan/nvim-skk-sandbox.git

まず対象リポジトリを clone/pull し、現状（最新タグ・最新コミット）を確認するところから始めてください。

## 現在のバージョン・状態

- 最新版: v0.1.1（2026-08-26 リリース、GitHub Releases 公開済み）
- v0.1.1 で、nvim-autopairs（開き文字に対応する閉じ文字を自動挿入するプラグイン）との相性問題を根本解決済み（挿入位置の割り込み・カーソル位置のずれ・`z(` の全角/半角不揃い）。詳細は README.md の「nvim-autopairs との相性問題」セクション、CHANGELOG.md の `[v0.1.1]` 参照。
- それ以前に解決済みの主な課題（README.md 参照、蒸し返し不要）：`<CR>` 確定時の改行二重挿入、`<DEL>`/`<F11>` での誤った▽開始、全角英数モードでの `<CR>` 後の他プラグイン由来文字列混入、句読点のカスタマイズオプション化。

## 今回の不具合・改善要望

（ここに具体的な症状を記入してください。以下の情報があると調査がスムーズです）

- 症状：（何をしたら、何が起きたか。可能であれば実機の `vim.on_key()` ログや `:messages`、再現手順）
- 入力モード：ひらがな / カタカナ / 全角英数 / 半角英数 / コマンドライン のどれで発生するか
- 関連しそうな他プラグイン（オートペア・補完・スニペット等）の有無
- 発生する設定（nvim-skk / nvim-snd のどちらで確認したか）

## 開発の進め方の前提（これまでの運用）

- 実機（Manjaro Linux、Neovim v0.12.4）での動作確認・push は私（ユーザー）が行う。そちらは clone/pull して同期し、push は行わない。
- 実際のソースを確認してから変更を提案してほしい。存在しない API・オプションを作り出さないこと。
- 変更点は差分ベースで見せてほしい。
- 新規作成・変更したファイルは、Artifacts ウィンドウに表示されるリンクとして提示してほしい（チャット内への生コード貼り付けや、ダウンロードリンクではない）。
- luacheck と `test.sh`（全テストファイルの Failed/Errors 0）の実行・確認をしてから提示する。
- 新規APIを作らず、既存のソース構造・命名規約に沿って実装すること。
- タイミング依存（`vim.schedule()` の遅延実行、他プラグインが生成する合成キー列など）の不具合を疑う場合は、`nvim_feedkeys(keys, "x", false)` では正しく再現できないことが分かっている（typeahead 処理全体が終わるまで `vim.schedule()` が一切実行されないため）。代わりに `nvim --headless --listen <socket>` でサーバーを起動し、別プロセスから `nvim --server <socket> --remote-send '<keys>'` で実際のキーストロークを送り込む方式（実機と同一の Neovim v0.12.4 バイナリを使用）で再現・検証すること。1回の `--remote-send` に複数キーをまとめて渡すと「同一ティック内で複数キーが連続して来る」状況を、複数回に分けて `sleep` を挟みながら送ると「現実的な間隔でのタイピング」をそれぞれ再現できる。
- 複雑な合成キー列の挙動は、上記のヘッドレス再現で挙動を特定してから修正すること。
- バッチ化・アーキテクチャ変更のような大きめの設計変更に着手する場合は、着手前に一声かけてほしい。
- 修正が固まったら、README.md / CHANGELOG.md / doc/skk.nvim.txt の更新も忘れずに（今回のセッションで nvim-autopairs 対応時に整備した記述スタイル・既知の制限セクションを踏襲）。

まずは対象リポジトリの現状把握と、上記の不具合・改善要望の原因調査から始めてください。

end

# skk.nvim 開発の続き

# 2026-09-04 金曜日 06:00:13

別チャットから引き継ぎます。今回は（未定・下記「今回やってほしいこと」に記入）という位置づけの作業です。

## 対象リポジトリ

- skk.nvim 本体: https://github.com/nabehan/skk.nvim.git
- 実機設定（skk.nvim移行検証用）: https://github.com/nabehan/nvim-config-blink-skknvim.git
- 検証用サンドボックス（nvim-snd で起動）: https://github.com/nabehan/nvim-skk-sandbox.git
- 参考・変更しない: nvim-config-blink-skkeleton（skkeleton現用設定）、blink.cmp、skkeleton

まず対象リポジトリを clone/pull し、現状を確認するところから始めてください。

## これまでの開発状況（要約）

skk.nvim は denops非依存・Lua実装のNeovim専用SKK日本語入力プラグインとして v0.1.0 を公開済み。ローマ字→かな/カタカナ変換、4モード切替、辞書変換（▽/▼、送りあり/なし/abbrev）、候補選択ウィンドウ、単語登録UI、Sticky-shift、個人辞書、複数辞書マージ、SKKサーバー連携（yaskkserv2）、コマンドラインモード対応、blink.cmpネイティブソース統合、:checkhealth skk を実装済み。

これまでに発見・解決した実機限定の主な不具合（詳細はskk.nvim README.mdの「実機で発見・重要」節、CHANGELOG.md参照）：

- `<CR>`確定時の改行二重挿入（blink.cmp連携、`confirm_henkan_if_active()`/`passthrough_guard`で解決）
- `<Del>`/`<F11>`キーで誤って▽開始（内部キーコードの大文字誤認、`#key==1`ガードで解決）
- 全角英数モードで他プラグイン由来の文字列が混入（`<C-r>=`式レジスタイディオムの誤解釈、CTRL_R検知で解決）
- ひらがな/カタカナ・全角英数モードでのnvim-autopairsとの相性問題（合成キー列`<C-g>u...<C-g>U<Left><C-g>u`の誤解釈による文字化け・促音消失・挿入位置ズレ。extmarkアンカー化＋バッチ書き込み機構`hira_kata_batch`/`zenei_batch`で根本解決）
- abbrevモードでのオートペア相性問題（skk.nvim本体ではなく、実機設定側`lua/my/cmp/blink.lua`の`SkkHenkanChanged`ハンドラでhenkanアクティブ中はnvim-autopairs等を`disable()`する方式で解決。nvim-autopairs・mini.pairs・ultimate-autopair.nvimに対応済み）
- Telescope（プロンプト、`buftype="prompt"`）との相性問題：
  - `<C-j>`（enter_key）：Telescope本体が既定で`<C-j>`をバッファローカルに無害化(`actions.nop`)しており、skk.nvim本体のグローバルキーマップに優先するため発火しない。→ 実機設定側`lua/my/telescope/config.lua`の`FileType TelescopePrompt`オートコマンドでバッファローカルに`<C-j>`→`:SkkEnable`を上書きして解決
  - `<C-n>`/`<C-p>`（候補フォーカス移動）：同型の問題だが、統合層（実機設定側）だけの上書きでは解決不可能と判明（`vim.on_key()`が実キーマップより先に発火し、▼状態の無条件自動確定フォールバックに落ちてしまうため）。→ skk.nvim本体に`extra_candidate_next_key`/`extra_candidate_prev_key`オプションを新設し、`vim.on_key()`自身がCTRL_N/CTRL_Pと同格の追加キーとして認識する方式で解決
- `extra_candidate_next_key`/`extra_candidate_prev_key`（および`enter_key`等、キー設定全般）に指定するキーの選定で複数の落とし穴を発見・記録済み（README.md「キーの選び方」節）：Alt修飾キー（端末依存のESCプレフィックス方式で分割されうる）、Ctrl+記号（端末によって符号化対応が割れる）、Vim/Neovim組み込みの意味を持つASCII制御コード（`<C-j>`=改行、`<C-k>`=ダイグラフ入力等、▼状態以外で組み込み動作へ素通りする）はいずれも避けるべきで、CSIシーケンス系のキー（`<C-Up>`/`<C-Down>`/`<C-Left>`/`<C-Right>`等）が最も安定。OS・デスクトップ環境・入力メソッドフレームワーク（KDE Plasma、fcitx5等）側のグローバルショートカットとの衝突もありうる

現在の実機設定（`nvim-config-blink-skknvim`の`lua/my/utils/skk.lua`）は最終的に、`enter_key = "<C-j>"`（既定のまま）、`extra_candidate_next_key = "<C-Left>"`、`extra_candidate_prev_key = "<C-Right>"`に落ち着いている。`<C-n>`/`<C-p>`自体はユーザーの手癖のため変更していない。

現時点で既知の未解決課題は無し。しばらく実運用して不具合が無いか様子見している段階。

## 開発の進め方の前提（これまでの運用）

- 実機（Manjaro Linux/KDE Plasma、Neovim v0.12.4）での動作確認・push は私（ユーザー）が行う。そちらは clone/pull して同期し、push は行わない。
- 実際のソースを確認してから変更を提案してほしい。存在しない API・オプションを作り出さないこと。
- 新規作成・変更したファイルは、Artifacts ウィンドウに表示されるリンクとして提示してほしい（チャット内への生コード貼り付けや、ダウンロードリンクではない）。file 作成時は、実ファイルをそのままコピーして diff で完全一致を確認してから提示すること（手打ちでの再構成は絶対にしないこと）。
- luacheck と `test.sh`（全テストファイルの Failed/Errors 0）の実行・確認をしてから提示する（skk.nvim本体に変更を加える場合）。新規追加した関数がconfirm_henkan_if_active()のような既存の同型関数と比べて専用テストの前例が無い場合、無理に新設せず前例に合わせてよい。
- タイミング依存の不具合を疑う場合は、`nvim --headless --listen <socket>` + `nvim --server <socket> --remote-send '<keys>'` の方式（実機と同一の Neovim v0.12.4 バイナリを使用。GitHub Releasesから取得可能）で再現・検証すること。
- **重要（実機で繰り返し学んだ教訓）**：ヘッドレス環境での検証結果を「実機でも通用する」と断定しないこと。特に、Ctrl/Alt修飾キーの`--remote-send`は、実端末とは異なる内部バイト列を生成することがあり、当方が一切変更していない既存機能でも同じ症状を再現して初めて「ヘッドレスの限界」と判明したケースがあった。修飾キーが絡む検証は実機での最終確認を必須とすること。逆に、ヘッドレスで問題が起きても、それが本当にコードの不具合か`--remote-send`固有の符号化アーティファクトかを、当該機能が未変更の既存コードでも同じ症状が出るか比較して切り分けること。
- バッチ化・アーキテクチャ変更のような大きめの設計変更に着手する場合は、着手前に一声かけてほしい。skk.nvim 本体に手を入れるのではなく、既存の公開イベント/API（`SkkHenkanChanged`等）や統合先（実機設定リポジトリ）側の設定で解決できないかを先に検討する視点を持つこと。ただし、統合層だけでは原理的に解決不可能なケース（`vim.on_key()`と実キーマップの発火順序に起因する問題等）もこれまでに複数あったため、統合層での対処を試して効果がなければ、その原因を明確にした上でskk.nvim本体側の対応を検討してよい。
- キーバインドを新規に選ぶ提案をする際は、README.mdの「キーの選び方」節にまとめた既知の落とし穴（Alt修飾キー、Ctrl+記号、Vim/Neovim組み込みキー）を踏まえること。

## 今回やってほしいこと

（ここに今回の作業内容を記入してください）

end
