-- ~/.config/nvim/init.lua

-- ============================================================================
-- lazy.nvimのインストール処理
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 基本設定
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 表示設定
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.colorcolumn = "100"
vim.opt.wrap = false
vim.opt.scrolloff = 6
vim.opt.sidescrolloff = 6

-- 検索設定
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- 入力設定
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- パフォーマンス設定
vim.opt.updatetime = 300
vim.opt.timeoutlen = 1000
vim.opt.undofile = true

-- ============================================================================
-- キーマップ
-- ============================================================================
local map = vim.keymap.set

-- 基本操作
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "No highlight" })

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h", { desc = "Win left" })
map("n", "<C-j>", "<C-w>j", { desc = "Win down" })
map("n", "<C-k>", "<C-w>k", { desc = "Win up" })
map("n", "<C-l>", "<C-w>l", { desc = "Win right" })

-- LSPキーマップ
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- ============================================================================
-- プラグイン設定
-- ============================================================================
require("lazy").setup({
  -- カラースキーム
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "light"
      vim.cmd.colorscheme("oxocarbon")
    end,
  },

  -- ファイルエクスプローラー
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      preview = {
        max_width = 0.5,
        min_width = { 40, 0.4 },
        width = 0.5,
        border = "rounded",
        win_options = {
          wrap = false,
          signcolumn = "no",
        },
      },
      float = {
        preview_split = "right",
      },
      keymaps = {
        ["<CR>"] = "actions.select",
        ["-"] = "actions.parent",
        ["<C-p>"] = "actions.preview",
      },
      view_options = {
        show_hidden = true,
      },
    },
  },

  -- ファイル検索・全文検索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")

      -- gitリポジトリのルートを検出
      local function get_git_root()
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir = current_file == "" and vim.fn.getcwd() or vim.fn.fnamemodify(current_file, ":h")
        local git_root = vim.fn.finddir(".git", current_dir .. ";")
        return git_root ~= "" and vim.fn.fnamemodify(git_root, ":h") or current_dir
      end

      map("n", "<leader>ff", function()
        builtin.find_files({ cwd = get_git_root() })
      end, { desc = "Find Files" })

      map("n", "<leader>fg", function()
        builtin.live_grep({ cwd = get_git_root() })
      end, { desc = "Live Grep" })

      map("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
    end,
  },

  -- LSP設定
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")

      -- capabilitiesの準備
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- Vue TypeScriptプラグインの設定
      local vue_language_server_path = vim.fn.stdpath("data")
        .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
      local tsserver_filetypes = {
        "typescript",
        "javascript",
        "javascriptreact",
        "typescriptreact",
        "vue",
      }
      local vue_plugin = {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path,
        languages = { "vue" },
        configNamespace = "typescript",
      }

      -- Masonのセットアップ
      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "vue_ls",
          "tailwindcss",
          "eslint",
          "ruby_ls",
          "pyright",
          "ruff_lsp",
        },
        handlers = {
          -- ts_lsの設定（vue_lsより先に設定）
          ["ts_ls"] = function()
            vim.lsp.config("ts_ls", {
              capabilities = capabilities,
              init_options = {
                plugins = { vue_plugin },
              },
              filetypes = tsserver_filetypes,
            })
            vim.lsp.enable("ts_ls")
          end,

          -- vue_lsの設定（ts_lsに依存）
          ["vue_ls"] = function()
            vim.lsp.config("vue_ls", {
              capabilities = capabilities,
              on_init = function(client)
                client.handlers["tsserver/request"] = function(_, result, context)
                  local ts_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })
                  local vtsls_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
                  local clients = {}

                  vim.list_extend(clients, ts_clients)
                  vim.list_extend(clients, vtsls_clients)

                  if #clients == 0 then
                    vim.notify(
                      "Could not find `ts_ls`, `vtsls`, or `typescript-tools` lsp client required by `vue_ls`.",
                      vim.log.levels.ERROR
                    )
                    return
                  end

                  local ts_client = clients[1]
                  local param = unpack(result)
                  local id, command, payload = unpack(param)

                  ts_client:exec_cmd({
                    title = "vue_request_forward",
                    command = "typescript.tsserverRequest",
                    arguments = { command, payload },
                  }, { bufnr = context.bufnr }, function(_, r)
                    local response = r and r.body
                    local response_data = { { id, response } }
                    ---@diagnostic disable-next-line: param-type-mismatch
                    client:notify("tsserver/response", response_data)
                  end)
                end
              end,
            })
            vim.lsp.enable("vue_ls")
          end,

          -- その他のサーバーのデフォルトハンドラー
          function(server_name)
            if server_name ~= "ts_ls" and server_name ~= "vue_ls" then
              vim.lsp.config(server_name, {
                capabilities = capabilities,
              })
              vim.lsp.enable(server_name)
            end
          end,
        },
      })

      -- lua_lsの特別な設定
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      vim.lsp.enable("lua_ls")
    end,
  },

  -- 補完
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
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
    end,
  },
})

-- ============================================================================
-- 追加のキーマップ
-- ============================================================================
map("n", "-", function()
  require("oil").open_float()
end, { desc = "Open oil in floating window" })
