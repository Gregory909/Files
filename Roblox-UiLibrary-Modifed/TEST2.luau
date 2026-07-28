--[[
	Vanish Hub | Remastered Universal
	Это новая версия универсального скрипта для множество шутеров, простых лобби или просто большой хаб для универсального использования! Отдельна от Main чтобы не ломать логику скрипта!
]]
pcall(function()
	do
		local c = game:GetService("UserInputService").WindowFocused:Connect(function() end)
		local d = game:GetService("UserInputService").WindowFocusReleased:Connect(function() end)
		if typeof(c) ~= "RBXScriptConnection" or typeof(d) ~= "RBXScriptConnection" then
			game:shutdown()
		end
		c:Disconnect()
		d:Disconnect()
	end
	local a, b, c, d =
		3, {
			{
				"AssetType",
				"FaceMakeup",
			},
			{
				"AssetType",
				"LipMakeup",
			},
			{
				"AssetType",
				"EyeMakeup",
			},
			{
				"UserInputState",
				"None",
			},
			{
				"VideoSampleSize",
				"Small",
			},
			{
				"VideoSampleSize",
				"Medium",
			},
			{
				"VideoSampleSize",
				"Large",
			},
			{
				"VideoSampleSize",
				"Full",
			},
			{
				"TextInputType",
				"NewPassword",
			},
			{
				"TextInputType",
				"NewPasswordShown",
			},
			{
				"ExperienceAuthScope",
				"DefaultScope",
			},
			{
				"ExperienceAuthScope",
				"CreatorAssetsCreate",
			},
		}, 0, {}

	for e, f in ipairs(b) do
		local g, h = f[1], f[2]
		local i = pcall(function()
			local i = Enum[g][h]
		end)

		if not i then
			c = c + 1

			table.insert(d, g .. "." .. h)
		end
	end

	if c >= a then
		game:shutdown()
	end
end)
if _G.Vanish_Universal_Loaded or _G.Vanish_Universal_Loading then
	print("[Vanish]: You are already loading or has loaded script!")
	return
end
_G.Vanish_Universal_Loaded = true
if ((identifyexecutor()):lower()):find("solara") then
	print("[Vanish]: " .. getexecutorname() .. " Exploit doesnt supports this script. Try to use another exploit!")
	return
end
if
	not (
		type(isfile) == "function"
		and type(isfolder) == "function"
		and type(makefolder) == "function"
		and type(writefile) == "function"
		and type(delfile) == "function"
		and type(delfolder) == "function"
	)
then
	print(
		"[Vanish]: Your exploit '"
			.. getexecutorname()
			.. "' doesnt support System Folder UNC! Try to use another exploit!"
	)
	return
end
if not require or not request then
	print(
		"[Vanish]: Your exploit '"
			.. getexecutorname()
			.. "' doesnt support (require or request)! Try to use another exploit!"
	)
	return
end
if not game:IsLoaded() then
	print("[Vanish]: Game is begging loaded, waiting for it...")
	game.Loaded:Wait()
end
print("[Vanish]: Starting loading script assets...")

-- BYPASS ANTICHEATS!!!!
local bypassed_anticheats = {
	["Adonis"] = false,
	["Rivals"] = false,
	["BAC"] = false,
}

local function smartWait()
	local startTime = tick()
	local maxWait = 12 + 5

	while tick() - startTime < 12 do
		local adonisReady = false
		pcall(function()
			for _, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
				if v.Name:lower():find("admin") then
					adonisReady = true
					break
				end
			end
		end)

		if adonisReady and tick() - startTime > 8 then
			task.wait(3)
			break
		end

		task.wait(1)
	end
end

smartWait()

local oldMeta = {}
local metaProtected = false

pcall(function()
	local mt = getrawmetatable(game)
	setreadonly(mt, false)

	oldMeta.__index = mt.__index
	oldMeta.__newindex = mt.__newindex
	oldMeta.__namecall = mt.__namecall

	metaProtected = true
	setreadonly(mt, true)
end)

pcall(function()
	local realGetGC = getgc
	local lastGCCall = 0
	local callCount = 0
	local maxCallsPerSecond = 5

	getgc = function(...)
		local now = tick()
		callCount = callCount + 1

		if now - lastGCCall >= 1 then
			callCount = 0
			lastGCCall = now
		end

		if callCount > maxCallsPerSecond then
			task.wait(math.random(50, 150) / 1000)
		end

		lastGCCall = tick()
		return realGetGC(...)
	end
end)

pcall(function()
	local originalGetCallingScript = getcallingscript

	getcallingscript = function()
		local calling = originalGetCallingScript()

		if calling == nil then
			local success, result = pcall(function()
				return game:GetService("StarterPlayer").StarterPlayerScripts
			end)
			if success and result then
				return result
			end
		end

		return calling
	end
end)

task.spawn(function()
	task.wait(0.1)

	local function safeGetGC()
		local success, result = pcall(function()
			return getgc(true)
		end)
		return success and result or {}
	end

	local objects = safeGetGC()
	local checked = 0
	local maxCheck = 80

	for _, v in next, objects do
		checked = checked + 1
		if checked > maxCheck then
			break
		end

		if typeof(v) == "table" then
			local detected = rawget(v, "Detected")
			local rlocked = rawget(v, "RLocked")

			if detected and typeof(detected) == "function" and rlocked then
				local hookSuccess = pcall(function()
					local oldDetected = detected
					hookfunction(detected, function(action, info, crash)
						if action == "_" and info == "_" and crash == false then
							return oldDetected(action, info, crash)
						end
						return task.wait(9e9)
					end)
				end)
				break
			end
		end

		if checked % 10 == 0 then
			task.wait(0.01)
		end
	end
end)

local bypassSuccess = plr or metaProtected

task.wait(0.5)

if bypassed_anticheats.Adonis then
	print("[Vanish] Vanish Universal has been protected from Adonis AntiCheat!")
elseif bypassed_anticheats.Rivals then
	print("[Vanish] Vanish Universal has been protected from Rivals AntiCheat!")
elseif bypassed_anticheats.Rivals then
	print("[Vanish] Vanish Universal has been protected from Rivals AntiCheat!")
end

local TABLE_MAIN = {
	LocalServices = {
		["Players"] = game:GetService("Players"),
		["Workspace"] = game:GetService("Workspace"),
		["RunService"] = game:GetService("RunService"),
		["UserInputService"] = game:GetService("UserInputService"),
		["HttpService"] = game:GetService("HttpService"),
		["ReplicatedStorage"] = game:GetService("ReplicatedStorage"),
		["CoreGui"] = game:GetService("CoreGui"),
		["Lighting"] = game:GetService("Lighting"),
		["CollectionService"] = game:GetService("CollectionService"),
		["Debris"] = game:GetService("Debris"),
		["TweenService"] = game:GetService("TweenService"),
		["PathfindingService"] = game:GetService("PathfindingService"),
	},
	Locals = {},
	Main_Features = {
		Version = "1.2hf",
		Enaled_AntiDex = false,
		Enabled_AntiRSPY = false,
		Enabled_AdminControl = false,
		Allowed_Usage = {
			Users = true,
			Testers = true,
		},
		Roles = {
			Owners = {
				3029063746,
				9094062967,
				10133766492,
			},
			Developers = {
				7426644606,
				8056018968,
				10470964695,
			},
			Testers = {
				7768245791,
				8996412029,
			},
		},
		Script_Icon = "rbxassetid://137827218584732",
		Mobile = function()
			return not game:GetService("UserInputService").KeyboardEnabled
				and game:GetService("UserInputService").TouchEnabled
		end,
	},
	DiscordServices = {
		Invite = "taq5ZQsN",
		WebhookChat = "https://webhook.lewisakura.moe/api/webhooks/1470372730527551673/-5C8fv8KKYl2Ivw1WKFyxt1GoKmKd-FXzxyTFePqb-CBfBsWUOQMFVgIwBvhEQtOI7O4",
		WebhookPrompt = "https://webhook.lewisakura.moe/api/webhooks/1470391708813365473/fQXJPuRQKsULX_5-BIks6oENBSWkD9zzYjpuy9BAPFbXRigDGfdMqBQKH5WUkuCoc5YD",
		WebhookLog = "https://webhook.lewisakura.moe/api/webhooks/1470374191340720201/0B98uBjr9BA5K8JdEDHXLdmqoQ2nCJxWiZ9fBPv-CCpNUosrfyapsFDaSVynouBa-OMj",
		ChannelPrompt = "1458064029024129190",
		ChannelLog = "1458064029024129190",
		ChannelChat = "1422168196949086289",
		T = "5dc5a8482cc23f7e8cbc3c6624913dbe3e7cd3c9",
	},
	WebsocketServer = {
		Server = "https://dixrtdflqv.onrender.com/",
		WSLink = "wss://dixrtdflqv.onrender.com/ws",
	},
	GitHub = {
		Owner = "Gregory909",
		Repo = "Api",
		Branch = "main",
		e = "GHSAT0AAAAAAD44NDQ77Q3HRH4RC3RSIAZ62STORDQ",
	},
	ChangeLogs = game:HttpGet("https://raw.githubusercontent.com/Gregory909/Files/refs/heads/main/changelogs.txt"),
	LocalsLib = {
		Locals = {},
		Set = function(self, key, value)
			self.Locals[key] = value
		end,
		Get = function(self, key)
			return self.Locals[key]
		end,
		Remove = function(self, key)
			self.Locals[key] = nil
		end,
		Clear = function(self)
			self.Locals = {}
		end,
	},
	ConnectionLib = {
		Connects = {},
		Connect = function(self, event, func)
			local connection = event:Connect(func)
			table.insert(self.Connects, connection)
			return connection
		end,
		Disconnect = function(self, connection)
			for i, conn in pairs(self.Connects) do
				if conn == connection then
					conn:Disconnect()
					table.remove(self.Connects, i)
					break
				end
			end
		end,
		DisconnectAll = function(self)
			for _, connection in pairs(self.Connects) do
				connection:Disconnect()
			end
			self.Connects = {}
		end,
	},
	SpecialConnections = {},
	SpecialValues = {},
	AdminCommands = {},
}
TABLE_MAIN.Players_Lib = {
	GetPlayers = function(self, includeLocalPlayer)
		local players = {}
		local localPlayer = self:GetLP()
		for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
			if includeLocalPlayer or plr ~= localPlayer then
				table.insert(players, plr)
			end
		end
		return players
	end,
	GetList = function(self, includeLocalPlayer)
		local jf = {}
		for _, plr in ipairs(self:GetPlayers(includeLocalPlayer == true)) do
			table.insert(jf, plr.Name)
		end
		table.sort(jf, function(a, b)
			return tostring(a):lower() < tostring(b):lower()
		end)
		return jf
	end,
	HasPlayerOption = function(self, dropdown, name)
		if not dropdown or type(dropdown.Options) ~= "table" then
			return false
		end
		for _, option in ipairs(dropdown.Options) do
			if tostring(option) == tostring(name) then
				return true
			end
		end
		return false
	end,
	SyncPlayerDropdown = function(self, dropdown)
		if not dropdown then
			return
		end
		local activeNames = {}
		for _, name in ipairs(self:GetList()) do
			activeNames[name] = true
			if dropdown.AddOption and not self:HasPlayerOption(dropdown, name) then
				dropdown:AddOption(name)
			end
		end
		if dropdown.RemoveOption and type(dropdown.Options) == "table" then
			local currentOptions = {}
			for _, option in ipairs(dropdown.Options) do
				table.insert(currentOptions, option)
			end
			for _, option in ipairs(currentOptions) do
				local optionName = tostring(option)
				if optionName ~= "Select" and optionName ~= "None" and not activeNames[optionName] then
					dropdown:RemoveOption(optionName)
				end
			end
		end
	end,
	SyncPlayerDropdowns = function(self, featureList)
		for _, dropdown in pairs(featureList or {}) do
			self:SyncPlayerDropdown(dropdown)
		end
	end,
	BindPlayerDropdowns = function(self, featureList)
		if TABLE_MAIN.ConnectionLib.Connects.PlayerList_Added then
			TABLE_MAIN.ConnectionLib.Connects.PlayerList_Added:Disconnect()
			TABLE_MAIN.ConnectionLib.Connects.PlayerList_Added = nil
		end
		if TABLE_MAIN.ConnectionLib.Connects.PlayerList_Removed then
			TABLE_MAIN.ConnectionLib.Connects.PlayerList_Removed:Disconnect()
			TABLE_MAIN.ConnectionLib.Connects.PlayerList_Removed = nil
		end
		self:SyncPlayerDropdowns(featureList)
		local playersService = game:GetService("Players")
		local statsService = game:GetService("Stats")
		local TweenService = game:GetService("TweenService")
		local Lighting = game:GetService("Lighting")
		local UserInputService = game:GetService("UserInputService")
		local ReflectionService = game:GetService("ReflectionService")
		TABLE_MAIN.ConnectionLib.Connects.PlayerList_Added = playersService.PlayerAdded:Connect(function(plr)
			if plr == self:GetLP() then
				return
			end
			for _, dropdown in pairs(featureList or {}) do
				if dropdown and dropdown.AddOption and not self:HasPlayerOption(dropdown, plr.Name) then
					dropdown:AddOption(plr.Name)
				end
			end
		end)
		TABLE_MAIN.ConnectionLib.Connects.PlayerList_Removed = playersService.PlayerRemoving:Connect(function(plr)
			for _, dropdown in pairs(featureList or {}) do
				if dropdown and dropdown.RemoveOption then
					dropdown:RemoveOption(plr.Name)
				end
			end
		end)
	end,
	SearchPlayer = function(query)
		local players = game:GetService("Players"):GetPlayers()
		local found = {}
		for _, plr in pairs(players) do
			if string.find(plr.Name:lower(), query:lower()) then
				table.insert(found, plr)
			end
		end
		return found
	end,
	SearchPlayerByUserId = function(userId)
		local plr = game:GetService("Players"):GetPlayerByUserId(userId)
		return plr
	end,
	GetLP = function()
		return game.Players.LocalPlayer
	end,
	GetPlayerCharacter = function(plr)
		return plr and plr.Character
	end,
	GetPlayerHumanoid = function(character)
		return character and character:FindFirstChildOfClass("Humanoid")
	end,
	GetPlayerHumParts = function(character)
		if not character then
			return nil
		end
		return character and character:FindFirstChild("HumanoidRootPart")
	end,
}

local services = TABLE_MAIN.LocalServices
local Players = services.Players
local lp = Players.LocalPlayer
local HttpService = services.HttpService
local UserInputService = services.UserInputService
local PathfindingService = services.PathfindingService
TABLE_MAIN.EncodeLuaValue = function(value, depth)
	depth = depth or 0
	local valueType = type(value)
	if valueType == "string" then
		return string.format("%q", value)
	end
	if valueType == "number" or valueType == "boolean" then
		return tostring(value)
	end
	if valueType ~= "table" then
		return "nil"
	end

	local count = 0
	local maxIndex = 0
	local isArray = true
	for k, _ in pairs(value) do
		count += 1
		if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
			isArray = false
			break
		end
		maxIndex = math.max(maxIndex, k)
	end
	if isArray and maxIndex ~= count then
		isArray = false
	end

	if count == 0 then
		return "{}"
	end

	local indent = string.rep("    ", depth)
	local nextIndent = string.rep("    ", depth + 1)
	local out = {}
	if isArray then
		for i = 1, maxIndex do
			table.insert(out, nextIndent .. TABLE_MAIN.EncodeLuaValue(value[i], depth + 1))
		end
	else
		local keys = {}
		for k, _ in pairs(value) do
			table.insert(keys, k)
		end
		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)
		for _, k in ipairs(keys) do
			local keyChunk
			if type(k) == "string" and k:match("^[%a_][%w_]*$") then
				keyChunk = k
			else
				keyChunk = "[" .. TABLE_MAIN.EncodeLuaValue(k, depth + 1) .. "]"
			end
			table.insert(
				out,
				string.format("%s%s = %s", nextIndent, keyChunk, TABLE_MAIN.EncodeLuaValue(value[k], depth + 1))
			)
		end
	end

	return "{\n" .. table.concat(out, ",\n") .. "\n" .. indent .. "}"
end
TABLE_MAIN.Others_Services = {
	Notification = "BocusLuke",
	GetUserIP = function()
		return (HttpService:JSONDecode(game:HttpGet("https://ipwho.is/"))).ip
	end,
	GetJoinLink = function()
		local jb = game.JobId
		if not jb then
			return "No Link!"
		end
		return "https://www.roblox.com/games/start?placeId=" .. game.PlaceId .. "&jobId=" .. jb
	end,
	GetFILE = function(file)
		local resolvedPath = TABLE_MAIN.Others_Services.ResolveRepositoryPath(file)
		local owner = "Gregory909"
		local repo = "Api"
		local branch = "main"
		local success, result = pcall(function()
			local code = game:HttpGet(
				("https://codeberg.org/%s/%s/raw/branch/%s/%s"):format(owner, repo, branch, resolvedPath),
				true
			)
			if not code or code == "" then
				error("Empty response from Codeberg")
			end
			return loadstring(code)()
		end)

		if not success then
			warn("[Vanish]: Failed to load Codeberg file: " .. tostring(resolvedPath) .. " | " .. tostring(result))
		end
		return result
	end,
	SetFILE = function(path, cont)
		local req = request or http_request or http and http.request or syn and syn.request
		if typeof(req) ~= "function" then
			return
		end
		local resolvedPath = TABLE_MAIN.Others_Services.ResolveRepositoryPath(path)
		local owner = "Gregory909"
		local repo = "Api"
		local branch = "main"
		local apiUrl = ("https://codeberg.org/api/v1/repos/%s/%s/contents/%s"):format(
			owner,
			repo,
			HttpService:UrlEncode(resolvedPath)
		)
		local headers = {
			["Content-Type"] = "application/json",
			Authorization = "token " .. tostring(TABLE_MAIN.DiscordServices.T or ""),
		}
		local sha
		pcall(function()
			local response = req({
				Url = apiUrl .. "?ref=" .. HttpService:UrlEncode(branch),
				Method = "GET",
				Headers = headers,
			})
			if response and response.Body and response.Body ~= "" then
				local body = HttpService:JSONDecode(response.Body)
				sha = body and body.sha
			end
		end)
		local payload = {
			message = "Updated File!",
			content = crypt.base64encode(cont),
			branch = branch,
		}
		if sha then
			payload.sha = sha
		end
		req({
			Url = apiUrl,
			Method = if sha then "PUT" else "POST",
			Headers = headers,
			Body = HttpService:JSONEncode(payload),
		})
	end,
	GetMainModContent = function(data)
		local template =
			"local API = {};\n\nlocal HardBans = %s;\nlocal IPBans = %s;\nlocal Warnings = %s;\n\nfunction API:GetHardBans()\n    return HardBans;\nend;\n\nfunction API:GetIPBans()\n    return IPBans;\nend;\n\nfunction API:GetWarnings()\n    return Warnings;\nend;\n\nfunction API:IsHardBanned(plr)\n    return table.find(HardBans, tostring(plr.UserId)) ~= nil;\nend;\n\nfunction API:HasWarning(userId)\n    return Warnings[tostring(userId)] ~= nil;\nend;\n\nfunction API:IsIPBanned(ip)\n    return table.find(IPBans, tostring(ip)) ~= nil;\nend;\n\nreturn API;\n"
		local code = string.format(
			template,
			TABLE_MAIN.EncodeLuaValue(data.HardBans or {}),
			TABLE_MAIN.EncodeLuaValue(data.IPBans or {}),
			TABLE_MAIN.EncodeLuaValue(data.Warnings or {})
		)
		return code
	end,
	GetChatModContentunction = function(data)
		local template =
			"local API = {};\n\nlocal ChatModeration = %s;\n\nfunction API:GetChatModeration()\n    return ChatModeration;\nend;\n\nfunction API:GetUserState(userId)\n    return ChatModeration[tostring(userId)] or {};\nend;\n\nfunction API:IsMuted(userId)\n    local state = API:GetUserState(userId)\n    local mutedUntil = tonumber(state.MutedUntil) or 0\n    return mutedUntil > os.time(), mutedUntil\nend;\n\nreturn API;\n"
		local code = string.format(template, TABLE_MAIN.EncodeLuaValue(data.ChatModeration or {}))
		return code
	end,
}
TABLE_MAIN.Others_Services.UpdateWarnUser = function(type, plr, reason, moderator)
	if type == "Add" then
		local file = TABLE_MAIN.Others_Services.GetFILE("'/_.lua")
		local data_warns = file:GetWarnings()
		local data_bans = file:GetHardBans()
		local data_ipbans = file:GetIPBans()
		data_warns[tostring(plr.UserId)] = {
			Reason = reason,
			Moderator = moderator,
		}
		local final_code = TABLE_MAIN.Others_Services.GetMainModContent({
			HardBans = data_bans,
			IPBans = data_ipbans,
			Warnings = data_warns,
		})
		TABLE_MAIN.Others_Services.SetFILE("'/_.lua", final_code)
	elseif type == "Remove" then
		local file = TABLE_MAIN.Others_Services.GetFILE("'/_.lua")
		local data_warns = file:GetWarnings()
		local data_bans = file:GetHardBans()
		local data_ipbans = file:GetIPBans()
		data_warns[tostring(plr.UserId)] = nil
		local final_code = TABLE_MAIN.Others_Services.GetMainModContent({
			HardBans = data_bans,
			IPBans = data_ipbans,
			Warnings = data_warns,
		})
		TABLE_MAIN.Others_Services.SetFILE("'/_.lua", final_code)
	end
end
TABLE_MAIN.Others_Services.UpdateBanUsers = function(type, bantype, plr, ip)
	if type == "Add" then
		local file = TABLE_MAIN.Others_Services.GetFILE("'/_.lua")
		local data_warns = file:GetWarnings()
		local data_bans = file:GetHardBans()
		local data_ipbans = file:GetIPBans()
		if bantype == "UserId" then
			table.insert(data_bans, tostring(plr.UserId))
		elseif bantype == "IP" then
			table.insert(data_bans, ip)
		end
		local final_code = TABLE_MAIN.Others_Services.GetMainModContent({
			HardBans = data_bans,
			IPBans = data_ipbans,
			Warnings = data_warns,
		})
		TABLE_MAIN.Others_Services.SetFILE("'/_.lua")
	elseif type == "Remove" then
		local file = TABLE_MAIN.Others_Services.GetFILE("'/_.lua")
		local data_warns = file:GetWarnings()
		local data_bans = file:GetHardBans()
		local data_ipbans = file:GetIPBans()
		if bantype == "UserId" then
			data_bans[tostring(plr.UserId)] = nil
		elseif bantype == "IP" then
			data_bans[ip] = nil
		end
		local final_code = TABLE_MAIN.Others_Services.GetMainModContent({
			HardBans = data_bans,
			IPBans = data_ipbans,
			Warnings = data_warns,
		})
		TABLE_MAIN.Others_Services.SetFILE("'/_.lua", final_code)
	end
end
TABLE_MAIN.Others_Services.GetChatModerationData = function()
	local file = TABLE_MAIN.Others_Services.GetFILE("'/_2.lua")
	if type(file) ~= "table" then
		if not TABLE_MAIN.Others_Services._Configuration2Bootstrap then
			TABLE_MAIN.Others_Services._Configuration2Bootstrap = true
			pcall(function()
				local defaultCode = TABLE_MAIN.Others_Services.GetChatModContent()
				TABLE_MAIN.Others_Services.SetFILE("'/_2.lua", defaultCode)
			end)
		end
		return {}
	end
	if type(file.GetChatModeration) == "function" then
		local ok, data = pcall(function()
			return file:GetChatModeration()
		end)
		if ok and type(data) == "table" then
			return data
		end
	end
	return {}
end
TABLE_MAIN.Others_Services.UpdateChatModerationUser = function(action, userId, state)
	local data = TABLE_MAIN.Others_Services.GetChatModerationData()
	local key = tostring(userId or "")
	if key == "" then
		return
	end
	if action == "Add" and type(state) == "table" then
		data[key] = state
	elseif action == "Remove" then
		data[key] = nil
	else
		return
	end
	local final_code = TABLE_MAIN.Others_Services.GetChatModContent()
	TABLE_MAIN.Others_Services.SetFILE("'/_2.lua", final_code)
end
TABLE_MAIN.AdminCommands.ban = function(args, plr)
	TABLE_MAIN.Others_Services.UpdateBanUsers("Add", args[3], lp, TABLE_MAIN.Others_Services.GetUserIP())
end
TABLE_MAIN.AdminCommands.unban = function(args, plr)
	TABLE_MAIN.Others_Services.UpdateBanUsers("Remove", args[3], lp, TABLE_MAIN.Others_Services.GetUserIP())
end
TABLE_MAIN.AdminCommands.fling = function(args, plr)
	local char = plr.Character
	if not char then
		return
	end
	local root = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChild("Humanoid")
	if not root or not humanoid then
		return
	end

	local savedState = {
		Anchored = root.Anchored,
		PlatformStand = humanoid.PlatformStand,
	}

	root.Anchored = false
	humanoid.PlatformStand = true

	task.spawn(function()
		local startTime = os.clock()
		while os.clock() - startTime < 0.3 do
			if not char or not char:IsDescendantOf(workspace) then
				break
			end
			root = char:FindFirstChild("HumanoidRootPart")
			if root then
				root.AssemblyLinearVelocity =
					Vector3.new(math.random(-150, 150), math.random(100, 200), math.random(-150, 150))
				root.AssemblyAngularVelocity =
					Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
			end
			task.wait()
		end

		if char and char:IsDescendantOf(workspace) then
			root = char:FindFirstChild("HumanoidRootPart")
			humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.PlatformStand = savedState.PlatformStand
			end
			if root then
				root.Anchored = savedState.Anchored
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end

		pcall(TABLE_MAIN.Players_Lib.FixVelocity)
	end)
end
TABLE_MAIN.AdminCommands.freeze = function(args, plr)
	local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	root.Anchored = true
end
TABLE_MAIN.AdminCommands.unfreeze = function(args, plr)
	local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	root.Anchored = false
end
TABLE_MAIN.AdminCommands.kill = function(args, plr)
	local char = plr.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.Health = 0
	end
end
TABLE_MAIN.AdminCommands.bring = function(args, plr)
	local charact = plr.Character
	if not charact then
		return
	end
	local target = GP(args[3])
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		charact.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
	end
end
TABLE_MAIN.AdminCommands.kick = function(args, plr)
	game:shutdown()
end
TABLE_MAIN.AdminCommands.warn = function(args, plr)
	TABLE_MAIN.Others_Services.UpdateWarnUser("Add", plr, args[3], args[4])
end
TABLE_MAIN.AdminCommands.detect = function(args, plr)
	if game.JobId == args[2] then
		local apiRequest = request or http_request or http and http.request or syn and syn.request
		if typeof(apiRequest) ~= "function" then
			return
		end
		apiRequest({
			Url = TABLE_MAIN.DiscordServices.WebhookPrompt,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode({
				content = ";send_detect " .. plr.Name,
			}),
		})
	end
end

function IsOwner(g)
	return table.find(TABLE_MAIN.Main_Features.Roles.Owners, g.UserId)
end
function IsVanishTeam(g)
	return table.find(TABLE_MAIN.Main_Features.Roles.Developers, g.UserId)
end
function IsTester(g)
	return table.find(TABLE_MAIN.Main_Features.Roles.Testers, g.UserId)
end
GP = function(name)
	return services.Players:FindFirstChild(name) or services.Players:GetPlayerByUserId(tonumber(name) or 0)
end
function get_character()
	return TABLE_MAIN.Players_Lib:GetLP().Character
end
function get_humanoid()
	return get_character() and get_character():FindFirstChild("Humanoid")
end
function get_humanoidrootpart()
	return get_character() and get_character():FindFirstChild("HumanoidRootPart")
		or get_character() and get_character():FindFirstChild("RootPart")
end

function set_collision(runtime, character, includeRoot, state)
	if state then
		if not character then
			return
		end
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if runtime.NoclipOriginalStates[part] == nil then
					runtime.NoclipOriginalStates[part] = {
						CanCollide = part.CanCollide,
						CastShadow = part.CastShadow,
					}
				end
				pcall(function()
					part.CanCollide = false
					part.CastShadow = false
				end)
			end
		end
	else
		for part, state in pairs(runtime.NoclipOriginalStates or {}) do
			if part and part.Parent then
				pcall(function()
					if type(state) == "table" then
						part.CanCollide = state.CanCollide
						part.CastShadow = state.CastShadow
					else
						part.CanCollide = state
						part.CastShadow = true
					end
				end)
			end
		end
		runtime.NoclipOriginalStates = {}
	end
end
function get_human_status()
	if get_humanoid() ~= nil then
		return (get_humanoid():GetState()).Name
	end
	return "NoDetect"
end
function TABLE_MAIN.AdminCommands:Handle(admin)
	if not TABLE_MAIN.Main_Features.Enabled_AdminControl then
		return
	end
	local ws
	local allowAdminCommands = admin == true
	local targetChannelId = tostring(TABLE_MAIN.DiscordServices.ChannelPrompt or "")
	local bridgeWsUrl = TABLE_MAIN.WebsocketServer.WSLink
	TABLE_MAIN.SpecialValues.vanishUsers = {}
	function ExecuteCmd(command, args, plr)
		local normalizedCommand = string.lower(tostring(command or ""))
		if TABLE_MAIN.AdminCommands[normalizedCommand] then
			TABLE_MAIN.AdminCommands[normalizedCommand](args, plr)
		end
	end
	function FormatCommand(content)
		local text = tostring(content or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if text == "" then
			return ""
		end
		local prefix = text:sub(1, 1)
		if prefix == ";" or prefix == "!" or prefix == "/" then
			text = text:sub(2)
		end
		return text:gsub("^%s+", ""):gsub("%s+$", "")
	end
	function ManageCommand(msg, content, tt)
		local normalizedContent = FormatCommand(content)
		if normalizedContent == "" then
			return
		end
		local args = string.split(normalizedContent, " ")
		local cmd = string.lower(tostring(args[1] or ""))
		local username = tostring(args[2] or "")
		local isBotMessage = msg.author and msg.author.bot == true
		if cmd == "send_detect" then
			if tt and isBotMessage and username ~= "" then
				if not TABLE_MAIN.ConnectionLib.Connects.Vanish_UserLeft then
					TABLE_MAIN.ConnectionLib.Connects.Vanish_UserLeft = Players.PlayerRemoving:Connect(function(plr)
						if plr.Name == username then
							if TABLE_MAIN.SpecialValues.vanishUsers[username] then
								TABLE_MAIN.SpecialValues.vanishUsers[username] = nil
							end
						end
					end)
				end
				if not TABLE_MAIN.SpecialValues.vanishUsers[username] then
					_ntf("plr '" .. username .. "' using Vanish!")
				end
				TABLE_MAIN.SpecialValues.vanishUsers[username] = true
			end
			return
		end
		if not allowAdminCommands then
			return
		end
		ExecuteCmd(cmd, args, GP(args[2]))
	end
	ws = WebSocket.connect(bridgeWsUrl)
	if not ws then
		return
	end
	if targetChannelId == "" or not ws then
		return
	end
	local sendFn = ws.Send or ws.send
	if typeof(sendFn) == "function" then
		pcall(
			sendFn,
			ws,
			services["HttpService"]:JSONEncode({
				type = "subscribe",
				channelIds = { targetChannelId },
			})
		)
	end
	ws.OnMessage:Connect(function(message)
		local ok, packet = pcall(game:GetService("HttpService").JSONDecode, HttpService, message)
		if not ok or typeof(packet) ~= "table" then
			warn("JSON decode error")
			return
		end
		if packet.type == "discord.ready" or packet.type == "ready" then
			if targetChannelId == "" or not ws then
				return
			end
			local sendFn = ws.Send or ws.send
			if typeof(sendFn) == "function" then
				pcall(
					sendFn,
					ws,
					services["HttpService"]:JSONEncode({
						type = "subscribe",
						channelIds = { targetChannelId },
					})
				)
			end
			return
		end
		if packet.type ~= "discord.message" then
			return
		end
		if tostring(packet.channelId or packet.channel_id or "") ~= targetChannelId then
			return
		end

		local msg = typeof(packet.message) == "table" and packet.message
			or {
				channel_id = tostring(packet.channelId or packet.channel_id or ""),
				content = tostring(packet.content or ""),
				author = {
					id = tostring(packet.authorId or ""),
					username = tostring(packet.username or "Unknown"),
					bot = packet.bot == true or packet.isBot == true,
				},
			}
		local author = typeof(msg.author) == "table" and msg.author or {}
		if author.bot == nil then
			author.bot = packet.bot == true or packet.isBot == true
		end
		if tostring(author.username or "") == "" then
			author.username = tostring(packet.username or "Unknown")
		end
		if tostring(author.id or "") == "" then
			author.id = tostring(packet.authorId or "")
		end
		msg.author = author
		msg.content = tostring(msg.content or packet.content or "")
		if tostring(msg.channel_id or "") == targetChannelId then
			ManageCommand(msg, msg.content, admin)
		end
	end)
	ws.OnClose:Connect(function()
		print("WebSocket has closed for some reasons!")
	end)
end
function TABLE_MAIN.Players_Lib:FixVelocity()
	local chara = TABLE_MAIN.Players_Lib:GetPlayerCharacter(TABLE_MAIN.Players_Lib:GetLP())
	if chara == nil then
		return
	end
	local hrp = TABLE_MAIN.Players_Lib:GetPlayerHumParts(chara)
	if hrp == nil then
		return
	end
	local humanoid = TABLE_MAIN.Players_Lib:GetPlayerHumanoid(chara)
	if humanoid == nil then
		return
	end
	hrp.Velocity = Vector3.zero
	hrp.RotVelocity = Vector3.zero
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	for _, obj in ipairs(hrp:GetChildren()) do
		if
			obj:IsA("BodyMover")
			or obj:IsA("VectorForce")
			or obj:IsA("AlignPosition")
			or obj:IsA("AlignOrientation")
			or obj:IsA("LinearVelocity")
			or obj:IsA("AngularVelocity")
		then
			obj:Destroy()
		end
	end
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	humanoid.PlatformStand = true
	humanoid.PlatformStand = false
end
local Universal_Features = {
	["Universal"] = {
		Working = true,
		Features = {
			["WalkSpeed Toggle"] = false,
			["WalkSpeed Value"] = 16,
			["JumpPower Toggle"] = false,
			["JumpPower Value"] = 50,
			["Fov Toggle"] = false,
			["Fov Value"] = 65,
			["Fly Toggle"] = false,
			["Fly Speed"] = 10,
			["Click Tp"] = false,
			Float = false,
			["Infinite Jump"] = false,
			Fling = false,
			Spinner = false,
			["Spin Power"] = 15,
			["Anti Fling"] = false,
			["Anti AFK"] = false,
			["Anti AFK Key"] = "RightShift",
			-- Aimbot
			["Aimbot Aim Part"] = "Head",
			["Aimbot FOV Color"] = Color3.fromRGB(255, 255, 255),
			["Aimbot FOV Thickness"] = 1,
			["Aimbot FOV Filled"] = false,
			["Aimbot FOV Sides"] = 60,
			["Aimbot Priority"] = "Closest to Mouse",
			["Aimbot Keybind"] = "F",
			["Aimbot Prediction"] = 0,
			["Aimbot Visible Check"] = false,
			["Toggle Triggerbot"] = false,
			["Triggerbot Delay"] = 0,
			["Silent Aim Keybind"] = "V",
			["Silent Aim Wall Check"] = false,
			["Silent Aim Team Check"] = false,

			-- ESP
			["Esp Font"] = "BuilderSansBold",
			["Esp Text Size"] = 1,
			["ESP Show Distance"] = false,
			["ESP Show Health"] = false,
			["ESP Show Name"] = true,
			["Highlight Color"] = Color3.fromRGB(255, 0, 0),
			["Highlight Transparency"] = 0.5,
			["Tracer Color"] = Color3.fromRGB(255, 255, 255),
			["Tracer Start Position"] = "Bottom Screen",
			["ESP Box"] = false,
			["Box Type"] = "2D",
			["Box Color"] = Color3.fromRGB(255, 255, 255),
			["ESP Max Distance"] = 1000,
			["ESP Attachment Part"] = "Head",
			["Esp Teammates"] = false,
			["Esp Enemies"] = false,
			["Highlight Teammates"] = false,
			["Highlight Enemies"] = false,
			["Tracers Teammates"] = false,
			["Tracers  Enemies"] = false,
			["Default Esp Color"] = Color3.fromRGB(225, 0, 0),
			["Teammate Color"] = Color3.fromRGB(0, 0, 225),
			["Toggle Aimbot"] = false,
			["Aimbot Keybind"] = "F",
			["Aimbot Button"] = false,
			["Aimbot Team Check"] = false,
			["Aimbot Wall Check"] = "Raycast", -- Варианты: "Raycast", "Improved", "Disabled",
			["Show Aimbot FOV Circle"] = false,
			["Aimbot FOV"] = 150,
			["Toggle Silent Aim"] = false,
			["Silent Aim Button"] = false,
			["Silent Aim Keybind"] = "V",
			["Silent Aim Wall Check"] = false,
			["Silent Aim Team Check"] = false,
			["Auto Save Features"] = false,
			["Auto Get Discord Invite"] = true,
			["Use Discord Chat as Guest"] = false,
			["Notify On New Messages"] = true,
			Theme = "Dark",
			["Toggle UI Keybind"] = "RightControl",
			["Button Placement"] = "Screen",
			["Aimbot Method"] = "Camera Method",
			["Aiming Method"] = "New",
			["Aiming Smooth"] = 0.05,
			["Esp Font"] = "BuilderSansBold",
			["Text Font"] = "BuilderSansBold",
			["Esp Text Size"] = 1,
			["Tracers Positions"] = "Under Screen",
			["Tracers Thickness"] = 1,
			["Highlight Mode"] = "Outline",
			["Highlight Transparency"] = 50,
			["Disable Features"] = false,
			["Disable Features Keybind"] = "F6",
		},
	},
}
local FeatureRegistry = {}

local function RegisterFeature(gameName, featureId, defaultValue, options)
	if not Universal_Features[gameName] then
		Universal_Features[gameName] = { Features = {} }
	end

	FeatureRegistry[featureId] = {
		Game = gameName,
		DefaultValue = defaultValue,
		Options = options or {},
	}

	if Universal_Features[gameName].Features[featureId] == nil then
		Universal_Features[gameName].Features[featureId] = defaultValue
	end
end

local function GetFeature(gameName, featureId)
	if Universal_Features[gameName] and Universal_Features[gameName].Features then
		return Universal_Features[gameName].Features[featureId]
	end
	return FeatureRegistry[featureId] and FeatureRegistry[featureId].DefaultValue
end

local function MigrateOldFeatures(gameName)
	if not Universal_Features[gameName] then
		return
	end

	local oldToNew = {
		-- Movement
		["WalkSpeed Toggle"] = "movement.walkspeed.toggle",
		["WalkSpeed Value"] = "movement.walkspeed.value",
		["Fly Toggle"] = "movement.fly.toggle",
		["Fly Value"] = "movement.fly.speed",
		["Noclip"] = "movement.noclip",
		["Infinite Jump"] = "movement.infinitejump",
		["Float"] = "movement.float",
		["Anti Fling"] = "movement.antifling",
		["Anti AFK"] = "movement.antiafk",

		-- Combat
		["Toggle Aimbot"] = "combat.aimbot.toggle",
		["Aimbot Method"] = "combat.aimbot.method",
		["Aimbot FOV"] = "combat.aimbot.fov",
		["Aiming Smooth"] = "combat.aimbot.smooth",
		["Aimbot Wall Check"] = "combat.aimbot.wallcheck",
		["Aimbot Team Check"] = "combat.aimbot.teamcheck",
		["Show Aimbot FOV Circle"] = "combat.aimbot.fovcircle",
		["Toggle Silent Aim"] = "combat.silentaim.toggle",
		["Triggerbot Enabled"] = "combat.triggerbot.enabled",

		-- Visual
		["ESP Mode"] = "visual.esp.mode",
		["ESP Enabled"] = "visual.esp.enabled",
		["ESP Color"] = "visual.esp.color",
		["ESP Teammate Color"] = "visual.esp.teamcolor",
		["ESP Team Check"] = "visual.esp.teamcheck",
		["Highlight Enabled"] = "visual.highlight.enabled",
		["Highlight Mode"] = "visual.highlight.mode",
		["Highlight Transparency"] = "visual.highlight.transparency",
		["Tracers Enabled"] = "visual.tracers.enabled",
		["Tracers Position"] = "visual.tracers.position",
		["Tracers Thickness"] = "visual.tracers.thickness",

		-- Settings
		["Theme"] = "settings.theme",
		["Text Font"] = "settings.font",
		["Toggle UI Keybind"] = "settings.togglekey",
		["Auto Save Features"] = "settings.autosave",
	}

	local features = Universal_Features[gameName].Features
	for oldName, newName in pairs(oldToNew) do
		if features[oldName] ~= nil and features[newName] == nil then
			features[newName] = features[oldName]
			features[oldName] = nil
		end
	end
end

function TABLE_MAIN.DiscordServices:Send(url, typeofs, report_type, report_ust, logContent)
	if typeofs == "" or typeofs == nil then
		typeofs = "Executed-Script"
	end

	local apiRequest = request or http_request or (http and http.request) or (syn and syn.request)
	if type(apiRequest) ~= "function" then
		warn("[Vanish]: HTTP request function is not available in this executor.")
		return
	end

	local executor = "Unknown"
	if type(identifyexecutor) == "function" then
		executor = identifyexecutor()
	elseif syn then
		executor = "Synapse X"
	elseif KRNL_LOADED then
		executor = "Krnl"
	elseif fluxus then
		executor = "Fluxus"
	elseif is_sirhurt_closure then
		executor = "SirHurt"
	elseif OXYGEN then
		executor = "Oxygen U"
	end

	local rolescript = "Member"
	if IsOwner(services.Players.LocalPlayer) then
		rolescript = "Owner"
	elseif IsVanishTeam(services.Players.LocalPlayer) then
		rolescript = "Developer"
	elseif IsTester(services.Players.LocalPlayer) then
		rolescript = "Tester"
	end

	local function getPlatform()
		if TABLE_MAIN.Main_Features.Mobile() then
			return "Mobile"
		elseif services.UserInputService.GamepadEnabled then
			return "Console"
		else
			return "PC"
		end
	end

	local hwid = "Unavailable"
	pcall(function()
		if syn and syn.gethwid then
			hwid = syn.gethwid()
		elseif type(gethwid) == "function" then
			hwid = gethwid()
		elseif fluxus and getgenv and getgenv().fluxus then
			hwid = tostring(getgenv().fluxus.HWID or "Unavailable")
		elseif delta and type(get_hw_id) == "function" then
			hwid = tostring(get_hw_id())
		else
			hwid = tostring((game:GetService("RbxAnalyticsService")):GetClientId())
		end
	end)

	local requiredembed = {
		{
			title = "plr executed Vanish Studios(Main) Script!",
			color = 3447003,
			author = {
				name = services.Players.LocalPlayer.Name,
				icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(
					services.Players.LocalPlayer.UserId
				) .. "&width=150&height=150&format=png",
			},
			thumbnail = {
				url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(
					services.Players.LocalPlayer.UserId
				) .. "&width=420&height=420&format=png",
			},
			fields = {
				{
					name = "User Info",
					value = "Username: " .. services.Players.LocalPlayer.Name .. "\nUser ID: " .. tostring(
						services.Players.LocalPlayer.UserId
					) .. "\nPlatform: " .. getPlatform() .. "\nScript Role: " .. rolescript,
					inline = false,
				},
				{
					name = "Executor Info",
					value = "Executor: " .. executor .. "\nHWID: ||" .. tostring(hwid) .. "||",
					inline = false,
				},
				{
					name = "Game Info",
					value = "Game: **" .. ((game:GetService("MarketplaceService")):GetProductInfo(game.PlaceId)).Name
						or "Unknow Game"
							.. "**\nGame ID: "
							.. tostring(game.GameId)
							.. "\nJob ID: "
							.. tostring(game.JobId),
					inline = false,
				},
			},
			footer = {
				text = "User ID: " .. tostring(services.Players.LocalPlayer.UserId),
			},
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		},
	}

	if typeofs == "Banned-User" then
		for _, embed in pairs(requiredembed) do
			if embed.title then
				embed.title = "plr had attempt to executed script on blacklisted IP/HWID/UserId!"
			end
			for key, field in pairs(embed.fields) do
				if field.name == "User Info" then
					field.value = "Username: "
						.. services.Players.LocalPlayer.Name
						.. "\nUser ID: "
						.. tostring(services.Players.LocalPlayer.UserId)
						.. "\nPlatform: "
						.. getPlatform()
						.. "\nScript Role: "
						.. rolescript
						.. "\nIP: ||"
						.. tostring(TABLE_MAIN.Others_Services.GetUserIP())
						.. "||"
				end
			end
		end
	elseif typeofs == "Report" then
		if requiredembed[1] and requiredembed[1].fields then
			table.insert(requiredembed[1].fields, {
				name = "Report Information:",
				value = tostring(report_type) .. "\n**Message:**\n" .. tostring(report_ust),
				inline = false,
			})

			if logContent and #logContent > 0 then
				table.insert(requiredembed[1].fields, {
					name = "Attached Log File:",
					value = "```lua\n" .. logContent:sub(1, 1000) .. (#logContent > 1000 and "..." or "") .. "\n```",
					inline = false,
				})
			end
		end
	elseif typeofs == "Security-Detection" then
		for _, embed in pairs(requiredembed) do
			if embed.title then
				embed.title = "plr has been detected by Vanish Security System!!"
				embed.color = 15158332
			end
			for _, field in pairs(embed.fields) do
				if field.name == "User Info" then
					field.value = "Username: "
						.. services.Players.LocalPlayer.Name
						.. "\nUser ID: "
						.. tostring(services.Players.LocalPlayer.UserId)
						.. "\nPlatform: "
						.. getPlatform()
						.. "\nScript Role: "
						.. rolescript
						.. "\n**Type Of Detection:** "
						.. tostring(report_type)
						.. "\n**Value Of Detects:**\n```lua\n"
						.. tostring(report_ust)
						.. "\n```"
				end
			end
		end
	end

	local success, err = pcall(function()
		apiRequest({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode({
				content = (typeofs == "Report" or typeofs == "Security-Detection")
						and "||<@&1416782800236974230> <@&1456909452128161833> <@1013356712398442498>||"
					or "",
				username = "Vanish API [" .. typeofs .. "]",
				embeds = requiredembed,
			}),
		})
	end)

	if not success then
		warn("[Vanish]: Failed to send Discord webhook. Error: " .. tostring(err))
	end
end
print("[Vanish]: Checking " .. getexecutorname() .. "...")
if ishooked then
	testfunction = function()
		return "1"
	end
	hookfunction(testfunction, function()
		return "2"
	end)
	task.wait()
	local test132, hdg = pcall(function()
		return testfunction()
	end)
	if test132 and hdg == "2" and ishooked(testfunction) == false then
		TABLE_MAIN.DiscordServices:Send(
			TABLE_MAIN.DiscordServices.WebhookLog,
			"Security-Detection",
			"Hooked Function | Environment",
			"ishooked"
		)
		lp:Kick(
			"You have been detected by Vanish Security System! If you have any questions, please contact support team."
		)
	end
	local found = {}
	pcall(function()
		for _, v in ipairs(game:GetChildren()) do
			local Methods = ReflectionService:GetMethodsOfClass(v.ClassName)
			if Methods == nil then
				continue
			end
			for _, method in pairs(Methods) do
				local func = v[method.Name]
				if ishooked(func) then
					table.insert(found, method.Name)
				end
			end
		end
	end)
	for i, v in pairs(getgenv()) do
		if v ~= ishooked then
			if type(v) == "function" and ishooked(v) then
				table.insert(found, i)
			end
		end
	end
	if #found > 0 then
		TABLE_MAIN.DiscordServices:Send(
			TABLE_MAIN.DiscordServices.WebhookLog,
			"Security-Detection",
			"Hooked Function | Environment",
			HttpService:JSONEncode(found)
		)
		lp:Kick(
			"You have been detected by Vanish Security System! If you have any questions, please contact support team."
		)
	end
end
function CreateElementsSections(parentTab, definitions)
	local sections = {}
	for _, definition in ipairs(definitions or {}) do
		if type(definition) == "table" then
			local key = definition.Key or definition[1]
			if key ~= nil then
				sections[key] = parentTab:AddElementsSection({
					Title = definition.Title or definition[2] or tostring(key),
					Description = definition.Description or definition[3] or "",
					Collapsible = definition.Collapsible ~= false,
					ElementsVisible = definition.ElementsVisible,
					Visible = definition.Visible,
				})
			end
		end
	end
	return sections
end
local DragTable = {}
function EnableDragify(object)
	object:SetAttribute("Dragging", false)
	DragTable[object.Name] = {
		dragInput = nil,
		dragStart = nil,
		startPos = nil,
		dragPos = nil,
	}
	DragTable[object.Name].updateInput = function(input)
		if DragTable[object.Name].dragStart == nil then
			return
		end
		local Delta = input.Position - DragTable[object.Name].dragStart
		local Position = UDim2.new(
			DragTable[object.Name].startPos.X.Scale,
			DragTable[object.Name].startPos.X.Offset + Delta.X,
			DragTable[object.Name].startPos.Y.Scale,
			DragTable[object.Name].startPos.Y.Offset + Delta.Y
		);
		((game:GetService("TweenService")):Create(object, TweenInfo.new(0.125), {
			Position = Position,
		})):Play()
	end
	TABLE_MAIN.ConnectionLib.Connects[object.Name .. "_Dragify_InputBegan"] = object.InputBegan:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and UserInputService:GetFocusedTextBox() == nil
		then
			DragTable[object.Name].dragStart = input.Position
			DragTable[object.Name].startPos = object.Position
			object:SetAttribute("Dragging", true)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					object:SetAttribute("Dragging", false)
				end
			end)
		end
	end)
	TABLE_MAIN.ConnectionLib.Connects[object.Name .. "_Dragify_InputChanged"] = object.InputChanged:Connect(
		function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			then
				DragTable[object.Name].dragInput = input
			end
		end
	)
	TABLE_MAIN.ConnectionLib.Connects[object.Name .. "_Dragify_InputDetection"] = (game:GetService("UserInputService")).InputChanged:Connect(
		function(input)
			if input == DragTable[object.Name].dragInput and object:GetAttribute("Dragging") == true then
				DragTable[object.Name].updateInput(input)
			end
		end
	)
end

FeatureAliases = {
	["Auto Save Feature"] = "Auto Save Features",
}

local VANISH_ROOT = "Vanish"
local VANISH_GAMES = "Vanish/Games"
local VANISH_OTHERS = "Vanish/Others"
local VANISH_LOGS = "Vanish/Logs"
local VANISH_LOGS_FILE = VANISH_LOGS .. "/Errors.txt"

function SafeDecode(str)
	local ok, res = pcall(function()
		return HttpService:JSONDecode(str)
	end)
	return ok and res or nil
end

function SafeEncode(tbl)
	local toSave = {}
	for k, v in pairs(tbl or {}) do
		toSave[k] = typeof(v) == "Color3" and ("COLORHEX?-" .. v:ToHex()) or v
	end
	local ok, res = pcall(function()
		return HttpService:JSONEncode(toSave)
	end)
	return ok and res or "{}"
end

local function ensureFolder(path)
	if not isfolder(path) then
		makefolder(path)
	end
end

local function resolveGamePath(gameName, relativePath)
	local newPath = VANISH_GAMES .. "/" .. gameName .. "/" .. relativePath
	local oldPath = VANISH_ROOT .. "/" .. gameName .. "/" .. relativePath
	if relativePath:match("%.json$") then
		if isfile(newPath) then
			return newPath
		end
		if isfile(oldPath) then
			return oldPath
		end
	else
		if isfolder(newPath) then
			return newPath
		end
		if isfolder(oldPath) then
			return oldPath
		end
	end
	return newPath
end

local function moveFile(src, dst)
	if isfile(src) then
		local parent = dst:match("(.+)/[^/]+$")
		if parent and not isfolder(parent) then
			ensureFolder(parent)
		end
		writefile(dst, readfile(src))
		delfile(src)
	end
end

local function moveFolder(src, dst)
	if isfolder(src) then
		if not isfolder(dst) then
			ensureFolder(dst)
		end
		for _, file in ipairs(listfiles(src)) do
			local name = file:match("([^/]+)$")
			if name then
				moveFile(file, dst .. "/" .. name)
			end
		end
		for _, sub in ipairs(listfiles(src)) do
			if sub:sub(-1) == "/" then
				local name = sub:match("([^/]+)/$")
				if name then
					moveFolder(sub, dst .. "/" .. name)
				end
			end
		end
		delfolder(src)
	end
end

local function migrateOldVanishStructure()
	if not isfolder(VANISH_ROOT) then
		return
	end
	ensureFolder(VANISH_GAMES)
	ensureFolder(VANISH_OTHERS)
	ensureFolder(VANISH_LOGS)

	for name, _ in pairs(Universal_Features) do
		if type(name) ~= "string" then
			continue
		end
		local oldGamePath = VANISH_ROOT .. "/" .. name
		local newGamePath = VANISH_GAMES .. "/" .. name
		if isfolder(oldGamePath) and not isfolder(newGamePath) then
			moveFolder(oldGamePath, newGamePath)
		end
	end
end

local function logCrash(source, message)
	pcall(function()
		if not isfolder(VANISH_LOGS) then
			ensureFolder(VANISH_LOGS)
		end
		local timestamp = os.date("%Y-%m-%d %H:%M:%S")
		local entry = "[" .. timestamp .. "] [" .. tostring(source) .. "] " .. tostring(message) .. "\n"
		if isfile(VANISH_LOGS_FILE) then
			appendfile(VANISH_LOGS_FILE, entry)
		else
			writefile(VANISH_LOGS_FILE, entry)
		end
	end)
end

local function safeCall(name, fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		logCrash(name, err)
		return nil
	end
	return err
end

local function colorFromHexValue(value)
	if type(value) ~= "string" then
		return nil
	end

	local normalized = value:gsub("#", ""):gsub("0x", ""):gsub("0X", "")

	if #normalized ~= 6 then
		return nil
	end

	local red = tonumber(normalized:sub(1, 2), 16)
	local green = tonumber(normalized:sub(3, 4), 16)
	local blue = tonumber(normalized:sub(5, 6), 16)

	if red and green and blue then
		return Color3.fromRGB(red, green, blue)
	end

	return nil
end
local function NormalizeColorValue(value)
	if typeof(value) == "Color3" then
		return value
	end
	if type(value) == "string" then
		return colorFromHexValue(value)
	end
	if type(value) == "table" then
		local hexValue = value.hex or value.Hex

		if type(hexValue) == "string" then
			local fromHex = colorFromHexValue(hexValue)

			if fromHex then
				return fromHex
			end
		end

		local red = tonumber(value.R or value.r or value[1])
		local green = tonumber(value.G or value.g or value[2])
		local blue = tonumber(value.B or value.b or value[3])

		if red and green and blue then
			if red <= 1 and green <= 1 and blue <= 1 then
				return Color3.new(red, green, blue)
			end

			return Color3.fromRGB(red, green, blue)
		end
	end

	return nil
end
function NormalizeFeatureAliases(features)
	if type(features) ~= "table" then
		return
	end

	for oldName, newName in pairs(FeatureAliases) do
		if features[oldName] ~= nil and features[newName] == nil then
			features[newName] = features[oldName]
		end
		features[oldName] = nil
	end
end

function ApplyFeatureConfig(featureTable, decoded)
	if type(featureTable) ~= "table" or type(decoded) ~= "table" then
		return false
	end

	NormalizeFeatureAliases(decoded)

	for k, v in pairs(decoded) do
		if featureTable[k] ~= nil then
			if typeof(featureTable[k]) == "Color3" then
				v = NormalizeColorValue(v) or featureTable[k]
			end
			featureTable[k] = v
		end
	end

	return true
end

function LoadAutoSaveForGame(gameName)
	local gameData = Universal_Features[gameName]
	if not gameData or type(gameData.Features) ~= "table" then
		return false
	end
	NormalizeFeatureAliases(gameData.Features)

	local autoPath = resolveGamePath(gameName, "AutoSave.json")
	if not isfile(autoPath) then
		return false
	end

	local decoded = SafeDecode(readfile(autoPath))
	if not decoded or not (decoded["Auto Save Features"] or decoded["Auto Save Feature"]) then
		return false
	end

	return ApplyFeatureConfig(gameData.Features, decoded) or false
end

local function UpdateFeature(gameName, featureId, value)
	if not Universal_Features[gameName] then
		Universal_Features[gameName] = { Features = {} }
	end

	Universal_Features[gameName].Features[featureId] = value

	if Universal_Features[gameName].Features["Auto Save Features"] then
		local autoPath = resolveGamePath(gameName, "AutoSave.json")
		if isfile(autoPath) then
			writefile(autoPath, SafeEncode(Universal_Features[gameName].Features))
		end
	end
end

function InitGameFolder(gameName)
	NormalizeFeatureAliases(Universal_Features[gameName].Features)

	local base = VANISH_GAMES .. "/" .. gameName
	local cfg = base .. "/Configs"
	if not isfolder(VANISH_ROOT) then
		makefolder(VANISH_ROOT)
	end
	if not isfolder(VANISH_GAMES) then
		makefolder(VANISH_GAMES)
	end
	if not isfolder(base) then
		makefolder(base)
	end
	if not isfolder(cfg) then
		makefolder(cfg)
	end

	local auto = base .. "/AutoSave.json"
	if not isfile(auto) then
		writefile(auto, SafeEncode(Universal_Features[gameName].Features))
	end
end

if not isfolder("Vanish") then
	makefolder("Vanish")
end

migrateOldVanishStructure()

for name, _ in pairs(Universal_Features) do
	if not Universal_Features[name] then
		continue
	end
	InitGameFolder(name)
end
local Notification = {
	["BocusLuke"] = loadstring(
		game:HttpGet(
			"https://raw.githubusercontent.com/Gregory909/Files/refs/heads/main/Roblox-UiLibrary-Modifed/BocusLukeNotification.lua"
		)
	)(),
}
function Notification:Notify(text, duration)
	if TABLE_MAIN.Others_Services.Notification == "BocusLuke" then
		task.spawn(function()
			Notification["BocusLuke"]:Notify(
				{ Title = "Vanish Hub (Universal) | Notification", Description = text },
				{ OutlineColor = Color3.fromRGB(3, 170, 191), Time = duraction or 5, Type = "image" },
				{ Image = TABLE_MAIN.Main_Features.Script_Icon, ImageColor = Color3.fromRGB(255, 255, 255) }
			)
		end)
	end
end
function Notification:Warn(text, duration)
	if TABLE_MAIN.Others_Services.Notification == "BocusLuke" then
		task.spawn(function()
			Notification["BocusLuke"]:Notify(
				{ Title = "Vanish Hub (Universal) | Warning", Description = text },
				{ OutlineColor = Color3.fromRGB(249, 214, 55), Time = duraction or 5, Type = "image" },
				{ Image = TABLE_MAIN.Main_Features.Script_Icon, ImageColor = Color3.fromRGB(255, 255, 255) }
			)
		end)
	end
end
function Notification:Error(text, duration)
	if TABLE_MAIN.Others_Services.Notification == "BocusLuke" then
		task.spawn(function()
			Notification["BocusLuke"]:Notify(
				{ Title = "Vanish Hub (Universal) | ErRoR", Description = text or "No description provided!" },
				{ OutlineColor = Color3.fromRGB(222, 81, 4), Time = duraction or 5, Type = "image" },
				{ Image = TABLE_MAIN.Main_Features.Script_Icon, ImageColor = Color3.fromRGB(255, 255, 255) }
			)
		end)
	end
end
function Notification:Critical(text, duration)
	if TABLE_MAIN.Others_Services.Notification == "BocusLuke" then
		task.spawn(function()
			Notification["BocusLuke"]:Notify(
				{ Title = "Vanish Hub (Universal) | Critical", Description = text },
				{ OutlineColor = Color3.fromRGB(255, 38, 38), Time = duraction or 5, Type = "image" },
				{ Image = TABLE_MAIN.Main_Features.Script_Icon, ImageColor = Color3.fromRGB(255, 255, 255) }
			)
		end)
	end
end
local _ntf, _wrn, _err =
	function(text, duraction)
		Notification:Notify(text, duraction or 5)
	end, function(text, duraction)
		Notification:Warn(text, duraction or 5)
	end, function(text, duraction)
		Notification:Error(text, duraction or 5)
	end

local UiLibrary = loadstring(
	game:HttpGet(
		"https://api.jnkie.com/api/v1/luascripts/public/bc81c7cca0407bd45e14a6a7d2daf7de6c7b8a512b6f3b1e2296f923361cc1a5/download"
	)
)()

function LoadSettings(Windows, tab, sections, features, currentGame, args)
	local win = args and args.window or nil
	local btnPlacement = args and args.buttonplacement or nil
	local groups = args and args.groups or {}

	if type(tab) ~= "table" or type(sections) ~= "table" or type(features) ~= "table" then
		return
	end

	HttpService = services.HttpService
	UserInputService = services.UserInputService
	Players = services.Players
	lp = Players.LocalPlayer

	local function notify(msg)
		if type(_ntf) == "function" then
			pcall(_ntf, tostring(msg))
		else
			warn("[Vanish]: " .. tostring(msg))
		end
	end

	local function warnUser(msg)
		if type(_wrn) == "function" then
			pcall(_wrn, tostring(msg))
		else
			warn("[Vanish]: " .. tostring(msg))
		end
	end

	local function NormalizeColorValue(value)
		if typeof(value) == "Color3" then
			return value
		end
		if type(value) == "string" then
			local hex = value:match("^COLORHEX%?%-(%x+)$") or value:match("^#?(%x%x%x%x%x%x)$")
			if hex then
				local ok, parsed = pcall(function()
					return Color3.fromHex(hex)
				end)
				if ok and parsed then
					return parsed
				end
			end
		end
		return nil
	end

	local Configs = {
		Get = function(gameName)
			local folder = VANISH_GAMES .. "/" .. gameName .. "/Configs"
			local list = {}
			if isfolder(folder) then
				for _, file in ipairs(listfiles(folder)) do
					table.insert(list, file:match("([^/]+)%.json$"))
				end
			end
			return list
		end,

		Save = function(gameName, configName, featureTable)
			if configName == "" then
				warn("[Vanish]: Config name cannot be empty!")
				return false
			end
			local folder = VANISH_GAMES .. "/" .. gameName .. "/Configs"
			if not isfolder(folder) then
				makefolder(folder)
			end
			local file = folder .. "/" .. configName .. ".json"
			writefile(file, SafeEncode(featureTable))
			return true
		end,

		Load = function(gameName, configName, featureTable, onUpdate)
			if configName == "" then
				warn("[Vanish]: Config name cannot be empty!")
				return false
			end
			local file = resolveGamePath(gameName, "Configs/" .. configName .. ".json")
			if not isfile(file) then
				return false
			end
			local decoded = SafeDecode(readfile(file))
			if not decoded then
				return false
			end
			for k, v in pairs(decoded) do
				if typeof(featureTable[k]) == "Color3" then
					local normalized = NormalizeColorValue(v)
					if normalized then
						v = normalized
					end
				end
				if featureTable[k] ~= nil and featureTable[k] ~= v then
					featureTable[k] = v
					if type(onUpdate) == "function" then
						onUpdate(k, v)
					end
				end
			end
			return true
		end,

		Delete = function(gameName, configName)
			if configName == "" then
				return false
			end
			local file = resolveGamePath(gameName, "Configs/" .. configName .. ".json")
			if isfile(file) then
				delfile(file)
				return true
			end
			return false
		end,

		ReplaceAutoSave = function(gameName, configName)
			if configName == "" then
				return false
			end

			local source = resolveGamePath(gameName, "Configs/" .. configName .. ".json")
			if not isfile(source) then
				return false
			end

			local decoded = SafeDecode(readfile(source))
			if not decoded then
				return false
			end

			NormalizeFeatureAliases(decoded)
			decoded["Auto Save Features"] = true
			local autoPath = resolveGamePath(gameName, "AutoSave.json")
			writefile(autoPath, SafeEncode(decoded))
			ApplyFeatureConfig(features, decoded)
			return true
		end,
	}

	local CustomThemeColorDefinitions = {
		{
			Feature = "Custom Theme Primary",
			Label = "Primary",
			Default = Color3.fromRGB(22, 22, 24),
			Path = { "Primary" },
		},
		{
			Feature = "Custom Theme Secondary",
			Label = "Secondary",
			Default = Color3.fromRGB(16, 16, 17),
			Path = { "Secondary" },
		},
		{
			Feature = "Custom Theme Accent",
			Label = "Accent",
			Default = Color3.fromRGB(255, 68, 68),
			Path = { "Accent" },
		},
		{
			Feature = "Custom Theme Text",
			Label = "Text",
			Default = Color3.fromRGB(230, 230, 230),
			Path = { "Text" },
		},
		{
			Feature = "Custom Theme SubText",
			Label = "Sub Text",
			Default = Color3.fromRGB(160, 160, 160),
			Path = { "SubText" },
		},
		{
			Feature = "Custom Theme Chat Background",
			Label = "Chat Background",
			Default = Color3.fromRGB(16, 16, 17),
			Path = { "Chat", "Background" },
		},
		{
			Feature = "Custom Theme Chat Bubble",
			Label = "Chat Bubble",
			Default = Color3.fromRGB(54, 54, 56),
			Path = { "Chat", "Bubble" },
		},
	}

	local function EnsureCustomThemeColorDefaults()
		for _, definition in ipairs(CustomThemeColorDefinitions) do
			if features[definition.Feature] == nil then
				features[definition.Feature] = definition.Default
			else
				features[definition.Feature] = NormalizeColorValue(features[definition.Feature]) or definition.Default
			end
		end
	end

	local function BuildCustomThemeColors()
		local colors = {}

		for _, definition in ipairs(CustomThemeColorDefinitions) do
			local value = NormalizeColorValue(features[definition.Feature]) or definition.Default
			local target = colors

			for index = 1, #definition.Path - 1 do
				local key = definition.Path[index]

				target[key] = target[key] or {}
				target = target[key]
			end

			target[definition.Path[#definition.Path]] = value
		end

		return colors
	end

	local function ApplyCustomThemeColors()
		if win and type(win.SetCustomColors) == "function" then
			pcall(function()
				win:SetCustomColors(BuildCustomThemeColors())
			end)
		end
	end

	EnsureCustomThemeColorDefaults()

	local ServerBrowser = {}
	ServerBrowser.MAX_PAGES = 15
	ServerBrowser.BASE_DELAY = 0.56

	function ServerBrowser.DecodeResponse(raw)
		if type(raw) ~= "string" or raw == "" then
			return nil
		end
		local okDecode, decoded = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if not okDecode or type(decoded) ~= "table" then
			return nil
		end
		local apiError = decoded.errors and decoded.errors[1]
		local code = tonumber(apiError and apiError.code)
		if code == 429 then
			return "ratelimit"
		end
		if type(decoded.data) == "table" then
			return decoded
		end
		return nil
	end

	function ServerBrowser.Fetch(placeId, cursor)
		local query = "sortOrder=Asc&limit=100&excludeFullGames=true"
		if typeof(cursor) == "string" and cursor ~= "" then
			query = query .. "&cursor=" .. HttpService:UrlEncode(cursor)
		end
		local urls = {
			("https://games.roblox.com/v1/games/%d/servers/Public?%s"):format(placeId, query),
			("https://games.roproxy.com/v1/games/%d/servers/Public?%s"):format(placeId, query),
		}

		for attempt = 1, 3 do
			for _, url in ipairs(urls) do
				local okRequest, response = pcall(function()
					return game:HttpGet(url)
				end)
				if not okRequest then
					continue
				end

				local okDecode, decoded = pcall(ServerBrowser.DecodeResponse, response)
				if not okDecode then
					decoded = nil
				end
				if decoded == "ratelimit" then
					task.wait(3.2 + (attempt * 0.25))
				elseif type(decoded) == "table" then
					return decoded
				end
			end
			task.wait(0.8 + (attempt * 0.25))
		end

		return nil
	end
	local function getTeleportService()
		local ok, ts = pcall(function()
			return game:GetService("TeleportService")
		end)
		return ok and ts or nil
	end
	function ServerBrowser.Teleport(placeId, jobId)
		if typeof(jobId) ~= "string" or jobId == "" then
			return false
		end
		if jobId == game.JobId then
			return false
		end

		local ts = getTeleportService()
		if not ts then
			warnUser("TeleportService unavailable!")
			return false
		end

		local success, err = pcall(function()
			ts:TeleportToPlaceInstance(placeId, jobId, services.Players.LocalPlayer)
		end)

		if not success then
			warn("[Vanish] Teleport error:", err)
		end

		return success
	end

	local autoPath = "Vanish/" .. currentGame .. "/AutoSave.json"
	if isfile(autoPath) then
		local decoded = SafeDecode(readfile(autoPath))
		if decoded and (decoded["Auto Save Features"] or decoded["Auto Save Feature"]) then
			ApplyFeatureConfig(features, decoded)
		end
	end

	local function applyRT(name, val)
		if win and type(win.SetTheme) == "function" and name == "Theme" then
			pcall(function()
				if val == "Custom" then
					ApplyCustomThemeColors()
				end
				win:SetTheme(val)
			end)
		elseif win and type(win.SetTextFont) == "function" and name == "Text Font" then
			pcall(function()
				win:SetTextFont(val)
			end)
		elseif win and type(win.SetCustomBackground) == "function" and name == "Custom Background" then
			pcall(function()
				win:SetCustomBackground(val)
			end)
		elseif win and type(win.SetCustomBackgroundDim) == "function" and name == "Custom Background Dim" then
			pcall(function()
				win:SetCustomBackgroundDim(val)
			end)
		elseif win and type(win.SetCustomBackgroundMode) == "function" and name == "Custom Background Mode" then
			pcall(function()
				win:SetCustomBackgroundMode(val)
			end)
		elseif
			win
			and type(win.SetCustomBackgroundPauseOnHide) == "function"
			and name == "Custom Background Pause On Hide"
		then
			pcall(function()
				win:SetCustomBackgroundPauseOnHide(val)
			end)
		elseif name == "Button Placement" and type(btnPlacement) == "function" then
			pcall(function()
				btnPlacement(val)
			end)
		elseif win and type(win.SetBind) == "function" and name == "Toggle UI Keybind" then
			pcall(function()
				win:SetBind(val)
			end)
		elseif type(name) == "string" and name:find("^Custom Theme ") then
			ApplyCustomThemeColors()
		end
		if name == "Button Placement" and lp and lp:FindFirstChild("PlayerGui") then
			local topBar = lp.PlayerGui:FindFirstChild("Vanish", true)
			if topBar then
				if topBar:IsA("ScreenGui") then
					topBar.Enabled = tostring(val) == "TopBar"
				elseif topBar:IsA("GuiObject") then
					topBar.Visible = tostring(val) == "TopBar"
				end
			end
		end
	end

	local function updateFeature(k, v)
		local nv = NormalizeColorValue(v)
		if nv ~= nil then
			v = nv
		end
		applyRT(k, v)
		UpdateFeature(currentGame, k, v)
	end

	local creditsMount = sections.Credits or tab
	local uiMount = sections.UI or tab
	local configMount = sections.Configs or tab
	local visualMount = sections.VisualHelpers or tab
	local colorMount = sections.Colors or tab
	local serverMount = sections.Servers or tab
	local reportMount = sections.Reports or tab

	creditsMount:AddSection({
		"Thanks you for using our script!",
		"This script was maded by Gregory909(Main Developer, Owner) and Dmel(Second Developer, UI)!",
	})

	local customThemeSection = nil
	local function UpdateCustomThemeControlsVisibility(themeName)
		if customThemeSection and type(customThemeSection.SetVisible) == "function" then
			customThemeSection:SetVisible(themeName == "Custom")
		end
	end

	uiMount:AddDropdown({
		"Theme",
		features["Theme"],
		{ "Dark", "Custom", "Red", "Green", "Blue", "Purple" },
		function(val)
			updateFeature("Theme", val)
			UpdateCustomThemeControlsVisibility(val)
		end,
	})

	if type(uiMount.AddElementsSection) == "function" then
		customThemeSection = uiMount:AddElementsSection({
			"Custom Theme Colors",
			"",
			Visible = features["Theme"] == "Custom",
			Collapsible = true,
			ElementsVisible = true,
		})

		for _, definition in ipairs(CustomThemeColorDefinitions) do
			local def = definition

			customThemeSection:AddColorPicker({
				def.Label,
				features[def.Feature],
				function(val)
					updateFeature(def.Feature, val)
				end,
			})
		end
	end

	uiMount:AddDropdown({
		"Text Font",
		features["Text Font"],
		{
			"BuilderSans",
			"BuilderSansBold",
			"Gotham",
			"GothamBold",
			"SourceSans",
			"SourceSansBold",
			"Roboto",
			"RobotoCondensed",
		},
		function(val)
			updateFeature("Text Font", val)
		end,
	})

	uiMount:AddTextBox({
		"Custom Background",
		features["Custom Background"] ~= "" and features["Custom Background"] or "https://...",
		function(val)
			updateFeature("Custom Background", tostring(val or ""))
		end,
	})

	uiMount:AddSlider({
		"Custom Background Dim",
		features["Custom Background Dim"] or 0.35,
		0,
		0.8,
		function(val)
			updateFeature("Custom Background Dim", val)
		end,
		0.05,
	})

	uiMount:AddDropdown({
		"Custom Background Mode",
		features["Custom Background Mode"],
		{ "Crop", "Fit" },
		function(val)
			updateFeature("Custom Background Mode", val)
		end,
	})

	uiMount:AddToggle({
		"Custom Background Pause On Hide",
		features["Custom Background Pause On Hide"],
		function(val)
			updateFeature("Custom Background Pause On Hide", val)
		end,
	})

	if UserInputService.TouchEnabled then
		uiMount:AddDropdown({
			"Button Placement",
			features["Button Placement"],
			{ "Screen", "TopBar", "TopLeft", "BottomLeft", "BottomRight" },
			function(val)
				updateFeature("Button Placement", val)
			end,
		})
	else
		uiMount:AddKeybind({
			"Toggle UI Keybind",
			features["Toggle UI Keybind"],
			function()
				if win and type(win.ToggleUi) == "function" then
					win:ToggleUi()
				end
			end,
			function(val)
				updateFeature("Toggle UI Keybind", val)
			end,
		})
	end

	uiMount:AddToggle({
		"Auto Save Features",
		features["Auto Save Features"],
		function(val)
			updateFeature("Auto Save Features", val)
		end,
	})

	local currentConfig = ""

	configMount:AddDropdown({
		"Config List",
		"Select Config",
		Configs.Get(currentGame),
		function(val)
			currentConfig = tostring(val or "")
		end,
	})

	configMount:AddTextBox({
		"Config Name",
		"Your config name...",
		function(val)
			currentConfig = tostring(val or ""):gsub("^%s+", ""):gsub("%s+$", "")
		end,
	})

	configMount:AddButton({
		"Save Config",
		function()
			if currentConfig == "" then
				warnUser("Config name cannot be empty")
				return
			end
			if Configs.Save(currentGame, currentConfig, features) then
				notify("Config saved: " .. currentConfig)
			end
		end,
	})

	configMount:AddButton({
		"Load Config",
		function()
			if currentConfig == "" then
				warnUser("Config name cannot be empty")
				return
			end
			if Configs.Load(currentGame, currentConfig, features, function(k, v)
				updateFeature(k, v)
			end) then
				notify("Config loaded: " .. currentConfig)
			end
		end,
	})

	configMount:AddButton({
		"Delete Config",
		function()
			if currentConfig == "" then
				warnUser("Config name cannot be empty")
				return
			end
			if Configs.Delete(currentGame, currentConfig) then
				notify("Config deleted: " .. currentConfig)
			end
		end,
	})

	configMount:AddButton({
		"Replace AutoSave",
		function()
			if currentConfig == "" then
				warnUser("Config name cannot be empty")
				return
			end
			if Configs.ReplaceAutoSave(currentGame, currentConfig) then
				notify("AutoSave replaced with: " .. currentConfig)
			end
		end,
	})
	visualMount:AddDropdown({
		"Esp Font",
		features["Esp Font"],
		{
			"BuilderSans",
			"BuilderSansBold",
			"Gotham",
			"GothamBold",
			"SourceSans",
			"SourceSansBold",
			"Roboto",
			"RobotoCondensed",
		},
		function(val)
			updateFeature("Esp Font", val)
		end,
	})

	visualMount:AddSlider({
		"Esp Text Size",
		features["Esp Text Size"] or features["ESP Text Size"] or 1,
		0.5,
		5,
		function(val)
			updateFeature("Esp Text Size", val)
		end,
		0.25,
	})

	visualMount:AddDropdown({
		"Tracers Positions",
		features["Tracers Positions"],
		{ "Under Screen", "Center Screen", "Bottom Screen", "From Character" },
		function(val)
			updateFeature("Tracers Positions", val)
		end,
	})

	visualMount:AddSlider({
		"Tracers Thickness",
		features["Tracers Thickness"],
		1,
		10,
		function(val)
			updateFeature("Tracers Thickness", val)
		end,
		0.25,
	})

	visualMount:AddDropdown({
		"Highlight Mode",
		features["Highlight Mode"] or "Outline",
		{ "Outline", "Fill" },
		function(val)
			updateFeature("Highlight Mode", val)
		end,
	})

	local serverState = {
		jobId = tostring(features["Server JobId"] or ""),
		amountPlayers = tonumber(features["Server Amount Of Players"]) or 1,
		isHopping = false,
	}

	local function getMaxPlayers()
		local ok, max = pcall(function()
			return Players.MaxPlayers
		end)
		return (ok and tonumber(max) and tonumber(max) > 0) and tonumber(max) or 20
	end

	local function doRejoin()
		local ts = getTeleportService()
		if not ts then
			_wrn("Teleport Service unavailable!")
			return
		end
		_ntf("Rejoining...")
		task.delay(0.5, function()
			pcall(function()
				ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
			end)
		end)
	end
	local function doServerHop(mode)
		if serverState.isHopping then
			warnUser("Already searching for a server...")
			return
		end
		serverState.isHopping = true
		notify("Searching for server (" .. (mode == "small" and "small" or "normal") .. ")...")

		task.spawn(function()
			local placeId = game.PlaceId
			local target = serverState.amountPlayers
			local cursor = nil
			local bestJobId = nil
			local bestScore = math.huge
			local pagesSearched = 0

			repeat
				local result = ServerBrowser.Fetch(placeId, cursor)
				if not result then
					break
				end

				for _, server in ipairs(result.data or {}) do
					local jid = tostring(server.id or "")
					local ping = tonumber(server.ping) or 9999
					local pop = tonumber(server.playing) or 0
					local maxP = tonumber(server.maxPlayers) or 1

					if jid == "" or jid == game.JobId then
						continue
					end
					if pop >= maxP then
						continue
					end

					local score
					if mode == "small" then
						score = pop * 1000 + ping
					else
						score = math.abs(pop - target) * 1000 + ping
					end

					if score < bestScore then
						bestScore = score
						bestJobId = jid
					end
				end

				cursor = result.nextPageCursor
				pagesSearched += 1

				if bestJobId and mode == "normal" and bestScore < 1000 then
					break
				end

				task.wait(ServerBrowser.BASE_DELAY)
			until not cursor or pagesSearched >= ServerBrowser.MAX_PAGES

			serverState.isHopping = false

			if not bestJobId then
				warnUser("No suitable server found")
				return
			end

			notify("Teleporting to server...")
			task.delay(0.5, function()
				ServerBrowser.Teleport(placeId, bestJobId)
			end)
		end)
	end
	local function doJoinServer()
		local jobId = serverState.jobId:gsub("^%s+", ""):gsub("%s+$", "")

		if jobId ~= "" then
			if jobId == game.JobId then
				warnUser("You're already in this server!")
				return
			end
			notify("Joining server by JobId...")
			task.delay(0.5, function()
				local ok = ServerBrowser.Teleport(game.PlaceId, jobId)
				if not ok then
					warnUser("Failed to join server (invalid JobId or full server)")
				end
			end)
		else
			doServerHop("normal")
		end
	end

	serverMount:AddButton({
		"Rejoin",
		function()
			doRejoin()
		end,
	})

	serverMount:AddButton({
		"Server Hop To Normal Server",
		function()
			doServerHop("normal")
		end,
	})

	serverMount:AddButton({
		"Server Hop To Small Server",
		function()
			doServerHop("small")
		end,
	})

	serverMount:AddTextBox({
		"JobId",
		serverState.jobId ~= "" and serverState.jobId or "Enter Job ID (optional)...",
		function(val)
			serverState.jobId = tostring(val or "")
		end,
	})

	local maxPlayersLimit = getMaxPlayers()
	serverMount:AddSlider({
		"Amount Of Players",
		serverState.amountPlayers,
		1,
		maxPlayersLimit,
		function(val)
			serverState.amountPlayers = math.clamp(math.floor(tonumber(val) or 1), 1, maxPlayersLimit)
		end,
		1,
	})

	serverMount:AddButton({
		"Join Server",
		function()
			doJoinServer()
		end,
	})
	local report_config = {
		Message = "",
		Type = "Suggestion",
		Cooldown = false,
	}
	reportMount:AddTextBox({
		"Enter Message Here",
		"Example",
		function(val)
			report_config.Message = val
		end,
	})
	reportMount:AddDropdown({
		"Select Category",
		report_config.Type,
		{
			"Errors In Script",
			"Bugs In Script",
			"Suggestion",
			"Others",
		},
		function(val)
			report_config.Type = val
		end,
	})
	reportMount:AddToggle({
		"Attach Logs File",
		features["Attach Logs File"] or false,
		function(val)
			updateFeature("Attach Logs File", val)
		end,
	})
	reportMount:AddButton({
		"Send Report",
		function()
			safeCall("Report.Send", function()
				if not report_config.Cooldown then
					if report_config.Message == "" then
						_err("You can't send empty message! Please enter message before sending...")
						return
					end
					report_config.Cooldown = true
					local attachLogs = features["Attach Logs File"] or false
					local logContent = nil
					if attachLogs and isfile(VANISH_LOGS_FILE) then
						logContent = readfile(VANISH_LOGS_FILE)
					end
					TABLE_MAIN.DiscordServices:Send(
						TABLE_MAIN.DiscordServices.WebhookLog,
						"Report",
						report_config.Type,
						report_config.Message,
						logContent
					)
					_ntf("Successful sended " .. report_config.Type .. " to our developers / owner!")
					task.wait(60)
					report_config.Cooldown = false
				else
					_err("Report is on cooldown! Please Wait 60 Seconds To Send Report Again!")
				end
			end)
		end,
	})
	reportMount:AddSection({
		"Warning!",
		"Dont send this section to troll our team or anything thats doesnt hears like bugs or suggestion. By ingoring that, you can get blacklisted!",
	})
	reportMount:AddSection({
		"Languages:",
		"You can use English and Russian language for this section. Others ways we cannot appeal your report!",
	})
	ApplyCustomThemeColors()
	applyRT("Theme", features["Theme"])
	applyRT("Text Font", features["Text Font"])
	applyRT("Custom Background", features["Custom Background"])
	applyRT("Custom Background Dim", features["Custom Background Dim"])
	applyRT("Custom Background Mode", features["Custom Background Mode"])
	applyRT("Custom Background Pause On Hide", features["Custom Background Pause On Hide"])
	applyRT("Button Placement", features["Button Placement"])
	applyRT("Toggle UI Keybind", features["Toggle UI Keybind"])

	if TABLE_MAIN.ConnectionLib.Connects.DisableFeaturesKeybind then
		TABLE_MAIN.ConnectionLib.Connects.DisableFeaturesKeybind:Disconnect()
		TABLE_MAIN.ConnectionLib.Connects.DisableFeaturesKeybind = nil
	end

	return {
		updateFeature = updateFeature,
		features = features,
		UI = { Tab = tab, Sections = sections },
	}
end

function BuildAdminFeatures(Window, Players_Features_List, SpecialValues, Tabs)
	local adminTab = Window:MakeTab({
		"Admin Panel",
		"command",
	})
	local AdminSections = CreateElementsSections(adminTab, {
		{ Key = "Intel", Title = "Detection" },
		{ Key = "Target", Title = "Target plr" },
		{ Key = "Commands", Title = "Commands" },
		{ Key = "Moderation", Title = "Moderation" },
	})
	local function getAdminRequest()
		return request or http_request or http and http.request or syn and syn.request
	end
	local function getSelectedTarget()
		local target = SpecialValues and SpecialValues.PLAYERTARGET
		if target and target.Parent == services.Players then
			return target
		end
		return nil
	end
	local function requireTarget()
		local target = getSelectedTarget()
		if not target then
			_err("Please select a plr first.")
			return nil
		end
		return target
	end
	local function runAdminCommand(commandText, cooldownSeconds)
		local now = os.clock()
		local nextAllowedAt = tonumber(SpecialValues.AdminCommandNextAllowedAt) or 0
		local waitSeconds = math.max(0, nextAllowedAt - now)
		if waitSeconds > 0 then
			_err("Please wait " .. tostring(math.ceil(waitSeconds)) .. " seconds before sending another command.")
			return false
		end
		local apiRequest = getAdminRequest()
		if typeof(apiRequest) ~= "function" then
			_err("Your executor does not support HTTP requests.")
			return false
		end
		local ok, err = pcall(function()
			apiRequest({
				Url = TABLE_MAIN.DiscordServices.WebhookPrompt,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json",
				},
				Body = HttpService:JSONEncode({
					content = tostring(commandText or ""),
				}),
			})
		end)
		if not ok then
			_err("Failed to send admin command: " .. tostring(err))
			return false
		end
		SpecialValues.AdminCommandNextAllowedAt = now + (tonumber(cooldownSeconds) or 5)
		return true
	end

	adminTab:AddLabel({
		"Admin commands are sent through the Discord bridge.",
	})
	AdminSections.Intel:AddButton({
		"Check Players",
		function()
			runAdminCommand(";detect " .. tostring(game.JobId), 5)
		end,
	})
	AdminSections.Intel:AddSection({
		"Tip",
		"Detected players will trigger a notification through the bridge.",
	})
	Players_Features_List["Select plr (Admin)"] = AdminSections.Target:AddDropdown({
		Name = "Select plr",
		Options = TABLE_MAIN.Players_Lib:GetList(),
		Default = "Select",
		Callback_OnDeletion = false,
		Callback = function(playerName)
			SpecialValues.PLAYERTARGET = GP(playerName)
		end,
	})
	AdminSections.Target:AddButton({
		"Refresh plr List",
		function()
			TABLE_MAIN.Players_Lib:SyncPlayerDropdowns(Players_Features_List)
		end,
	})
	SpecialValues.AdminBanType = SpecialValues.AdminBanType or "UserId"
	AdminSections.Moderation:AddDropdown({
		Name = "Ban Mode",
		Options = {
			"UserId",
			"IP",
		},
		Default = SpecialValues.AdminBanType,
		Callback = function(value)
			SpecialValues.AdminBanType = value
		end,
	})
	SpecialValues.AdminWarnReason = SpecialValues.AdminWarnReason or "ManualAction"
	AdminSections.Moderation:AddTextBox({
		"Warn Reason",
		"ManualAction",
		function(value)
			local text = tostring(value or ""):gsub("%s+", "_")
			if text == "" then
				text = "ManualAction"
			end
			SpecialValues.AdminWarnReason = text
		end,
	})
	AdminSections.Commands:AddButton({
		"Kill plr",
		function()
			local target = requireTarget()
			if target then
				runAdminCommand(";kill " .. target.Name, 5)
			end
		end,
	})
	AdminSections.Commands:AddButton({
		"Freeze plr",
		function()
			local target = requireTarget()
			if target then
				runAdminCommand(";freeze " .. target.Name, 5)
			end
		end,
	})
	AdminSections.Commands:AddButton({
		"Unfreeze plr",
		function()
			local target = requireTarget()
			if target then
				runAdminCommand(";unfreeze " .. target.Name, 5)
			end
		end,
	})
	AdminSections.Commands:AddButton({
		"Bring plr",
		function()
			local target = requireTarget()
			if target then
				runAdminCommand(";bring " .. target.Name .. " " .. services.Players.LocalPlayer.Name, 5)
			end
		end,
	})
	AdminSections.Commands:AddButton({
		"Fling plr",
		function()
			local target = requireTarget()
			if target then
				runAdminCommand(";fling " .. target.Name, 5)
			end
		end,
	})
	AdminSections.Moderation:AddButton({
		"Warn plr",
		function()
			local target = requireTarget()
			if target then
				local reason = tostring(SpecialValues.AdminWarnReason or "ManualAction"):gsub("%s+", "_")
				runAdminCommand(";warn " .. target.Name .. " " .. reason .. " " .. services.Players.LocalPlayer.Name, 5)
			end
		end,
	})
	AdminSections.Moderation:AddButton({
		"Ban plr",
		function()
			local target = requireTarget()
			if target then
				runAdminCommand(";ban " .. target.Name .. " " .. tostring(SpecialValues.AdminBanType or "UserId"), 5)
			end
		end,
	})
	AdminSections.Moderation:AddButton({
		"Unban plr",
		function()
			local target = requireTarget()
			if target then
				runAdminCommand(";unban " .. target.Name .. " " .. tostring(SpecialValues.AdminBanType or "UserId"), 5)
			end
		end,
	})
	AdminSections.Moderation:AddButton({
		"Kick plr",
		function()
			local target = requireTarget()
			if target then
				runAdminCommand(";kick " .. target.Name, 5)
			end
		end,
	})
end

function AddBoostFps(tab)
	local function applyPerformanceToInstance(inst)
		if not inst then
			return
		end
		if inst:IsA("ParticleEmitter") then
			inst.Enabled = false
			inst.Rate = 0
		elseif
			inst:IsA("Trail")
			or inst:IsA("Smoke")
			or inst:IsA("Fire")
			or inst:IsA("Sparkles")
			or inst:IsA("Beam")
		then
			inst.Enabled = false
		elseif inst:IsA("BasePart") then
			inst.CastShadow = false
		end
	end
	tab:AddButton({
		"Boost FPS",
		function()
			local descendants = workspace:GetDescendants()
			for i = 1, #descendants do
				applyPerformanceToInstance(descendants[i])
				if i % 500 == 0 then
					task.wait()
				end
			end
			if _OIRBBAKXHWLA and TABLE_MAIN.ConnectionLib.Connects then
				if TABLE_MAIN.ConnectionLib.Connects.BoostFps_DescendantAdded then
					TABLE_MAIN.ConnectionLib.Connects.BoostFps_DescendantAdded:Disconnect()
				end
				if TABLE_MAIN.ConnectionLib.Connects.BoostFps_LightingAdded then
					TABLE_MAIN.ConnectionLib.Connects.BoostFps_LightingAdded:Disconnect()
					TABLE_MAIN.ConnectionLib.Connects.BoostFps_LightingAdded = nil
				end
				TABLE_MAIN.ConnectionLib.Connects.BoostFps_DescendantAdded = workspace.DescendantAdded:Connect(
					function(inst)
						applyPerformanceToInstance(inst)
					end
				)
			end
		end,
	})
end

function MoveCameraTo(targetPosition, method, smooth)
	local smoothValue = math.clamp(tonumber(smooth) or 0.5, 0.001, 1)
	if method == "Lerp" or method == "New" then
		workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(
			CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPosition),
			smoothValue
		)
	elseif method == "Tween" then
		local tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.015), {
			CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPosition),
		})
		tween:Play()
	else
		workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPosition)
	end
end

function GetTracersPosition(feature)
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	local pos = feature["Tracers Positions"]
	if pos == "Under Screen" then
		return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
	elseif pos == "Center Screen" then
		return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	elseif pos == "Bottom Screen" then
		return Vector2.new(camera.ViewportSize.X / 2, 0)
	elseif pos == "From Character" then
		local hp = GetLPHumpart()
		if not hp then
			return nil
		end
		local sp = camera:WorldToViewportPoint(hp.Position)
		return Vector2.new(sp.X, sp.Y)
	end
	return nil
end

function GetTracerThickness(features)
	return tonumber(features["Tracers Thickness"]) or 1
end

function ClearEspStore(store)
	if not store then
		return
	end
	for key, esp in pairs(store) do
		if esp then
			if esp.Highlight then
				pcall(function()
					ESP_LIBRARY:RemoveHighlight(esp.Highlight)
				end)
			end
			if esp.EspText then
				pcall(function()
					ESP_LIBRARY:RemoveEspText(esp.EspText)
				end)
			end
			if esp.Tracer then
				pcall(function()
					ESP_LIBRARY:RemoveTracer(esp.Tracer)
				end)
			end
		end
		store[key] = nil
	end
end

function GetClampedFeatureNumber(featureTable, key, defaultValue, minValue, maxValue)
	local value = tonumber(featureTable and featureTable[key]) or defaultValue
	if minValue ~= nil or maxValue ~= nil then
		return math.clamp(value, minValue or value, maxValue or value)
	end
	return value
end

function ReadPingMs()
	if type(getPing) == "function" then
		local ok, value = pcall(getPing)
		if ok and tonumber(value) then
			return tonumber(value)
		end
	end
	local ok, value = pcall(function()
		local network = statsService and statsService:FindFirstChild("Network")
		local serverStatsItem = network and network:FindFirstChild("ServerStatsItem")
		local dataPing = serverStatsItem and serverStatsItem:FindFirstChild("Data Ping")
		if dataPing and type(dataPing.GetValue) == "function" then
			return dataPing:GetValue()
		end
		return nil
	end)
	return ok and tonumber(value) or 0
end

function GetClampedPingMs(maxValue)
	return math.clamp(ReadPingMs(), 0, tonumber(maxValue) or 300)
end

function GetPingScaledSeconds(pingMs, scale, minValue, maxValue)
	local scaled = ((tonumber(pingMs) or 0) / 1000) * (tonumber(scale) or 0)
	return math.clamp(scaled, tonumber(minValue) or scaled, tonumber(maxValue) or scaled)
end

function GetEspTextScale(feature)
	return math.clamp(tonumber(feature["Esp Text Size"]) or 1, 0.5, 5)
end

function GetEspFont(feature)
	local fontName = feature["Esp Font"] or "BuilderSansBold"
	if typeof(fontName) == "EnumItem" then
		return fontName
	end
	if type(fontName) == "string" then
		local ok, fontEnum = pcall(function()
			return Enum.Font[fontName]
		end)
		if ok and fontEnum then
			return fontEnum
		end
	end
	return Enum.Font.BuilderSansBold
end

function PrepareEspLabel(label)
	if not label then
		return
	end
	label.TextWrapped = true
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.LineHeight = 0.92
	label.TextStrokeColor3 = label.TextStrokeColor3 or Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = math.min(tonumber(label.TextStrokeTransparency) or 0.18, 0.18)
end

function FormatEspDistanceText(distanceOrWorldPosition)
	local studs
	if type(distanceOrWorldPosition) == "number" then
		studs = distanceOrWorldPosition
	elseif typeof(distanceOrWorldPosition) == "Vector3" then
		local localRoot = GetLPHumpart()
		if not localRoot then
			return nil
		end
		studs = (localRoot.Position - distanceOrWorldPosition).Magnitude
	end
	if studs == nil then
		return nil
	end
	return tostring(math.max(0, math.floor(studs + 0.5))) .. " studs"
end

function build_distancething(title, distanceOrWorldPosition)
	local base = tostring(title or "")
	local distanceText = FormatEspDistanceText(distanceOrWorldPosition)
	if distanceText and distanceText ~= "" then
		return base ~= "" and (base .. "\n" .. distanceText) or distanceText
	end
	return base
end

function GetUIFont(feature)
	local fontName = feature["Text Font"] or "BuilderSansBold"
	if typeof(fontName) == "EnumItem" then
		return fontName
	end
	if type(fontName) == "string" then
		local ok, fontEnum = pcall(function()
			return Enum.Font[fontName]
		end)
		if ok and fontEnum then
			return fontEnum
		end
	end
	return Enum.Font.BuilderSansBold
end

local ESP_LIBRARY = {}
do
	ESP_LIBRARY.Players = {}
	ESP_LIBRARY.Objects = {}
	ESP_LIBRARY.Connections = {}
	ESP_LIBRARY.Trackers = {}
	ESP_LIBRARY.PlayerRoleChecks = {}
	ESP_LIBRARY.RuntimeConnection = nil
	ESP_LIBRARY.LastPlayersUpdate = 0
	ESP_LIBRARY.PlayerVisualsActive = false

	local function esp_folders()
		local core = gethui() or game:GetService("CoreGui")
		local root = core:FindFirstChild("ESP_Holders")

		if root and root.Parent == nil then
			pcall(function()
				root:Destroy()
			end)
			root = nil
		end

		if not root then
			root = Instance.new("Folder")
			root.Name = "ESP_Holders"
			root.Parent = core
		end
		local highlights = root:FindFirstChild("Highlights")
		if not highlights then
			highlights = Instance.new("Folder")
			highlights.Name = "Highlights"
			highlights.Parent = root
		end
		local texts = root:FindFirstChild("Texts")
		if not texts then
			texts = Instance.new("Folder")
			texts.Name = "Texts"
			texts.Parent = root
		end
		return root, highlights, texts
	end

	local ESP_HOLDERS, ESP_HIGHLIGHTS_FOLDER, ESP_TEXTS_FOLDER = esp_folders()
	local HIGHLIGHT_MODE_ATTRIBUTE = "Mode"
	local HIGHLIGHT_ALPHA_ATTRIBUTE = "tEsT"

	local function normalizeHighlightTransparency(value)
		local numeric = tonumber(value)
		if numeric == nil then
			return 0.5
		end
		if numeric > 1 then
			numeric = numeric / 100
		end
		return math.clamp(numeric, 0, 1)
	end

	local function resolveHighlightMode(highlight, mode)
		if type(mode) == "string" and mode ~= "" then
			return mode
		end
		if highlight and highlight.GetAttribute then
			local stored = highlight:GetAttribute(HIGHLIGHT_MODE_ATTRIBUTE)
			if type(stored) == "string" and stored ~= "" then
				return stored
			end
		end
		return "Outline"
	end

	local function applyHighlightTransparency(highlight, transparency, mode, fillColor, outlineColor)
		if not highlight then
			return
		end
		local alpha = normalizeHighlightTransparency(transparency)
		local highlightMode = resolveHighlightMode(highlight, mode)

		if fillColor then
			highlight.FillColor = fillColor
		end
		if outlineColor then
			highlight.OutlineColor = outlineColor
		else
			highlight.OutlineColor = highlight.FillColor
		end

		if highlight.SetAttribute then
			highlight:SetAttribute(HIGHLIGHT_MODE_ATTRIBUTE, highlightMode)
			highlight:SetAttribute(HIGHLIGHT_ALPHA_ATTRIBUTE, alpha)
		end

		if highlightMode == "Fill" then
			highlight.FillTransparency = alpha
			highlight.OutlineTransparency = 1
		elseif highlightMode == "Outline" then
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = alpha
		else
			highlight.FillTransparency = alpha
			highlight.OutlineTransparency = alpha
		end
	end

	local function resolveEspTextSize(value, defaultSize)
		local baseSize = tonumber(defaultSize) or 14
		local numeric = tonumber(value)
		if numeric == nil then
			return math.max(8, baseSize)
		end
		if numeric <= 5 then
			return math.max(8, baseSize * math.clamp(numeric, 0.5, 5))
		end
		return math.max(8, numeric)
	end

	local function getEspBillboardSize(textSize, customSize)
		if typeof(customSize) == "UDim2" then
			return customSize
		end
		local ts = tonumber(textSize) or 14
		return UDim2.fromOffset(math.max(170, math.floor(ts * 12.5)), math.max(64, math.floor(ts * 4.4)))
	end

	local function countEntries(tbl)
		local total = 0
		if type(tbl) ~= "table" then
			return total
		end
		for _ in pairs(tbl) do
			total += 1
		end
		return total
	end

	local function resolveFeatureTrack(featureTable, track)
		if track == nil then
			return false
		end
		local t = type(track)
		if t == "boolean" then
			return track
		end
		if t == "string" and type(featureTable) == "table" then
			return featureTable[track] == true
		end
		return track == true
	end

	local function resolveTextAdornee(target)
		if not target then
			return nil
		end
		if target:IsA("BasePart") then
			return target
		end
		local head = target:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			return head
		end
		local hrp = target:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then
			return hrp
		end
		local bp = target:FindFirstChildOfClass("BasePart")
		if bp then
			return bp
		end
		return nil
	end

	local function resolveObjectTextAdornee(obj, basepart, args)
		if args and args.getadornee then
			local ok, adornee = pcall(args.getadornee, obj, basepart)
			if ok and typeof(adornee) == "Instance" and adornee:IsA("BasePart") then
				return adornee
			end
		end
		return resolveTextAdornee(basepart or obj)
	end

	function ESP_LIBRARY:CreateHighlight(target, options)
		local espObject = Instance.new("Highlight")
		espObject.Adornee = target
		espObject.Parent = ESP_HIGHLIGHTS_FOLDER or game.CoreGui
		espObject.Enabled = options.Enabled or false
		espObject.FillColor = options.FillColor or Color3.fromRGB(255, 255, 255)
		espObject.OutlineColor = options.OutlineColor or Color3.fromRGB(0, 0, 0)
		espObject.FillTransparency = normalizeHighlightTransparency(options.FillTransparency)
		espObject.OutlineTransparency = normalizeHighlightTransparency(options.OutlineTransparency or 0)
		applyHighlightTransparency(espObject, options.FillTransparency, options.HighlightMode)
		return espObject
	end

	function ESP_LIBRARY:RemoveHighlight(espObject)
		if espObject and espObject.Parent then
			espObject:Destroy()
		end
	end

	function ESP_LIBRARY:CreateEspText(target, options)
		local resolvedTextSize = resolveEspTextSize(options.TextSize, 14)
		local billboardGui = Instance.new("BillboardGui")

		if target then
			billboardGui.Adornee = resolveTextAdornee(target)
		end

		billboardGui.Size = getEspBillboardSize(resolvedTextSize, options.Size)
		billboardGui.AlwaysOnTop = options.AlwaysOnTop ~= nil and options.AlwaysOnTop or true
		billboardGui.StudsOffset = options.StudsOffset or Vector3.new(0, 3, 0)
		billboardGui.Parent = ESP_TEXTS_FOLDER or game.CoreGui
		billboardGui.Enabled = options.Enabled or false

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = options.TextColor or Color3.fromRGB(255, 255, 255)
		textLabel.TextStrokeColor3 = options.TextStrokeColor or Color3.fromRGB(0, 0, 0)
		textLabel.TextStrokeTransparency = options.TextStrokeTransparency ~= nil and options.TextStrokeTransparency
			or 0.18
		textLabel.Font = options.Font or Enum.Font.BuilderSansBold
		textLabel.TextSize = resolvedTextSize
		textLabel.Text = options.Text or "Esp Text"
		textLabel.LineHeight = 0.92
		PrepareEspLabel(textLabel)
		textLabel.Parent = billboardGui
		textLabel.Visible = true

		return billboardGui
	end

	function ESP_LIBRARY:RemoveEspText(espText)
		if espText and espText.Parent then
			espText:Destroy()
		end
	end

	function ESP_LIBRARY:CreateTracer(target, options)
		local tracer = Drawing.new("Line")
		tracer.From = options.From or Vector2.new(0, 0)
		tracer.To = options.To or Vector2.new(0, 0)
		tracer.Color = options.Color or Color3.fromRGB(255, 255, 25)
		tracer.Thickness = options.Thickness or 1
		tracer.Transparency = options.Transparency or 1
		tracer.Visible = options.Visible or false
		return tracer
	end

	function ESP_LIBRARY:RemoveTracer(tracer)
		if tracer then
			tracer:Remove()
		end
	end

	local function normalizeTrackedObjectList(found)
		if found == nil then
			return {}
		end
		if typeof(found) == "Instance" then
			return { found }
		end
		if type(found) ~= "table" then
			return { found }
		end

		local list, seen = {}, {}
		for key, value in pairs(found) do
			local obj = value
			if typeof(key) == "Instance" and value == true then
				obj = key
			end
			if obj ~= nil and obj ~= false and not seen[obj] then
				seen[obj] = true
				table.insert(list, obj)
			end
		end
		return list
	end

	function ESP_LIBRARY:CleanupTrackedVisual(data)
		if not data then
			return
		end
		if data.Connections then
			for _, connection in pairs(data.Connections) do
				pcall(function()
					connection:Disconnect()
				end)
			end
			data.Connections = nil
		end
		if data.Highlight then
			pcall(function()
				self:RemoveHighlight(data.Highlight)
			end)
			data.Highlight = nil
		end
		if data.EspText then
			pcall(function()
				self:RemoveEspText(data.EspText)
			end)
			data.EspText = nil
		end
		if data.Tracer then
			pcall(function()
				self:RemoveTracer(data.Tracer)
			end)
			data.Tracer = nil
		end
	end

	function ESP_LIBRARY:EnsureRuntime()
		if self.RuntimeConnection then
			return
		end

		local lastPing = os.clock()

		self.RuntimeConnection = services.RunService.Heartbeat:Connect(function()
			local now = os.clock()
			self:StepPlayers(now)
			self:StepTrackers(now)

			if now - lastPing >= 4 then
				lastPing = now
				pcall(function()
					self:PingRender()
				end)
			end
		end)
		table.insert(self.Connections, self.RuntimeConnection)
	end

	function ESP_LIBRARY:HasEnabledPlayerVisuals()
		for _, def in ipairs(self.PlayerRoleChecks or {}) do
			local ft = def._featureTable or {}
			if
				resolveFeatureTrack(ft, def.ESP_Track)
				or resolveFeatureTrack(ft, def.Highlight_Track)
				or resolveFeatureTrack(ft, def.Tracker_Track)
			then
				return true
			end
		end
		return false
	end

	function ESP_LIBRARY:StepPlayers(now)
		if not self.PlayerRoleChecks or #self.PlayerRoleChecks == 0 then
			return
		end
		if countEntries(self.Players) <= 0 then
			return
		end

		if not self:HasEnabledPlayerVisuals() then
			if self.PlayerVisualsActive then
				self.PlayerVisualsActive = false
				self:UpdateAllPlayerESP()
			end
			return
		end

		self.PlayerVisualsActive = true
		if (now - (self.LastPlayersUpdate or 0)) < 0.0034 then
			return
		end
		self.LastPlayersUpdate = now
		self:UpdateAllPlayerESP()
	end

	function ESP_LIBRARY:StepTrackers(now)
		if type(self.Trackers) ~= "table" or #self.Trackers == 0 then
			return
		end
		local processed = 0

		for _, tracker in ipairs(self.Trackers) do
			if not tracker or tracker.Disconnected then
				continue
			end

			local args = tracker.Args or {}
			local features = args.features_table or {}
			local featureTrack = args.feature_track or {}

			local anyEnabled = resolveFeatureTrack(features, featureTrack.Text)
				or resolveFeatureTrack(features, featureTrack.Highlight)
				or resolveFeatureTrack(features, featureTrack.Tracer)

			if not anyEnabled then
				if tracker.Active then
					for obj, data in pairs(tracker.TrackedObjects) do
						self:CleanupTrackedVisual(data)
						tracker.TrackedObjects[obj] = nil
					end
					tracker.Active = false
				end
				continue
			end

			local interval = args.UpdateInterval or 0.016
			if (now - (tracker.LastUpdate or 0)) < interval then
				continue
			end
			tracker.LastUpdate = now

			local scanInterval = args.ScanInterval or 0.05
			if not tracker._cachedObjects or (now - (tracker._cacheTime or 0)) >= scanInterval then
				local found = args.findobject and args.findobject() or {}
				tracker._cachedObjects = normalizeTrackedObjectList(found)
				tracker._cacheTime = now
				tracker._index = 1
			end

			local objects = tracker._cachedObjects
			local count = #objects
			if count == 0 then
				for obj, data in pairs(tracker.TrackedObjects) do
					self:CleanupTrackedVisual(data)
					tracker.TrackedObjects[obj] = nil
				end
				tracker.Active = false
				continue
			end

			local foundSet = {}
			for _, obj in ipairs(objects) do
				foundSet[obj] = true
			end
			for obj, data in pairs(tracker.TrackedObjects) do
				local objectAlive = typeof(obj) ~= "Instance" or obj.Parent ~= nil
				if not foundSet[obj] or not objectAlive then
					self:CleanupTrackedVisual(data)
					tracker.TrackedObjects[obj] = nil
				end
			end

			local maxProcessed = args.MaxProcessed or 200
			local perTick = args.PerTick or math.min(count, maxProcessed)
			tracker._index = tracker._index or 1

			for i = 1, perTick do
				if processed >= maxProcessed then
					break
				end
				local obj = objects[tracker._index]
				tracker._index += 1
				if tracker._index > count then
					tracker._index = 1
				end

				if obj then
					local basepart = args.getbasepart and args.getbasepart(obj) or obj
					if basepart and typeof(basepart) == "Instance" and basepart:IsA("BasePart") and basepart.Parent then
						self:UpdateOrCreateObjectESP(obj, basepart, args, tracker.TrackedObjects)
						tracker.Active = true
					else
						if tracker.TrackedObjects[obj] then
							self:CleanupTrackedVisual(tracker.TrackedObjects[obj])
							tracker.TrackedObjects[obj] = nil
						end
					end
				end
				processed += 1
			end
		end
	end

	function ESP_LIBRARY:UpdateOrCreateObjectESP(obj, basepart, args, trackedObjects)
		local data = trackedObjects[obj]
		if not data then
			data = { LastTextUpdate = 0, LastScreenPos = nil, LastText = nil, LastTracerUpdate = nil, Connections = {} }
			trackedObjects[obj] = data
		end

		if not data.LifetimeHooked then
			data.LifetimeHooked = true
			local function cleanupIfCurrent()
				if trackedObjects[obj] == data then
					self:CleanupTrackedVisual(data)
					trackedObjects[obj] = nil
				end
			end
			local function watch(instance)
				if typeof(instance) ~= "Instance" then
					return
				end
				table.insert(
					data.Connections,
					instance.AncestryChanged:Connect(function(_, parent)
						if parent == nil then
							cleanupIfCurrent()
						end
					end)
				)
				pcall(function()
					table.insert(data.Connections, instance.Destroying:Connect(cleanupIfCurrent))
				end)
			end
			watch(obj)
			if basepart ~= obj then
				watch(basepart)
			end
		end

		local features = args.features_table or {}
		local featureTrack = type(args.feature_track) == "table" and args.feature_track or {}
		local textFlag = featureTrack.Text and features[featureTrack.Text]
		local highlightFlag = featureTrack.Highlight and features[featureTrack.Highlight]
		local tracerFlag = featureTrack.Tracer and features[featureTrack.Tracer]

		local color = features[args.color_track] or Color3.new(1, 1, 1)
		if args.getcolor then
			local ok, rc = pcall(args.getcolor, obj, basepart, features)
			if ok and typeof(rc) == "Color3" then
				color = rc
			end
		end

		local transparency = normalizeHighlightTransparency(features["Highlight Transparency"])
		local highlightMode = features["Highlight Mode"] or "Outline"
		local font = GetEspFont(features)
		local textSize = (tonumber(args.TextSize) or 19) * GetEspTextScale(features)

		local highlightTarget = basepart
		if args.gethighlighttarget then
			local ok, ht = pcall(args.gethighlighttarget, obj, basepart)
			if ok and typeof(ht) == "Instance" then
				highlightTarget = ht
			end
		end

		local worldPosition = basepart.Position
		if args.getposition then
			local ok, rp = pcall(args.getposition, obj, basepart)
			if ok and typeof(rp) == "Vector3" then
				worldPosition = rp
			end
		end

		local camera = workspace.CurrentCamera
		if not camera then
			return
		end

		local diff = worldPosition - camera.CFrame.Position
		local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
		local maxDist = args.MaxDistance or 10000
		local maxDistSq = maxDist * maxDist

		local lod = distSq > maxDistSq and 0 or (distSq > maxDistSq * 0.4 and 1 or 2)

		local labelText = (obj and typeof(obj) == "Instance" and obj.Name) or "Object"
		if args.gettext then
			local ok, ct = pcall(args.gettext, obj, basepart)
			if ok and type(ct) == "string" and ct ~= "" then
				labelText = ct
			end
		end

		if lod == 0 then
			if data.Highlight then
				self:UpdateHighlight(data.Highlight, { Enabled = false })
			end
			if data.EspText then
				self:UpdateEspText(data.EspText, { Enabled = false })
			end
			if data.Tracer then
				self:UpdateTracer(data.Tracer, { Visible = false })
			end
			return
		end

		local now = os.clock()
		local textEnabled = lod == 2 and textFlag == true
		if textEnabled then
			local textAdornee = resolveObjectTextAdornee(obj, basepart, args)
			if not data.EspText then
				data.EspText = self:CreateEspText(textAdornee or basepart, {
					Text = labelText,
					TextColor = color,
					Font = font,
					TextSize = textSize,
					Enabled = true,
					AlwaysOnTop = true,
				})
			else
				if now - (data.LastTextUpdate or 0) >= 0.2 then
					self:UpdateEspText(data.EspText, {
						Text = labelText,
						TextColor = color,
						Font = font,
						TextSize = textSize,
					})
					data.LastTextUpdate = now
				end
				if data.EspText and data.EspText.Parent then
					local adornee = textAdornee
					if adornee and data.EspText.Adornee ~= adornee then
						data.EspText.Adornee = adornee
					end
					data.EspText.Enabled = true
				end
			end
		else
			if data.EspText then
				self:UpdateEspText(data.EspText, { Enabled = false })
			end
		end

		local highlightEnabled = lod >= 1 and highlightFlag == true
		if highlightEnabled then
			if not data.Highlight then
				data.Highlight = self:CreateHighlight(highlightTarget, {
					Enabled = true,
					FillColor = color,
					OutlineColor = color,
					FillTransparency = transparency,
					HighlightMode = highlightMode,
				})
			else
				if data.Highlight.Adornee ~= highlightTarget then
					data.Highlight.Adornee = highlightTarget
				end
				self:UpdateHighlight(data.Highlight, {
					Enabled = true,
					FillColor = color,
					OutlineColor = color,
					FillTransparency = transparency,
					HighlightMode = highlightMode,
				})
			end
		else
			if data.Highlight then
				data.Highlight.Enabled = false
			end
		end

		local tracerEnabled = lod == 2 and tracerFlag == true
		if tracerEnabled then
			if not data.Tracer then
				data.Tracer = self:CreateTracer(nil, {
					Visible = false,
					Color = color,
					Thickness = GetTracerThickness(features),
					Transparency = 1,
				})
			end

			local sp, onScreen = camera:WorldToViewportPoint(worldPosition)
			if onScreen then
				local shouldUpdate = not data.LastTracerUpdate
					or (now - data.LastTracerUpdate >= (args.TracerUpdateInterval or 0))
				if shouldUpdate then
					local from = GetTracersPosition(features)
						or Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
					self:UpdateTracer(data.Tracer, {
						From = from,
						To = Vector2.new(sp.X, sp.Y),
						Visible = true,
						Color = color,
						Thickness = GetTracerThickness(features),
					})
					data.LastScreenPos = Vector2.new(sp.X, sp.Y)
					data.LastTracerUpdate = now
				end
			else
				self:UpdateTracer(data.Tracer, { Visible = false })
				data.LastScreenPos = nil
			end
		else
			if data.Tracer then
				self:UpdateTracer(data.Tracer, { Visible = false })
			end
		end

		data.LastWorldPos = worldPosition
	end

	function ESP_LIBRARY:DisconnectTracker(tracker)
		if not tracker or tracker.Disconnected == true then
			return
		end
		tracker.Disconnected = true
		for obj, data in pairs(tracker.TrackedObjects or {}) do
			self:CleanupTrackedVisual(data)
			tracker.TrackedObjects[obj] = nil
		end
		tracker._cachedObjects = nil
	end

	function ESP_LIBRARY:UpdateEspText(espText, options)
		if not espText or not espText.Parent then
			return
		end
		local textLabel = espText:FindFirstChildOfClass("TextLabel")
		if not textLabel then
			return
		end
		local resolvedTextSize = options.TextSize ~= nil and resolveEspTextSize(options.TextSize, textLabel.TextSize)
			or textLabel.TextSize
		if options.Enabled ~= nil then
			espText.Enabled = options.Enabled
		end
		if options.AlwaysOnTop ~= nil then
			espText.AlwaysOnTop = options.AlwaysOnTop
		end
		if options.StudsOffset ~= nil then
			espText.StudsOffset = options.StudsOffset
		end
		if options.Size ~= nil or options.TextSize ~= nil then
			espText.Size = getEspBillboardSize(resolvedTextSize, options.Size)
		end
		textLabel.TextColor3 = options.TextColor or textLabel.TextColor3
		textLabel.TextStrokeColor3 = options.TextStrokeColor or textLabel.TextStrokeColor3
		textLabel.TextStrokeTransparency = options.TextStrokeTransparency or textLabel.TextStrokeTransparency
		textLabel.Font = options.Font or textLabel.Font
		textLabel.TextSize = resolvedTextSize
		textLabel.Text = options.Text or textLabel.Text
	end

	function ESP_LIBRARY:UpdateHighlight(espObject, options)
		if not espObject or not espObject.Parent then
			return
		end
		if options.Enabled ~= nil then
			espObject.Enabled = options.Enabled
		end
		if options.FillColor ~= nil then
			espObject.FillColor = options.FillColor
		end
		if options.OutlineColor ~= nil then
			espObject.OutlineColor = options.OutlineColor
		end
		if options.FillTransparency ~= nil or options.HighlightMode ~= nil then
			applyHighlightTransparency(
				espObject,
				options.FillTransparency,
				options.HighlightMode,
				options.FillColor,
				options.OutlineColor
			)
		elseif options.OutlineTransparency ~= nil then
			espObject.OutlineTransparency = normalizeHighlightTransparency(options.OutlineTransparency)
		end
	end

	function ESP_LIBRARY:UpdateTracer(tracer, options)
		if not tracer then
			return
		end
		if options.From ~= nil then
			tracer.From = options.From
		end
		if options.To ~= nil then
			tracer.To = options.To
		end
		if options.Color ~= nil then
			tracer.Color = options.Color
		end
		if options.Thickness ~= nil then
			tracer.Thickness = options.Thickness
		end
		if options.Transparency ~= nil then
			tracer.Transparency = options.Transparency
		end
		if options.Visible ~= nil then
			tracer.Visible = options.Visible
		end
	end

	function ESP_LIBRARY:AddPlayer(plr, options)
		if not plr then
			return
		end
		local playerData = self.Players[plr.UserId] or { Connections = {} }
		playerData.plr = plr
		if options ~= nil then
			if options.Highlight then
				playerData.Highlight = self:CreateHighlight(plr.Character, options.Highlight)
			end
			if options.EspText then
				playerData.EspText = self:CreateEspText(plr.Character, options.EspText)
			end
			if options.Tracer then
				playerData.Tracer = self:CreateTracer(nil, options.Tracer)
			end
		end
		self.Players[plr.UserId] = playerData
		self:EnsureRuntime()
	end

	function ESP_LIBRARY:AddTrackingESPConnection(args)
		if args.SearchMethod == "Path" and args.Start and args.End then
			args.findobject = function()
				local root = game
				for _, p in ipairs(args.Start) do
					root = root:FindFirstChild(p)
					if not root then
						return {}
					end
				end
				local target = root
				for _, p in ipairs(args.End) do
					target = target:FindFirstChild(p)
					if not target then
						return {}
					end
				end
				return { target }
			end
		end
		local tracker = {
			Args = args,
			TrackedObjects = {},
			LastUpdate = 0,
			Active = false,
			Disconnected = false,
			_cachedObjects = nil,
			_cacheTime = 0,
			_index = 1,
		}
		function tracker:Disconnect()
			ESP_LIBRARY:DisconnectTracker(self)
		end
		table.insert(self.Trackers, tracker)
		table.insert(self.Connections, tracker)
		self:EnsureRuntime()
		return tracker
	end

	function ESP_LIBRARY:ChangePlayersUpdateDirection(args)
		local featureTable = args.FeatureTable or {}
		local roleDefs = {}
		for k, v in pairs(args) do
			if k ~= "FeatureTable" then
				local def = {}
				def.name = k
				def.Priority = tonumber(v.Priority) or math.huge
				def.ESP_Track = v.ESP_Track
				def.Highlight_Track = v.Highlight_Track
				def.Tracker_Track = v.Tracker_Track
				def.RoleDetection = v.RoleDetection
				def.Color = v.Color
				def.Text = v.Text
				def.BuildText = v.BuildText
				def._featureTable = featureTable
				table.insert(roleDefs, def)
			end
		end
		table.sort(roleDefs, function(a, b)
			if a.Priority == b.Priority then
				return tostring(a.name) < tostring(b.name)
			end
			return a.Priority < b.Priority
		end)
		self.PlayerRoleChecks = roleDefs
		if #self.PlayerRoleChecks > 0 then
			self:EnsureRuntime()
		end
	end

	function ESP_LIBRARY:UpdateAllPlayerESP()
		for userId, playerData in pairs(self.Players) do
			local plr = playerData and playerData.plr
			if not plr then
				self.Players[userId] = nil
				continue
			end
			if plr.Parent ~= services.Players then
				self:RemovePlayer(plr)
				continue
			end

			local _, color, text, matchedKey, def = self:GetPlayerRole(plr)
			local featureTable = def and def._featureTable or {}
			local espEnabled = def and resolveFeatureTrack(featureTable, def.ESP_Track) or false
			local highlightEnabled = def and resolveFeatureTrack(featureTable, def.Highlight_Track) or false
			local tracerEnabled = def and resolveFeatureTrack(featureTable, def.Tracker_Track) or false
			color = color or Color3.new(1, 1, 1)

			if def and type(def.BuildText) == "function" then
				local ok, resolvedText = pcall(def.BuildText, plr, matchedKey, def)
				if ok and type(resolvedText) == "string" and resolvedText ~= "" then
					text = resolvedText
				end
			end
			text = (type(text) == "string" and text ~= "" and text) or (plr and plr.Name) or "plr"

			self:ApplyPlayerVisuals(plr, {
				ShowBillboard = espEnabled,
				ShowHighlight = highlightEnabled,
				ShowTracer = tracerEnabled,
				Color = color,
				Text = text,
				TracerFrom = GetTracersPosition(featureTable),
				TracerThickness = GetTracerThickness(featureTable),
				HighlightTransparency = normalizeHighlightTransparency(featureTable["Highlight Transparency"]),
				HighlightMode = featureTable["Highlight Mode"] or "Outline",
				TextSize = 19 * GetEspTextScale(featureTable),
				Font = GetEspFont(featureTable),
			})
		end
	end

	function ESP_LIBRARY:ApplyPlayerVisuals(plr, opts)
		if not plr then
			return
		end
		local uid = plr.UserId
		local data = self.Players[uid]
		if not data then
			data = { Connections = {} }
			self.Players[uid] = data
		end

		local function getAdornee()
			local char = plr.Character
			if not char then
				return nil, nil
			end
			local head = char:FindFirstChild("Head")
			local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
			return head or root or char, root and root.Position or (head and head.Position) or nil
		end

		if opts.ShowBillboard then
			if not data.EspText then
				local adornee = getAdornee()
				data.EspText = self:CreateEspText(adornee, {
					Text = opts.Text or "",
					TextColor = opts.Color or Color3.new(1, 1, 1),
					Font = opts.Font or GetEspFont({}),
					TextSize = opts.TextSize or 14,
				})
			else
				self:UpdateEspText(data.EspText, {
					Text = opts.Text or "",
					TextColor = opts.Color or Color3.new(1, 1, 1),
					Font = opts.Font,
					TextSize = opts.TextSize,
				})
			end
			pcall(function()
				local adornee = getAdornee()
				if data.EspText and adornee then
					data.EspText.Adornee = adornee
					data.EspText.Enabled = true
				end
			end)
		else
			if data.EspText then
				data.EspText.Enabled = false
			end
		end

		if opts.ShowHighlight then
			if not data.Highlight then
				data.Highlight = self:CreateHighlight(plr.Character, {
					Enabled = true,
					FillColor = opts.Color or Color3.new(1, 1, 1),
					FillTransparency = opts.HighlightTransparency or 0.5,
					HighlightMode = opts.HighlightMode,
				})
			else
				self:UpdateHighlight(data.Highlight, {
					Enabled = true,
					FillColor = opts.Color or data.Highlight.FillColor,
					FillTransparency = opts.HighlightTransparency or data.Highlight.FillTransparency,
				})
				applyHighlightTransparency(data.Highlight, opts.HighlightTransparency, opts.HighlightMode)
			end
			pcall(function()
				if data.Highlight and plr.Character then
					data.Highlight.Adornee = plr.Character
					data.Highlight.Enabled = true
				end
			end)
		else
			if data.Highlight then
				data.Highlight.Enabled = false
			end
		end

		if opts.ShowTracer then
			if not data.Tracer then
				data.Tracer = self:CreateTracer(nil, {
					Visible = false,
					Color = opts.Color or Color3.new(1, 1, 1),
					Thickness = opts.TracerThickness or 1,
				})
			end
			local camera = workspace.CurrentCamera
			if camera and plr.Character then
				local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
				if root then
					local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
					if onScreen then
						local from = type(opts.TracerFrom) == "function" and opts.TracerFrom() or opts.TracerFrom
						from = from or Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
						self:UpdateTracer(data.Tracer, {
							From = from,
							To = Vector2.new(screenPos.X, screenPos.Y),
							Visible = true,
							Color = opts.Color or data.Tracer.Color,
							Thickness = opts.TracerThickness or data.Tracer.Thickness,
						})
					else
						self:UpdateTracer(data.Tracer, { Visible = false })
					end
				else
					self:UpdateTracer(data.Tracer, { Visible = false })
				end
			else
				self:UpdateTracer(data.Tracer, { Visible = false })
			end
		else
			if data.Tracer then
				data.Tracer.Visible = false
			end
		end

		if data.Connections and not data.Connections.CharacterAdded then
			data.Connections.CharacterAdded = plr.CharacterAdded:Connect(function(newChar)
				pcall(function()
					local head = newChar:FindFirstChild("Head")

					if data.EspText then
						data.EspText.Parent = ESP_TEXTS_FOLDER
						if head then
							data.EspText.Adornee = head
						end
						data.EspText.Enabled = true
					end

					if data.Highlight then
						data.Highlight.Parent = ESP_HIGHLIGHTS_FOLDER
						data.Highlight.Adornee = newChar
						data.Highlight.Enabled = true
					end

					if data.Tracer then
						data.Tracer.Visible = true
					end
				end)
			end)

			data.Connections.CharacterRemoving = plr.CharacterRemoving:Connect(function()
				pcall(function()
					if data.Highlight then
						data.Highlight.Enabled = false
						data.Highlight.Parent = nil
					end
					if data.EspText then
						data.EspText.Enabled = false
						data.EspText.Parent = nil
					end
					if data.Tracer then
						data.Tracer.Visible = false
					end
				end)
			end)
		end
	end
	function ESP_LIBRARY:PingRender()
		local function kickInstance(inst)
			if inst and inst.Parent then
				local p = inst.Parent
				inst.Parent = nil
				inst.Parent = p
			end
		end

		local function kickDrawing(drawing)
			if drawing then
				drawing.Visible = false
				drawing.Visible = true
			end
		end

		for _, playerData in pairs(self.Players) do
			kickInstance(playerData.Highlight)
			kickInstance(playerData.EspText)
			kickDrawing(playerData.Tracer)
		end

		for _, tracker in ipairs(self.Trackers) do
			for _, data in pairs(tracker.TrackedObjects) do
				kickInstance(data.Highlight)
				kickInstance(data.EspText)
				kickDrawing(data.Tracer)
			end
		end
	end
	function ESP_LIBRARY:GetPlayerRole(plr)
		if not plr then
			return "Unknown", Color3.new(1, 1, 1), nil, nil, nil
		end

		local resultRole, resultColor, resultText, resultKey, resultDef = "Unknown", Color3.new(1, 1, 1), nil, nil, nil

		for _, def in ipairs(self.PlayerRoleChecks) do
			local rd = def.RoleDetection
			local matchedKey = nil
			local chosenColor, chosenText = nil, nil

			if type(rd) == "function" then
				local ok, res = pcall(rd, plr)
				if ok and res then
					matchedKey = true
				end
			elseif typeof(rd) == "Instance" or type(rd) == "userdata" then
				if rd == plr then
					matchedKey = true
				end
			elseif type(rd) == "table" then
				for subk, detector in pairs(rd) do
					if type(detector) == "function" then
						local ok, res = pcall(detector, plr)
						if ok and res then
							matchedKey = subk
							break
						end
					elseif typeof(detector) == "Instance" or type(detector) == "userdata" then
						if detector == plr then
							matchedKey = subk
							break
						end
					elseif type(detector) == "table" then
						for _, item in ipairs(detector) do
							if item == plr or item == plr.Name then
								matchedKey = subk
								break
							end
						end
						if matchedKey then
							break
						end
					elseif type(detector) == "string" then
						if detector == plr.Name then
							matchedKey = subk
							break
						end
					end
				end
			end

			if matchedKey then
				if type(def.Color) == "table" and def.Color[matchedKey] then
					chosenColor = def.Color[matchedKey]
				else
					chosenColor = def.Color
				end
				if type(chosenColor) == "string" and def._featureTable then
					chosenColor = def._featureTable[chosenColor]
				end
				chosenColor = chosenColor or Color3.new(1, 1, 1)

				if type(def.Text) == "function" then
					local ok, resolvedText = pcall(def.Text, plr, matchedKey, def)
					if ok and type(resolvedText) == "string" and resolvedText ~= "" then
						chosenText = resolvedText
					end
				elseif type(def.Text) == "table" and def.Text[matchedKey] then
					chosenText = def.Text[matchedKey]
				elseif type(def.Text) == "string" and def.Text ~= "" then
					chosenText = def.Text
				end

				resultRole, resultColor, resultText, resultKey, resultDef =
					def.name, chosenColor, chosenText, matchedKey, def
				break
			end
		end

		return resultRole, resultColor, resultText, resultKey, resultDef
	end

	function ESP_LIBRARY:RemovePlayer(plr)
		if not plr then
			return
		end
		local uid = plr.UserId
		local data = self.Players[uid]
		if not data then
			return
		end
		if data.Connections then
			for _, conn in pairs(data.Connections) do
				pcall(function()
					if conn and conn.Disconnect then
						conn:Disconnect()
					end
				end)
			end
		end
		if data.Highlight then
			data.Highlight.Enabled = false
		end
		if data.EspText then
			data.EspText.Enabled = false
		end
		if data.Tracer then
			data.Tracer.Visible = false
		end
		self.Players[uid] = nil
	end

	function ESP_LIBRARY:ClearEsp()
		for _, playerData in pairs(self.Players) do
			if playerData.Highlight then
				self:RemoveHighlight(playerData.Highlight)
			end
			if playerData.EspText then
				self:RemoveEspText(playerData.EspText)
			end
			if playerData.Tracer then
				self:RemoveTracer(playerData.Tracer)
			end
		end
		self.Players = {}
		for _, tracker in ipairs(self.Trackers) do
			self:DisconnectTracker(tracker)
		end
		self.Trackers = {}
		self.Objects = {}
		local folder = gethui() and gethui():FindFirstChild("ESP_Holders") or game.CoreGui:FindFirstChild("ESP_Holders")
		if folder then
			folder:Destroy()
		end
	end
end

TABLE_MAIN.Movement = {}
local MovementModule = TABLE_MAIN.Movement

local Runtime = {
	Started = false,
	Connections = {},
	Originals = {
		WalkSpeed = nil,
		JumpPower = nil,
		JumpHeight = nil,
		UseJumpPower = nil,
	},
	NoclipOriginalStates = {},
	Fly = {
		Instances = {},
		Control = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 },
		LastControl = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 },
		CurrentSpeed = 0,
		ControlModule = nil,
	},
}

local function GetRig()
	local plr = services.Players.LocalPlayer
	local char = plr and plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char
		and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChild("RootPart"))
	return plr, char, hum, root
end

local function DisconnectConn(conn)
	if typeof(conn) == "RBXScriptConnection" then
		pcall(function()
			conn:Disconnect()
		end)
	end
end

local function DisconnectAllConns(connectionsTable)
	for key, conn in pairs(connectionsTable or {}) do
		DisconnectConn(conn)
		connectionsTable[key] = nil
	end
end

local function CanApply(options)
	if not options then
		return true
	end
	local predicate = options.ShouldApply
	if type(predicate) == "function" then
		local ok, result = pcall(predicate)
		return ok and result ~= false
	end
	return true
end

local function ClampValue(value, options, fallback)
	local num = tonumber(value) or fallback or 0
	local min = options and tonumber(options.MinValue)
	local max = options and tonumber(options.MaxValue)
	if min ~= nil or max ~= nil then
		num = math.clamp(num, min or num, max or num)
	end
	return num
end

MovementModule.WalkSpeed = {
	Enabled = false,
	Value = 16,
	Method = "Humanoid",
	Connections = {},
	OriginalValue = nil,
	Options = {},
}

function MovementModule:SetWalkSpeed(enabled, value, options)
	self.WalkSpeed.Enabled = enabled == true
	self.WalkSpeed.Value = tonumber(value) or self.WalkSpeed.Value or 16
	self.WalkSpeed.Options = type(options) == "table" and options or {}
	self.WalkSpeed.Method = tostring(self.WalkSpeed.Options.Mode or self.WalkSpeed.Method or "Humanoid")

	if not self.WalkSpeed.Enabled then
		self:StopWalkSpeedRuntime(true)
		return
	end

	self:StopWalkSpeedRuntime(false)

	local function applySpeed(hum, targetSpeed)
		if not hum or hum.Health <= 0 then
			return
		end
		if self.WalkSpeed.OriginalValue == nil then
			self.WalkSpeed.OriginalValue = hum.WalkSpeed
		end
		pcall(function()
			hum.WalkSpeed = targetSpeed
		end)
	end

	local function step(dt)
		if not self.WalkSpeed.Enabled or not CanApply(self.WalkSpeed.Options) then
			return
		end
		local _, char, hum, root = GetRig()
		if not char or not hum or hum.Health <= 0 then
			return
		end

		local mode = self.WalkSpeed.Method
		local target = ClampValue(self.WalkSpeed.Value, self.WalkSpeed.Options, 16)

		if mode == "Humanoid" or mode == "Legacy" then
			applySpeed(hum, target)
		elseif mode == "Translate" and hum.MoveDirection.Magnitude > 0 then
			local scale = tonumber(self.WalkSpeed.Options.TranslateScale) or 1
			pcall(function()
				char:TranslateBy(hum.MoveDirection * (target * (tonumber(dt) or 0) * scale))
			end)
		elseif mode == "Velocity" and root and hum.MoveDirection.Magnitude > 0 then
			local vel = root.AssemblyLinearVelocity
			pcall(function()
				root.AssemblyLinearVelocity = hum.MoveDirection.Unit * target + Vector3.new(0, vel.Y, 0)
			end)
		elseif mode == "Attribute" then
			local attrName = tostring(self.WalkSpeed.Options.AttributeName or "WalkSpeed")
			if char:GetAttribute(attrName) ~= target then
				pcall(function()
					char:SetAttribute(attrName, target)
				end)
			end
		end
	end

	self.WalkSpeed.Connections.Heartbeat = services.RunService.Heartbeat:Connect(step)
	self.WalkSpeed.Connections.CharacterAdded = services.Players.LocalPlayer.CharacterAdded:Connect(function()
		task.delay(0.15, function()
			if self.WalkSpeed.Enabled then
				local _, _, hum = GetRig()
				if hum then
					self.WalkSpeed.OriginalValue = nil
					if self.WalkSpeed.Method == "Humanoid" or self.WalkSpeed.Method == "Legacy" then
						applySpeed(hum, ClampValue(self.WalkSpeed.Value, self.WalkSpeed.Options, 16))
					end
				end
			end
		end)
	end)

	step(0)
end

function MovementModule:StopWalkSpeedRuntime(restore)
	DisconnectAllConns(self.WalkSpeed.Connections)
	if restore then
		local _, _, hum = GetRig()
		if hum and hum.Health > 0 then
			local resetValue = tonumber(self.WalkSpeed.Options.ResetValue)
				or tonumber(self.WalkSpeed.OriginalValue)
				or 16
			pcall(function()
				hum.WalkSpeed = resetValue
			end)
		end
	end
	self.WalkSpeed.OriginalValue = nil
end

MovementModule.JumpPower = {
	Enabled = false,
	Value = 50,
	Connections = {},
	OriginalValue = nil,
	OriginalUseJumpPower = nil,
	OriginalJumpHeight = nil,
}

function MovementModule:SetJumpPower(enabled, value)
	self.JumpPower.Enabled = enabled == true
	self.JumpPower.Value = tonumber(value) or self.JumpPower.Value or 50

	if not self.JumpPower.Enabled then
		DisconnectAllConns(self.JumpPower.Connections)
		local _, _, hum = GetRig()
		if hum and self.JumpPower.OriginalValue ~= nil then
			pcall(function()
				hum.UseJumpPower = self.JumpPower.OriginalUseJumpPower ~= false
				if hum.UseJumpPower then
					hum.JumpPower = tonumber(self.JumpPower.OriginalValue) or 50
				else
					hum.JumpHeight = tonumber(self.JumpPower.OriginalJumpHeight) or hum.JumpHeight
				end
			end)
		end
		self.JumpPower.OriginalValue = nil
		self.JumpPower.OriginalUseJumpPower = nil
		self.JumpPower.OriginalJumpHeight = nil
		return
	end

	DisconnectAllConns(self.JumpPower.Connections)

	local function applyJump(hum)
		if not hum or hum.Health <= 0 then
			return
		end
		if self.JumpPower.OriginalValue == nil then
			self.JumpPower.OriginalValue = hum.JumpPower
			self.JumpPower.OriginalUseJumpPower = hum.UseJumpPower
			self.JumpPower.OriginalJumpHeight = hum.JumpHeight
		end
		pcall(function()
			hum.UseJumpPower = true
			hum.JumpPower = self.JumpPower.Value
		end)
	end

	self.JumpPower.Connections.Heartbeat = services.RunService.Heartbeat:Connect(function()
		if self.JumpPower.Enabled then
			local _, _, hum = GetRig()
			pcall(applyJump, hum)
		end
	end)

	self.JumpPower.Connections.CharacterAdded = services.Players.LocalPlayer.CharacterAdded:Connect(function()
		task.delay(0.15, function()
			if self.JumpPower.Enabled then
				self.JumpPower.OriginalValue = nil
				local _, _, hum = GetRig()
				pcall(applyJump, hum)
			end
		end)
	end)

	local _, _, hum = GetRig()
	pcall(applyJump, hum)
end

MovementModule.Fly = {
	Enabled = false,
	Speed = 50,
	Connections = {},
	Instances = {},
}

function MovementModule:ToggleFly(enabled, speed)
	self.Fly.Enabled = enabled == true
	self.Fly.Speed = tonumber(speed) or self.Fly.Speed or 50

	local function cleanupFly()
		DisconnectAllConns(self.Fly.Connections)
		for _, inst in pairs(self.Fly.Instances) do
			pcall(function()
				if inst and inst.Parent then
					inst:Destroy()
				end
			end)
		end
		self.Fly.Instances = {}
		local _, _, hum = GetRig()
		if hum then
			pcall(function()
				hum.PlatformStand = false
			end)
		end
		pcall(function()
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end)
	end

	if not self.Fly.Enabled then
		cleanupFly()
		return
	end

	cleanupFly()

	local function startFly()
		local _, char, hum, root = GetRig()
		if not char or not root or not hum then
			return
		end

		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root

		local bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVel.Velocity = Vector3.zero
		bodyVel.Parent = root

		self.Fly.Instances.BodyGyro = bodyGyro
		self.Fly.Instances.BodyVelocity = bodyVel

		local inputState =
			{ W = false, A = false, S = false, D = false, Space = false, Ctrl = false, E = false, Q = false }
		local keyMap = {
			[Enum.KeyCode.W] = "W",
			[Enum.KeyCode.A] = "A",
			[Enum.KeyCode.S] = "S",
			[Enum.KeyCode.D] = "D",
			[Enum.KeyCode.Space] = "Space",
			[Enum.KeyCode.LeftControl] = "Ctrl",
			[Enum.KeyCode.E] = "E",
			[Enum.KeyCode.Q] = "Q",
		}

		self.Fly.Connections.InputBegan = services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			local k = keyMap[input.KeyCode]
			if k then
				inputState[k] = true
			end
		end)

		self.Fly.Connections.InputEnded = services.UserInputService.InputEnded:Connect(function(input)
			local k = keyMap[input.KeyCode]
			if k then
				inputState[k] = false
			end
		end)

		self.Fly.Connections.RenderStepped = services.RunService.RenderStepped:Connect(function()
			if not self.Fly.Enabled then
				return
			end
			local _, currentChar, currentHum, currentRoot = GetRig()
			if not currentChar or not currentRoot or not currentHum then
				return
			end

			if bodyGyro.Parent ~= currentRoot then
				bodyGyro.Parent = currentRoot
			end
			if bodyVel.Parent ~= currentRoot then
				bodyVel.Parent = currentRoot
			end

			if currentHum.Health > 0 then
				currentHum.PlatformStand = true
				currentHum.WalkSpeed = 0
			end

			local camera = workspace.CurrentCamera
			if not camera then
				return
			end

			bodyGyro.CFrame = camera.CFrame

			local forward = (inputState.W and 1 or 0) + (inputState.S and -1 or 0)
			local right = (inputState.D and 1 or 0) + (inputState.A and -1 or 0)
			local up = ((inputState.E or inputState.Space) and 1 or 0) + ((inputState.Q or inputState.Ctrl) and -1 or 0)

			local moveDir = camera.CFrame.LookVector * forward
				+ camera.CFrame.RightVector * right
				+ camera.CFrame.UpVector * up
			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit
			elseif currentHum.MoveDirection.Magnitude > 0 then
				moveDir = currentHum.MoveDirection.Unit
			end

			bodyVel.Velocity = moveDir * self.Fly.Speed
		end)
	end

	self.Fly.Connections.CharacterAdded = services.Players.LocalPlayer.CharacterAdded:Connect(function()
		task.delay(0.35, function()
			if self.Fly.Enabled then
				startFly()
			end
		end)
	end)

	startFly()
end

MovementModule.Noclip = {
	Enabled = false,
	Options = {},
	Connections = {},
}

function MovementModule:ToggleNoclip(enabled, options)
	self.Noclip.Enabled = enabled == true
	self.Noclip.Options = type(options) == "table" and options or {}

	if not self.Noclip.Enabled then
		for part, state in pairs(Runtime.NoclipOriginalStates) do
			if part and part.Parent then
				pcall(function()
					part.CanCollide = state
				end)
			end
		end
		Runtime.NoclipOriginalStates = {}
		DisconnectAllConns(self.Noclip.Connections)
		return
	end

	local _, char, _, _ = GetRig()
	if not char or not CanApply(self.Noclip.Options) then
		return
	end

	local includeRoot = self.Noclip.Options.IncludeRootPart == true

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and (includeRoot or part.Name ~= "HumanoidRootPart") then
			if Runtime.NoclipOriginalStates[part] == nil then
				Runtime.NoclipOriginalStates[part] = part.CanCollide
			end
			pcall(function()
				part.CanCollide = false
			end)
		end
	end

	self.Noclip.Connections.DescendantAdded = char.DescendantAdded:Connect(function(desc)
		if self.Noclip.Enabled and desc:IsA("BasePart") and (includeRoot or desc.Name ~= "HumanoidRootPart") then
			if Runtime.NoclipOriginalStates[desc] == nil then
				Runtime.NoclipOriginalStates[desc] = desc.CanCollide
			end
			pcall(function()
				desc.CanCollide = false
			end)
		end
	end)

	self.Noclip.Connections.Heartbeat = services.RunService.Heartbeat:Connect(function()
		if self.Noclip.Enabled and char and char.Parent then
			for part in pairs(Runtime.NoclipOriginalStates) do
				if part and part.Parent then
					pcall(function()
						part.CanCollide = false
					end)
				end
			end
		end
	end)
end

MovementModule.InfiniteJump = {
	Enabled = false,
	Connection = nil,
}

function MovementModule:ToggleInfiniteJump(enabled)
	self.InfiniteJump.Enabled = enabled == true
	if self.InfiniteJump.Enabled then
		if not self.InfiniteJump.Connection then
			self.InfiniteJump.Connection = services.UserInputService.JumpRequest:Connect(function()
				local _, _, hum = GetRig()
				if hum and hum.Health > 0 then
					pcall(function()
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end)
				end
			end)
		end
	else
		if self.InfiniteJump.Connection then
			DisconnectConn(self.InfiniteJump.Connection)
			self.InfiniteJump.Connection = nil
		end
	end
end

MovementModule.AntiFling = {
	Enabled = false,
	Connection = nil,
}

function MovementModule:ToggleAntiFling(enabled)
	self.AntiFling.Enabled = enabled == true
	if self.AntiFling.Enabled then
		if not self.AntiFling.Connection then
			local lastCheck = 0
			self.AntiFling.Connection = services.RunService.Heartbeat:Connect(function()
				local now = tick()
				if (now - lastCheck) < 0.15 then
					return
				end
				lastCheck = now

				local _, _, hum, root = GetRig()
				if not root or not hum then
					return
				end

				local lin = root.AssemblyLinearVelocity
				local ang = root.AssemblyAngularVelocity

				-- Детект подозрительной скорости
				if (lin.Magnitude > 320 and math.abs(lin.Y) > 120) or ang.Magnitude > 500 then
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					hum.PlatformStand = true
					task.wait(0.05)
					hum.PlatformStand = false
				end
			end)
		end
	else
		if self.AntiFling.Connection then
			DisconnectConn(self.AntiFling.Connection)
			self.AntiFling.Connection = nil
		end
	end
end

MovementModule.Float = {
	Enabled = false,
	Connection = nil,
}

function MovementModule:ToggleFloat(enabled)
	self.Float = self.Float or { Enabled = false, Connection = nil }
	self.Float.Enabled = enabled == true

	if self.Float.Enabled then
		if not self.Float.Connection then
			self.Float.Connection = services.RunService.Heartbeat:Connect(function()
				local char = GetLPCharacter()
				local hrp = GetLPHumpart()
				if not char or not hrp then
					return
				end

				local floatPart = workspace:FindFirstChild("Vanish_Float")
				if not floatPart then
					floatPart = Instance.new("Part")
					floatPart.Name = "Vanish_Float"
					floatPart.Anchored = true
					floatPart.CanCollide = true
					floatPart.Transparency = 1
					floatPart.Size = Vector3.new(5, 1, 5)
					floatPart.Parent = workspace
				end

				floatPart.CFrame = hrp.CFrame * CFrame.new(0, -3.1, 0)
			end)
		end
	else
		if self.Float.Connection then
			self.Float.Connection:Disconnect()
			self.Float.Connection = nil
		end
		local floatPart = workspace:FindFirstChild("Vanish_Float")
		if floatPart then
			floatPart:Destroy()
		end
	end
end

function MovementModule:StartRuntime()
	if Runtime.Started then
		return
	end
	Runtime.Started = true

	Runtime.Connections.CharacterAdded = services.Players.LocalPlayer.CharacterAdded:Connect(function()
		task.defer(function()
			if not self.Noclip.Enabled then
				for part, state in pairs(Runtime.NoclipOriginalStates) do
					if part and part.Parent then
						pcall(function()
							part.CanCollide = state
						end)
					end
				end
				Runtime.NoclipOriginalStates = {}
			end
		end)
	end)
end

function MovementModule:StopRuntime()
	pcall(function()
		self:SetWalkSpeed(false, 16)
	end)
	pcall(function()
		self:SetJumpPower(false, 50)
	end)
	pcall(function()
		self:ToggleFly(false, 50)
	end)
	pcall(function()
		self:ToggleNoclip(false)
	end)
	pcall(function()
		self:ToggleInfiniteJump(false)
	end)
	pcall(function()
		self:ToggleAntiFling(false)
	end)
	pcall(function()
		self:ToggleFloat(false)
	end)

	local function clearConnections(tbl)
		if tbl and type(tbl.Connections) == "table" then
			for key, conn in pairs(tbl.Connections) do
				pcall(function()
					conn:Disconnect()
				end)
				tbl.Connections[key] = nil
			end
		end
		if tbl then
			tbl.Started = false
		end
	end

	clearConnections(self.RuntimeHandler)
	clearConnections(self.Runtime)

	local specificConns = {
		self.WalkSpeed and self.WalkSpeed.Connections,
		self.JumpPower and self.JumpPower.Connections,
		self.Fly and self.Fly.Connections,
		self.Noclip and self.Noclip.Connections,
	}
	for _, conns in ipairs(specificConns) do
		if type(conns) == "table" then
			for key, conn in pairs(conns) do
				pcall(function()
					conn:Disconnect()
				end)
				conns[key] = nil
			end
		end
	end

	if self.InfiniteJump and self.InfiniteJump.Connection then
		pcall(function()
			self.InfiniteJump.Connection:Disconnect()
		end)
		self.InfiniteJump.Connection = nil
	end

	if self.AntiFling and self.AntiFling.Connection then
		pcall(function()
			self.AntiFling.Connection:Disconnect()
		end)
		self.AntiFling.Connection = nil
	end

	pcall(function()
		local hum = GetLPHumanoid()
		local hrp = GetLPHumpart()

		if hum then
			hum.PlatformStand = false
			hum.WalkSpeed = 16
			if hum.UseJumpPower then
				hum.JumpPower = 50
			else
				hum.JumpHeight = 7.2
			end
		end

		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			for _, obj in ipairs(hrp:GetChildren()) do
				if obj:IsA("BodyMover") or obj:IsA("VectorForce") or obj:IsA("AlignPosition") then
					obj:Destroy()
				end
			end
		end

		if workspace.CurrentCamera then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end
	end)

	pcall(function()
		local floatPart = workspace:FindFirstChild("Vanish_Float")
		if floatPart then
			floatPart:Destroy()
		end
	end)
end

local AimbotModule = {
	FOVCircle = Drawing.new("Circle"),
	Connections = {},
	Hooked = false,
	OldRaycast = nil,
}

AimbotModule.FOVCircle.Thickness = 1
AimbotModule.FOVCircle.NumSides = 60
AimbotModule.FOVCircle.Radius = 100
AimbotModule.FOVCircle.Filled = false
AimbotModule.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
AimbotModule.FOVCircle.Visible = false
AimbotModule.FOVCircle.Transparency = 0.8

local mouseMoveCarry = Vector2.zero
local lastValidTarget = nil
local targetLockTimer = 0

local function GetCurrentMousePos()
	local input = game:GetService("UserInputService")
	local ok, mousePos = pcall(function()
		return input:GetMouseLocation()
	end)
	if ok and typeof(mousePos) == "Vector2" then
		return mousePos
	end
	return Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
end

local function clampViewportPoint(point)
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	return Vector2.new(math.clamp(point.X, 0, viewport.X), math.clamp(point.Y, 0, viewport.Y))
end

local function clampVectorMagnitude(vector, maxMagnitude)
	if typeof(vector) ~= "Vector2" then
		return vector
	end
	local magnitude = vector.Magnitude
	if magnitude <= 0 or magnitude <= maxMagnitude then
		return vector
	end
	return vector.Unit * maxMagnitude
end

local function roundSigned(value)
	if value >= 0 then
		return math.floor(value + 0.5)
	end
	return math.ceil(value - 0.5)
end

local function resolveMouseMoveFunctions()
	local genv = getgenv and getgenv()
	return (genv and genv.mousemoveabs) or mousemoveabs, (genv and genv.mousemoverel) or mousemoverel
end

local function GetMouseMoveDivisor(screenDistance, fov, smooth)
	local radius = math.max(1, tonumber(fov) or 150)
	local distanceRatio = math.clamp((tonumber(screenDistance) or 0) / radius, 0, 1)
	local smoothValue = math.clamp(smooth or 0.5, 0.05, 1)
	local curved = math.sqrt(smoothValue) * 0.28
	local scaled = curved * (0.78 + (distanceRatio * 0.28))
	return math.clamp(1 / math.max(scaled, 0.035), 3, 40)
end

local function GetMouseMaxStep(screenDistance, fov)
	local radius = math.max(1, tonumber(fov) or 150)
	local distanceRatio = math.clamp((tonumber(screenDistance) or 0) / radius, 0, 1)
	return math.clamp((radius * 0.08) + (distanceRatio * radius * 0.14), 10, 64)
end

local function GetClosestPlayer(fov, teamCheck, wallCheck)
	local closest, shortestDist = nil, fov
	local mousePos = GetCurrentMousePos()
	local camera = workspace.CurrentCamera
	local lpChar = services.Players.LocalPlayer.Character

	for _, plr in ipairs(services.Players:GetPlayers()) do
		if plr ~= services.Players.LocalPlayer and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local head = plr.Character:FindFirstChild("Head")

			if hum and hum.Health > 0 and head then
				if teamCheck and AimbotModule:TeamCheck(plr, lpChar) then
					continue
				end
				local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					if dist < shortestDist then
						if wallCheck and wallCheck ~= "Disabled" then
							if not AimbotModule:CheckWall(head, wallCheck) then
								continue
							end
						end
						shortestDist = dist
						closest = plr
					end
				end
			end
		end
	end
	return closest
end

local function SmoothMoveMouseTo(targetScreenPos, smooth, deadzone, deltaTime)
	local moveAbs, moveRel = resolveMouseMoveFunctions()

	-- Проверяем, доступны ли функции мыши
	if not moveAbs and not moveRel then
		warn("[Aimbot] Mouse move functions NOT available!")
		return false
	end

	deltaTime = deltaTime or 0.016
	deltaTime = math.clamp(deltaTime, 0.001, 0.1)

	local currentPos = GetCurrentMousePos()
	local delta = targetScreenPos - currentPos

	-- Deadzone
	if delta.Magnitude <= math.max(0, tonumber(deadzone) or 0) then
		mouseMoveCarry = Vector2.zero
		return false
	end

	-- Экспоненциальное сглаживание
	local smoothFactor = math.clamp(tonumber(smooth) or 0.5, 0.05, 1)
	local smoothing = 1 - math.pow(1 - smoothFactor, deltaTime * 60)

	local targetVelocity = delta * smoothing

	-- Инерция
	local inertiaDecay = 0.85
	if mouseMoveCarry:Dot(targetVelocity) < 0 then
		mouseMoveCarry = mouseMoveCarry * 0.3
	else
		mouseMoveCarry = mouseMoveCarry * inertiaDecay
	end

	local finalVelocity = targetVelocity + mouseMoveCarry * 0.15

	-- Ограничение скорости
	local maxSpeed = 80
	if finalVelocity.Magnitude > maxSpeed then
		finalVelocity = finalVelocity.Unit * maxSpeed
	end

	local minSpeed = 0.5
	if finalVelocity.Magnitude < minSpeed and finalVelocity.Magnitude > 0 then
		finalVelocity = finalVelocity.Unit * minSpeed
	end

	mouseMoveCarry = finalVelocity - targetVelocity

	-- Применяем движение
	if moveRel then
		local relX = roundSigned(finalVelocity.X)
		local relY = roundSigned(finalVelocity.Y)

		if relX == 0 and math.abs(finalVelocity.X) >= 0.2 then
			relX = finalVelocity.X > 0 and 1 or -1
		end
		if relY == 0 and math.abs(finalVelocity.Y) >= 0.2 then
			relY = finalVelocity.Y > 0 and 1 or -1
		end

		if relX ~= 0 or relY ~= 0 then
			pcall(moveRel, relX, relY)
			return true
		end
	elseif moveAbs then
		local newPos = currentPos + finalVelocity
		local clampedPos = clampViewportPoint(newPos)
		pcall(moveAbs, math.floor(clampedPos.X + 0.5), math.floor(clampedPos.Y + 0.5))
		return true
	end

	return false
end

function AimbotModule:CheckWall(targetPart, method)
	if not targetPart or not targetPart.Parent then
		return false
	end

	local wallCheckMethod = method or Universal_Features["Universal"].Features["Aimbot Wall Check"] or "Raycast"

	if wallCheckMethod == "Disabled" then
		return true
	end

	local camera = workspace.CurrentCamera
	local localCharacter = services.Players.LocalPlayer.Character

	if wallCheckMethod == "Improved" then
		local ignoreList = { camera }
		if localCharacter then
			table.insert(ignoreList, localCharacter)
		end
		if targetPart.Parent then
			table.insert(ignoreList, targetPart.Parent)
		end

		local ok, obscuringParts = pcall(function()
			return camera:GetPartsObscuringTarget({ targetPart.Position }, ignoreList)
		end)

		if ok then
			return not obscuringParts or #obscuringParts == 0
		end
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { camera }
	if localCharacter then
		table.insert(rayParams.FilterDescendantsInstances, localCharacter)
	end
	if targetPart.Parent then
		table.insert(rayParams.FilterDescendantsInstances, targetPart.Parent)
	end

	local origin = camera.CFrame.Position
	local direction = targetPart.Position - origin

	local result = workspace:Raycast(origin, direction, rayParams)
	return result == nil or result.Instance == targetPart or result.Instance:IsDescendantOf(targetPart.Parent)
end

function AimbotModule:TeamCheck(target, lpchar)
	if not target or not target.Character then
		return false
	end

	if game.GameId == 6993600665 then
		if (lpchar and lpchar:GetAttribute("TeamColor")) and target.Character:GetAttribute("TeamColor") then
			return target.Character:GetAttribute("TeamColor") == lpchar:GetAttribute("TeamColor")
		end
	end

	if game.GameId == 7633926880 then
		return target:GetAttribute("Team") == services.Players.LocalPlayer:GetAttribute("Team")
	end

	return target.Team == services.Players.LocalPlayer.Team
end

function AimbotModule:ApplyHumanoidAimbotTo(targetPosition)
	local _, _, _, root = GetRig()
	if not root then
		return false
	end

	local flatDir = Vector3.new(targetPosition.X - root.Position.X, 0, targetPosition.Z - root.Position.Z)

	if flatDir.Magnitude > 0.1 then
		pcall(function()
			root.CFrame = CFrame.new(root.Position, root.Position + flatDir.Unit)
		end)
		return true
	end
	return false
end

function AimbotModule:ApplyAimbotTo(camera, features, targetPosition, deltaTime)
	if not camera or typeof(targetPosition) ~= "Vector3" then
		return false
	end

	local f = features or Universal_Features["Universal"].Features

	local selectedMethod = f["Aimbot Method"]
	local fov = tonumber(f["Aimbot FOV"]) or 150
	local smooth = tonumber(f["Aiming Smooth"]) or 0.5
	local deadzone = tonumber(f["Aim Assist Deadzone"]) or 0

	local targetViewport, onScreen = camera:WorldToViewportPoint(targetPosition)
	if not onScreen then
		return false
	end

	local targetScreenPos = Vector2.new(targetViewport.X, targetViewport.Y)
	local mousePos = GetCurrentMousePos()
	local screenDistance = (targetScreenPos - mousePos).Magnitude

	if selectedMethod == "Mouse Method (Abs)" or selectedMethod == "Mouse Method (Rel)" then
		return SmoothMoveMouseTo(targetScreenPos, smooth, deadzone, deltaTime)
	end

	local useHumanoidMethod = selectedMethod == "Humanoid Method" or selectedMethod == "Both"
	local useCameraMethod = selectedMethod == "Camera Method" or selectedMethod == "Both"

	if useHumanoidMethod then
		self:ApplyHumanoidAimbotTo(targetPosition)
	end

	if useCameraMethod then
		local aimCFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
		camera.CFrame = camera.CFrame:Lerp(aimCFrame, smooth)
	end

	return useHumanoidMethod or useCameraMethod
end

function AimbotModule:StartRuntime(features)
	if self.Connections.RenderStepped then
		return
	end

	self.Connections.RenderStepped = services.RunService.RenderStepped:Connect(function(deltaTime)
		local f = features or Universal_Features["Universal"].Features
		local camera = workspace.CurrentCamera

		if f["Toggle Aimbot"] and f["Show Aimbot FOV Circle"] then
			self.FOVCircle.Position = GetCurrentMousePos()
			self.FOVCircle.Radius = tonumber(f["Aimbot FOV"]) or 100
			self.FOVCircle.Visible = true
		else
			self.FOVCircle.Visible = false
		end

		if f["Toggle Aimbot"] and camera then
			local target =
				GetClosestPlayer(tonumber(f["Aimbot FOV"]) or 150, f["Aimbot Team Check"], f["Aimbot Wall Check"])
			if target and target.Character then
				local targetPart = target.Character:FindFirstChild(f["Aimbot Aim Part"])
					or target.Character:FindFirstChild("Head")
				if targetPart then
					local targetPosition = targetPart.Position
					if f["Aimbot Prediction"] > 0 then
						targetPosition = targetPosition
							+ target.Character.HumanoidRootPart.AssemblyLinearVelocity * f["Aimbot Prediction"]
					end
					self:ApplyAimbotTo(camera, f, targetPosition, deltaTime)
				end
			end
		end
	end)
end

function AimbotModule:StopRuntime()
	if self.Connections.RenderStepped then
		self.Connections.RenderStepped:Disconnect()
		self.Connections.RenderStepped = nil
	end

	self.FOVCircle.Visible = false
	mouseMoveCarry = Vector2.zero
	lastValidTarget = nil
end

_flg_msg = {}

TABLE_MAIN.LocalsLib.Locals.SavingFromVoid = false

function TABLE_MAIN.Players_Lib:FlingUser(TargetPlayer)
	local success, result = pcall(function()
		if not TargetPlayer or TargetPlayer == lp then
			return false, "Invalid target"
		end

		if TABLE_MAIN.LocalsLib.Locals.SavingFromVoid ~= false then
			return false, "Saving from void in progress"
		end

		if TABLE_MAIN.LocalsLib.Locals["flinginguser"] == true then
			return false, "Fling already in progress"
		end

		local localChar = services.Players.LocalPlayer.Character
		local localHum = localChar and localChar:FindFirstChildOfClass("Humanoid")
		local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

		local targetChar = TargetPlayer.Character
		local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
		local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

		if not localChar or not localChar.Parent then
			return false, "Local character missing"
		end
		if not localHum or not localRoot then
			return false, "Local humanoid/root missing"
		end
		if not targetChar or not targetChar.Parent then
			return false, "Target character missing"
		end
		if not targetHum or not targetRoot then
			return false, "Target humanoid/root missing"
		end
		if localHum.Health <= 0 or targetHum.Health <= 0 then
			return false, "Character is dead"
		end

		TABLE_MAIN.LocalsLib.Locals["flinginguser"] = true

		local savedState = {
			CFrame = localRoot.CFrame,
			PlatformStand = localHum.PlatformStand,
			Sit = localHum.Sit,
			AutoRotate = localHum.AutoRotate,
			Collide = localRoot.CollisionGroupId,
		}

		local oldDestroyHeight = workspace.FallenPartsDestroyHeight
		workspace.FallenPartsDestroyHeight = -math.huge

		local flingSuccess = false
		local maxDuration = 2.0
		local startTime = os.clock()
		local flingConnection

		flingConnection = services.RunService.Heartbeat:Connect(function()
			if not (localChar and localChar.Parent) or not (targetChar and targetChar.Parent) then
				flingConnection:Disconnect()
				return
			end

			if localHum.Health <= 0 or targetHum.Health <= 0 then
				flingConnection:Disconnect()
				return
			end

			local currentTargetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			if not currentTargetRoot then
				flingConnection:Disconnect()
				return
			end

			if os.clock() - startTime >= maxDuration then
				flingConnection:Disconnect()
				return
			end

			local tv = currentTargetRoot.AssemblyLinearVelocity
			local predicted = currentTargetRoot.Position + tv * 0.12

			local randomOffset = Vector3.new(math.random(-15, 15) / 10, 1.5, math.random(-15, 15) / 10)

			localRoot.CFrame = CFrame.new(predicted) * CFrame.new(randomOffset)

			localHum.PlatformStand = true
			localHum.Sit = false
			localHum.AutoRotate = false

			local kick = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
			if kick.Magnitude == 0 then
				kick = Vector3.new(1, 0, 0)
			end
			kick = kick.Unit * 650

			local launch = Vector3.new(kick.X, -2000, kick.Z)
			local spin = Vector3.new(math.random(-250, 250), math.random(-250, 250), math.random(-250, 250))

			pcall(function()
				currentTargetRoot.AssemblyLinearVelocity = launch
				currentTargetRoot.AssemblyAngularVelocity = spin
			end)

			pcall(function()
				localRoot.AssemblyLinearVelocity = launch
				localRoot.AssemblyAngularVelocity = Vector3.zero
			end)

			if currentTargetRoot.AssemblyLinearVelocity.Magnitude > 450 then
				flingSuccess = true
			end
		end)

		local function cleanup()
			pcall(function()
				workspace.FallenPartsDestroyHeight = oldDestroyHeight

				if localRoot and localRoot.Parent then
					localRoot.CFrame = savedState.CFrame
				end
				if localHum and localHum.Parent then
					localHum.PlatformStand = savedState.PlatformStand
					localHum.Sit = savedState.Sit
					localHum.AutoRotate = savedState.AutoRotate
				end

				TABLE_MAIN.Players_Lib:FixVelocity()
				TABLE_MAIN.LocalsLib.Locals["flinginguser"] = false
			end)
		end

		task.delay(maxDuration + 0.5, cleanup)

		return true, "Fling started"
	end)

	if not success then
		warn("[Vanish] FlingUser error:", result)
		TABLE_MAIN.LocalsLib.Locals["flinginguser"] = false
	end

	return result
end
function UnloadScript()
	local function disconnect(connection)
		if not connection then
			return
		end
		if typeof(connection) == "RBXScriptConnection" then
			pcall(function()
				connection:Disconnect()
			end)
			return
		end
		if type(connection) == "table" and type(connection.Disconnect) == "function" then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	local function remove_ingame(instance)
		if typeof(instance) ~= "Instance" or not instance.Parent then
			return
		end
		pcall(function()
			instance:Destroy()
		end)
	end

	local function clear_table(tbl)
		if type(tbl) ~= "table" then
			return
		end
		pcall(function()
			table.clear(tbl)
		end)
	end

	_G.Vanish_Universal_Loading = nil
	_G.Vanish_Universal_Loaded = nil

	pcall(function()
		if type(Universal_Features) == "table" then
			local features = Universal_Features["Universal"].Features
			if type(features) == "table" then
				for featureName, featureValue in pairs(features) do
					if
						type(featureValue) == "boolean"
						and featureName ~= "Auto Save Features"
						and featureName ~= "Auto Save Feature"
					then
						features[featureName] = false
					end
				end
			end
		end
	end)

	pcall(function()
		local specialValues = TABLE_MAIN and TABLE_MAIN.SpecialValues
		if type(specialValues) == "table" and type(specialValues.clear_void) == "function" then
			specialValues.clear_void()
		end
	end)

	pcall(function()
		if type(UiLibrary) == "table" and type(UiLibrary.ClearMobileButtons) == "function" then
			UiLibrary:ClearMobileButtons()
		end
		for i, v in pairs(UiLibrary.ConnectionsList) do
			v:Disconnect()
			v = nil
		end
	end)

	pcall(function()
		if lp.Character then
			if
				lp.Character:FindFirstChildOfClass("Tool")
				and lp.Character:FindFirstChildOfClass("Tool"):GetAttribute("___") == true
			then
				remove_ingame(lp.Character:FindFirstChildOfClass("Tool"))
			end
			if
				lp.Backpack:FindFirstChildOfClass("Tool")
				and lp.Backpack:FindFirstChildOfClass("Tool"):GetAttribute("___") == true
			then
				remove_ingame(lp.Backpack:FindFirstChildOfClass("Tool"))
			end
		end
	end)

	pcall(function()
		local character = get_character()
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = get_humanoidrootpart()
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			root.Velocity = Vector3.zero
			root.RotVelocity = Vector3.zero
		end
		if humanoid then
			humanoid.PlatformStand = false
			humanoid.WalkSpeed = 16
			if humanoid.UseJumpPower then
				humanoid.JumpPower = 50
			else
				humanoid.JumpHeight = 7.2
			end
		end
		if camera and camera.Parent then
			camera.FieldOfView = 70
			camera.CameraType = Enum.CameraType.Custom
			if humanoid then
				camera.CameraSubject = humanoid
			end
		end
	end)

	pcall(function()
		local lighting = services and services.Lighting or game:GetService("Lighting")
		local restore = _G.FullBrightSetup and _G.FullBrightSetup.Off
		if type(restore) == "table" then
			if restore.Brightness ~= nil then
				lighting.Brightness = restore.Brightness
			end
			if restore.ClockTime ~= nil then
				lighting.ClockTime = restore.ClockTime
			end
			if restore.FogEnd ~= nil then
				lighting.FogEnd = restore.FogEnd
			end
			if restore.FogStart ~= nil then
				lighting.FogStart = restore.FogStart
			end
			if restore.GlobalShadows ~= nil then
				lighting.GlobalShadows = restore.GlobalShadows
			end
			if typeof(restore.OutdoorAmbient) == "Color3" then
				lighting.OutdoorAmbient = restore.OutdoorAmbient
			end
			if typeof(restore.Ambient) == "Color3" then
				lighting.Ambient = restore.Ambient
			end
		end
	end)

	pcall(function()
		remove_ingame(workspace:FindFirstChild("FloatExploit"))
		remove_ingame(workspace:FindFirstChild("L"))
		remove_ingame(workspace:FindFirstChild("Vanish_Forsaken_AutoBlockTriggers", true))
		remove_ingame(workspace:FindFirstChild("Alice_Tentacles"))
	end)

	pcall(function()
		local specialValues = TABLE_MAIN and TABLE_MAIN.SpecialValues
		remove_ingame(specialValues and specialValues.FPES_TimerGui)
		remove_ingame(specialValues and specialValues.FPES_ESPFolder)
		remove_ingame(specialValues and specialValues.FPES_AliceTentacleFolder)
		remove_ingame(specialValues and specialValues.HiderBarriers)
		local universalFovCircle = specialValues and specialValues.AimbotRuntimeFOVCircle
		if universalFovCircle then
			pcall(function()
				universalFovCircle.Visible = false
			end)
			pcall(function()
				universalFovCircle:Remove()
			end)
			remove_ingame(universalFovCircle)
			specialValues.AimbotRuntimeFOVCircle = nil
		end
	end)

	pcall(function()
		local specialConnections = TABLE_MAIN and TABLE_MAIN.SpecialConnections
		if type(specialConnections) == "table" and specialConnections.Aimbot_Tween then
			pcall(function()
				specialConnections.Aimbot_Tween:Cancel()
			end)
			specialConnections.Aimbot_Tween = nil
		end
	end)

	pcall(function()
		if type(change_hitbox) == "function" then
			for _, plr in ipairs(Players:GetPlayers()) do
				change_hitbox(plr)
			end
		end
	end)

	pcall(function()
		local roots = {}
		local hui = gethui and gethui() or nil
		if hui then
			table.insert(roots, hui)
		end
		if game.CoreGui then
			table.insert(roots, game.CoreGui)
		end
		if lp and lp:FindFirstChild("PlayerGui") then
			table.insert(roots, lp.PlayerGui)
		end
		for _, root in ipairs(roots) do
			remove_ingame(root:FindFirstChild("VanishMobileButtons"))
			remove_ingame(root:FindFirstChild("VanishNotifications"))
			remove_ingame(root:FindFirstChild("TimerGUI"))
		end
	end)

	pcall(function()
		local connections = TABLE_MAIN and TABLE_MAIN.ConnectionLib and TABLE_MAIN.ConnectionLib.Connects
		if type(connections) == "table" then
			for key, connection in pairs(connections) do
				disconnect(connection)
				connections[key] = nil
			end
		end
		if TABLE_MAIN and TABLE_MAIN.ConnectionLib then
			TABLE_MAIN.ConnectionLib.Connects = {}
		end
	end)

	pcall(function()
		if TABLE_MAIN and type(TABLE_MAIN.SpecialConnections) == "table" then
			for key, connection in pairs(TABLE_MAIN.SpecialConnections) do
				disconnect(connection)
				TABLE_MAIN.SpecialConnections[key] = nil
			end
		end
	end)

	pcall(function()
		if TABLE_MAIN and TABLE_MAIN.LocalsLib and type(TABLE_MAIN.LocalsLib.Clear) == "function" then
			TABLE_MAIN.LocalsLib:Clear()
		end
	end)

	pcall(function()
		if type(UiLibrary) == "table" and type(UiLibrary.Features_Table) == "table" then
			table.clear(UiLibrary.Features_Table)
		end
		clear_table(DragTable)
	end)

	pcall(function()
		if type(ESP_LIBRARY) == "table" then
			if type(ESP_LIBRARY.ClearEsp) == "function" then
				ESP_LIBRARY:ClearEsp()
			end
			disconnect(ESP_LIBRARY.RuntimeConnection)
			ESP_LIBRARY.RuntimeConnection = nil
			disconnect(ESP_LIBRARY.PlayerUpdateConnection)
			ESP_LIBRARY.PlayerUpdateConnection = nil
			if type(ESP_LIBRARY.Connections) == "table" then
				for key, connection in pairs(ESP_LIBRARY.Connections) do
					disconnect(connection)
					ESP_LIBRARY.Connections[key] = nil
				end
			end
			ESP_LIBRARY.Players = {}
			ESP_LIBRARY.Objects = {}
			ESP_LIBRARY.Trackers = {}
			ESP_LIBRARY.PlayerRoleChecks = {}
			ESP_LIBRARY.LastPlayersUpdate = 0
			ESP_LIBRARY.PlayerVisualsActive = false
		end
	end)

	pcall(function()
		if TABLE_MAIN and type(TABLE_MAIN.SpecialValues) == "table" then
			for key, value in pairs(TABLE_MAIN.SpecialValues) do
				if type(value) == "table" then
					clear_table(value)
				end
				TABLE_MAIN.SpecialValues[key] = nil
			end
		end
		TABLE_MAIN.SpecialValues = {}
		TABLE_MAIN.SpecialConnections = {}
	end)
	pcall(function()
		if AimbotModule and type(AimbotModule.StopRuntime) == "function" then
			AimbotModule:StopRuntime()
		end
		if AimbotModule and AimbotModule.FOVCircle then
			pcall(function()
				AimbotModule.FOVCircle:Remove()
			end)
		end
	end)
	pcall(function()
		if MovementModule and type(MovementModule.StopRuntime) == "function" then
			MovementModule:StopRuntime()
		end
	end)
	pcall(function()
		workspace.CurrentCamera.FieldOfView = 70
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
	pcall(function()
		local floatPart = workspace:FindFirstChild("Vanish_Float")
		if floatPart then
			floatPart:Destroy()
		end
	end)
	if type(cleardrawcache) == "function" then
		task.defer(cleardrawcache)
	end
end
function Initialize()
	features_tbl = Universal_Features["Universal"].Features
	local _fireproximityprompt = (
		not getexecutorname():find("Xeno")
		and not identifyexecutor():lower():find("solara")
		and fireproximityprompt ~= nil
	)
			and fireproximityprompt
		or function(pp)
			local oldenabled = pp.Enabled
			local oldhold = pp.HoldDuration
			local oldrlos = pp.RequiresLineOfSight
			pp.Enabled = true
			pp.HoldDuration = 0
			pp.RequiresLineOfSight = false
			wait(0.2)
			pp:InputHoldBegin()
			services.RunService.RenderStepped:Wait()
			pp:InputHoldEnd()
			wait(0.1)
			pp.Enabled = pp.Enabled
			pp.HoldDuration = pp.HoldDuration
			pp.RequiresLineOfSight = pp.RequiresLineOfSight
		end
	local touchinterest_alternative = function(toTouch, TouchWith, on)
		if on == 0 then
			return
		end
		if toTouch.ClassName == "TouchTransmitter" then
			local function get()
				local classes = {
					"BasePart",
					"Part",
					"MeshPart",
				}
				for _, v in pairs(classes) do
					if toTouch:FindFirstAncestorOfClass(v) then
						return toTouch:FindFirstAncestorOfClass(v)
					end
				end
			end
			toTouch = get()
		end
		local cf = toTouch.CFrame
		local anc = toTouch.CanCollide
		toTouch.CanCollide = false
		toTouch.CFrame = TouchWith.CFrame
		services.RunService.RenderStepped:Wait()
		toTouch.CanCollide = false
		services.RunService.RenderStepped:Wait()
		toTouch.CanCollide = false
		services.RunService.RenderStepped:Wait()
		toTouch.CFrame = cf
		toTouch.CanCollide = anc
	end

	local espMode = features_tbl["ESP Mode"]

	local function IsTeammate(player)
		if lp.Character == nil then
			return true
		end
		return AimbotModule:TeamCheck(player, lp.Character)
	end

	ESP_LIBRARY.PlayerRoleChecks = {}

	if espMode == "All Players" then
		ESP_LIBRARY:ChangePlayersUpdateDirection({
			FeatureTable = features_tbl,
			["AllPlayers"] = {
				Priority = 1,
				ESP_Track = "ESP Enabled",
				Highlight_Track = "Highlight Enabled",
				Tracker_Track = "Tracers Enabled",
				RoleDetection = function(player)
					return player ~= services.Players.LocalPlayer
				end,
				Color = "ESP Color",
				Text = function(player)
					return player and player.Name or ""
				end,
			},
		})
	elseif espMode == "Team Check" then
		ESP_LIBRARY:ChangePlayersUpdateDirection({
			FeatureTable = features_tbl,
			["Teammates"] = {
				Priority = 1,
				ESP_Track = "ESP Enabled",
				Highlight_Track = "Highlight Enabled",
				Tracker_Track = "Tracers Enabled",
				RoleDetection = function(player)
					return features_tbl["ESP Team Check"] and IsTeammate(player)
				end,
				Color = "ESP Teammate Color",
				Text = function(player)
					return player and ("[Team] " .. player.Name) or ""
				end,
			},
			["Enemies"] = {
				Priority = 2,
				ESP_Track = "ESP Enabled",
				Highlight_Track = "Highlight Enabled",
				Tracker_Track = "Tracers Enabled",
				RoleDetection = function(player)
					return features_tbl["ESP Team Check"] and not IsTeammate(player)
				end,
				Color = "ESP Color",
				Text = function(player)
					return player and ("[Enemy] " .. player.Name) or ""
				end,
			},
		})
	end

	for i, v in pairs(Players:GetPlayers()) do
		if v ~= lp then
			ESP_LIBRARY:AddPlayer(v)
		end
	end
	TABLE_MAIN.ConnectionLib.Connects.ESP_AddedPlayer = Players.PlayerAdded:Connect(function(a)
		ESP_LIBRARY:AddPlayer(a)
	end)
	TABLE_MAIN.ConnectionLib.Connects.ESP_RemovedPlayer = Players.PlayerRemoving:Connect(function(a)
		ESP_LIBRARY:RemovePlayer(a)
	end)

	local Window = UiLibrary:MakeWindow({
		Title = "Vanish Universal | Remastered",
		SubTitle = "v" .. TABLE_MAIN.Main_Features.Version,
		Theme = features_tbl.Theme,
		Unload = UnloadScript,
	})

	local Tabs = {}

	Tabs.Main = Window:MakeTab({ "Main", "Home" })
	Tabs.Main:AddInformation({ TABLE_MAIN.ChangeLogs, "v" .. TABLE_MAIN.Main_Features.Version })
	Tabs.Movement = Window:MakeTab({ "Movement", "user" })
	Tabs.Visual = Window:MakeTab({ "Visuals", "eye" })
	Tabs.Combat = Window:MakeTab({ "Combat", "crosshair" })
	Tabs.Server = Window:MakeTab({ "Server", "globe" })
	Tabs.Settings = Window:MakeTab({ "Settings", "settings" })

	local MovSec = Tabs.Movement:AddElementsSection({ "Movement", "Modify your character" })

	MovSec:AddToggle({
		Name = "WalkSpeed Toggle",
		Default = features_tbl["WalkSpeed Toggle"],
		Callback = function(val)
			UpdateFeature("Universal", "WalkSpeed Toggle", val)
			MovementModule:SetWalkSpeed(val, features_tbl["WalkSpeed Value"])
		end,
	})
	MovSec:AddSlider({
		Name = "WalkSpeed Value",
		Default = features_tbl["WalkSpeed Value"],
		MinValue = 16,
		MaxValue = 150,
		Callback = function(val)
			UpdateFeature("Universal", "WalkSpeed Value", val)
			MovementModule:SetWalkSpeed(features_tbl["WalkSpeed Toggle"], val)
		end,
	})
	MovSec:AddToggle({
		Name = "Fly Toggle",
		Default = features_tbl["Fly Toggle"],
		Callback = function(val)
			UpdateFeature("Universal", "Fly Toggle", val)
			MovementModule:ToggleFly(val, features_tbl["Fly Speed"])
		end,
	})
	MovSec:AddSlider({
		"Fly Speed",
		features_tbl["Fly Speed"],
		50,
		1000,
		function(val)
			UpdateFeature("Universal", "Fly Speed", val)
		end,
		25,
	})
	MovSec:AddToggle({
		Name = "Noclip",
		Default = features_tbl.Noclip,
		Callback = function(val)
			UpdateFeature("Universal", "Noclip", val)
			MovementModule:ToggleNoclip(val)
		end,
	})
	MovSec:AddToggle({
		Name = "Infinite Jump",
		Default = features_tbl["Infinite Jump"],
		Callback = function(val)
			UpdateFeature("Universal", "Infinite Jump", val)
			MovementModule:ToggleInfiniteJump(val)
		end,
	})

	local EspSec = Tabs.Visual:AddElementsSection({ "ESP Players", "Visual enhancements" })

	-- Режим ESP
	EspSec:AddDropdown({
		"ESP Mode",
		features_tbl["ESP Mode"] or "All Players",
		{
			"All Players", -- На всех
			"Team Check", -- С проверкой команды (можно менять цвета)
		},
		function(val)
			UpdateFeature("Universal", "ESP Mode", val)
			if val == "All Players" then
				ESP_LIBRARY:ChangePlayersUpdateDirection({
					FeatureTable = features_tbl,
					["AllPlayers"] = {
						Priority = 1,
						ESP_Track = "ESP Enabled",
						Highlight_Track = "Highlight Enabled",
						Tracker_Track = "Tracers Enabled",
						RoleDetection = function(player)
							return player ~= services.Players.LocalPlayer
						end,
						Color = "ESP Color",
						Text = function(player)
							return player and player.Name or ""
						end,
					},
				})
			elseif val == "Team Check" then
				ESP_LIBRARY:ChangePlayersUpdateDirection({
					FeatureTable = features_tbl,
					["Teammates"] = {
						Priority = 1,
						ESP_Track = "ESP Enabled",
						Highlight_Track = "Highlight Enabled",
						Tracker_Track = "Tracers Enabled",
						RoleDetection = function(player)
							return features_tbl["ESP Team Check"] and IsTeammate(player)
						end,
						Color = "ESP Teammate Color",
						Text = function(player)
							return player and ("[Team] " .. player.Name) or ""
						end,
					},
					["Enemies"] = {
						Priority = 2,
						ESP_Track = "ESP Enabled",
						Highlight_Track = "Highlight Enabled",
						Tracker_Track = "Tracers Enabled",
						RoleDetection = function(player)
							return features_tbl["ESP Team Check"] and not IsTeammate(player)
						end,
						Color = "ESP Color",
						Text = function(player)
							return player and ("[Enemy] " .. player.Name) or ""
						end,
					},
				})
			end
		end,
	})

	EspSec:AddColorPicker({
		Name = "ESP Color",
		Default = features_tbl["ESP Color"] or Color3.fromRGB(255, 0, 0),
		Callback = function(val)
			UpdateFeature("Universal", "ESP Color", val)
		end,
	})

	EspSec:AddColorPicker({
		Name = "ESP Teammate Color",
		Default = features_tbl["ESP Teammate Color"] or Color3.fromRGB(0, 0, 255),
		Callback = function(val)
			UpdateFeature("Universal", "ESP Teammate Color", val)
		end,
	})

	EspSec:AddToggle({
		Name = "ESP Team Check",
		Default = features_tbl["ESP Team Check"],
		Callback = function(val)
			UpdateFeature("Universal", "ESP Team Check", val)
		end,
	})

	EspSec:AddToggle({
		Name = "ESP Enabled",
		Default = features_tbl["ESP Enabled"],
		Callback = function(val)
			UpdateFeature("Universal", "ESP Enabled", val)
		end,
	})

	EspSec:AddDropdown({
		"ESP Font",
		features_tbl["Esp Font"] or "BuilderSansBold",
		{ "BuilderSansBold", "BuilderSans", "Roboto", "RobotoMono", "Gotham", "GothamBold", "Code", "FredokaOne" },
		function(val)
			UpdateFeature("Universal", "Esp Font", val)
		end,
	})
	EspSec:AddSlider({
		"ESP Text Size",
		features_tbl["Esp Text Size"] or 1,
		0.5,
		3,
		function(val)
			UpdateFeature("Universal", "Esp Text Size", val)
		end,
		0.1,
	})

	EspSec:AddToggle({
		Name = "Show Distance",
		Default = features_tbl["ESP Show Distance"],
		Callback = function(val)
			UpdateFeature("Universal", "ESP Show Distance", val)
		end,
	})
	EspSec:AddToggle({
		Name = "Show Health",
		Default = features_tbl["ESP Show Health"],
		Callback = function(val)
			UpdateFeature("Universal", "ESP Show Health", val)
		end,
	})
	EspSec:AddToggle({
		Name = "Show Name",
		Default = features_tbl["ESP Show Name"],
		Callback = function(val)
			UpdateFeature("Universal", "ESP Show Name", val)
		end,
	})

	-- Highlight
	EspSec:AddToggle({
		Name = "Highlight Enabled",
		Default = features_tbl["Highlight Enabled"],
		Callback = function(val)
			UpdateFeature("Universal", "Highlight Enabled", val)
		end,
	})

	EspSec:AddDropdown({
		"Highlight Mode",
		features_tbl["Highlight Mode"] or "Outline",
		{ "Outline", "Fill", "Both" },
		function(val)
			UpdateFeature("Universal", "Highlight Mode", val)
		end,
	})

	EspSec:AddSlider({
		"Highlight Transparency",
		features_tbl["Highlight Transparency"] or 50,
		0,
		100,
		function(val)
			UpdateFeature("Universal", "Highlight Transparency", val)
		end,
		1,
	})

	-- Tracers
	EspSec:AddToggle({
		Name = "Tracers Enabled",
		Default = features_tbl["Tracers Enabled"],
		Callback = function(val)
			UpdateFeature("Universal", "Tracers Enabled", val)
		end,
	})

	EspSec:AddDropdown({
		"Tracer Position",
		features_tbl["Tracer Position"] or "Under Screen",
		{ "Under Screen", "Center Screen", "Bottom Screen" },
		function(val)
			UpdateFeature("Universal", "Tracer Position", val)
		end,
	})

	EspSec:AddSlider({
		"Tracer Thickness",
		features_tbl["Tracer Thickness"] or 1,
		1,
		8,
		function(val)
			UpdateFeature("Universal", "Tracer Thickness", val)
		end,
		0.25,
	})

	local AimSec = Tabs.Combat:AddElementsSection({ "Aimbot", "Aim assistance" })

	AimSec:AddToggle({
		Name = "Toggle Aimbot",
		Default = features_tbl["Toggle Aimbot"],
		Callback = function(val)
			UpdateFeature("Universal", "Toggle Aimbot", val)
		end,
	})
	AimSec:AddKeybind({
		"Aimbot Keybind",
		features_tbl["Aimbot Keybind"] or "F",
		function(val)
			UpdateFeature("Universal", "Aimbot Keybind", val)
		end,
	})
	AimSec:AddSlider({
		Name = "Aimbot FOV",
		Default = features_tbl["Aimbot FOV"],
		MinValue = 10,
		MaxValue = 500,
		Callback = function(val)
			UpdateFeature("Universal", "Aimbot FOV", val)
		end,
	})
	AimSec:AddToggle({
		Name = "Show Aimbot FOV Circle",
		Default = features_tbl["Show Aimbot FOV Circle"],
		Callback = function(val)
			UpdateFeature("Universal", "Show Aimbot FOV Circle", val)
		end,
	})
	AimSec:AddColorPicker({
		Name = "FOV Circle Color",
		Default = features_tbl["Aimbot FOV Color"] or Color3.fromRGB(255, 255, 255),
		Callback = function(val)
			UpdateFeature("Universal", "Aimbot FOV Color", val)
		end,
	})
	AimSec:AddSlider({
		"FOV Circle Thickness",
		features_tbl["Aimbot FOV Thickness"] or 1,
		1,
		5,
		function(val)
			UpdateFeature("Universal", "Aimbot FOV Thickness", val)
		end,
		0.5,
	})
	AimSec:AddToggle({
		Name = "FOV Circle Filled",
		Default = features_tbl["Aimbot FOV Filled"],
		Callback = function(val)
			UpdateFeature("Universal", "Aimbot FOV Filled", val)
		end,
	})
	AimSec:AddSlider({
		"FOV Circle Sides",
		features_tbl["Aimbot FOV Sides"] or 60,
		10,
		120,
		function(val)
			UpdateFeature("Universal", "Aimbot FOV Sides", val)
		end,
		1,
	})
	AimSec:AddDropdown({
		"Aimbot Wall Check",
		features_tbl["Aimbot Wall Check"],
		{
			"Raycast",
			"Improved",
			"Disabled",
		},
		function(val)
			UpdateFeature("Universal", "Aimbot Wall Check", val)
		end,
	})
	AimSec:AddToggle({
		Name = "Aimbot Team Check",
		Default = features_tbl["Aimbot Team Check"],
		Callback = function(val)
			UpdateFeature("Universal", "Aimbot Team Check", val)
		end,
	})
	AimSec:AddSlider({
		"Aiming Smooth",
		features_tbl["Aiming Smooth"] or 0.5,
		0.05, -- Min
		1, -- Max
		function(val)
			UpdateFeature("Universal", "Aiming Smooth", val)
		end,
		0.05, -- Increase (шаг)
	})

	AimSec:AddSlider({
		"Aimbot Prediction",
		features_tbl["Aimbot Prediction"] or 0,
		0,
		1,
		function(val)
			UpdateFeature("Universal", "Aimbot Prediction", val)
		end,
		0.01,
	})

	AimSec:AddDropdown({
		"Aimbot Method",
		features_tbl["Aimbot Method"],
		{
			"Camera Method",
			"Humanoid Method",
			"Mouse Method (Abs)",
			"Mouse Method (Rel)",
		},
		function(val)
			UpdateFeature("Universal", "Aimbot Method", val)
		end,
	})

	AimSec:AddDropdown({
		"Aim Part",
		features_tbl["Aimbot Aim Part"] or "Head",
		{ "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso" },
		function(val)
			UpdateFeature("Universal", "Aimbot Aim Part", val)
		end,
	})

	local SilentSec = Tabs.Combat:AddElementsSection({ "Silent Aim", "Bypass aim requirements" })
	SilentSec:AddToggle({
		Name = "Toggle Silent Aim",
		Default = features_tbl["Toggle Silent Aim"],
		Callback = function(val)
			UpdateFeature("Universal", "Toggle Silent Aim", val)
		end,
	})
	AimbotModule:StartRuntime(features_tbl)
	return true
end
if Universal_Features["Universal"].Working == false then
	_G.Vanish_Universal_Loading = nil
	_G.Vanish_Universal_Loaded = nil
	_err("Universal Script doesnt working at this moment! Wait for hotfix or others updates!", 5)
	return
end
if Universal_Features["Universal"].Development == true then
	_wrn("Universal script currently in development, but you can still use this script!")
end
local loading, r = pcall(Initialize)
if not loading then
	logCrash("Main-Statement", r)
end
