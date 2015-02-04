local directions = {
	["north"] = {
		["west"] = "left",
		["east"] = "right",
	},
	["east"] = {
		["north"] = "left",
		["south"] = "right",
	},
	["south"] = {
		["east"] = "left",
		["west"] = "right",
	},
	["west"] = {
		["south"] = "left",
		["north"] = "right",
	},

}
local function navigate(facing, heading)
	if facing == heading then
		return "forward"
	else
		return directions[facing][heading]
	end
end

local function handle_maze()
	local start, a, b, c, d, e = text:match([[You will start out facing%s+(.-).%s+You should go%s+(.-),%s+(.-),%s+(.-),%s+(.-),%s+(.-),%s+and then, assuming you haven't messed up somewhere]])

	local actions = {}
	actions[1] = navigate(start, a)
	actions[2] = navigate(a, b)
	actions[3] = navigate(b, c)
	actions[4] = navigate(c, d)
	actions[5] = navigate(d, e)
	ascension["zone.gameinform.maze"] = actions
	ascension["zone.gameinform.maze_step"] = 0
end

add_processor("/choice.php", function()
	if adventure_title ~= "GameInformPowerDailyPro Walkthru" then return end

	if text:match([[The final challenge of%s-.-%s-will be a maze.]]) then
		handle_maze()
	end

	ascension["zone.gameinform.door"] = text:match([[My advice to you is to choose the (.-) door.]])
end)

add_processor("/choice.php", function()
	if adventure_title ~= "A Gracious Maze" then return end

	if text:match([[you're going around in circles]]) then
		ascension["zone.gameinform.maze_step"] = 0
		return
	end

	if text:match([[Finally, you come to]]) then
		ascension["zone.gameinform.maze"] = nil
		return
	end

	if ascension["zone.gameinform.maze"] == nil then
		return
	end

	ascension["zone.gameinform.maze_step"] = ascension["zone.gameinform.maze_step"] + 1
end)

add_printer("/choice.php", function()
	if adventure_title ~= "A Gracious Maze" then return end

	if ascension["zone.gameinform.maze"] == nil then
		return
	end

	local step = ascension["zone.gameinform.maze_step"]
	if step == 0 then
		return
	end
	local action = ascension["zone.gameinform.maze"][step]

	text = text:gsub([[(<input class=button type=submit value="Go ]] .. action .. [[">)]], [[%1 <span style="color: green">{ walkthru path }</span>]])
end)

add_printer("/choice.php", function()
	if adventure_title ~= "When You're a Stranger" then return end

	local action = ascension["zone.gameinform.door"]
	if action == nil then return end
	text = text:gsub([[value="Unlock the ]] .. action .. [[ door">]], [[%1 <span style="color: green;">{ choose me }]])
end)