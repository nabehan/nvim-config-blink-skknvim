-- lua/plugins/10-lisp.lua
-- Common Lisp 開発環境
-- conjure: REPL 駆動開発（バッファ内の式を直接 SBCL に送信・評価）
-- nvim-parinfer: 括弧の自動バランス補正

return {
  -- -----------------------------------------------------------------
  -- conjure: Neovim 用 REPL 統合
  -- SBCL と直接通信し、バッファ内の式をリアルタイムで評価できる
  -- -----------------------------------------------------------------
  {
    "Olical/conjure",
    ft = { "lisp", "commonlisp", "clojure", "scheme", "racket", "fennel" },
    init = function()
      -- Common Lisp のバックエンドを SBCL に設定
      vim.g["conjure#client#common_lisp#swank#exec"] = "sbcl"

      -- ログバッファの表示設定
      vim.g["conjure#log#hud#width"] = 0.42 -- 画面右側42%に表示
      vim.g["conjure#log#hud#height"] = 0.30 -- 画面高さの30%
      vim.g["conjure#log#hud#enabled"] = true -- HUD を有効化

      -- ログバッファをウィンドウ下部に開く
      vim.g["conjure#log#botright"] = true

      -- <localleader> を \ に設定（デフォルトは \ ）
      -- vim.g.maplocalleader = "\\"
    end,
  },

  -- -----------------------------------------------------------------
  -- nvim-parinfer: 括弧の自動バランス補正
  -- Lisp 系言語では括弧が命のため、インデントに合わせて自動補正する
  -- -----------------------------------------------------------------
  {
    "gpanders/nvim-parinfer",
    ft = { "lisp", "commonlisp", "clojure", "scheme", "racket", "fennel" },
  },
}
