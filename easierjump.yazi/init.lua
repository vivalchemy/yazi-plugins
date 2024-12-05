local SINGLE_LABLES = {
	"a",
	"s",
	"d",
	"f",
	"g",
	"h",
	"j",
	"k",
	"l",
	";",
}

-- Generate NORMAL_DOUBLE_LABLES
local NORMAL_DOUBLE_LABLES = {}
for _, first in ipairs(SINGLE_LABLES) do
	for _, second in ipairs(SINGLE_LABLES) do
		table.insert(NORMAL_DOUBLE_LABLES, first .. second)
	end
end

-- Generate INPUT_KEY
local INPUT_KEY = {}
for _, label in ipairs(SINGLE_LABLES) do
	table.insert(INPUT_KEY, label)
end

table.insert(INPUT_KEY, "z")
table.insert(INPUT_KEY, "<Esc>")
table.insert(INPUT_KEY, "<Backspace>")

-- Generate SINGLE_POS
local SINGLE_POS = {}
for i, label in ipairs(SINGLE_LABLES) do
	SINGLE_POS[label] = i
end

-- Generate DOUBLE_POS
local DOUBLE_POS = {}
for i, label in ipairs(NORMAL_DOUBLE_LABLES) do
	DOUBLE_POS[label] = i
end

local INPUT_CANDS = {}
for _, key in ipairs(INPUT_KEY) do
	table.insert(INPUT_CANDS, { on = key })
end

local init = ya.sync(function(state)
	local folder = cx.active.current
	state.file_pos = {}
	local first_key_of_lable = {}

	state.current_num = #folder.window

	for i, file in ipairs(folder.window) do
		state.file_pos[tostring(file.url)] = i
		if state.current_num > #SINGLE_LABLES then
			first_key_of_lable[NORMAL_DOUBLE_LABLES[i]:sub(1, 1)] = ""
		end
	end

	return state.current_num, folder.cursor, folder.offset, first_key_of_lable
end)

local toggle_ui = ya.sync(function(st)
	if st.entity_lable_id or st.status_ej_id then
		Entity:children_remove(st.entity_lable_id)
		Status:children_remove(st.status_ej_id)
		st.entity_lable_id = nil
		st.status_ej_id = nil
		Entity._inc = Entity._inc - 1
		Status._inc = Status._inc - 1
		ya.render()
		return
	end

	local entity_lable = function(self)
		local file = self._file
		local pos = st.file_pos[tostring(file.url)]
		if not pos then
			return ui.Line({})
		elseif st.current_num > #SINGLE_LABLES then
			if st.double_first_key ~= nil and NORMAL_DOUBLE_LABLES[pos]:sub(1, 1) == st.double_first_key then
				return ui.Line({
					ui.Span(NORMAL_DOUBLE_LABLES[pos]:sub(1, 1)):fg(st.opt_first_key_fg),
					ui.Span(NORMAL_DOUBLE_LABLES[pos]:sub(2, 2) .. " "):fg(st.opt_icon_fg),
				})
			else
				return ui.Line({ ui.Span(NORMAL_DOUBLE_LABLES[pos] .. " "):fg(st.opt_icon_fg) })
			end
		else
			return ui.Line({ ui.Span(SINGLE_LABLES[pos] .. " "):fg(st.opt_icon_fg) })
		end
	end
	st.entity_lable_id = Entity:children_add(entity_lable, 2001)

	local status_ej = function(self)
		local style = self:style()
		return ui.Line({
			ui.Span("[EJ] "):style(style),
		})
	end
	st.status_ej_id = Status:children_add(status_ej, 2001, Status.LEFT)

	ya.render()
end)

local update_double_first_key = ya.sync(function(state, str)
	state.double_first_key = str
end)

local hovered_state = ya.sync(function(st)
	return {
		hovered_url = tostring(cx.active.current.hovered.url),
		is_dir = tostring(cx.active.current.hovered.cha.is_dir),
	}
end)

local function read_input_todo(current_num, cursor, offset, first_key_of_lable)
	local cand = nil
	local key
	local key_num_count = 0
	local pos
	local double_key

	while true do
		cand = ya.which({ cands = INPUT_CANDS, silent = true })

		if cand == nil then
			goto nextkey
		end

		if INPUT_KEY[cand] == "<Esc>" or INPUT_KEY[cand] == "z" then
			return nil, nil
		end

		if INPUT_KEY[cand] == "<Backspace>" and key_num_count == 0 then
			return "..", "true" -- a hacky way of using cd
		end

		if current_num <= #SINGLE_LABLES then
			key = INPUT_KEY[cand]
			pos = SINGLE_POS[key]
			if pos == nil or pos > current_num then
				goto nextkey
			else
				ya.manager_emit("arrow", { pos - cursor - 1 + offset })
				local st = hovered_state()
				return st.hovered_url, st.is_dir
			end
		end

		if INPUT_KEY[cand] == "<Backspace>" and current_num > #SINGLE_LABLES then
			key_num_count = 0
			update_double_first_key(nil)
			goto nextkey
		end

		if key_num_count == 0 and current_num > #SINGLE_LABLES then
			key = INPUT_KEY[cand]
			if first_key_of_lable[key] then
				key_num_count = key_num_count + 1
				update_double_first_key(key)
			else
				key_num_count = 0
			end
			goto nextkey
		end

		if key_num_count == 1 and current_num > #SINGLE_LABLES then
			double_key = key .. INPUT_KEY[cand]
			pos = DOUBLE_POS[double_key]
			if pos == nil or pos > current_num then
				goto nextkey
			else
				ya.manager_emit("arrow", { pos - cursor - 1 + offset })
				local st = hovered_state()
				return st.hovered_url, st.is_dir
			end
		end

		::nextkey::
	end
end

local set_opts_default = ya.sync(function(state)
	if state.opt_icon_fg == nil then
		state.opt_icon_fg = "#ffffff"
	end
	if state.opt_first_key_fg == nil then
		state.opt_first_key_fg = "#dc143c"
	end
end)

local clear_state_str = ya.sync(function(state)
	state.file_pos = nil
	state.current_num = nil
	state.double_first_key = nil
end)

local function entry(_, _)
	set_opts_default()

	while true do
		local current_num, cursor, offset, first_key_of_lable = init()

		if not current_num or current_num == 0 then
			break
		end

		toggle_ui()

		local hovered_url, is_dir = read_input_todo(current_num, cursor, offset, first_key_of_lable)
		if is_dir then
			if is_dir == "false" then
				ya.manager_emit("open", { "--hovered" })
				break
			else
				ya.manager_emit("cd", { hovered_url })
				clear_state_str()
			end
		else
			toggle_ui()
			break
		end
		toggle_ui()
	end
end

local function setup(state, opts)
	-- Save the user configuration to the plugin's state
	if opts ~= nil and opts.icon_fg ~= nil then
		state.opt_icon_fg = opts.icon_fg
	end
	if opts ~= nil and opts.first_key_fg ~= nil then
		state.opt_first_key_fg = opts.first_key_fg
	end
end

return {
	entry = entry,
	setup = setup,
}
