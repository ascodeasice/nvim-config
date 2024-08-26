local null_ls = require("null-ls")

local opts = {
	sources = {
		require("none-ls-shellcheck.diagnostics"),
		require("none-ls-shellcheck.code_actions"),
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.black,
		null_ls.builtins.diagnostics.mypy,
		null_ls.builtins.formatting.shfmt.with({ filetypes = { "sh", "zsh" } }),
		null_ls.builtins.formatting.prettierd,
	}
}
return opts
