-- ~/.config/nvim/lua/my/autocommand.lua
local vim = vim

-- 専用のグループを作成（clear = true により、再読み込み時に古い設定をリセット）
-- 2026-06-20 Sat 05:31:54
local my_augroup = vim.api.nvim_create_augroup("MyCustomAutocmds", { clear = true })

-- ===================================================================
-- LSPサーバーアタッチ時の処理 2026-06-20 Sat 21:57:20
-- ===================================================================
vim.api.nvim_create_autocmd("LspAttach", {
  group = my_augroup,
  callback = function(ctx)
    local builtin = require("telescope.builtin")

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = ctx.buf,
        silent = true,
        desc = desc,
      })
    end

    -- Telescope 系
    map("n", "gd", builtin.lsp_definitions, "[G]oto [D]efinition")
    map("n", "gr", builtin.lsp_references, "[G]oto [R]eferences")
    map("n", "gi", builtin.lsp_implementations, "[G]oto [I]mplementation")
    map("n", "\\D", builtin.lsp_type_definitions, "Type [D]efinition")

    map("n", "\\gs", builtin.lsp_document_symbols, "[G]et document [S]ymbols")
    map("n", "\\gS", builtin.lsp_workspace_symbols, "[G]et workspace [S]ymbols")
    map("n", "\\gi", builtin.lsp_incoming_calls, "[G]et [I]ncoming calls")
    map("n", "\\go", builtin.lsp_outgoing_calls, "[G]et [O]utgoing calls")

    map("n", "g/", builtin.diagnostics, "[G]oto diagnostic search")

    -- Diagnostics
    map("n", "g[", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("n", "g]", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "\\q", vim.diagnostic.setloclist, "Diagnostics to loclist")

    -- LSP標準
    map("n", "gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

    map("n", "\\rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("n", "\\ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

    map("n", "\\F", function()
      vim.lsp.buf.format()
    end, "[F]ormat")

    -- Workspace
    map("n", "\\wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd")

    map("n", "\\wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove")

    map("n", "\\wl", function()
      vim.print(vim.lsp.buf.list_workspace_folders())
    end, "[W]orkspace [L]ist")

    -- ▼ 追加: 保存時の自動整形 (Format on Save) 2026-06-21 Sun 19:11:58
    local client = vim.lsp.get_client_by_id(ctx.data.client_id)
    if client and client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = ctx.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = ctx.buf, async = false })
        end,
      })
    end
  end,
})

-- ===================================================================
-- インデントとタブ 2026-06-20 Sat 21:57:31
-- ===================================================================
local indent4_filetypes = {
  markdown = true,
  text = true,
  yaml = true,
  python = true,
  haskell = true,
  scratch = true,
}

vim.api.nvim_create_autocmd("FileType", {
  group = my_augroup,
  pattern = "*",
  callback = function()
    local width = indent4_filetypes[vim.bo.filetype] and 4 or 2

    -- 【修正】幅の変更と同時に、バッファローカルでスペース化を強制的に上書き有効化する
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = width
    vim.opt_local.tabstop = width
    vim.opt_local.shiftwidth = width
  end,
})

-- ===================================================================
-- 保存時に行末の空白を自動削除
-- ===================================================================
vim.api.nvim_create_autocmd("BufWritePre", {
  group = my_augroup, -- 2026-06-20 Sat 05:31:35
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- ===================================================================
-- Windows 改行のファイルを開いたら Unix 形式に自動変換
-- ===================================================================
vim.api.nvim_create_autocmd("BufReadPost", {
  group = my_augroup, -- 2026-06-20 Sat 05:31:35
  pattern = "*",
  callback = function()
    if vim.bo.fileformat == "dos" then
      vim.bo.fileformat = "unix"
    end
  end,
})

-- ===================================================================
-- markdown と text で markdown table mode を自動有効にする
-- ===================================================================
vim.api.nvim_create_autocmd("FileType", {
  group = my_augroup, -- 2026-06-20 Sat 05:31:35
  pattern = { "markdown", "text", "scratch" },
  callback = function(ev)
    if vim.b[ev.buf].mtm_enabled then
      return
    end
    local orig_notify = vim.notify
    vim.notify = function() end
    vim.cmd("silent! Mtm")
    vim.notify = orig_notify
    vim.b[ev.buf].mtm_enabled = true
  end,
})

-- ===================================================================
-- Terminal のキーマッピング
-- ===================================================================
vim.api.nvim_create_autocmd("TermOpen", {
  group = my_augroup, -- 2026-06-20 Sat 05:31:35
  pattern = "*",
  callback = function()
    local opts = { buffer = 0 }
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
    -- vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    -- vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    -- vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    -- vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
  end,
})

-- ===================================================================
-- 複数マッチを使って強調表示
-- ===================================================================
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
  group = my_augroup, -- 2026-06-20 Sat 05:31:35
  callback = function()
    vim.cmd("call clearmatches()")
    vim.fn.matchadd("ZenkakuSpace", "　")
    vim.fn.matchadd("TrailingSpace", [[\s\+$]])
  end,
})

-- ===================================================================
-- neovim 起動時 / 特定ファイルタイプの処理
-- ===================================================================
vim.api.nvim_create_autocmd("VimEnter", {
  group = my_augroup, -- 2026-06-20 Sat 05:31:35
  callback = function()
    if vim.bo.filetype == "man" then
      return
    end
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        vim.cmd("Telescope file_browser")
      end)
    end
  end,
})

-- ===================================================================
-- lisp ファイルを開いたら SWANK を自動起動 -- 2026-06-23 Tue 21:15:04
-- ===================================================================
vim.api.nvim_create_autocmd("FileType", {
  group = my_augroup,
  pattern = { "lisp", "commonlisp" },
  once = true, -- 複数の lisp ファイルを開いても1回だけ起動
  callback = function()
    -- ポート 4005 が既に使用中か確認
    local result = vim.fn.system("ss -tlnp | grep 4005")
    if result ~= "" then
      vim.notify("SWANK は既に起動しています (port 4005)", vim.log.levels.INFO)
      return
    end

    -- toggleterm で SWANK をバックグラウンド起動
    local Terminal = require("toggleterm.terminal").Terminal
    local swank = Terminal:new({
      cmd = 'sbcl --eval "(ql:quickload :swank)" --eval "(swank:create-server :port 4005 :dont-close t)"',
      direction = "horizontal",
      hidden = true, -- 自動的には表示しない
      close_on_exit = false,
      on_open = function()
        vim.notify("SWANK を起動しています...", vim.log.levels.INFO)
      end,
      on_exit = function()
        vim.notify("SWANK が終了しました", vim.log.levels.WARN)
      end,
    })
    swank:toggle()
    -- ターミナルウィンドウを閉じてバックグラウンドで動かす
    vim.defer_fn(function()
      swank:close()
    end, 3000) -- 3秒後にウィンドウを閉じる（SWANK の起動を待つ）
  end,
})
