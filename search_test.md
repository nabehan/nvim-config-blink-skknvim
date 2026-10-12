このファイルは Neovim の検索操作（`/`, `?`）、カーソル移動（`f`, `t`, `*`, `#`）、正規表現パターンマッチング、および文字列置換（`:%s`）の挙動をテストするために作成されたサンプルテキストです。日本語、英語、各種プログラミング言語のコードブロックが含まれています。

---

## 1. 日本語テキストの検索と移動テスト (Japanese Text Search Test)

日本語の文章内での検索操作をテストします。マルチバイト文字（全角文字）に対する `/` 検索や、ひらがな・カタカナ・漢字の混在パターンを確認してください。

### 1.1 形態素とキーワード検索

Neovim で日本語を検索する場合、検索文字列の正確な一致が求められます。
例えば「検索」という単語は、この段落内に何度も登場します。検索機能（Search function）を利用して「検索」をハイライト表示し、`n` キーで次へ、`N` キーで前へ移動できるかテストしてください。

- **重要キーワード:** データベース, ネットワーク, 非同期処理, アルゴリズム, 暗号化
- **類似キーワード:** データの検索, ネットの接続, 同期処理の実行, アルゴリズムの評価, 暗号化の復号

また、「バッファ」「ウィンドウ」「タブ」「レジスタ」「マッピング」といった Vim/Neovim 用語のカタカナ表記についても、全角カタカナの検索が正しく機能するか確認します。バッファを切り替える操作や、レジスタに文字列をヤンク（コピー）する操作は頻繁に行われます。

### 1.2 長文エッセイ（マルチバイト文字の連続）

ソフトウェア開発において、エディタの選択は生産性に直列に影響を与えます。特に Neovim は Vim の伝統を継承しつつ、Lua による柔軟な拡張性、組み込みの LSP (Language Server Protocol) クライアント、Tree-sitter による高度な構文ハイライト機能などを備えており、現代のエディタとして非常に強力です。

検索操作は単に文字を探すだけでなく、コードの構造を把握し、リファクタリングを行うための第一歩となります。前方検索 `/` と後方検索 `?` を使い分けることで、長大なログファイルやドキュメント内を瞬時に移動できます。

---

## 2. 英語テキストと英数字・記号の検索テスト (English & Symbol Search Test)

英語テキストでは、大文字・小文字の区別（`ignorecase`, `smartcase` 設定）や、単語単位の移動（`w`, `b`, `e`）、記号を含む正規表現のテストを行います。

### 2.1 Sample Technical Overview

Neovim is a refactor, and sometimes redone, fork of Vim. It is designed to be easily extensible, embeddable, and maintainable. It includes an embedded Lua interpreter, a built-in terminal emulator, and asynchronous plugin architecture.

- **Case Sensitivity Test:**
  - apple, Apple, APPLE, ApPlE
  - buffer, Buffer, BUFFER, buff3r
  - search, Search, SEARCH, re-search, pre-search

- **Symbol & Pattern Test:**
  - Email addresses: `user@example.com`, `admin.test-123@sub.domain.org`
  - IP addresses: `192.168.1.1`, `10.0.0.255`, `127.0.0.1`
  - URLs: `https://neovim.io`, `http://localhost:8080/api/v1/users?id=42&sort=desc`
  - File paths: `/usr/local/bin/nvim`, `C:\Users\Username\AppData\Local\nvim\init.lua`

Try searching for word boundaries using `\<word\>` pattern in Vim search. For example, searching for `\<in\>` should match "in" but not "inside" or "plugin".

---

## 3. プログラミング言語コードブロック (Code Blocks Test)

コード内でのシンボル検索、変数名の置換、記号（ブラケット、演算子）の検索テスト用です。

### 3.1 Python (アルゴリズムと非同期処理)

```python
import asyncio
import re
from typing import List, Dict, Optional

class SearchProcessor:
    def __init__(self, target_pattern: str):
        self.pattern = re.compile(target_pattern, re.IGNORECASE)
        self.results: List[Dict[str, str]] = []

    async def process_text(self, text_line: str, line_num: int) -> Optional[Dict[str, str]]:
        """Search target pattern within a given line of text."""
        await asyncio.sleep(0.001)  # Simulate async I/O
        match = self.pattern.search(text_line)
        if match:
            result = {
                "line": str(line_num),
                "matched": match.group(0),
                "context": text_line.strip()
            }
            self.results.append(result)
            return result
        return None

async def main():
    processor = SearchProcessor(r"neovim|vim")
    sample_lines = [
        "Neovim provides asynchronous plugin infrastructure.",
        "Vim has a long history starting from Vi.",
        "Emacs is another popular text editor.",
        "Lua scripts make Neovim extremely fast."
    ]

    tasks = [processor.process_text(line, i + 1) for i, line in enumerate(sample_lines)]
    await asyncio.gather(*tasks)

    for item in processor.results:
        print(f"Line {item['line']}: Found '{item['matched']}' in context: {item['context']}")

if __name__ == "__main__":
    asyncio.run(main())
```

### 3.2 TypeScript / JavaScript (フロントエンド・LSP 関連)

```typescript
interface SearchConfig {
  caseSensitive: boolean;
  useRegex: boolean;
  maxResults?: number;
}

type SearchResult<T> = {
  item: T;
  score: number;
  matches: Array<{ indices: [number, number]; key: string }>;
};

class FuzzySearchEngine<T extends Record<string, any>> {
  private items: T[];
  private config: SearchConfig;

  constructor(
    items: T[],
    config: SearchConfig = { caseSensitive: false, useRegex: false },
  ) {
    this.items = items;
    this.config = config;
  }

  public executeQuery(query: string, keys: Array<keyof T>): SearchResult<T>[] {
    if (!query || query.trim() === "") {
      return [];
    }

    const results: SearchResult<T>[] = [];
    const flags = this.config.caseSensitive ? "g" : "gi";
    const regex = this.config.useRegex
      ? new RegExp(query, flags)
      : new RegExp(query.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), flags);

    for (const item of this.items) {
      for (const key of keys) {
        const value = String(item[key]);
        if (regex.test(value)) {
          results.push({
            item,
            score: 1.0,
            matches: [{ indices: [0, value.length], key: String(key) }],
          });
          break;
        }
      }
    }

    return results.slice(0, this.config.maxResults ?? 100);
  }
}
```

### 3.3 Rust (メモリ安全な検索インデックス)

```rust
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct InvertedIndex {
    docs: HashMap<usize, String>,
    index: HashMap<String, Vec<usize>>,
}

impl InvertedIndex {
    pub fn new() -> Self {
        InvertedIndex {
            docs: HashMap::new(),
            index: HashMap::new(),
        }
    }

    pub fn add_document(&mut self, doc_id: usize, content: &str) {
        self.docs.insert(doc_id, content.to_string());
        for word in content.split_whitespace() {
            let clean_word = word.trim_matches(|c: char| !c.is_alphanumeric()).to_lowercase();
            if !clean_word.is_empty() {
                self.index.entry(clean_word).or_insert_with(Vec::new).push(doc_id);
            }
        }
    }

    pub fn search(&self, keyword: &str) -> Option<&Vec<usize>> {
        let clean_keyword = keyword.to_lowercase();
        self.index.get(&clean_keyword)
    }
}

fn main() {
    let mut search_db = InvertedIndex::new();
    search_db.add_document(1, "Neovim is fast and efficient");
    search_db.add_document(2, "Rust guarantees memory safety");
    search_db.add_document(3, "Search indexing with Rust in Neovim plugins");

    if let Some(results) = search_db.search("neovim") {
        println!("Found 'neovim' in documents: {:?}", results);
    }
}
```

---

## 4. 置換（`:%s`）テスト用のターゲットリスト

以下のセクションのテキストは、各種置換コマンド（`:s/old/new/g` など）の実験用データです。

### 4.1 変数名の一括置換（CamelCase / snake_case / kebab-case）

- `user_account_id` -> `userAccountId`
- `user_account_name` -> `userAccountName`
- `user_account_email` -> `userAccountEmail`
- `user_account_status` -> `userAccountStatus`
- `user_account_created_at` -> `userAccountCreatedAt`

### 4.2 設定値の置換（`true` / `false` / 数値）

```ini
[server_config]
host = "127.0.0.1"
port = 8080
enable_ssl = false
max_connections = 100
timeout_seconds = 30
debug_mode = false
log_level = "info"
```

### 4.3 ログデータの正規表現抽出・置換

以下の形式のログから IP アドレスやステータスコードを抽出・置換する練習を行えます。

```text
2026-08-12 10:00:01 [INFO] 192.168.1.10 - GET /api/v1/status - 200 OK
2026-08-12 10:00:05 [WARN] 192.168.1.15 - POST /api/v1/login - 401 Unauthorized
2026-08-12 10:00:12 [ERROR] 10.0.0.50 - GET /api/v1/data - 500 Internal Server Error
2026-08-12 10:00:20 [INFO] 192.168.1.10 - PUT /api/v1/user/1 - 200 OK
2026-08-12 10:00:25 [INFO] 172.16.0.8 - DELETE /api/v1/item/99 - 204 No Content
```

---

## 5. まとめとテスト完了確認

Neovim での代表的な検索・置換操作の復習チェックリストです。

- [ ] `/keyword` で「keyword」を順方向検索できるか
- [ ] `?keyword` で「keyword」を逆方向検索できるか
- [ ] 単語上で `*` や `#` を押して、カーソル下の単語を瞬時に検索できるか
- [ ] `:%s/2026/2027/g` で年号の一括置換が行えるか
- [ ] `f(` や `t"` などで改行内の文字移動がスムーズに行えるか
- [ ] 正規表現 `\v` (very magic) を利用した複雑なパターンマッチが機能するか

以上のテキストを用いて、キーボードショートカットや各種プラグイン（`telescope.nvim`, `flash.nvim`, `hlslens` など）の動作検証を行ってください。

========================================
<F2><F3><F4><F5><F6><F7><F8><F9><F10><F11>

<F2><F3><F4><F5><F6><F7><F8><F9><F10>
＝３２＿ｉｎｓｅｒｔ＿ｎｅｗ＿ｂｕｌｌｅｔ（）

                2009-01-21 水曜日
        2027-07-22 木曜日    1234-01-01 日曜日

# 煙管　　　　　芥川龍之介監護改悟全額散飯莞児

加州石川郡金沢城の城主、前田斉広は、参勤中、江戸城の本丸へ登城する毎に、必ず愛用の煙管を持ってった。次
当時有名な煙管商、住吉屋七兵衛の手に成った、金無垢地に、剣梅鉢の紋ぢらしと云う、数寄を凝らした煙管である。

前田家は、幕府の制度によると、五世、加賀守綱紀以来、大廊下詰めで、席次は、世々尾紀水三家の次を占めている。危言

勿論、裕福な事も、当時の大小名の中で、肩を比べる者は、ほとんど、一人もない。
だから、その当主たる斉広が、金無垢の煙管を持つと云う事は、寧ろ身分相当の装飾品を持つのに過ぎないのである。完吾を韓語仁慈菌糸朝日放送

========================================

今、画面に映って,揺＼れの範囲は長周期規模地震動は棚の本は宇都宮放送局の前です。震度水道管の破裂が確認されています排水が機能していて、現状は一箇所のみです。周辺での断水は確認されていない。緊急地震速報が鳴ってすぐ

JR東日本では始発から運行できるか判断しています。震源地は茨城県南部で道路やコンビニなどの店舗に瑞々しいのだが時間差

あいうえおかきくけこさしすせそたちつてとなにぬねのやゆよわをん　
1234567890ー^\[]@」」\。、<F2><F3><F4><F5><F6><F7><F8><F9><F10><F11>
!""#$%&''())~=~|{}}```()```
""#$%&'())~~=~~|'{}}``

[]］()！""＃＄％＆''()～＝～|{}｝

| モード             | 打鍵 | 実際の挿入 | 期待している結果 |
| ------------------ | ---- | ---------- | ---------------- |
| ひらがな・カタカナ | <[>  | []         | 「,または「」    |
| ひらがな・カタカナ | <z(> | z()        | （,または（）    |
| ひらがな・カタカナ | <z > | z          | 　               |
| 全角英数           | <">  | ""         | ＂,または＂＂    |
| 全角英数           | <'>  | ''         | ＇,または＇＇    |
| 全角英数           | <(>  | ()         | （,または（）    |
| 全角英数           | <[>  | []         | ［,または［］    |
| 全角英数           | <{>  | {}         | ｛,または｛｝    |

                 「」「」

ひらがな(カタカナ)モード いろは の直後で打鍵、_ はカーソル位置を示す
いろは"_"
いろは'_'
いろ()_は
いろ「」*は
いろは`_`
いろは「」
いろは{_}

全角英数モード ＡＢＤ の直後で打鍵、_ はカーソル位置を示す
ＡＢ＂＂_Ｃ
ＡＢ＇＇_Ｃ
ＡＢ（）_Ｃ
ＡＢ［］_Ｃ
ＡＢ｛｝_Ｃ
ＡＢ｀｀_Ｃ

また、"つ"の小文字が入力できなくなりました。 <tta> が "た"になります

イロハ""
イロハ''
イロ()ハ
イロ「」ハ
イロハ{}
イロハ``
）''

========================================

# 2026-08-26 水曜日 00:37:31

## ひらがな入力モード: _ はカーソルポジション

| 文字列に続けて打鍵 | 結果        |
| ------------------ | ----------- |
| <">                | いろは"_"   |
| <'>                | いろは'_'   |
| <(>                | いろは()_   |
| <[>                | いろは「」_ |
| <[>                | いろは{_}   |
| <`>                | いろは`_`   |

## 全角英数入力モード: _ はカーソルポジション

| 文字列に続けて打鍵 | 結果        |
| ------------------ | ----------- |
| <">                | ＡＢＣ＂＂_ |
| <'>                | ＡＢＣ＇＇_ |
| <(>                | ＡＢＣ（）_ |
| <[>                | ＡＢＣ｛｝_ |
| <{>                | ＡＢＣ｛｝_ |
| <`>                | ＡＢＣ｀｀_ |

## 半角英数入力モード: _ はカーソルポジション

| 文字列に続けて打鍵 | 結果     |
| ------------------ | -------- |
| <">                | ABC"_"   |
| <'>                | ABC'_    |
| <(>                | ABC(_)   |
| <[>                | ABC[_]   |
| <{>                | ABC{_}   |
| <`>                | ABC`_`   |
| <('>               | ABC('_') |

# 2026-08-26 水曜日 01:29:37

1234567890ー^\
!""#$%&''())~~=~~|
@「」``{}
:」+*}
、。\<>?_

１２３４５６７８９０－＾＼
！＂＂＃＄％＆＇＇（））～＝～|
＠［］｀｀｛｝
；：］＋＊｝
，．／＼
＜＞？＿

1234567890-^\
!""#$%&''())~~=~~|
qwertyuiop@[]
QWERTYUIOP`{}
asdfghjkl;:]
ASDFGHJKL+*}
zxcvbnm,./\
ZXCVBNM<>?_

z<SPC> 　_
a) ）_
z( z(_)

あいうえお ぁぃぅぇぉ
かきくけこ きゃきぃきゅきぇきょ
さしすせそ しゃしぃしゅしぇしょ
ざじずぜぞ じゃじぃじゅじぇじょ
たちつてと ちゃちぃちゅちぇちょ
だぢづでど ぢゃぢぃぢゅぢぇぢょ
なにぬねの にゃにぃにゅにぇにょ
はひふへほ ひゃひぃひゅひぇひょ
ばびぶべぼ びゃびぃびゅびぇびょ
ぱぴぷぺぽ ぴゃぴぃぴゅぴぇぴょ
まみむめも みゃみぃみゅみぇみょ
やいゆいぇよ
らりるれろ
わをん
ゔぁゔぃゔゔぇゔぉ
ちゃちちゅちぇちょ
しゃししゅしぇしょ
こっき かっぱ どっく

色は匂へど散りぬるを我が世誰そ常ならむ有為の奥山今日越えて浅き夢見じ酔ひもせず
いろはにほへとちりぬるをわかよたれそつねならむうゐのおくやまけふこえてあさきゆめみしゑひもせす

やゑゑ ゐ
あいうえお かきくけこ　さしそ
ちゃった かっちこっち にゅっつっつっていってたっとっぷ
あっゆっうんにっぶっゔぃっゔぃっやっやっぃっぃっじああっしっぢっふぁ
っふぃっがっひっじっじっきっじ実機での
end

# 2026-08-29 土曜日 19:58:44

## 実機での動作確認

- nvim-autopairs を有効にした nvim-skk にて、<i><C-j></> につづけて
  - ▽Bu までは blink.cmp のライブ補完が有効です。
  - ▽Bug でライブ補完が消えます。おそらく辞書に候補が無いためです。
  - ▽bug だとライブ補完が継続します。
  - ▽bug( と入力すると、 ▽bug() とプレエディットが継続したまま補完されました。
    - 補完後のカーソル位置は ) の直後でしたた。

## むしろ検討して欲しい動作について

- むしろ検討の話題にしたいのは、次の入力パターンです。同じく </>の直後に続けて
- ▽( とすると () とプレエディットを抜けて確定し、()の間にカーソルが位置しました。
- <(> の他にも <"> <'> <`> <[> <{> でも同じ挙動でした。

## 他の autopairs 系プラグインを試してみた

- セッションを中断した間に、 https://github.com/windwp/nvim-autopairs.git の他に
- https://github.com/nvim-mini/mini.pairs.git
- https://github.com/m4xshen/autoclose.nvim.git
- https://github.com/altermo/ultimate-autopair.nvim.git
- これらのプラグインを実機で試しました。
  - https://github.com/nabehan/nvim-config-blink-skknvim.git
  - ここの lua/plugins/01-base.lua のコメントアウトしたコードがチャレンジの痕跡です。
- 少なくとも通常バッファの abbrevモードは、nvim-autopairs と同様でした。
- コマンドラインモードは試していません。

## abbrevモードでの記号入力からの変換に期待している動作

- skkの辞書には 半角記号が見出しになっている項目があります。
- <i><C-j></><(><SPC> から （ , ［ ,『っっj , 【 , 〔 , 左小かっこ , left parenthesis , に変換できる辞書になっているんです。
- <(> の他にも <"> <'> <`> <[> <{> でも 通常バッファの abbrevモード で期待できる動作を実現できていません。
- しかし不思議なことに、コマンドラインや検索モードでは、期待したとおりの動作が実現できています。

ひきつづき、検討をよろしくおねがいします。相棒!

# 2026-08-30 日曜日 04:20:49

## 最小環境とコマンドライン入力は問題なし

- 最小環境の nvim-snd と、nvim-skk の コマンドライン入力や検索入力では、先程のセッションで提示してくれた capture.lua でも、abbrevモードで期待の動作が実現できていました。

## autopairs との相性が悪いなら、モードに応じて抑止してしまえないか?

- この問題に nvim-autopairs 自体の on/off を切り替えて対応できないのでしょうか？
- skk.nvim の 半角英数モードと全角英数モードでだけ autopairs を有効にして、それ以外ではautopairs は抑止しておく。
  - つまり、abbrevモードがある ひらがなモード と カタカナモードでは autopairs を抑止する
- または、abbrevモードが開始されたら autopairs を抑止する。
- もし、nvim-autopairs では、このような状況に応じた on/off が不可能なら、他の autopairs 系プラグインに切替えてもいいでしょう。
  - https://github.com/nvim-mini/mini.pairs.git
  - https://github.com/m4xshen/autoclose.nvim.git
  - https://github.com/altermo/ultimate-autopair.nvim.git

# 2026-08-30 日曜日 21:00:06

- セッションが中断していましたが、続きから生成を再開してください。
- 更新したファイルの準備が整ったら、Artifact に示してください。

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

end
