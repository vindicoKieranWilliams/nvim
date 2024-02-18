--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>sgh', require('gitsigns').preview_hunk,
          { buffer = bufnr, desc = '[S]earch [G]it [H]unk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
      end,
    },
  },

  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {}
  },

  -- {
  --   -- Add indentation guides even on blank lines
  --   'lukas-reineke/indent-blankline.nvim',
  --   -- Enable `lukas-reineke/indent-blankline.nvim`
  --   -- See `:help indent_blankline.txt`
  --   opts = {
  --     char = '⎸',
  --     show_trailing_blankline_indent = false,
  --   },
  -- },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {
      }
    end,
  },

  { 'mhinz/vim-startify' },


  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },



  {
    'justinmk/vim-sneak'
  },


  {
    "kdheepak/lazygit.nvim",
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    'github/copilot.vim'
  },

  {
    "elihunter173/dirbuf.nvim"
  },

  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      -- configurations go here
    },
  },

  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      -- Your setup opts here
    },
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})


-- ====================================================================================================================
-- ====================================================================================================================
-- ====================================================================================================================


-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.clipboard = ""

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.autoindent = true

vim.o.foldenable = false

vim.o.relativenumber = true

vim.o.smarttab = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

vim.opt.cursorline = true

vim.opt.swapfile = false


-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

require('nvim-treesitter.configs').setup {
  -- Install the parsers for the languages you want to comment in
  -- Here are the supported languages:
  ensure_installed = {
    'astro', 'css', 'graphql', 'html', 'javascript',
    'lua', 'python', 'scss', 'svelte', 'tsx', 'twig',
    'typescript', 'vim', 'vue',
  },

  context_commentstring = {
    enable = true,
  },

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,


  -- This is where you can add other nvim-treesitter modules' configurations
  -- For example, `incremental_selection`, `textobjects`, `refactor`, etc.
  -- Refer to the nvim-treesitter documentation for more modules
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

-- [[nvim-tree setup]]
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)
  -- custom mappings
  vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open Horizontal'))
end

-- pass to setup along with your other options
require("nvim-tree").setup {
  view = {
    preserve_window_proportions = true,
  },
  on_attach = my_on_attach,
  disable_netrw = true,
}

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    layout_strategy = 'vertical',
    vertical = {
      preview_cutoff = 0
    },

    width = 100,
    height = 100,
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 0,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>ff', require('telescope.builtin').git_files, { desc = 'Search git files' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]resume' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>sgb', require('telescope.builtin').git_branches, { desc = '[S]earch [G]it [B]ranches' })
vim.keymap.set('n', '<leader>sgc', require('telescope.builtin').git_commits, { desc = '[S]earch [G]it [C]ommits' })



require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt", "vim" },
})

-- Startify settings
vim.g.startify_lists = {
  { type = 'files',     header = { 'Recent Files' } },
  { type = 'dir',       header = { 'Current Directory ' } },
  { type = 'sessions',  header = { 'Sessions' } },
  { type = 'bookmarks', header = { 'Bookmarks' } }
}

vim.g.startify_bookmarks = {
  { c = '~/.config/nvim/' },
  { z = '~/.zshrc' }
}

vim.g.startify_session_autoload = 1
vim.g.startify_change_to_vcs_root = 1
vim.g.startify_fortune_use_unicode = 1
vim.g.startify_session_persistence = 1
vim.g.startify_enable_special = 0

vim.g.startify_custom_header = {
  '/════════════════════════════════════════════════╗ ',
  '║                                                ║ ',
  '║   ██╗  ██╗██╗    ██╗      ██╗██████╗ ███████╗  ║ ',
  '║   ██║ ██╔╝██║    ██║      ██║██╔══██╗██╔════╝  ║ ',
  '║   █████╔╝ ██║ █╗ ██║█████╗██║██║  ██║█████╗    ║ ',
  '║   ██╔═██╗ ██║███╗██║╚════╝██║██║  ██║██╔══╝    ║ ',
  '║   ██║  ██╗╚███╔███╔╝      ██║██████╔╝███████╗  ║ ',
  '║   ╚═╝  ╚═╝ ╚══╝╚══╝       ╚═╝╚═════╝ ╚══════╝  ║ ',
  '╚════════════════════════════════════════════════╝ '
}

-- [[Terminal settings]]
-- Open terminal on ctrl+n
vim.api.nvim_exec([[
  function! OpenTerminal()
    split term://zsh
    resize 10
  endfunction
]], false)

vim.api.nvim_set_keymap('n', '<C-n>', ':call OpenTerminal()<CR>', { noremap = true, silent = true })


-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>-', '10<C-W>-<CR>', { noremap = true, silent = true })

-- Turn terminal to normal mode with ctrl-c
vim.api.nvim_set_keymap('t', '<C-x>', '<C-\\><C-n>', { noremap = true, silent = true })

-- Start terminal in insert mode
vim.api.nvim_command('au BufEnter * if &buftype == "terminal" | startinsert | endif')


local map = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

map('n', '<C-b>', ':NvimTreeToggle<CR>', options)
map('n', '<leader><C-b>', ':NvimTreeFindFile<CR>', options)

-- Use alt+hjkl to move between split/vsplit panels
map('t', '<A-h>', '<C-\\><C-n><C-w>h', options)
map('t', '<A-j>', '<C-\\><C-n><C-w>j', options)
map('t', '<A-k>', '<C-\\><C-n><C-w>k', options)
map('t', '<A-l>', '<C-\\><C-n><C-w>l', options)
map('n', '<A-h>', '<C-w>h', options)
map('n', '<A-j>', '<C-w>j', options)
map('n', '<A-k>', '<C-w>k', options)
map('n', '<A-l>', '<C-w>l', options)


-- Alt + 3 ==> #
map('i', '<A-3>', '#', options)

map('i', '<A-3>', '#', options)

-- Tab Remapping
map('n', '<C-a>', ':tabprevious<CR>', options)

-- no highlight mapping
map('n', '<leader>h', ':noh<CR>', options)

-- Source current file
map('n', '<leader>s', ':source %<CR>', options)

-- Save file with ctrl + s
map('i', '<C-s>', '<C-c>:w<CR>', options)
map('n', '<C-s>', ':w<CR>', options)

-- Horizontal scroll
map('', '<C-L>', '20zl', options)
map('', '<C-H>', '20zh', options)

-- Yank to end of line with Y
map('n', 'Y', 'y$', options)

-- Yank to system clipboard with ctrl + y
map('v', 'Y', '"*y', options)


-- Ctrl J does the opposite of shift J
map('n', '<C-J>', 'a<CR><Esc>k$', options)
map('n', '<leader>j', '$a<CR><Esc>', options)


-- Remap Ctrl + d to move half a page down and center the cursor line
vim.api.nvim_set_keymap('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
-- Remap Ctrl + u to move half a page up and center the cursor line
vim.api.nvim_set_keymap('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })


-- This function opens the current buffer in a horizontal split
function Split_current_buffer_horizontally()
  -- Store the current buffer number
  local current_buf = vim.api.nvim_get_current_buf()
  -- Open a new horizontal split
  vim.cmd('split')
  -- Set the buffer of the new window to the stored buffer
  vim.api.nvim_win_set_buf(0, current_buf)
  -- move to top of the window
  vim.cmd('normal! gg')
end

-- This function opens the current buffer in a vertical split
function Split_current_buffer_vertically()
  -- Store the current buffer number
  local current_buf = vim.api.nvim_get_current_buf()
  -- Open a new vertical split
  vim.cmd('vsplit')
  -- Set the buffer of the new window to the stored buffer
  vim.api.nvim_win_set_buf(0, current_buf)
  -- move to top of the window
  vim.cmd('normal! gg')
end

-- Map leader-x to the function_split current_buffer_horizontally
vim.api.nvim_set_keymap('n', '<Leader>x', ':lua Split_current_buffer_horizontally()<CR>',
  { noremap = true, silent = true })

-- Map leader-v to the function Split_current_buffer_vertically
vim.api.nvim_set_keymap('n', '<Leader>v', ':lua Split_current_buffer_vertically()<CR>',
  { noremap = true, silent = true })


vim.cmd [[ hi Normal guibg=NONE ctermbg=NONE ]]
vim.cmd [[ hi SignColumn guibg=NONE ctermbg=NONE ]]
vim.cmd [[ hi VertSplit guifg=NONE ctermfg=NONE ]]
vim.cmd [[ hi MsgArea guibg=NONE ctermbg=NONE ]]
vim.cmd [[ hi MsgSeparator guibg=NONE ctermbg=NONE ]]
vim.cmd [[highlight CursorLine guibg=#24364a ]]

-- -- Resize buffers
-- -- Width
-- map('n', '<C-w>+', ':vertical resize +5<CR>', options)
-- map('n', '<C-w>++', ':vertical resize +10<CR>', options)
-- map('n', '<C-w>+++', ':vertical resize +20<CR>', options)
-- map('n', '<C-w>-', ':vertical resize -5<CR>', options)
-- map('n', '<C-w>--', ':vertical resize -10<CR>', options)
-- map('n', '<C-w>---', ':vertical resize -20<CR>', options)
-- -- Height
-- map('n', '<C-h>+', ':resize +5<CR>', options)
-- map('n', '<C-h>++', ':resize +10<CR>', options)
-- map('n', '<C-h>+++', ':resize +20<CR>', options)
-- map('n', '<C-h>-', ':resize -5<CR>', options)
-- map('n', '<C-h>--', ':resize -10<CR>', options)
-- map('n', '<C-h>---', ':resize -20<CR>', options)

-- Speed up scroll down and up
map('n', '<C-e>', '5<C-e>', options)
map('n', '<C-y>', '5<C-y>', options)

-- Function to copy the current working directory to clipboard
function CwdCopy()
  vim.cmd('!pwd | pbcopy')
end

-- Key mapping for copying the current working directory to clipboard with <Leader>cwd
map('n', '<Leader>cwd', ':lua CwdCopy()<CR>', options)


map('n', '<Leader>lg', ':LazyGit<CR>', options)
map('n', '<Leader>db', ':Dirbuf<CR>', options)
map('n', '<Leader>f.', ':silent !npx prettier --write %<CR>', options)
map('n', '<Leader>fa', ':!npx prettier --write .<CR>', { noremap = true, silent = true })
