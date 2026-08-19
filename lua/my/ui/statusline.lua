-- ~/.config/nvim/lua/my/ui/statusline.lua
-- lualine: A blazing fast and easy to configure Neovim statusline
-- lazy.nvim 対応: noice は dependencies に追加済みだが、
-- require を関数内に閉じ込めて安全に遅延評価する
local vim = vim

local function format_register_content(content, prefix)
  content = content:gsub("\t", " ")
  content = content:gsub("^%s+", "")
  content = content:gsub("\n", " ")
  content = content:gsub("%s+", " ")
  content = content:gsub("%%", "")
  if #content > 40 then
    content = string.sub(content, 1, 38) .. "…"
  end
  if content == "" then
    return prefix .. "EMPTY"
  end
  return prefix .. content
end

local function yank_register()
  local content = vim.fn.getreg('"')
  return format_register_content(content, "")
end

local function search_register()
  local content = vim.fn.getreg("/")
  return format_register_content(content, "/")
end

local function current_time()
  local date = os.date("%m/%d")
  local time = os.date("%H:%M:%S")
  local wdays = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
  local w = tonumber(os.date("%w")) + 1
  return string.format("%s %s %s", date, wdays[w], time)
end

local function total_lines()
  return "L:" .. vim.fn.line("$")
end

local function indent_style()
  if vim.bo.expandtab then
    return "I:s" .. math.floor(vim.bo.shiftwidth)
  else
    return "I:t" .. math.floor(vim.bo.tabstop)
  end
end

local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

-- noice コンポーネントを関数ラップして遅延 require（lazy.nvim 対応）
local function noice_get(key)
  return function()
    local ok, noice = pcall(require, "noice")
    if not ok then
      return ""
    end
    return noice.api.status[key].get()
  end
end

local function noice_has(key)
  return function()
    local ok, noice = pcall(require, "noice")
    if not ok then
      return false
    end
    return noice.api.status[key].has()
  end
end

local function skkeleton_mode()
  -- Denops や skkeleton が読み込まれていない場合は安全にスキップ
  if vim.fn.exists("*skkeleton#mode") == 0 then
    return ""
  end

  -- skkeleton が有効化されているかチェック
  -- (is_enabled が未定義または 0 の場合は非表示)
  if vim.fn.exists("*skkeleton#is_enabled") == 1 and vim.fn["skkeleton#is_enabled"]() == 0 then
    return ""
  end

  local mode = vim.fn["skkeleton#mode"]()

  -- <l> 等で直接入力モードになると mode は "" (空文字) を返すため "eiji" に置き換える
  if mode == "" then
    mode = "eiji"
  end

  local mode_map = {
    hira = "ひら",
    kata = "カタ",
    hankata = "半カ",
    zenkaku = "ＬＡ",
    eiji = "latin",
  }

  return mode_map[mode] or ""
end

require("lualine").setup({
  options = {
    globalstatus = true,
    theme = "tokyonight",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      {
        skkeleton_mode,
        color = { gui = "bold" }, -- お好みの色に調整可能
        -- color = { fg = "#7aa2f7", gui = "bold" }, -- お好みの色に調整可能
      },
      total_lines,
      "location",
      indent_style,
    },
    lualine_c = {
      {
        noice_get("mode"),
        cond = noice_has("mode"),
        color = { fg = "#ff9e64" },
      },
      {
        noice_get("message"),
        cond = noice_has("message"),
      },
    },
    lualine_x = {
      {
        noice_get("search"),
        cond = noice_has("search"),
        color = { fg = "#ff9e64" },
      },
      {
        noice_get("command"),
        cond = noice_has("command"),
        color = { fg = "#ff9e64" },
      },
    },
    lualine_y = {
      "encoding",
      "fileformat",
      "filesize",
    },
    lualine_z = {
      current_time,
    },
  },

  tabline = {
    lualine_a = { "tabs" },
    lualine_b = { "buffers" },
    lualine_c = {
      {
        "filename",
        path = 1,
        newfile_status = false,
        symbols = {
          modified = " ",
          readonly = " ",
          unnamed = " ",
          newfile = "󰬕󰬌󰬞",
        },
      },
    },
    lualine_x = { yank_register },
    lualine_y = {
      { "diff", symbols = { added = " ", modified = " ", removed = " " }, source = diff_source },
      "branch",
    },
    lualine_z = {
      "filetype",
      "lsp_status",
    },
  },
})
