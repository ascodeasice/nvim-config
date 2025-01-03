-- set root to where .git or Makefile is
-- https://nanotipsforvim.prose.sh/automatically-set-the-cwd-without-rooter-plugin

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(ctx)
		local root = vim.fs.root(ctx.buf, {".git", "Makefile"})
		if root then vim.uv.chdir(root) end
	end,
})
