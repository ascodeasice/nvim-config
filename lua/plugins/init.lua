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
		'nvim-treesitter/nvim-treesitter-context',
		config = function()
			require('treesitter-context').setup({
				mode = 'topline'
			})
		end
	},
	{
		"gaoDean/autolist.nvim",
		ft = {
			"markdown",
			"text",
			"tex",
			"plaintex",
			"norg",
		},
		config = function()
			require("autolist").setup()

			vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
			vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
			-- NOTE: not working
			vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
			vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
			vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
			vim.keymap.set("n", "<leader>ct", "<cmd>AutolistToggleCheckbox<cr><CR>") -- checkbox toggle
			vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")

			-- cycle list types with dot-repeat
			vim.keymap.set("n", "<leader>cn", require("autolist").cycle_next_dr, { expr = true })
			vim.keymap.set("n", "<leader>cp", require("autolist").cycle_prev_dr, { expr = true })

			-- functions to recalculate list on edit
			vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>")
			vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
			vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
			vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>")
		end,
	},
	'jghauser/follow-md-links.nvim',
	{
		'rapan931/lasterisk.nvim'
	},
	{
		"HakonHarnes/img-clip.nvim",
		event = "VeryLazy",
		opts = {
			-- add options here
			-- or leave it empty to use the default settings
		},
		keys = {
			-- suggested keymap
			{ "<leader>P", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
		},
	},
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
							-- 如果輸入是空的，則返回，不進行排序
							if delimiter == '' then
								return
							end
							-- 處理分隔符兩邊的空白
							opts.split_patterns = { '%s*' .. vim.pesc(delimiter) .. '%s*' }
						end

						-- 設置排序比較函數，數字按大小排列
						opts.compare_fun = function(a, b)
							local num_a = tonumber(a)
							local num_b = tonumber(b)

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
						-- enable again after https://github.com/3rd/image.nvim/issues/174 is fixed
						enabled = false,
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
				-- icons = { "󰬺", "󰬻", "󰬼", "󰬽", "󰬾", "󰬿", },
				icons = { "", "", "", "", "", "", },
				-- left_pad = 1,
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
					add = 'S',        -- Add surrounding in Normal and Visual modes
					delete = 'ds',    -- Delete surrounding
					find = 'Sf',      -- Find surrounding (to the right)
					find_left = 'SF', -- Find surrounding (to the left)
					highlight = 'SH', -- Highlight surrounding
					replace = 'cs',   -- Replace surrounding
					update_n_lines = 'Sn', -- Update `n_lines`

					suffix_last = '', -- Suffix to search with "prev" method
					suffix_next = '', -- Suffix to search with "next" method
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
								require("oil").set_columns({ "icon", "permissions",
									"size", "mtime" })
							else
								require("oil").set_columns({ "icon" })
							end
						end,
					},
					["gi"] = {
						desc = "Toggle icon",
						callback = function()
							icon = not icon
							if icon then
								require("oil").set_columns({ "icon" })
							else
								require("oil").set_columns({})
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
				-- NOTE: unicode characters causes crash
				-- NOTE: seems like it cannot work with symbols
				additions = {
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
	{
		"mistricky/codesnap.nvim",
		keys = {
			{ "<leader>cc", "<cmd>CodeSnap<cr>",     mode = "x", desc = "Save selected code snapshot into clipboard" },
			{ "<leader>cs", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
		},
		build = "make build_generator",
		opts = {
			save_path = "~/Pictures",
			has_breadcrumbs = false,
		},
	},
	{ "mtdl9/vim-log-highlighting" },
	{
		"okuuva/auto-save.nvim",
		cmd = "ASToggle",     -- optional for lazy loading on command
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
				dim = true           -- dim all other characters if set to true (recommended!)
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
				block = 'gbc', -- <C-/> control slash
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

}, {})
