local o = vim.opt
local g = vim.g
g.mapleader       = ' '
g.maplocalleader  = ' '

local opts = { noremap=true, silent=true }
o.expandtab       = true
o.wrap            = false
o.shell           = '/bin/bash'

local map = vim.keymap.set
-- map('n', '<leader>b', '<C-O>', opts)          -- prev item in jumplist
map('n', 'Q', '<nop>', opts)                  -- disable 'Q'
map('n', '<leader>w', ':!make fmt<CR>', opts) -- code format command
map('n', '<leader>c', ':e /home/justin/.config/nvim/init.lua<CR>', opts)
map('t', '<Esc>', [[<C-\><C-n>]], opts)       -- exit terminal mode
map('n', '<C-k>', ':wincmd k<CR>', opts)      -- navigate splits
map('n', '<C-j>', ':wincmd j<CR>', opts)
map('n', '<C-h>', ':wincmd h<CR>', opts)
map('n', '<C-l>', ':wincmd l<CR>', opts)

local autocmd = vim.api.nvim_create_autocmd
autocmd('Filetype', { pattern = { 'make' }, command = 'setlocal tabstop=4 shiftwidth=4 softtabstop=4' })

function setup_lsp()
  map('n', '<leader>e', vim.diagnostic.open_float, opts)
  map('n', '<leader>q', vim.diagnostic.setloclist, opts)

  local on_attach = function(client, bufnr)
    map('n', '<leader>d', vim.lsp.buf.definition, bufopts)
    map('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    map('n', '<leader>h', vim.lsp.buf.hover, bufopts)
    map('n', '<leader>r', vim.lsp.buf.references, bufopts)
    map('n', '<leader>i', vim.lsp.buf.implementation, bufopts)
    map('i', '<C-k>', vim.lsp.completion.get, bufopts)
  end

  local nvim_lsp = require('lspconfig')
  function handler(server_name)
    local opts = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    nvim_lsp[server_name].setup(opts)
  end

  handler("pyright")
  handler("clangd")
end


function setup_fzf()
local fzf = require("fzf-lua")
fzf.setup({
  keymap={
    fzf={
      ["ctrl-q"] = "select-all+accept"
    },
  },
  grep={
      rg_glob = true,
      glob_flag = "--iglob",
      glob_separator = "%s%-%-",
    },
  })
  local fzf_files = function()
    fzf.files() --{ winopts = { preview = { hidden = "hidden" } } })
  end

  local fzf_symbols = function()
    fzf.lsp_document_symbols() --({ winopts = { preview = { hidden = "hidden" } } })
  end

  local fzf_live_grep_resume = function()
    fzf.live_grep({resume=true})
  end

  map("n", "<leader>f", fzf_files, { desc = "Fzf Files", noremap=true, silent=true })
  map("n", "<leader>s", fzf_symbols, { desc = "Fzf Symbols", noremap=true, silent=true })
  map("n", "<leader>b", fzf.buffers, { desc = "Fzf Buffers", noremap=true, silent=true })
  map("n", "<leader>/", fzf.live_grep, { desc = "Fzf Grep", noremap=true, silent=true })
  map("n", "<leader>R", fzf_live_grep_resume, { desc = "Fzf Resume Grep", noremap=true, silent=true })
end

local function setup_treesitter()
  local ts_parsers = {
    "bash",
    "c",
    "cpp",
    "dockerfile",
    "gitcommit",
    "json",
    "lua",
    "make",
    "markdown",
    "python",
    "yaml",
  }
  local nts = require("nvim-treesitter")
  nts.install(ts_parsers)
  autocmd("FileType", { -- enable treesitter highlighting and indents
    callback = function(ev)
      local filetype = ev.match
      local lang = vim.treesitter.language.get_lang(filetype)
      if vim.treesitter.language.add(lang) then
	if vim.treesitter.query.get(filetype, "indents") then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        if vim.treesitter.query.get(filetype, "folds") then
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
        vim.treesitter.start()
      end
    end,
  })
end

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/Mofiqul/dracula.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = 'main' },
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/ruifm/gitlinker.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/folke/which-key.nvim.git",
  "https://github.com/tpope/vim-sleuth.git",
})

require("dracula").setup({}) -- I dont really like this actually...
vim.cmd[[colorscheme dracula]]

setup_treesitter()
setup_lsp()
setup_fzf()
require("treesitter-context").setup({
  max_lines = 3,
  multiline_threshold = 1,
  separator = '-',
  min_window_height = 20,
  line_numbers = true,
})

require("gitlinker").setup({})

