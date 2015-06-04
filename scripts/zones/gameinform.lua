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
	session["zone.gameinform.maze"] = actions
	session["zone.gameinform.maze_step"] = 0
end

add_processor("/choice.php", function()
	if adventure_title ~= "GameInformPowerDailyPro Walkthru" then return end

	if text:match([[The final challenge of%s-.-%s-will be a maze.]]) then
		handle_maze()
	end

	session["zone.gameinform.door"] = text:match([[My advice to you is to choose the (.-) door.]])
	session["zone.gameinform.riddle"] = text:match([[The answer is "(.-)".]])
	session["zone.gameinform.passage"] = text:match([[secret passage .- (candlesticks)]]) or text:match([[secret passage .- (bookshelves)]]) or text:match([[secret passage .- (fireplace)]])
end)

add_processor("/choice.php", function()
	if adventure_title ~= "A Gracious Maze" then return end

	if text:match([[you're going around in circles]]) then
		session["zone.gameinform.maze_step"] = 0
		return
	end

	if text:match([[Finally, you come to]]) then
		session["zone.gameinform.maze"] = nil
		return
	end

	if session["zone.gameinform.maze"] == nil then
		return
	end

	session["zone.gameinform.maze_step"] = session["zone.gameinform.maze_step"] + 1
end)

add_choice_text("A Gracious Maze", function() -- choice adventure number: 502
	if session["zone.gameinform.maze"] == nil then
		return {}
	end

	local step = session["zone.gameinform.maze_step"]
	if step == 0 then
		return {}
	end
	local action = session["zone.gameinform.maze"][step]

	return {
		["Go left"] = {text="left",good_choice = (action == "left")},
		["Go forward"] = {text="forward",good_choice = (action == "forward")},
		["Go right"] = {text="right",good_choice = (action == "right")},
	}
end)

add_choice_text("Sphinx For the Memories", function()
	local action = session["zone.gameinform.riddle"]
	return {
		["&quot;Time?&quot;"] = {text="time",good_choice = (action == "time")},
		["&quot;A mirror?&quot;"] = {text="mirror",good_choice = (action == "forward")},
		["&quot;Hope?&quot;"] = {text="hope",good_choice = (action == "right")},
	}
end)

add_choice_text("It's a Place Where Books Are Free", function()
	local action = session["zone.gameinform.passage"]
	return {
		["Check the bookshelves"] = {text="bookshelves",good_choice = (action == "bookshelves")},
		["Move the candlesticks"] = {text="candlesticks",good_choice = (action == "candlesticks")},
		["Search the fireplace"] = {text="fireplace",good_choice = (action == "fireplace")},
	}
end)

add_printer("/choice.php", function()
	if adventure_title ~= "When You're a Stranger" then return end

	local action = session["zone.gameinform.door"]
	if action == nil then return end
	text = text:gsub([[value="Unlock the ]] .. action .. [[ door">]], [[%1 <span style="color: green;">{ choose me }]])
end)

-- The answer is ".+".
-- The trick here is to .*!
-- add_printer("/choice.php", function()
-- 	if adventure_title ~= "Think or Thwim") then return end

-- 	local action = session["zone.gameinform.swim"]
-- 	if action == nil then return end

-- 	text = text:gsub([[<input class=button type=submit value="Throw your broccoli into the water"]])
-- end)

