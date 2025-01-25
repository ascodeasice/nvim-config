require('core.options') -- Vim options
require('core.keymaps')
require('core.autocmds')

-- plugins managed with lazy.nvim
require('plugins')


local function is_tmux_fullscreen()
  -- 使用 `tmux display-message` 來判斷是否全螢幕
  local same_width = vim.fn.system("tmux display-message -p '#{?#{==:#{pane_width},#{window_width}},1,0}'")
  local same_height = vim.fn.system("tmux display-message -p '#{?#{==:#{pane_height},#{window_height}},1,0}'")
  -- 去除結尾換行符號
  same_width = same_width:gsub("%s+", "")
  same_height = same_height:gsub("%s+", "")
  -- 返回布林值
  return same_width == "1" and same_height == "1"
end


-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

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
      -- NOTE: this is a way to not ignore any file unless specified here
      find_command = {
        "rg",
        "--no-ignore",
        "--hidden",
        "--files",
        "-g",
        "!**/node_modules/*",
        "-g",
        "!**/.git/*",
        "-g",
        "!**/venv/*",
        "-g",
        "!**/.*cache/*",
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
    ensure_installed = { "bash", "c", "clojure", "commonlisp", "cpp", "css", "dockerfile", "fish", "gitignore", "go", "html", "javascript", "kotlin", "latex", "lua", "markdown", "python", "rust", "tsx", "typescript", "vim", "vimdoc", "vue", "yaml", "diff", "xml" },

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
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { require("recorder").recordingStatus, 'another_item',
      {
        "harpoon2",
        indicators = { "n", "e", "i", "o" },
        active_indicators = { "[n]", "[e]", "[i]", "[o]" },
        no_harpoon = "Harpoon not loaded",
      },
    },
    -- TODO: make it only show time and username
    lualine_y = { { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available } },
    lualine_z = { 'selectioncount', 'location' }
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

  nmap('<leader>tu', function()
    vim.lsp.buf.code_action {
      context = {
        only = { 'source.removeUnusedImports.ts' }
      },
      apply = true
    }
  end, '[R]emove unused i[m]ports')

  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  -- nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')


  -- See `:help K` for why this keymap
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

local mason_registry = require('mason-registry')
local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() ..
    '/node_modules/@vue/language-server'

local servers = {
  clangd = {},
  marksman = {},
  -- gopls = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  ts_ls = {
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    init_options = {
      plugins = {
        {
          name = '@vue/typescript-plugin',
          location = vue_language_server_path,
          languages = { 'vue' },
        },
      },
    },
  },
  volar = {},
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
    -- 'ruff_lsp',
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
      init_options = (servers[server_name] or {}).init_options,
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

-- lspconfig.ruff_lsp.setup {
--   init_options = {
--     settings = {
--       -- Any extra CLI arguments for `ruff` go here.
--       args = {},
--     }
--   }
-- }
--
require("lspconfig")["pyright"].setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        diagnosticSeverityOverrides = {
          reportUnusedExpression = "none",
        },
      },
    },
  },
})


lspconfig.jdtls.setup {}

-- NOTE: this is needed for kotlin ls
lspconfig.kotlin_language_server.setup({
  init_options = {
    storagePath = require('lspconfig/util').path.join(vim.env.XDG_DATA_HOME, "nvim-data"),
  },
})

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
local f = ls.function_node
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

ls.add_snippets("markdown", {
  -- action tag
  s("do", t("`do` ")),
  s("plan", t("`plan` ")),
  s("write", t("`write` ")),
  s("find", t("`find` ")),
  s("read", t("`read` ")),
  -- date tag
  s("dt", {
    t("`"),
    f(function() return os.date("%Y-%m-%d") end, {}),
    i(1),
    t("` "),
  }),
  -- project tag, wikilink of current file
  s("pt", {
    t("[["),
    f(function()
      return vim.fn.expand("%:t:r") -- current file base name
    end, {}),
    t("]] "),
  }),
  -- wikilink
  s("wl", {
    t("[["),
    i(1),
    t("]] "),
  }),
  -- inline code, easier to type than code, less possible to get wrong snippet
  s("in", {
    t("`"),
    i(1),
    t("` "),
  }),
  -- gtd contexts
  s("an", {
    t("`@anywhere` ")
  }),
  s("out", {
    t("`@out"),
    i(1),
    t("` ")
  }),
  s("vi", {
    t("`@video` ")
  }),
  s("as", {
    t("`@async` ")
  }),
})

ls.add_snippets("python", {
  -- for enumerate
  s("fe", {
    t("for "), i(1, "i"), t(", "), i(2, "val"), t(" in enumerate("), i(3, "arr"), t("):"),
    t({ "", "    " }), i(4, "print(i, val)")
  })
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

vim.keymap.set("n", "<leader>hi", ":set hlsearch!<CR>", { silent = true })
-- remaps
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set({ "n", "x" }, "K", "%", { remap = true })
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
vim.keymap.set("n", "<C-f>", function()
    vim.lsp.buf.format()
    vim.api.nvim_command('write')
  end,
  { desc = "Format and save" })

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

-- smarter gx, forward seeking url, if not found, select all url inside buffer with menu
vim.keymap.set("n", "gx", function()
  require("various-textobjs").url()
  local foundURL = vim.fn.mode():find("v")
  if foundURL then
    vim.cmd.normal('"zy')
    local url = vim.fn.getreg("z")
    vim.ui.open(url)
  else
    -- find all URLs in buffer
    local urlPattern = require("various-textobjs.charwise-textobjs").urlPattern
    local bufText = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    local urls = {}
    for url in bufText:gmatch(urlPattern) do
      table.insert(urls, url)
    end
    if #urls == 0 then return end

    -- select one, use a plugin like dressing.nvim for nicer UI for
    -- `vim.ui.select`
    vim.ui.select(urls, { prompt = "Select URL:" }, function(choice)
      if choice then vim.ui.open(choice) end
    end)
  end
end, { desc = "URL Opener" })

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
vim.keymap.set("n", "<leader>ds", require("dap").close)            -- dap stop
vim.keymap.set("n", "<leader>dv", '<cmd>DapVirtualTextToggle<CR>') -- dap stop

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

-- return the max fold level of the buffer (for now doing the opposite and folding incrementally is unbounded)
-- Also jarring if you start folding incrementally after opening all folds
local function max_level()
  -- return vim.wo.foldlevel -- find a way for this to return max fold level
  return 0
end

---Set the fold level to the provided value and store it locally to the buffer
---@param num integer the fold level to set
local function set_fold(num)
  -- vim.w.ufo_foldlevel = math.min(math.max(0, num), max_level()) -- when max_level is implemneted properly
  vim.b.ufo_foldlevel = math.max(0, num)
  require("ufo").closeFoldsWith(vim.b.ufo_foldlevel)
end

---Shift the current fold level by the provided amount
---@param dir number positive or negative number to add to the current fold level to shift it
local shift_fold = function(dir) set_fold((vim.b.ufo_foldlevel or max_level()) + dir) end

-- when max_level is implemented properly
-- vim.keymap.set("n", "zR", function() set_win_fold(max_level()) end, { desc = "Open all folds" })
vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })

vim.keymap.set("n", "zM", function() set_fold(0) end, { desc = "Close all folds" })

vim.keymap.set("n", "zr", function() shift_fold(vim.v.count == 0 and 1 or vim.v.count) end, { desc = "Fold less" })

vim.keymap.set("n", "zm", function() shift_fold(-(vim.v.count == 0 and 1 or vim.v.count)) end, { desc = "Fold more" })

-- next and prev fold
vim.api.nvim_set_keymap('n', 'z<Up>', 'zk', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'z<Down>', 'zj', { noremap = true, silent = true })

-- disable auto completion in telescope

-- nvim-ts-autotag
require('nvim-ts-autotag').setup({
  opts = {
    -- Defaults
    enable_close = true,         -- Auto close tags
    enable_rename = true,        -- Auto rename pairs of tags
    enable_close_on_slash = true -- Auto close on trailing </
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

vim.keymap.set('n', '<leader>tr', MiniTrailspace.trim) -- trim trailing space

-- format on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   desc = 'Format on Save',
--   -- ts and tsx are handled in another autocmd
--   callback = function()
--     if vim.bo.filetype == "curl" then
--       return
--     end
--     vim.lsp.buf.format()
--   end,
-- })
--
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
vim.keymap.set("n", "<leader>-", require('oil').toggle_float)
vim.keymap.set("n", "_", function()
  require('oil').open(vim.loop.cwd())
end) -- open cwd


-- SECTION: my keymap
vim.keymap.set('n', '<leader>sa', 'ggVG', { desc = "select all" })

-- SECTION: image.nvim

-- NOTE: must use the branch that allows toggle image to use this keymap

vim.keymap.set("n", "<leader>ti", function()
  local image = require('image')
  if image.is_enabled() then
    image.disable()
  else
    image.enable()
  end
end, {})

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


-- map go and gi to jump list
vim.api.nvim_set_keymap('n', 'go', '<C-o>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gi', '<C-i>', { noremap = true, silent = true })

-- do not open binary files

local function xdg_open()
  -- Get the current buffer number before opening the file
  local prev_buf = vim.fn.bufnr('%')

  -- Get the full path of the current file
  local fn = vim.fn.expand('%:p')

  -- Open the file using xdg-open
  vim.fn.jobstart('xdg-open "' .. fn .. '"')

  -- Echo a message
  vim.api.nvim_echo({ { string.format("Opening file: %s", fn) }, { type = "" } }, false, {})

  -- Switch back to the previous buffer
  if vim.fn.buflisted(prev_buf) == 1 then
    vim.api.nvim_set_current_buf(prev_buf)
  end

  -- Optionally close the current buffer if you want
  vim.api.nvim_buf_delete(0, { force = true })
end

-- Open binary files with the default application
local bin_files = vim.api.nvim_create_augroup("binFiles", { clear = true })

-- open those with image.nvim
-- "jpg", "jpeg", "webp", "png",
local file_types = { "pdf", "doc", "docx", "gif", "mkv", "mp3", "mp4", "webm", "xls", "xlsx", "xopp", "pptx", "ppt",
  "wav", "rar",
  "jpg", "jpeg", "webp", "png",
}

for _, ext in ipairs(file_types) do
  vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
    pattern = "*." .. ext,
    group = bin_files,
    callback = xdg_open
  })
end

-- SECTION: refactoring.nvim

vim.keymap.set("x", "<leader>rf", function() require('refactoring').refactor('Extract Function') end,
  { desc = 'Extract Function' })
vim.keymap.set("x", "<leader>rF", function() require('refactoring').refactor('Extract Function To File') end,
  { desc = 'Extract Function To File' })
vim.keymap.set("x", "<leader>rv", function() require('refactoring').refactor('Extract Variable') end,
  { desc = 'Extract Variable' })
vim.keymap.set("n", "<leader>rI", function() require('refactoring').refactor('Inline Function') end,
  { desc = 'Inline Function' })
vim.keymap.set({ "n", "x" }, "<leader>ri", function() require('refactoring').refactor('Inline Variable') end,
  { desc = 'Inline Variable' })
-- Use in visual mode if normal is not working

-- prompt for a refactor to apply when the remap is triggered
vim.keymap.set(
  { "n", "x" },
  "<leader>rr",
  function() require('refactoring').select_refactor() end,
  { desc = "Select refactor method" }
)
-- Note that not all refactor support both normal and visual mode

-- SECTION: dial.nvim

vim.keymap.set("n", "<C-a>", function()
  require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
  require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("n", "g<C-a>", function()
  require("dial.map").manipulate("increment", "gnormal")
end)
vim.keymap.set("n", "g<C-x>", function()
  require("dial.map").manipulate("decrement", "gnormal")
end)
vim.keymap.set("v", "<C-a>", function()
  require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("v", "<C-x>", function()
  require("dial.map").manipulate("decrement", "visual")
end)
vim.keymap.set("v", "g<C-a>", function()
  require("dial.map").manipulate("increment", "gvisual")
end)
vim.keymap.set("v", "g<C-x>", function()
  require("dial.map").manipulate("decrement", "gvisual")
end)

local augend = require("dial.augend")

require("dial.config").augends:register_group {
  default = {
    -- uppercase hex number (0x1A1A, 0xEEFE, etc.)
    augend.constant.new {
      elements = { "and", "or" },
      word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
      cyclic = true, -- "or" is incremented into "and".
    },
    augend.constant.new {
      elements = { "&&", "||" },
      word = false,
      cyclic = true,
    },
    augend.constant.new {
      elements = { "dev", "prod" },
      word = true,
      cyclic = true,
      preserve_case = true
    },
    augend.constant.new {
      elements = { "let", "const" },
      word = true,
      cyclic = true,
    },
    augend.constant.new {
      elements = { "true", "false" },
      word = true,
      cyclic = true,
      preserve_case = true
    },
    augend.constant.new {
      elements = { "up", "down" },
      word = true,
      cyclic = true,
      preserve_case = true
    },
    augend.constant.new {
      elements = { "left", "right" },
      word = true,
      cyclic = true,
      preserve_case = true
    },
    augend.constant.new {
      elements = { "top", "bottom" },
      word = true,
      cyclic = true,
      preserve_case = true
    },
    augend.constant.new {
      elements = { "yes", "no" },
      word = true,
      cyclic = true,
      preserve_case = true
    },
    augend.constant.new {
      elements = { "prev", "next" },
      word = true,
      cyclic = true,
      preserve_case = true
    },
    augend.constant.new {
      elements = { "plan", "find", "read", "do", "write" },
      word = true,
      cyclic = true,
      preserve_case = true
    },
    augend.constant.alias.bool,
    augend.integer.alias.decimal,
    augend.integer.alias.binary,
    augend.integer.alias.octal,
    augend.integer.alias.hex,
    augend.semver.alias.semver,
    augend.date.alias["%Y/%m/%d"],
    augend.date.alias["%Y-%m-%d"],
    augend.date.alias["%m/%d"],
    augend.date.alias["%H:%M"],
    augend.date.alias["%Y年%-m月%-d日"],
  },
}

vim.api.nvim_set_keymap("n", "<leader>wt", "<cmd>set wrap!<CR>", { desc = "Wrap toggle" })
vim.api.nvim_set_keymap("n", "<esc>", "<cmd>set wrap!<CR>", { desc = "Wrap toggle" })

-- SECTION: obsidian.nvim


vim.api.nvim_set_keymap("n", "<leader>ow", "<cmd>lua CreateNextSevenDaysNotes()<CR>",
  { noremap = true, desc = "Obsidian notes for next 7 days" })

function CreateNextSevenDaysNotes()
  local start_day = 1 -- 從明天開始
  local days = 6      -- 生成未來六天的筆記
  for i = start_day, start_day + days - 1 do
    vim.cmd(string.format("ObsidianToday +%d", i))
  end
end

vim.api.nvim_set_keymap("n", "<leader>oy", "<cmd>ObsidianToday -1<CR>",
  { noremap = true, desc = "Obsidian yesterday without working day" })
vim.api.nvim_set_keymap("n", "<leader>ot", "<cmd>ObsidianToday<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>om", "<cmd>ObsidianToday +1<CR>",
  { noremap = true, desc = "Obsidian tomorrow without working day" })
vim.api.nvim_set_keymap("n", "<leader>on", "<cmd>ObsidianNew<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>og", "<cmd>ObsidianTags<CR>", { noremap = true })
vim.api.nvim_set_keymap("v", "<leader>oe", ":ObsidianExtractNote<CR>", { noremap = true }) -- NOTE: <cmd> and : are different
vim.api.nvim_set_keymap("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>oN", "<cmd>ObsidianNewFromTemplate<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>oT", "<cmd>ObsidianTemplate<CR>", { noremap = true })

-- SECTION: diagram.nvim

-- toggle diagram render for feature/toggle branch
vim.api.nvim_set_keymap("n", "<leader>tD", "<cmd>Diagram toggle<CR>", { noremap = true })

-- SECTION: molten.nvim

-- I find auto open annoying, keep in mind setting this option will require setting
-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
vim.g.molten_auto_open_output = false

-- this guide will be using image.nvim
-- Don't forget to setup and install the plugin if you want to view image outputs
vim.g.molten_image_provider = "image.nvim"

-- optional, I like wrapping. works for virt text and the output window
vim.g.molten_wrap_output = true

-- Output as virtual text. Allows outputs to always be shown, works with images, but can
-- be buggy with longer images
vim.g.molten_virt_text_output = true

-- this will make it so the output shows up below the \`\`\` cell delimiter
vim.g.molten_virt_lines_off_by_1 = true

vim.api.nvim_create_autocmd("User", {
  pattern = "MoltenInitPost",
  callback = function()
    vim.keymap.set("n", "<localleader>me", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
    vim.keymap.set("n", "<localleader>mo", ":noautocmd MoltenEnterOutput<CR>",
      { desc = "open output window", silent = true })
    vim.keymap.set("n", "<localleader>mr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
    vim.keymap.set("v", "<localleader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv",
      { desc = "execute visual selection", silent = true })
    vim.keymap.set("n", "<localleader>mh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
    vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })

    -- if you work with html outputs:
    vim.keymap.set("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })
  end,
})

-- SECTION: lsp remap
-- NOTE: move lsp remap outside of on_attach so that quarto.nvim can use them even if no lsp is attached through lspconfig

vim.keymap.set("n", '<leader>ca', function()
  vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
end, { desc = '[C]ode [A]ction' })

vim.keymap.set("n", 'gd', function()
  vim.api.nvim_feedkeys("mR", "n", false); -- mark as reference
  require('telescope.builtin').lsp_definitions()
end, { desc = '[G]oto [D]efinition' })

vim.keymap.set("n", 'gD', function()
  vim.api.nvim_feedkeys("mR", "n", false); -- mark as reference
  require('telescope.builtin').lsp_type_definitions()
end, { desc = '[G]oto type [D]efinition' })
vim.keymap.set("n", 'gR', function()
  vim.api.nvim_feedkeys("mD", "n", false); -- mark as definition
  require('telescope.builtin').lsp_references()
end, { desc = '[G]oto [R]eferences' })
vim.keymap.set("n", 'gh', vim.lsp.buf.hover, { desc = 'Hover Documentation' })

-- SECTION quarto.nvim

local runner = require("quarto.runner")
-- these did not overlap with refactoring.nvim
vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
  runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })

-- Provide a command to create a blank new Python notebook
-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
-- if you use another language than Python, you should change it in the template.
local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

local function new_notebook(filename)
  local path = filename .. ".ipynb"
  local file = io.open(path, "w")
  if file then
    file:write(default_notebook)
    file:close()
    vim.cmd("edit " .. path)
  else
    print("Error: Could not open new notebook file for writing.")
  end
end

vim.api.nvim_create_user_command('NewNotebook', function(opts)
  new_notebook(opts.args)
end, {
  nargs = 1,
  complete = 'file'
})

-- SECTION: nabla.nvim

vim.keymap.set('n', '<leader>nt', function()
  -- enable_virt would set nowrap
  local old_wrap = vim.wo.wrap
  require('nabla').toggle_virt()
  vim.wo.wrap = old_wrap
end, { desc = 'Nable Toggle' })

-- SECTION: zen-mode.nvim

vim.keymap.set('n', '<M-z>', '<cmd>ZenMode<CR>')

-- for some reason, they do not work in visual mode
vim.keymap.set({ 'n', 'v' }, '<M-down>', function()
  require('mini.move').move_line('down')
end)

vim.keymap.set({ 'n', 'v' }, '<M-up>', function()
  require('mini.move').move_line('up')
end)

-- make text bold
vim.keymap.set({ 'n' }, '<C-b>', 'siwO', { remap = true })
vim.keymap.set({ 'v' }, '<C-b>', 'sO', { remap = true })
-- make text link with url in register
vim.keymap.set({ 'n' }, '<C-l>', 'siwlEP', { remap = true })
vim.keymap.set({ 'v' }, '<C-l>', 'slf)P', { remap = true })


-- autocmd for exit full screen
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    -- is full screen in nvim, and not opened from yazi (which will have another fullscreen hook)
    if os.getenv("NVIM_FULL_SCREEN") and is_tmux_fullscreen() then
      os.execute("tmux resize-pane -Z") -- try to exit full screen of tmux
    end
  end,
})

-- sticky yank
local cursorPreYank
vim.keymap.set({ "n", "x" }, "y", function()
  cursorPreYank = vim.api.nvim_win_get_cursor(0)
  return "y"
end, { expr = true })
vim.keymap.set("n", "Y", function()
  cursorPreYank = vim.api.nvim_win_get_cursor(0)
  return "y$"
end, { expr = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" and cursorPreYank then
      vim.api.nvim_win_set_cursor(0, cursorPreYank)
    end
  end,
})


vim.keymap.set("n", "<leader>u", function()
  local col = vim.fn.col(".")
  local line_end = vim.fn.col("$") - 1

  -- if cursor is in line end, do not move right
  if col == line_end then
    vim.cmd("normal! mzblgueh~`z")
  else
    vim.cmd("normal! mzlblgueh~`z")
  end
end) -- switch case of word


-- SECTION: remember folding
-- https://nanotipsforvim.prose.sh/better-folding-(part-3)--remember-your-folds-across-sessions
local function remember(mode)
  -- avoid complications with some special filetypes
  local ignoredFts = { "TelescopePrompt", "DressingSelect", "DressingInput", "toggleterm", "gitcommit", "replacer",
    "harpoon", "help", "qf" }
  if vim.tbl_contains(ignoredFts, vim.bo.filetype) or vim.bo.buftype ~= "" or not vim.bo.modifiable then return end

  if mode == "save" then
    vim.cmd.mkview(1)
  else
    pcall(function() vim.cmd.loadview(1) end) -- pcall, since new files have no view yet
  end
end

vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "?*",
  callback = function() remember("save") end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "?*",
  callback = function() remember("load") end,
})

-- SECTION: fold back after searching is done
-- https://nanotipsforvim.prose.sh/better-folding-(part-1)--pause-folds-while-searching
vim.opt.foldopen:remove { "search" } -- no auto-open when searching, since the following snippet does that better

vim.keymap.set("n", "/", "zn/", { desc = "Search & Pause Folds" })
vim.on_key(function(char)
  local key = vim.fn.keytrans(char)
  local searchKeys = { "n", "N", "*", "#", "/", "?" }
  local searchConfirmed = (key == "<CR>" and vim.fn.getcmdtype():find("[/?]") ~= nil)
  if not (searchConfirmed or vim.fn.mode() == "n") then return end
  local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, key))

  local pauseFold = vim.opt.foldenable:get() and searchKeyUsed
  local unpauseFold = not (vim.opt.foldenable:get()) and not searchKeyUsed
  if pauseFold then
    vim.opt.foldenable = false
  elseif unpauseFold then
    vim.opt.foldenable = true
    vim.cmd.normal("zv") -- after closing folds, keep the *current* fold open
  end
end, vim.api.nvim_create_namespace("auto_pause_folds"))

vim.keymap.set(
  "n",
  "<C-t>",
  require('obfuscate').toggle,
  { desc = "Toggle Obfuscate", noremap = true, silent = true }
)
