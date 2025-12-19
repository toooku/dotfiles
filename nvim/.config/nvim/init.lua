-- ~/.config/nvim/init.lua
vim.g.mapleader = " "

-- 基本
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus" -- OSクリップボード共有
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.wrap = false
vim.opt.scrolloff = 6
vim.opt.sidescrolloff = 6

-- Light テーマ前提の視認性調整
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.colorcolumn = "100" -- 任意

-- インデント
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- 見た目/操作
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400

-- 保存時の事故防止
vim.opt.undofile = true

-- キーマップ
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "No highlight" })

-- ウィンドウ移動（Cursorっぽく）
map("n", "<C-h>", "<C-w>h", { desc = "Win left" })
map("n", "<C-j>", "<C-w>j", { desc = "Win down" })
map("n", "<C-k>", "<C-w>k", { desc = "Win up" })
map("n", "<C-l>", "<C-w>l", { desc = "Win right" })

-- LSPキーマップ（アタッチ時）
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local map = vim.keymap.set
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- lazy.nvim を runtimepath に追加
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- oxocarbon (light)
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "light"
      vim.cmd.colorscheme("oxocarbon")
    end,
  },

  -- ファイル検索/全文検索（CursorのCmd+P相当）
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      local map = vim.keymap.set
      map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
      map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Grep" })
      map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
    end
  },

  -- LSP（定義ジャンプ/補完の土台）
  { "neovim/nvim-lspconfig" },

  -- LSP/formatter等のインストーラ（あると超楽）
  -- Mason（必ず最初に setup）
  { "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end
  },

  -- LSP本体
  { "neovim/nvim-lspconfig" },

  -- Mason <-> LSP ブリッジ
  { "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- mason.nvim が確実に初期化済みかチェック
      local ok, mason = pcall(require, "mason")
      if not ok then
        vim.notify("mason.nvim not loaded", vim.log.levels.ERROR)
        return
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- LSP設定（Neovim 0.11+）
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- mason-lspconfig は「インストール管理だけ」
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
        automatic_enable = true,
      })
    end
  },

  -- 補完（CursorのIntellisense）
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end
  },
})
