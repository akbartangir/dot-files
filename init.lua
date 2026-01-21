-- Leaders
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Core options
local o = vim.opt
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.termguicolors = true
o.wrap = false
o.splitright = true
o.splitbelow = true
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.smartindent = true
o.clipboard = "unnamedplus"
o.mouse = "a"
o.updatetime = 200
o.timeoutlen = 400
o.scrolloff = 4
o.ignorecase = true
o.smartcase = true
o.completeopt = "menu,menuone,noselect"

-- Basic keymaps
local map = vim.keymap.set
local silent = { silent = true }
map({ "n", "v" }, "<Space>", "<Nop>", silent)
map("n", "<leader>w", ":w<CR>", silent)
map("n", "<leader>q", ":q<CR>", silent)

-- Diagnostics
map("n", "<leader>d", vim.diagnostic.setloclist, silent)
map("n", "<leader>df", function()
  vim.diagnostic.open_float(nil, { focus = false, scope = "line" })
end, silent)
map("n", "[d", vim.diagnostic.goto_prev, silent)
map("n", "]d", vim.diagnostic.goto_next, silent)

-- Window navigation
map("n", "<C-h>", "<C-w>h", silent)
map("n", "<C-j>", "<C-w>j", silent)
map("n", "<C-k>", "<C-w>k", silent)
map("n", "<C-l>", "<C-w>l", silent)
map("n", "<leader><leader>", "<C-w>w", silent)

-- Buffer navigation
map("n", "<leader>]", ":bnext<CR>", silent)
map("n", "<leader>[", ":bprevious<CR>", silent)
map("n", "<leader>bd", ":bdelete<CR>", silent)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  -- Colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        transparent_mode = false,
        contrast = "hard",
        italic = {
          strings = false,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        bold = true,
        overrides = {
          SignColumn = { bg = "#282828" },
          GruvboxGreenSign = { bg = "#282828" },
          GruvboxOrangeSign = { bg = "#282828" },
          GruvboxPurpleSign = { bg = "#282828" },
          GruvboxYellowSign = { bg = "#282828" },
          GruvboxRedSign = { bg = "#282828" },
          GruvboxBlueSign = { bg = "#282828" },
          GruvboxAquaSign = { bg = "#282828" },
        },
      })
      vim.cmd.colorscheme("gruvbox")
    end
  },

  -- UI
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup({
        view = { width = 30, side = "left" },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
        git = { enable = true },
      })
      map("n", "<leader>e", ":NvimTreeToggle<CR>", silent)
      map("n", "<leader>ef", ":NvimTreeFindFile<CR>", silent)
    end
  },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox", globalstatus = true }
      })
    end
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({})
    end
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 12,
        direction = "horizontal",
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
      })

      local Terminal = require("toggleterm.terminal").Terminal
      local bottom_term = Terminal:new({
        direction = "horizontal",
        hidden = true,
      })

      map({ "n", "t" }, "<leader>t", function()
        bottom_term:toggle()
      end, silent)
    end
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },

  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    cmd = "Trouble",
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>dt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end
  },

  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup()
    end
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "bash" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "williamboman/mason.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "lua_ls" },
        automatic_installation = true,
      })
    end
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local function on_attach(_, bufnr)
        local function bufmap(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end
        bufmap("n", "gd", vim.lsp.buf.definition)
        bufmap("n", "gD", vim.lsp.buf.declaration)
        bufmap("n", "gr", vim.lsp.buf.references)
        bufmap("n", "gi", vim.lsp.buf.implementation)
        bufmap("n", "K", vim.lsp.buf.hover)
        bufmap("n", "<leader>rn", vim.lsp.buf.rename)
        bufmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action)
        bufmap("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- clangd
      vim.lsp.config('clangd', {
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--completion-style=bundled",
          "--header-insertion=iwyu",
        },
        init_options = {
          fallbackFlags = { "-std=c++23" },
        },
      })
      vim.lsp.enable('clangd')

      -- lua_ls
      vim.lsp.config('lua_ls', {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } }
          }
        },
      })
      vim.lsp.enable('lua_ls')
    end
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          cpp = { "clang_format" },
          c = { "clang_format" },
        },
        format_on_save = { lsp_fallback = true },
      })
    end
  }

})

-- Diagnostic configuration
vim.diagnostic.config({
  -- virtual_text = {
  --   spacing = 1,
  --   prefix = "",
  --   format = function(diagnostic)
  --     local max_width = 50
  --     local message = diagnostic.message
  --     if #message > max_width then
  --       message = message:sub(1, max_width) .. "..."
  --     end
  --     return message
  --   end,
  -- },
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "none",
    source = false,
    header = "",
    prefix = "",
    suffix = "",
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
})

-- Auto-show diagnostic float on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "none",
      source = false,
    }
    vim.diagnostic.open_float(nil, opts)
  end
})

-- Minimal diagnostic highlights
vim.cmd([[
  highlight DiagnosticUnderlineError gui=underline guisp=#fb4934
  highlight DiagnosticUnderlineWarn gui=underline guisp=#fabd2f
]])

-- LSP hover border
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  max_width = 100,
  max_height = 30,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
  max_width = 100,
})

-- Compile and Run C++ (single file)
vim.api.nvim_create_user_command("CppRun", function()
  local file = vim.fn.expand("%:p")
  local file_no_ext = vim.fn.expand("%:p:r")
  local output = file_no_ext

  -- Save file first
  vim.cmd("write")

  -- Compile command with warnings
  local compile_cmd = string.format(
  -- "g++ -Wall -Wextra -std=c++20 '%s' -o '%s'",
    "clang++ -Wall -Wextra -std=c++23 '%s' -o '%s'",
    file, output
  )

  -- Create new horizontal terminal and run
  vim.cmd("split")
  vim.cmd("terminal " .. compile_cmd .. " && '" .. output .. "'")
  vim.cmd("resize 12")
  vim.cmd("startinsert")
end, {})

-- Keymap for compile & run
map("n", "<leader>r", ":CppRun<CR>", silent)

-- Quick terminal toggle
map("t", "<Esc>", "<C-\\><C-n>", silent) -- Exit terminal mode with Esc
