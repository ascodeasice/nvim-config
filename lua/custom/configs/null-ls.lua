local null_ls = require("null-ls")

local opts = {
	sources = {
		require("none-ls-shellcheck.diagnostics"),
		require("none-ls-shellcheck.code_actions"),
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.black,
		null_ls.builtins.diagnostics.mypy.with({
			extra_args = function()
				local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX") or "/usr"
				return { "--python-executable", virtual .. "/bin/python3" }
			end,
		}),
		null_ls.builtins.formatting.shfmt.with({ filetypes = { "sh", "zsh" } }),
		null_ls.builtins.formatting.prettierd,
		null_ls.builtins.diagnostics.actionlint,
		null_ls.builtins.diagnostics.markdownlint,
	}
}
return opts
