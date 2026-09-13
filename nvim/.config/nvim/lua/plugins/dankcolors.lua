return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#181825',
				base01 = '#181825',
				base02 = '#8d9599',
				base03 = '#8d9599',
				base04 = '#e8f3f7',
				base05 = '#f8fcff',
				base06 = '#f8fcff',
				base07 = '#f8fcff',
				base08 = '#ff9dbd',
				base09 = '#ff9dbd',
				base0A = '#90ddff',
				base0B = '#a4ffae',
				base0C = '#c4edff',
				base0D = '#90ddff',
				base0E = '#a4e3ff',
				base0F = '#a4e3ff',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#8d9599',
				fg = '#f8fcff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#90ddff',
				fg = '#181825',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#8d9599' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#c4edff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#a4e3ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#90ddff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#90ddff',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#c4edff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#a4ffae',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#e8f3f7' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#e8f3f7' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#8d9599',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
