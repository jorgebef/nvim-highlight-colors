local colors = require("nvim-highlight-colors.color.utils")

local M = {}

local deprecated = {
	cmd = {"HighlightColorsOn", "HighlightColorsOff", "HighlightColorsToggle"}
}

function M.get_last_row_index()
	return vim.fn.line('$')
end

function M.get_win_visible_rows(winid)
	return vim.api.nvim_win_call(
		winid,
		function()
			return {
				vim.fn.line('w0'),
				vim.fn.line('w$')
			}
		end
	)
end

local function create_highlight_name(color_value)
	return string.gsub(color_value, "#", ""):gsub("[(),%s%.-/%%=:\"']+", "")
end

function M.create_highlight(ns_id, row, start_column, end_column, color, should_colorize_foreground, custom_colors)
	local highlight_group = create_highlight_name(color)
	local color_value = colors.get_color_value(color, 2, custom_colors)
	if color_value == nil then
		return
	end

	if should_colorize_foreground then
		pcall(vim.api.nvim_set_hl, 0, highlight_group, {
            		fg = color_value
        	})
	else
		local foreground_color = colors.get_foreground_color_from_hex_color(color_value)
		pcall(vim.api.nvim_set_hl, 0, highlight_group, {
            		fg = foreground_color,
            		bg = color_value
        	})
	end
	vim.api.nvim_buf_add_highlight(
		0,
		ns_id,
		highlight_group,
		row + 1,
		start_column,
		end_column
	)
end

function M.deprecate()
	for _, cmd in ipairs(deprecated.cmd) do
		vim.api.nvim_create_user_command(cmd,
			function()
				print("The command \'" .. cmd .. "\' has been deprecated! Please use the new syntax: HighlightColors On/Off/Toggle")
			end,
			{ nargs = 0, desc = "Deprecated command" .. cmd })
	end
end

return M
