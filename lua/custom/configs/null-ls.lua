local null_ls = require("null-ls")

local opts = {
	sources = {
		null_ls.buitins.diagnostics.mypy,
		null_ls.buitins.diagnostics.ruff,
	}
}
return opts
