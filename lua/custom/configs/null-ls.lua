local null_ls = require("null-ls")

local opts = {
	sources = {
		null_ls.builtins.diagnostics.pylint.with({
			diagnostics_postprocess = function(diagnostic)
				diagnostic.code = diagnostic.message_id
			end,
		}),
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.black,
		null_ls.builtins.diagnostics.mypy,
	}
}
return opts