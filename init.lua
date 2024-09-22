-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- show both relative and absolute line number
vim.o.number = true
vim.wo.relativenumber = true
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.cursorline = true -- highlight current line number
vim.o.cursorlineopt = "number"

package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

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
    'echasnovski/mini.operators',
    config = function()
      require('mini.operators').setup({
        exchange = {
          prefix = 'ge',
        },
        sort = {
          func = function(content)
            local opts = {}
            if content.submode == 'v' then
              -- 問使用者要用哪個分隔符進行排序
              local delimiter = vim.fn.input('Sort delimiter: ')
              -- 處理分隔符兩邊的空白
              opts.split_patterns = { '%s*' .. vim.pesc(delimiter) .. '%s*' }
            end

            -- 設置排序比較函數，數字按大小排列
            opts.compare_fun = function(a, b)
              local num_a = tonumber(a)
              local num_b = tonumber(b)
              print(num_a)
              print(num_b)

              if num_a and num_b then
                -- 如果兩者都是數字，按數值大小排序
                return num_a < num_b
              else
                -- 否則按字母順序排序
                return a < b
              end
            end

            return MiniOperators.default_sort_func(content, opts)
          end
        }
      })
    end,
    version = false,
  },
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    config = function()
      require("image").setup({
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
          },
        },
        editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
        tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
        max_height_window_percentage = 50,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
      })
    end
  }
  ,
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {
      render_modes = { 'n', 'i', 'c' },
      heading = {
        position = 'inline',
        backgrounds = {
          "DiagnosticVirtualTextError",
          "DiagnosticVirtualTextHint",
          "DiagnosticVirtualTextWarn",
          "DiagnosticVirtualTextError",
          "DiagnosticVirtualTextHint",
          "DiagnosticVirtualTextWarn",
        },
        -- icons = { "󰬺", " 󰬻", "  󰬼", "   󰬽", "    󰬾", "     󰬿", },
        icons = { "󰬺", "󰬻", "󰬼", "󰬽", "󰬾", "󰬿", },
        left_pad = 1,
        sign = false
      },
      code = {
        sign = false,
        left_pad = 2,
        right_pad = 4,
        width = 'block',
      },
      pipe_table = {
        row = 'TSRainbowRed',
      }
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  },
  {
    'echasnovski/mini.splitjoin',
    version = false,
    config = function()
      require('mini.splitjoin').setup({
        mappings = {
          toggle = '<leader>T',
          split = '<leader>ts',
          join = '<leader>tj',
        },
      })
    end
  },
  {
    'echasnovski/mini.surround',
    version = false,
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'S',             -- Add surrounding in Normal and Visual modes
          delete = 'ds',         -- Delete surrounding
          find = 'Sf',           -- Find surrounding (to the right)
          find_left = 'SF',      -- Find surrounding (to the left)
          highlight = 'SH',      -- Highlight surrounding
          replace = 'cs',        -- Replace surrounding
          update_n_lines = 'Sn', -- Update `n_lines`

          suffix_last = '',      -- Suffix to search with "prev" method
          suffix_next = '',      -- Suffix to search with "next" method
        },
        custom_surroundings = {
          -- python [f]-string
          ['f'] = {
            input = { 'f"{' .. '().-()' .. '}"' },
            output = { left = 'f"{', right = '}"' },
          },

          -- markdown [l]ink
          ['l'] = {
            input = { '%[().-()%]%(%)' },
            output = { left = '[', right = ']()' },
          },

          -- markdown [i]mage
          ['i'] = {
            input = { '!%[' .. '().-()' .. '%]%(%)' },
            output = { left = '![', right = ']()' },
          },

          ['B'] = {
            input = { '{' .. '().-()' .. '}' },
            output = { left = '{', right = '}' },
          },

          -- b[r]acket
          ['r'] = {
            input = { '%[().-()%]' },
            output = { left = '[', right = ']' },
          },
          -- TODO: c/C for single line/multiline comment function, use function to return type
        },

      })
    end
  },
  {
    "GCBallesteros/jupytext.nvim",
    config = true,
    -- Depending on your nvim distro or config you may need to make the loading not lazy
    -- lazy=false,
  },
  {
    "refractalize/oil-git-status.nvim",

    dependencies = {
      "stevearc/oil.nvim",
    },

    config = function()
      require('oil-git-status').setup({
        show_ignored = false -- show files that match gitignore with !!
      })
    end,
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        keymaps = {
          ["<C-p>"] = false,
          ["<C-s>"] = false,
          ["<C-l>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
          ["<C-r>"] = "actions.refresh",
          ["gp"] = "actions.preview",
          ["gd"] = {
            desc = "Toggle file detail view",
            callback = function()
              detail = not detail
              if detail then
                require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
              else
                require("oil").set_columns({ "icon" })
              end
            end,
          },
        },
        view_options = {
          show_hidden = true,
          is_always_hidden = function(name, _)
            return name == '..' or name == '.git'
          end
        },
        win_options = {
          wrap = true,
          signcolumn = "yes:2",
        },
        float = {
          padding = 3,
        }
      })
    end
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = false,
      highlight = {
        multiline = false,
        before = "fg",
        keyword = "fg"
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
      },
      keywords = {
        NOTE = { icon = " ", color = "hint", alt = { "INFO", "SECTION" } },
      }
    }
  },
  {
    "oysandvik94/curl.nvim",
    cmd = { "CurlOpen" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },
  {
    'echasnovski/mini.trailspace',
    version = false,
    config = function()
      require('mini.trailspace').setup()
    end
  },
  {
    "keaising/im-select.nvim",
    config = function()
      require("im_select").setup({
        default_im_select = "keyboard-us",
        default_command = "fcitx5-remote",
        set_default_events = { "VimEnter", "InsertLeave", "CmdlineLeave" },
        set_previous_events = {}, -- always english when entering insert mode
      })
    end,
  },

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
    "nat-418/boole.nvim",
    config = function()
      require('boole').setup({
        mappings = {
          increment = '<C-a>',
          decrement = '<C-x>'
        },
        additions = {
          -- NOTE: unicode characters causes crash
        },
        allow_caps_additions = {
          { 'dev', 'prod' }
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
        show = "neio12345:./+",
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
  { "sindrets/diffview.nvim" },
  { 'eandrju/cellular-automaton.nvim' },
  { "mistricky/codesnap.nvim",        build = "make" },
  { "mtdl9/vim-log-highlighting" },
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
    event = "VeryLazy",
    dependencies = {
      "gbprod/none-ls-shellcheck.nvim",
    },
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

      vim.keymap.set("n", "<leader><C-n>", function() harpoon:list():replace_at(1) end)
      vim.keymap.set("n", "<leader><C-e>", function() harpoon:list():replace_at(2) end)
      vim.keymap.set("n", "<leader><C-i>", function() harpoon:list():replace_at(3) end)
      vim.keymap.set("n", "<leader><C-o>", function() harpoon:list():replace_at(4) end)

      vim.keymap.set("n", "<leader>re", function() harpoon:list():remove() end) -- remove current buffer
    end,
  },
  -- NOTE: First, some plugins that don't require any configuration
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

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',

      { "SergioRibera/cmp-dotenv", event = "UiEnter" },
      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp_kinds = {
        Text = '',
        Method = '',
        Function = '',
        Constructor = '',
        Field = '',
        Variable = '',
        Class = '',
        Interface = '',
        Module = '',
        Property = '',
        Unit = '',
        Value = '',
        Enum = '',
        Keyword = '',
        Snippet = '',
        Color = '',
        File = '',
        Reference = '',
        Folder = '',
        EnumMember = '',
        Constant = '',
        Struct = '',
        Event = '',
        Operator = '',
        TypeParameter = '',
      }

      local cmp = require("cmp")
      cmp.setup {
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            -- remove the text after icon
            vim_item.menu = "    (" .. (vim_item.kind or "") .. ")" .. " "
            vim_item.kind = (cmp_kinds[vim_item.kind] or '')
            return vim_item
          end,
        },
        snippet = {
          expand = function(args)
            local luasnip = require 'luasnip'
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        mapping = cmp.mapping.preset.insert({
          ['<Down>'] = cmp.mapping.select_next_item(),
          ['<Up>'] = cmp.mapping.select_prev_item(),
          ['<C-c>'] = cmp.mapping.complete {}, -- suggest what you can type next
          ["<C-Up>"] = function(fallback)
            for i = 1, 5 do
              cmp.mapping.select_prev_item()(nil)
            end
          end,
          ["<C-Down>"] = function(fallback)
            for i = 1, 5 do
              cmp.mapping.select_next_item()(nil)
            end
          end,
          ["<PageUp>"] = function(fallback)
            for i = 1, 10 do
              cmp.mapping.select_prev_item()(nil)
            end
          end,
          ["<PageDown>"] = function(fallback)
            for i = 1, 10 do
              cmp.mapping.select_next_item()(nil)
            end
          end,
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if require("luasnip").expand_or_locally_jumpable() then
              require("luasnip").expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if require("luasnip").locally_jumpable(-1) then
              require("luasnip").jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = "dotenv",
            option = {
              load_shell = false,
            }
          },
          {
            name = 'buffer',
            option = {
            },
          },
        },
        enabled = function()
          -- disable completion in comments
          local context = require 'cmp.config.context'
          local buftype = vim.api.nvim_buf_get_option(0, "buftype")

          -- keep command mode completion enabled when cursor is in a comment
          -- also, when it's not in telescope prompt
          if buftype == "prompt" then return false end

          if vim.api.nvim_get_mode().mode == 'c' then
            return true
          else
            return not context.in_treesitter_capture("comment")
                and not context.in_syntax_group("Comment")
          end
        end
      }
    end
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
  },
}


-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
require("telescope").load_extension("diff")

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
vim.keymap.set('n', '<C-p>', function()
  local path = vim.loop.cwd() .. "/.git"
  local isdir = function(path)
    local ok = vim.loop.fs_stat(path)
    return ok
  end
  if isdir(path) then
    require("telescope.builtin").git_files()
  else
    require("telescope.builtin").find_files()
  end
end)
vim.keymap.set('n', '<leader>pp', function()
  require('telescope.builtin').find_files()
end)
-- vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
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
vim.keymap.set("n", "<leader>gh", require("telescope.builtin").git_bcommits)


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'markdown', "kotlin" },

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
    -- TODO: make it only show time and username
    lualine_y = { { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available } },
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

  -- SECTION: ts code actions
  nmap('<leader>ru', function()
    vim.lsp.buf.code_action {
      context = {
        only = { 'source.removeUnused.ts' }
      },
      apply = true
    }
  end, '[R]emove [U]nused')

  nmap('<leader>ti', function()
    vim.lsp.buf.code_action {
      context = {
        only = { 'source.addMissingImports.ts' }
      },
      apply = true
    }
  end, '[T]ypescript add missing imports')

  nmap('<leader>ri', function()
    vim.lsp.buf.code_action {
      context = {
        only = { 'source.removeUnusedImports.ts' }
      },
      apply = true
    }
  end, '[R]emove unused i[m]ports')

  nmap('<leader>ca', function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end, '[C]ode [A]ction')

  nmap('gd', function()
    vim.api.nvim_feedkeys("mR", "n", false); -- mark as reference
    require('telescope.builtin').lsp_definitions()
  end, '[G]oto [D]efinition')
  nmap('gD', function()
    vim.api.nvim_feedkeys("mR", "n", false); -- mark as reference
    require('telescope.builtin').lsp_type_definitions()
  end, '[G]oto [D]efinition')
  nmap('gR', function()
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
  marksman = {},
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
    -- 'tsserver',
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
    if server_name == "tsserver" then
      server_name = "ts_ls"
    end
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

-- lspconfig.emmet_language_server.setup({})
-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()

-- my snippet
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- ts, tsx, jsx also loads this
ls.add_snippets("javascript", {
  s("menv", { t("import.meta.env.") }),
  s("penv", { t("process.env") })
})

ls.add_snippets("typescript", {
  s("cn", {
    t("constructor("),
    i(1), -- 第一次跳到這裡，進入 ()
    t({ ") {", "\t" }),
    i(2), -- 第二次跳到這裡，進入 {}
    t({ "", "}" })
  }),
  s("pu", { t("public ") }),
  s("pv", { t("private ") }),
  s("uo", { t("public readonly ") }),
  s("po", { t("private readonly ") }),
  s("rl", { t("readonly ") })
})

ls.add_snippets("javascriptreact", {
  s("com", {
    t({ "{/* " }),
    i(1, "Your comment here"),
    t({ " */}" })
  }),
})

ls.add_snippets("typescriptreact", {
  s("com", {
    t({ "{/* " }),
    i(1, "Your comment here"),
    t({ " */}" })
  }),
})

luasnip.config.setup {}
luasnip.filetype_extend('typescript', { 'javascript' })
luasnip.filetype_extend('typescriptreact', { 'javascript' })
luasnip.filetype_extend('javascriptreact', { 'javascript', 'typescript' })


-- The line beneath this is called `modeline`. See `:help modeline`

-- vim: ts=2 sts=2 sw=2 et

-- my Remap
-- remap H and L for motion
vim.api.nvim_set_keymap('n', 'H', '^', { noremap = true })
vim.api.nvim_set_keymap('n', 'L', '$', { noremap = true })


vim.opt.timeoutlen = 2000 -- allow longer wait time for leader key
vim.opt.swapfile = false

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
-- vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<cmd>q!<CR>")
vim.keymap.set("n", "<leader>ff", vim.lsp.buf.format)

-- for quickfix
vim.keymap.set("n", "<C-Up>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-Down>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader><Up>", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader><Down>", "<cmd>lprev<CR>zz")

-- replace the word that I am on
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set(
  "n",
  "<leader>ee",
  "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

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
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename) -- lsp rename
-- vim.keymap.set("n", "<leader>rn", ":IncRename ")

-- dap ui shortcut
vim.keymap.set("n", "<leader>dt", require('dapui').toggle)
vim.keymap.set("n", "<leader>dc", require("dap").continue)
vim.keymap.set("n", "<leader>do", require("dap").step_over)
vim.keymap.set("n", "<leader>di", require("dap").step_into)
vim.keymap.set("n", "<leader>dO", require("dap").step_out)
vim.keymap.set("n", "<leader>dB", require("dap").step_back)
vim.keymap.set("n", "<leader>dr", require("dap").restart)
vim.keymap.set("n", "<leader>ds", require("dap").close) -- dap stop

require("codesnap").setup({
  mac_window_bar = false,
  watermark = ""
})


vim.keymap.set("n", "<leader>fml", function()
  vim.g.enable_spelunker_vim = 0; -- disable spelunker
  require("cellular-automaton").start_animation("make_it_rain");
end)

vim.keymap.set("n", "<leader>Do", "<cmd>DiffviewOpen<CR>")
vim.keymap.set("n", "<leader>Dc", "<cmd>DiffviewClose<CR>")
vim.keymap.set("n", "<leader>Dt", "<cmd>DiffviewToggleFiles<CR>")
vim.keymap.set("n", "<leader>Dh", "<cmd>DiffviewFileHistory<CR>")

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

-- toggle nvim cmp
vim.api.nvim_set_keymap('n', '<leader>tc', ':NvimCmpToggle<CR>', { noremap = true, silent = true })

-- dot lsp
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.dot" },
  callback = function()
    vim.lsp.start({
      name = "dot",
      cmd = { "dot-language-server", "--stdio" }
    })
  end,
})

local augroup = vim.api.nvim_create_augroup('markdown', {})
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.md',
  group = augroup,
  callback = function()
    -- only set conceal level to 2 in markdown files
    vim.opt.conceallevel = 2;
  end
})

vim.keymap.set('n', '<leader>tr', MiniTrailspace.trim) -- trim trailing space
vim.keymap.set("n", "<leader>ze", "<cmd>ZenMode<CR>")

-- format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = 'Format on Save',
  -- ts and tsx are handled in another autocmd
  callback = function()
    if vim.bo.filetype == "curl" then
      return
    end
    vim.lsp.buf.format()
  end,
})

-- curl.nvim
local curl = require("curl")
curl.setup({})

vim.keymap.set("n", "<leader>cc", function()
  curl.open_curl_tab()
end, { desc = "Open a curl tab scoped to the current working directory" })

vim.keymap.set("n", "<leader>co", function()
  curl.open_global_tab()
end, { desc = "Open a curl tab with gloabl scope" })

-- These commands will prompt you for a name for your collection
vim.keymap.set("n", "<leader>csc", function()
  curl.create_scoped_collection()
end, { desc = "Create or open a collection with a name from user input" })

vim.keymap.set("n", "<leader>cgc", function()
  curl.create_global_collection()
end, { desc = "Create or open a global collection with a name from user input" })

vim.keymap.set("n", "<leader>fsc", function()
  curl.pick_scoped_collection()
end, { desc = "Choose a scoped collection and open it" })

vim.keymap.set("n", "<leader>fgc", function()
  curl.pick_global_collection()
end, { desc = "Choose a global collection and open it" })

-- vim.api.nvim_set_keymap('n', '<C-a>', 'gg^vG$', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-y>', '<C-a>', { noremap = true })

-- todo-comment.nvim
vim.api.nvim_set_keymap(
  "n",
  "<leader>pc",
  ":TodoTelescope keywords=TODO,FIX<CR>",
  { noremap = true, silent = true }
)

vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next({ keywords = { "TODO", "FIX", "SECTION" } })
end, { desc = "Next TODO/FIX comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev({ keywords = { "TODO", "FIX", "SECTION" } })
end, { desc = "Previous TODO/FIX comment" })

-- oil.nvim
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<C-b>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-", require('oil').toggle_float)
vim.keymap.set("n", "_", function()
  require('oil').open(vim.loop.cwd())
end) -- open cwd
