-- ~/.config/nvim/lua/my/cmp/skkeleton_source.lua
-- blink.cmp ネイティブソース: skkeleton (SKK) の変換候補を補完メニューに出す
--
-- uga-rosa/cmp-skkeleton (nvim-cmp 用) の実装ロジックをそのまま移植したもの。
-- blink.compat 経由では確定 (accept) 時にテキストがバッファへ反映されない
-- 問題が解決できなかったため、ネイティブソースとして書き直した。
--
-- 最大の相違点: cmp-skkeleton は nvim-cmp の params.context.cursor.character
-- (LSP 準拠の UTF-16 コードユニット単位) を基準に textEdit.range を計算している。
-- blink.cmp のネイティブソースは LSP ワイヤープロトコルを経由しないため、
-- range は素の「バイトオフセット」（nvim_win_get_cursor / nvim_buf_set_text と
-- 同じ単位）で計算する。skkeleton の getPreEdit で得られる実際の文字列の
-- バイト長 (#pre_edit) を使えば、UTF-16 換算をまったく行わずに済む。

---@module 'blink.cmp'
---@class blink.cmp.Source
local source = {}
source.__index = source

function source.new()
  return setmetatable({}, source)
end

---@param key string
---@param args table|nil
local function request(key, args)
  args = args or {}
  return vim.fn["denops#request"]("skkeleton", key, args)
end

local function skkeleton_enabled()
  return vim.fn.exists("*skkeleton#is_enabled") == 1 and vim.fn["skkeleton#is_enabled"]() == true
end

-- skkeleton は ▽/▼ が現れたときだけ show() されるため（lua/my/cmp/blink.lua の
-- autocmd を参照）、trigger_characters は特に必要ない
function source:get_trigger_characters()
  return {}
end

function source:get_completions(_, callback)
  if not skkeleton_enabled() then
    callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
    return function() end
  end

  local ok, candidates = pcall(request, "getCompletionResult")
  if not ok or not candidates or vim.tbl_isempty(candidates) then
    callback({ items = {}, is_incomplete_forward = true, is_incomplete_backward = true })
    return function() end
  end

  local pre_edit = request("getPreEdit") --  例: "▽かんじ"
  local ranks_ok, ranks = pcall(request, "getRanks")
  ranks = ranks_ok and ranks or {}

  -- 素のバイトオフセットで range を計算する（LSP の UTF-16 換算はしない）
  local win = vim.api.nvim_win_get_cursor(0)
  local row0 = win[1] - 1
  local end_col = win[2]
  local start_col = math.max(end_col - #pre_edit, 0)

  local range = {
    start = { line = row0, character = start_col },
    ["end"] = { line = row0, character = end_col },
  }

  local items = {}
  local global_rank = -1

  for _, cand in ipairs(candidates) do
    local kana = cand[1]
    for _, word in ipairs(cand[2]) do
      local label = word:gsub(";.*$", "")

      local rank = ranks[word]
      if not rank then
        rank = global_rank
        global_rank = global_rank - 1
      end

      table.insert(items, {
        label = label,
        filterText = pre_edit,
        sortText = string.format("%010d", -rank),
        kind = require("blink.cmp.types").CompletionItemKind.Text,
        textEdit = {
          range = range,
          newText = label,
        },
        data = { kana = kana, word = word },
      })
    end
  end

  callback({
    items = items,
    is_incomplete_forward = true,
    is_incomplete_backward = true,
  })

  return function() end
end

function source:resolve(item, callback)
  local word = item.data and item.data.word
  if word and word:find(";") then
    item.documentation = {
      kind = "plaintext",
      value = word:match(";%s*(.*)$"),
    }
  end
  callback(item)
end

-- 確定後、実際のテキスト置換 (default_implementation) を行い、
-- そのうえで skkeleton 側に「この候補が選ばれた」ことを通知する。
--
-- 【重要】blink.cmp の accept パイプラインでは、textEdit の実際の適用は
-- source:execute() に渡される第4引数 default_implementation を
-- 自分で呼び出さない限り一切実行されない
-- (lua/blink/cmp/sources/lsp/init.lua の lsp:execute も同様の実装)。
-- これを呼び忘れていたのが「確定してもバッファに反映されない」不具合の直接の原因だった。
function source:execute(_, item, callback, default_implementation)
  default_implementation()

  local data = item.data or {}
  if data.kana and data.word then
    pcall(request, "completeCallback", { data.kana, data.word })
  end

  callback()
end

return source
