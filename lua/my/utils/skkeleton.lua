-- ~/.config/nvim/lua/my/utils/skkeleton.lua
-- lazy.nvim 対応: denops.vim は lazy=false で起動するが、
-- DenopsReady が既に発火済みの場合も考慮してフォールバックを用意する
local vim = vim

local function skkeleton_config()
  vim.fn["skkeleton#config"]({
    sources = { "skk_server", "skk_dictionary" },

    skkServerHost = "127.0.0.1",
    skkServerPort = 1178,

    globalDictionaries = {
      { "/usr/local/share/skk/SKK-JISYO.edict2", "utf-8" },
      { "/usr/local/share/skk/SKK-JISYO.emoji", "utf-8" },
      { "/usr/local/share/skk/SKK-JISYO.emoji-ja", "utf-8" },
      -- { "/usr/local/share/skk/SKK-JISYO.LLL.utf8", "utf-8" },
      -- { "/usr/local/share/skk/SKK-JISYO.jawiki", "utf-8" },
    },

    userDictionary = vim.fn.expand("~/.local/share/skk/SKK-JISYO.user"),

    completionRankFile = vim.fn.expand("~/.cache/skkeleton_rank.json"),

    eggLikeNewline = true,
    registerConvertResult = true,
    showCandidatesCount = 1,

    markerHenkan = "▽",
    markerHenkanSelect = "▼",
  })
end

-- DenopsReady が既に発火済みなら即実行、未発火なら autocmd で待つ
if vim.g.denops_status == "ready" then
  skkeleton_config()
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "DenopsReady",
    once = true,
    callback = skkeleton_config,
  })
end

require("skkeleton_indicator").setup({
  eijiText = "latn",
  hiraText = "ひら",
  kataText = "カタ",
  hankataText = "半カ",
  zenkakuText = "ＬＡ",
})

vim.keymap.set({ "i", "c" }, "<C-j>", "<Plug>(skkeleton-enable)", { silent = true, remap = true })
-- Normalモード：iで挿入モードに入りつつskkeletonをON
vim.keymap.set("n", "<C-j>", "i<Plug>(skkeleton-enable)", { silent = true, remap = true })
