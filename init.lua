-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- show both relative and absolute line number
vim.o.number = true
vim.wo.relativenumber = true
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
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

-- [[ Configure plugins ]]
require('lazy').setup({
  {
    "gitaarik/nvim-cmp-toggle",
  },
  {
    "andrewferrier/debugprint.nvim",
    opts = {},
    dependencies = {
      -- "echasnovski/mini.nvim"   -- Needed for :ToggleCommentDebugPrints (not needed for NeoVim 0.10+)
    },
    -- The 'keys' and 'cmds' sections of this configuration are optional and only needed if
    -- you want to take advantage of `lazy.nvim` lazy-loading. If you decide to
    -- customize the keys/commands (see below), you'll need to change these too.
    keys = {
      { "g?", mode = 'n' },
      { "g?", mode = 'x' },
    },
    cmd = {
      "ToggleCommentDebugPrints",
      "DeleteDebugPrints",
    },
  },
  {
    "theKnightsOfRohan/csvlens.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim"
    },
    config = true,
    opts = { --[[ Place your opts here ]] }
  },
  {
    'echasnovski/mini.starter',
    version = false,
    config = function()
      require('mini.starter').setup()
    end
  },
  {
    "nat-418/boole.nvim",
    config = function()
      require('boole').setup({
        mappings = {
          increment = '<C-a>',
          decrement = '<C-x>'
        },
        additions = {
          -- { "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" }, -- this is causing crash
        }
      })
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "folke/twilight.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  {
    "debugloop/telescope-undo.nvim",
    dependencies = { -- note how they're inverted to above example
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { -- lazy style key map
        "<leader>u",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
    },
    opts = {
      -- don't use `defaults = { }` here, do this in the main telescope spec
      extensions = {
        undo = {
          -- telescope-undo.nvim config, see below
          use_delta = false,
          entry_format = "#$ID, $STAT, $TIME",
          saved_only = true,
        },
        -- no other extensions here, they can have their own spec too
      },
    },
    config = function(_, opts)
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is in it's own namespace (telescope
      -- defaults, as well as each extension).
      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
    end,
  },
  {
    "windwp/nvim-ts-autotag"
  },
  {
    "tversteeg/registers.nvim",
    cmd = "Registers",
    config = function()
      local registers = require("registers")
      registers.setup({
        show_register_types = false,
        show_empty = false,
        show = "\"neio12345:./+",
        window = {
          border = "rounded",
          transparency = 0
        }
      });
    end,
    keys = {
      { "\"",    mode = { "n", "v" } },
      { "<C-R>", mode = "i" }
    },
    name = "registers",
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "gbprod/none-ls-shellcheck.nvim",
    },
  },
  {
    'luukvbaal/statuscol.nvim',
    opts = function()
      local builtin = require('statuscol.builtin')
      return {
        setopt = true,
        -- override the default list of segments with:
        -- number-less fold indicator, then signs, then line number & separator
        segments = {
          { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
          { text = { '%s' },             click = 'v:lua.ScSa' },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
          },
        },
      }
    end,
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    -- event = 'VeryLazy',    -- You can make it lazy-loaded via VeryLazy, but comment out if thing doesn't work
    init = function()
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
    end,
    config = function()
      require('ufo').setup {}
    end,
  },
  {
    'barrett-ruth/live-server.nvim',
    build = 'pnpm add -g live-server',
    cmd = { 'LiveServerStart', 'LiveServerStop' },
    config = true
  },
  -- {
  --   'nvim-java/nvim-java',
  --   dependencies = {
  --     'nvim-java/lua-async-await',
  --     'nvim-java/nvim-java-refactor',
  --     'nvim-java/nvim-java-core',
  --     'nvim-java/nvim-java-test',
  --     'nvim-java/nvim-java-dap',
  --     'MunifTanjim/nui.nvim',
  --     'neovim/nvim-lspconfig',
  --     'mfussenegger/nvim-dap',
  --     {
  --       'williamboman/mason.nvim',
  --       opts = {
  --         registries = {
  --           'github:nvim-java/mason-registry',
  --           'github:mason-org/mason-registry',
  --         },
  --       },
  --     }
  --   },
  -- },
  {
    "chrisgrieser/nvim-various-textobjs",
    lazy = false,
    opts = { useDefaultKeymaps = true },
  },
  { "chrisgrieser/nvim-spider",       lazy = true },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    "jemag/telescope-diff.nvim",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
    }
  },
  {
    "RutaTang/quicknote.nvim",
    config = function()
      -- you must call setup to let quicknote.nvim works correctly
      require("quicknote").setup({
        mode = "resident",
      })
    end
    ,
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  { "sindrets/diffview.nvim" },
  { 'eandrju/cellular-automaton.nvim' },
  { "mistricky/codesnap.nvim",        build = "make" },
  { "mtdl9/vim-log-highlighting" },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",        -- optional for lazy loading on command
    opts = {
      debounce_delay = 5000, -- delay after which a pending save is executed
    },
  },
  {
    "kamykn/spelunker.vim",
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "R", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
    opts = {
      modes = {
        search = {
          enabled = true
        },
        char = {
          enabled = false
        }
      }
    }
  },
  {
    "jinh0/eyeliner.nvim",
    config = function()
      require 'eyeliner'.setup {
        highlight_on_key = true, -- show highlights only after keypress
        dim = true               -- dim all other characters if set to true (recommended!)
      }
    end,
    condition = false -- temporary disable this plugin
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = true,
  },
  {
    "sontungexpt/url-open", -- using this because opening url with `gx` is from netrw by default
    event = "VeryLazy",
    cmd = "URLOpenUnderCursor",
    config = function()
      local status_ok, url_open = pcall(require, "url-open")
      if not status_ok then
        return
      end
      url_open.setup({
        open_only_when_cursor_on_url = true -- for removing the highlight when searching with eyeliner
      })
    end,
  },
  {
    "chentoast/marks.nvim",
    opts = {
      mappings = {
        delete_buf = "<leader>dm",
      }
    }
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end
  },
  {
    "mfussenegger/nvim-dap",
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui"
    },
    config = function(_, opts)
      local path = " /home/leo/anaconda3/bin/python "
      require("dap-python").setup(path)
    end
  },
  {
    "nvimtools/none-ls.nvim",
    ft = { "python" },
    opts = function()
      return require "custom.configs.null-ls"
    end
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
      lsp = {
        progress = {
          enabled = false
        }
      },
      routes = {
        {
          view = "notify",
          filter = { event = "msg_showmode", find = "recording" },
        },
      },
      -- show popup menu and cmdline in the same position
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 8,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
    }
  },
  "f-person/git-blame.nvim",
  "dstein64/vim-startuptime",
  {
    "letieu/harpoon-lualine",
    dependencies = {
      {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
      }
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
    end,
  },
  -- 'mbbill/undotree',
  {
    'alexghergh/nvim-tmux-navigation',
    config = function()
      local nvim_tmux_nav = require('nvim-tmux-navigation')

      nvim_tmux_nav.setup {
        disable_when_zoomed = true -- defaults to false
      }

      vim.keymap.set('n', "<A-n>", nvim_tmux_nav.NvimTmuxNavigateLeft)
      vim.keymap.set('n', "<A-e>", nvim_tmux_nav.NvimTmuxNavigateDown)
      vim.keymap.set('n', "<A-u>", nvim_tmux_nav.NvimTmuxNavigateUp)
      vim.keymap.set('n', "<A-i>", nvim_tmux_nav.NvimTmuxNavigateRight)
      vim.keymap.set('n', "<A-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
      vim.keymap.set('n', "<A-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
    end
  },
  'nvim-lua/plenary.nvim',
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      local harpoon = require("harpoon")

      harpoon:setup()

      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
      vim.keymap.set("n", "<leader>m", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      vim.keymap.set("n", "<C-n>", function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<C-e>", function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<C-i>", function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<C-o>", function() harpoon:list():select(4) end)
      vim.keymap.set("n", "<leader>re", function() harpoon:list():remove() end) -- remove current buffer
    end,
  },
  -- NOTE: First, some plugins that don't require any configuration
  -- set up copilot
  'github/copilot.vim',
  -- recommend some better key presses
  -- some git commands
  'tpope/vim-fugitive',
  -- for auto remaining consistency in indentation
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        'williamboman/mason.nvim',
      },
      {
        'williamboman/mason-lspconfig.nvim',
      },
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        'j-hui/fidget.nvim',
        filter = function(client, title)
          -- filter out diagnostic message
          if client == 'null-ls' and title == 'diagnostics' then
            return false
          end
          return true
        end
      },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has 'win32' == 1 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',
      "mlaursen/vim-react-snippets",

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-copilot',


      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk('next')
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk('prev')
          end
        end)
        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      require('onedark').setup {
        -- Set a style preset. 'dark' is default.
        style = 'dark', -- dark, darker, cool, deep, warm, warmer, light
      }
      require('onedark').load()
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation lines even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    version = "3.5", -- the latest version only supports latest neovim, so use a older version
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    opts = {
      toggler = {
        line = '<C-_>', -- <C-/> control slash
        block = 'gbc',  -- <C-/> control slash
      },
    }
  },

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

  -- TODO: check the plugins
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

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

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end);
vim.keymap.set('n', ']e',
  function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
  end);
vim.keymap.set('n', 'gf', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
  pickers = {
    find_files = {
      find_command = {
        "rg",
        "--no-ignore",
        "--hidden",
        "--files",
        "-g",
        "!**/node_modules/*",
        "-g",
        "!**/.git/*",
      },
    },
  },
  extensions = {
    quicknote = {
      defaultScope = "CWD",
    },
  },
}

require("telescope").load_extension("quicknote")

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
require("telescope").load_extension("diff")
require("telescope").load_extension("undo")

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' }) -- find every function in telescope
vim.keymap.set('n', '<C-p>', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>pp', function()
  require('telescope.builtin').find_files()
end)
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>gb', require('telescope.builtin').git_branches, { desc = '[G]it [B]ranches' })
vim.keymap.set('n', '<leader>gsl', require('telescope.builtin').git_stash) -- can apply stash, but not removing them
vim.keymap.set('n', '<leader>gd', require('telescope.builtin').git_status) -- a useful way for checking git diff
vim.keymap.set('n', '<leader>ps', function()
  require('telescope.builtin').grep_string({ search = vim.fn.input('Grep > ') })
end)
vim.keymap.set("n", "<leader>pd", function()
  require("telescope").extensions.diff.diff_current({ hidden = true })
end, { desc = "Compare file with current" })

vim.keymap.set("n", "<leader>po", function()
  require("telescope.builtin").lsp_document_symbols()
end, { desc = "Compare file with current" })


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- List of parsers to ignore installing
    ignore_install = {},
    -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
    modules = {},
    highlight = { enable = true },
    indent = { enable = true, disable = { 'dart' } },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {},
  }
end, 0)


--[[ Configure git-blame]]
local git_blame = require('gitblame')
-- This disables showing of the blame text next to the cursor
vim.g.gitblame_display_virtual_text = 0 -- don't show line git blame  by default
vim.g.gitblame_message_template = '<author> • <date>'
vim.g.gitblame_date_format = '%r'

-- config lualine
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'another_item',
      {
        "harpoon2",
        indicators = { "n", "e", "i", "o" },
        active_indicators = { "[n]", "[e]", "[i]", "[o]" },
        no_harpoon = "Harpoon not loaded",
      },
    },
    lualine_y = { { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available } }, -- TODO: make it only show time and username
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

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

  nmap('<leader>ca', function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end, '[C]ode [A]ction')

  nmap('gd', function()
    vim.api.nvim_feedkeys("mR", "n", false); -- mark as reference
    require('telescope.builtin').lsp_definitions()
  end, '[G]oto [D]efinition')
  nmap('gr', function()
    vim.api.nvim_feedkeys("mD", "n", false); -- mark as definition
    require('telescope.builtin').lsp_references()
  end, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  -- nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')


  -- See `:help K` for why this keymap
  nmap('gh', vim.lsp.buf.hover, 'Hover Documentation')
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

-- require('java').setup()

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
-- I don't know why this is set up twice, but I didin't write this, so don't touch it
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  clangd = {},
  -- gopls = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'
local lspconfig = require("lspconfig")

mason_lspconfig.setup {
  ensure_installed = {
    'lua_ls',
    'ruff_lsp',
    'tsserver',
    'pyright',
    'clangd',
  },
  automatic_installation = true
  -- actionlint
  -- yaml-language-server
  --[[    NOTE: black, mypy, debugpy
  cannot be put into ensure_installed, so install them manually in the :Mason command ]]
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

lspconfig.pyright.setup {
  on_attach = on_attach,
  settings = {
    pyright = {
      autoImportCompletion = true,
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
        typeCheckingMode = 'off' }
    }
  }
}

lspconfig.ruff_lsp.setup {
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {},
    }
  }
}

lspconfig.jdtls.setup {}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
require("vim-react-snippets").lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert({
    ['<Down>'] = cmp.mapping.select_next_item(),
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
  enabled = function()
    -- disable completion in comments
    local context = require 'cmp.config.context'
    -- keep command mode completion enabled when cursor is in a comment
    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    else
      return not context.in_treesitter_capture("comment")
          and not context.in_syntax_group("Comment")
    end
  end
}

-- The line beneath this is called `modeline`. See `:help modeline`

-- vim: ts=2 sts=2 sw=2 et

-- my Remap
-- remap H and L for motion
vim.api.nvim_set_keymap('n', 'H', '^', { noremap = true })
vim.api.nvim_set_keymap('n', 'L', '$', { noremap = true })


vim.opt.timeoutlen = 2000 -- allow longer wait time for leader key
vim.opt.swapfile = false

-- ctrl n  to  accept  Copilot suggestion
-- NOTE:  alt right to  accept next word
vim.keymap.set('i', '<C-t>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

-- vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

--[[ some shortcut for vim-fugitive ]]
vim.keymap.set("n", "<leader>gg", vim.cmd.Git)                                       -- git status
vim.keymap.set("n", "<leader>ge", "<cmd>Gdiffsplit!<CR>")                            -- git diff editor
vim.keymap.set("n", "<leader>gl", "<cmd>Git log --graph --oneline --decorate<CR>")   -- git log
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>")                             -- git commit
vim.keymap.set("n", "<leader>ga", "<cmd>Git add .<CR>")                              -- git add all
vim.keymap.set("n", "<leader>gm", "<cmd>Git commit --amend<CR>")                     -- git amend
vim.keymap.set("n", "<leader>gn", "<cmd>Git add .|Git commit --amend --no-edit<CR>") -- git amend no edit
vim.keymap.set("n", "<leader>gp", "<cmd>Git push<CR>")                               -- git push
vim.keymap.set("n", "<leader>gu", "<cmd>Git pull --rebase<CR>")                      -- git pull rebase
vim.keymap.set("n", "<leader>gss", "<cmd>Git stash<CR>")
vim.keymap.set("n", "<leader>gsp", "<cmd>Git stash pop<CR>")
vim.keymap.set("n", "<leader>gsd", "<cmd>Git stash drop<CR>")
vim.keymap.set("n", "<leader>gN", "<cmd>Git nah<CR>") -- go back to last commit(using git alias)

-- prevent auto comment on new line
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ 'r', 'o' })
  end,
})

vim.opt.hlsearch = true
-- toggle highlight search
vim.keymap.set("n", "<leader>hh", ":set hlsearch!<CR>")
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8

vim.opt.updatetime = 50

-- remaps
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set({ "n", "v" }, "<leader>P", [["+p]]) -- my remap,paste from system clipboard

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<cmd>q!<CR>")
vim.keymap.set("n", "<leader>ff", vim.lsp.buf.format)

-- for quickfix
vim.keymap.set("n", "<C-Up>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-Down>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader><Up>", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader><Down>", "<cmd>lprev<CR>zz")

-- replace the word that I am on
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set(
  "n",
  "<leader>ee",
  "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end)

vim.keymap.set("n", "<C-b>", "<cmd>NvimTreeToggle<CR>")
vim.keymap.set("n", "K", "%")
vim.keymap.set("v", "K", "%")

-- save remap
function Save_file()
  local modifiable = vim.api.nvim_buf_get_option(0, 'modifiable')
  if modifiable then
    vim.cmd 'w!'
  end
end

vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<Cmd>lua Save_file()<CR>', {
  noremap = true,
  silent = true,
})

vim.keymap.set("n", "<leader>lb", function()
  git_blame.toggle()
end) -- toggle showing line blame after line

--[[ Configure nvim-tree ]]
local function on_attach_nvim_tree(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end


  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.del('n', '<C-e>', { buffer = bufnr }) -- unmap, used for harpoon
  vim.keymap.set('n', '<Right>', function() api.node.open.edit() end, { buffer = bufnr })
  vim.keymap.set('n', '<Left>', function() api.tree.collapse_all() end, { buffer = bufnr })
end

-- pass to setup along with your other options
require('nvim-tree').setup({
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
  on_attach = on_attach_nvim_tree,
})



--[[ Configure nvim dap]]
vim.keymap.set("n", "<leader>db", "<cmd> DapToggleBreakpoint<CR>")
vim.keymap.set("n", "<leader>dpr", function()
  require("dap-python").test_method()
end)                                                    -- debug python run
vim.keymap.set("n", "/", "ms/")                         -- mark with s before searching
vim.keymap.set("n", "<leader>tt", "<cmd>tab split<CR>") -- open fullscreen in new tab

-- clear all marks on start
-- vim.api.nvim_create_autocmd({ "BufRead" }, { command = ":delm a-zA-Z0-9", })

-- configure url-open plugin
vim.keymap.set("n", "gx", "<esc>:URLOpenUnderCursor<cr>")

--configure set flutter tool setup
require("flutter-tools").setup {
  flutter_path = "/home/leo/snap/flutter/common/flutter/bin/flutter",
  lsp = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      analysisExcludedFolders = {
        vim.fn.expand("$HOME/flutter/.pub-cache"),
        vim.fn.expand("$HOME/.pub-cache"),
        vim.fn.expand("$HOME/tools/flutter/"),
      },
    }
  },
  debugger = {
    enabled = true,
    run_via_dap = true,
  },
}

require("nvim-surround").setup {}

require("auto-save").setup({
  condition = function(buf)
    local fn = vim.fn
    local utils = require "auto-save.utils.data"
    if utils.not_in(fn.getbufvar(buf, "&filetype"), { "harpoon" }) then
      return true
    end
    return false
  end,
});

vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg = '#56B6C2', bold = true, underline = true })
vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg = '#C67BDD', bold = true, underline = true })

-- some flutter tools shortcut
vim.keymap.set("n", "<leader>fr", "<cmd>FlutterRun<CR>")
vim.keymap.set("n", "<leader>fe", "<cmd>FlutterEmulators<CR>")
vim.keymap.set("n", "<leader>fo", "<cmd>FlutterOutlineToggle<CR>")
vim.keymap.set("n", "<leader>fR", "<cmd>FlutterRestart<CR>")
vim.keymap.set("n", "<leader>fn", "<cmd>FlutterRename<CR>")

local api = vim.api
local M = {}

-- toggle dev log of flutter
M.toggle_log = function()
  local wins = api.nvim_list_wins()

  for _, id in pairs(wins) do
    local bufnr = api.nvim_win_get_buf(id)
    if api.nvim_buf_get_name(bufnr):match '.*/([^/]+)$' == '__FLUTTER_DEV_LOG__' then
      return vim.api.nvim_win_close(id, true)
    end
  end

  pcall(function()
    vim.api.nvim_command 'sb + __FLUTTER_DEV_LOG__ | resize 15'
  end)
end


vim.keymap.set("n", "<leader>fl", M.toggle_log)
vim.keymap.set("n", "<leader>fd", "<cmd>FlutterDevices<CR>")
vim.keymap.set("n", "<leader>rq", "<cmd>FlutterQuit<CR>")
vim.keymap.set("n", "<leader>rn", ":IncRename ")

-- dap ui shortcut
vim.keymap.set("n", "<leader>dt", require('dapui').toggle)
vim.keymap.set("n", "<leader>dc", require("dap").continue)
vim.keymap.set("n", "<leader>do", require("dap").step_over)
vim.keymap.set("n", "<leader>di", require("dap").step_into)
vim.keymap.set("n", "<leader>dO", require("dap").step_out)
vim.keymap.set("n", "<leader>dB", require("dap").step_back)
vim.keymap.set("n", "<leader>dr", require("dap").restart)
vim.keymap.set("n", "<leader>ds", require("dap").stop)

require("codesnap").setup({
  mac_window_bar = false,
  watermark = ""
})


vim.keymap.set("n", "<leader>fml", function()
  vim.g.enable_spelunker_vim = 0; -- disable spelunker
  require("cellular-automaton").start_animation("make_it_rain");
end)

vim.keymap.set("n", "<leader>pt", "<cmd>NvimTreeFindFile<CR>") -- find current file in nvim-tree

vim.keymap.set("n", "<leader>Do", "<cmd>DiffviewOpen<CR>")
vim.keymap.set("n", "<leader>Dc", "<cmd>DiffviewClose<CR>")
vim.keymap.set("n", "<leader>Dt", "<cmd>DiffviewToggleFiles<CR>")
vim.keymap.set("n", "<leader>Dh", "<cmd>DiffviewFileHistory<CR>")

-- quick note
vim.keymap.set("n", "<leader>nc", require("quicknote").NewNoteAtCWD) -- note cwd
vim.keymap.set("n", "<leader>nl", require("quicknote").NewNoteAtCurrentLine)
vim.keymap.set("n", "<leader>no", require("quicknote").OpenNoteAtCurrentLine)
vim.keymap.set('n', "<leader>nt", "<cmd>Telescope quicknote<CR>") -- note telescope
vim.keymap.set('n', "<leader>nd", require("quicknote").DeleteNoteAtCurrentLine)
vim.keymap.set('n', "<leader>nD", require("quicknote").DeleteNoteAtCWD)

-- resizing window

vim.keymap.set("n", "<C-w>f", [[<cmd>vertical resize +20<cr>]]) -- note: nvim tree uses vertical size
vim.keymap.set("n", "<C-w>s", [[<cmd>vertical resize -20<cr>]])
vim.keymap.set("n", "<C-w>t", [[<cmd>horizontal resize +4<cr>]])
vim.keymap.set("n", "<C-w>r", [[<cmd>horizontal resize -4<cr>]])

vim.keymap.set(
  { "n", "o", "x" },
  "w",
  "<cmd>lua require('spider').motion('w')<CR>",
  { desc = "Spider-w" }
)
vim.keymap.set(
  { "n", "o", "x" },
  "e",
  "<cmd>lua require('spider').motion('e')<CR>",
  { desc = "Spider-e" }
)
vim.keymap.set(
  { "n", "o", "x" },
  "b",
  "<cmd>lua require('spider').motion('b')<CR>",
  { desc = "Spider-b" }
)

-- `as` for outer subword, `is` for inner subword
vim.keymap.set({ "o", "x" }, "as", '<cmd>lua require("various-textobjs").subword("outer")<CR>')
vim.keymap.set({ "o", "x" }, "is", '<cmd>lua require("various-textobjs").subword("inner")<CR>')

vim.api.nvim_set_keymap('n', '<leader>te', '<cmd>tabn<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tn', '<cmd>tabp<CR>', { noremap = true, silent = true })

-- ufo (folding)
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
vim.keymap.set('n', 'zu', require('ufo').enableFold)
vim.keymap.set("n", "zp", function()
  require("ufo.preview"):peekFoldedLinesUnderCursor()
end)

-- next and prev fold
vim.api.nvim_set_keymap('n', 'z<Up>', 'zk', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'z<Down>', 'zj', { noremap = true, silent = true })

-- disable auto completion in telescope
cmp.setup({
  enabled = function()
    buftype = vim.api.nvim_buf_get_option(0, "buftype")
    if buftype == "prompt" then return false end
    return true
  end
})

-- store recent five registers in neio

-- move registers between them
local function move_registers()
  vim.fn.setreg('o', vim.fn.getreg('i'))
  vim.fn.setreg('i', vim.fn.getreg('e'))
  vim.fn.setreg('e', vim.fn.getreg('n'))
  vim.fn.setreg('n', vim.fn.getreg('0')) -- NOTE: 0 is default copy register)
end

-- 自動命令組：每次複製、刪除和改變寄存器內容後自動調用 move_registers 函數
local yank_augroup = vim.api.nvim_create_augroup('YankToRegisters', { clear = true })


vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
  callback = function()
    move_registers()
  end,
  group = yank_augroup,
})

-- nvim-ts-autotag
require('nvim-ts-autotag').setup({
  opts = {
    -- Defaults
    enable_close = true,          -- Auto close tags
    enable_rename = true,         -- Auto rename pairs of tags
    enable_close_on_slash = false -- Auto close on trailing </
  },
})

-- twilight.nvim
vim.keymap.set("n", "<leader>tw", "<cmd>Twilight<CR>")

-- enable twilight by default
vim.api.nvim_create_augroup('Twilight', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = 'Twilight',
  pattern = '*',
  command = 'TwilightEnable'
})

-- toggle nvim cmp
vim.api.nvim_set_keymap('n', '<leader>tc', ':NvimCmpToggle<CR>', { noremap = true, silent = true })
