-- ~/.config/nvim/lua/my/cmp/LuaSnipCustom.lua
local ls  = require("luasnip")
local s   = ls.snippet
local f   = ls.function_node
local c   = ls.choice_node
local t   = ls.text_node
local i   = ls.insert_node
local d   = ls.dynamic_node
local sn  = ls.snippet_node

-- ===================================================================
-- 今日の日付・現在日時スニペット
-- ===================================================================

local function today_date()
  return os.date("%Y-%m-%d %A")
end

local function today_date_en()
  local date  = os.date("%Y-%m-%d")
  local wdays = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
  local w     = tonumber(os.date("%w")) + 1
  return string.format("%s %s", date, wdays[w])
end

local function now_datetime()
  return os.date("%Y-%m-%d %A %H:%M:%S")
end

local function now_datetime_en()
  local date  = os.date("%Y-%m-%d")
  local wdays = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
  local time  = os.date("%H:%M:%S")
  local w     = tonumber(os.date("%w")) + 1
  return string.format("%s %s %s", date, wdays[w], time)
end

-- ===================================================================
-- 任意日付 → 曜日付加スニペット（トリガー: dw）
-- ===================================================================
-- 使い方:
--   1. "dw" と入力して <Tab> で展開
--   2. YYYY-MM-DD 形式で日付を入力
--   3. <Tab> でジャンプ → <C-n>/<C-p> で英略/英語/日本語を切り替え
--   4. <CR> で確定
-- ===================================================================

local wdays_short = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
local wdays_long  = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
local wdays_jp    = { "日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日" }

local function calc_weekday(date_str)
  local y, m, day = date_str:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
  if not y then return nil end
  local ts = os.time({
    year  = tonumber(y),
    month = tonumber(m),
    day   = tonumber(day),
    hour  = 0, min = 0, sec = 0,
  })
  if not ts then return nil end
  return tonumber(os.date("%w", ts))  -- 0=Sun ... 6=Sat
end

-- dynamic_node: i(1) の入力値から曜日のみを生成（日付は i(1) が出力するので重複しない）
local function weekday_choices(args)
  local date_str = args[1][1]
  local w = calc_weekday(date_str)

  if not w then
    return sn(nil, { t("(??)") })
  end

  local idx = w + 1
  return sn(nil, {
    c(1, {
      t(wdays_jp[idx]),     -- 金曜日
      t(wdays_short[idx]),  -- Fri
      t(wdays_long[idx]),   -- Friday
    }),
  })
end

-- ===================================================================
-- スニペット登録
-- ===================================================================
ls.add_snippets("all", {

  -- 今日の日付
  s("today_jp", { f(today_date,    {}) }),
  s("today",    { f(today_date_en, {}) }),

  -- 現在日時
  s("now_jp", { f(now_datetime,    {}) }),
  s("now",    { f(now_datetime_en, {}) }),

  -- 任意日付 + 曜日（dw でトリガー）
  -- 出力例: 2026-06-19 Fri / 2026-06-19 Friday / 2026-06-19 金曜日
  s("dw", {
    i(1, "YYYY-MM-DD"),          -- 日付入力フィールド
    t(" "),                       -- 区切りスペース
    d(2, weekday_choices, { 1 }), -- i(1) の値から曜日のみを生成
  }),
})
