require('core.options') -- Vim options
require('core.keymaps')
require('core.autocmds')

-- plugins managed with lazy.nvim
require('plugins')

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
    ensure_installed = { 'html', 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'markdown', "kotlin" },

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

  nmap('<leader>tm', function()
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

vim.keymap.set("n", "<leader>hh", ":set hlsearch!<CR>")
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


-- SECTION: my keymap
vim.keymap.set('n', '<leader>sa', 'ggVG', { desc = "select all" })

-- SECTION: image.nvim

-- NOTE: must use the branch that allows toggle image to use this keymap

-- vim.keymap.set("n", "<leader>ti", function()
--   local image = require('image')
--   if image.is_enabled() then
--     image.disable()
--   else
--     image.enable()
--   end
-- end, {})
--
vim.keymap.set('n', '<leader>td', require('render-markdown.api').toggle)

-- SECTION: lasterisk.nvim

vim.keymap.set('n', '*', function() require("lasterisk").search() end)
vim.keymap.set('n', 'g*', function() require("lasterisk").search({ is_whole = false }) end)
vim.keymap.set('x', 'g*', function() require("lasterisk").search({ is_whole = false }) end)

-- SECTION: follow-md-links.nvim
-- NOTE: <CR> is mapped into opening files in markdown
-- Go back to where the file is from
vim.keymap.set('n', '<bs>', ':edit #<cr>', { silent = true })

-- SECTION: treesitter-context
vim.keymap.set("n", "[x", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

-- 將 Ctrl + , 映射到跳轉列表中的前一個位置 (Ctrl + o)
vim.api.nvim_set_keymap('n', '<C-,>', '<C-o>', { noremap = true, silent = true })

-- 將 Ctrl + . 映射到跳轉列表中的下一個位置 (Ctrl + i)
vim.api.nvim_set_keymap('n', '<C-.>', '<C-i>', { noremap = true, silent = true })


-- SECTION: portal.nvim
vim.keymap.set("n", "go", "<cmd>Portal jumplist backward<cr>")
vim.keymap.set("n", "gi", "<cmd>Portal jumplist forward<cr>")
