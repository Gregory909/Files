--[[
	Vanish UI Library
	Сама UI библиотека, что используется в Vanish Main и Universal. Она обычно загружается в файле на junkie, поэтому в тех скриптах обычно применяется следующая локализация:
	`local UiLibrary = loadstring(...)`
	и сам данный исходный код загружается
]]

local UiLibrary = (function()
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local TextService = game:GetService("TextService")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local lp = Players.LocalPlayer
	local Library = { Features_Table = {}, ConnectionsList = {} }
	local uncCheckCache = {}
	local CheckingFunctions = {
		{
			Name = print",
			Check = function()
				local p,a = pcall(function()
					print("test")
				end)
				return p and true or false
			end,
		},
		{
			Name = "require",
			Check = function()
				return require ~= nil and typeof(require) == "function"
			end,
		}
	}
	local function RunCheckingFunctions(requirement)
		if uncCheckCache[requirement.Name] ~= nil then
			return uncCheckCache[requirement.Name]
		end

		local ok, result = pcall(requirement.Check)
		result = ok and result or false
		uncCheckCache[requirement.Name] = result

		return result
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

	local Camera = workspace.CurrentCamera
	local Lucide =
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Gregory909/Files/refs/heads/main/Icons.lua"))()
	local spr = (function()
		local STRICT_RUNTIME_TYPES = true
		local SLEEP_OFFSET_SQ_LIMIT = 6.781684027777778E-8
		local SLEEP_VELOCITY_SQ_LIMIT = 1E-4
		local SLEEP_ROTATION_OFFSET = math.rad(0.01)
		local SLEEP_ROTATION_VELOCITY = math.rad(0.1)
		local EPS = 1e-5
		local AXIS_MATRIX_EPS = 1e-6
		local pi = math.pi
		local exp = math.exp
		local sin = math.sin
		local cos = math.cos
		local min = math.min
		local sqrt = math.sqrt
		local round = math.round

		local function magnitudeSq(vec: { number })
			local out = 0

			for _, v in vec do
				out += v ^ 2
			end

			return out
		end
		local function distanceSq(vec0: { number }, vec1: { number })
			local out = 0

			for i0, v0 in vec0 do
				out += (vec1[i0] - v0) ^ 2
			end

			return out
		end

		type TypeMetadata<T> = {
			springType: (
				dampingRatio: number,
				frequency: number,
				pos: number,
				typedat: TypeMetadata<T>,
				rawTarget: T
			) -> LinearSpring<T>,
			toIntermediate: (T) -> { number },
			fromIntermediate: ({ number }) -> T,
		}

		local LinearSpring = {}

		type LinearSpring<T> = typeof(setmetatable(
			{} :: {
				d: number,
				f: number,
				g: { number },
				p: { number },
				v: { number },
				typedat: TypeMetadata<T>,
				rawTarget: T,
			},
			LinearSpring
		))

		do
			LinearSpring.__index = LinearSpring

			function LinearSpring.new<T>(dampingRatio: number, frequency: number, pos: T, rawGoal: T, typedat)
				local linearPos = typedat.toIntermediate(pos)

				return setmetatable({
					d = dampingRatio,
					f = frequency,
					g = linearPos,
					p = linearPos,
					v = table.create(#linearPos, 0),
					typedat = typedat,
					rawGoal = rawGoal,
				}, LinearSpring)
			end
			function LinearSpring.setGoal<T>(self, goal: T)
				self.rawGoal = goal
				self.g = self.typedat.toIntermediate(goal)
			end
			function LinearSpring.setDampingRatio<T>(self: LinearSpring<T>, dampingRatio: number)
				self.d = dampingRatio
			end
			function LinearSpring.setFrequency<T>(self: LinearSpring<T>, frequency: number)
				self.f = frequency
			end
			function LinearSpring.canSleep<T>(self)
				if magnitudeSq(self.v) > SLEEP_VELOCITY_SQ_LIMIT then
					return false
				end
				if distanceSq(self.p, self.g) > SLEEP_OFFSET_SQ_LIMIT then
					return false
				end

				return true
			end
			function LinearSpring.step<T>(self: LinearSpring<T>, dt: number)
				local d = self.d
				local f = self.f * 2 * pi
				local g = self.g
				local p = self.p
				local v = self.v

				if d == 1 then
					local q = exp(-f * dt)
					local w = dt * q
					local c0 = q + w * f
					local c2 = q - w * f
					local c3 = w * f * f

					for idx = 1, #p do
						local o = p[idx] - g[idx]

						p[idx] = o * c0 + v[idx] * w + g[idx]
						v[idx] = v[idx] * c2 - o * c3
					end
				elseif d < 1 then
					local q = exp(-d * f * dt)
					local c = sqrt(1 - d * d)
					local i = cos(dt * f * c)
					local j = sin(dt * f * c)
					local z

					if c > EPS then
						z = j / c
					else
						local a = dt * f

						z = a + ((a * a) * (c * c) * (c * c) / 20 - c * c) * (a * a * a) / 6
					end

					local y

					if f * c > EPS then
						y = j / (f * c)
					else
						local b = f * c

						y = dt + ((dt * dt) * (b * b) * (b * b) / 20 - b * b) * (dt * dt * dt) / 6
					end

					for idx = 1, #p do
						local o = p[idx] - g[idx]

						p[idx] = (o * (i + z * d) + v[idx] * y) * q + g[idx]
						v[idx] = (v[idx] * (i - z * d) - o * (z * f)) * q
					end
				else
					local c = sqrt(d * d - 1)
					local r1 = -f * (d - c)
					local r2 = -f * (d + c)
					local ec1 = exp(r1 * dt)
					local ec2 = exp(r2 * dt)

					for idx = 1, #p do
						local o = p[idx] - g[idx]
						local co2 = (v[idx] - o * r1) / (2 * f * c)
						local co1 = ec1 * (o - co2)

						p[idx] = co1 + co2 * ec2 + g[idx]
						v[idx] = co1 * r1 + co2 * ec2 * r2
					end
				end

				return self.typedat.fromIntermediate(self.p)
			end
		end

		local RotationSpring = {}

		type RotationSpring = typeof(setmetatable(
			{} :: { d: number, f: number, g: CFrame, p: CFrame, v: Vector3 },
			RotationSpring
		))

		do
			RotationSpring.__index = RotationSpring

			local function angleBetween(c0: CFrame, c1: CFrame)
				local _, angle = (c1:ToObjectSpace(c0)):ToAxisAngle()

				return math.abs(angle)
			end
			local function matrixToAxis(m: CFrame)
				local axis, angle = m:ToAxisAngle()

				return axis * angle
			end
			local function axisToMatrix(v: Vector3)
				local mag = v.Magnitude

				if mag > AXIS_MATRIX_EPS then
					return CFrame.fromAxisAngle(v.Unit, mag)
				end

				return CFrame.identity
			end

			function RotationSpring.new(d: number, f: number, p: CFrame, g: CFrame)
				return setmetatable({
					d = d,
					f = f,
					g = g,
					p = p,
					v = Vector3.zero,
				}, RotationSpring)
			end
			function RotationSpring.setGoal(self: RotationSpring, value: CFrame)
				self.g = value
			end
			function RotationSpring.setDampingRatio(self: RotationSpring, dampingRatio: number)
				self.d = dampingRatio
			end
			function RotationSpring.setFrequency(self: RotationSpring, frequency: number)
				self.f = frequency
			end
			function RotationSpring.canSleep(self: RotationSpring)
				local sleepP = angleBetween(self.p, self.g) < SLEEP_ROTATION_OFFSET
				local sleepV = self.v.Magnitude < SLEEP_ROTATION_VELOCITY

				return sleepP and sleepV
			end
			function RotationSpring.step(self: RotationSpring, dt: number): CFrame
				local d = self.d
				local f = self.f * 2 * pi
				local g = self.g
				local p0 = self.p
				local v0 = self.v
				local offset = matrixToAxis(p0 * g:Inverse())
				local decay = exp(-d * f * dt)
				local pt: CFrame
				local vt: Vector3

				if d == 1 then
					local w = dt * decay

					pt = axisToMatrix((offset * (1 + f * dt) + v0 * dt) * decay) * g
					vt = (v0 * (1 - dt * f) - offset * (dt * f * f)) * decay
				elseif d < 1 then
					local c = sqrt(1 - d * d)
					local i = cos(dt * f * c)
					local j = sin(dt * f * c)
					local y = j / (f * c)
					local z = j / c

					pt = axisToMatrix((offset * (i + z * d) + v0 * y) * decay) * g
					vt = (v0 * (i - z * d) - offset * (z * f)) * decay
				else
					local c = sqrt(d * d - 1)
					local r1 = -f * (d - c)
					local r2 = -f * (d + c)
					local co2 = (v0 - offset * r1) / (2 * f * c)
					local co1 = offset - co2
					local e1 = co1 * exp(r1 * dt)
					local e2 = co2 * exp(r2 * dt)

					pt = axisToMatrix(e1 + e2) * g
					vt = e1 * r1 + e2 * r2
				end

				self.p = pt
				self.v = vt

				return pt
			end
		end

		local typeMetadata_Vector3 = {
			springType = LinearSpring.new,
			toIntermediate = function(value)
				return {
					value.X,
					value.Y,
					value.Z,
				}
			end,
			fromIntermediate = function(value: { number })
				return Vector3.new(value[1], value[2], value[3])
			end,
		}
		local CFrameSpring = {}

		do
			CFrameSpring.__index = CFrameSpring

			function CFrameSpring.new(
				dampingRatio: number,
				frequency: number,
				valueCurrent: CFrame,
				valueGoal: CFrame,
				_: any
			)
				return setmetatable({
					rawGoal = valueGoal,
					_position = LinearSpring.new(
						dampingRatio,
						frequency,
						valueCurrent.Position,
						valueGoal.Position,
						typeMetadata_Vector3
					),
					_rotation = RotationSpring.new(dampingRatio, frequency, valueCurrent.Rotation, valueGoal.Rotation),
				}, CFrameSpring)
			end
			function CFrameSpring:setGoal(value: CFrame)
				self.rawGoal = value

				self._position:setGoal(value.Position)
				self._rotation:setGoal(value.Rotation)
			end
			function CFrameSpring:setDampingRatio(value: number)
				self._position:setDampingRatio(value)
				self._rotation:setDampingRatio(value)
			end
			function CFrameSpring:setFrequency(value: number)
				self._position:setFrequency(value)
				self._rotation:setFrequency(value)
			end
			function CFrameSpring:canSleep()
				return self._position:canSleep() and self._rotation:canSleep()
			end
			function CFrameSpring:step(dt): CFrame
				local p: Vector3 = self._position:step(dt)
				local r: CFrame = self._rotation:step(dt)

				return r + p
			end
		end

		local rgbToLuv
		local luvToRgb

		do
			local function inverseGammaCorrectD65(c)
				return c < 0.0404482362771076 and c / 12.92 or 0.87941546140213 * (c + 0.055) ^ 2.4
			end
			local function gammaCorrectD65(c)
				return c < 3.1306684424999998e-3 and 12.92 * c or 1.055 * c ^ 0.4166666666666667 - 0.055
			end

			function rgbToLuv(value: Color3): { number }
				local r, g, b = value.R, value.G, value.B

				r = inverseGammaCorrectD65(r)
				g = inverseGammaCorrectD65(g)
				b = inverseGammaCorrectD65(b)

				local x = 0.9257063972951867 * r - 0.8333736323779866 * g - 0.09209820666085898 * b
				local y = 0.2125862307855956 * r + 0.7151703037034108 * g + 0.0722004986433362 * b
				local z = 3.6590806972265884 * r + 11.442689580057424 * g + 4.114991502426484 * b
				local l = y > 0.008856451679035631 and 116 * y ^ 0.3333333333333333 - 16 or 903.296296296296 * y
				local u, v

				if z > 1e-14 then
					u = l * x / z
					v = l * (9 * y / z - 0.46832)
				else
					u = -0.19783 * l
					v = -0.46832 * l
				end

				return { l, u, v }
			end
			function luvToRgb(value: { number }): Color3
				local l = value[1]

				if l < 0.0197955 then
					return Color3.new(0, 0, 0)
				end

				local u = value[2] / l + 0.19783
				local v = value[3] / l + 0.46832
				local y = (l + 16) / 116

				y = y > 0.20689655172413793 and y * y * y or 0.12841854934601665 * y - 0.01771290335807126

				local x = y * u / v
				local z = y * ((3 - 0.75 * u) / v - 5)
				local r = 7.2914074 * x - 1.537208 * y - 0.4986286 * z
				local g = -2.180094 * x + 1.8757561 * y + 0.0415175 * z
				local b = 0.1253477 * x - 0.2040211 * y + 1.0569959 * z

				if r < 0 and r < g and r < b then
					r, g, b = 0, g - r, b - r
				elseif g < 0 and g < b then
					r, g, b = r - g, 0, b - g
				elseif b < 0 then
					r, g, b = r - b, g - b, 0
				end

				return Color3.new(min(gammaCorrectD65(r), 1), min(gammaCorrectD65(g), 1), min(gammaCorrectD65(b), 1))
			end
		end

		local typeMetadata = {
			boolean = {
				springType = LinearSpring.new,
				toIntermediate = function(value)
					return {
						value and 1 or 0,
					}
				end,
				fromIntermediate = function(value)
					return value[1] >= 0.5
				end,
			},
			number = {
				springType = LinearSpring.new,
				toIntermediate = function(value)
					return { value }
				end,
				fromIntermediate = function(value)
					return value[1]
				end,
			},
			NumberRange = {
				springType = LinearSpring.new,
				toIntermediate = function(value)
					return {
						value.Min,
						value.Max,
					}
				end,
				fromIntermediate = function(value)
					return NumberRange.new(value[1], value[2])
				end,
			},
			UDim = {
				springType = LinearSpring.new,
				toIntermediate = function(value)
					return {
						value.Scale,
						value.Offset,
					}
				end,
				fromIntermediate = function(value: { number })
					return UDim.new(value[1], round(value[2]))
				end,
			},
			UDim2 = {
				springType = LinearSpring.new,
				toIntermediate = function(value)
					local x = value.X
					local y = value.Y

					return {
						x.Scale,
						x.Offset,
						y.Scale,
						y.Offset,
					}
				end,
				fromIntermediate = function(value: { number })
					return UDim2.new(value[1], round(value[2]), value[3], round(value[4]))
				end,
			},
			Vector2 = {
				springType = LinearSpring.new,
				toIntermediate = function(value)
					return {
						value.X,
						value.Y,
					}
				end,
				fromIntermediate = function(value: { number })
					return Vector2.new(value[1], value[2])
				end,
			},
			Vector3 = typeMetadata_Vector3,
			Color3 = {
				springType = LinearSpring.new,
				toIntermediate = rgbToLuv,
				fromIntermediate = luvToRgb,
			},
			ColorSequence = {
				springType = LinearSpring.new,
				toIntermediate = function(value)
					local keypoints = value.Keypoints
					local luv0 = rgbToLuv(keypoints[1].Value)
					local luv1 = rgbToLuv(keypoints[#keypoints].Value)

					return {
						luv0[1],
						luv0[2],
						luv0[3],
						luv1[1],
						luv1[2],
						luv1[3],
					}
				end,
				fromIntermediate = function(value: {})
					return ColorSequence.new(
						luvToRgb({
							value[1],
							value[2],
							value[3],
						}),
						luvToRgb({
							value[4],
							value[5],
							value[6],
						})
					)
				end,
			},
			CFrame = {
				springType = CFrameSpring.new,
				toIntermediate = error,
				fromIntermediate = error,
			},
		}

		type PropertyOverride = { [string]: { class: string, get: (any) -> (), set: (any, any) -> () } }

		local PSEUDO_PROPERTIES: PropertyOverride = {
			Pivot = {
				class = "PVInstance",
				get = function(inst: PVInstance)
					return inst:GetPivot()
				end,
				set = function(inst: PVInstance, value: CFrame)
					inst:PivotTo(value)
				end,
			},
			Scale = {
				class = "Model",
				get = function(inst: Model)
					return inst:GetScale()
				end,
				set = function(inst: Model, value: number)
					inst:ScaleTo(value)
				end,
			},
		}
		local springStates: { [Instance]: { [string]: any } } = {}
		local completedCallbacks: { [Instance]: { () -> () } } = {}

		RunService.Heartbeat:Connect(function(dt)
			for instance, state in springStates do
				for propName, spring in state do
					local override = PSEUDO_PROPERTIES[propName]

					if override and instance:IsA(override.class) then
						if spring:canSleep() then
							state[propName] = nil

							override.set(instance, spring.rawGoal)
						else
							override.set(instance, spring:step(dt))
						end
					else
						if spring:canSleep() then
							state[propName] = nil
							(instance :: any)[propName] = spring.rawGoal
						else
							(instance :: any)[propName] = spring:step(dt)
						end
					end
				end

				if not next(state) then
					springStates[instance] = nil

					local callbackList = completedCallbacks[instance]

					if callbackList then
						completedCallbacks[instance] = nil

						for _, callback in callbackList do
							task.spawn(callback)
						end
					end
				end
			end
		end)

		local spr = {}

		do
			local function assertType(argNum: number, fnName: string, expectedType: string, value: any)
				if not expectedType:find(typeof(value)) then
					error(`bad argument #{argNum} to {fnName} ({expectedType} expected, got {typeof(value)})`, 3)
				end
			end

			function spr.target(
				instance: Instance,
				dampingRatio: number,
				frequency: number,
				properties: { [string]: any }
			)
				if STRICT_RUNTIME_TYPES then
					assertType(1, "spr.target", "Instance", instance)
					assertType(2, "spr.target", "number", dampingRatio)
					assertType(3, "spr.target", "number", frequency)
					assertType(4, "spr.target", "table", properties)
				end
				if dampingRatio ~= dampingRatio or dampingRatio < 0 then
					error(("expected damping ratio >= 0; got %.2f"):format(dampingRatio), 2)
				end
				if frequency ~= frequency or frequency < 0 then
					error(("expected undamped frequency >= 0; got %.2f"):format(frequency), 2)
				end

				local state = springStates[instance]

				if not state then
					state = {}
					springStates[instance] = state
				end

				for propName, propTarget in properties do
					local propValue
					local override = PSEUDO_PROPERTIES[propName]

					if override and instance:IsA(override.class) then
						propValue = override.get(instance)
					else
						propValue = (instance :: any)[propName]
					end
					if STRICT_RUNTIME_TYPES and typeof(propTarget) ~= typeof(propValue) then
						error(
							"bad property {propName} to spr.target ({typeof(propValue)} expected, got {typeof(propTarget)})",
							2
						)
					end
					if frequency == math.huge then
						(instance :: any)[propName] = propTarget
						state[propName] = nil

						continue
					end

					local spring = state[propName]

					if not spring then
						local md = typeMetadata[typeof(propTarget)]

						if not md then
							error("unsupported type: " .. typeof(propTarget), 2)
						end

						spring = md.springType(dampingRatio, frequency, propValue, propTarget, md)
						state[propName] = spring
					end

					spring:setGoal(propTarget)
					spring:setDampingRatio(dampingRatio)
					spring:setFrequency(frequency)
				end

				if not next(state) then
					springStates[instance] = nil
				end
			end
			function spr.stop(instance: Instance, property: string?)
				if STRICT_RUNTIME_TYPES then
					assertType(1, "spr.stop", "Instance", instance)
					assertType(2, "spr.stop", "string|nil", property)
				end
				if property then
					local state = springStates[instance]

					if state then
						state[property] = nil
					end
				else
					springStates[instance] = nil
				end
			end
			function spr.completed(instance: Instance, callback: () -> ())
				if STRICT_RUNTIME_TYPES then
					assertType(1, "spr.completed", "Instance", instance)
					assertType(2, "spr.completed", "function", callback)
				end

				local callbackList = completedCallbacks[instance]

				if callbackList then
					table.insert(callbackList, callback)
				else
					completedCallbacks[instance] = { callback }
				end
			end
		end
		return table.freeze(spr)
	end)()
	function get_callback(Configs, index)
		local func = Configs[index] or Configs.Callback or function() end

		if type(func) == "table" then
			return {
				function(Value)
					func[1][func[2]] = Value
				end,
			}
		end

		return func
	end

	local ColorTheme = {
		Match = {
			A = Color3.fromRGB(22, 22, 24),
			B = Color3.fromRGB(16, 16, 17),
		},
		Red = {
			A = Color3.fromRGB(45, 0, 0),
			B = Color3.fromRGB(30, 0, 0),
		},
	}
	local originalColor = {}
	local ThemeColors = {
		Dark = {
			Primary = Color3.fromRGB(22, 22, 24),
			Secondary = Color3.fromRGB(16, 16, 17),
			Accent = Color3.fromRGB(255, 68, 68),
		},
		Red = {
			Primary = Color3.fromRGB(45, 0, 0),
			Secondary = Color3.fromRGB(30, 0, 0),
			Accent = Color3.fromRGB(255, 50, 50),
		},
		Green = {
			Primary = Color3.fromRGB(0, 45, 0),
			Secondary = Color3.fromRGB(0, 30, 0),
			Accent = Color3.fromRGB(50, 255, 50),
		},
		Blue = {
			Primary = Color3.fromRGB(0, 20, 45),
			Secondary = Color3.fromRGB(0, 15, 30),
			Accent = Color3.fromRGB(50, 150, 255),
		},
		Purple = {
			Primary = Color3.fromRGB(30, 0, 45),
			Secondary = Color3.fromRGB(20, 0, 30),
			Accent = Color3.fromRGB(150, 50, 255),
		},
	}
	local CustomColorAliases = {
		BackgroundColor = "Primary",
		Background = "Primary",
		PrimaryColor = "Primary",
		SecondaryColor = "Secondary",
		AccentColor = "Accent",
		TextColor = "Text",
		SubTextColor = "SubText",
	}
	local function DeepCopyTable(source)
		local copy = {}

		for key, value in pairs(source or {}) do
			if type(value) == "table" then
				copy[key] = DeepCopyTable(value)
			else
				copy[key] = value
			end
		end

		return copy
	end
	local function ApplyCustomColorAliases(target, colors)
		for key, value in pairs(colors or {}) do
			local normalizedKey = CustomColorAliases[key] or key

			if type(value) == "table" and type(target[normalizedKey]) == "table" then
				ApplyCustomColorAliases(target[normalizedKey], value)
			else
				target[normalizedKey] = value
			end
		end
	end
	Library.CustomColors = DeepCopyTable(ThemeColors.Dark)
	ThemeColors.Custom = DeepCopyTable(ThemeColors.Dark)

	local function GetContrastTextColor(backgroundColor)
		if typeof(backgroundColor) ~= "Color3" then
			return Color3.fromRGB(255, 255, 255)
		end

		local luminance = backgroundColor.R * 0.299 + backgroundColor.G * 0.587 + backgroundColor.B * 0.114

		if luminance > 0.62 then
			return Color3.fromRGB(18, 18, 18)
		end

		return Color3.fromRGB(255, 255, 255)
	end
	local function BlendColor(first, second, alpha)
		if typeof(first) ~= "Color3" or typeof(second) ~= "Color3" then
			return Color3.fromRGB(255, 255, 255)
		end

		local t = math.clamp(tonumber(alpha) or 0.5, 0, 1)

		return Color3.new(
			first.R + (second.R - first.R) * t,
			first.G + (second.G - first.G) * t,
			first.B + (second.B - first.B) * t
		)
	end
	local function GetColorDistance(first, second)
		if typeof(first) ~= "Color3" or typeof(second) ~= "Color3" then
			return 1
		end

		return math.abs(first.R - second.R) + math.abs(first.G - second.G) + math.abs(first.B - second.B)
	end
	local function GetSendButtonTextColor(theme, backgroundColor)
		local bg = typeof(backgroundColor) == "Color3" and backgroundColor
			or BlendColor(theme.Accent, theme.Button.Hover, 0.5)
		local color = GetContrastTextColor(bg)

		if GetColorDistance(color, bg) < 0.26 then
			local luminance = bg.R * 0.299 + bg.G * 0.587 + bg.B * 0.114

			color = luminance > 0.62 and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(255, 255, 255)
		end

		return color
	end
	local function ApplyChatTheme(page, theme)
		spr.target(page, 0.8, 4, {
			BackgroundColor3 = theme.Chat.Background,
		})

		local animatedBackground = page:FindFirstChild("AnimatedBackground")

		if animatedBackground then
			spr.target(animatedBackground, 0.8, 4, {
				BackgroundColor3 = theme.Chat.BackgroundAlt,
			})

			local bgGradient = animatedBackground:FindFirstChild("BackgroundGradient")

			if bgGradient and bgGradient:IsA("UIGradient") then
				bgGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, theme.Chat.BackgroundAlt),
					ColorSequenceKeypoint.new(0.5, theme.Chat.Background),
					ColorSequenceKeypoint.new(1, theme.Chat.Bubble),
				})
			end

			local glowA = animatedBackground:FindFirstChild("GlowA")

			if glowA and glowA:IsA("Frame") then
				spr.target(glowA, 0.8, 4, {
					BackgroundColor3 = theme.Accent,
				})
			end

			local glowB = animatedBackground:FindFirstChild("GlowB")

			if glowB and glowB:IsA("Frame") then
				spr.target(glowB, 0.8, 4, {
					BackgroundColor3 = theme.Chat.Username,
				})
			end
		end

		local container = page:FindFirstChild("Container", true)

		if container then
			local messages = container:FindFirstChild("Messages", true)

			if messages then
				messages.ScrollBarImageColor3 = BlendColor(theme.Accent, theme.Secondary, 0.45)
			end

			spr.target(container, 0.7, 4, {
				BackgroundColor3 = BlendColor(theme.Chat.Background, theme.Chat.Bubble, 0.52),
			})

			local containerStroke = container:FindFirstChild("ContainerStroke")

			if containerStroke and containerStroke:IsA("UIStroke") then
				spr.target(containerStroke, 0.7, 4, {
					Color = BlendColor(theme.Chat.ScrollBar, theme.Accent, 0.48),
				})
			end
		end

		local inputBar = page:FindFirstChild("InputBar", true)

		if inputBar then
			spr.target(inputBar, 0.6, 4, {
				BackgroundColor3 = theme.Chat.InputBar,
			})

			local inputStroke = inputBar:FindFirstChild("InputStroke")

			if inputStroke and inputStroke:IsA("UIStroke") then
				spr.target(inputStroke, 0.6, 4, {
					Color = BlendColor(theme.Accent, theme.Chat.InputBar, 0.55),
				})
			end

			local statusRow = inputBar:FindFirstChild("StatusRow")

			if statusRow then
				local statusPill = statusRow:FindFirstChild("StatusPill")
				local statusStroke = statusRow:FindFirstChild("StatusStroke", true)
				local statusDot = statusRow:FindFirstChild("StatusDot", true)
				local statusGlow = statusRow:FindFirstChild("StatusGlow", true)
				local statusIcon = statusRow:FindFirstChild("StatusIcon", true)
				local statusLabel = statusRow:FindFirstChild("StatusLabel", true)

				if statusPill and statusPill:IsA("Frame") then
					spr.target(statusPill, 0.6, 4, {
						BackgroundColor3 = BlendColor(theme.Chat.InputBox, theme.Accent, 0.12),
					})
				end
				if statusStroke and statusStroke:IsA("UIStroke") then
					spr.target(statusStroke, 0.6, 4, {
						Color = BlendColor(theme.Accent, theme.Chat.InputBar, 0.38),
					})
				end
				if statusLabel then
					if statusDot then
						statusDot.BackgroundColor3 = statusLabel.TextColor3
					end
					if statusGlow then
						spr.target(statusGlow, 0.6, 4, {
							BackgroundColor3 = statusLabel.TextColor3,
						})
					end
					if statusIcon and statusIcon:IsA("ImageLabel") then
						statusIcon.ImageColor3 = statusLabel.TextColor3
					end
				end
			end

			local replyBar = inputBar:FindFirstChild("ReplyBar")

			if replyBar then
				spr.target(replyBar, 0.6, 4, {
					BackgroundColor3 = theme.Chat.ReplyBar,
				})

				local replyStroke = replyBar:FindFirstChild("ReplyStroke")

				if replyStroke and replyStroke:IsA("UIStroke") then
					spr.target(replyStroke, 0.6, 4, {
						Color = BlendColor(theme.Chat.ScrollBar, theme.Accent, 0.32),
					})
				end

				local replyAccentStripe = replyBar:FindFirstChild("ReplyAccentStripe")

				if replyAccentStripe then
					spr.target(replyAccentStripe, 0.6, 4, {
						BackgroundColor3 = theme.Accent,
					})
				end

				local replyIcon = replyBar:FindFirstChild("ReplyIcon")

				if replyIcon and replyIcon:IsA("ImageLabel") then
					spr.target(replyIcon, 0.6, 4, {
						ImageColor3 = theme.Accent,
					})
				end

				local replyPreview = replyBar:FindFirstChild("ReplyPreview")

				if replyPreview and replyPreview:IsA("TextLabel") then
					replyPreview.TextColor3 = theme.SubText
				end

				local replyClear = replyBar:FindFirstChild("ReplyClear")

				if replyClear then
					spr.target(replyClear, 0.6, 4, {
						BackgroundColor3 = theme.Primary,
					})

					local clearIcon = replyClear:FindFirstChild("Icon")

					if clearIcon and clearIcon:IsA("ImageLabel") then
						spr.target(clearIcon, 0.6, 4, {
							ImageColor3 = theme.SubText,
						})
					end
				end
			end

			local inputRow = inputBar:FindFirstChild("InputRow")

			if inputRow then
				local inputBox = inputRow:FindFirstChild("InputBox")

				if inputBox then
					spr.target(inputBox, 0.6, 4, {
						BackgroundColor3 = theme.Chat.InputBox,
						TextColor3 = theme.Chat.Text,
					})

					inputBox.PlaceholderColor3 = BlendColor(theme.SubText, theme.Chat.Text, 0.3)

					local inputBoxStroke = inputBox:FindFirstChild("InputBoxStroke")

					if inputBoxStroke and inputBoxStroke:IsA("UIStroke") then
						spr.target(inputBoxStroke, 0.6, 4, {
							Color = BlendColor(theme.Chat.ScrollBar, theme.Accent, 0.25),
						})
					end

					local charCounter = inputBox:FindFirstChild("CharCounter")

					if charCounter and charCounter:IsA("TextLabel") then
						charCounter.TextColor3 = theme.SubText
					end
				end

				local sendButton = inputRow:FindFirstChild("SendButton")

				if sendButton then
					spr.target(sendButton, 0.6, 4, {
						BackgroundColor3 = theme.Accent,
					})

					local sendIcon = sendButton:FindFirstChild("SendIcon")

					if sendIcon and sendIcon:IsA("ImageLabel") then
						spr.target(sendIcon, 0.6, 4, {
							ImageColor3 = GetSendButtonTextColor(theme, theme.Accent),
						})
					end

					local sendGlow = sendButton:FindFirstChild("SendGlow")

					if sendGlow and sendGlow:IsA("Frame") then
						spr.target(sendGlow, 0.6, 4, {
							BackgroundColor3 = theme.Accent,
						})
					end
				end
			end
		end

		for _, inst in ipairs(page:GetDescendants()) do
			if inst:IsA("Frame") and inst:GetAttribute("IsChatBubble") then
				spr.target(inst, 0.6, 4, {
					BackgroundColor3 = theme.Chat.Bubble,
				})
			elseif inst:IsA("TextLabel") and inst:GetAttribute("IsChatUsername") then
				inst.TextColor3 = theme.Chat.Username
			elseif inst:IsA("TextLabel") and inst:GetAttribute("IsChatContent") then
				inst.TextColor3 = theme.Chat.Text
			elseif inst:IsA("TextLabel") and inst:GetAttribute("IsChatReplyMeta") then
				inst.TextColor3 = theme.SubText
			elseif inst:IsA("UIStroke") and inst:GetAttribute("IsChatAvatarStroke") then
				spr.target(inst, 0.6, 4, {
					Color = theme.Chat.AvatarStroke,
				})
			elseif inst:IsA("UIStroke") and inst:GetAttribute("IsChatBubbleStroke") then
				spr.target(inst, 0.6, 4, {
					Color = theme.Chat.ScrollBar,
				})
			end
		end
	end

	function NormalizeTheme(theme)
		local t = table.clone(theme or ThemeColors.Dark)

		t.Text = t.Text or Color3.fromRGB(230, 230, 230)
		t.SubText = t.SubText or Color3.fromRGB(160, 160, 160)
		t.Chat = t.Chat or {}
		t.Chat.Background = t.Chat.Background or t.Secondary
		t.Chat.BackgroundAlt = t.Chat.BackgroundAlt
			or Color3.fromRGB(
				math.clamp(t.Secondary.R * 255 + 8, 0, 255),
				math.clamp(t.Secondary.G * 255 + 8, 0, 255),
				math.clamp(t.Secondary.B * 255 + 8, 0, 255)
			)
		t.Chat.Bubble = t.Chat.Bubble
			or Color3.fromRGB(
				math.clamp(t.Primary.R * 255 + 32, 0, 255),
				math.clamp(t.Primary.G * 255 + 32, 0, 255),
				math.clamp(t.Primary.B * 255 + 32, 0, 255)
			)
		t.Chat.Username = t.Chat.Username or t.Accent
		t.Chat.Text = t.Chat.Text or t.Text
		t.Chat.InputBar = t.Chat.InputBar or t.Primary
		t.Chat.InputBox = t.Chat.InputBox or t.Secondary
		t.Chat.ScrollBar = t.Chat.ScrollBar or BlendColor(t.Accent, t.Secondary, 0.42)
		t.Chat.ReplyBar = t.Chat.ReplyBar or t.Secondary
		t.Chat.AvatarStroke = t.Chat.AvatarStroke or t.Accent
		t.Button = t.Button or {}
		t.Button.Primary = t.Button.Primary or t.Accent
		t.Button.Hover = t.Button.Hover
			or Color3.fromRGB(
				math.clamp(t.Accent.R * 255 - 20, 0, 255),
				math.clamp(t.Accent.G * 255 - 20, 0, 255),
				math.clamp(t.Accent.B * 255 - 20, 0, 255)
			)

		return t
	end

	local currentTheme = "Dark"
	local function RefreshCustomTheme()
		local customTheme = DeepCopyTable(ThemeColors.Dark)

		ApplyCustomColorAliases(customTheme, Library.CustomColors)
		local normalizedTheme = NormalizeTheme(customTheme)

		Library.CustomColors = DeepCopyTable(normalizedTheme)
		ThemeColors.Custom = DeepCopyTable(normalizedTheme)
		ColorTheme.Custom = {
			A = normalizedTheme.Primary or ThemeColors.Dark.Primary,
			B = normalizedTheme.Secondary or ThemeColors.Dark.Secondary,
		}

		return normalizedTheme
	end
	RefreshCustomTheme()

	function Library:SetCustomColors(colors, refresh)
		if type(colors) ~= "table" then
			return RefreshCustomTheme()
		end

		ApplyCustomColorAliases(Library.CustomColors, colors)
		local customTheme = RefreshCustomTheme()

		if refresh ~= false then
			for _, windowHandle in ipairs(Library._ThemeWindows or {}) do
				if
					type(windowHandle) == "table"
					and type(windowHandle.GetCurrentTheme) == "function"
					and type(windowHandle.SetTheme) == "function"
					and windowHandle:GetCurrentTheme() == "Custom"
				then
					pcall(function()
						windowHandle:SetTheme("Custom")
					end)
				end
			end
		end

		return customTheme
	end

	function Library:SetCustomColor(name, value, refresh)
		if type(name) ~= "string" then
			return RefreshCustomTheme()
		end

		return Library:SetCustomColors({
			[name] = value,
		}, refresh)
	end

	local function colorsMatch(color1, color2, tolerance)
		tolerance = tolerance or 0.01

		return math.abs(color1.R - color2.R) < tolerance
			and math.abs(color1.G - color2.G) < tolerance
			and math.abs(color1.B - color2.B) < tolerance
	end
	local function changeColor(UIobj: Instance, themeName)
		if not UIobj:IsA("GuiObject") then
			return
		end

		local selectedTheme = ColorTheme[themeName] or ColorTheme.Red

		if not originalColor[UIobj] then
			if UIobj:IsA("TextLabel") or UIobj:IsA("TextButton") or UIobj:IsA("TextBox") then
				originalColor[UIobj] = {
					BackgroundColor3 = UIobj.BackgroundColor3,
					TextColor3 = UIobj.TextColor3,
					BorderColor3 = UIobj.BorderColor3,
				}
			elseif UIobj:IsA("Frame") or UIobj:IsA("ScrollingFrame") then
				originalColor[UIobj] = {
					BackgroundColor3 = UIobj.BackgroundColor3,
					BorderColor3 = UIobj.BorderColor3,
				}
			elseif UIobj:IsA("ImageLabel") or UIobj:IsA("ImageButton") then
				originalColor[UIobj] = {
					BackgroundColor3 = UIobj.BackgroundColor3,
					ImageColor3 = UIobj.ImageColor3,
					BorderColor3 = UIobj.BorderColor3,
				}
			else
				originalColor[UIobj] = {
					BackgroundColor3 = UIobj.BackgroundColor3,
				}
			end
		end

		local function checkAndChange(currentColor)
			if colorsMatch(currentColor, ColorTheme.Match.A) then
				return selectedTheme.A
			elseif colorsMatch(currentColor, ColorTheme.Match.B) then
				return selectedTheme.B
			end

			return currentColor
		end

		if UIobj:IsA("TextLabel") or UIobj:IsA("TextButton") or UIobj:IsA("TextBox") then
			UIobj.BackgroundColor3 = checkAndChange(UIobj.BackgroundColor3)
			UIobj.TextColor3 = checkAndChange(UIobj.TextColor3)
			UIobj.BorderColor3 = checkAndChange(UIobj.BorderColor3)
		elseif UIobj:IsA("ImageLabel") or UIobj:IsA("ImageButton") then
			UIobj.BackgroundColor3 = checkAndChange(UIobj.BackgroundColor3)
			UIobj.ImageColor3 = checkAndChange(UIobj.ImageColor3)
			UIobj.BorderColor3 = checkAndChange(UIobj.BorderColor3)
		elseif UIobj:IsA("Frame") or UIobj:IsA("ScrollingFrame") then
			UIobj.BackgroundColor3 = checkAndChange(UIobj.BackgroundColor3)
			UIobj.BorderColor3 = checkAndChange(UIobj.BorderColor3)
		else
			UIobj.BackgroundColor3 = checkAndChange(UIobj.BackgroundColor3)
		end
	end
	local function changeAllDescendants(parent: Instance, themeName)
		themeName = themeName or currentTheme

		for _, descendant in ipairs(parent:GetDescendants()) do
			changeColor(descendant, themeName)
		end
	end
	local function resetToOriginal(parent: Instance)
		for _, descendant in ipairs(parent:GetDescendants()) do
			if originalColor[descendant] then
				local obj = descendant

				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					obj.BackgroundColor3 = originalColor[obj].BackgroundColor3
					obj.TextColor3 = originalColor[obj].TextColor3
					obj.BorderColor3 = originalColor[obj].BorderColor3
				elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
					obj.BackgroundColor3 = originalColor[obj].BackgroundColor3
					obj.ImageColor3 = originalColor[obj].ImageColor3
					obj.BorderColor3 = originalColor[obj].BorderColor3
				else
					obj.BackgroundColor3 = originalColor[obj].BackgroundColor3
				end
			end
		end
	end

	function GetDeviceType()
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			return "Mobile"
		elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
			return "Console"
		else
			return "PC"
		end
	end
	function GetScale()
		local vp = Camera.ViewportSize
		local minSide = math.min(vp.X, vp.Y)

		if minSide < 600 then
			return 0.575
		elseif minSide < 900 then
			return 1
		else
			return 1.15
		end
	end
	function CalculateUIScale()
		local viewport = Camera.ViewportSize
		local device = GetDeviceType()

		if device == "Mobile" then
			local shortSide = math.min(viewport.X, viewport.Y)
			local yFactor = viewport.Y / 900
			local shortFactor = shortSide / 520
			local blended = (yFactor * 0.68) + (shortFactor * 0.32)

			return math.clamp(blended * 0.93, 0.78, 1)
		else
			return math.clamp(viewport.Y / 900 * 0.88, 0.88, 1)
		end
	end
	function GetTabCellHeight()
		local scale = CalculateUIScale()

		if GetDeviceType() == "Mobile" then
			return 37 * scale
		end

		return 42.5 * scale
	end

	local Themes = {
		changeTheme = changeAllDescendants,
		resetColors = resetToOriginal,
		setCurrentTheme = function(themeName)
			currentTheme = themeName
		end,
	}
	local ScreenGui2 = Instance.new("ScreenGui", gethui() or game.CoreGui or lp.PlayerGui)

	ScreenGui2.Name = "VanishMobileButtons"

	local MobileButtons = {}

	local function getMobileTheme(themeName)
		local key = themeName or currentTheme
		return NormalizeTheme(ThemeColors[key] or ThemeColors.Dark)
	end

	local function applyMobileButtonTheme(entry, theme, isHover)
		if not entry or not entry.button then
			return
		end
		local bgColor = isHover and BlendColor(theme.Secondary, theme.Accent, 0.18) or theme.Primary
		local iconColor = isHover and theme.Accent or theme.Text
		local strokeTransp = isHover and 0.08 or 0.42
		local glowTransp = isHover and 0.68 or 0.90

		spr.target(entry.button, 0.68, 7, { BackgroundColor3 = bgColor })
		if entry.inner then
			spr.target(entry.inner, 0.68, 7, { BackgroundColor3 = BlendColor(theme.Secondary, theme.Primary, 0.6) })
		end
		if entry.icon then
			spr.target(entry.icon, 0.68, 7, { ImageColor3 = iconColor })
		end
		if entry.stroke then
			spr.target(entry.stroke, 0.68, 7, { Color = theme.Accent, Transparency = strokeTransp })
		end
		if entry.glow then
			spr.target(entry.glow, 0.68, 7, { BackgroundColor3 = theme.Accent, BackgroundTransparency = glowTransp })
		end
	end

	function Library:RefreshMobileButtonsTheme(themeName)
		local theme = getMobileTheme(themeName)
		for _, entry in pairs(MobileButtons) do
			applyMobileButtonTheme(entry, theme, false)
		end
	end

	function Library:IsHasButtonWithName(name)
		return ScreenGui2:FindFirstChild(name)
	end

	function Library:AddMobileButton(name, icon, callback)
		if Library:IsHasButtonWithName(name) then
			return
		end

		local theme = getMobileTheme()
		local iconurl = Lucide.GetAsset(icon)

		local clickdetector = Instance.new("TextButton")
		clickdetector.Name = name
		clickdetector.Size = UDim2.new(0, 72, 0, 72)
		clickdetector.Position = UDim2.new(0, 20, 0, 20)
		clickdetector.Parent = ScreenGui2
		clickdetector.Text = ""
		clickdetector.BackgroundTransparency = 1
		clickdetector.BorderSizePixel = 0
		clickdetector.Active = true
		clickdetector.Visible = false

		EnableDragify(clickdetector)

		local btn = Instance.new("ImageButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.Name = "image"
		btn.BackgroundColor3 = theme.Primary
		btn.Image = iconurl.Url
		btn.ImageRectSize = iconurl.ImageRectSize
		btn.ImageRectOffset = iconurl.ImageRectOffset
		btn.ScaleType = Enum.ScaleType.Fit
		btn.ImageColor3 = theme.Text
		btn.AutoButtonColor = false
		btn.Parent = clickdetector
		btn.Visible = false
		btn.Active = false
		btn.AnchorPoint = Vector2.new(0.5, 0.5)
		btn.Position = UDim2.fromScale(0.5, 0.5)
		btn.ZIndex = 2

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 18)
		corner.Parent = btn

		local glow = Instance.new("Frame")
		glow.Name = "Glow"
		glow.Size = UDim2.new(1, 12, 1, 12)
		glow.Position = UDim2.new(0, -6, 0, -6)
		glow.BackgroundColor3 = theme.Accent
		glow.BackgroundTransparency = 0.90
		glow.BorderSizePixel = 0
		glow.ZIndex = 0
		glow.Parent = btn
		local glowCorner = Instance.new("UICorner")
		glowCorner.CornerRadius = UDim.new(0, 22)
		glowCorner.Parent = glow

		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180)),
		})
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.88),
			NumberSequenceKeypoint.new(1, 0.96),
		})
		gradient.Rotation = 135
		gradient.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Color = theme.Accent
		stroke.Thickness = 1.4
		stroke.Transparency = 0.42
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		local inner = Instance.new("Frame")
		inner.Name = "Inner"
		inner.Size = UDim2.new(1, -14, 1, -14)
		inner.Position = UDim2.new(0, 7, 0, 7)
		inner.BackgroundColor3 = BlendColor(theme.Secondary, theme.Primary, 0.6)
		inner.BackgroundTransparency = 0.78
		inner.BorderSizePixel = 0
		inner.ZIndex = 1
		inner.Parent = btn
		local innerCorner = Instance.new("UICorner")
		innerCorner.CornerRadius = UDim.new(0, 16)
		innerCorner.Parent = inner

		local ripple = Instance.new("Frame")
		ripple.Name = "Ripple"
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		ripple.Position = UDim2.fromScale(0.5, 0.5)
		ripple.Size = UDim2.fromOffset(0, 0)
		ripple.BackgroundColor3 = theme.Accent
		ripple.BackgroundTransparency = 0.62
		ripple.BorderSizePixel = 0
		ripple.ZIndex = 3
		ripple.ClipsDescendants = false
		ripple.Parent = btn
		local rippleCorner = Instance.new("UICorner")
		rippleCorner.CornerRadius = UDim.new(1, 0)
		rippleCorner.Parent = ripple

		local iconScale = Instance.new("UIScale")
		iconScale.Name = "ButtonScale"
		iconScale.Scale = 1
		iconScale.Parent = btn

		local tooltip = Instance.new("TextLabel")
		tooltip.Name = "Tooltip"
		tooltip.Size = UDim2.new(0, 0, 0, 22)
		tooltip.AutomaticSize = Enum.AutomaticSize.X
		tooltip.Position = UDim2.new(1, 8, 0.5, -11)
		tooltip.BackgroundColor3 = BlendColor(theme.Primary, Color3.fromRGB(0, 0, 0), 0.22)
		tooltip.BackgroundTransparency = 1
		tooltip.BorderSizePixel = 0
		tooltip.Text = "  " .. name .. "  "
		tooltip.TextColor3 = theme.Text
		tooltip.Font = Enum.Font.GothamBold
		tooltip.TextSize = 12
		tooltip.ZIndex = 20
		tooltip.Parent = btn
		local tooltipCorner = Instance.new("UICorner")
		tooltipCorner.CornerRadius = UDim.new(0, 8)
		tooltipCorner.Parent = tooltip
		local tooltipStroke = Instance.new("UIStroke")
		tooltipStroke.Color = theme.Accent
		tooltipStroke.Thickness = 1
		tooltipStroke.Transparency = 0.5
		tooltipStroke.Parent = tooltip

		local entry =
			{ root = clickdetector, button = btn, inner = inner, icon = btn, stroke = stroke, glow = glow, binds = {} }
		MobileButtons[name] = entry
		Library:RefreshMobileButtonsTheme()

		local tooltipToken = 0
		local function showTooltip()
			tooltipToken += 1
			local tok = tooltipToken
			task.delay(0.8, function()
				if tooltipToken ~= tok then
					return
				end
				spr.target(tooltip, 0.65, 6, { BackgroundTransparency = 0.08, TextTransparency = 0 })
			end)
		end
		local function hideTooltip()
			tooltipToken += 1
			spr.target(tooltip, 0.65, 6, { BackgroundTransparency = 1, TextTransparency = 1 })
		end
		tooltip.BackgroundTransparency = 1

		local function playRipple()
			ripple.Size = UDim2.fromOffset(0, 0)
			ripple.BackgroundTransparency = 0.55
			spr.target(ripple, 0.55, 5, { Size = UDim2.fromOffset(70, 70) })
			task.delay(0.12, function()
				spr.target(ripple, 0.55, 4, { BackgroundTransparency = 1 })
				task.delay(0.18, function()
					ripple.Size = UDim2.fromOffset(0, 0)
					ripple.BackgroundTransparency = 0.62
				end)
			end)
		end

		Library.ConnectionsList[name .. " MouseEnter"] = clickdetector.MouseEnter:Connect(function()
			applyMobileButtonTheme(entry, getMobileTheme(), true)
			spr.target(iconScale, 0.65, 8, { Scale = 1.07 })
			showTooltip()
		end)
		Library.ConnectionsList[name .. " MouseLeave"] = clickdetector.MouseLeave:Connect(function()
			applyMobileButtonTheme(entry, getMobileTheme(), false)
			spr.target(iconScale, 0.65, 8, { Scale = 1 })
			hideTooltip()
		end)
		Library.ConnectionsList[name .. " InputBegan"] = clickdetector.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				spr.target(iconScale, 0.7, 10, { Scale = 0.88 })
				spr.target(
					btn,
					0.7,
					8,
					{ BackgroundColor3 = BlendColor(getMobileTheme().Primary, getMobileTheme().Accent, 0.24) }
				)
				playRipple()
			end
		end)
		Library.ConnectionsList[name .. " Activated"] = clickdetector.Activated:Connect(function()
			spr.target(iconScale, 0.5, 7, { Scale = 1.12 })
			task.delay(0.08, function()
				spr.target(iconScale, 0.65, 8, { Scale = 1 })
				applyMobileButtonTheme(entry, getMobileTheme(), false)
			end)
			if callback then
				callback()
			end
			for _, bindCb in ipairs(entry.binds) do
				task.spawn(bindCb)
			end
		end)

		local btnHandle = {}
		function btnHandle:AddBind(bindCallback)
			if type(bindCallback) == "function" then
				table.insert(entry.binds, bindCallback)
			end
		end
		function btnHandle:SetIcon(newIcon)
			local newUrl = Lucide.GetAsset(newIcon)
			if newUrl then
				btn.Image = newUrl.Url
				btn.ImageRectSize = newUrl.ImageRectSize
				btn.ImageRectOffset = newUrl.ImageRectOffset
			end
		end
		function btnHandle:SetVisible(state)
			Library:ToggleVisibleMobileButton(name, state)
		end
		function btnHandle:Remove()
			Library:RemoveMobileButton(name)
		end

		return btnHandle
	end

	function Library:ToggleVisibleMobileButton(name, toggle)
		if Library:IsHasButtonWithName(name) then
			local obj = ScreenGui2:FindFirstChild(name)
			if obj then
				obj.Visible = toggle
				if obj:FindFirstChild("image") then
					obj.image.Visible = toggle
				end
			end
		end
	end

	function Library:RemoveMobileButton(name)
		if Library:IsHasButtonWithName(name) then
			local target = ScreenGui2:FindFirstChild(name)
			if target then
				target:Destroy()
			end
			MobileButtons[name] = nil
			for key, connect in pairs(Library.ConnectionsList) do
				if type(key) == "string" and (key:find("^" .. name .. " ") or key:find("^" .. name .. "_Dragify_")) then
					pcall(function()
						connect:Disconnect()
					end)
					Library.ConnectionsList[key] = nil
				end
			end
		end
	end

	function Library:ClearMobileButtons()
		for _, v in pairs(ScreenGui2:GetChildren()) do
			v:Destroy()
		end
		table.clear(MobileButtons)
		for connection, connect in pairs(Library.ConnectionsList) do
			if
				type(connection) == "string"
				and (
					connection:find(" MouseEnter")
					or connection:find(" MouseLeave")
					or connection:find(" Activated")
					or connection:find("_Dragify_")
				)
			then
				pcall(function()
					connect:Disconnect()
				end)
				Library.ConnectionsList[connection] = nil
			end
		end
	end

	local NotificationGui = Instance.new("ScreenGui")

	NotificationGui.Name = "VanishNotifications"
	NotificationGui.IgnoreGuiInset = true
	NotificationGui.ResetOnSpawn = false
	NotificationGui.DisplayOrder = 999997
	NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	NotificationGui.Parent = gethui() or game.CoreGui or lp.PlayerGui

	local NotificationHolder = Instance.new("Frame")

	NotificationHolder.Name = "NotificationHolder"
	NotificationHolder.AnchorPoint = Vector2.new(1, 0)
	NotificationHolder.Position = UDim2.new(1, -12, 0, 12)
	NotificationHolder.Size = UDim2.new(0, 338, 1, -24)
	NotificationHolder.BackgroundTransparency = 1
	NotificationHolder.BorderSizePixel = 0
	NotificationHolder.ClipsDescendants = false
	NotificationHolder.Parent = NotificationGui

	local NotificationList = Instance.new("UIListLayout")

	NotificationList.FillDirection = Enum.FillDirection.Vertical
	NotificationList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	NotificationList.VerticalAlignment = Enum.VerticalAlignment.Top
	NotificationList.Padding = UDim.new(0, 8)
	NotificationList.SortOrder = Enum.SortOrder.LayoutOrder
	NotificationList.Parent = NotificationHolder

	local NOTIFICATION_MAX_VISIBLE = 5
	local NotificationEntries = {}
	local NotificationSerial = 0
	local notificationViewportPending = false

	local function TrimLibraryText(text)
		return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	end
	local function getNotificationTheme(themeName)
		local key = themeName or currentTheme

		return NormalizeTheme(ThemeColors[key] or ThemeColors.Dark)
	end
	local function updateNotificationHolderBounds()
		local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
		local width = math.clamp(math.floor(viewport.X * 0.275 + 0.5), 300, 368)

		NotificationHolder.Size = UDim2.new(0, width, 1, -24)
	end
	local function removeEntryFromList(entry)
		for i = #NotificationEntries, 1, -1 do
			if NotificationEntries[i] == entry then
				table.remove(NotificationEntries, i)

				break
			end
		end
	end
	local function cleanDeadEntries()
		for i = #NotificationEntries, 1, -1 do
			local entry = NotificationEntries[i]
			local isDead = not entry or entry.Removed == true or not entry.Slot or not entry.Slot.Parent

			if isDead then
				table.remove(NotificationEntries, i)
			end
		end
	end
	local function resolveNotificationAccent(config, theme)
		if typeof(config.Color) == "Color3" then
			return config.Color, false
		end
		if typeof(config.AccentColor) == "Color3" then
			return config.AccentColor, false
		end

		local notifType = string.lower(tostring(config.Type or ""))

		if notifType == "warning" or notifType == "warn" then
			return Color3.fromRGB(245, 165, 62), false
		end
		if notifType == "error" then
			return Color3.fromRGB(234, 76, 89), false
		end
		if notifType == "success" then
			return Color3.fromRGB(85, 205, 132), false
		end

		return theme.Accent, true
	end
	local function applyNotificationTheme(entry, theme)
		if not entry or entry.Removed then
			return
		end

		local accentColor = entry.UseThemeAccent and theme.Accent or entry.AccentColor
		local cardColor = BlendColor(theme.Secondary, theme.Primary, 0.2)
		local strokeColor = BlendColor(theme.Accent, theme.Secondary, 0.46)
		local trackColor = BlendColor(theme.Primary, theme.Secondary, 0.65)

		if entry.Card and entry.Card.Parent then
			spr.target(entry.Card, 0.75, 6, { BackgroundColor3 = cardColor })
		end
		if entry.Stroke and entry.Stroke.Parent then
			spr.target(entry.Stroke, 0.75, 6, { Color = strokeColor })
		end
		if entry.Accent and entry.Accent.Parent then
			spr.target(entry.Accent, 0.75, 6, { BackgroundColor3 = accentColor })
		end
		if entry.ProgressBar and entry.ProgressBar.Parent then
			spr.target(entry.ProgressBar, 0.75, 6, { BackgroundColor3 = accentColor })
		end
		if entry.ProgressTrack and entry.ProgressTrack.Parent then
			spr.target(entry.ProgressTrack, 0.75, 6, { BackgroundColor3 = trackColor })
		end
		if entry.Title and entry.Title.Parent then
			entry.Title.TextColor3 = theme.Text
		end
		if entry.Description and entry.Description.Parent then
			entry.Description.TextColor3 = theme.SubText
		end
		if entry.Close and entry.Close.Parent then
			entry.Close.TextColor3 = theme.SubText
		end
	end
	local function removeNotification(entry, immediate)
		if not entry or entry.Removed then
			return
		end

		entry.Removed = true

		removeEntryFromList(entry)

		if entry.ProgressTween then
			pcall(function()
				entry.ProgressTween:Cancel()
			end)

			entry.ProgressTween = nil
		end
		if entry.CloseConn then
			pcall(function()
				entry.CloseConn:Disconnect()
			end)

			entry.CloseConn = nil
		end
		if entry.CloseEnterConn then
			pcall(function()
				entry.CloseEnterConn:Disconnect()
			end)

			entry.CloseEnterConn = nil
		end
		if entry.CloseLeaveConn then
			pcall(function()
				entry.CloseLeaveConn:Disconnect()
			end)

			entry.CloseLeaveConn = nil
		end
		if not entry.Slot or not entry.Slot.Parent then
			return
		end
		if immediate then
			entry.Slot:Destroy()

			return
		end
		if entry.Title and entry.Title.Parent then
			spr.target(entry.Title, 0.75, 6, { TextTransparency = 1 })
		end
		if entry.Description and entry.Description.Parent then
			spr.target(entry.Description, 0.75, 6, { TextTransparency = 1 })
		end
		if entry.Close and entry.Close.Parent then
			spr.target(entry.Close, 0.75, 6, { TextTransparency = 1 })
		end
		if entry.Stroke and entry.Stroke.Parent then
			spr.target(entry.Stroke, 0.75, 6, { Transparency = 1 })
		end
		if entry.ProgressTrack and entry.ProgressTrack.Parent then
			spr.target(entry.ProgressTrack, 0.75, 6, { BackgroundTransparency = 1 })
		end
		if entry.Card and entry.Card.Parent then
			spr.target(entry.Card, 0.75, 6, {
				BackgroundTransparency = 1,
				Position = UDim2.new(0.12, 0, 0, 0),
			})
		end
		if entry.CardScale and entry.CardScale.Parent then
			spr.target(entry.CardScale, 0.75, 6, { Scale = 0.94 })
		end

		task.delay(0.2, function()
			if entry.Slot and entry.Slot.Parent then
				entry.Slot:Destroy()
			end
		end)
	end

	function Library:RefreshNotificationsTheme(themeName)
		local theme = getNotificationTheme(themeName)

		cleanDeadEntries()

		for _, entry in ipairs(NotificationEntries) do
			applyNotificationTheme(entry, theme)
		end
	end
	function Library:SendNotification(title, description, color)
		local config

		if type(title) == "table" then
			config = title
		else
			config = {}

			if description == nil then
				config.Description = tostring(title or "")
			else
				config.Title = tostring(title or "")
				config.Description = tostring(description or "")
			end
			if typeof(color) == "Color3" then
				config.Color = color
			end
		end

		local titleText = TrimLibraryText(config.Title or config.Name or "Vanish | Notification")

		if titleText == "" then
			titleText = "Vanish | Notification"
		end

		local bodyText = TrimLibraryText(config.Description or config.Content or config.Text or "...")

		if bodyText == "" then
			bodyText = "..."
		end

		local duration = math.clamp(tonumber(config.Duration or config.Time) or 6, 1.5, 30)
		local theme = getNotificationTheme()
		local accentColor, useThemeAccent = resolveNotificationAccent(config, theme)

		cleanDeadEntries()

		if #NotificationEntries >= NOTIFICATION_MAX_VISIBLE then
			removeNotification(NotificationEntries[1], true)
		end

		local holderWidth = NotificationHolder.AbsoluteSize.X

		if holderWidth <= 0 then
			local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)

			holderWidth = math.clamp(math.floor(viewport.X * 0.275 + 0.5), 300, 368)
		end

		local textMaxWidth = math.max(170, holderWidth - 74)
		local titleHeight = math.max(
			16,
			TextService:GetTextSize(titleText, 14, Enum.Font.GothamBold, Vector2.new(textMaxWidth, 1000)).Y
		)
		local descHeight =
			math.max(14, TextService:GetTextSize(bodyText, 13, Enum.Font.Gotham, Vector2.new(textMaxWidth, 1000)).Y)
		local targetHeight = math.clamp(28 + titleHeight + descHeight + 18, 64, 172)

		NotificationSerial += 1

		local slot = Instance.new("Frame")

		slot.Name = "ToastSlot_" .. tostring(NotificationSerial)
		slot.BackgroundTransparency = 1
		slot.BorderSizePixel = 0
		slot.Size = UDim2.new(1, 0, 0, targetHeight)
		slot.ClipsDescendants = false
		slot.LayoutOrder = NotificationSerial
		slot.Parent = NotificationHolder

		local card = Instance.new("Frame")

		card.Name = "ToastCard"
		card.BackgroundColor3 = BlendColor(theme.Secondary, theme.Primary, 0.2)
		card.BackgroundTransparency = 1
		card.BorderSizePixel = 0
		card.Size = UDim2.fromScale(1, 1)
		card.Position = UDim2.new(0.08, 0, 0, 0)
		card.Parent = slot

		local cardScale = Instance.new("UIScale")

		cardScale.Scale = 0.91
		cardScale.Parent = card

		local cardCorner = Instance.new("UICorner")

		cardCorner.CornerRadius = UDim.new(0, 10)
		cardCorner.Parent = card

		local cardStroke = Instance.new("UIStroke")

		cardStroke.Color = BlendColor(theme.Accent, theme.Secondary, 0.46)
		cardStroke.Thickness = 1
		cardStroke.Transparency = 1
		cardStroke.Parent = card

		local accent = Instance.new("Frame")

		accent.Name = "Accent"
		accent.Size = UDim2.new(0, 3, 1, -18)
		accent.Position = UDim2.fromOffset(9, 9)
		accent.BackgroundColor3 = accentColor
		accent.BorderSizePixel = 0
		accent.Parent = card

		local accentCorner = Instance.new("UICorner")

		accentCorner.CornerRadius = UDim.new(1, 0)
		accentCorner.Parent = accent

		local body = Instance.new("Frame")

		body.Name = "Body"
		body.BackgroundTransparency = 1
		body.Size = UDim2.new(1, -28, 1, -18)
		body.Position = UDim2.fromOffset(18, 9)
		body.Parent = card

		local titleLabel = Instance.new("TextLabel")

		titleLabel.Name = "Title"
		titleLabel.BackgroundTransparency = 1
		titleLabel.Size = UDim2.new(1, -22, 0, titleHeight)
		titleLabel.Text = titleText
		titleLabel.TextColor3 = theme.Text
		titleLabel.TextTransparency = 1
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 14
		titleLabel.TextWrapped = false
		titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = body

		local descriptionLabel = Instance.new("TextLabel")

		descriptionLabel.Name = "Description"
		descriptionLabel.BackgroundTransparency = 1
		descriptionLabel.Position = UDim2.fromOffset(0, titleHeight + 4)
		descriptionLabel.Size = UDim2.new(1, 0, 0, descHeight)
		descriptionLabel.Text = bodyText
		descriptionLabel.TextColor3 = theme.SubText
		descriptionLabel.TextTransparency = 1
		descriptionLabel.Font = Enum.Font.Gotham
		descriptionLabel.TextSize = 13
		descriptionLabel.TextWrapped = true
		descriptionLabel.TextTruncate = Enum.TextTruncate.None
		descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
		descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
		descriptionLabel.Parent = body

		local closeButton = Instance.new("TextButton")

		closeButton.Name = "Close"
		closeButton.BackgroundTransparency = 1
		closeButton.Size = UDim2.fromOffset(18, 18)
		closeButton.Position = UDim2.new(1, -20, 0, 4)
		closeButton.Text = "x"
		closeButton.Font = Enum.Font.GothamBold
		closeButton.TextSize = 14
		closeButton.TextColor3 = theme.SubText
		closeButton.TextTransparency = 1
		closeButton.AutoButtonColor = false
		closeButton.Parent = body

		local progressTrack = Instance.new("Frame")

		progressTrack.Name = "ProgressTrack"
		progressTrack.BackgroundColor3 = BlendColor(theme.Primary, theme.Secondary, 0.65)
		progressTrack.BackgroundTransparency = 0.22
		progressTrack.BorderSizePixel = 0
		progressTrack.Size = UDim2.new(1, 0, 0, 2)
		progressTrack.Position = UDim2.new(0, 0, 1, -2)
		progressTrack.Parent = card

		local trackCorner = Instance.new("UICorner")

		trackCorner.CornerRadius = UDim.new(1, 0)
		trackCorner.Parent = progressTrack

		local progressBar = Instance.new("Frame")

		progressBar.Name = "ProgressBar"
		progressBar.BackgroundColor3 = accentColor
		progressBar.BorderSizePixel = 0
		progressBar.Size = UDim2.new(1, 0, 1, 0)
		progressBar.Parent = progressTrack

		local barCorner = Instance.new("UICorner")

		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = progressBar

		local entry = {
			Id = NotificationSerial,
			Removed = false,
			UseThemeAccent = useThemeAccent,
			AccentColor = accentColor,
			Slot = slot,
			Card = card,
			CardScale = cardScale,
			Stroke = cardStroke,
			Accent = accent,
			Title = titleLabel,
			Description = descriptionLabel,
			Close = closeButton,
			ProgressTrack = progressTrack,
			ProgressBar = progressBar,
		}

		table.insert(NotificationEntries, entry)
		applyNotificationTheme(entry, theme)
		spr.target(card, 0.75, 5, {
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0.06,
		})
		spr.target(cardScale, 0.72, 5, { Scale = 1 })
		spr.target(cardStroke, 0.75, 5, { Transparency = 0.18 })
		spr.target(titleLabel, 0.8, 6, { TextTransparency = 0 })
		spr.target(descriptionLabel, 0.8, 6, { TextTransparency = 0 })
		spr.target(closeButton, 0.8, 6, { TextTransparency = 0 })

		entry.CloseConn = closeButton.Activated:Connect(function()
			removeNotification(entry, false)
		end)
		entry.CloseEnterConn = closeButton.MouseEnter:Connect(function()
			if entry.Removed then
				return
			end

			local hoverTheme = getNotificationTheme()

			closeButton.TextColor3 = hoverTheme.Text
		end)
		entry.CloseLeaveConn = closeButton.MouseLeave:Connect(function()
			if entry.Removed then
				return
			end

			local hoverTheme = getNotificationTheme()

			closeButton.TextColor3 = hoverTheme.SubText
		end)
		entry.ProgressTween = TweenService:Create(
			progressBar,
			TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(0, 0, 1, 0),
			}
		)

		entry.ProgressTween:Play()
		task.delay(duration, function()
			removeNotification(entry, false)
		end)

		return {
			Close = function()
				removeNotification(entry, false)
			end,
		}
	end

	updateNotificationHolderBounds()

	if Camera then
		Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if notificationViewportPending then
				return
			end

			notificationViewportPending = true

			task.defer(function()
				notificationViewportPending = false

				updateNotificationHolderBounds()
			end)
		end)
	end
	local function MakeStroke(parent, color, thickness, transparency)
		local s = Instance.new("UIStroke")
		s.Color = color or Color3.fromRGB(255, 255, 255)
		s.Thickness = thickness or 1
		s.Transparency = transparency or 0.72
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = parent
		return s
	end

	local function MakeCorner(parent, radius)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, radius or 10)
		c.Parent = parent
		return c
	end

	local function MakeAccentStripe(parent, theme)
		local stripe = Instance.new("Frame")
		stripe.Name = "AccentStripe"
		stripe.Size = UDim2.new(0, 3, 1, -16)
		stripe.Position = UDim2.fromOffset(-1, 8)
		stripe.BackgroundColor3 = theme.Accent
		stripe.BackgroundTransparency = 1
		stripe.BorderSizePixel = 0
		stripe.ZIndex = 4
		MakeCorner(stripe, 3)
		stripe.Parent = parent
		return stripe
	end

	local function MakePressSpring(clickable, targetFrame, getColors)
		if not clickable or not targetFrame then
			return
		end
		local btnScale = targetFrame:FindFirstChild("BtnScale")
		if not btnScale then
			btnScale = Instance.new("UIScale")
			btnScale.Name = "BtnScale"
			btnScale.Scale = 1
			btnScale.Parent = targetFrame
		end
		local state = { hover = false, down = false }
		local function apply()
			spr.target(btnScale, 0.8, 7, { Scale = state.down and 0.972 or (state.hover and 1.008 or 1) })
			if getColors then
				local c = getColors(state, GetTheme())
				if c then
					spr.target(targetFrame, 0.6, 6, { BackgroundColor3 = c })
				end
			end
		end
		clickable.MouseEnter:Connect(function()
			state.hover = true
			apply()
		end)
		clickable.MouseLeave:Connect(function()
			state.hover = false
			state.down = false
			apply()
		end)
		clickable.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				state.down = true
				apply()
			end
		end)
		clickable.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				state.down = false
				apply()
			end
		end)
	end

	function Library:MakeWindow(Config)
		Config = Config or {}

		local UI
		local Main
		local TabsGridLayout

		if type(Config.CustomColors) == "table" then
			Library:SetCustomColors(Config.CustomColors, false)
		end

		currentTheme = ThemeColors[Config.Theme] and Config.Theme or "Dark"

		local funcApplied = {}
		local Tabs_Connections_Data = {}
		local currentPage
		local Switching = false
		local firstOneTab = nil
		local currentSelectedButton = nil

		local function DisableScrolling(page)
			if page and page:IsA("ScrollingFrame") then
				page.ScrollingEnabled = false
			end

			local parent = page and page.Parent

			if parent and parent:IsA("ScrollingFrame") then
				parent.ScrollingEnabled = false
			end
		end
		local function EnableScrolling(page)
			if page and page:IsA("ScrollingFrame") then
				page.ScrollingEnabled = true
			end

			local parent = page and page.Parent

			if parent and parent:IsA("ScrollingFrame") then
				parent.ScrollingEnabled = true
			end
		end
		local function getUIScale()
			return Main.Parent.AutoScale.Scale
		end

		local currentTextFont = Enum.Font.BuilderSansBold

		local function applyCurrentTextFont(rootObj)
			if not rootObj then
				return
			end
			if rootObj:IsA("TextLabel") or rootObj:IsA("TextButton") or rootObj:IsA("TextBox") then
				rootObj.Font = currentTextFont
			end

			for _, obj in ipairs(rootObj:GetDescendants()) do
				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					obj.Font = currentTextFont
				end
			end
		end
		local function GetTheme()
			return NormalizeTheme(ThemeColors[currentTheme] or ThemeColors.Dark)
		end
		local function IsDropdown(element)
			return element.Name == "Dropdown" or element:FindFirstChild("Data")
		end
		local function IsSlider(element)
			return element:FindFirstChild("Gutter") and element.Gutter:FindFirstChild("Fill")
		end
		local function ApplyStroke(inst, theme)
			local stroke = inst:FindFirstChildWhichIsA("UIStroke")

			if stroke then
				stroke.Color = theme.Accent
			end
		end
		local function AttachButtonSpring(clickable, targetFrame, getColors)
			if not clickable or not targetFrame then
				return
			end

			local btnScale = targetFrame:FindFirstChild("ButtonScale")

			if not btnScale then
				btnScale = Instance.new("UIScale")
				btnScale.Name = "ButtonScale"
				btnScale.Scale = 1
				btnScale.Parent = targetFrame
			end

			local state = {
				hover = false,
				down = false,
			}

			local function applyState()
				local scaleGoal = state.down and 0.965 or (state.hover and 1.015 or 1)

				spr.target(btnScale, 0.82, 6, { Scale = scaleGoal })

				if getColors then
					local color = getColors(state, GetTheme())

					if color then
						spr.target(targetFrame, 0.65, 6, { BackgroundColor3 = color })
					end
				end
			end

			Library.ConnectionsList[targetFrame.Name .. " Enter"] = clickable.MouseEnter:Connect(function()
				state.hover = true

				applyState()
			end)
			Library.ConnectionsList[targetFrame.Name .. " Leave"] = clickable.MouseLeave:Connect(function()
				state.hover = false
				state.down = false

				applyState()
			end)
			Library.ConnectionsList[targetFrame.Name .. " Begin"] = clickable.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					state.down = true

					applyState()
				end
			end)
			Library.ConnectionsList[targetFrame.Name .. " End"] = clickable.InputEnded:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					state.down = false

					applyState()
				end
			end)
			Library.ConnectionsList[targetFrame.Name .. " Active"] = clickable.Activated:Connect(function()
				spr.target(btnScale, 0.85, 7, { Scale = 0.955 })
				task.delay(0.06, applyState)
			end)
		end
		local function getTargetPosition(v, elem)
			local scale = getUIScale()
			local relativeY = v.AbsolutePosition.Y - elem.AbsolutePosition.Y

			return (relativeY + elem.CanvasPosition.Y - 6) / scale
		end
		local function getTargetSize(v)
			local scale = getUIScale()

			return v.AbsoluteSize / scale
		end

		local ElementSizeTracking = {}

		local function RegisterElementSize(element, baseHeight, elementType)
			ElementSizeTracking[element] = {
				baseHeight = baseHeight,
				elementType = elementType or "Generic",
			}
		end
		local function UpdateAllElementSizes()
			local currentScale = CalculateUIScale()

			for element, data in pairs(ElementSizeTracking) do
				if element and element.Parent then
					local scaledHeight = data.baseHeight * currentScale

					element.Size = UDim2.new(element.Size.X.Scale, element.Size.X.Offset, 0, scaledHeight)
				else
					ElementSizeTracking[element] = nil
				end
			end
		end
		local function HideInactivePages(activePage)
			local pages = Main and Main:FindFirstChild("Pages")
			if not pages then
				return
			end

			for _, page in ipairs(pages:GetChildren()) do
				if page ~= activePage and page:IsA("GuiObject") then
					page.Visible = false
					page.Position = UDim2.fromScale(0, 0)
					DisableScrolling(page)
				end
			end

			if activePage then
				activePage.Visible = true
				activePage.Position = UDim2.fromScale(0, 0)
				EnableScrolling(activePage)
			end
		end
		local function UpdateTabsFunction()
			if not Main or not Main.Parent then
				return
			end

			local tabsRoot = Main:FindFirstChild("Tabs")
			local pages = Main:FindFirstChild("Pages")

			if not tabsRoot or not pages then
				return
			end

			local folder = tabsRoot:FindFirstChild("Folder")

			if not folder then
				return
			end

			local enabledFrame = folder:FindFirstChild("EnabledFrame")

			if not enabledFrame then
				return
			end

			for i, v in pairs(Tabs_Connections_Data) do
				if v then
					v:Disconnect()
				end

				Tabs_Connections_Data[i] = nil
			end

			table.clear(funcApplied)

			local script = folder
			local autoscale = Main.Parent and Main.Parent:FindFirstChild("AutoScale")
			local lastClickedPosition = enabledFrame.AbsolutePosition.Y

			if currentSelectedButton ~= nil then
				local targetY = getTargetPosition(currentSelectedButton, script.Parent)
				local targetSize = getTargetSize(currentSelectedButton)

				spr.target(enabledFrame, 0.6, 4, {
					Position = UDim2.fromOffset(0, targetY),
					Size = UDim2.fromOffset(targetSize.X, targetSize.Y),
				})
			end

			do
				for _, v in script.Parent:GetChildren() do
					if v:FindFirstChild("ClickDetector") then
						local button = v.ClickDetector

						if firstOneTab == nil then
							if pages:FindFirstChild(v.Name) then
								enabledFrame.Visible = true
								Switching = true

								local targetY = getTargetPosition(v, script.Parent)
								local targetSize = getTargetSize(v)
								local Page = (function()
									return pages:FindFirstChild(v.Name)
								end)()
								if not Page then
									Switching = false
									return
								end

								if currentPage then
									if currentPage == Page then
										Switching = false
										HideInactivePages(Page)
										return
									end

									currentPage.Visible = true
								end

								Page.Visible = true
								firstOneTab = v
								currentSelectedButton = v
								lastClickedPosition = targetY

								local currentFrameY = enabledFrame.AbsolutePosition.Y
								local buttonY = v.AbsolutePosition.Y
								local newHeight = targetSize.Y * 1.25

								if currentFrameY < buttonY then
									spr.target(enabledFrame, 0.6, 4, {
										Position = UDim2.fromOffset(0, targetY),
										Size = UDim2.fromOffset(targetSize.X, newHeight),
									})

									Page.Position = UDim2.fromScale(0, 1.1)
								else
									local heightDiff = newHeight - targetSize.Y

									spr.target(enabledFrame, 0.6, 4, {
										Position = UDim2.fromOffset(0, targetY - heightDiff),
										Size = UDim2.fromOffset(targetSize.X, newHeight),
									})

									Page.Position = UDim2.fromScale(0, -1.1)
								end
								if currentPage then
									spr.target(currentPage, 0.6, 4, {
										Position = UDim2.fromScale(0, -Page.Position.Y.Scale),
									})
								end

								spr.target(Page, 0.6, 4, {
									Position = UDim2.fromScale(0, 0),
								})
								task.wait(0.15)
								spr.target(enabledFrame, 0.6, 4, {
									Position = UDim2.fromOffset(0, targetY),
									Size = UDim2.fromOffset(targetSize.X, targetSize.Y),
								})

								currentPage = Page
								HideInactivePages(Page)

								task.wait(1)

								Switching = false
							end
						end
						if not funcApplied[v] then
							enabledFrame.AnchorPoint = Vector2.new(0, 0)
							Tabs_Connections_Data["MouseEnter " .. v.Name] = button.MouseEnter:Connect(function()
								if Switching then
									return
								end

								local targetSize = getTargetSize(v)
								local currentFrameY = enabledFrame.AbsolutePosition.Y
								local buttonY = v.AbsolutePosition.Y
								local newHeight = targetSize.Y * 1.1
								local currentHeight = enabledFrame.AbsoluteSize.Y / getUIScale()

								if currentFrameY < buttonY then
									spr.target(enabledFrame, 0.6, 4, {
										Size = UDim2.fromOffset(targetSize.X, newHeight),
									})
								else
									local heightDiff = newHeight - currentHeight
									local currentPos = enabledFrame.Position.Y.Offset

									spr.target(enabledFrame, 0.6, 4, {
										Position = UDim2.fromOffset(0, currentPos - heightDiff),
										Size = UDim2.fromOffset(targetSize.X, newHeight),
									})
								end
							end)
							Tabs_Connections_Data["MouseLeave " .. v.Name] = button.MouseLeave:Connect(function()
								if Switching then
									return
								end
								if currentSelectedButton then
									local scale = getUIScale()
									local relativeY = currentSelectedButton.AbsolutePosition.Y
										- script.Parent.AbsolutePosition.Y
									local returnPosition = (relativeY + script.Parent.CanvasPosition.Y - 6) / scale
									local returnSize = currentSelectedButton.AbsoluteSize / getUIScale()

									spr.target(enabledFrame, 0.6, 4, {
										Position = UDim2.fromOffset(0, returnPosition),
										Size = UDim2.fromOffset(returnSize.X, returnSize.Y),
									})
								else
									spr.target(enabledFrame, 0.6, 4, {
										Position = UDim2.fromOffset(0, lastClickedPosition),
										Size = UDim2.fromOffset(
											enabledFrame.AbsoluteSize.X,
											enabledFrame.AbsoluteSize.Y
										),
									})
								end
							end)
							Tabs_Connections_Data["Activated " .. v.Name] = button.Activated:Connect(function()
								enabledFrame.Visible = true
								Switching = true

								local targetY = getTargetPosition(v, script.Parent)
								local targetSize = getTargetSize(v)
								local Page = (function()
									return pages:FindFirstChild(v.Name)
								end)()
								if not Page then
									Switching = false
									return
								end

								if currentPage then
									if currentPage == Page then
										Switching = false
										HideInactivePages(Page)
										return
									end

									currentPage.Visible = true
								end

								Page.Visible = true
								currentSelectedButton = v
								lastClickedPosition = targetY

								local currentFrameY = enabledFrame.AbsolutePosition.Y
								local buttonY = v.AbsolutePosition.Y
								local newHeight = targetSize.Y * 1.25

								if currentFrameY < buttonY then
									spr.target(enabledFrame, 0.6, 4, {
										Position = UDim2.fromOffset(0, targetY),
										Size = UDim2.fromOffset(targetSize.X, newHeight),
									})

									Page.Position = UDim2.fromScale(0, 1.1)
								else
									local heightDiff = newHeight - targetSize.Y

									spr.target(enabledFrame, 0.6, 4, {
										Position = UDim2.fromOffset(0, targetY - heightDiff),
										Size = UDim2.fromOffset(targetSize.X, newHeight),
									})

									Page.Position = UDim2.fromScale(0, -1.1)
								end
								if currentPage then
									spr.target(currentPage, 0.6, 4, {
										Position = UDim2.fromScale(0, -Page.Position.Y.Scale),
									})
								end

								spr.target(Page, 0.6, 4, {
									Position = UDim2.fromScale(0, 0),
								})
								task.wait(0.15)
								spr.target(enabledFrame, 0.6, 4, {
									Position = UDim2.fromOffset(0, targetY),
									Size = UDim2.fromOffset(targetSize.X, targetSize.Y),
								})

								currentPage = Page
								HideInactivePages(Page)

								task.wait(1)

								Switching = false
							end)
							funcApplied[v] = true
						end
					end
				end
			end
		end

		local Tabs = {}

		function Tabs:MakeChatTab(config)
			config = config or {}

			local DiscordChatData = {}
			local ChatTabFallbackIcon = "rbxasset://textures/ui/TopBar/chatOff.png"
			local AvatarFallbackIcon = "rbxasset://textures/ui/GuiImagePlaceholder.png"

			local function IsProbablyImagePath(value)
				if typeof(value) ~= "string" then
					return false
				end

				return value:find("^rbxasset") ~= nil
					or value:find("^rbxthumb://") ~= nil
					or value:find("^https?://") ~= nil
			end
			local function ResolveBoolSetting(defaultValue, ...)
				local items = { ... }

				for _, item in ipairs(items) do
					if item ~= nil then
						return item == true
					end
				end

				return defaultValue
			end
			local function NormalizeDiscordConfiguration(rawConfig, rootConfig)
				local constants = {}
				rawConfig = type(rawConfig) == "table" and rawConfig or {}
				rootConfig = type(rootConfig) == "table" and rootConfig or {}

				for key, value in pairs(rawConfig) do
					if type(key) ~= "number" then
						constants[key] = value
					end
				end

				constants.WebSocketLink = rawConfig[1]
					or rawConfig.WebSocketLink
					or rawConfig.WebsocketLink
					or rawConfig.WebSocket
					or rawConfig.Websocket
					or rawConfig.Link
					or rootConfig.Link
					or constants.WebSocketLink
				constants.Webhook = rawConfig[2]
					or rawConfig.Webhook
					or rawConfig.WebhookUrl
					or rawConfig.WebhookURL
					or constants.Webhook
				constants.Channel = rawConfig[3]
					or rawConfig.Channel
					or rawConfig.ChannelId
					or rawConfig.ChannelID
					or constants.Channel

				return constants
			end

			DiscordChatData.Name = config[1] or config.Title or config.Name or "Chat"

			do
				local iconRequest = config[2] or config.Icon
				local resolvedIcon = nil

				if type(iconRequest) == "string" and iconRequest ~= "" then
					local ok, asset = pcall(Lucide.GetAsset, iconRequest)

					if ok and asset then
						resolvedIcon = asset
					end
				end
				if not resolvedIcon then
					for _, fallbackIcon in ipairs({
						"message-circle-more",
						"message-square",
						"messages-square",
					}) do
						local ok, asset = pcall(Lucide.GetAsset, fallbackIcon)

						if ok and asset then
							resolvedIcon = asset

							break
						end
					end
				end

				DiscordChatData.Icon = resolvedIcon
					or (IsProbablyImagePath(config.Icon) and config.Icon)
					or ChatTabFallbackIcon
			end

			DiscordChatData.Constants = NormalizeDiscordConfiguration(config.Configuration, config)
			DiscordChatData.AsGuest = config and (config.Guest == true or config.AsGuest == true or config[3] == true)
				or false
			DiscordChatData.Link = DiscordChatData.Constants.WebSocketLink
				or DiscordChatData.Constants.Link
				or config.Link
			local bridgeConfig = TABLE_MAIN and (TABLE_MAIN.DiscordBridge or TABLE_MAIN.WebsocketServer) or {}
			DiscordChatData.WebSocketServer = DiscordChatData.Link or bridgeConfig.WSLink or bridgeConfig.Server
			DiscordChatData.Cooldown_SendingMessage = false
			DiscordChatData.ActiveReply = nil
			DiscordChatData.HoldDuration = tonumber(DiscordChatData.Constants.ReplyHoldDuration) or 0.55
			DiscordChatData.OnNewMessageValue = DiscordChatData.Constants.OnNewMessageValue
				or DiscordChatData.Constants.CallbackValue
				or DiscordChatData.Constants.Value
			DiscordChatData._OnNewMessageCallbacks = {}
			DiscordChatData._MessageCounter = 0
			DiscordChatData.GetsNewMessagesNotification = ResolveBoolSetting(
				true,
				DiscordChatData.Constants.GetsNewMessagesNotification,
				DiscordChatData.Constants["Gets New Messages Notification"]
			)
			DiscordChatData.NewMessageNotifyDuration = tonumber(DiscordChatData.Constants.NewMessageNotifyDuration) or 6
			DiscordChatData.NotifyOnlyWhenChatHidden =
				ResolveBoolSetting(true, DiscordChatData.Constants.NotifyOnlyWhenChatHidden)
			DiscordChatData.MessageEntries = {}
			DiscordChatData.MessageGroups = {}
			DiscordChatData.ActionReplyPayload = nil
			DiscordChatData.AuthorIdentityCache = {
				ByKey = {},
				AvatarById = {},
			}
			DiscordChatData.ModerationState = {
				Strikes = 0,
				MutedUntil = 0,
				LastReason = "",
				LastUpdated = 0,
			}
			DiscordChatData.LastModerationSync = 0
			DiscordChatData.MuteDurations = DiscordChatData.Constants.MuteDurations
				or {
					300,
					1800,
					3600,
					10800,
				}
			DiscordChatData.SpamWindowSeconds = tonumber(DiscordChatData.Constants.SpamWindowSeconds) or 5
			DiscordChatData.SpamWarnThreshold = tonumber(DiscordChatData.Constants.SpamWarnThreshold) or 5
			DiscordChatData.SpamMuteThreshold = tonumber(DiscordChatData.Constants.SpamMuteThreshold) or 8
			DiscordChatData.CombineWindowSeconds = tonumber(DiscordChatData.Constants.CombineWindowSeconds) or 600
			DiscordChatData.BypassStrikeThreshold = tonumber(DiscordChatData.Constants.BypassStrikeThreshold) or 3
			DiscordChatData.BypassWindowSeconds = tonumber(DiscordChatData.Constants.BypassWindowSeconds)
				or math.max(4, DiscordChatData.SpamWindowSeconds)
			DiscordChatData.CooldownDuration = tonumber(DiscordChatData.Constants.SendCooldownSeconds) or 1.2
			DiscordChatData.DoubleSendWindow = tonumber(DiscordChatData.Constants.DoubleSendWindow) or 0.85
			DiscordChatData.MaxMessageLength = tonumber(DiscordChatData.Constants.MaxMessageLength) or 320
			DiscordChatData.CapsWarnThreshold = tonumber(DiscordChatData.Constants.CapsWarnThreshold) or 0.82
			DiscordChatData.CapsMinLetters = tonumber(DiscordChatData.Constants.CapsMinLetters) or 18
			DiscordChatData.RepeatCharThreshold = tonumber(DiscordChatData.Constants.RepeatCharThreshold) or 11
			DiscordChatData.StrikeDecaySeconds = tonumber(DiscordChatData.Constants.StrikeDecaySeconds) or 900
			DiscordChatData.SpamAttempts = {}
			DiscordChatData.BypassAttempts = {}
			DiscordChatData.LastBubbleRootId = nil
			DiscordChatData._GroupCounter = 0
			DiscordChatData.IsSendingNow = false
			DiscordChatData.LastSendSignature = ""
			DiscordChatData.LastSendTick = 0
			DiscordChatData.CooldownUntil = 0

			do
				local fallbackDurations = {
					300,
					1800,
					3600,
					10800,
				}
				local normalized = {}

				if type(DiscordChatData.MuteDurations) == "table" then
					for _, rawValue in ipairs(DiscordChatData.MuteDurations) do
						local num = tonumber(rawValue)

						if num and num > 0 then
							table.insert(normalized, math.floor(num))
						end
					end
				end
				if #normalized == 0 then
					DiscordChatData.MuteDurations = fallbackDurations
				else
					DiscordChatData.MuteDurations = normalized
				end
			end

			local DefaultBlacklistWords = {
				"nigga",
				"nga",
				"nigger",
				"bitch",
				"fuck",
				"fucking",
				"shit",
				"asshole",
				"motherfucker",
				"retard",
				"slut",
				"whore",
				"bastard",
				"dick",
				"pussy",
				"faggot",
				"cunt",
				"porn",
				"pornhub",
				"discord.gg",
				"eclipse hub",
				"eclipse",
				"ethanoj1",
				"skid",
				"discohook",
			}

			DiscordChatData.BlacklistWords = {}

			local function TrimText(text)
				return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
			end
			local function AddWords(source)
				if typeof(source) ~= "table" then
					return
				end

				for _, word in ipairs(source) do
					if typeof(word) == "string" then
						local clean = TrimText(word):lower()

						if clean ~= "" and not table.find(DiscordChatData.BlacklistWords, clean) then
							table.insert(DiscordChatData.BlacklistWords, clean)
						end
					end
				end
			end

			if DiscordChatData.Constants.UseDefaultBlacklist ~= false then
				AddWords(DefaultBlacklistWords)
			end

			AddWords(
				DiscordChatData.Constants.BlacklistWords
					or DiscordChatData.Constants.BlacklistedWords
					or DiscordChatData.Constants.BadWords
			)

			DiscordChatData.WordBlacklistEnabled = DiscordChatData.Constants.EnableBlacklistWords ~= false
			DiscordChatData.MaskBlacklistedIncoming = DiscordChatData.Constants.MaskBlacklistedIncoming ~= false
			DiscordChatData.LinkFilterEnabled = ResolveBoolSetting(
				true,
				DiscordChatData.Constants.LinkFilterEnabled,
				DiscordChatData.Constants.BlockLinks,
				DiscordChatData.Constants["Link Filter"]
			)

			local BlacklistBypassMap = {
				["0"] = "o",
				["1"] = "i",
				["2"] = "z",
				["3"] = "e",
				["4"] = "a",
				["5"] = "s",
				["6"] = "g",
				["7"] = "t",
				["8"] = "b",
				["9"] = "g",
				["@"] = "a",
				["$"] = "s",
				["!"] = "i",
				["+"] = "t",
				["|"] = "i",
			}

			local function ApplyBypassMap(text)
				local source = tostring(text or ""):lower()
				local output = {}

				for i = 1, #source do
					local ch = source:sub(i, i)

					output[i] = BlacklistBypassMap[ch] or ch
				end

				return table.concat(output)
			end
			local function BuildBlacklistVariants(text)
				local lowered = tostring(text or ""):lower()
				local mapped = ApplyBypassMap(lowered)
				local compact = mapped:gsub("[_%W]+", "")
				local compactTight = compact:gsub("(.)%1+", "%1")
				local mappedTight = mapped:gsub("(.)%1%1+", "%1%1")

				return {
					lowered = lowered,
					mapped = mapped,
					compact = compact,
					compactTight = compactTight,
					mappedTight = mappedTight,
				}
			end
			local function IsWordChar(ch)
				return ch ~= "" and ch:match("[%w]") ~= nil
			end
			local function FindWithBoundaries(haystack, needle)
				if haystack == "" or needle == "" then
					return nil, nil
				end

				local startAt = 1

				while true do
					local s, e = haystack:find(needle, startAt, true)

					if not s then
						return nil, nil
					end

					local prev = s > 1 and haystack:sub(s - 1, s - 1) or ""
					local nextChar = e < #haystack and haystack:sub(e + 1, e + 1) or ""

					if not IsWordChar(prev) and not IsWordChar(nextChar) then
						return s, e
					end

					startAt = e + 1
				end
			end

			DiscordChatData.BlacklistIndex = {}

			local function RebuildBlacklistIndex()
				local out = {}

				for _, word in ipairs(DiscordChatData.BlacklistWords) do
					local normalized = TrimText(word):lower()

					if normalized ~= "" then
						table.insert(out, {
							word = normalized,
							variants = BuildBlacklistVariants(normalized),
							requireBoundary = normalized:match("^[%w]+$") ~= nil,
						})
					end
				end

				DiscordChatData.BlacklistIndex = out
			end

			RebuildBlacklistIndex()

			local function ContainsBlacklistedWord(text)
				if not DiscordChatData.WordBlacklistEnabled then
					return false, nil
				end

				local textVariants = BuildBlacklistVariants(text)

				for _, item in ipairs(DiscordChatData.BlacklistIndex) do
					local wordVariants = item.variants
					local findFn = item.requireBoundary and FindWithBoundaries
						or function(haystack, needle)
							return haystack:find(needle, 1, true)
						end
					local found = findFn(textVariants.lowered, wordVariants.lowered)
						or findFn(textVariants.mapped, wordVariants.mapped)
						or (wordVariants.compact ~= "" and findFn(textVariants.compact, wordVariants.compact))
						or (wordVariants.compactTight ~= "" and findFn(
							textVariants.compactTight,
							wordVariants.compactTight
						))
						or (wordVariants.compact ~= "" and findFn(textVariants.mappedTight, wordVariants.compact))

					if found then
						return true, item.word
					end
				end

				return false, nil
			end
			local function MaskBlacklistedWords(text)
				local masked = tostring(text or "")

				if not DiscordChatData.MaskBlacklistedIncoming then
					return masked
				end

				local lowered = masked:lower()

				for _, item in ipairs(DiscordChatData.BlacklistIndex) do
					local word = item.word
					local startAt = 1

					while true do
						local s, e = lowered:find(word, startAt, true)

						if not s then
							break
						end
						if item.requireBoundary then
							local prev = s > 1 and lowered:sub(s - 1, s - 1) or ""
							local nextChar = e < #lowered and lowered:sub(e + 1, e + 1) or ""

							if IsWordChar(prev) or IsWordChar(nextChar) then
								startAt = e + 1
								s = nil
							end
						end
						if s then
							masked = masked:sub(1, s - 1) .. string.rep("*", e - s + 1) .. masked:sub(e + 1)
							lowered = lowered:sub(1, s - 1) .. string.rep("*", e - s + 1) .. lowered:sub(e + 1)
							startAt = e + 1
						end
					end
				end

				local stillBlacklisted = ContainsBlacklistedWord(masked)

				if stillBlacklisted then
					return "[Blocked by blacklist]"
				end

				return masked
			end
			local function GetRequestFunction()
				return http_request or request or HttpRequest or (syn and syn.request)
			end
			local RemoteImageCache = {
				Folder = "Vanish/DiscordAvatarCache",
				Memory = {},
				Downloading = {},
				Pending = {},
			}
			local function CanUseRemoteImageCache()
				return type(isfolder) == "function"
					and type(makefolder) == "function"
					and type(isfile) == "function"
					and type(writefile) == "function"
					and (type(getcustomasset) == "function" or type(getsynasset) == "function")
			end
			local function EnsureRemoteImageCacheFolder()
				if not CanUseRemoteImageCache() then
					return false
				end
				if not isfolder("Vanish") then
					pcall(makefolder, "Vanish")
				end
				if not isfolder(RemoteImageCache.Folder) then
					pcall(makefolder, RemoteImageCache.Folder)
				end
				return isfolder(RemoteImageCache.Folder)
			end
			local function IsHttpImage(value)
				return typeof(value) == "string" and value:find("^https?://") ~= nil
			end
			local function GetRemoteImageExtension(url)
				local clean = tostring(url or ""):lower():gsub("%?.*$", "")
				local ext = clean:match("%.([%w]+)$")

				if ext == "jpg" or ext == "jpeg" or ext == "png" or ext == "webp" or ext == "gif" then
					return ext == "jpeg" and "jpg" or ext
				end

				return "png"
			end
			local function HashRemoteImageUrl(url)
				local hash = 5381
				local text = tostring(url or "")

				for i = 1, #text do
					hash = ((hash * 33) + string.byte(text, i)) % 2147483647
				end

				return string.format("%x", hash)
			end
			local function GetRawMessageValue(rawMessage, ...)
				if typeof(rawMessage) ~= "table" then
					return nil
				end

				for _, key in ipairs({ ... }) do
					local value = rawMessage[key]

					if value ~= nil and tostring(value) ~= "" then
						return value
					end
				end

				return nil
			end
			local function NormalizeIdentityPart(value)
				return TrimText(tostring(value or "")):lower()
			end
			local function ResolveAuthorIdentity(rawMessage, authorName, avatarUrl)
				local cache = DiscordChatData.AuthorIdentityCache
				local author = rawMessage and rawMessage.author or nil
				local authorId = TrimText(
					tostring(
						GetRawMessageValue(
							rawMessage,
							"authorId",
							"authorIdentity",
							"author_id",
							"userId",
							"user_id",
							"robloxUserId",
							"roblox_user_id"
						)
							or (author and (author.id or author.user_id or author.userId))
							or ""
					)
				)
				local webhookId = TrimText(tostring(GetRawMessageValue(rawMessage, "webhook_id", "webhookId") or ""))
				local normalizedName = NormalizeIdentityPart(authorName)

				if authorId ~= "" then
					if IsProbablyImagePath(avatarUrl) then
						cache.AvatarById[authorId] = avatarUrl
					end

					return authorId
				end
				if normalizedName == NormalizeIdentityPart(lp.Name) then
					authorId = "roblox:" .. tostring(lp.UserId)
				elseif DiscordChatData.AsGuest and normalizedName == "guest" then
					authorId = "roblox-guest:" .. tostring(lp.UserId)
				else
					local key = table.concat({
						webhookId ~= "" and ("webhook:" .. webhookId) or "webhook:none",
						"name:" .. (normalizedName ~= "" and normalizedName or "unknown"),
					}, "|")

					authorId = cache.ByKey[key]

					if not authorId then
						authorId = "generated:" .. HashRemoteImageUrl(key)
						cache.ByKey[key] = authorId
					end
				end

				if IsProbablyImagePath(avatarUrl) then
					cache.AvatarById[authorId] = avatarUrl
				end

				return authorId
			end
			local function GetCachedRemoteImagePath(url)
				return string.format(
					"%s/%s.%s",
					RemoteImageCache.Folder,
					HashRemoteImageUrl(url),
					GetRemoteImageExtension(url)
				)
			end
			local function GetCustomAssetPath(path)
				local ok, asset = pcall(function()
					if type(getcustomasset) == "function" then
						return getcustomasset(path)
					end
					if type(getsynasset) == "function" then
						return getsynasset(path)
					end
					return nil
				end)

				return ok and asset or nil
			end
			local function GetCachedRemoteImage(url)
				if not IsHttpImage(url) or not CanUseRemoteImageCache() then
					return nil
				end
				if RemoteImageCache.Memory[url] then
					return RemoteImageCache.Memory[url]
				end
				if not EnsureRemoteImageCacheFolder() then
					return nil
				end

				local path = GetCachedRemoteImagePath(url)

				if isfile(path) then
					local asset = GetCustomAssetPath(path)

					if asset then
						RemoteImageCache.Memory[url] = asset
						return asset
					end
				end

				return nil
			end
			local function QueueRemoteImageCache(url, onCached)
				if not IsHttpImage(url) or not CanUseRemoteImageCache() then
					return
				end
				if GetCachedRemoteImage(url) then
					if type(onCached) == "function" then
						onCached(RemoteImageCache.Memory[url])
					end
					return
				end
				if type(onCached) == "function" then
					RemoteImageCache.Pending[url] = RemoteImageCache.Pending[url] or {}
					table.insert(RemoteImageCache.Pending[url], onCached)
				end
				if RemoteImageCache.Downloading[url] then
					return
				end

				RemoteImageCache.Downloading[url] = true
				task.spawn(function()
					local cachedAsset = nil

					pcall(function()
						if not EnsureRemoteImageCacheFolder() then
							return
						end

						local requestFn = GetRequestFunction()

						if typeof(requestFn) ~= "function" then
							return
						end

						local response = requestFn({
							Url = url,
							Method = "GET",
						})
						local statusCode = tonumber(
							response and (response.StatusCode or response.status or response.Code)
						) or 0
						local body = response and response.Body

						if
							(statusCode ~= 0 and (statusCode < 200 or statusCode >= 300))
							or type(body) ~= "string"
							or body == ""
						then
							return
						end

						local path = GetCachedRemoteImagePath(url)

						writefile(path, body)
						cachedAsset = GetCustomAssetPath(path)
						if cachedAsset then
							RemoteImageCache.Memory[url] = cachedAsset
						end
					end)

					RemoteImageCache.Downloading[url] = nil
					local pending = RemoteImageCache.Pending[url]
					RemoteImageCache.Pending[url] = nil
					if cachedAsset and type(pending) == "table" then
						for _, callback in ipairs(pending) do
							task.spawn(callback, cachedAsset)
						end
					end
				end)
			end
			local function ResolveCachedRemoteImage(url)
				return GetCachedRemoteImage(url) or url
			end
			local SetImageWithFallback
			local function IsValidLucideAsset(asset)
				return typeof(asset) == "table"
					and IsProbablyImagePath(asset.Url)
					and typeof(asset.ImageRectSize) == "Vector2"
					and typeof(asset.ImageRectOffset) == "Vector2"
			end
			local function ApplyImageAsset(imageObject, asset, fallbackImage)
				if not imageObject or not imageObject:IsA("ImageLabel") then
					return
				end
				local fallback = IsProbablyImagePath(fallbackImage) and fallbackImage or ChatTabFallbackIcon

				if IsValidLucideAsset(asset) then
					imageObject:SetAttribute("DiscordImageToken", nil)
					imageObject.Image = asset.Url
					imageObject.ImageRectSize = asset.ImageRectSize
					imageObject.ImageRectOffset = asset.ImageRectOffset
					return
				end

				imageObject.ImageRectSize = Vector2.zero
				imageObject.ImageRectOffset = Vector2.zero
				SetImageWithFallback(imageObject, IsProbablyImagePath(asset) and asset or fallback, fallback)
			end
			SetImageWithFallback = function(imageObject, candidateImage, fallbackImage)
				if not imageObject or not imageObject:IsA("ImageLabel") then
					return
				end

				local fallback = IsProbablyImagePath(fallbackImage) and fallbackImage or AvatarFallbackIcon
				local candidate = IsProbablyImagePath(candidateImage) and candidateImage or fallback
				local originalCandidate = candidate
				local imageToken = HttpService:GenerateGUID(false)

				imageObject:SetAttribute("DiscordImageToken", imageToken)

				candidate = ResolveCachedRemoteImage(candidate)

				imageObject.ImageRectSize = Vector2.zero
				imageObject.ImageRectOffset = Vector2.zero

				imageObject.Image = candidate
				QueueRemoteImageCache(originalCandidate, function(cachedAsset)
					if
						imageObject
						and imageObject.Parent
						and imageObject:GetAttribute("DiscordImageToken") == imageToken
						and IsProbablyImagePath(cachedAsset)
					then
						imageObject.Image = cachedAsset
					end
				end)

				task.delay(2.5, function()
					if
						not imageObject
						or not imageObject.Parent
						or imageObject:GetAttribute("DiscordImageToken") ~= imageToken
					then
						return
					end

					local okLoaded, isLoaded = pcall(function()
						return imageObject.IsLoaded
					end)

					if not okLoaded or not isLoaded then
						local cachedAsset = GetCachedRemoteImage(originalCandidate)
						if cachedAsset then
							imageObject.Image = cachedAsset
						else
							QueueRemoteImageCache(originalCandidate, function(asset)
								if
									imageObject
									and imageObject.Parent
									and imageObject:GetAttribute("DiscordImageToken") == imageToken
									and IsProbablyImagePath(asset)
								then
									imageObject.Image = asset
								end
							end)
							task.delay(3, function()
								if
									imageObject
									and imageObject.Parent
									and imageObject:GetAttribute("DiscordImageToken") == imageToken
								then
									local retryOk, retryLoaded = pcall(function()
										return imageObject.IsLoaded
									end)
									if not retryOk or not retryLoaded then
										imageObject.Image = fallback
									end
								end
							end)
						end
					end
				end)
			end
			local function BuildAvatarUrl(rawMessage)
				local author = rawMessage and rawMessage.author or nil
				local function prepareAvatarUrl(url)
					QueueRemoteImageCache(url)
					return ResolveCachedRemoteImage(url)
				end

				if rawMessage and typeof(rawMessage.avatar_url) == "string" and rawMessage.avatar_url ~= "" then
					return prepareAvatarUrl(rawMessage.avatar_url)
				end
				if rawMessage and typeof(rawMessage.avatarUrl) == "string" and rawMessage.avatarUrl ~= "" then
					return prepareAvatarUrl(rawMessage.avatarUrl)
				end
				if
					rawMessage
					and typeof(rawMessage.authorAvatarUrl) == "string"
					and rawMessage.authorAvatarUrl ~= ""
				then
					return prepareAvatarUrl(rawMessage.authorAvatarUrl)
				end
				if rawMessage and typeof(rawMessage.authorAvatar) == "string" and rawMessage.authorAvatar ~= "" then
					return prepareAvatarUrl(rawMessage.authorAvatar)
				end
				if author and typeof(author.avatar_url) == "string" and author.avatar_url ~= "" then
					return prepareAvatarUrl(author.avatar_url)
				end
				if author and typeof(author.avatarUrl) == "string" and author.avatarUrl ~= "" then
					return prepareAvatarUrl(author.avatarUrl)
				end
				if author and typeof(author.display_avatar_url) == "string" and author.display_avatar_url ~= "" then
					return prepareAvatarUrl(author.display_avatar_url)
				end
				if author and IsHttpImage(author.avatar) then
					return prepareAvatarUrl(author.avatar)
				end
				if author and tostring(author.id or "") ~= "" and tostring(author.avatar or "") ~= "" then
					return prepareAvatarUrl(
						string.format("https://cdn.discordapp.com/avatars/%s/%s.png?size=128", author.id, author.avatar)
					)
				end

				local defaultIndex = 0

				if author and author.discriminator then
					local discriminator = tonumber(author.discriminator)

					if discriminator then
						defaultIndex = discriminator % 5
					end
				end

				return prepareAvatarUrl(
					DiscordChatData.Constants.DefaultAvatarUrl
						or string.format("https://cdn.discordapp.com/embed/avatars/%d.png", defaultIndex)
				)
			end
			local function ResolveLocalPlayerDiscordAvatarUrl()
				if IsHttpImage(DiscordChatData.LocalPlayerDiscordAvatarUrl) then
					return DiscordChatData.LocalPlayerDiscordAvatarUrl
				end

				local fallbackUrl = string.format(
					"https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
					lp.UserId
				)
				local requestFn = GetRequestFunction()

				if typeof(requestFn) == "function" then
					local ok, result = pcall(function()
						return requestFn({
							Url = string.format(
								"https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png&isCircular=false",
								lp.UserId
							),
							Method = "GET",
							Headers = {
								["Content-Type"] = "application/json",
							},
						})
					end)

					if ok and result then
						local statusCode = tonumber(result.StatusCode or result.status or result.Code) or 0
						local body = tostring(result.Body or result.body or result.ResponseBody or "")

						if (statusCode == 0 or (statusCode >= 200 and statusCode < 300)) and body ~= "" then
							local decodeOk, decoded = pcall(function()
								return HttpService:JSONDecode(body)
							end)
							local entry = decodeOk and type(decoded) == "table" and decoded.data and decoded.data[1]
							local imageUrl = type(entry) == "table" and tostring(entry.imageUrl or "") or ""

							if IsHttpImage(imageUrl) then
								DiscordChatData.LocalPlayerDiscordAvatarUrl = imageUrl
								QueueRemoteImageCache(imageUrl)
								return imageUrl
							end
						end
					end
				end

				DiscordChatData.LocalPlayerDiscordAvatarUrl = fallbackUrl
				QueueRemoteImageCache(fallbackUrl)
				return fallbackUrl
			end
			local function EmitOnNewMessage(payload)
				for _, callback in ipairs(DiscordChatData._OnNewMessageCallbacks) do
					task.spawn(function()
						callback(payload, DiscordChatData.OnNewMessageValue)
					end)
				end
			end

			function DiscordChatData:OnNewMessage(callback)
				if typeof(callback) ~= "function" then
					warn("OnNewMessage callback must be a function")

					return {
						Disconnect = function() end,
					}
				end

				table.insert(DiscordChatData._OnNewMessageCallbacks, callback)

				local disconnected = false

				return {
					Disconnect = function()
						if disconnected then
							return
						end

						disconnected = true

						for i, cb in ipairs(DiscordChatData._OnNewMessageCallbacks) do
							if cb == callback then
								table.remove(DiscordChatData._OnNewMessageCallbacks, i)

								break
							end
						end
					end,
				}
			end
			function DiscordChatData:SetGetsNewMessagesNotification(toggle)
				DiscordChatData.GetsNewMessagesNotification = toggle == true
			end
			function DiscordChatData:GetGetsNewMessagesNotification()
				return DiscordChatData.GetsNewMessagesNotification
			end

			local UpdateInputPanelLayout = function() end
			local Page = (function()
				local TabPage = Instance.new("ScrollingFrame")

				TabPage.Name = DiscordChatData.Name
				TabPage.Size = UDim2.new(1, 0, 1, 0)
				TabPage.BackgroundColor3 = GetTheme().Chat.Background
				TabPage.BackgroundTransparency = 0
				TabPage.ClipsDescendants = true
				TabPage.ScrollBarThickness = 0
				TabPage.BorderSizePixel = 0
				TabPage.Visible = false
				TabPage.ScrollBarImageTransparency = 1
				TabPage.ScrollingEnabled = false
				TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
				TabPage.AutomaticCanvasSize = Enum.AutomaticSize.None
				TabPage.Parent = Main.Pages

				TabPage:SetAttribute("IsChat", true)

				local AnimatedBackground = Instance.new("Frame")

				AnimatedBackground.Name = "AnimatedBackground"
				AnimatedBackground.Size = UDim2.fromScale(1, 1)
				AnimatedBackground.BackgroundColor3 = GetTheme().Chat.BackgroundAlt
				AnimatedBackground.BorderSizePixel = 0
				AnimatedBackground.ZIndex = 0
				AnimatedBackground.Parent = TabPage

				local BackgroundGradient = Instance.new("UIGradient")

				BackgroundGradient.Name = "BackgroundGradient"
				BackgroundGradient.Rotation = 20
				BackgroundGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, GetTheme().Chat.BackgroundAlt),
					ColorSequenceKeypoint.new(0.5, GetTheme().Chat.Background),
					ColorSequenceKeypoint.new(1, GetTheme().Chat.Bubble),
				})
				BackgroundGradient.Parent = AnimatedBackground

				local GlowA = Instance.new("Frame")

				GlowA.Name = "GlowA"
				GlowA.Size = UDim2.fromOffset(230, 230)
				GlowA.Position = UDim2.new(-8E-2, 0, -0.16, 0)
				GlowA.BackgroundColor3 = GetTheme().Accent
				GlowA.BackgroundTransparency = 0.82
				GlowA.BorderSizePixel = 0
				GlowA.ZIndex = 0
				GlowA.Parent = AnimatedBackground

				local GlowACorner = Instance.new("UICorner")

				GlowACorner.CornerRadius = UDim.new(1, 0)
				GlowACorner.Parent = GlowA

				local GlowB = Instance.new("Frame")

				GlowB.Name = "GlowB"
				GlowB.Size = UDim2.fromOffset(320, 320)
				GlowB.Position = UDim2.new(0.65, 0, 0.58, 0)
				GlowB.BackgroundColor3 = GetTheme().Chat.Username
				GlowB.BackgroundTransparency = 0.86
				GlowB.BorderSizePixel = 0
				GlowB.ZIndex = 0
				GlowB.Parent = AnimatedBackground

				local GlowBCorner = Instance.new("UICorner")

				GlowBCorner.CornerRadius = UDim.new(1, 0)
				GlowBCorner.Parent = GlowB

				local MessagesContainer = Instance.new("Frame")

				MessagesContainer.Size = UDim2.new(1, 0, 1, -112)
				MessagesContainer.BackgroundColor3 =
					BlendColor(GetTheme().Chat.Background, GetTheme().Chat.Bubble, 0.52)
				MessagesContainer.BackgroundTransparency = 0.52
				MessagesContainer.BorderSizePixel = 0
				MessagesContainer.Parent = TabPage
				MessagesContainer.Name = "Container"
				MessagesContainer.ZIndex = 2

				local MessagesContainerCorner = Instance.new("UICorner")

				MessagesContainerCorner.CornerRadius = UDim.new(0, 12)
				MessagesContainerCorner.Parent = MessagesContainer

				local MessagesContainerStroke = Instance.new("UIStroke")

				MessagesContainerStroke.Name = "ContainerStroke"
				MessagesContainerStroke.Color = BlendColor(GetTheme().Chat.ScrollBar, GetTheme().Accent, 0.48)
				MessagesContainerStroke.Transparency = 0.5
				MessagesContainerStroke.Thickness = 1
				MessagesContainerStroke.Parent = MessagesContainer

				local Messages = Instance.new("ScrollingFrame")

				Messages.Name = "Messages"
				Messages.Size = UDim2.new(1, 0, 1, 0)
				Messages.BackgroundTransparency = 1
				Messages.ScrollBarThickness = 5
				Messages.AutomaticCanvasSize = Enum.AutomaticSize.Y
				Messages.CanvasSize = UDim2.new()
				Messages.ScrollingDirection = Enum.ScrollingDirection.Y
				Messages.BorderSizePixel = 0
				Messages.ScrollBarImageColor3 = Color3.fromRGB(110, 110, 118)
				Messages.Parent = MessagesContainer
				Messages.ZIndex = 3

				local MessagesLayout = Instance.new("UIListLayout")

				MessagesLayout.Padding = UDim.new(0, 12)
				MessagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
				MessagesLayout.Parent = Messages

				local MessagesPadding = Instance.new("UIPadding")

				MessagesPadding.PaddingLeft = UDim.new(0, 12)
				MessagesPadding.PaddingRight = UDim.new(0, 14)
				MessagesPadding.PaddingTop = UDim.new(0, 14)
				MessagesPadding.PaddingBottom = UDim.new(0, 14)
				MessagesPadding.Parent = Messages

				local InputBar = Instance.new("Frame")

				InputBar.Name = "InputBar"
				InputBar.Size = UDim2.new(1, -20, 0, 56)
				InputBar.Position = UDim2.new(0, 10, 1, -64)
				InputBar.BackgroundColor3 = GetTheme().Chat.InputBar
				InputBar.BackgroundTransparency = 0.04
				InputBar.BorderSizePixel = 0
				InputBar.ClipsDescendants = false
				InputBar.Parent = TabPage
				InputBar.ZIndex = 4

				local InputBarCorner = Instance.new("UICorner")

				InputBarCorner.CornerRadius = UDim.new(0, 16)
				InputBarCorner.Parent = InputBar

				local InputBarGradient = Instance.new("UIGradient")

				InputBarGradient.Name = "InputBarGradient"
				InputBarGradient.Rotation = 92
				InputBarGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
				})
				InputBarGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.94),
					NumberSequenceKeypoint.new(1, 0.97),
				})
				InputBarGradient.Parent = InputBar

				local InputStroke = Instance.new("UIStroke")

				InputStroke.Name = "InputStroke"
				InputStroke.Color = BlendColor(GetTheme().Accent, GetTheme().Chat.InputBar, 0.55)
				InputStroke.Thickness = 1.5
				InputStroke.Transparency = 0.28
				InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				InputStroke.Parent = InputBar

				local StatusRow = Instance.new("Frame")

				StatusRow.Name = "StatusRow"
				StatusRow.Size = UDim2.new(1, -16, 0, 18)
				StatusRow.Position = UDim2.fromOffset(8, 6)
				StatusRow.BackgroundTransparency = 1
				StatusRow.BorderSizePixel = 0
				StatusRow.Visible = false
				StatusRow.ZIndex = 6
				StatusRow.Parent = InputBar

				local StatusPill = Instance.new("Frame")

				StatusPill.Name = "StatusPill"
				StatusPill.Size = UDim2.fromScale(1, 1)
				StatusPill.BackgroundColor3 = BlendColor(GetTheme().Chat.InputBox, GetTheme().Accent, 0.12)
				StatusPill.BackgroundTransparency = 0.08
				StatusPill.BorderSizePixel = 0
				StatusPill.ZIndex = 6
				StatusPill.Parent = StatusRow

				local StatusPillCorner = Instance.new("UICorner")

				StatusPillCorner.CornerRadius = UDim.new(1, 0)
				StatusPillCorner.Parent = StatusPill

				local StatusStroke = Instance.new("UIStroke")

				StatusStroke.Name = "StatusStroke"
				StatusStroke.Color = BlendColor(GetTheme().Accent, GetTheme().Chat.InputBar, 0.38)
				StatusStroke.Transparency = 0.26
				StatusStroke.Thickness = 1
				StatusStroke.Parent = StatusPill

				local StatusDot = Instance.new("Frame")

				StatusDot.Name = "StatusDot"
				StatusDot.AnchorPoint = Vector2.new(0.5, 0.5)
				StatusDot.Size = UDim2.fromOffset(6, 6)
				StatusDot.Position = UDim2.new(0, 13, 0.5, 0)
				StatusDot.BackgroundColor3 = Color3.fromRGB(255, 196, 74)
				StatusDot.BorderSizePixel = 0
				StatusDot.ZIndex = 7
				StatusDot.Parent = StatusPill

				local StatusGlow = Instance.new("Frame")

				StatusGlow.Name = "StatusGlow"
				StatusGlow.AnchorPoint = Vector2.new(0.5, 0.5)
				StatusGlow.Size = UDim2.fromOffset(16, 16)
				StatusGlow.Position = UDim2.new(0, 13, 0.5, 0)
				StatusGlow.BackgroundColor3 = StatusDot.BackgroundColor3
				StatusGlow.BackgroundTransparency = 0.72
				StatusGlow.BorderSizePixel = 0
				StatusGlow.ZIndex = 6
				StatusGlow.Parent = StatusPill

				local StatusGlowCorner = Instance.new("UICorner")

				StatusGlowCorner.CornerRadius = UDim.new(1, 0)
				StatusGlowCorner.Parent = StatusGlow

				local StatusDotCorner = Instance.new("UICorner")

				StatusDotCorner.CornerRadius = UDim.new(1, 0)
				StatusDotCorner.Parent = StatusDot

				local StatusIcon = Instance.new("ImageLabel")

				StatusIcon.Name = "StatusIcon"
				StatusIcon.Size = UDim2.fromOffset(12, 12)
				StatusIcon.Position = UDim2.fromOffset(22, 3)
				StatusIcon.BackgroundTransparency = 1
				StatusIcon.ImageColor3 = StatusDot.BackgroundColor3
				StatusIcon.ScaleType = Enum.ScaleType.Fit
				StatusIcon.ZIndex = 7
				StatusIcon.Parent = StatusPill

				local StatusLabel = Instance.new("TextLabel")

				StatusLabel.Name = "StatusLabel"
				StatusLabel.Size = UDim2.new(1, -42, 1, 0)
				StatusLabel.Position = UDim2.fromOffset(40, 0)
				StatusLabel.BackgroundTransparency = 1
				StatusLabel.Text = ""
				StatusLabel.TextColor3 = Color3.fromRGB(255, 196, 74)
				StatusLabel.Font = Enum.Font.GothamMedium
				StatusLabel.TextSize = 11
				StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
				StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
				StatusLabel.Parent = StatusPill
				StatusLabel.ZIndex = 7

				StatusLabel:GetPropertyChangedSignal("Visible"):Connect(function()
					StatusRow.Visible = StatusLabel.Visible
				end)
				StatusLabel:GetPropertyChangedSignal("Text"):Connect(function()
					StatusDot.BackgroundColor3 = StatusLabel.TextColor3
				end)

				local ReplyBar = Instance.new("Frame")

				ReplyBar.Name = "ReplyBar"
				ReplyBar.Size = UDim2.new(1, -16, 0, 26)
				ReplyBar.Position = UDim2.fromOffset(8, 30)
				ReplyBar.BackgroundColor3 = GetTheme().Chat.ReplyBar
				ReplyBar.BackgroundTransparency = 0.1
				ReplyBar.BorderSizePixel = 0
				ReplyBar.Visible = false
				ReplyBar.ZIndex = 6
				ReplyBar.Parent = InputBar

				local ReplyBarCorner = Instance.new("UICorner")

				ReplyBarCorner.CornerRadius = UDim.new(0, 8)
				ReplyBarCorner.Parent = ReplyBar

				local ReplyAccentStripe = Instance.new("Frame")

				ReplyAccentStripe.Name = "ReplyAccentStripe"
				ReplyAccentStripe.Size = UDim2.new(0, 3, 1, -8)
				ReplyAccentStripe.Position = UDim2.fromOffset(0, 4)
				ReplyAccentStripe.BackgroundColor3 = GetTheme().Accent
				ReplyAccentStripe.BackgroundTransparency = 0.1
				ReplyAccentStripe.BorderSizePixel = 0
				ReplyAccentStripe.ZIndex = 7
				ReplyAccentStripe.Parent = ReplyBar

				local ReplyAccentCorner = Instance.new("UICorner")

				ReplyAccentCorner.CornerRadius = UDim.new(1, 0)
				ReplyAccentCorner.Parent = ReplyAccentStripe

				local ReplyIcon = Instance.new("ImageLabel")

				ReplyIcon.Name = "ReplyIcon"
				ReplyIcon.Size = UDim2.fromOffset(12, 12)
				ReplyIcon.Position = UDim2.new(0, 10, 0.5, -6)
				ReplyIcon.BackgroundTransparency = 1
				ReplyIcon.ImageColor3 = GetTheme().Accent
				ReplyIcon.ScaleType = Enum.ScaleType.Fit
				ReplyIcon.ZIndex = 7
				ReplyIcon.Parent = ReplyBar

				do
					local ok, iconData = pcall(Lucide.GetAsset, "reply")

					if ok and iconData then
						ReplyIcon.Image = iconData.Url
						ReplyIcon.ImageRectSize = iconData.ImageRectSize
						ReplyIcon.ImageRectOffset = iconData.ImageRectOffset
					else
						ReplyIcon.Image = ""
					end
				end

				local ReplyPreview = Instance.new("TextLabel")

				ReplyPreview.Name = "ReplyPreview"
				ReplyPreview.Size = UDim2.new(1, -56, 1, 0)
				ReplyPreview.Position = UDim2.fromOffset(26, 0)
				ReplyPreview.BackgroundTransparency = 1
				ReplyPreview.Text = ""
				ReplyPreview.TextColor3 = GetTheme().SubText
				ReplyPreview.Font = Enum.Font.GothamMedium
				ReplyPreview.TextSize = 11
				ReplyPreview.TextXAlignment = Enum.TextXAlignment.Left
				ReplyPreview.TextTruncate = Enum.TextTruncate.AtEnd
				ReplyPreview.Parent = ReplyBar
				ReplyPreview.ZIndex = 7

				local ReplyStroke = Instance.new("UIStroke")

				ReplyStroke.Name = "ReplyStroke"
				ReplyStroke.Color = BlendColor(GetTheme().Chat.ScrollBar, GetTheme().Accent, 0.32)
				ReplyStroke.Transparency = 0.55
				ReplyStroke.Thickness = 1
				ReplyStroke.Parent = ReplyBar

				local ReplyClear = Instance.new("TextButton")

				ReplyClear.Name = "ReplyClear"
				ReplyClear.Size = UDim2.fromOffset(22, 22)
				ReplyClear.Position = UDim2.new(1, -24, 0.5, -11)
				ReplyClear.BackgroundColor3 = GetTheme().Primary
				ReplyClear.BackgroundTransparency = 0.5
				ReplyClear.Text = ""
				ReplyClear.BorderSizePixel = 0
				ReplyClear.AutoButtonColor = false
				ReplyClear.ZIndex = 8
				ReplyClear.Parent = ReplyBar

				local ReplyClearCorner = Instance.new("UICorner")

				ReplyClearCorner.CornerRadius = UDim.new(1, 0)
				ReplyClearCorner.Parent = ReplyClear

				local ReplyClearIcon = Instance.new("ImageLabel")

				ReplyClearIcon.Name = "Icon"
				ReplyClearIcon.Size = UDim2.fromOffset(10, 10)
				ReplyClearIcon.AnchorPoint = Vector2.new(0.5, 0.5)
				ReplyClearIcon.Position = UDim2.fromScale(0.5, 0.5)
				ReplyClearIcon.BackgroundTransparency = 1
				ReplyClearIcon.ImageColor3 = GetTheme().SubText
				ReplyClearIcon.ScaleType = Enum.ScaleType.Fit
				ReplyClearIcon.ZIndex = 9
				ReplyClearIcon.Parent = ReplyClear

				do
					local ok, iconData = pcall(Lucide.GetAsset, "x")

					if ok and iconData then
						ReplyClearIcon.Image = iconData.Url
						ReplyClearIcon.ImageRectSize = iconData.ImageRectSize
						ReplyClearIcon.ImageRectOffset = iconData.ImageRectOffset
					else
						ReplyClearIcon.Image = ""
					end
				end

				local InputRow = Instance.new("Frame")

				InputRow.Name = "InputRow"
				InputRow.Size = UDim2.new(1, -16, 0, 38)
				InputRow.Position = UDim2.fromOffset(8, 10)
				InputRow.BackgroundTransparency = 1
				InputRow.BorderSizePixel = 0
				InputRow.ZIndex = 5
				InputRow.Parent = InputBar

				local InputBox = Instance.new("TextBox")

				InputBox.Name = "InputBox"
				InputBox.Size = UDim2.new(1, -46, 1, 0)
				InputBox.Position = UDim2.fromOffset(0, 0)
				InputBox.BackgroundColor3 = GetTheme().Chat.InputBox
				InputBox.BackgroundTransparency = 0.06
				InputBox.BorderSizePixel = 0
				InputBox.PlaceholderText = "Message..."
				InputBox.Text = ""
				InputBox.TextColor3 = GetTheme().Chat.Text
				InputBox.PlaceholderColor3 = BlendColor(GetTheme().SubText, GetTheme().Chat.Text, 0.3)
				InputBox.Font = Enum.Font.Gotham
				InputBox.TextSize = 14
				InputBox.TextXAlignment = Enum.TextXAlignment.Left
				InputBox.ClearTextOnFocus = false
				InputBox.MultiLine = false
				InputBox.ZIndex = 6
				InputBox.Parent = InputRow

				local InputBoxCorner = Instance.new("UICorner")

				InputBoxCorner.CornerRadius = UDim.new(0, 12)
				InputBoxCorner.Parent = InputBox

				local InputBoxStroke = Instance.new("UIStroke")

				InputBoxStroke.Name = "InputBoxStroke"
				InputBoxStroke.Color = BlendColor(GetTheme().Chat.ScrollBar, GetTheme().Accent, 0.25)
				InputBoxStroke.Transparency = 0.62
				InputBoxStroke.Thickness = 1.5
				InputBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				InputBoxStroke.Parent = InputBox

				local InputBoxPadding = Instance.new("UIPadding")

				InputBoxPadding.PaddingLeft = UDim.new(0, 14)
				InputBoxPadding.PaddingRight = UDim.new(0, 8)
				InputBoxPadding.Parent = InputBox

				local CharCounter = Instance.new("TextLabel")

				CharCounter.Name = "CharCounter"
				CharCounter.Size = UDim2.fromOffset(40, 14)
				CharCounter.AnchorPoint = Vector2.new(1, 0.5)
				CharCounter.Position = UDim2.new(1, -6, 0.5, 0)
				CharCounter.BackgroundTransparency = 1
				CharCounter.Text = ""
				CharCounter.TextColor3 = GetTheme().SubText
				CharCounter.Font = Enum.Font.GothamMedium
				CharCounter.TextSize = 10
				CharCounter.TextXAlignment = Enum.TextXAlignment.Right
				CharCounter.ZIndex = 7
				CharCounter.Visible = false
				CharCounter.Parent = InputBox

				local SendButton = Instance.new("TextButton")

				SendButton.Name = "SendButton"
				SendButton.Size = UDim2.fromOffset(38, 38)
				SendButton.AnchorPoint = Vector2.new(1, 0.5)
				SendButton.Position = UDim2.new(1, 0, 0.5, 0)
				SendButton.BackgroundColor3 = GetTheme().Accent
				SendButton.BorderSizePixel = 0
				SendButton.Text = ""
				SendButton.AutoButtonColor = false
				SendButton.ZIndex = 6
				SendButton.Parent = InputRow

				local SendCorner = Instance.new("UICorner")

				SendCorner.CornerRadius = UDim.new(0, 12)
				SendCorner.Parent = SendButton

				local SendIcon = Instance.new("ImageLabel")

				SendIcon.Name = "SendIcon"
				SendIcon.Size = UDim2.fromOffset(18, 18)
				SendIcon.AnchorPoint = Vector2.new(0.5, 0.5)
				SendIcon.Position = UDim2.fromScale(0.5, 0.5)
				SendIcon.BackgroundTransparency = 1
				SendIcon.ImageColor3 = GetSendButtonTextColor(GetTheme(), GetTheme().Accent)
				SendIcon.ScaleType = Enum.ScaleType.Fit
				SendIcon.ZIndex = 7
				SendIcon.Parent = SendButton

				do
					local ok, iconData = pcall(Lucide.GetAsset, "send-horizontal")

					if not ok then
						ok, iconData = pcall(Lucide.GetAsset, "send")
					end
					if ok and iconData then
						SendIcon.Image = iconData.Url
						SendIcon.ImageRectSize = iconData.ImageRectSize
						SendIcon.ImageRectOffset = iconData.ImageRectOffset
					else
						local fallback = Instance.new("TextLabel")

						fallback.Size = UDim2.fromScale(1, 1)
						fallback.BackgroundTransparency = 1
						fallback.Text = ">"
						fallback.TextColor3 = GetSendButtonTextColor(GetTheme(), GetTheme().Accent)
						fallback.Font = Enum.Font.GothamBold
						fallback.TextSize = 15
						fallback.AnchorPoint = Vector2.new(0.5, 0.5)
						fallback.Position = UDim2.fromScale(0.5, 0.5)
						fallback.Parent = SendButton
					end
				end

				local SendGlow = Instance.new("Frame")

				SendGlow.Name = "SendGlow"
				SendGlow.Size = UDim2.new(1, 6, 1, 6)
				SendGlow.Position = UDim2.new(0, -3, 0, -3)
				SendGlow.BackgroundColor3 = GetTheme().Accent
				SendGlow.BackgroundTransparency = 1
				SendGlow.BorderSizePixel = 0
				SendGlow.ZIndex = 5
				SendGlow.Parent = SendButton

				local SendGlowCorner = Instance.new("UICorner")

				SendGlowCorner.CornerRadius = UDim.new(0, 15)
				SendGlowCorner.Parent = SendGlow

				local SendScale = Instance.new("UIScale")

				SendScale.Name = "ButtonScale"
				SendScale.Scale = 1
				SendScale.Parent = SendButton
				UpdateInputPanelLayout = function()
					local GAP = 6
					local SIDE_PAD = 8
					local TOP_PAD = 8
					local BOT_PAD = 8
					local ROW_H = 38
					local STATUS_H = 18
					local REPLY_H = 26
					local y = TOP_PAD

					if StatusLabel.Visible then
						StatusRow.Position = UDim2.fromOffset(SIDE_PAD, y)
						StatusRow.Size = UDim2.new(1, -SIDE_PAD * 2, 0, STATUS_H)
						y = y + STATUS_H + GAP
					end
					if ReplyBar.Visible then
						ReplyBar.Position = UDim2.fromOffset(SIDE_PAD, y)
						ReplyBar.Size = UDim2.new(1, -SIDE_PAD * 2, 0, REPLY_H)
						y = y + REPLY_H + GAP
					end

					InputRow.Position = UDim2.fromOffset(SIDE_PAD, y)
					InputRow.Size = UDim2.new(1, -SIDE_PAD * 2, 0, ROW_H)
					y = y + ROW_H + BOT_PAD

					local finalH = math.max(54, y)

					InputBar.Size = UDim2.new(1, -20, 0, finalH)
					InputBar.Position = UDim2.new(0, 10, 1, -(finalH + 8))
					MessagesContainer.Size = UDim2.new(1, 0, 1, -(finalH + 18))
				end

				StatusLabel:GetPropertyChangedSignal("Visible"):Connect(UpdateInputPanelLayout)
				ReplyBar:GetPropertyChangedSignal("Visible"):Connect(UpdateInputPanelLayout)
				InputBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateInputPanelLayout)
				UpdateInputPanelLayout()
				InputBox:GetPropertyChangedSignal("Text"):Connect(function()
					local maxLen = math.max(24, math.floor(tonumber(DiscordChatData.MaxMessageLength) or 320))
					local len = #InputBox.Text
					local ratio = len / maxLen

					if ratio >= 0.8 then
						CharCounter.Visible = true

						local remaining = maxLen - len

						CharCounter.Text = tostring(remaining)

						if remaining <= 20 then
							CharCounter.TextColor3 = Color3.fromRGB(255, 90, 90)
						elseif remaining <= 60 then
							CharCounter.TextColor3 = Color3.fromRGB(255, 196, 74)
						else
							CharCounter.TextColor3 = GetTheme().SubText
						end
					else
						CharCounter.Visible = false
					end
				end)
				DiscordChatData.InputBoxStatus = {
					hover = false,
					focused = false,
				}
				local function ApplyInputBoxStatus()
					local theme = GetTheme()
					local inputStrokeColor = BlendColor(theme.Accent, theme.Chat.InputBar, 0.55)
					local inputStrokeTransparency = 0.28
					local boxStrokeColor = BlendColor(theme.Chat.ScrollBar, theme.Accent, 0.25)
					local boxStrokeTransparency = 0.62
					local boxBackgroundTransparency = 0.06

					if DiscordChatData.InputBoxStatus.hover then
						inputStrokeColor = BlendColor(theme.Accent, theme.Chat.InputBar, 0.74)
						inputStrokeTransparency = 0.18
						boxStrokeColor = BlendColor(theme.Accent, theme.Chat.InputBox, 0.42)
						boxStrokeTransparency = 0.34
						boxBackgroundTransparency = 0.03
					end

					if DiscordChatData.InputBoxStatus.focused then
						inputStrokeColor = theme.Accent
						inputStrokeTransparency = 0.12
						boxStrokeColor = theme.Accent
						boxStrokeTransparency = 0.08
						boxBackgroundTransparency = 0
					end

					spr.target(InputBoxStroke, 0.6, 6, {
						Color = boxStrokeColor,
						Transparency = boxStrokeTransparency,
					})
					spr.target(InputBox, 0.6, 6, {
						BackgroundTransparency = boxBackgroundTransparency,
					})
					spr.target(InputStroke, 0.6, 6, {
						Color = inputStrokeColor,
						Transparency = inputStrokeTransparency,
					})
				end

				InputBox.MouseEnter:Connect(function()
					DiscordChatData.InputBoxStatus.hover = true
					ApplyInputBoxStatus()
				end)
				InputBox.MouseLeave:Connect(function()
					DiscordChatData.InputBoxStatus.hover = false
					ApplyInputBoxStatus()
				end)
				InputBox.Focused:Connect(function()
					DiscordChatData.InputBoxStatus.focused = true
					ApplyInputBoxStatus()
				end)
				InputBox.FocusLost:Connect(function()
					DiscordChatData.InputBoxStatus.focused = false
					ApplyInputBoxStatus()
				end)

				local sendState = {
					hover = false,
					down = false,
				}

				local function applySendState()
					local theme = GetTheme()
					local targetColor

					if sendState.down then
						targetColor = theme.Button.Hover
					elseif sendState.hover then
						targetColor = BlendColor(theme.Accent, theme.Button.Hover, 0.35)
					else
						targetColor = theme.Accent
					end

					local scaleGoal = sendState.down and 0.88 or (sendState.hover and 1.06 or 1)
					local glowTrans = sendState.hover and 0.82 or 1

					spr.target(SendButton, 0.65, 7, { BackgroundColor3 = targetColor })
					spr.target(SendScale, 0.7, 7, { Scale = scaleGoal })
					spr.target(SendGlow, 0.65, 6, {
						BackgroundColor3 = theme.Accent,
						BackgroundTransparency = glowTrans,
					})

					SendIcon.ImageColor3 = GetSendButtonTextColor(theme, targetColor)
				end

				SendButton.MouseEnter:Connect(function()
					sendState.hover = true

					applySendState()
				end)
				SendButton.MouseLeave:Connect(function()
					sendState.hover = false
					sendState.down = false

					applySendState()
				end)
				SendButton.InputBegan:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						sendState.down = true

						applySendState()
					end
				end)
				SendButton.InputEnded:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						sendState.down = false

						applySendState()
					end
				end)
				TweenService:Create(
					BackgroundGradient,
					TweenInfo.new(11, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						Offset = Vector2.new(0.95, 0),
					}
				):Play()
				TweenService
					:Create(GlowA, TweenInfo.new(9.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
						Position = UDim2.new(0.08, 0, -5E-2, 0),
					})
					:Play()
				TweenService
					:Create(GlowB, TweenInfo.new(12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
						Position = UDim2.new(0.52, 0, 0.48, 0),
					})
					:Play()

				return TabPage
			end)()

			local Tab = (function()
				local Tab = Instance.new("Frame")
				local ClickDetector = Instance.new("TextButton")
				local TextLabel = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")
				local ImageLabel = Instance.new("ImageLabel")

				Tab.Name = DiscordChatData.Name
				Tab.Parent = Main.Tabs
				Tab.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				Tab.BackgroundTransparency = 1
				Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Tab.BorderSizePixel = 0
				Tab.Size = UDim2.new(1, 0, 0, 170 * CalculateUIScale())
				ClickDetector.FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				)
				ClickDetector.TextColor3 = Color3.fromRGB(0, 0, 0)
				ClickDetector.TextSize = 14
				ClickDetector.TextTransparency = 1
				ClickDetector.Name = "ClickDetector"
				ClickDetector.Parent = Tab
				ClickDetector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ClickDetector.BackgroundTransparency = 1
				ClickDetector.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ClickDetector.BorderSizePixel = 0
				ClickDetector.Position = UDim2.new(2.7006706200000004e-7, 0, 0, 0)
				ClickDetector.Size = UDim2.new(0.949579835, 0, 0.995215297, 0)
				TextLabel.FontFace =
					Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				TextLabel.Text = DiscordChatData.Name
				TextLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
				TextLabel.TextScaled = true
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.Parent = Tab
				TextLabel.AnchorPoint = Vector2.new(0, 0.5)
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				TextLabel.BackgroundTransparency = 1
				TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel.BorderSizePixel = 0
				TextLabel.Position = UDim2.new(0.296868831, 0, 0.5, 0)
				TextLabel.Size = UDim2.new(0.663865566, 0, 0.550000012, 0)
				UICorner.CornerRadius = UDim.new(0, 12)
				UICorner.Parent = Tab
				ImageLabel.Parent = Tab
				ImageLabel.ScaleType = Enum.ScaleType.Fit
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = 1
				ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ImageLabel.BorderSizePixel = 0
				ImageLabel.Position = UDim2.new(0.0840336159, 0, 0.132059053, 0)
				ImageLabel.Size = UDim2.new(0.15126051, 0, 0.688995242, 0)

				ApplyImageAsset(ImageLabel, DiscordChatData.Icon, ChatTabFallbackIcon)

				return Tab
			end)()

			UpdateTabsFunction()
			ApplyChatTheme(Page, GetTheme())

			local HoldMenu = Instance.new("Frame")

			HoldMenu.Name = "MessageHoldMenu"
			HoldMenu.Size = UDim2.fromOffset(90, 32)
			HoldMenu.BackgroundColor3 = Color3.fromRGB(26, 26, 29)
			HoldMenu.BorderSizePixel = 0
			HoldMenu.Visible = false
			HoldMenu.ZIndex = 50
			HoldMenu.Parent = Page

			local HoldMenuCorner = Instance.new("UICorner")

			HoldMenuCorner.CornerRadius = UDim.new(0, 10)
			HoldMenuCorner.Parent = HoldMenu

			local HoldMenuStroke = Instance.new("UIStroke")

			HoldMenuStroke.Color = Color3.fromRGB(55, 55, 60)
			HoldMenuStroke.Thickness = 1
			HoldMenuStroke.Transparency = 0.12
			HoldMenuStroke.Parent = HoldMenu

			local HoldMenuReply = Instance.new("TextButton")

			HoldMenuReply.Name = "ReplyButton"
			HoldMenuReply.Size = UDim2.new(1, 0, 1, 0)
			HoldMenuReply.BackgroundTransparency = 1
			HoldMenuReply.Text = "Reply"
			HoldMenuReply.TextColor3 = Color3.fromRGB(235, 235, 235)
			HoldMenuReply.Font = Enum.Font.GothamMedium
			HoldMenuReply.TextSize = 14
			HoldMenuReply.ZIndex = 51
			HoldMenuReply.Parent = HoldMenu

			local function HideHoldMenu()
				HoldMenu.Visible = false
				DiscordChatData.ActionReplyPayload = nil
			end
			local function ShowHoldMenu(messageBubble, payload)
				if not messageBubble or not messageBubble.Parent then
					return
				end

				DiscordChatData.ActionReplyPayload = payload

				local absolute = messageBubble.AbsolutePosition
				local pageAbsolute = Page.AbsolutePosition
				local x = math.clamp(
					absolute.X - pageAbsolute.X + messageBubble.AbsoluteSize.X - 90,
					8,
					Page.AbsoluteSize.X - 92
				)
				local y = math.clamp(absolute.Y - pageAbsolute.Y + 4, 8, Page.AbsoluteSize.Y - 36)

				HoldMenu.Position = UDim2.fromOffset(x, y)
				HoldMenu.Visible = true
			end
			local function BindHoldGesture(target, payload, highlightTarget)
				if not target then
					return
				end

				highlightTarget = highlightTarget or target

				local function ResolvePayload()
					if typeof(payload) == "function" then
						local ok, resolved = pcall(payload)

						if ok then
							return resolved
						end

						return nil
					end

					return payload
				end

				local holdToken = 0

				local function CancelHold()
					holdToken += 1
				end
				local function StartHold()
					holdToken += 1

					local currentToken = holdToken

					task.delay(DiscordChatData.HoldDuration, function()
						if holdToken ~= currentToken then
							return
						end

						local holdPayload = ResolvePayload()

						if not holdPayload then
							return
						end

						ShowHoldMenu(target, holdPayload)

						if highlightTarget and highlightTarget.Parent then
							spr.target(highlightTarget, 0.5, 6, { BackgroundTransparency = 0.08 })
							task.delay(0.18, function()
								if highlightTarget and highlightTarget.Parent then
									spr.target(highlightTarget, 0.5, 6, { BackgroundTransparency = 0 })
								end
							end)
						end
					end)
				end

				target.InputBegan:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						StartHold()
					end
				end)
				target.InputEnded:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						CancelHold()
					end
				end)
				target.MouseLeave:Connect(CancelHold)
			end

			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed or not HoldMenu.Visible then
					return
				end
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					local inputPos = input.Position
					local menuPos = HoldMenu.AbsolutePosition
					local menuSize = HoldMenu.AbsoluteSize
					local inside = inputPos.X >= menuPos.X
						and inputPos.X <= menuPos.X + menuSize.X
						and inputPos.Y >= menuPos.Y
						and inputPos.Y <= menuPos.Y + menuSize.Y

					if not inside then
						HideHoldMenu()
					end
				end
			end)

			local function RestoreInputStroke()
				local theme = GetTheme()

				spr.target(Page.InputBar.InputStroke, 0.6, 6, {
					Color = BlendColor(theme.Chat.ScrollBar, theme.Accent, 0.45),
					Transparency = 0.22,
				})
			end
			local function SanitizeDiscordMentions(text)
				local sanitized = tostring(text or "")

				sanitized = sanitized:gsub("@everyone", "@ everyone")
				sanitized = sanitized:gsub("@here", "@ here")
				sanitized = sanitized:gsub("<@!?%d+>", "@ user")
				sanitized = sanitized:gsub("<@&%d+>", "@ role")
				sanitized = sanitized:gsub("<#%d+>", "# channel")

				return sanitized
			end
			local function FormatMessageTime(isoTimestamp)
				if typeof(isoTimestamp) ~= "string" or isoTimestamp == "" then
					return os.date("%H:%M")
				end

				local ok, dt = pcall(DateTime.fromIsoDate, isoTimestamp)

				if ok and dt then
					return os.date("%H:%M", dt.UnixTimestamp)
				end

				return os.date("%H:%M")
			end
			local function IsChatTabVisible()
				local window = Main and Main.Parent
				local uiVisible = window and window.Visible == true
				local chatSelected = currentPage == Page
					and Page.Visible == true
					and math.abs(Page.Position.Y.Scale) < 0.02

				return uiVisible and chatSelected
			end
			local function IsReplyToLocalPlayer(raw)
				if typeof(raw) ~= "table" then
					return false
				end

				local ref = raw.referenced_message

				if ref and ref.author and typeof(ref.author.username) == "string" then
					local refName = string.lower(ref.author.username)
					local lpName = string.lower(tostring(lp and lp.Name or ""))
					local lpDisplay = string.lower(tostring(lp and lp.DisplayName or ""))

					if refName == lpName or refName == lpDisplay then
						return true
					end
				end

				local lowerContent = string.lower(tostring(raw.content or ""))

				if lowerContent:find("@" .. string.lower(tostring(lp and lp.Name or "")), 1, true) then
					return true
				end

				return false
			end
			local function ShortenText(text, maxLength)
				local value = TrimText(text):gsub("\n", " ")

				if value == "" then
					return "[No text]"
				end

				maxLength = maxLength or 80

				if #value > maxLength then
					return value:sub(1, maxLength) .. "..."
				end

				return value
			end

			local REPLY_EMBED_MARKER_URL = "https://vanish.reply/"

			local function BuildOutgoingReplyEmbed(replyPayload)
				if type(replyPayload) ~= "table" then
					return nil
				end

				local authorName = ShortenText(replyPayload.AuthorName or "Unknown", 56)
				local previewText = ShortenText(
					replyPayload.IsRemoved and "Removed Message" or tostring(replyPayload.Content or ""),
					180
				)
				local messageId = TrimText(tostring(replyPayload.MessageId or ""))

				if messageId == "" then
					messageId = "local"
				end

				return {
					color = 6316128,
					author = {
						name = "Reply to " .. authorName,
						url = REPLY_EMBED_MARKER_URL .. messageId,
					},
					description = previewText,
					footer = {
						text = replyPayload.IsRemoved and "Removed Message" or "Reply Preview",
					},
				}
			end
			local function ExtractReplyMetaFromEmbeds(embeds)
				if typeof(embeds) ~= "table" then
					return nil
				end

				for _, embed in ipairs(embeds) do
					if type(embed) == "table" then
						local author = embed.author
						local markerUrl = TrimText(tostring(author and author.url or ""))

						if markerUrl:sub(1, #REPLY_EMBED_MARKER_URL) == REPLY_EMBED_MARKER_URL then
							local authorName = TrimText(tostring(author and author.name or ""))

							authorName = authorName:gsub("^Reply to%s+", "")

							if authorName == "" then
								authorName = "Unknown"
							end

							local footerText =
								string.lower(TrimText(tostring(embed.footer and embed.footer.text or "")))
							local isRemoved = footerText == "removed message"
							local content = ShortenText(embed.description or "", 180)

							return {
								AuthorName = authorName,
								Content = content,
								IsRemoved = isRemoved,
							}
						end
					end
				end

				return nil
			end
			local function BuildWebhookExecuteUrl(baseUrl)
				local url = TrimText(tostring(baseUrl or ""))

				if url == "" or url:find("[?&]wait=", 1) then
					return url
				end
				if url:find("?", 1, true) then
					return url .. "&wait=true"
				end

				return url .. "?wait=true"
			end
			local function FormatDuration(seconds)
				local value = math.max(0, math.floor(tonumber(seconds) or 0))
				local hours = math.floor(value / 3600)
				local minutes = math.floor((value % 3600) / 60)
				local secs = value % 60

				if hours > 0 then
					return string.format("%dh %dm", hours, minutes)
				end
				if minutes > 0 then
					return string.format("%dm %ds", minutes, secs)
				end

				return string.format("%ds", secs)
			end

			local statusToken = 0
			local statusPulseTween = nil
			local statusGlowTween = nil
			local statusIconTween = nil
			local statusIconCache = {}

			local function stopStatusTween(tween)
				if tween then
					pcall(function()
						tween:Cancel()
					end)
				end

				return nil
			end
			local function resolveStatusKind(message, color)
				local text = string.lower(TrimText(message))

				if
					text:find("loading", 1, true)
					or text:find("connecting", 1, true)
					or text:find("please wait", 1, true)
				then
					return "loading"
				end
				if
					text:find("connected", 1, true)
					or text:find("message sent", 1, true)
					or text:find("sent.", 1, true)
				then
					return "success"
				end
				if
					text:find("warning", 1, true)
					or text:find("duplicate", 1, true)
					or text:find("cooldown", 1, true)
					or text:find("blocked", 1, true)
				then
					return "warning"
				end
				if
					text:find("failed", 1, true)
					or text:find("muted", 1, true)
					or text:find("error", 1, true)
					or text:find("removed from chat", 1, true)
				then
					return "error"
				end
				if typeof(color) == "Color3" then
					if color.G > color.R and color.G > color.B then
						return "success"
					elseif color.R > 0.8 and color.G > 0.6 then
						return "warning"
					elseif color.R > color.G and color.R > color.B then
						return "error"
					end
				end

				return "info"
			end
			local function resolveStatusIcon(kind)
				local lookup = {
					loading = {
						"loader-circle",
						"loader-2",
						"loader",
						"refresh-cw",
					},
					success = {
						"check",
						"check-check",
					},
					warning = {
						"triangle-alert",
						"alert-triangle",
						"shield-alert",
					},
					error = {
						"circle-alert",
						"alert-circle",
						"x",
					},
					info = {
						"info",
						"message-circle-more",
						"bell",
					},
				}

				for _, iconName in ipairs(lookup[kind] or lookup.info) do
					local cached = statusIconCache[iconName]

					if cached == nil then
						local ok, asset = pcall(Lucide.GetAsset, iconName)

						cached = ok and asset or false
						statusIconCache[iconName] = cached
					end
					if cached then
						return cached
					end
				end

				return nil
			end
			local function UpdateStatusVisuals(color, message)
				local statusLabel = Page.InputBar:FindFirstChild("StatusLabel", true)
				local statusRow = Page.InputBar:FindFirstChild("StatusRow")
				local statusPill = statusRow and statusRow:FindFirstChild("StatusPill")
				local statusStroke = statusPill and statusPill:FindFirstChild("StatusStroke")
				local statusDot = statusRow and statusRow:FindFirstChild("StatusDot", true)
				local statusGlow = statusRow and statusRow:FindFirstChild("StatusGlow", true)
				local statusIcon = statusRow and statusRow:FindFirstChild("StatusIcon", true)

				if not statusLabel or not statusDot then
					return
				end

				statusPulseTween = stopStatusTween(statusPulseTween)
				statusGlowTween = stopStatusTween(statusGlowTween)
				statusIconTween = stopStatusTween(statusIconTween)

				if statusLabel.Visible ~= true then
					statusDot.Size = UDim2.fromOffset(6, 6)
					statusDot.BackgroundTransparency = 0
					statusDot.Position = UDim2.new(0, 13, 0.5, 0)

					if statusGlow then
						statusGlow.Size = UDim2.fromOffset(16, 16)
						statusGlow.BackgroundTransparency = 0.72
					end
					if statusIcon and statusIcon:IsA("ImageLabel") then
						statusIcon.Image = ""
						statusIcon.Rotation = 0
					end

					return
				end

				local accent = typeof(color) == "Color3" and color or statusLabel.TextColor3
				local kind = resolveStatusKind(message or statusLabel.Text, color)
				local iconAsset = resolveStatusIcon(kind)

				statusDot.BackgroundColor3 = accent
				statusDot.Size = UDim2.fromOffset(6, 6)
				statusDot.BackgroundTransparency = 0

				if statusGlow then
					statusGlow.BackgroundColor3 = accent
					statusGlow.Size = UDim2.fromOffset(16, 16)
					statusGlow.BackgroundTransparency = 0.72
				end
				if statusIcon and statusIcon:IsA("ImageLabel") then
					statusIcon.ImageColor3 = accent
					statusIcon.Rotation = 0

					if iconAsset then
						statusIcon.Image = iconAsset.Url
						statusIcon.ImageRectSize = iconAsset.ImageRectSize
						statusIcon.ImageRectOffset = iconAsset.ImageRectOffset
					else
						statusIcon.Image = ""
						statusIcon.ImageRectSize = Vector2.zero
						statusIcon.ImageRectOffset = Vector2.zero
					end
				end
				if statusPill then
					spr.target(statusPill, 0.6, 5, {
						BackgroundColor3 = BlendColor(
							GetTheme().Chat.InputBox,
							accent,
							kind == "error" and 0.2 or 0.14
						),
					})
				end
				if statusStroke and statusStroke:IsA("UIStroke") then
					spr.target(statusStroke, 0.6, 5, {
						Color = BlendColor(accent, GetTheme().Chat.InputBar, 0.32),
						Transparency = kind == "loading" and 0.18 or 0.26,
					})
				end

				statusPulseTween = TweenService:Create(
					statusDot,
					TweenInfo.new(
						kind == "error" and 0.5 or (kind == "loading" and 0.7 or 0.9),
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut,
						-1,
						true
					),
					{
						Size = UDim2.fromOffset(kind == "loading" and 9 or 8, kind == "loading" and 9 or 8),
						BackgroundTransparency = kind == "error" and 0.12 or 0.22,
					}
				)

				statusPulseTween:Play()

				if statusGlow then
					statusGlowTween = TweenService:Create(
						statusGlow,
						TweenInfo.new(
							kind == "error" and 0.5 or (kind == "loading" and 0.7 or 0.9),
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.InOut,
							-1,
							true
						),
						{
							Size = UDim2.fromOffset(kind == "loading" and 20 or 18, kind == "loading" and 20 or 18),
							BackgroundTransparency = kind == "error" and 0.8 or 0.86,
						}
					)

					statusGlowTween:Play()
				end
				if kind == "loading" and statusIcon and statusIcon.Image ~= "" then
					statusIconTween = TweenService:Create(
						statusIcon,
						TweenInfo.new(1.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
						{ Rotation = 360 }
					)

					statusIconTween:Play()
				end
			end
			local function SetStatusMessage(message, color, duration)
				local statusLabel = Page.InputBar:FindFirstChild("StatusLabel", true)

				if not statusLabel then
					return
				end

				statusToken += 1

				local activeToken = statusToken
				local text = TrimText(message)

				if text == "" then
					statusLabel.Visible = false
					statusLabel.Text = ""

					UpdateStatusVisuals(color, text)
					UpdateInputPanelLayout()

					return
				end

				local statusKind = resolveStatusKind(text, color)

				statusLabel:SetAttribute("StatusKind", statusKind)

				statusLabel.Text = text
				statusLabel.Visible = true

				if typeof(color) == "Color3" then
					statusLabel.TextColor3 = color
				end

				UpdateStatusVisuals(color, text)

				if statusKind == "loading" then
					local baseText = TrimText(text:gsub("%.+$", ""))

					if baseText == "" then
						baseText = text
					end

					task.spawn(function()
						local suffixes = {
							".",
							"..",
							"...",
						}
						local index = 1

						while statusToken == activeToken and statusLabel.Visible do
							statusLabel.Text = baseText .. suffixes[index]
							index = index % #suffixes + 1

							task.wait(0.35)
						end
					end)
				end

				UpdateInputPanelLayout()

				if tonumber(duration) and tonumber(duration) > 0 then
					task.delay(tonumber(duration), function()
						if statusToken == activeToken then
							SetStatusMessage("", nil)
						end
					end)
				end
			end
			local function SyncModerationState(force)
				local nowClock = os.clock()

				if not force and nowClock - DiscordChatData.LastModerationSync < 20 then
					return
				end

				DiscordChatData.LastModerationSync = nowClock

				local ok, remoteData = pcall(function()
					return TABLE_MAIN.Others_Services.GetChatModerationData()
				end)

				if not ok or type(remoteData) ~= "table" then
					return
				end

				local incoming = remoteData[tostring(lp.UserId)]

				if type(incoming) ~= "table" then
					return
				end

				DiscordChatData.ModerationState.Strikes = tonumber(incoming.Strikes) or 0
				DiscordChatData.ModerationState.MutedUntil = tonumber(incoming.MutedUntil) or 0
				DiscordChatData.ModerationState.LastReason = tostring(incoming.LastReason or "")
				DiscordChatData.ModerationState.LastUpdated = tonumber(incoming.LastUpdated) or 0
			end
			local function SaveModerationState(reason)
				DiscordChatData.ModerationState.LastUpdated = os.time()
				DiscordChatData.ModerationState.LastReason =
					tostring(reason or DiscordChatData.ModerationState.LastReason or "")

				local payload = {
					Strikes = tonumber(DiscordChatData.ModerationState.Strikes) or 0,
					MutedUntil = tonumber(DiscordChatData.ModerationState.MutedUntil) or 0,
					LastReason = tostring(DiscordChatData.ModerationState.LastReason or ""),
					LastUpdated = tonumber(DiscordChatData.ModerationState.LastUpdated) or os.time(),
				}

				task.spawn(function()
					pcall(function()
						TABLE_MAIN.Others_Services.UpdateChatModerationUser("Add", lp.UserId, payload)
					end)
				end)
			end
			local function IsMutedNow()
				SyncModerationState(false)

				local state = DiscordChatData.ModerationState
				local now = os.time()
				local decaySeconds = math.max(60, tonumber(DiscordChatData.StrikeDecaySeconds) or 900)
				local strikeCount = math.max(0, tonumber(state.Strikes) or 0)
				local lastUpdate = tonumber(state.LastUpdated) or now

				if strikeCount > 0 and now - lastUpdate >= decaySeconds then
					local decaySteps = math.floor((now - lastUpdate) / decaySeconds)

					if decaySteps > 0 then
						state.Strikes = math.max(0, strikeCount - decaySteps)
						state.LastUpdated = now

						SaveModerationState("strike decay")
					end
				end

				local mutedUntil = tonumber(DiscordChatData.ModerationState.MutedUntil) or 0

				if mutedUntil > now then
					return true, mutedUntil - now
				end

				return false, 0
			end
			local function IsCapsSpamMessage(text)
				local letters = 0
				local upper = 0

				for char in tostring(text or ""):gmatch("%a") do
					letters += 1

					if char == string.upper(char) then
						upper += 1
					end
				end

				local minLetters = math.max(8, tonumber(DiscordChatData.CapsMinLetters) or 18)

				if letters < minLetters then
					return false, 0
				end

				local ratio = letters > 0 and (upper / letters) or 0

				return ratio >= math.clamp(tonumber(DiscordChatData.CapsWarnThreshold) or 0.82, 0.5, 0.98), ratio
			end
			local function HasExcessiveRepeatChars(text)
				local threshold = math.max(6, math.floor(tonumber(DiscordChatData.RepeatCharThreshold) or 11))
				local lower = tostring(text or ""):lower()
				local repeatCount = 0
				local lastChar = ""

				for i = 1, #lower do
					local ch = lower:sub(i, i)

					if ch == lastChar then
						repeatCount += 1
					else
						lastChar = ch
						repeatCount = 1
					end
					if repeatCount >= threshold and ch:match("[%w]") then
						return true, ch, repeatCount
					end
				end

				return false, "", 0
			end
			local function ContainsBlockedLink(text)
				if not DiscordChatData.LinkFilterEnabled then
					return false, nil
				end

				local lowered = tostring(text or ""):lower()
				local indicators = {
					"https://",
					"http://",
					"www.",
					"discord.gg/",
					"discord.com/invite/",
					"t.me/",
				}

				for _, marker in ipairs(indicators) do
					if lowered:find(marker, 1, true) then
						return true, marker
					end
				end

				return false, nil
			end
			local function ApplyMuteStrike(reason)
				local state = DiscordChatData.ModerationState

				state.Strikes = math.max(0, tonumber(state.Strikes) or 0) + 1

				local durations = DiscordChatData.MuteDurations
				local index = math.clamp(state.Strikes, 1, #durations)
				local muteFor = tonumber(durations[index]) or tonumber(durations[#durations]) or 300

				state.MutedUntil = os.time() + math.max(1, math.floor(muteFor))

				SaveModerationState(reason)

				local message = string.format("Muted for %s.", FormatDuration(muteFor))

				SetStatusMessage(message, Color3.fromRGB(255, 120, 120))
				_wrn("[Chat] " .. message .. " Reason: " .. (TrimText(reason) ~= "" and reason or "spam"), 7)
			end
			local function PruneTimedWindow(items, nowClock, windowSeconds)
				local cutoff = nowClock - math.max(0.1, tonumber(windowSeconds) or 1)
				local writeIndex = 1

				for readIndex = 1, #items do
					local value = tonumber(items[readIndex])

					if value and value >= cutoff then
						items[writeIndex] = value
						writeIndex += 1
					end
				end

				for index = #items, writeIndex, -1 do
					items[index] = nil
				end

				return #items
			end
			local function SetBlockedStatus(reason)
				SetStatusMessage("Blocked: " .. ShortenText(reason, 52), Color3.fromRGB(255, 196, 74), 3)
			end
			local function RegisterBypassAttempt(reason)
				local nowClock = os.clock()

				table.insert(DiscordChatData.BypassAttempts, nowClock)
				PruneTimedWindow(DiscordChatData.BypassAttempts, nowClock, DiscordChatData.BypassWindowSeconds)
				SetBlockedStatus(reason)

				if #DiscordChatData.BypassAttempts >= DiscordChatData.BypassStrikeThreshold then
					DiscordChatData.BypassAttempts = {}

					ApplyMuteStrike(reason)
				end
			end
			local function UpdateReplyPreviewBar()
				local replyBar = Page.InputBar:FindFirstChild("ReplyBar")
				local replyPreview = replyBar and replyBar:FindFirstChild("ReplyPreview")

				if not replyBar or not replyPreview then
					return
				end
				if DiscordChatData.ActiveReply then
					local preview = ShortenText(
						DiscordChatData.ActiveReply.IsRemoved and "Removed Message"
							or DiscordChatData.ActiveReply.Content,
						74
					)

					replyPreview.Text =
						string.format("Reply to %s: %s", DiscordChatData.ActiveReply.AuthorName, preview)
					replyBar.Visible = true
					Page.InputBar.InputRow.InputBox.PlaceholderText =
						string.format("Reply to %s...", DiscordChatData.ActiveReply.AuthorName)
				else
					replyPreview.Text = ""
					replyBar.Visible = false
					Page.InputBar.InputRow.InputBox.PlaceholderText = "Type a message..."
				end

				UpdateInputPanelLayout()
			end
			local function ClearReplyTarget()
				DiscordChatData.ActiveReply = nil

				UpdateReplyPreviewBar()
			end
			local function ParseIsoUnixTimestamp(isoTimestamp)
				if typeof(isoTimestamp) ~= "string" or isoTimestamp == "" then
					return os.time()
				end

				local ok, dt = pcall(DateTime.fromIsoDate, isoTimestamp)

				if ok and dt then
					return tonumber(dt.UnixTimestamp) or os.time()
				end

				return os.time()
			end
			local function BuildMessagePayload(usernameOrRaw, content, isHistory)
				local payload = {
					MessageId = "",
					AuthorId = "",
					WebhookId = "",
					AuthorName = "Unknown",
					Content = "",
					AvatarUrl = IsProbablyImagePath(DiscordChatData.Constants.DefaultAvatarUrl)
							and DiscordChatData.Constants.DefaultAvatarUrl
						or AvatarFallbackIcon,
					IsHistory = isHistory == true,
					ReplyMeta = nil,
					BaseTimeText = os.date("%H:%M"),
					TimeText = os.date("%H:%M"),
					EditedTimestamp = nil,
					IsEdited = false,
					IsReplyToLocal = false,
					UnixTimestamp = os.time(),
				}

				if typeof(usernameOrRaw) == "table" then
					local raw = usernameOrRaw

					payload.MessageId = tostring(raw.id or raw.messageId or "")
					payload.WebhookId = tostring(raw.webhook_id or raw.webhookId or "")

					local function normalizeAuthorName(value)
						local candidateText = TrimText(tostring(value or ""))

						if candidateText ~= "" then
							return candidateText
						end

						return nil
					end

					payload.AuthorName = normalizeAuthorName(raw.username)
						or normalizeAuthorName(raw.global_name)
						or normalizeAuthorName(raw.display_name)
						or normalizeAuthorName(raw.member and raw.member.nick)
						or normalizeAuthorName(raw.author and raw.author.global_name)
						or normalizeAuthorName(raw.author and raw.author.display_name)
						or normalizeAuthorName(raw.author and raw.author.username)
						or payload.AuthorName
					payload.Content = tostring(raw.content or "")
					payload.AvatarUrl = BuildAvatarUrl(raw)
					payload.AuthorId = ResolveAuthorIdentity(raw, payload.AuthorName, payload.AvatarUrl)
					payload.BaseTimeText = FormatMessageTime(raw.timestamp)
					payload.TimeText = payload.BaseTimeText
					payload.EditedTimestamp = tostring(raw.edited_timestamp or "")
					payload.IsEdited = payload.EditedTimestamp ~= ""

					if payload.IsEdited then
						payload.TimeText = payload.BaseTimeText .. " - edited"
					end

					payload.IsReplyToLocal = IsReplyToLocalPlayer(raw)
					payload.UnixTimestamp = ParseIsoUnixTimestamp(raw.timestamp)

					if payload.Content == "" and raw.attachments and #raw.attachments > 0 then
						local links = {}

						for _, attach in ipairs(raw.attachments) do
							if attach.url then
								table.insert(links, tostring(attach.url))
							end
						end

						payload.Content = table.concat(links, "\n")
					end
					if raw.referenced_message and raw.referenced_message.author then
						payload.ReplyMeta = {
							AuthorName = tostring(raw.referenced_message.author.username or "Unknown"),
							Content = tostring(raw.referenced_message.content or ""),
							IsRemoved = false,
						}
					elseif raw.message_reference and raw.message_reference.message_id then
						payload.ReplyMeta = {
							AuthorName = "Unknown",
							Content = "Removed Message",
							IsRemoved = true,
						}
					end
					if not payload.ReplyMeta then
						payload.ReplyMeta = ExtractReplyMetaFromEmbeds(raw.embeds)
					end
				else
					payload.AuthorName = tostring(usernameOrRaw or "Unknown")
					payload.Content = tostring(content or "")
					payload.AvatarUrl = BuildAvatarUrl({
						authorId = payload.AuthorName == lp.Name and tostring(lp.UserId) or "",
						username = payload.AuthorName,
						avatar_url = payload.AvatarUrl,
					})
					payload.AuthorId = ResolveAuthorIdentity(nil, payload.AuthorName, payload.AvatarUrl)
				end

				payload.Content = MaskBlacklistedWords(SanitizeDiscordMentions(payload.Content))

				return payload
			end
			local function GetPayloadDisplayContent(payload, inlineEditedSuffix)
				local displayText = TrimText(tostring(payload and payload.Content or ""))

				if displayText == "" then
					displayText = "[No text]"
				end
				if inlineEditedSuffix and payload and payload.IsEdited then
					displayText = displayText .. " (edited)"
				end

				return displayText
			end
			local function ReplaceReplyMetaLabel(existingLabel, parent, layoutOrder, replyMeta, theme)
				if existingLabel and existingLabel.Parent then
					existingLabel:Destroy()
				end
				if not replyMeta then
					return nil
				end

				return CreateReplyMetaLabel(parent, layoutOrder, replyMeta, theme)
			end
			local function CreateReplyMetaLabel(parent, layoutOrder, replyMeta, theme)
				if not parent or not replyMeta then
					return nil
				end

				local replyText = string.format(
					"Reply to %s: %s",
					tostring(replyMeta.AuthorName or "Unknown"),
					TrimText(replyMeta.Content) ~= "" and TrimText(replyMeta.Content) or "[No text]"
				)
				local label = Instance.new("TextLabel")

				label.Size = UDim2.new(1, 0, 0, 14)
				label.BackgroundTransparency = 1
				label.Text = replyText
				label.TextColor3 = theme.SubText
				label.Font = Enum.Font.Gotham
				label.TextSize = 11
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextTruncate = Enum.TextTruncate.AtEnd
				label.LayoutOrder = layoutOrder

				label:SetAttribute("IsChatReplyMeta", true)

				label.Parent = parent

				return label
			end
			local function GetAuthorGroupKey(payload)
				local authorId = tostring(payload.AuthorId or "")
				local webhookId = tostring(payload.WebhookId or "")
				local authorName = string.lower(TrimText(payload.AuthorName))

				if authorName == "" then
					authorName = "unknown"
				end
				if authorId ~= "" then
					return "id:" .. authorId
				end
				if webhookId ~= "" then
					return "webhook:" .. webhookId .. ":name:" .. authorName
				end

				return "name:" .. authorName
			end
			local function ShouldCombineWithLastGroup(payload)
				local combineWindow = tonumber(DiscordChatData.CombineWindowSeconds) or 0

				if combineWindow <= 0 then
					return nil
				end

				local lastRootId = tostring(DiscordChatData.LastBubbleRootId or "")

				if lastRootId == "" then
					return nil
				end

				local groupEntry = DiscordChatData.MessageGroups[lastRootId]

				if not groupEntry or not groupEntry.Bubble or not groupEntry.Bubble.Parent then
					DiscordChatData.MessageGroups[lastRootId] = nil

					if DiscordChatData.LastBubbleRootId == lastRootId then
						DiscordChatData.LastBubbleRootId = nil
					end

					return nil
				end

				local authorKey = GetAuthorGroupKey(payload)

				if authorKey == "" or groupEntry.AuthorKey ~= authorKey then
					return nil
				end
				if groupEntry.LastPayload and GetAuthorGroupKey(groupEntry.LastPayload) ~= authorKey then
					return nil
				end

				local currentTs = tonumber(payload.UnixTimestamp) or os.time()
				local lastTs = tonumber(groupEntry.LastTimestamp) or currentTs
				local delta = currentTs - lastTs

				if delta < 0 or delta > combineWindow then
					return nil
				end
				if groupEntry.LastPayload and groupEntry.LastPayload.IsHistory ~= payload.IsHistory then
					return nil
				end

				return groupEntry
			end
			local function UpdateGroupLastPayload(groupEntry, payload)
				if not groupEntry or not payload then
					return
				end

				groupEntry.LastPayload = payload
				groupEntry.LastTimestamp = tonumber(payload.UnixTimestamp) or os.time()
				groupEntry.LastMessageId = tostring(payload.MessageId or "")
			end
			local function ApplyPayloadAvatar(imageObject, payload)
				if not imageObject or not payload then
					return
				end

				local authorId = tostring(payload.AuthorId or "")
				local cachedAvatar = authorId ~= "" and DiscordChatData.AuthorIdentityCache.AvatarById[authorId] or nil
				local avatarUrl = IsProbablyImagePath(cachedAvatar) and cachedAvatar or payload.AvatarUrl

				if authorId ~= "" and IsProbablyImagePath(payload.AvatarUrl) then
					DiscordChatData.AuthorIdentityCache.AvatarById[authorId] = payload.AvatarUrl
				end

				SetImageWithFallback(imageObject, avatarUrl, AvatarFallbackIcon)
			end
			local function CreateMessageAvatar(parent, payload, theme)
				local avatarFrame = Instance.new("Frame")

				avatarFrame.Name = "AvatarFrame"
				avatarFrame.BackgroundColor3 = theme.Secondary
				avatarFrame.BorderSizePixel = 0
				avatarFrame.Position = UDim2.fromOffset(0, 0)
				avatarFrame.Size = UDim2.fromOffset(36, 36)
				avatarFrame.Parent = parent

				avatarFrame:SetAttribute("IsChatAvatarFrame", true)

				local avatarCorner = Instance.new("UICorner")

				avatarCorner.CornerRadius = UDim.new(1, 0)
				avatarCorner.Parent = avatarFrame

				local avatarStroke = Instance.new("UIStroke")

				avatarStroke.Color = theme.Chat.AvatarStroke
				avatarStroke.Thickness = 1
				avatarStroke.Transparency = 0.35
				avatarStroke.Parent = avatarFrame

				avatarStroke:SetAttribute("IsChatAvatarStroke", true)

				local avatarImage = Instance.new("ImageLabel")

				avatarImage.Name = "AvatarImage"
				avatarImage.BackgroundTransparency = 1
				avatarImage.Size = UDim2.fromScale(1, 1)
				avatarImage.ScaleType = Enum.ScaleType.Crop
				avatarImage.Parent = avatarFrame

				local imageCorner = Instance.new("UICorner")

				imageCorner.CornerRadius = UDim.new(1, 0)
				imageCorner.Parent = avatarImage

				ApplyPayloadAvatar(avatarImage, payload)

				return avatarFrame, avatarImage
			end
			local function SetGroupRootPayload(groupEntry, payload, theme)
				if not groupEntry or not payload then
					return
				end
				if groupEntry.RootReplyLabel and groupEntry.RootReplyLabel.Parent then
					groupEntry.RootReplyLabel:Destroy()
				end

				groupEntry.RootReplyLabel = nil

				if payload.ReplyMeta then
					groupEntry.RootReplyLabel =
						CreateReplyMetaLabel(groupEntry.ContentHolder, 1, payload.ReplyMeta, theme)
				end

				groupEntry.RootPayload = payload
				groupEntry.RootMessageId = tostring(payload.MessageId or "")
				groupEntry.AuthorKey = GetAuthorGroupKey(payload)
				groupEntry.UsernameLabel.Text = payload.AuthorName
				groupEntry.TimeLabel.Text = payload.TimeText
				groupEntry.RootContentLabel.Text = GetPayloadDisplayContent(payload, false)
				ApplyPayloadAvatar(groupEntry.AvatarImage, payload)
			end
			local function RemoveCombinedPart(groupEntry, targetPart)
				if not groupEntry or not targetPart then
					return
				end

				for index, part in ipairs(groupEntry.CombinedParts) do
					if part == targetPart then
						table.remove(groupEntry.CombinedParts, index)

						return
					end
				end
			end
			local function SetReplyTarget(payload)
				DiscordChatData.ActiveReply = {
					MessageId = tostring(payload.MessageId or ""),
					AuthorName = tostring(payload.AuthorName or "Unknown"),
					Content = tostring(payload.Content or ""),
					IsRemoved = payload.IsRemoved == true,
				}

				UpdateReplyPreviewBar()

				if not Page.InputBar.InputRow.InputBox:IsFocused() then
					Page.InputBar.InputRow.InputBox:CaptureFocus()
				end
			end

			Page.InputBar.ReplyBar.ReplyClear.Activated:Connect(function()
				ClearReplyTarget()
			end)
			HoldMenuReply.Activated:Connect(function()
				if DiscordChatData.ActionReplyPayload then
					SetReplyTarget(DiscordChatData.ActionReplyPayload)
				end

				HideHoldMenu()
			end)

			function DiscordChatData:ToggleGuest(t)
				DiscordChatData.AsGuest = t
			end
			function DiscordChatData:AddMessage(usernameOrRaw, content, isHistory)
				local payload = BuildMessagePayload(usernameOrRaw, content, isHistory)

				if payload.MessageId ~= "" and DiscordChatData.MessageEntries[payload.MessageId] then
					local existing = DiscordChatData.MessageEntries[payload.MessageId]
					local existingBubble = existing.Bubble or (existing.Group and existing.Group.Bubble)

					if existingBubble and existingBubble.Parent then
						return existing.Payload or payload
					end

					DiscordChatData.MessageEntries[payload.MessageId] = nil
				end

				local theme = GetTheme()
				local groupEntry = ShouldCombineWithLastGroup(payload)

				if groupEntry then
					local PartFrame = Instance.new("Frame")

					PartFrame.Name = "CombinedPart"
					PartFrame.Size = UDim2.new(1, 0, 0, 0)
					PartFrame.AutomaticSize = Enum.AutomaticSize.Y
					PartFrame.BackgroundTransparency = 1
					PartFrame.Active = true
					PartFrame.LayoutOrder = groupEntry.NextLayoutOrder
					PartFrame.Parent = groupEntry.ContentHolder

					local PartLayout = Instance.new("UIListLayout")

					PartLayout.SortOrder = Enum.SortOrder.LayoutOrder
					PartLayout.Padding = UDim.new(0, 2)
					PartLayout.Parent = PartFrame

					local PartReplyLabel = nil

					if payload.ReplyMeta then
						PartReplyLabel = CreateReplyMetaLabel(PartFrame, 1, payload.ReplyMeta, theme)
					end

					local PartContentLabel = Instance.new("TextLabel")

					PartContentLabel.Size = UDim2.new(1, 0, 0, 0)
					PartContentLabel.AutomaticSize = Enum.AutomaticSize.Y
					PartContentLabel.BackgroundTransparency = 1
					PartContentLabel.Text = GetPayloadDisplayContent(payload, true)
					PartContentLabel.TextColor3 = theme.Chat.Text
					PartContentLabel.Font = Enum.Font.Gotham
					PartContentLabel.TextSize = 14
					PartContentLabel.TextXAlignment = Enum.TextXAlignment.Left
					PartContentLabel.TextYAlignment = Enum.TextYAlignment.Top
					PartContentLabel.TextWrapped = true
					PartContentLabel.RichText = true
					PartContentLabel.LineHeight = 1.28
					PartContentLabel.LayoutOrder = 2

					PartContentLabel:SetAttribute("IsChatContent", true)

					PartContentLabel.Parent = PartFrame

					applyCurrentTextFont(groupEntry.Bubble)

					if PartReplyLabel then
						PartReplyLabel.TextTransparency = 1

						spr.target(PartReplyLabel, 0.6, 5, { TextTransparency = 0 })
					end

					PartContentLabel.TextTransparency = 0.92

					spr.target(PartContentLabel, 0.68, 4, { TextTransparency = 0 })

					local part = {
						Payload = payload,
						MessageId = tostring(payload.MessageId or ""),
						Frame = PartFrame,
						ReplyLabel = PartReplyLabel,
						ContentLabel = PartContentLabel,
					}

					table.insert(groupEntry.CombinedParts, part)

					groupEntry.NextLayoutOrder += 1

					UpdateGroupLastPayload(groupEntry, payload)

					DiscordChatData.LastBubbleRootId = groupEntry.RootId

					BindHoldGesture(PartFrame, payload, groupEntry.Bubble)

					if payload.MessageId ~= "" then
						DiscordChatData.MessageEntries[payload.MessageId] = {
							Bubble = groupEntry.Bubble,
							Payload = payload,
							ContentLabel = PartContentLabel,
							ReplyLabel = PartReplyLabel,
							Group = groupEntry,
							Part = part,
							IsRoot = false,
						}
					end
				else
					local MessageBubble = Instance.new("Frame")

					DiscordChatData._MessageCounter += 1

					MessageBubble.Name = "Message_" .. tostring(DiscordChatData._MessageCounter)
					MessageBubble.Size = UDim2.new(1, -4, 0, 0)
					MessageBubble.AutomaticSize = Enum.AutomaticSize.Y
					MessageBubble.BackgroundColor3 = theme.Chat.Bubble
					MessageBubble.BackgroundTransparency = 0.88
					MessageBubble.BorderSizePixel = 0
					MessageBubble.Active = true

					MessageBubble:SetAttribute("IsChatBubble", true)

					MessageBubble.Parent = Page.Container.Messages

					local BubbleCorner = Instance.new("UICorner")

					BubbleCorner.CornerRadius = UDim.new(0, 12)
					BubbleCorner.Parent = MessageBubble

					local BubbleStroke = Instance.new("UIStroke")

					BubbleStroke.Color = theme.Chat.AvatarStroke
					BubbleStroke.Thickness = 1
					BubbleStroke.Transparency = 0.62

					BubbleStroke:SetAttribute("IsChatBubbleStroke", true)

					BubbleStroke.Parent = MessageBubble

					local BubblePadding = Instance.new("UIPadding")

					BubblePadding.PaddingLeft = UDim.new(0, 12)
					BubblePadding.PaddingRight = UDim.new(0, 14)
					BubblePadding.PaddingTop = UDim.new(0, 12)
					BubblePadding.PaddingBottom = UDim.new(0, 12)
					BubblePadding.Parent = MessageBubble

					local ContentHolder = Instance.new("Frame")

					ContentHolder.Name = "ContentHolder"
					ContentHolder.BackgroundTransparency = 1
					ContentHolder.Position = UDim2.fromOffset(48, 0)
					ContentHolder.Size = UDim2.new(1, -48, 0, 0)
					ContentHolder.AutomaticSize = Enum.AutomaticSize.Y
					ContentHolder.Parent = MessageBubble

					local AvatarFrame, AvatarImage = CreateMessageAvatar(MessageBubble, payload, theme)

					local ContentLayout = Instance.new("UIListLayout")

					ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
					ContentLayout.Padding = UDim.new(0, 3)
					ContentLayout.Parent = ContentHolder

					local ReplyMetaLabel = nil

					if payload.ReplyMeta then
						ReplyMetaLabel = CreateReplyMetaLabel(ContentHolder, 1, payload.ReplyMeta, theme)
					end

					local HeaderRow = Instance.new("Frame")

					HeaderRow.Name = "HeaderRow"
					HeaderRow.BackgroundTransparency = 1
					HeaderRow.Size = UDim2.new(1, 0, 0, 20)
					HeaderRow.LayoutOrder = 2
					HeaderRow.Parent = ContentHolder

					local UsernameLabel = Instance.new("TextLabel")

					UsernameLabel.Size = UDim2.new(0.74, 0, 1, 0)
					UsernameLabel.BackgroundTransparency = 1
					UsernameLabel.Text = payload.AuthorName
					UsernameLabel.TextColor3 = theme.Chat.Username
					UsernameLabel.Font = Enum.Font.GothamBold
					UsernameLabel.TextSize = 13.5
					UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

					UsernameLabel:SetAttribute("IsChatUsername", true)

					UsernameLabel.Parent = HeaderRow

					local TimeLabel = Instance.new("TextLabel")

					TimeLabel.Size = UDim2.new(0.26, 0, 1, 0)
					TimeLabel.Position = UDim2.new(0.74, 0, 0, 0)
					TimeLabel.BackgroundTransparency = 1
					TimeLabel.Text = payload.TimeText
					TimeLabel.TextColor3 = theme.SubText
					TimeLabel.Font = Enum.Font.GothamMedium
					TimeLabel.TextSize = 12
					TimeLabel.TextXAlignment = Enum.TextXAlignment.Right

					TimeLabel:SetAttribute("IsChatReplyMeta", true)

					TimeLabel.Parent = HeaderRow

					local ContentLabel = Instance.new("TextLabel")

					ContentLabel.Size = UDim2.new(1, 0, 0, 0)
					ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
					ContentLabel.BackgroundTransparency = 1
					ContentLabel.Text = GetPayloadDisplayContent(payload, false)
					ContentLabel.TextColor3 = theme.Chat.Text
					ContentLabel.Font = Enum.Font.Gotham
					ContentLabel.TextSize = 14
					ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
					ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
					ContentLabel.TextWrapped = true
					ContentLabel.RichText = true
					ContentLabel.LineHeight = 1.28
					ContentLabel.LayoutOrder = 4

					ContentLabel:SetAttribute("IsChatContent", true)

					ContentLabel.Parent = ContentHolder

					applyCurrentTextFont(MessageBubble)

					MessageBubble.BackgroundTransparency = 0.88
					UsernameLabel.TextTransparency = 1
					TimeLabel.TextTransparency = 1
					ContentLabel.TextTransparency = 1

					spr.target(MessageBubble, 0.68, 4, { BackgroundTransparency = 0 })
					spr.target(UsernameLabel, 0.6, 5, { TextTransparency = 0 })
					spr.target(TimeLabel, 0.6, 5, { TextTransparency = 0 })
					spr.target(ContentLabel, 0.6, 5, { TextTransparency = 0 })

					if ReplyMetaLabel then
						ReplyMetaLabel.TextTransparency = 1

						spr.target(ReplyMetaLabel, 0.6, 5, { TextTransparency = 0 })
					end

					local rootMessageId = tostring(payload.MessageId or "")
					local rootId = rootMessageId

					if rootId == "" then
						DiscordChatData._GroupCounter += 1

						rootId = "group_" .. tostring(DiscordChatData._GroupCounter)
					end

					groupEntry = {
						RootId = rootId,
						RootMessageId = rootMessageId,
						RootPayload = payload,
						LastPayload = payload,
						LastTimestamp = tonumber(payload.UnixTimestamp) or os.time(),
						LastMessageId = rootMessageId,
						AuthorKey = GetAuthorGroupKey(payload),
						Bubble = MessageBubble,
						ContentHolder = ContentHolder,
						UsernameLabel = UsernameLabel,
						TimeLabel = TimeLabel,
						RootContentLabel = ContentLabel,
						RootReplyLabel = ReplyMetaLabel,
						AvatarFrame = AvatarFrame,
						AvatarImage = AvatarImage,
						CombinedParts = {},
						NextLayoutOrder = 6,
					}
					DiscordChatData.MessageGroups[rootId] = groupEntry
					DiscordChatData.LastBubbleRootId = rootId

					BindHoldGesture(MessageBubble, function()
						return groupEntry and groupEntry.RootPayload or payload
					end, MessageBubble)

					if payload.MessageId ~= "" then
						DiscordChatData.MessageEntries[payload.MessageId] = {
							Bubble = MessageBubble,
							Payload = payload,
							ContentLabel = ContentLabel,
							ReplyLabel = ReplyMetaLabel,
							Group = groupEntry,
							IsRoot = true,
						}
					end
				end

				local messagesFrame = Page.Container.Messages

				task.defer(function()
					local function SnapToBottom()
						if not messagesFrame or not messagesFrame.Parent then
							return
						end

						local targetY = math.max(0, messagesFrame.AbsoluteCanvasSize.Y - messagesFrame.AbsoluteSize.Y)

						messagesFrame.CanvasPosition = Vector2.new(0, targetY)
					end

					SnapToBottom()
					task.wait()
					SnapToBottom()
				end)

				if not payload.IsHistory then
					EmitOnNewMessage(payload)

					if DiscordChatData.GetsNewMessagesNotification then
						local shouldNotify = true

						if DiscordChatData.NotifyOnlyWhenChatHidden then
							shouldNotify = not IsChatTabVisible()
						end
						if shouldNotify then
							local localName = string.lower(tostring(lp and lp.Name or ""))
							local authorLower = string.lower(tostring(payload.AuthorName or ""))

							if authorLower == localName or (DiscordChatData.AsGuest and authorLower == "guest") then
								return payload
							end

							local shortContent = TrimText(payload.Content):gsub("\n", " ")

							if shortContent == "" then
								shortContent = "[No text]"
							end
							if #shortContent > 96 then
								shortContent = shortContent:sub(1, 96) .. "..."
							end

							local notifyTitle = payload.IsReplyToLocal and "Reply from " or "New message from "

							if Library.SendNotification then
								Library:SendNotification({
									Title = notifyTitle .. payload.AuthorName,
									Description = shortContent,
									Duration = DiscordChatData.NewMessageNotifyDuration,
									Type = payload.IsReplyToLocal and "warning" or "default",
								})
							else
								_ntf(
									notifyTitle .. payload.AuthorName .. "\n" .. shortContent,
									DiscordChatData.NewMessageNotifyDuration
								)
							end
						end
					end
				end

				return payload
			end
			function DiscordChatData:HandleDeletedMessage(messageId)
				local targetId = tostring(messageId or "")

				if targetId == "" then
					return
				end

				local entry = DiscordChatData.MessageEntries[targetId]

				if entry then
					local groupEntry = entry.Group

					if
						HoldMenu.Visible
						and DiscordChatData.ActionReplyPayload
						and tostring(DiscordChatData.ActionReplyPayload.MessageId or "") == targetId
					then
						HideHoldMenu()
					end
					if groupEntry and groupEntry.Bubble and groupEntry.Bubble.Parent then
						if entry.IsRoot then
							if #groupEntry.CombinedParts > 0 then
								local promoted = table.remove(groupEntry.CombinedParts, 1)

								if promoted and promoted.MessageId ~= "" then
									DiscordChatData.MessageEntries[promoted.MessageId] = nil
								end
								if promoted and promoted.Frame and promoted.Frame.Parent then
									promoted.Frame:Destroy()
								end

								local oldRootId = groupEntry.RootId
								local newRootPayload = promoted and promoted.Payload or groupEntry.RootPayload

								SetGroupRootPayload(groupEntry, newRootPayload, GetTheme())

								local newRootMessageId = tostring(newRootPayload.MessageId or "")
								local newRootId = newRootMessageId ~= "" and newRootMessageId or oldRootId

								groupEntry.RootId = newRootId

								if oldRootId ~= newRootId then
									DiscordChatData.MessageGroups[oldRootId] = nil
									DiscordChatData.MessageGroups[newRootId] = groupEntry

									if DiscordChatData.LastBubbleRootId == oldRootId then
										DiscordChatData.LastBubbleRootId = newRootId
									end
								end

								DiscordChatData.MessageEntries[targetId] = nil

								if newRootMessageId ~= "" then
									DiscordChatData.MessageEntries[newRootMessageId] = {
										Bubble = groupEntry.Bubble,
										Payload = newRootPayload,
										ContentLabel = groupEntry.RootContentLabel,
										ReplyLabel = groupEntry.RootReplyLabel,
										Group = groupEntry,
										IsRoot = true,
									}
								end
								if #groupEntry.CombinedParts > 0 then
									local tail = groupEntry.CombinedParts[#groupEntry.CombinedParts]

									UpdateGroupLastPayload(groupEntry, tail.Payload)
								else
									UpdateGroupLastPayload(groupEntry, groupEntry.RootPayload)
								end
							else
								if groupEntry.Bubble and groupEntry.Bubble.Parent then
									groupEntry.Bubble:Destroy()
								end

								DiscordChatData.MessageGroups[groupEntry.RootId] = nil
								DiscordChatData.MessageEntries[targetId] = nil

								if DiscordChatData.LastBubbleRootId == groupEntry.RootId then
									DiscordChatData.LastBubbleRootId = nil
								end
							end
						else
							local part = entry.Part

							if part then
								RemoveCombinedPart(groupEntry, part)

								if part.Frame and part.Frame.Parent then
									part.Frame:Destroy()
								end
							end

							DiscordChatData.MessageEntries[targetId] = nil

							if #groupEntry.CombinedParts > 0 then
								local tail = groupEntry.CombinedParts[#groupEntry.CombinedParts]

								UpdateGroupLastPayload(groupEntry, tail.Payload)
							else
								UpdateGroupLastPayload(groupEntry, groupEntry.RootPayload)
							end
						end
					else
						if entry.Bubble and entry.Bubble.Parent then
							entry.Bubble:Destroy()
						end

						DiscordChatData.MessageEntries[targetId] = nil
					end

					SetStatusMessage("Tracked deletion: message removed from chat.", Color3.fromRGB(170, 176, 190))
				end
				if
					DiscordChatData.ActiveReply
					and tostring(DiscordChatData.ActiveReply.MessageId or "") == targetId
				then
					DiscordChatData.ActiveReply.Content = "Removed Message"
					DiscordChatData.ActiveReply.IsRemoved = true

					UpdateReplyPreviewBar()
				end
			end
			function DiscordChatData:HandleUpdatedMessage(usernameOrRaw, content, isHistory)
				local payload = BuildMessagePayload(usernameOrRaw, content, isHistory)
				local targetId = tostring(payload.MessageId or "")

				if targetId == "" then
					return DiscordChatData:AddMessage(usernameOrRaw, content, isHistory)
				end

				local entry = DiscordChatData.MessageEntries[targetId]

				if not entry then
					return DiscordChatData:AddMessage(usernameOrRaw, content, isHistory)
				end

				local groupEntry = entry.Group
				local theme = GetTheme()

				entry.Payload = payload

				if groupEntry and groupEntry.Bubble and groupEntry.Bubble.Parent then
					if entry.IsRoot then
						SetGroupRootPayload(groupEntry, payload, theme)

						entry.ContentLabel = groupEntry.RootContentLabel
						entry.ReplyLabel = groupEntry.RootReplyLabel

						if groupEntry.LastMessageId == targetId or #groupEntry.CombinedParts == 0 then
							UpdateGroupLastPayload(groupEntry, payload)
						end
					else
						if entry.Part then
							entry.Part.Payload = payload
						end
						if entry.ContentLabel then
							entry.ContentLabel.Text = GetPayloadDisplayContent(payload, true)
						end

						local replyParent = entry.Part and entry.Part.Frame

						entry.ReplyLabel =
							ReplaceReplyMetaLabel(entry.ReplyLabel, replyParent, 1, payload.ReplyMeta, theme)

						if entry.Part then
							entry.Part.ReplyLabel = entry.ReplyLabel
						end
						if groupEntry.LastMessageId == targetId then
							UpdateGroupLastPayload(groupEntry, payload)
						end
					end
				end
				if
					HoldMenu.Visible
					and DiscordChatData.ActionReplyPayload
					and tostring(DiscordChatData.ActionReplyPayload.MessageId or "") == targetId
				then
					DiscordChatData.ActionReplyPayload = payload
				end
				if
					DiscordChatData.ActiveReply
					and tostring(DiscordChatData.ActiveReply.MessageId or "") == targetId
				then
					DiscordChatData.ActiveReply.AuthorName = tostring(payload.AuthorName or "Unknown")
					DiscordChatData.ActiveReply.Content = tostring(payload.Content or "")
					DiscordChatData.ActiveReply.IsRemoved = false

					UpdateReplyPreviewBar()
				end

				SetStatusMessage("Tracked edit: message updated.", Color3.fromRGB(170, 176, 190))

				return payload
			end

			local function FormatBaseUrl(value)
				local text = TrimText(tostring(value or ""))

				if text == "" then
					return nil
				end

				return (text:gsub("/+$", ""))
			end
			local function FormatHttpBase(value)
				local text = FormatBaseUrl(value)

				if not text then
					return nil
				end
				if text:sub(1, 6) == "wss://" then
					text = "https://" .. text:sub(7)
				elseif text:sub(1, 5) == "ws://" then
					text = "http://" .. text:sub(6)
				end

				return (text:gsub("/ws$", ""))
			end
			local function FormatWSurl(value)
				local text = FormatBaseUrl(value)

				if not text then
					return nil
				end
				if text:sub(1, 8) == "https://" then
					text = "wss://" .. text:sub(9)
				elseif text:sub(1, 7) == "http://" then
					text = "ws://" .. text:sub(8)
				end
				if text:sub(-3) ~= "/ws" then
					text = text .. "/ws"
				end

				return text
			end
			local function GetBridgeHttpBase()
				return FormatHttpBase(
					DiscordChatData.Link
						or DiscordChatData.Constants.WebSocketLink
						or DiscordChatData.Constants.Link
						or DiscordChatData.Constants.BridgeHttp
						or DiscordChatData.Constants.BridgeHTTP
						or DiscordChatData.Constants.BridgeBaseUrl
						or DiscordChatData.Constants.BridgeBaseURL
						or DiscordChatData.Constants.BridgeWs
						or DiscordChatData.Constants.BridgeWS
						or DiscordChatData.Constants.BridgeSocket
						or DiscordChatData.WebSocketServer
				)
			end
			local function GetWSUrl()
				local explicit = FormatWSurl(
					DiscordChatData.Link
						or DiscordChatData.Constants.WebSocketLink
						or DiscordChatData.Constants.Link
						or DiscordChatData.Constants.BridgeWs
						or DiscordChatData.Constants.BridgeWS
						or DiscordChatData.Constants.BridgeSocket
						or DiscordChatData.Constants.BridgeHttp
						or DiscordChatData.Constants.BridgeHTTP
						or DiscordChatData.Constants.BridgeBaseUrl
						or DiscordChatData.Constants.BridgeBaseURL
						or DiscordChatData.WebSocketServer
				)

				if explicit then
					return explicit
				end

				return nil
			end
			local function GetRequiredChannel()
				local raw = DiscordChatData.Constants.BridgeChannels or DiscordChatData.Constants.AllowedChannels or {}
				local channels = {}

				if typeof(raw) == "table" then
					for _, entry in ipairs(raw) do
						local channelId = TrimText(tostring(entry or ""))

						if channelId ~= "" then
							table.insert(channels, channelId)
						end
					end
				end
				if #channels == 0 then
					local fallbackChannel = TrimText(tostring(DiscordChatData.Constants.Channel or ""))

					if fallbackChannel ~= "" then
						table.insert(channels, fallbackChannel)
					end
				end

				return channels
			end
			local function SyncBridgeChannelsFromReady(readyChannels)
				if typeof(readyChannels) ~= "table" then
					return
				end

				local available = {}
				local preferredChatChannel = nil
				for _, entry in ipairs(readyChannels) do
					local channelId = ""
					local channelName = ""

					if typeof(entry) == "table" then
						channelId = TrimText(tostring(entry.channelId or entry.channel_id or entry.id or ""))
						channelName = string.lower(
							TrimText(tostring(entry.channelName or entry.channel_name or entry.name or ""))
						)
					else
						channelId = TrimText(tostring(entry or ""))
					end

					if channelId ~= "" then
						table.insert(available, channelId)
						if not preferredChatChannel and channelName:find("chat", 1, true) then
							preferredChatChannel = channelId
						end
					end
				end

				if #available == 0 then
					return
				end

				local requested = GetRequiredChannel()
				if #requested == 0 then
					DiscordChatData.Constants.Channel = preferredChatChannel or available[1]
					return
				end

				for _, requestedChannel in ipairs(requested) do
					if table.find(available, requestedChannel) then
						return
					end
				end

				DiscordChatData.Constants.Channel = preferredChatChannel or available[1]
				DiscordChatData.Constants.BridgeChannels = nil
				DiscordChatData.Constants.AllowedChannels = nil
			end
			local function SubscribeBridgeChannels(ws)
				if not ws then
					return
				end

				local channels = GetRequiredChannel()

				if #channels == 0 then
					return
				end

				local sendFn = ws.Send or ws.send

				if typeof(sendFn) ~= "function" then
					return
				end

				pcall(
					sendFn,
					ws,
					HttpService:JSONEncode({
						type = "subscribe",
						channelIds = channels,
					})
				)
			end
			local function IsBridgeChannelAllowed(channelId)
				local targetChannel = TrimText(tostring(channelId or ""))

				if targetChannel == "" then
					return false
				end

				local channels = GetRequiredChannel()

				if #channels == 0 then
					return true
				end

				return table.find(channels, targetChannel) ~= nil
			end
			local function ExtractBridgeMessage(packet)
				if typeof(packet) ~= "table" then
					return nil
				end

				local nestedMessage = packet.message or packet.payload or packet.data

				if typeof(nestedMessage) == "table" then
					if nestedMessage.avatar_url == nil then
						nestedMessage.avatar_url = packet.avatar_url
							or packet.avatarUrl
							or packet.authorAvatarUrl
							or packet.authorAvatar
					end
					if nestedMessage.channel_id == nil then
						nestedMessage.channel_id = packet.channel_id or packet.channelId
					end
					if typeof(nestedMessage.author) ~= "table" then
						local username = TrimText(tostring(packet.username or packet.authorName or ""))
						nestedMessage.author = {
							id = tostring(packet.authorId or ""),
							username = username ~= "" and username or "Unknown",
							avatar = tostring(packet.authorAvatarHash or packet.avatarHash or ""),
						}
					else
						nestedMessage.author.id = tostring(nestedMessage.author.id or packet.authorId or "")
						nestedMessage.author.username = TrimText(
							tostring(nestedMessage.author.username or packet.username or packet.authorName or "")
						)
						if nestedMessage.author.username == "" then
							nestedMessage.author.username = "Unknown"
						end
						nestedMessage.author.avatar = nestedMessage.author.avatar
							or packet.authorAvatarHash
							or packet.avatarHash
						nestedMessage.author.avatar_url = nestedMessage.author.avatar_url
							or nestedMessage.author.avatarUrl
							or packet.avatar_url
							or packet.avatarUrl
							or packet.authorAvatarUrl
							or packet.authorAvatar
					end
					return nestedMessage
				end

				local username = TrimText(tostring(packet.username or packet.authorName or ""))
				local content = tostring(packet.content or "")
				local channelId = TrimText(tostring(packet.channelId or packet.channel_id or ""))

				if username == "" and content == "" and channelId == "" then
					return nil
				end

				return {
					id = tostring(packet.messageId or packet.id or HttpService:GenerateGUID(false)),
					channel_id = channelId,
					content = content,
					timestamp = tostring(packet.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")),
					edited_timestamp = tostring(packet.editedTimestamp or packet.edited_timestamp or ""),
					avatar_url = tostring(
						packet.avatar_url or packet.avatarUrl or packet.authorAvatarUrl or packet.authorAvatar or ""
					),
					author = {
						id = tostring(packet.authorId or ""),
						username = username ~= "" and username or "Unknown",
						avatar = tostring(packet.authorAvatarHash or packet.avatarHash or ""),
					},
				}
			end
			local function GetMessageUnixTimestamp(message)
				if typeof(message) ~= "table" then
					return 0
				end
				local rawTimestamp = message.timestamp
					or message.created_at
					or message.createdAt
					or message.time
					or message.t
				if typeof(rawTimestamp) == "number" then
					return rawTimestamp
				end
				if typeof(rawTimestamp) == "string" and rawTimestamp ~= "" then
					local numeric = tonumber(rawTimestamp)
					if numeric then
						return numeric
					end
					local ok, dateTime = pcall(DateTime.fromIsoDate, rawTimestamp)
					if ok and dateTime then
						return tonumber(dateTime.UnixTimestamp) or 0
					end
				end
				return 0
			end
			local function NormalizeDiscordMessageList(source)
				local messages = {}
				if typeof(source) ~= "table" then
					return messages
				end

				local list = source.messages or source.history or source.data or source
				if typeof(list) ~= "table" then
					return messages
				end

				for _, entry in pairs(list) do
					local message = ExtractBridgeMessage(entry)
					if typeof(message) == "table" then
						table.insert(messages, message)
					end
				end

				table.sort(messages, function(a, b)
					local at = GetMessageUnixTimestamp(a)
					local bt = GetMessageUnixTimestamp(b)
					if at == bt then
						return tostring(a.id or "") < tostring(b.id or "")
					end
					return at < bt
				end)

				return messages
			end
			local function FetchLastMessages(botToken, channelId)
				local bridgeHttpBase = GetBridgeHttpBase()

				if bridgeHttpBase then
					local success, result = pcall(function()
						local requestFn = GetRequestFunction()

						if typeof(requestFn) ~= "function" then
							return {}
						end

						local fetchLimit = tonumber(DiscordChatData.Constants.FetchLimit) or 20
						local bridgeChannels = GetRequiredChannel()
						local requestUrl = string.format("%s/api/messages?limit=%d", bridgeHttpBase, fetchLimit)

						if #bridgeChannels <= 1 and TrimText(tostring(channelId or "")) ~= "" then
							requestUrl = requestUrl
								.. "&channelId="
								.. HttpService:UrlEncode(TrimText(tostring(channelId or "")))
						end

						local res = requestFn({
							Url = requestUrl,
							Method = "GET",
							Headers = {
								["Content-Type"] = "application/json",
							},
						})
						local statusCode = tonumber((res and (res.StatusCode or res.status or res.Code)) or 0)

						if statusCode ~= 200 then
							return {}
						end

						local decoded = HttpService:JSONDecode(tostring(res.Body or "[]"))
						return NormalizeDiscordMessageList(decoded)
					end)

					if success then
						return result
					else
						warn("Failed to fetch bridge messages:", result)

						return {}
					end
				end

				local token = botToken

				if not token:find("Bot ") then
					token = "Bot " .. token
				end

				local success, result = pcall(function()
					local requestFn = GetRequestFunction()

					if typeof(requestFn) ~= "function" then
						return {}
					end

					local fetchLimit = tonumber(DiscordChatData.Constants.FetchLimit) or 20
					local res = requestFn({
						Url = string.format(
							"https://discord.com/api/v10/channels/%s/messages?limit=%d",
							channelId,
							fetchLimit
						),
						Method = "GET",
						Headers = {
							Authorization = token,
							["Content-Type"] = "application/json",
						},
					})

					if not res or tonumber(res.StatusCode or 0) ~= 200 then
						return {}
					end

					return NormalizeDiscordMessageList(HttpService:JSONDecode(res.Body))
				end)

				if success then
					return result
				else
					warn("Failed to fetch messages:", result)

					return {}
				end
			end

			function DiscordChatData:LoadMessages()
				if
					not GetBridgeHttpBase()
					and (not DiscordChatData.Constants.Bot or not DiscordChatData.Constants.Channel)
				then
					warn("Bot token or Channel ID not provided")

					return
				end

				SetStatusMessage("Loading recent chat history...", Color3.fromRGB(170, 176, 190), 3)

				local messages = FetchLastMessages(DiscordChatData.Constants.Bot, DiscordChatData.Constants.Channel)

				for _, msg in ipairs(messages) do
					local ch = tostring(msg.channel_id or msg.channelId or "")
					if IsBridgeChannelAllowed(ch) then
						local ok, err = pcall(function()
							DiscordChatData:AddMessage(msg, nil, true)
						end)
						if not ok then
							warn("Failed to add history message:", err)
						end
					end
				end

				if #messages > 0 then
					SetStatusMessage(
						string.format("Loaded %d recent messages.", #messages),
						Color3.fromRGB(120, 214, 158),
						2.4
					)
				end
			end
			function ResolveWebSocketConnect()
				local candidates = {
					WebSocket,
					Websocket,
					syn and syn.websocket,
					Krnl and Krnl.WebSocket,
				}
				for _, wsLib in ipairs(candidates) do
					if typeof(wsLib) == "table" then
						local connectFn = wsLib.connect or wsLib.Connect
						if typeof(connectFn) == "function" then
							return connectFn
						end
					elseif typeof(wsLib) == "function" then
						return wsLib
					end
				end
				return nil
			end
			function DiscordChatData:ConnectAPI()
				DiscordChatData._ReconnectToken = (DiscordChatData._ReconnectToken or 0) + 1
				local myToken = DiscordChatData._ReconnectToken

				local bridgeWsUrl = GetWSUrl()

				if not bridgeWsUrl and (not DiscordChatData.Constants.Bot or not DiscordChatData.Constants.Channel) then
					warn("[Chat] Bot token or Channel ID not provided — cannot connect.")
					return
				end

				if bridgeWsUrl then
					local wsConnect = ResolveWebSocketConnect()
					if typeof(wsConnect) ~= "function" then
						SetStatusMessage("Bridge sync unavailable on this executor.", Color3.fromRGB(255, 120, 120), 5)
						DiscordChatData:LoadMessages()
						return
					end

					local MAX_BACKOFF = 30
					local backoff = 1

					task.spawn(function()
						while DiscordChatData._ReconnectToken == myToken do
							SetStatusMessage("Connecting to bridge...", Color3.fromRGB(170, 176, 190))
							DiscordChatData._IsConnected = false

							local ok, err = pcall(function()
								local ws = wsConnect(bridgeWsUrl)
								SubscribeBridgeChannels(ws)

								backoff = 1
								DiscordChatData._IsConnected = true
								SetStatusMessage("Bridge connected.", Color3.fromRGB(120, 214, 158), 3)

								local closed = false

								ws.OnClose:Connect(function()
									closed = true
									DiscordChatData._IsConnected = false
								end)

								ws.OnMessage:Connect(function(message)
									if DiscordChatData._ReconnectToken ~= myToken then
										return
									end

									local decodeOk, packet = pcall(HttpService.JSONDecode, HttpService, message)
									if not decodeOk or typeof(packet) ~= "table" then
										return
									end

									if packet.type == "discord.ready" or packet.type == "ready" then
										SyncBridgeChannelsFromReady(packet.channels)
										SubscribeBridgeChannels(ws)
										if typeof(packet.history) == "table" then
											for _, bridgeMessage in ipairs(NormalizeDiscordMessageList(packet.history)) do
												local historyChannel = typeof(bridgeMessage) == "table"
														and tostring(bridgeMessage.channel_id or "")
													or ""

												if
													typeof(bridgeMessage) == "table"
													and IsBridgeChannelAllowed(historyChannel)
												then
													DiscordChatData:AddMessage(bridgeMessage, nil, true)
												end
											end
										end
										SetStatusMessage("Bridge sync connected.", Color3.fromRGB(120, 214, 158), 3)
										return
									end

									if packet.type == "discord.delete_bulk" then
										local ch = tostring(packet.channelId or packet.channel_id or "")
										if IsBridgeChannelAllowed(ch) then
											for _, id in ipairs(packet.messageIds or {}) do
												DiscordChatData:HandleDeletedMessage(id)
											end
										end
										return
									end

									if packet.type == "discord.delete" or packet.type == "delete" then
										local ch = tostring(packet.channelId or packet.channel_id or "")
										if IsBridgeChannelAllowed(ch) then
											DiscordChatData:HandleDeletedMessage(packet.messageId or packet.id)
										end
										return
									end

									local bridgeMessage = ExtractBridgeMessage(packet)
									if typeof(bridgeMessage) == "table" then
										local ch = tostring(
											bridgeMessage.channel_id or packet.channelId or packet.channel_id or ""
										)
										if IsBridgeChannelAllowed(ch) then
											if packet.type == "discord.message_update" then
												DiscordChatData:HandleUpdatedMessage(bridgeMessage, nil, false)
											else
												DiscordChatData:AddMessage(bridgeMessage, nil, false)
											end
										end
									end
								end)

								while not closed and DiscordChatData._ReconnectToken == myToken do
									task.wait(1)
								end
							end)

							if DiscordChatData._ReconnectToken ~= myToken then
								return
							end
							if not ok then
								warn("[Chat] Bridge WebSocket error:", err)
							end

							DiscordChatData._IsConnected = false

							local retryIn = math.min(backoff, MAX_BACKOFF)
							SetStatusMessage(
								string.format("Bridge disconnected. Retrying in %ds...", retryIn),
								Color3.fromRGB(255, 150, 80)
							)
							task.wait(retryIn)

							backoff = math.min(backoff * 2, MAX_BACKOFF)
						end
					end)
					return
				end

				local ws
				local heartbeatInterval
				local lastSeq = nil
				local heartbeatThread
				local token = DiscordChatData.Constants.Bot
				if not token:find("Bot ") then
					token = "Bot " .. token
				end

				local function send(payload)
					ws:Send(HttpService:JSONEncode(payload))
				end
				local function startHeartbeat()
					if heartbeatThread then
						task.cancel(heartbeatThread)
					end
					heartbeatThread = task.spawn(function()
						while ws and heartbeatInterval do
							task.wait(heartbeatInterval / 1000)
							send({ op = 1, d = lastSeq })
						end
					end)
				end
			end

			function DiscordChatData:Reconnect()
				DiscordChatData:ConnectAPI()
			end

			local function SendCurrentInput()
				if DiscordChatData.IsSendingNow then
					SetStatusMessage("Sending...", Color3.fromRGB(170, 176, 190))
					return
				end

				local nowTick = os.clock()
				local muted, remaining = IsMutedNow()

				if muted then
					RegisterBypassAttempt("sending during mute")
					SetStatusMessage("Muted for " .. FormatDuration(remaining) .. ".", Color3.fromRGB(255, 120, 120))
					return
				end
				if DiscordChatData.Cooldown_SendingMessage or nowTick < (DiscordChatData.CooldownUntil or 0) then
					RegisterBypassAttempt("cooldown bypass")

					local cooldownRemaining = math.max(0, (DiscordChatData.CooldownUntil or 0) - nowTick)

					SetStatusMessage(string.format("Cooldown %.1fs.", cooldownRemaining), Color3.fromRGB(255, 196, 74))
					return
				end
				if not DiscordChatData.Constants.Webhook or DiscordChatData.Constants.Webhook == "" then
					warn("Webhook URL not configured")
					return
				end

				local input = TrimText(Page.InputBar.InputRow.InputBox.Text)

				if input == "" then
					return
				end

				local maxMessageLength = math.max(24, math.floor(tonumber(DiscordChatData.MaxMessageLength) or 320))

				if #input > maxMessageLength then
					RegisterBypassAttempt(string.format("message too long (%d/%d)", #input, maxMessageLength))

					return
				end

				local capsSpam, capsRatio = IsCapsSpamMessage(input)

				if capsSpam then
					RegisterBypassAttempt(string.format("too many caps (%.0f%%)", math.floor(capsRatio * 100 + 0.5)))

					return
				end

				local hasRepeatChars, repeatChar = HasExcessiveRepeatChars(input)

				if hasRepeatChars then
					RegisterBypassAttempt("repeated characters: " .. tostring(repeatChar))

					return
				end

				local nowClock = os.clock()

				table.insert(DiscordChatData.SpamAttempts, nowClock)
				PruneTimedWindow(DiscordChatData.SpamAttempts, nowClock, DiscordChatData.SpamWindowSeconds)

				local spamCount = #DiscordChatData.SpamAttempts

				if spamCount >= DiscordChatData.SpamMuteThreshold then
					DiscordChatData.SpamAttempts = {}

					ApplyMuteStrike(string.format("spam burst (%d/%ds)", spamCount, DiscordChatData.SpamWindowSeconds))

					return
				elseif spamCount >= DiscordChatData.SpamWarnThreshold then
					SetStatusMessage("Slow down.", Color3.fromRGB(255, 196, 74))
				elseif not DiscordChatData.ActiveReply then
					SetStatusMessage("", nil)
				end

				local hasBlacklisted, matchedWord = ContainsBlacklistedWord(input)

				if hasBlacklisted then
					_err(string.format("Blocked message: blacklisted word detected (%s).", matchedWord))
					RegisterBypassAttempt("blocked word")

					return
				end

				local hasLink, matchedLink = ContainsBlockedLink(input)

				if hasLink then
					_err(string.format("Blocked message: link sharing is disabled (%s).", matchedLink))
					RegisterBypassAttempt("links are disabled")

					return
				end

				input = SanitizeDiscordMentions(input)

				local replyIdForSignature = DiscordChatData.ActiveReply
						and tostring(DiscordChatData.ActiveReply.MessageId or "")
					or ""
				local sendSignature = string.lower(TrimText(input)) .. "::" .. replyIdForSignature

				if
					sendSignature ~= "::"
					and sendSignature == DiscordChatData.LastSendSignature
					and nowTick - DiscordChatData.LastSendTick <= DiscordChatData.DoubleSendWindow
				then
					SetBlockedStatus("duplicate message")

					return
				end

				local payload = {
					content = input,
					username = DiscordChatData.AsGuest and "Guest" or lp.Name,
				}

				local localAvatarUrl = ResolveLocalPlayerDiscordAvatarUrl()

				if IsHttpImage(localAvatarUrl) then
					payload.avatar_url = localAvatarUrl
				end

				if DiscordChatData.ActiveReply and DiscordChatData.Constants.IncludeReplyReference ~= false then
					local replyEmbed = BuildOutgoingReplyEmbed(DiscordChatData.ActiveReply)

					if replyEmbed then
						payload.embeds = { replyEmbed }
					end
					if DiscordChatData.ActiveReply.MessageId ~= "" then
						payload.message_reference = {
							message_id = DiscordChatData.ActiveReply.MessageId,
							fail_if_not_exists = false,
						}

						local replyChannelId = TrimText(tostring(DiscordChatData.Constants.Channel or ""))

						if replyChannelId ~= "" then
							payload.message_reference.channel_id = replyChannelId
						end
					end
				end

				local requestFn = GetRequestFunction()

				if typeof(requestFn) ~= "function" then
					warn("Request function is not available")
					return
				end

				DiscordChatData.IsSendingNow = true
				DiscordChatData.LastSendSignature = sendSignature
				DiscordChatData.LastSendTick = nowTick

				local success, response = pcall(function()
					return requestFn({
						Url = BuildWebhookExecuteUrl(DiscordChatData.Constants.Webhook),
						Method = "POST",
						Headers = {
							["Content-Type"] = "application/json",
						},
						Body = HttpService:JSONEncode(payload),
					})
				end)

				DiscordChatData.IsSendingNow = false

				if not success then
					warn("Failed to send message:", response)

					DiscordChatData.LastSendSignature = ""
					DiscordChatData.LastSendTick = 0

					return
				end

				local statusCode =
					tonumber((response and (response.StatusCode or response.status or response.Code)) or 0)

				if statusCode > 0 and (statusCode < 200 or statusCode >= 300) then
					if statusCode == 429 then
						local retryAfter = DiscordChatData.CooldownDuration
						local okDecode, bodyData = pcall(function()
							return HttpService:JSONDecode(tostring(response.Body or "{}"))
						end)

						if okDecode and type(bodyData) == "table" then
							local parsedRetry = tonumber(bodyData.retry_after)

							if parsedRetry and parsedRetry > 0 then
								retryAfter = parsedRetry
							end
						end

						retryAfter = math.max(0.6, retryAfter)
						DiscordChatData.CooldownUntil =
							math.max(DiscordChatData.CooldownUntil or 0, os.clock() + retryAfter)

						SetStatusMessage(
							"Rate limited by Discord. Retry in " .. FormatDuration(math.ceil(retryAfter)) .. ".",
							Color3.fromRGB(255, 196, 74)
						)

						DiscordChatData.LastSendSignature = ""
						DiscordChatData.LastSendTick = 0

						return
					end

					warn("Failed to send message: status", statusCode)
					RegisterBypassAttempt("webhook rejected message")

					DiscordChatData.LastSendSignature = ""
					DiscordChatData.LastSendTick = 0

					return
				end

				local createdMessageBody =
					tostring((response and (response.Body or response.body or response.ResponseBody)) or "")

				if createdMessageBody ~= "" and createdMessageBody ~= "null" then
					local okDecode, createdMessage = pcall(function()
						return HttpService:JSONDecode(createdMessageBody)
					end)

					if okDecode and type(createdMessage) == "table" and createdMessage.id then
						DiscordChatData:AddMessage(createdMessage, nil, false)
					end
				end

				Page.InputBar.InputRow.InputBox.Text = ""

				ClearReplyTarget()
				HideHoldMenu()
				SetStatusMessage(
					"Message sent.",
					Color3.fromRGB(120, 214, 158),
					math.max(1.2, DiscordChatData.CooldownDuration)
				)

				DiscordChatData.Cooldown_SendingMessage = true
				DiscordChatData.CooldownUntil = os.clock() + DiscordChatData.CooldownDuration

				task.delay(DiscordChatData.CooldownDuration, function()
					DiscordChatData.Cooldown_SendingMessage = false
					DiscordChatData.CooldownUntil = 0
				end)
			end

			Page.InputBar.InputRow.SendButton.Activated:Connect(function()
				SendCurrentInput()
			end)

			if typeof(DiscordChatData.Constants.OnNewMessage) == "function" then
				DiscordChatData:OnNewMessage(DiscordChatData.Constants.OnNewMessage)
			end

			SyncModerationState(true)

			local mutedOnLoad, remainingOnLoad = IsMutedNow()

			if mutedOnLoad then
				SetStatusMessage(
					"Muted for " .. FormatDuration(remainingOnLoad) .. ". Wait before sending more messages.",
					Color3.fromRGB(255, 120, 120)
				)
			else
				SetStatusMessage(
					"Chat ready as " .. (DiscordChatData.AsGuest and "Guest" or lp.Name) .. ".",
					Color3.fromRGB(120, 214, 158),
					3
				)
			end

			UpdateReplyPreviewBar()
			if not GetWSUrl() then
				DiscordChatData:LoadMessages()
			end
			DiscordChatData:ConnectAPI()
			ApplyChatTheme(Page, GetTheme())

			return DiscordChatData
		end
		function Tabs:MakeTab(Config): ({ any }) -> { any }
			local Elements: { () -> () } = {}
			local Name = Config[1] or Config.Title or Config.Name or "Tab"
			local Icon = Lucide.GetAsset(Config[2]) or "rbxassetid://15567843390"
			local Page = (function()
				local Page = Instance.new("Frame")
				local OtherMain = Instance.new("ScrollingFrame")
				local UIListLayout = Instance.new("UIListLayout")
				local UIPadding = Instance.new("UIPadding")

				Page.Name = Name
				Page.Parent = Main.Pages
				Page.Visible = false
				Page.Active = true
				Page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Page.BackgroundTransparency = 1
				Page.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Page.BorderSizePixel = 0
				Page.Position = UDim2.new(-8.53838102E-8, 0, -1.3122883E-7, 0)
				Page.Size = UDim2.new(1, 0, 1, 0)
				OtherMain.AutomaticCanvasSize = Enum.AutomaticSize.Y
				OtherMain.CanvasSize = UDim2.new(0, 0, 0, 0)
				OtherMain.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
				OtherMain.ScrollBarImageColor3 = Color3.fromRGB(44, 44, 44)
				OtherMain.ScrollBarThickness = 6
				OtherMain.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
				OtherMain.Name = "Main"
				OtherMain.Parent = Page
				OtherMain.Active = true
				OtherMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				OtherMain.BackgroundTransparency = 1
				OtherMain.BorderColor3 = Color3.fromRGB(0, 0, 0)
				OtherMain.BorderSizePixel = 0
				OtherMain.Size = UDim2.new(1, 0, 1, 0)
				OtherMain.ZIndex = 2
				UIListLayout.Padding = UDim.new(0, 6)
				UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout.Parent = OtherMain
				UIPadding.PaddingBottom = UDim.new(0, 6)
				UIPadding.PaddingLeft = UDim.new(0, 6)
				UIPadding.PaddingRight = UDim.new(0, 6)
				UIPadding.PaddingTop = UDim.new(0, 6)
				UIPadding.Parent = OtherMain

				return Page
			end)()
			local Tab = (function()
				local Tab = Instance.new("Frame")
				local ClickDetector = Instance.new("TextButton")
				local TextLabel = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")
				local ImageLabel = Instance.new("ImageLabel")

				Tab.Name = Name
				Tab.Parent = Main.Tabs
				Tab.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				Tab.BackgroundTransparency = 1
				Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Tab.BorderSizePixel = 0
				Tab.Size = UDim2.new(1, 0, 0, 170 * CalculateUIScale())
				ClickDetector.FontFace = Font.new(
					"rbxasset://fonts/families/SourceSansPro.json",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				)
				ClickDetector.TextColor3 = Color3.fromRGB(0, 0, 0)
				ClickDetector.TextSize = 14
				ClickDetector.TextTransparency = 1
				ClickDetector.Name = "ClickDetector"
				ClickDetector.Parent = Tab
				ClickDetector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ClickDetector.BackgroundTransparency = 1
				ClickDetector.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ClickDetector.BorderSizePixel = 0
				ClickDetector.Position = UDim2.new(2.7006706200000004e-7, 0, 0, 0)
				ClickDetector.Size = UDim2.new(0.949579835, 0, 0.995215297, 0)
				TextLabel.FontFace =
					Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				TextLabel.Text = Name
				TextLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
				TextLabel.TextScaled = true
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.Parent = Tab
				TextLabel.AnchorPoint = Vector2.new(0, 0.5)
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				TextLabel.BackgroundTransparency = 1
				TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel.BorderSizePixel = 0
				TextLabel.Position = UDim2.new(0.296868831, 0, 0.5, 0)
				TextLabel.Size = UDim2.new(0.663865566, 0, 0.550000012, 0)
				UICorner.CornerRadius = UDim.new(0, 12)
				UICorner.Parent = Tab
				ImageLabel.Parent = Tab
				ImageLabel.Image = Icon.Url
				ImageLabel.ImageRectSize = Icon.ImageRectSize
				ImageLabel.ImageRectOffset = Icon.ImageRectOffset
				ImageLabel.ScaleType = Enum.ScaleType.Fit
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = 1
				ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ImageLabel.BorderSizePixel = 0
				ImageLabel.Position = UDim2.new(0.0840336159, 0, 0.132059053, 0)
				ImageLabel.Size = UDim2.new(0.15126051, 0, 0.688995242, 0)

				return Tab
			end)()

			UpdateTabsFunction()

			do
				local Handle = Elements

				local function GetPageMain()
					if typeof(Page) ~= "Instance" then
						return nil
					end

					local pageMain = Page:FindFirstChild("Main")

					if pageMain and pageMain:IsA("ScrollingFrame") then
						return pageMain
					end

					return nil
				end
				local function ResolveElementParent(context)
					local mountParent = context and rawget(context, "__ElementMountParent")

					if typeof(mountParent) == "Instance" and mountParent.Parent then
						return mountParent
					end

					return GetPageMain() or Page
				end

				function Handle:AddButton(Config)
					local NameButton = Config[1] or Config.Title or Config.Name or "Button"
					local BASE_HEIGHT = 45
					local Button = (function()
						local Button = Instance.new("Frame")
						local Info = Instance.new("Frame")
						local Title = Instance.new("TextLabel")
						local ClickDetector = Instance.new("TextButton")
						local Icon = Instance.new("ImageLabel")
						local UIScale = Instance.new("UIScale")
						local UICorner = Instance.new("UICorner")
						local Frame = Instance.new("Frame")

						Button.Name = "Button"
						Button.Parent = ResolveElementParent(self)
						Button.BackgroundColor3 = GetTheme().Primary
						Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Button.BorderSizePixel = 0
						Button.Size = UDim2.new(1, -5, 0, BASE_HEIGHT * CalculateUIScale())
						Info.Name = "Info"
						Info.Parent = Button
						Info.AnchorPoint = Vector2.new(0, 0.5)
						Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Info.BackgroundTransparency = 1
						Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Info.BorderSizePixel = 0
						Info.Position = UDim2.new(0.0299999993, 0, 0.5, 0)
						Info.Size = UDim2.new(0.855000019, 0, 0.649999976, 0)
						Title.FontFace =
							Font.new("rbxassetid://16658221428", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						Title.Text = NameButton
						Title.TextColor3 = Color3.fromRGB(230, 230, 230)
						Title.TextScaled = true
						Title.TextSize = 24
						Title.TextWrapped = true
						Title.TextXAlignment = Enum.TextXAlignment.Left
						Title.Name = "Title"
						Title.Parent = Info
						Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Title.BackgroundTransparency = 1
						Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Title.BorderSizePixel = 0
						Title.Size = UDim2.new(1, 0, 1, 0)
						ClickDetector.FontFace = Font.new(
							"rbxasset://fonts/families/SourceSansPro.json",
							Enum.FontWeight.Regular,
							Enum.FontStyle.Normal
						)
						ClickDetector.Text = ""
						ClickDetector.TextColor3 = Color3.fromRGB(0, 0, 0)
						ClickDetector.TextSize = 14
						ClickDetector.Name = "ClickDetector"
						ClickDetector.Parent = Button
						ClickDetector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						ClickDetector.BackgroundTransparency = 1
						ClickDetector.BorderColor3 = Color3.fromRGB(0, 0, 0)
						ClickDetector.BorderSizePixel = 0
						ClickDetector.Size = UDim2.new(1, 0, 1, 0)
						Icon.Name = "Icon"
						Icon.Parent = Button
						Icon.Image = "rbxassetid://91154801501853"
						Icon.ScaleType = Enum.ScaleType.Fit
						Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Icon.BackgroundTransparency = 1
						Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Icon.BorderSizePixel = 0
						Icon.Position = UDim2.new(0.894811034, 0, 0.183261871, 0)
						Icon.Size = UDim2.new(0, 25, 0, 25)
						UIScale.Scale = 0.8999999761581421
						UIScale.Parent = Icon
						UICorner.CornerRadius = UDim.new(0, 12)
						UICorner.Parent = Button
						Frame.Parent = Button
						Frame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
						Frame.BackgroundTransparency = 1
						Frame.BorderSizePixel = 0
						Frame.Size = UDim2.new(1, 0, 1, 0)
						Frame.ZIndex = 6

						RegisterElementSize(Button, BASE_HEIGHT, "Button")

						return Button
					end)()
					local callMe = get_callback(Config, 2)

					AttachButtonSpring(Button.ClickDetector, Button, function(state, theme)
						if state.down then
							return theme.Button.Hover
						end
						if state.hover then
							return theme.Secondary
						end

						return theme.Primary
					end)
					Button.ClickDetector.Activated:Connect(function()
						if callMe then
							callMe()
						end
					end)

					return { Callback = callMe }
				end
				function Handle:AddLabel(Config)
					local Text = Config[1] or Config.Text or Config.Title or Config.Name or "Label"
					local BASE_HEIGHT = 45
					local Label = (function()
						local Label = Instance.new("Frame")
						local Info = Instance.new("Frame")
						local Title = Instance.new("TextLabel")
						local UICorner = Instance.new("UICorner")

						Label.Name = Text
						Label.Parent = ResolveElementParent(self)
						Label.BackgroundColor3 = GetTheme().Primary
						Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Label.BorderSizePixel = 0
						Label.Size = UDim2.new(1, -5, 0, BASE_HEIGHT * CalculateUIScale())
						Info.Name = "Info"
						Info.Parent = Label
						Info.AnchorPoint = Vector2.new(0, 0.5)
						Info.AutomaticSize = Enum.AutomaticSize.XY
						Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Info.BackgroundTransparency = 1
						Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Info.BorderSizePixel = 0
						Info.Position = UDim2.new(0.0299999993, 0, 0.5, 0)
						Info.Size = UDim2.new(0.975000024, 0, 0.550000012, 0)
						Title.FontFace =
							Font.new("rbxassetid://16658221428", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						Title.Text = Text
						Title.TextColor3 = Color3.fromRGB(255, 255, 255)
						Title.TextScaled = true
						Title.TextWrapped = true
						Title.TextXAlignment = Enum.TextXAlignment.Left
						Title.Name = "Title"
						Title.Parent = Info
						Title.AutomaticSize = Enum.AutomaticSize.XY
						Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Title.BackgroundTransparency = 1
						Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Title.BorderSizePixel = 0
						Title.Size = UDim2.new(1, 0, 1, 0)
						UICorner.CornerRadius = UDim.new(0, 12)
						UICorner.Parent = Label

						RegisterElementSize(Label, BASE_HEIGHT, "Label")

						return Label
					end)()
					local LabelFunctions = {}

					function LabelFunctions:SetTitle(stg)
						Label.Info.Title.Text = stg
					end

					return LabelFunctions
				end
				function Handle:AddLine(Config)
					Config = Config or {}

					local Line = (function()
						local Line = Instance.new("Frame")
						local UICorner = Instance.new("UICorner")

						Line.Name = "Line"
						Line.Parent = ResolveElementParent(self)
						Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Line.BackgroundTransparency = 0.8999999761581421
						Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Line.BorderSizePixel = 0
						Line.ClipsDescendants = true
						Line.Size = UDim2.new(1, 0, 0, 3)
						UICorner.CornerRadius = UDim.new(0, 12)
						UICorner.Parent = Line

						return Line
					end)()

					return Config.ReturnUI and Line or Elements
				end
				function Handle:AddSlider(Config)
					Config = Config or {}
					local Default = Config[2] or Config.Value or Config.Default or 15
					local Minimum = Config[3] or Config.MinValue or Config.Minimum or 1
					local Maximum = Config[4] or Config.MaxValue or Config.Maximum or 100
					local Increase = Config[6] or Config.Increase or 1
					local BASE_HEIGHT = 74
					local Working = false
					local theme = GetTheme()

					local Slider = Instance.new("Frame")
					Slider.Name = "Slider"
					Slider.Parent = ResolveElementParent(self)
					Slider.BackgroundColor3 = theme.Primary
					Slider.BorderSizePixel = 0
					Slider.Position = UDim2.new(0, 0, 0.208, 0)
					Slider.Size = UDim2.new(1, -5, 0, BASE_HEIGHT * CalculateUIScale())
					Slider:SetAttribute("Working", false)
					MakeCorner(Slider, 12)

					local Info = Instance.new("Frame")
					Info.Name = "Info"
					Info.Parent = Slider
					Info.BackgroundTransparency = 1
					Info.Position = UDim2.new(0.0258, 0, 0.1547, 0)
					Info.Size = UDim2.new(0.9665, 0, 0.4285, 0)

					local InfoLayout = Instance.new("UIListLayout")
					InfoLayout.Padding = UDim.new(0, -1)
					InfoLayout.FillDirection = Enum.FillDirection.Horizontal
					InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
					InfoLayout.Parent = Info

					local TitleS = Instance.new("TextLabel")
					TitleS.FontFace =
						Font.new("rbxassetid://16658221428", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					TitleS.Text = Config[1] or Config.Name or Config.Title or "Slider"
					TitleS.TextColor3 = Color3.fromRGB(255, 255, 255)
					TitleS.TextScaled = true
					TitleS.TextWrapped = true
					TitleS.TextXAlignment = Enum.TextXAlignment.Left
					TitleS.Name = "Title"
					TitleS.Parent = Info
					TitleS.BackgroundTransparency = 1
					TitleS.BorderSizePixel = 0
					TitleS.Position = UDim2.new(0, 0, 0.5, 0)
					TitleS.Size = UDim2.new(0.849, 0, 0.9, 0)

					local ValueLabel = Instance.new("TextLabel")
					ValueLabel.FontFace =
						Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					ValueLabel.Text = string.format("%.1f", Default)
					ValueLabel.TextColor3 = theme.Accent
					ValueLabel.TextScaled = true
					ValueLabel.TextWrapped = true
					ValueLabel.Name = "Value"
					ValueLabel.Parent = Info
					ValueLabel.BackgroundTransparency = 1
					ValueLabel.Position = UDim2.new(0.845, 0, 0.5, 0)
					ValueLabel.Size = UDim2.new(0.15, 0, 0.75, 0)
					MakeCorner(Slider, 12)

					local Gutter = Instance.new("CanvasGroup")
					Gutter.Name = "Gutter"
					Gutter.Parent = Slider
					Gutter.BackgroundColor3 = theme.Secondary
					Gutter.BorderSizePixel = 0
					Gutter.Position = UDim2.new(0.026, 0, 0.696, 0)
					Gutter.Size = UDim2.new(0.954, 0, 0.178, 0)
					Gutter.ClipsDescendants = true
					MakeCorner(Gutter)

					local Fill = Instance.new("Frame")
					Fill.Name = "Fill"
					Fill.Parent = Gutter
					Fill.BackgroundColor3 = theme.Accent
					Fill.BorderSizePixel = 0
					Fill.Size = UDim2.new(0.15, 0, 1, 0)
					MakeCorner(Fill)

					local FillGradient = Instance.new("UIGradient")
					FillGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, theme.Accent),
						ColorSequenceKeypoint.new(1, BlendColor(theme.Accent, Color3.fromRGB(255, 255, 255), 0.22)),
					})
					FillGradient.Parent = Fill

					local KnobDot = Instance.new("Frame")
					KnobDot.Name = "KnobDot"
					KnobDot.Parent = Gutter
					KnobDot.AnchorPoint = Vector2.new(0.5, 0.5)
					KnobDot.ZIndex = 2
					KnobDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					KnobDot.BorderSizePixel = 0
					KnobDot.Size = UDim2.fromOffset(10, 10)
					MakeCorner(KnobDot, 5)
					MakeStroke(KnobDot, theme.Accent, 1.5, 0.22)

					RegisterElementSize(Slider, BASE_HEIGHT, "Slider")

					local SliderData = { Connections = {} }

					local function FixFloat(value, step)
						local decimals = 0
						if step < 1 then
							decimals = math.max(0, -math.floor(math.log10(step)))
						end
						local power = 10 ^ decimals
						return math.floor(value * power + 0.5) / power
					end

					SliderData.Callback = get_callback(Config, 5)

					local moveConn

					local function beginDrag(input)
						if
							input.UserInputType ~= Enum.UserInputType.MouseButton1
							and input.UserInputType ~= Enum.UserInputType.Touch
						then
							return
						end
						Working = true
						Slider:SetAttribute("Working", true)
						local function update(px)
							if not Slider.Gutter then
								return
							end
							local x = px or UserInputService:GetMouseLocation().X
							local posX = Slider.Gutter.AbsolutePosition.X
							local width = Slider.Gutter.AbsoluteSize.X
							local rel = math.clamp(x - posX, 0, width)
							local ratio = rel / width
							SliderData:SetValue(Minimum + ratio * (Maximum - Minimum))
						end
						update(input.Position and input.Position.X)
						moveConn = UserInputService.InputChanged:Connect(function(changed)
							if not Working and not Slider:GetAttribute("Working") then
								return
							end
							if
								changed.UserInputType == Enum.UserInputType.MouseMovement
								or changed.UserInputType == Enum.UserInputType.Touch
							then
								update(changed.Position and changed.Position.X)
							end
						end)
						local ended
						ended = input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								Working = false
								Slider:SetAttribute("Working", false)
								if moveConn then
									moveConn:Disconnect()
								end
								ended:Disconnect()
							end
						end)
					end

					SliderData.Connections.MainSliding = Gutter.InputBegan:Connect(beginDrag)
					SliderData.Connections.ChangedText = ValueLabel:GetPropertyChangedSignal("Text"):Connect(function()
						SliderData.Callback(SliderData:GetValue())
					end)

					function SliderData:GetValue()
						return tonumber(Slider.Info.Value.Text)
					end
					function SliderData:SetValue(value)
						local step = Increase or 1
						value = FixFloat(math.floor(((value - Minimum) / step + 0.5)) * step + Minimum, step)
						if step <= 0 then
							step = 1
						end
						value =
							math.clamp(math.floor(((value - Minimum) / step + 0.5)) * step + Minimum, Minimum, Maximum)
						local total = Maximum - Minimum
						local ratio = total > 0 and (value - Minimum) / total or 0
						spr.target(Fill, 0.6, 4, { Size = UDim2.new(ratio, 0, 1, 0) })
						spr.target(KnobDot, 0.6, 4, { Position = UDim2.new(ratio, 0, 0.5, 0) })
						ValueLabel.Text = string.format("%.1f", value)
					end
					function SliderData:Set(value)
						SliderData:SetValue(value)
					end
					function SliderData:SetRange(minValue, maxValue, increaseValue, value)
						local newMin = tonumber(minValue)
						local newMax = tonumber(maxValue)
						local newInc = tonumber(increaseValue)
						if newMin then
							Minimum = newMin
						end
						if newMax then
							Maximum = newMax
						end
						if Maximum < Minimum then
							Minimum, Maximum = Maximum, Minimum
						end
						if newInc and newInc > 0 then
							Increase = newInc
						end
						SliderData:SetValue(value or SliderData:GetValue() or Minimum)
					end

					SliderData:SetValue(Config[2] or Config.Default or 10)
					Library.Features_Table[Slider.Info.Title.Text] = SliderData
					return SliderData
				end
				function Handle:AddToggle(Config)
					local Data = {}

					Data.Toggled = Config[2] or Config.Default or false
					Data.CanClick = true

					local BASE_HEIGHT = 45
					local Toggle = (function()
						local Toggle = Instance.new("Frame")
						local Info = Instance.new("Frame")
						local Title = Instance.new("TextLabel")
						local Toggle_2 = Instance.new("Frame")
						local UICorner = Instance.new("UICorner")
						local Circle = Instance.new("Frame")
						local CircleCorner = Instance.new("UICorner")
						local UICorner_2 = Instance.new("UICorner")
						local ClickDetector = Instance.new("TextButton")
						local Frame = Instance.new("Frame")

						Toggle.Name = "Toggle"
						Toggle.Parent = ResolveElementParent(self)
						Toggle.BackgroundColor3 = GetTheme().Primary
						Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Toggle.BorderSizePixel = 0
						Toggle.Size = UDim2.new(1, -5, 0, BASE_HEIGHT * CalculateUIScale())
						Info.Name = "Info"
						Info.Parent = Toggle
						Info.AnchorPoint = Vector2.new(0, 0.5)
						Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Info.BackgroundTransparency = 1
						Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Info.BorderSizePixel = 0
						Info.Position = UDim2.new(0.0149999997, 0, 0.5, 0)
						Info.Size = UDim2.new(0.964999974, 0, 0.635500014, 0)
						Title.FontFace =
							Font.new("rbxassetid://16658221428", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						Title.RichText = true
						Title.Text = Config and (Config[1] or Config.Name or Config.Title) or "Toggle"
						Title.TextColor3 = Color3.fromRGB(230, 230, 230)
						Title.TextScaled = true
						Title.TextWrapped = true
						Title.TextXAlignment = Enum.TextXAlignment.Left
						Title.Name = "Title"
						Title.Parent = Info
						Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Title.BackgroundTransparency = 1
						Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Title.BorderSizePixel = 0
						Title.Position = UDim2.new(0.0149999997, 0, 0, 0)
						Title.Size = UDim2.new(0.720000029, 0, 1, 0)
						Toggle_2.Name = "Toggle"
						Toggle_2.Parent = Info
						Toggle_2.AnchorPoint = Vector2.new(1, 0.5)
						Toggle_2.BackgroundColor3 = GetTheme().Secondary
						Toggle_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Toggle_2.BorderSizePixel = 0
						Toggle_2.Position = UDim2.new(1, 0, 0.5, 0)
						Toggle_2.Size = UDim2.new(0, 50, 0, 27)
						UICorner.CornerRadius = UDim.new(1, 0)
						UICorner.Parent = Toggle_2
						Circle.Name = "Circle"
						Circle.Parent = Toggle_2
						Circle.AnchorPoint = Vector2.new(0.5, 0.5)
						Circle.BackgroundColor3 = GetTheme().SubText
						Circle.BackgroundTransparency = 0
						Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Circle.BorderSizePixel = 0
						Circle.Position = UDim2.new(0.699999988, 0, 0.5, 0)
						Circle.Size = UDim2.new(0.446999997, 0, 0.786000013, 0)
						CircleCorner.CornerRadius = UDim.new(1, 0)
						CircleCorner.Parent = Circle
						UICorner_2.CornerRadius = UDim.new(0, 12)
						UICorner_2.Parent = Toggle
						ClickDetector.FontFace = Font.new(
							"rbxasset://fonts/families/SourceSansPro.json",
							Enum.FontWeight.Regular,
							Enum.FontStyle.Normal
						)
						ClickDetector.Text = ""
						ClickDetector.TextColor3 = Color3.fromRGB(0, 0, 0)
						ClickDetector.TextSize = 14
						ClickDetector.Name = "ClickDetector"
						ClickDetector.Parent = Toggle
						ClickDetector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						ClickDetector.BackgroundTransparency = 1
						ClickDetector.BorderColor3 = Color3.fromRGB(0, 0, 0)
						ClickDetector.BorderSizePixel = 0
						ClickDetector.Size = UDim2.new(1, 0, 1, 0)
						Frame.Parent = Toggle
						Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
						Frame.BackgroundTransparency = 1
						Frame.BorderSizePixel = 0
						Frame.Size = UDim2.new(1, 0, 1, 0)
						Frame.ZIndex = 6

						RegisterElementSize(Toggle, BASE_HEIGHT, "Toggle")

						return Toggle
					end)()
					local button = Toggle.ClickDetector
					local frame = Toggle.Info.Toggle.Circle
					local Circle_Toggle = frame
					local enabledPosition = UDim2.fromScale(0.7, 0.5)
					local disabledPosition = UDim2.fromScale(0.3, 0.5)
					local Toggle_Track = Toggle.Info.Toggle
					local lastActivation = 0
					local debounce = 0.35

					AttachButtonSpring(button, Toggle, function(state, theme)
						if state.hover then
							return theme.Secondary
						end

						return theme.Primary
					end)

					Data.Toggled = Data.Toggled or false

					button.Activated:Connect(function()
						local currentTime = tick()

						if currentTime - lastActivation < debounce then
							return
						end

						lastActivation = currentTime

						Data:Toggle(not Data.Toggled)
					end)

					Data.Callback = get_callback(Config, 3)

					function Data:CheckToggle()
						return Data.Toggled
					end
					function Data:CaptureControl(toggle)
						Data.CanClick = toggle or not Data.CanClick
					end
					function Data:Toggle(toggle)
						if toggle ~= nil then
							Data.Toggled = toggle
						else
							Data.Toggled = not Data.Toggled
						end

						local theme = GetTheme()
						local offKnob = theme.SubText
						local offTrack = theme.Secondary

						spr.target(Circle_Toggle, 0.6, 4, {
							Position = Data.Toggled and enabledPosition or disabledPosition,
						})
						spr.target(Circle_Toggle, 0.6, 4, {
							BackgroundColor3 = Data.Toggled and theme.Accent or offKnob,
						})
						spr.target(Toggle_Track, 0.6, 4, {
							BackgroundColor3 = Data.Toggled and theme.Secondary or offTrack,
						})
						pcall(task.spawn, Data.Callback, Data.Toggled)
					end
					function Data:Set(value)
						Data:Toggle(value)
					end

					Data:Toggle(Data.Toggled)

					Library.Features_Table[Toggle.Info.Title.Text] = Data

					return Data
				end
				function Handle:AddKeybind(Config)
					local KeybindData = {
						Key = Config and (Config[2] or Config.Key or Config.Bind or Config.Keybind) or "RightShift",
						Changing = false,
						Cooldown = false,
						Connections = {},
					}
					local BASE_HEIGHT = 45
					local KeyBind = (function()
						local KeyBind = Instance.new("Frame")
						local Info = Instance.new("Frame")
						local Title = Instance.new("TextLabel")
						local ClickDetector = Instance.new("TextButton")
						local KeyFrame = Instance.new("Frame")
						local TextLabel = Instance.new("TextLabel")
						local UICorner = Instance.new("UICorner")
						local UICorner_2 = Instance.new("UICorner")
						local Frame = Instance.new("Frame")

						KeyBind.Name = "KeyBind"
						KeyBind.Parent = ResolveElementParent(self)
						KeyBind.BackgroundColor3 = GetTheme().Primary
						KeyBind.BorderColor3 = Color3.fromRGB(0, 0, 0)
						KeyBind.BorderSizePixel = 0
						KeyBind.Size = UDim2.new(1, -5, 0, BASE_HEIGHT * CalculateUIScale())
						Info.Name = "Info"
						Info.Parent = KeyBind
						Info.AnchorPoint = Vector2.new(0, 0.5)
						Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Info.BackgroundTransparency = 1
						Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Info.BorderSizePixel = 0
						Info.Position = UDim2.new(0.0299999993, 0, 0.5, 0)
						Info.Size = UDim2.new(0.699999988, 0, 0.649999976, 0)
						Title.FontFace =
							Font.new("rbxassetid://16658221428", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
						Title.Text = Config and (Config[1] or Config.Name or Config.Title) or "Keybind"
						Title.TextColor3 = Color3.fromRGB(255, 255, 255)
						Title.TextScaled = true
						Title.TextWrapped = true
						Title.TextXAlignment = Enum.TextXAlignment.Left
						Title.Name = "Title"
						Title.Parent = Info
						Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Title.BackgroundTransparency = 1
						Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Title.BorderSizePixel = 0
						Title.Size = UDim2.new(1, 0, 1, 0)
						ClickDetector.FontFace = Font.new(
							"rbxasset://fonts/families/SourceSansPro.json",
							Enum.FontWeight.Regular,
							Enum.FontStyle.Normal
						)
						ClickDetector.Text = ""
						ClickDetector.TextColor3 = Color3.fromRGB(0, 0, 0)
						ClickDetector.TextSize = 14
						ClickDetector.Name = "ClickDetector"
						ClickDetector.Parent = KeyBind
						ClickDetector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						ClickDetector.BackgroundTransparency = 1
						ClickDetector.BorderColor3 = Color3.fromRGB(0, 0, 0)
						ClickDetector.BorderSizePixel = 0
						ClickDetector.Size = UDim2.new(1.03647411, 0, 1.02272725, 0)
						KeyFrame.Name = "KeyFrame"
						KeyFrame.Parent = KeyBind
						KeyFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 17)
						KeyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
						KeyFrame.BorderSizePixel = 0
						KeyFrame.Position = UDim2.new(0.736000061, 0, 0.110606104, 0)
						KeyFrame.Size = UDim2.new(0.224924013, 0, 0.772727251, 0)
						TextLabel.FontFace =
							Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
						TextLabel.Text = KeybindData.Key
						TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
						TextLabel.TextScaled = true
						TextLabel.TextWrapped = true
						TextLabel.Parent = KeyFrame
						TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
						TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						TextLabel.BackgroundTransparency = 1
						TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
						TextLabel.BorderSizePixel = 0
						TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
						TextLabel.Size = UDim2.new(0.870000005, 0, 0.600000024, 0)
						UICorner.Parent = KeyFrame
						UICorner_2.CornerRadius = UDim.new(0, 12)
						UICorner_2.Parent = KeyBind
						Frame.Parent = KeyBind
						Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
						Frame.BackgroundTransparency = 1
						Frame.BorderSizePixel = 0
						Frame.Size = UDim2.new(1, 0, 1, 0)
						Frame.ZIndex = 6

						RegisterElementSize(KeyBind, BASE_HEIGHT, "KeyBind")

						return KeyBind
					end)()
					local Title = KeyBind.Info.Title
					local KeyBind_Main = KeyBind.ClickDetector
					local KeyValue = KeyBind.KeyFrame.TextLabel
					local _cb1, _cb2 = get_callback(Config, 3), get_callback(Config, 4)

					function KeybindData:ChangeKey(key)
						KeybindData.Key = key
					end
					function KeybindData:Set(value)
						KeybindData:ChangeKey(value)
					end

					KeybindData.Blacklisted_Keys = Config.NotAllow or Config.Blacklist or Config[5] or {}

					local tweenHover = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local tweenClick = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

					Library.ConnectionsList[Title.Text .. " Pressed"] = KeyBind_Main.Activated:Connect(function()
						if KeybindData.Cooldown == true then
							return
						end
						if GetDeviceType() == "Mobile" then
							return
						end
						if KeybindData.Changing == true then
							KeyValue.Text = KeybindData.Key
							KeybindData.Changing = false
						else
							KeyValue.Text = "Press any key..."
							KeybindData.Changing = true
						end
					end)

					task.spawn(function()
						Library.ConnectionsList[Title.Text .. " Main Detection"] = UserInputService.InputBegan:Connect(
							function(input, gameProcessed)
								if gameProcessed then
									return
								end
								if input.UserInputType == Enum.UserInputType.MouseButton1 then
									return
								end
								if input.UserInputType == Enum.UserInputType.Touch then
									return
								end
								if KeybindData.Cooldown == true then
									return
								end
								if not KeybindData.Changing then
									if input.KeyCode.Name == Enum.KeyCode[KeybindData.Key].Name then
										task.spawn(_cb1)
									end
								end
							end
						)
						Library.ConnectionsList[Title.Text .. " Main Changed"] = UserInputService.InputBegan:Connect(
							function(input, gameProcessed)
								if gameProcessed then
									return
								end
								if input.UserInputType ~= Enum.UserInputType.Keyboard then
									return
								end
								if input.KeyCode == Enum.KeyCode.Unknown then
									return
								end
								if input.UserInputType == Enum.UserInputType.Touch then
									return
								end
								if KeybindData.Cooldown == true then
									return
								end
								if KeybindData.Changing == true then
									if
										not table.find(
											(Library.Configs or {}).Blacklisted_Keys or {},
											input.KeyCode.Name
										)
										and (not table.find(KeybindData.Blacklisted_Keys, input.KeyCode.Name))
									then
										if input.KeyCode.Name ~= Enum.KeyCode[KeybindData.Key].Name then
											KeybindData.Cooldown = true
											KeybindData.Key = input.KeyCode.Name
											KeyValue.Text = KeybindData.Key

											task.spawn(_cb2, KeybindData.Key)
											task.wait(0.1)

											KeybindData.Changing = false

											task.wait(0.2)

											KeybindData.Cooldown = false
										end
									end
								end
							end
						)
					end)

					Library.Features_Table[KeyBind.Info.Title.Text] = KeybindData
					return KeybindData
				end
				function Handle:AddTextBox(Config)
					local BASE_HEIGHT = 45
					local TextBox = (function()
						local TextBox = Instance.new("Frame")
						local Info = Instance.new("Frame")
						local Title = Instance.new("TextLabel")
						local TextBox_2 = Instance.new("Frame")
						local Input = Instance.new("TextBox")
						local UICorner = Instance.new("UICorner")
						local UICorner_2 = Instance.new("UICorner")

						TextBox.Name = "TextBox"
						TextBox.Parent = ResolveElementParent(self)
						TextBox.BackgroundColor3 = GetTheme().Primary
						TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
						TextBox.BorderSizePixel = 0
						TextBox.Position = UDim2.new(0, 0, 0.108456515, 0)
						TextBox.Size = UDim2.new(1, -5, 0, BASE_HEIGHT * CalculateUIScale())
						Info.Name = "Info"
						Info.Parent = TextBox
						Info.AnchorPoint = Vector2.new(0, 0.5)
						Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Info.BackgroundTransparency = 1
						Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Info.BorderSizePixel = 0
						Info.Position = UDim2.new(0.0299999993, 0, 0.5, 0)
						Info.Size = UDim2.new(0.699999988, 0, 0.649999976, 0)
						Title.FontFace =
							Font.new("rbxassetid://16658221428", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						Title.Text = Config and (Config[1] or Config.Name or Config.Title) or "Textbox"
						Title.TextColor3 = Color3.fromRGB(255, 255, 255)
						Title.TextScaled = true
						Title.TextWrapped = true
						Title.TextXAlignment = Enum.TextXAlignment.Left
						Title.Name = "Title"
						Title.Parent = Info
						Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Title.BackgroundTransparency = 1
						Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Title.BorderSizePixel = 0
						Title.Size = UDim2.new(1, 0, 1, 0)
						TextBox_2.Name = "TextBox"
						TextBox_2.Parent = TextBox
						TextBox_2.BackgroundColor3 = Color3.fromRGB(16, 16, 17)
						TextBox_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
						TextBox_2.BorderSizePixel = 0
						TextBox_2.Position = UDim2.new(0.736000121, 0, 0.13333334, 0)
						TextBox_2.Size = UDim2.new(0.22272025, 0, 0.75555557, 0)
						Input.ClearTextOnFocus = false
						Input.FontFace =
							Font.new("rbxassetid://12187373592", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
						Input.PlaceholderText = Config[2] or Config.Placeholder or ""
						Input.RichText = true
						Input.Text = ""
						Input.TextColor3 = Color3.fromRGB(255, 255, 255)
						Input.TextScaled = true
						Input.TextSize = 14
						Input.TextWrapped = true
						Input.Name = "Input"
						Input.Parent = TextBox_2
						Input.AnchorPoint = Vector2.new(0.5, 0.5)
						Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Input.BackgroundTransparency = 1
						Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
						Input.BorderSizePixel = 0
						Input.Position = UDim2.new(0.5, 0, 0.5, 0)
						Input.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
						UICorner.Parent = TextBox_2
						UICorner_2.CornerRadius = UDim.new(0, 12)
						UICorner_2.Parent = TextBox

						RegisterElementSize(TextBox, BASE_HEIGHT, "TextBox")

						return TextBox
					end)()
					local Input = TextBox.TextBox.Input
					local Title = TextBox.Info.Title
					local TextboxFunctions = {
						Connections = {},
						Callback = get_callback(Config, 3),
					}

					function TextboxFunctions:FireCallback()
						task.spawn(TextboxFunctions.Callback, Input.Text)
					end

					Library.ConnectionsList[Title.Text .. " Focus"] = Input.FocusLost:Connect(function()
						TextboxFunctions:FireCallback()
					end)

					function TextboxFunctions:SetText(text)
						Input.Text = text
					end
					function TextboxFunctions:GetText()
						return Input.Text
					end

					TextboxFunctions:FireCallback()

					Library.Features_Table[TextBox.Info.Title.Text] = TextboxFunctions

					return TextboxFunctions
				end
				function Handle:AddSection(config)
					local SectionName = config[1] or "Section"
					local DescriptionText = config[2] or ""
					local SectionFunctions = {}
					local Section = (function()
						local Section = Instance.new("Frame")
						local UICorner = Instance.new("UICorner")
						local UIListLayout = Instance.new("UIListLayout")
						local UIPadding = Instance.new("UIPadding")
						local Title = Instance.new("TextLabel")
						local Description = Instance.new("TextLabel")

						Section.Name = "Section"
						Section.Parent = ResolveElementParent(self)
						Section.AutomaticSize = Enum.AutomaticSize.Y
						Section.BackgroundColor3 = GetTheme().Primary
						Section.BorderSizePixel = 0
						Section.Size = UDim2.new(1, -5, 0, 0)
						UICorner.CornerRadius = UDim.new(0, 12)
						UICorner.Parent = Section
						UIListLayout.Padding = UDim.new(0, 4)
						UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
						UIListLayout.Parent = Section
						UIPadding.PaddingBottom = UDim.new(0, 6)
						UIPadding.PaddingLeft = UDim.new(0, 20)
						UIPadding.PaddingRight = UDim.new(0, 6)
						UIPadding.PaddingTop = UDim.new(0, 6)
						UIPadding.Parent = Section
						Title.FontFace =
							Font.new("rbxassetid://16658221428", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
						Title.Text = SectionName
						Title.TextColor3 = Color3.fromRGB(255, 255, 255)
						Title.TextSize = 22
						Title.TextXAlignment = Enum.TextXAlignment.Left
						Title.Name = "Title"
						Title.Parent = Section
						Title.AutomaticSize = Enum.AutomaticSize.Y
						Title.BackgroundTransparency = 1
						Title.Size = UDim2.new(1, -10, 0, 0)
						Description.FontFace =
							Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
						Description.Text = DescriptionText:gsub("[/\\]n", "\n")
						Description.TextColor3 = Color3.fromRGB(200, 200, 200)
						Description.TextSize = 20
						Description.TextWrapped = true
						Description.TextXAlignment = Enum.TextXAlignment.Left
						Description.TextYAlignment = Enum.TextYAlignment.Top
						Description.Name = "Description"
						Description.Parent = Section
						Description.AutomaticSize = Enum.AutomaticSize.Y
						Description.BackgroundTransparency = 1
						Description.Size = UDim2.new(1, -10, 0, 0)

						function SectionFunctions:SetTitle(str)
							Title.Text = str
						end
						function SectionFunctions:SetDescription(str)
							Description.Text = str:gsub("[/\\]n", "\n")
						end

						return Section
					end)()

					return SectionFunctions
				end
				function Handle:AddCredits(developers, config)
					config = config or {}
					developers = developers or {}

					local sectionTitle = config.Title or "Credits"
					local collapsible = config.Collapsible ~= false
					local theme = GetTheme()

					local function parseUserId(url)
						if type(url) ~= "string" then
							return nil
						end
						return tonumber(url:match("/users/(%d+)/"))
					end

					local root = Instance.new("Frame")
					root.Name = "Credits"
					root.Parent = ResolveElementParent(self)
					root.AutomaticSize = Enum.AutomaticSize.Y
					root.BackgroundColor3 = theme.Primary
					root.BorderSizePixel = 0
					root.Size = UDim2.new(1, -5, 0, 0)
					MakeCorner(root, 10)
					MakeStroke(root, theme.Accent, 1, 0.60)

					local rootLayout = Instance.new("UIListLayout")
					rootLayout.Padding = UDim.new(0, 0)
					rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
					rootLayout.Parent = root

					local header = Instance.new("Frame")
					header.Name = "Header"
					header.Parent = root
					header.BackgroundColor3 = theme.Secondary
					header.BorderSizePixel = 0
					header.Size = UDim2.new(1, 0, 0, 36)
					header.LayoutOrder = 0
					header.ClipsDescendants = false

					local headerCorner = Instance.new("UICorner")
					headerCorner.CornerRadius = UDim.new(0, 10)
					headerCorner.Parent = header

					local accentBar = Instance.new("Frame")
					accentBar.Name = "AccentBar"
					accentBar.Parent = header
					accentBar.Size = UDim2.new(1, 0, 0, 2)
					accentBar.Position = UDim2.fromOffset(0, 0)
					accentBar.BackgroundColor3 = theme.Accent
					accentBar.BorderSizePixel = 0
					accentBar.ZIndex = 2
					do
						local g = Instance.new("UIGradient")
						g.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, theme.Accent),
							ColorSequenceKeypoint.new(0.5, BlendColor(theme.Accent, theme.Text, 0.30)),
							ColorSequenceKeypoint.new(1, theme.Accent),
						})
						g.Parent = accentBar
					end
					do
						local c = Instance.new("UICorner")
						c.CornerRadius = UDim.new(0, 10)
						c.Parent = accentBar
					end

					local headerIcon = Instance.new("ImageLabel")
					headerIcon.Name = "Icon"
					headerIcon.Parent = header
					headerIcon.AnchorPoint = Vector2.new(0, 0.5)
					headerIcon.Position = UDim2.new(0, 12, 0.5, 0)
					headerIcon.Size = UDim2.fromOffset(14, 14)
					headerIcon.BackgroundTransparency = 1
					headerIcon.ImageColor3 = theme.Accent
					headerIcon.ScaleType = Enum.ScaleType.Fit
					do
						local ok, ic = pcall(Lucide.GetAsset, "users")
						if ok and ic then
							headerIcon.Image = ic.Url
							headerIcon.ImageRectSize = ic.ImageRectSize
							headerIcon.ImageRectOffset = ic.ImageRectOffset
						end
					end

					local headerTitle = Instance.new("TextLabel")
					headerTitle.Name = "Title"
					headerTitle.Parent = header
					headerTitle.BackgroundTransparency = 1
					headerTitle.Position = UDim2.new(0, 32, 0, 0)
					headerTitle.Size = UDim2.new(1, -64, 1, 0)
					headerTitle.Text = sectionTitle
					headerTitle.TextColor3 = theme.Text
					headerTitle.Font = Enum.Font.GothamBold
					headerTitle.TextSize = 13
					headerTitle.TextXAlignment = Enum.TextXAlignment.Left

					local countBadge = Instance.new("Frame")
					countBadge.Name = "CountBadge"
					countBadge.Parent = header
					countBadge.AnchorPoint = Vector2.new(1, 0.5)
					countBadge.Position = UDim2.new(1, collapsible and -38 or -10, 0.5, 0)
					countBadge.Size = UDim2.fromOffset(22, 18)
					countBadge.BackgroundColor3 = BlendColor(theme.Accent, theme.Secondary, 0.72)
					countBadge.BorderSizePixel = 0
					local countCornerbadge = Instance.new("UICorner")
					countCornerbadge.CornerRadius = UDim.new(0, 10)
					countCornerbadge.Parent = countBadge

					local countLbl = Instance.new("TextLabel")
					countLbl.Parent = countBadge
					countLbl.Size = UDim2.fromScale(1, 1)
					countLbl.BackgroundTransparency = 1
					countLbl.Text = tostring(#developers)
					countLbl.TextColor3 = theme.Text
					countLbl.Font = Enum.Font.GothamBold
					countLbl.TextSize = 10
					countLbl.TextXAlignment = Enum.TextXAlignment.Center

					local isExpanded = true
					local toggleBtn = nil

					if collapsible then
						toggleBtn = Instance.new("TextButton")
						toggleBtn.Name = "CollapseBtn"
						toggleBtn.Parent = header
						toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
						toggleBtn.Position = UDim2.new(1, -6, 0.5, 0)
						toggleBtn.Size = UDim2.fromOffset(24, 24)
						toggleBtn.BackgroundColor3 = theme.Primary
						toggleBtn.BorderSizePixel = 0
						toggleBtn.Text = ""
						toggleBtn.AutoButtonColor = false
						toggleBtn.ZIndex = 3
						local toggleBtnCorner = Instance.new("UICorner")
						toggleBtnCorner.CornerRadius = UDim.new(0, 10)
						toggleBtnCorner.Parent = toggleBtn
						MakeStroke(toggleBtn, theme.Accent, 1, 0.55)

						local chevronCollapse = Instance.new("ImageLabel")
						chevronCollapse.Name = "Chevron"
						chevronCollapse.Parent = toggleBtn
						chevronCollapse.AnchorPoint = Vector2.new(0.5, 0.5)
						chevronCollapse.Position = UDim2.fromScale(0.5, 0.5)
						chevronCollapse.Size = UDim2.fromOffset(10, 10)
						chevronCollapse.BackgroundTransparency = 1
						chevronCollapse.ImageColor3 = theme.SubText
						chevronCollapse.ScaleType = Enum.ScaleType.Fit
						do
							local ok, ic = pcall(Lucide.GetAsset, "chevron-up")
							if ok and ic then
								chevronCollapse.Image = ic.Url
								chevronCollapse.ImageRectSize = ic.ImageRectSize
								chevronCollapse.ImageRectOffset = ic.ImageRectOffset
							end
						end

						MakePressSpring(toggleBtn, toggleBtn, function(state, t)
							if state.down then
								return BlendColor(t.Primary, t.Accent, 0.12)
							end
							if state.hover then
								return BlendColor(t.Primary, t.Secondary, 0.55)
							end
							return t.Primary
						end)
					end

					local cardsShell = Instance.new("Frame")
					cardsShell.Name = "CardsShell"
					cardsShell.Parent = root
					cardsShell.AutomaticSize = Enum.AutomaticSize.Y
					cardsShell.BackgroundTransparency = 1
					cardsShell.BorderSizePixel = 0
					cardsShell.Size = UDim2.new(1, 0, 0, 0)
					cardsShell.LayoutOrder = 1
					cardsShell.ClipsDescendants = false

					local cardsInner = Instance.new("Frame")
					cardsInner.Name = "Inner"
					cardsInner.Parent = cardsShell
					cardsInner.AutomaticSize = Enum.AutomaticSize.Y
					cardsInner.BackgroundTransparency = 1
					cardsInner.BorderSizePixel = 0
					cardsInner.Size = UDim2.new(1, 0, 0, 0)

					local cardsLayout = Instance.new("UIListLayout")
					cardsLayout.Padding = UDim.new(0, 1)
					cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
					cardsLayout.Parent = cardsInner

					local cardsPadding = Instance.new("UIPadding")
					cardsPadding.PaddingLeft = UDim.new(0, 0)
					cardsPadding.PaddingRight = UDim.new(0, 0)
					cardsPadding.PaddingTop = UDim.new(0, 4)
					cardsPadding.PaddingBottom = UDim.new(0, 6)
					cardsPadding.Parent = cardsInner

					for idx, dev in ipairs(developers) do
						local devName = tostring(dev[1] or dev.Name or "Unknown")
						local devRole = tostring(dev[2] or dev.Role or dev.Description or "")
						local devProfile = tostring(dev[3] or dev.Profile or dev.Url or "")
						local userId = parseUserId(devProfile)
						local isLast = idx == #developers

						local card = Instance.new("Frame")
						card.Name = "DevCard_" .. idx
						card.Parent = cardsInner
						card.BackgroundColor3 = theme.Primary
						card.BackgroundTransparency = 1
						card.BorderSizePixel = 0
						card.Size = UDim2.new(1, 0, 0, 52)
						card.LayoutOrder = idx
						card.ClipsDescendants = false

						if not isLast then
							local divider = Instance.new("Frame")
							divider.Name = "Divider"
							divider.Parent = card
							divider.AnchorPoint = Vector2.new(0, 1)
							divider.Position = UDim2.new(0, 58, 1, 0)
							divider.Size = UDim2.new(1, -68, 0, 1)
							divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							divider.BackgroundTransparency = 0.90
							divider.BorderSizePixel = 0
						end

						local avatarFrame = Instance.new("Frame")
						avatarFrame.Name = "AvatarFrame"
						avatarFrame.Parent = card
						avatarFrame.AnchorPoint = Vector2.new(0, 0.5)
						avatarFrame.Position = UDim2.new(0, 12, 0.5, 0)
						avatarFrame.Size = UDim2.fromOffset(36, 36)
						avatarFrame.BackgroundColor3 = theme.Secondary
						avatarFrame.BorderSizePixel = 0
						MakeCorner(avatarFrame, 18)
						MakeStroke(avatarFrame, theme.Accent, 1.5, 0.50)

						local avatarImg = Instance.new("ImageLabel")
						avatarImg.Parent = avatarFrame
						avatarImg.Size = UDim2.fromScale(1, 1)
						avatarImg.BackgroundTransparency = 1
						avatarImg.ScaleType = Enum.ScaleType.Crop
						avatarImg.Image = userId
								and string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", userId)
							or "rbxasset://textures/ui/GuiImagePlaceholder.png"
						MakeCorner(avatarImg, 18)

						local idxDot = Instance.new("Frame")
						idxDot.Name = "IndexDot"
						idxDot.Parent = avatarFrame
						idxDot.AnchorPoint = Vector2.new(1, 1)
						idxDot.Position = UDim2.fromScale(1, 1)
						idxDot.Size = UDim2.fromOffset(14, 14)
						idxDot.BackgroundColor3 = theme.Accent
						idxDot.BorderSizePixel = 0
						idxDot.ZIndex = 2
						MakeCorner(idxDot, 7)

						local idxLbl = Instance.new("TextLabel")
						idxLbl.Parent = idxDot
						idxLbl.Size = UDim2.fromScale(1, 1)
						idxLbl.BackgroundTransparency = 1
						idxLbl.Text = tostring(idx)
						idxLbl.TextColor3 = GetContrastTextColor(theme.Accent)
						idxLbl.Font = Enum.Font.GothamBold
						idxLbl.TextSize = 8
						idxLbl.TextXAlignment = Enum.TextXAlignment.Center
						idxLbl.ZIndex = 3

						local nameLbl = Instance.new("TextLabel")
						nameLbl.Parent = card
						nameLbl.BackgroundTransparency = 1
						nameLbl.Position = UDim2.new(0, 56, 0, 8)
						nameLbl.Size = UDim2.new(1, devProfile ~= "" and -116 or -68, 0, 18)
						nameLbl.Text = devName
						nameLbl.TextColor3 = theme.Text
						nameLbl.Font = Enum.Font.GothamBold
						nameLbl.TextSize = 13
						nameLbl.TextXAlignment = Enum.TextXAlignment.Left
						nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

						local roleLbl = Instance.new("TextLabel")
						roleLbl.Parent = card
						roleLbl.BackgroundTransparency = 1
						roleLbl.Position = UDim2.new(0, 56, 0, 27)
						roleLbl.Size = UDim2.new(1, devProfile ~= "" and -116 or -68, 0, 16)
						roleLbl.Text = devRole
						roleLbl.TextColor3 = theme.SubText
						roleLbl.Font = Enum.Font.Gotham
						roleLbl.TextSize = 11
						roleLbl.TextXAlignment = Enum.TextXAlignment.Left
						roleLbl.TextTruncate = Enum.TextTruncate.AtEnd

						if devProfile ~= "" then
							local profileBtn = Instance.new("TextButton")
							profileBtn.Name = "ProfileBtn"
							profileBtn.Parent = card
							profileBtn.AnchorPoint = Vector2.new(1, 0.5)
							profileBtn.Position = UDim2.new(1, -10, 0.5, 0)
							profileBtn.Size = UDim2.fromOffset(56, 24)
							profileBtn.BackgroundColor3 = BlendColor(theme.Accent, theme.Primary, 0.74)
							profileBtn.BorderSizePixel = 0
							profileBtn.Text = "Profile"
							profileBtn.TextColor3 = theme.Text
							profileBtn.AutoButtonColor = false
							profileBtn.Font = Enum.Font.GothamBold
							profileBtn.TextSize = 10
							profileBtn.ZIndex = 2
							MakeCorner(profileBtn, 6)
							MakeStroke(profileBtn, theme.Accent, 1, 0.38)

							MakePressSpring(profileBtn, profileBtn, function(state, t)
								if state.down then
									return t.Accent
								end
								if state.hover then
									return BlendColor(t.Accent, t.Primary, 0.48)
								end
								return BlendColor(t.Accent, t.Primary, 0.74)
							end)

							profileBtn.Activated:Connect(function()
								pcall(function()
									setclipboard(devProfile)
								end)
								pcall(function()
									Clipboard.set(devProfile)
								end)
								Library:SendNotification({
									Title = devName,
									Description = "Profile URL copied to clipboard.",
									Duration = 3,
									Type = "success",
								})
							end)
						end

						card.MouseEnter:Connect(function()
							spr.target(card, 0.6, 6, {
								BackgroundColor3 = GetTheme().Secondary,
								BackgroundTransparency = 0.55,
							})
						end)
						card.MouseLeave:Connect(function()
							spr.target(card, 0.6, 6, { BackgroundTransparency = 1 })
						end)
					end

					if collapsible and toggleBtn then
						local chevronImg = toggleBtn:FindFirstChild("Chevron")

						local function setExpanded(state)
							isExpanded = state
							cardsShell.Visible = isExpanded
							if chevronImg then
								spr.target(chevronImg, 0.65, 5, {
									Rotation = isExpanded and 0 or 180,
								})
							end
						end

						toggleBtn.Activated:Connect(function()
							setExpanded(not isExpanded)
						end)

						setExpanded(true)
					end

					local CF = {}

					function CF:SetTitle(text)
						headerTitle.Text = tostring(text or "")
					end

					function CF:SetExpanded(state)
						if collapsible then
							cardsShell.Visible = state ~= false
							isExpanded = state ~= false
							local chevronImg = toggleBtn and toggleBtn:FindFirstChild("Chevron")
							if chevronImg then
								spr.target(chevronImg, 0.65, 5, { Rotation = isExpanded and 0 or 180 })
							end
						end
					end

					function CF:Show()
						root.Visible = true
					end
					function CF:Hide()
						root.Visible = false
					end

					return CF
				end
				function Handle:AddElementsSection(config)
					config = config or {}
					local SectionName = config[1] or config.Title or config.Name or "Section"
					local DescriptionText = config[2] or config.Description or ""
					local sectionVisible = config.Visible ~= false
					local sectionCollapsible = config.Collapsible ~= false
					local elementsVisible = sectionCollapsible and (config.ElementsVisible ~= false) or true
					local sectionIcon = config.Icon or "layers-2"

					local theme = GetTheme()

					local Section = Instance.new("Frame")
					Section.Name = "ElementsSection"
					Section.Parent = ResolveElementParent(self)
					Section.AutomaticSize = Enum.AutomaticSize.Y
					Section.BackgroundColor3 = theme.Primary
					Section.BorderSizePixel = 0
					Section.Size = UDim2.new(1, -5, 0, 0)
					Section.Visible = sectionVisible
					MakeCorner(Section, 12)

					local RootLayout = Instance.new("UIListLayout")
					RootLayout.Padding = UDim.new(0, 5)
					RootLayout.SortOrder = Enum.SortOrder.LayoutOrder
					RootLayout.Parent = Section

					local RootPadding = Instance.new("UIPadding")
					RootPadding.PaddingBottom = UDim.new(0, 8)
					RootPadding.PaddingLeft = UDim.new(0, 7)
					RootPadding.PaddingRight = UDim.new(0, 7)
					RootPadding.PaddingTop = UDim.new(0, 7)
					RootPadding.Parent = Section

					local Header = Instance.new("Frame")
					Header.Name = "Header"
					Header.Parent = Section
					Header.AutomaticSize = Enum.AutomaticSize.Y
					Header.BackgroundColor3 = theme.Secondary
					Header.BorderSizePixel = 0
					Header.Size = UDim2.new(1, 0, 0, 0)
					Header.ClipsDescendants = false
					MakeCorner(Header, 10)

					local HeaderLayout = Instance.new("UIListLayout")
					HeaderLayout.Padding = UDim.new(0, 3)
					HeaderLayout.SortOrder = Enum.SortOrder.LayoutOrder
					HeaderLayout.Parent = Header

					local HeaderPadding = Instance.new("UIPadding")
					HeaderPadding.PaddingBottom = UDim.new(0, 8)
					HeaderPadding.PaddingLeft = UDim.new(0, 10)
					HeaderPadding.PaddingRight = UDim.new(0, 10)
					HeaderPadding.PaddingTop = UDim.new(0, 8)
					HeaderPadding.Parent = Header

					local TitleRow = Instance.new("Frame")
					TitleRow.Name = "TitleRow"
					TitleRow.Parent = Header
					TitleRow.BackgroundTransparency = 1
					TitleRow.Size = UDim2.new(1, 0, 0, 28)

					local SectionIconImg = Instance.new("ImageLabel")
					SectionIconImg.Name = "SectionIcon"
					SectionIconImg.Parent = TitleRow
					SectionIconImg.AnchorPoint = Vector2.new(0, 0.5)
					SectionIconImg.Position = UDim2.new(0, 0, 0.5, 0)
					SectionIconImg.Size = UDim2.fromOffset(14, 14)
					SectionIconImg.BackgroundTransparency = 1
					SectionIconImg.ImageColor3 = theme.Accent
					SectionIconImg.ScaleType = Enum.ScaleType.Fit
					SectionIconImg.ZIndex = 2
					do
						local ok, ic = pcall(Lucide.GetAsset, sectionIcon)
						if ok and ic then
							SectionIconImg.Image = ic.Url
							SectionIconImg.ImageRectSize = ic.ImageRectSize
							SectionIconImg.ImageRectOffset = ic.ImageRectOffset
						end
					end

					local Title = Instance.new("TextLabel")
					Title.Name = "Title"
					Title.Parent = TitleRow
					Title.BackgroundTransparency = 1
					Title.Position = UDim2.new(0, 20, 0, 0)
					Title.Size = UDim2.new(1, sectionCollapsible and -56 or -20, 1, 0)
					Title.FontFace = Font.new("rbxassetid://16658221428", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
					Title.Text = SectionName
					Title.TextColor3 = theme.Text
					Title.TextSize = 14
					Title.TextWrapped = true
					Title.TextXAlignment = Enum.TextXAlignment.Left

					local ToggleButton = Instance.new("TextButton")
					ToggleButton.Name = "ToggleButton"
					ToggleButton.Parent = TitleRow
					ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
					ToggleButton.Position = UDim2.new(1, 0, 0.5, 0)
					ToggleButton.Size = UDim2.new(0, 26, 0, 26)
					ToggleButton.AutoButtonColor = false
					ToggleButton.BackgroundColor3 = theme.Primary
					ToggleButton.BorderSizePixel = 0
					ToggleButton.Text = ""
					ToggleButton.Visible = sectionCollapsible
					MakeCorner(ToggleButton, 8)
					MakeStroke(ToggleButton, theme.Accent, 1, 0.55)

					local ChevronCollapseIcon = Instance.new("ImageLabel")
					ChevronCollapseIcon.Name = "ChevronIcon"
					ChevronCollapseIcon.Parent = ToggleButton
					ChevronCollapseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
					ChevronCollapseIcon.Position = UDim2.fromScale(0.5, 0.5)
					ChevronCollapseIcon.Size = UDim2.fromOffset(11, 11)
					ChevronCollapseIcon.BackgroundTransparency = 1
					ChevronCollapseIcon.ImageColor3 = theme.SubText
					ChevronCollapseIcon.ScaleType = Enum.ScaleType.Fit
					ChevronCollapseIcon.ZIndex = 2
					do
						local ok, ic = pcall(Lucide.GetAsset, "chevron-up")
						if ok and ic then
							ChevronCollapseIcon.Image = ic.Url
							ChevronCollapseIcon.ImageRectSize = ic.ImageRectSize
							ChevronCollapseIcon.ImageRectOffset = ic.ImageRectOffset
						end
					end

					local Description = Instance.new("TextLabel")
					Description.Name = "Description"
					Description.Parent = Header
					Description.AutomaticSize = Enum.AutomaticSize.Y
					Description.BackgroundTransparency = 1
					Description.Size = UDim2.new(1, 0, 0, 0)
					Description.FontFace =
						Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					Description.Text = tostring(DescriptionText):gsub("[/\\]n", "\n")
					Description.TextColor3 = Color3.fromRGB(180, 180, 180)
					Description.TextSize = 18
					Description.TextWrapped = true
					Description.TextXAlignment = Enum.TextXAlignment.Left
					Description.TextYAlignment = Enum.TextYAlignment.Top
					Description.Visible = Description.Text ~= ""

					local ContentShell = Instance.new("Frame")
					ContentShell.Name = "ContentShell"
					ContentShell.Parent = Section
					ContentShell.AutomaticSize = Enum.AutomaticSize.Y
					ContentShell.BackgroundColor3 = BlendColor(theme.Secondary, theme.Primary, 0.55)
					ContentShell.BorderSizePixel = 0
					ContentShell.Size = UDim2.new(1, 0, 0, 0)
					ContentShell.Visible = elementsVisible
					MakeCorner(ContentShell, 10)

					local Content = Instance.new("Frame")
					Content.Name = "Content"
					Content.Parent = ContentShell
					Content.AutomaticSize = Enum.AutomaticSize.Y
					Content.BackgroundTransparency = 1
					Content.Size = UDim2.new(1, 0, 0, 0)

					local ContentLayout = Instance.new("UIListLayout")
					ContentLayout.Padding = UDim.new(0, 5)
					ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
					ContentLayout.Parent = Content

					local ContentPadding = Instance.new("UIPadding")
					ContentPadding.PaddingBottom = UDim.new(0, 7)
					ContentPadding.PaddingLeft = UDim.new(0, 7)
					ContentPadding.PaddingRight = UDim.new(0, 7)
					ContentPadding.PaddingTop = UDim.new(0, 7)
					ContentPadding.Parent = Content

					local function SetElementsVisible(state)
						elementsVisible = state ~= false
						if sectionCollapsible then
							if elementsVisible then
								ContentShell.Visible = true
								spr.target(ContentShell, 0.72, 7, { BackgroundTransparency = 0 })
							else
								spr.target(ContentShell, 0.72, 7, { BackgroundTransparency = 1 })
								task.delay(0.14, function()
									if not elementsVisible then
										ContentShell.Visible = false
									end
								end)
							end
						else
							ContentShell.Visible = elementsVisible
						end
						local chevron = ToggleButton:FindFirstChild("ChevronIcon")
						if chevron then
							spr.target(chevron, 0.65, 6, { Rotation = elementsVisible and 0 or 180 })
						end
					end

					if sectionCollapsible then
						AttachButtonSpring(ToggleButton, ToggleButton, function(state, t)
							if state.down then
								return t.Primary
							end
							if state.hover then
								return BlendColor(t.Primary, t.Accent, 0.18)
							end
							return t.Primary
						end)
						ToggleButton.Activated:Connect(function()
							SetElementsVisible(not elementsVisible)
						end)
					end

					SetElementsVisible(elementsVisible)

					local SectionHandle = {
						__ElementMountParent = Content,
						Section = Section,
						Content = Content,
						ContentShell = ContentShell,
						Header = Header,
						ToggleButton = ToggleButton,
					}

					function SectionHandle:SetTitle(value)
						Title.Text = tostring(value or "")
					end
					function SectionHandle:SetDescription(value)
						Description.Text = tostring(value or ""):gsub("[/\\]n", "\n")
						Description.Visible = Description.Text ~= ""
					end
					function SectionHandle:SetVisible(state)
						Section.Visible = state ~= false
					end
					function SectionHandle:Show()
						self:SetVisible(true)
					end
					function SectionHandle:Hide()
						self:SetVisible(false)
					end
					function SectionHandle:SetElementsVisible(state)
						SetElementsVisible(state)
					end
					function SectionHandle:ToggleElements(state)
						if state == nil then
							state = not elementsVisible
						end
						SetElementsVisible(state)
						return elementsVisible
					end
					function SectionHandle:ShowElements()
						SetElementsVisible(true)
					end
					function SectionHandle:HideElements()
						SetElementsVisible(false)
					end

					return setmetatable(SectionHandle, { __index = Handle })
				end
				function Handle:AddInformation(config)
					local messageText = config[1] or "No changelog message"
					local versionText = config[2] or "v0.00"
					local showUserInfo = config.ShowUserInfo

					if showUserInfo == nil then
						showUserInfo = true
					end

					local function getRoleForInfo()
						if IsOwner(lp) then
							return "Owner"
						elseif IsVanishTeam(lp) then
							return "Developer"
						elseif IsTester(lp) then
							return "Tester"
						end

						return "Member"
					end
					local function getPlatformForInfo()
						if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
							return "Mobile"
						elseif UserInputService.KeyboardEnabled then
							return "PC"
						elseif UserInputService.GamepadEnabled then
							return "Console"
						end

						return "Unknown"
					end
					local function getExecutorForInfo()
						if identifyexecutor then
							return identifyexecutor()
						elseif syn then
							return "Synapse X"
						elseif KRNL_LOADED then
							return "Krnl"
						elseif fluxus then
							return "Fluxus"
						elseif is_sirhurt_closure then
							return "SirHurt"
						elseif OXYGEN then
							return "Oxygen U"
						end

						return "Unknown"
					end
					local function buildUserInfoText()
						return table.concat({
							"Username: " .. tostring(lp and lp.Name or "Unknown"),
							"User ID: " .. tostring(lp and lp.UserId or "Unknown"),
							"Platform: " .. getPlatformForInfo(),
							"Script Role: " .. getRoleForInfo(),
							"Executor: " .. getExecutorForInfo(),
							"Place ID: " .. tostring(game.PlaceId),
							"Job ID: " .. tostring(game.JobId),
						}, "\n")
					end

					local InformationFrame = Instance.new("Frame")

					InformationFrame.Size = UDim2.new(1, -5, 0, 0)
					InformationFrame.BackgroundTransparency = 1
					InformationFrame.Name = "Information"
					InformationFrame.BorderSizePixel = 0
					InformationFrame.AutomaticSize = Enum.AutomaticSize.Y
					InformationFrame.Parent = ResolveElementParent(self)

					local Background = Instance.new("Frame")

					Background.Size = UDim2.new(1, 0, 1, 0)
					Background.BackgroundColor3 = GetTheme().Secondary
					Background.BackgroundTransparency = 0.3
					Background.BorderSizePixel = 0
					Background.Parent = InformationFrame
					Background.Name = "BackgroundFrame"

					local UICorner = Instance.new("UICorner")

					UICorner.CornerRadius = UDim.new(0, 12)
					UICorner.Parent = Background

					local UIStroke = Instance.new("UIStroke")

					UIStroke.Color = Color3.fromRGB(60, 60, 65)
					UIStroke.Transparency = 0.5
					UIStroke.Thickness = 1
					UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					UIStroke.Parent = Background

					local ContentFrame = Instance.new("Frame")

					ContentFrame.Size = UDim2.new(1, 0, 1, 0)
					ContentFrame.BackgroundTransparency = 1
					ContentFrame.Parent = InformationFrame

					local UIListLayout = Instance.new("UIListLayout")

					UIListLayout.Padding = UDim.new(0, 10)
					UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					UIListLayout.Parent = ContentFrame

					local UIPadding = Instance.new("UIPadding")

					UIPadding.PaddingTop = UDim.new(0, 14)
					UIPadding.PaddingBottom = UDim.new(0, 14)
					UIPadding.PaddingRight = UDim.new(0, 14)
					UIPadding.PaddingLeft = UDim.new(0, 14)
					UIPadding.Parent = ContentFrame

					local HeaderFrame = Instance.new("Frame")

					HeaderFrame.Size = UDim2.new(1, 0, 0, 28)
					HeaderFrame.BackgroundTransparency = 1
					HeaderFrame.LayoutOrder = 1
					HeaderFrame.Parent = ContentFrame

					local TitleLabel = Instance.new("TextLabel")

					TitleLabel.Size = UDim2.new(0.72, 0, 1, 0)
					TitleLabel.BackgroundTransparency = 1
					TitleLabel.Text = "Change Logs"
					TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					TitleLabel.Font = Enum.Font.GothamBold
					TitleLabel.TextScaled = true
					TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
					TitleLabel.Parent = HeaderFrame
					TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
					TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)

					local TitleGradient = Instance.new("UIGradient")
					TitleGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, GetTheme().Accent),
						ColorSequenceKeypoint.new(1, BlendColor(GetTheme().Text, GetTheme().Accent, 0.28)),
					})
					TitleGradient.Rotation = 0
					TitleGradient.Parent = TitleLabel

					local VersionBadge = Instance.new("Frame")
					VersionBadge.Name = "VersionBadge"
					VersionBadge.Size = UDim2.new(0, 0, 0, 22)
					VersionBadge.AutomaticSize = Enum.AutomaticSize.X
					VersionBadge.AnchorPoint = Vector2.new(1, 0.5)
					VersionBadge.Position = UDim2.new(1, 0, 0.5, 0)
					VersionBadge.BackgroundColor3 = BlendColor(GetTheme().Accent, GetTheme().Secondary, 0.15)
					VersionBadge.BackgroundTransparency = 0.55
					VersionBadge.BorderSizePixel = 0
					VersionBadge.Parent = HeaderFrame

					local VersionBadgeCorner = Instance.new("UICorner")
					VersionBadgeCorner.CornerRadius = UDim.new(1, 0)
					VersionBadgeCorner.Parent = VersionBadge

					local VersionBadgeStroke = Instance.new("UIStroke")
					VersionBadgeStroke.Color = GetTheme().Accent
					VersionBadgeStroke.Thickness = 1
					VersionBadgeStroke.Transparency = 0.55
					VersionBadgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					VersionBadgeStroke.Parent = VersionBadge

					local VersionBadgePadding = Instance.new("UIPadding")
					VersionBadgePadding.PaddingLeft = UDim.new(0, 8)
					VersionBadgePadding.PaddingRight = UDim.new(0, 8)
					VersionBadgePadding.Parent = VersionBadge

					local VersionLabel = Instance.new("TextLabel")
					VersionLabel.Name = "VersionLabel"
					VersionLabel.Size = UDim2.new(0, 0, 1, 0)
					VersionLabel.AutomaticSize = Enum.AutomaticSize.X
					VersionLabel.Position = UDim2.new(0, 0, 0, 0)
					VersionLabel.BackgroundTransparency = 1
					VersionLabel.Text = versionText
					VersionLabel.TextColor3 = GetTheme().Accent
					VersionLabel.Font = Enum.Font.GothamBold
					VersionLabel.TextSize = 13
					VersionLabel.TextXAlignment = Enum.TextXAlignment.Center
					VersionLabel.Parent = VersionBadge

					local Line = Instance.new("Frame")

					Line.Size = UDim2.new(1, 0, 0, 1)
					Line.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
					Line.BackgroundTransparency = 0.3
					Line.BorderSizePixel = 0
					Line.LayoutOrder = 2
					Line.Parent = ContentFrame

					local function FormatChangelog(text)
						text = text:gsub("\r\n", "\n")
						text = text:gsub("[/\\]n", "\n")

						local theme = GetTheme()
						local accentHex = string.format(
							"%02X%02X%02X",
							math.floor(theme.Accent.R * 255),
							math.floor(theme.Accent.G * 255),
							math.floor(theme.Accent.B * 255)
						)

						local COLOR_ADD = "aaddaa"
						local COLOR_CHANGE = "e0c97a"
						local COLOR_REMOVE = "dd8888"
						local COLOR_HEADER = accentHex
						local COLOR_PIPE = "555566"
						local COLOR_TEXT = "c8c8cc"

						local lines = {}
						for line in (text .. "\n"):gmatch("([^\n]*)\n") do
							table.insert(lines, line)
						end

						local result = {}
						local i = 1

						while i <= #lines do
							local line = lines[i]
							line = line:match("^(.-)%s*$") or line

							local catName = line:match("^%[%s*(.-)%s*%]%s*$")
							if catName then
								if #result > 0 then
									table.insert(result, "")
								end
								table.insert(
									result,
									'<font color="#' .. COLOR_HEADER .. '"><b>[ ' .. catName .. " ]</b></font>"
								)
								i = i + 1
								while i <= #lines do
									local entryLine = lines[i]
									entryLine = entryLine:match("^(.-)%s*$") or entryLine

									if entryLine == "" then
										local j = i + 1
										while j <= #lines and (lines[j]:match("^%s*$")) do
											j = j + 1
										end
										local nextLine = lines[j] or ""
										if nextLine:match("^|") then
											i = j
										else
											break
										end
									elseif entryLine:match("^|%-") then
										local tag, rest = entryLine:match("^|%-%[([^%]]+)%]%s*(.*)")
										if tag then
											local color, icon
											if tag == "+" then
												color = COLOR_ADD
												icon = "+"
											elseif tag == "x" or tag == "X" then
												color = COLOR_REMOVE
												icon = "x"
											else
												color = COLOR_CHANGE
												icon = "*"
											end
											table.insert(
												result,
												'<font color="#'
													.. COLOR_PIPE
													.. '">|─</font>'
													.. '<font color="#'
													.. color
													.. '">['
													.. icon
													.. "] "
													.. (rest or "")
													.. "</font>"
											)
										else
											table.insert(
												result,
												'<font color="#'
													.. COLOR_PIPE
													.. '">|─</font>'
													.. '<font color="#'
													.. COLOR_TEXT
													.. '">'
													.. entryLine:sub(3)
													.. "</font>"
											)
										end
										i = i + 1
									else
										if entryLine ~= "" then
											table.insert(
												result,
												'<font color="#' .. COLOR_TEXT .. '">' .. entryLine .. "</font>"
											)
										end
										i = i + 1
									end
								end
							elseif line == "" then
								table.insert(result, "")
								i = i + 1
							else
								table.insert(result, '<font color="#' .. COLOR_TEXT .. '">' .. line .. "</font>")
								i = i + 1
							end
						end

						while #result > 0 and result[#result] == "" do
							table.remove(result)
						end

						return table.concat(result, "\n")
					end

					local ChangesLabel = Instance.new("TextLabel")

					ChangesLabel.LayoutOrder = 3
					ChangesLabel.BackgroundTransparency = 1
					ChangesLabel.TextColor3 = Color3.fromRGB(200, 200, 205)
					ChangesLabel.Font = Enum.Font.Gotham
					ChangesLabel.TextXAlignment = Enum.TextXAlignment.Left
					ChangesLabel.TextYAlignment = Enum.TextYAlignment.Top
					ChangesLabel.RichText = true
					ChangesLabel.TextWrapped = true
					ChangesLabel.AutomaticSize = Enum.AutomaticSize.Y
					ChangesLabel.Size = UDim2.new(1, 0, 0, 0)
					ChangesLabel.TextSize = 14
					ChangesLabel.LineHeight = 1.52
					ChangesLabel.Text = FormatChangelog(messageText)
					ChangesLabel.Parent = ContentFrame

					if showUserInfo then
						local currentThemeColors = GetTheme()
						local UserLine = Instance.new("Frame")

						UserLine.Name = "UserLine"
						UserLine.Size = UDim2.new(1, 0, 0, 1)
						UserLine.BackgroundColor3 = currentThemeColors.SubText
						UserLine.BackgroundTransparency = 0.3
						UserLine.BorderSizePixel = 0
						UserLine.LayoutOrder = 4
						UserLine.Parent = ContentFrame

						local UserCard = Instance.new("Frame")
						UserCard.Name = "UserCard"
						UserCard.LayoutOrder = 5
						UserCard.Size = UDim2.new(1, 0, 0, 0)
						UserCard.AutomaticSize = Enum.AutomaticSize.Y
						UserCard.BackgroundColor3 = currentThemeColors.Secondary
						UserCard.BorderSizePixel = 0
						UserCard.Parent = ContentFrame

						local UserCardCorner = Instance.new("UICorner")
						UserCardCorner.CornerRadius = UDim.new(0, 10)
						UserCardCorner.Parent = UserCard

						local UserCardStroke = Instance.new("UIStroke")
						UserCardStroke.Color = currentThemeColors.Accent
						UserCardStroke.Thickness = 1
						UserCardStroke.Transparency = 0.45
						UserCardStroke.Parent = UserCard

						local UserCardPadding = Instance.new("UIPadding")
						UserCardPadding.PaddingTop = UDim.new(0, 12)
						UserCardPadding.PaddingBottom = UDim.new(0, 12)
						UserCardPadding.PaddingLeft = UDim.new(0, 12)
						UserCardPadding.PaddingRight = UDim.new(0, 12)
						UserCardPadding.Parent = UserCard

						local UserCardLayout = Instance.new("UIListLayout")
						UserCardLayout.Padding = UDim.new(0, 10)
						UserCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
						UserCardLayout.FillDirection = Enum.FillDirection.Vertical
						UserCardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
						UserCardLayout.VerticalAlignment = Enum.VerticalAlignment.Top
						UserCardLayout.Parent = UserCard

						local UserHead = Instance.new("Frame")
						UserHead.Size = UDim2.new(1, 0, 0, 44)
						UserHead.BackgroundTransparency = 1
						UserHead.LayoutOrder = 1
						UserHead.Parent = UserCard

						local UserIcon = Instance.new("ImageLabel")
						UserIcon.Size = UDim2.fromOffset(40, 40)
						UserIcon.AnchorPoint = Vector2.new(0, 0.5)
						UserIcon.Position = UDim2.new(0, 0, 0.5, 0)
						UserIcon.BackgroundColor3 =
							BlendColor(currentThemeColors.Accent, currentThemeColors.Secondary, 0.2)
						UserIcon.BackgroundTransparency = 0.5
						UserIcon.Image = "rbxthumb://type=AvatarHeadShot&id="
							.. tostring(lp and lp.UserId or 1)
							.. "&w=150&h=150"
						UserIcon.ScaleType = Enum.ScaleType.Crop
						UserIcon.Parent = UserHead
						local UserIconCorner = Instance.new("UICorner")
						UserIconCorner.CornerRadius = UDim.new(1, 0)
						UserIconCorner.Parent = UserIcon
						local UserIconStroke = Instance.new("UIStroke")
						UserIconStroke.Color = currentThemeColors.Accent
						UserIconStroke.Thickness = 1.5
						UserIconStroke.Transparency = 0.3
						UserIconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						UserIconStroke.Parent = UserIcon

						local UserTitle = Instance.new("TextLabel")
						UserTitle.Size = UDim2.new(1, -52, 0, 20)
						UserTitle.Position = UDim2.new(0, 50, 0, 2)
						UserTitle.BackgroundTransparency = 1
						UserTitle.Text = tostring(lp and lp.DisplayName or lp and lp.Name or "Unknown")
						UserTitle.TextColor3 = currentThemeColors.Text
						UserTitle.Font = Enum.Font.GothamBold
						UserTitle.TextSize = 15
						UserTitle.TextXAlignment = Enum.TextXAlignment.Left
						UserTitle.TextTruncate = Enum.TextTruncate.AtEnd
						UserTitle.Parent = UserHead

						local UserSubRow = Instance.new("Frame")
						UserSubRow.Size = UDim2.new(1, -50, 0, 18)
						UserSubRow.Position = UDim2.new(0, 50, 0, 24)
						UserSubRow.BackgroundTransparency = 1
						UserSubRow.Parent = UserHead

						local UserSub = Instance.new("TextLabel")
						UserSub.Size = UDim2.new(1, 0, 1, 0)
						UserSub.BackgroundTransparency = 1
						UserSub.Text = "@" .. tostring(lp and lp.Name or "unknown")
						UserSub.TextColor3 = currentThemeColors.SubText
						UserSub.Font = Enum.Font.Gotham
						UserSub.TextSize = 11
						UserSub.TextXAlignment = Enum.TextXAlignment.Left
						UserSub.Parent = UserSubRow

						local roleText = getRoleForInfo()
						local RoleBadge = Instance.new("Frame")
						RoleBadge.AnchorPoint = Vector2.new(1, 0.5)
						RoleBadge.Position = UDim2.new(1, 0, 0.5, 0)
						RoleBadge.Size = UDim2.new(0, 0, 1, 0)
						RoleBadge.AutomaticSize = Enum.AutomaticSize.X
						RoleBadge.BackgroundColor3 =
							BlendColor(currentThemeColors.Accent, currentThemeColors.Secondary, 0.18)
						RoleBadge.BackgroundTransparency = 0.5
						RoleBadge.BorderSizePixel = 0
						RoleBadge.Parent = UserSubRow
						local RoleBadgeCorner = Instance.new("UICorner")
						RoleBadgeCorner.CornerRadius = UDim.new(1, 0)
						RoleBadgeCorner.Parent = RoleBadge
						local RoleBadgePad = Instance.new("UIPadding")
						RoleBadgePad.PaddingLeft = UDim.new(0, 7)
						RoleBadgePad.PaddingRight = UDim.new(0, 7)
						RoleBadgePad.Parent = RoleBadge
						local RoleBadgeStroke = Instance.new("UIStroke")
						RoleBadgeStroke.Color = currentThemeColors.Accent
						RoleBadgeStroke.Thickness = 1
						RoleBadgeStroke.Transparency = 0.45
						RoleBadgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						RoleBadgeStroke.Parent = RoleBadge
						local RoleLabel = Instance.new("TextLabel")
						RoleLabel.Size = UDim2.new(0, 0, 1, 0)
						RoleLabel.AutomaticSize = Enum.AutomaticSize.X
						RoleLabel.BackgroundTransparency = 1
						RoleLabel.Text = roleText
						RoleLabel.TextColor3 = currentThemeColors.Accent
						RoleLabel.Font = Enum.Font.GothamBold
						RoleLabel.TextSize = 10
						RoleLabel.TextXAlignment = Enum.TextXAlignment.Center
						RoleLabel.Parent = RoleBadge

						local InfoDivider = Instance.new("Frame")
						InfoDivider.LayoutOrder = 2
						InfoDivider.Size = UDim2.new(1, 0, 0, 1)
						InfoDivider.BackgroundColor3 = currentThemeColors.SubText
						InfoDivider.BackgroundTransparency = 0.75
						InfoDivider.BorderSizePixel = 0
						InfoDivider.Parent = UserCard

						local UserInfoLabel = Instance.new("TextLabel")
						UserInfoLabel.Name = "UserInfoLabel"
						UserInfoLabel.LayoutOrder = 3
						UserInfoLabel.BackgroundTransparency = 1
						UserInfoLabel.TextColor3 = currentThemeColors.SubText
						UserInfoLabel.Font = Enum.Font.Gotham
						UserInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
						UserInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
						UserInfoLabel.TextWrapped = true
						UserInfoLabel.AutomaticSize = Enum.AutomaticSize.Y
						UserInfoLabel.Size = UDim2.new(1, 0, 0, 0)
						UserInfoLabel.TextSize = 12
						UserInfoLabel.LineHeight = 1.6
						UserInfoLabel.Text = buildUserInfoText()
						UserInfoLabel.Parent = UserCard
					end

					Background.BackgroundTransparency = 1
					UIStroke.Transparency = 1

					task.spawn(function()
						task.wait(0.05)
						spr.target(Background, 0.8, 4, { BackgroundTransparency = 0.3 })
						spr.target(UIStroke, 0.8, 4, { Transparency = 0.5 })
					end)

					return InformationFrame
				end
				function Handle:AddColorPicker(Config)
					local Name = Config.Name or Config[1] or "Color Picker"
					local Default = NormalizeColorValue(Config.Default or Config[2]) or GetTheme().Accent
					local Callback = Config.Callback or get_callback(Config, 3) or function() end

					local BASE_HEIGHT = 46
					local PANEL_H = 250
					local isOpen = false
					local ColorPickerFunctions = {}
					local savedColor = Default
					local currentHue, currentSat, currentVal = Color3.toHSV(Default)
					local currentColor = Default

					local Button = Instance.new("Frame")
					Button.Name = "ColorPicker"
					Button.Parent = ResolveElementParent(self)
					Button.BackgroundColor3 = GetTheme().Primary
					Button.BorderSizePixel = 0
					Button.Size = UDim2.new(1, -5, 0, BASE_HEIGHT * CalculateUIScale())
					Button.ClipsDescendants = false
					MakeCorner(Button, 12)

					local Info = Instance.new("Frame")
					Info.Name = "Info"
					Info.Parent = Button
					Info.AnchorPoint = Vector2.new(0, 0.5)
					Info.BackgroundTransparency = 1
					Info.Position = UDim2.new(0.03, 0, 0.5, 0)
					Info.Size = UDim2.new(0.58, 0, 0.65, 0)

					local Title = Instance.new("TextLabel")
					Title.Name = "Title"
					Title.Parent = Info
					Title.BackgroundTransparency = 1
					Title.Text = Name
					Title.TextXAlignment = Enum.TextXAlignment.Left
					Title.FontFace =
						Font.new("rbxassetid://16658221428", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					Title.TextColor3 = Color3.fromRGB(255, 255, 255)
					Title.TextSize = 18
					Title.TextScaled = true
					Title.Size = UDim2.new(1, 0, 1, 0)

					local InlinePreview = Instance.new("Frame")
					InlinePreview.Name = "InlinePreview"
					InlinePreview.Parent = Button
					InlinePreview.BackgroundColor3 = Default
					InlinePreview.BorderSizePixel = 0
					InlinePreview.AnchorPoint = Vector2.new(0, 0.5)
					InlinePreview.Position = UDim2.new(0.64, 0, 0.5, 0)
					InlinePreview.Size = UDim2.new(0.28, 0, 0.6, 0)
					MakeCorner(InlinePreview, 6)
					MakeStroke(InlinePreview, GetTheme().Accent, 1.2, 0.45)

					local ChevronCP = Instance.new("ImageLabel")
					ChevronCP.Name = "Chevron"
					ChevronCP.Parent = Button
					ChevronCP.BackgroundTransparency = 1
					ChevronCP.Position = UDim2.new(0.945, 0, 0.5, 0)
					ChevronCP.AnchorPoint = Vector2.new(0.5, 0.5)
					ChevronCP.Size = UDim2.new(0, 12, 0, 12)
					ChevronCP.ImageColor3 = Color3.fromRGB(180, 180, 180)
					ChevronCP.ScaleType = Enum.ScaleType.Fit
					do
						local ok, ic = pcall(Lucide.GetAsset, "chevron-down")
						if ok and ic then
							ChevronCP.Image = ic.Url
							ChevronCP.ImageRectSize = ic.ImageRectSize
							ChevronCP.ImageRectOffset = ic.ImageRectOffset
						end
					end

					local ClickDetector = Instance.new("TextButton")
					ClickDetector.Name = "ClickDetector"
					ClickDetector.Parent = Button
					ClickDetector.BackgroundTransparency = 1
					ClickDetector.Size = UDim2.new(1, 0, 1, 0)
					ClickDetector.Text = ""
					ClickDetector.ZIndex = 2

					RegisterElementSize(Button, BASE_HEIGHT, "ColorPicker")

					local PickerPanel = Instance.new("Frame")
					PickerPanel.Name = "CPPanel_" .. Name
					PickerPanel.Parent = Page
					PickerPanel.BackgroundColor3 = GetTheme().Primary
					PickerPanel.BorderSizePixel = 0
					PickerPanel.Size = UDim2.new(0, 0, 0, 0)
					PickerPanel.Visible = false
					PickerPanel.ZIndex = 200
					PickerPanel.ClipsDescendants = true
					MakeCorner(PickerPanel, 12)
					MakeStroke(PickerPanel, GetTheme().Accent, 1.2, 0.35)

					local PanelScale = Instance.new("UIScale")
					PanelScale.Scale = 0.94
					PanelScale.Parent = PickerPanel

					local PanelHeader = Instance.new("Frame")
					PanelHeader.Name = "Header"
					PanelHeader.Parent = PickerPanel
					PanelHeader.BackgroundColor3 = BlendColor(GetTheme().Secondary, GetTheme().Primary, 0.4)
					PanelHeader.BorderSizePixel = 0
					PanelHeader.Size = UDim2.new(1, 0, 0, 32)
					PanelHeader.ZIndex = 201
					MakeCorner(PanelHeader, 10)

					local PanelHeaderAccent = Instance.new("Frame")
					PanelHeaderAccent.Size = UDim2.new(1, 0, 0, 2)
					PanelHeaderAccent.BackgroundColor3 = GetTheme().Accent
					PanelHeaderAccent.BackgroundTransparency = 0.4
					PanelHeaderAccent.BorderSizePixel = 0
					PanelHeaderAccent.ZIndex = 202
					MakeCorner(PanelHeaderAccent, 3)
					PanelHeaderAccent.Parent = PanelHeader

					local PanelTitle = Instance.new("TextLabel")
					PanelTitle.Parent = PanelHeader
					PanelTitle.BackgroundTransparency = 1
					PanelTitle.Position = UDim2.new(0, 12, 0, 0)
					PanelTitle.Size = UDim2.new(0.7, 0, 1, 0)
					PanelTitle.Text = Name
					PanelTitle.TextColor3 = GetTheme().Text
					PanelTitle.Font = Enum.Font.GothamBold
					PanelTitle.TextSize = 13
					PanelTitle.TextXAlignment = Enum.TextXAlignment.Left
					PanelTitle.ZIndex = 202

					local PanelCloseBtn = Instance.new("TextButton")
					PanelCloseBtn.AnchorPoint = Vector2.new(1, 0.5)
					PanelCloseBtn.Position = UDim2.new(1, -8, 0.5, 0)
					PanelCloseBtn.Size = UDim2.fromOffset(22, 22)
					PanelCloseBtn.BackgroundColor3 = GetTheme().Primary
					PanelCloseBtn.Text = ""
					PanelCloseBtn.AutoButtonColor = false
					PanelCloseBtn.BorderSizePixel = 0
					PanelCloseBtn.ZIndex = 202
					PanelCloseBtn.Parent = PanelHeader
					MakeCorner(PanelCloseBtn, 8)
					do
						local xi = Instance.new("ImageLabel")
						xi.Size = UDim2.fromOffset(10, 10)
						xi.AnchorPoint = Vector2.new(0.5, 0.5)
						xi.Position = UDim2.fromScale(0.5, 0.5)
						xi.BackgroundTransparency = 1
						xi.ImageColor3 = GetTheme().SubText
						xi.ScaleType = Enum.ScaleType.Fit
						xi.ZIndex = 203
						xi.Parent = PanelCloseBtn
						local ok, ic = pcall(Lucide.GetAsset, "x")
						if ok and ic then
							xi.Image = ic.Url
							xi.ImageRectSize = ic.ImageRectSize
							xi.ImageRectOffset = ic.ImageRectOffset
						end
					end

					local PanelContent = Instance.new("Frame")
					PanelContent.Name = "Content"
					PanelContent.Parent = PickerPanel
					PanelContent.BackgroundTransparency = 1
					PanelContent.Position = UDim2.new(0, 0, 0, 32)
					PanelContent.Size = UDim2.new(1, 0, 1, -32)
					PanelContent.ZIndex = 201

					local PC = UDim.new(0, 12)
					local ContentPad = Instance.new("UIPadding")
					ContentPad.PaddingLeft = PC
					ContentPad.PaddingRight = PC
					ContentPad.PaddingTop = UDim.new(0, 10)
					ContentPad.PaddingBottom = UDim.new(0, 10)
					ContentPad.Parent = PanelContent

					local BigPreview = Instance.new("Frame")
					BigPreview.Name = "BigPreview"
					BigPreview.Parent = PanelContent
					BigPreview.BackgroundColor3 = Default
					BigPreview.BorderSizePixel = 0
					BigPreview.Position = UDim2.fromOffset(0, 0)
					BigPreview.Size = UDim2.fromOffset(64, 64)
					BigPreview.ZIndex = 202
					MakeCorner(BigPreview, 10)
					MakeStroke(BigPreview, GetTheme().Accent, 1.5, 0.38)

					local HexOverlay = Instance.new("TextLabel")
					HexOverlay.Name = "HexOverlay"
					HexOverlay.Parent = BigPreview
					HexOverlay.AnchorPoint = Vector2.new(0.5, 1)
					HexOverlay.Position = UDim2.new(0.5, 0, 1, -4)
					HexOverlay.Size = UDim2.new(1, -4, 0, 14)
					HexOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					HexOverlay.BackgroundTransparency = 0.45
					HexOverlay.BorderSizePixel = 0
					HexOverlay.ZIndex = 203
					HexOverlay.Text = "#FFFFFF"
					HexOverlay.TextColor3 = Color3.fromRGB(255, 255, 255)
					HexOverlay.Font = Enum.Font.GothamBold
					HexOverlay.TextSize = 9
					MakeCorner(HexOverlay, 4)

					local SVW = 0
					local SVSquare = Instance.new("Frame")
					SVSquare.Name = "SVSquare"
					SVSquare.Parent = PanelContent
					SVSquare.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
					SVSquare.BorderSizePixel = 0
					SVSquare.Position = UDim2.new(0, 76, 0, 0)
					SVSquare.Size = UDim2.new(1, -76, 0, 90)
					SVSquare.ZIndex = 202
					MakeCorner(SVSquare, 8)
					MakeStroke(SVSquare, GetTheme().Accent, 1, 0.55)

					local SatOverlay = Instance.new("Frame")
					SatOverlay.Parent = SVSquare
					SatOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					SatOverlay.BorderSizePixel = 0
					SatOverlay.Size = UDim2.fromScale(1, 1)
					SatOverlay.ZIndex = 203
					MakeCorner(SatOverlay, 8)
					local SatGrad = Instance.new("UIGradient")
					SatGrad.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					})
					SatGrad.Parent = SatOverlay

					local ValOverlay = Instance.new("Frame")
					ValOverlay.Parent = SVSquare
					ValOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					ValOverlay.BorderSizePixel = 0
					ValOverlay.Size = UDim2.fromScale(1, 1)
					ValOverlay.ZIndex = 204
					MakeCorner(ValOverlay, 8)
					local ValGrad = Instance.new("UIGradient")
					ValGrad.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0),
					})
					ValGrad.Rotation = 90
					ValGrad.Parent = ValOverlay

					local SVKnob = Instance.new("Frame")
					SVKnob.Name = "SVKnob"
					SVKnob.Parent = SVSquare
					SVKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					SVKnob.BorderSizePixel = 0
					SVKnob.Size = UDim2.fromOffset(14, 14)
					SVKnob.AnchorPoint = Vector2.new(0.5, 0.5)
					SVKnob.Position = UDim2.new(currentSat, 0, 1 - currentVal, 0)
					SVKnob.ZIndex = 205
					MakeCorner(SVKnob, 7)
					MakeStroke(SVKnob, Color3.fromRGB(0, 0, 0), 2, 0.1)

					local HueSlider = Instance.new("Frame")
					HueSlider.Name = "HueSlider"
					HueSlider.Parent = PanelContent
					HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					HueSlider.BorderSizePixel = 0
					HueSlider.Position = UDim2.new(0, 0, 0, 74)
					HueSlider.Size = UDim2.new(1, 0, 0, 14)
					HueSlider.ZIndex = 202
					MakeCorner(HueSlider, 7)
					local HueGrad = Instance.new("UIGradient")
					HueGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
						ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
						ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
						ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
						ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
						ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
					})
					HueGrad.Parent = HueSlider

					local HueKnob = Instance.new("Frame")
					HueKnob.Name = "HueKnob"
					HueKnob.Parent = HueSlider
					HueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					HueKnob.BorderSizePixel = 0
					HueKnob.Size = UDim2.new(0, 4, 1, 8)
					HueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
					HueKnob.Position = UDim2.new(currentHue, 0, 0.5, 0)
					HueKnob.ZIndex = 203
					MakeCorner(HueKnob, 2)
					MakeStroke(HueKnob, Color3.fromRGB(30, 30, 30), 1, 0.1)

					local InputRow = Instance.new("Frame")
					InputRow.Name = "InputRow"
					InputRow.Parent = PanelContent
					InputRow.BackgroundTransparency = 1
					InputRow.Position = UDim2.new(0, 0, 0, 98)
					InputRow.Size = UDim2.new(1, 0, 0, 28)
					InputRow.ZIndex = 202

					local InputRowLayout = Instance.new("UIListLayout")
					InputRowLayout.FillDirection = Enum.FillDirection.Horizontal
					InputRowLayout.Padding = UDim.new(0, 4)
					InputRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					InputRowLayout.Parent = InputRow

					local function makeInput(labelText, width)
						local frame = Instance.new("Frame")
						frame.Size = UDim2.new(0, width, 1, 0)
						frame.BackgroundColor3 = GetTheme().Secondary
						frame.BorderSizePixel = 0
						frame.ZIndex = 202
						MakeCorner(frame, 6)
						MakeStroke(frame, GetTheme().Accent, 1, 0.62)

						local lbl = Instance.new("TextLabel")
						lbl.Size = UDim2.new(0, 18, 1, 0)
						lbl.Position = UDim2.fromOffset(4, 0)
						lbl.BackgroundTransparency = 1
						lbl.Text = labelText
						lbl.TextColor3 = GetTheme().SubText
						lbl.Font = Enum.Font.GothamBold
						lbl.TextSize = 10
						lbl.TextXAlignment = Enum.TextXAlignment.Left
						lbl.ZIndex = 203
						lbl.Parent = frame

						local box = Instance.new("TextBox")
						box.Size = UDim2.new(1, -22, 1, 0)
						box.Position = UDim2.new(0, 20, 0, 0)
						box.BackgroundTransparency = 1
						box.Text = "255"
						box.TextColor3 = GetTheme().Text
						box.Font = Enum.Font.Gotham
						box.TextSize = 11
						box.TextXAlignment = Enum.TextXAlignment.Center
						box.ClearTextOnFocus = false
						box.ZIndex = 203
						box.Parent = frame
						frame.Parent = InputRow
						return box
					end

					local RInput = makeInput("R", 44)
					local GInput = makeInput("G", 44)
					local BInput = makeInput("B", 44)

					local HexFrame = Instance.new("Frame")
					HexFrame.Size = UDim2.new(1, -(44 * 3 + 4 * 3 + 2), 1, 0)
					HexFrame.BackgroundColor3 = GetTheme().Secondary
					HexFrame.BorderSizePixel = 0
					HexFrame.ZIndex = 202
					MakeCorner(HexFrame, 6)
					MakeStroke(HexFrame, GetTheme().Accent, 1, 0.62)
					HexFrame.Parent = InputRow

					local HexLbl = Instance.new("TextLabel")
					HexLbl.Size = UDim2.new(0, 14, 1, 0)
					HexLbl.Position = UDim2.fromOffset(5, 0)
					HexLbl.BackgroundTransparency = 1
					HexLbl.Text = "#"
					HexLbl.TextColor3 = GetTheme().SubText
					HexLbl.Font = Enum.Font.GothamBold
					HexLbl.TextSize = 11
					HexLbl.ZIndex = 203
					HexLbl.Parent = HexFrame

					local HexInput = Instance.new("TextBox")
					HexInput.Size = UDim2.new(1, -18, 1, 0)
					HexInput.Position = UDim2.new(0, 16, 0, 0)
					HexInput.BackgroundTransparency = 1
					HexInput.Text = "FF4444"
					HexInput.TextColor3 = GetTheme().Text
					HexInput.Font = Enum.Font.GothamBold
					HexInput.TextSize = 10
					HexInput.TextXAlignment = Enum.TextXAlignment.Center
					HexInput.ClearTextOnFocus = false
					HexInput.ZIndex = 203
					HexInput.Parent = HexFrame

					local BtnRow = Instance.new("Frame")
					BtnRow.Name = "BtnRow"
					BtnRow.Parent = PanelContent
					BtnRow.BackgroundTransparency = 1
					BtnRow.AnchorPoint = Vector2.new(0, 1)
					BtnRow.Position = UDim2.new(0, 0, 1, 0)
					BtnRow.Size = UDim2.new(1, 0, 0, 30)
					BtnRow.ZIndex = 202

					local BtnRowLayout = Instance.new("UIListLayout")
					BtnRowLayout.FillDirection = Enum.FillDirection.Horizontal
					BtnRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
					BtnRowLayout.Padding = UDim.new(0, 6)
					BtnRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					BtnRowLayout.Parent = BtnRow

					local function makePanelBtn(text, isPrimary)
						local theme = GetTheme()
						local btn = Instance.new("TextButton")
						btn.Size = UDim2.new(0, 78, 0, 28)
						btn.BackgroundColor3 = isPrimary and theme.Accent
							or BlendColor(theme.Primary, theme.Secondary, 0.55)
						btn.Text = text
						btn.TextColor3 = isPrimary and GetContrastTextColor(theme.Accent) or theme.Text
						btn.AutoButtonColor = false
						btn.Font = Enum.Font.GothamBold
						btn.TextSize = 12
						btn.BorderSizePixel = 0
						btn.ZIndex = 202
						btn.Parent = BtnRow
						MakeCorner(btn, 8)
						if not isPrimary then
							MakeStroke(btn, theme.Accent, 1, 0.55)
						end
						AttachButtonSpring(btn, btn, function(state, t)
							if isPrimary then
								if state.down then
									return BlendColor(t.Accent, Color3.fromRGB(255, 255, 255), 0.12)
								end
								if state.hover then
									return BlendColor(t.Accent, Color3.fromRGB(255, 255, 255), 0.06)
								end
								return t.Accent
							else
								if state.down then
									return BlendColor(t.Primary, t.Secondary, 0.22)
								end
								if state.hover then
									return BlendColor(t.Primary, t.Accent, 0.08)
								end
								return BlendColor(t.Primary, t.Secondary, 0.55)
							end
						end)
						return btn
					end

					local CancelBtn = makePanelBtn("Cancel", false)
					local ApplyBtn = makePanelBtn("Apply", true)

					local function colorToHex(c)
						return string.format(
							"%02X%02X%02X",
							math.floor(c.R * 255 + 0.5),
							math.floor(c.G * 255 + 0.5),
							math.floor(c.B * 255 + 0.5)
						)
					end

					local function syncInputs()
						local r = math.floor(currentColor.R * 255 + 0.5)
						local g = math.floor(currentColor.G * 255 + 0.5)
						local b = math.floor(currentColor.B * 255 + 0.5)
						RInput.Text = tostring(r)
						GInput.Text = tostring(g)
						BInput.Text = tostring(b)
						HexInput.Text = colorToHex(currentColor)
						HexOverlay.Text = "#" .. colorToHex(currentColor)
					end

					local function updateColor(skipCallback)
						currentColor = Color3.fromHSV(currentHue, currentSat, currentVal)
						spr.target(InlinePreview, 0.5, 5, { BackgroundColor3 = currentColor })
						spr.target(BigPreview, 0.5, 5, { BackgroundColor3 = currentColor })
						spr.target(SVSquare, 0.5, 5, { BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1) })
						syncInputs()
						if not skipCallback then
							Callback(currentColor)
						end
					end

					local function onRGBInput()
						local r = math.clamp(tonumber(RInput.Text) or 0, 0, 255) / 255
						local g = math.clamp(tonumber(GInput.Text) or 0, 0, 255) / 255
						local b = math.clamp(tonumber(BInput.Text) or 0, 0, 255) / 255
						currentColor = Color3.new(r, g, b)
						currentHue, currentSat, currentVal = Color3.toHSV(currentColor)
						spr.target(HueKnob, 0.8, 5, { Position = UDim2.new(currentHue, 0, 0.5, 0) })
						spr.target(SVKnob, 0.8, 5, { Position = UDim2.new(currentSat, 0, 1 - currentVal, 0) })
						updateColor()
					end

					local function onHexInput()
						local hex = HexInput.Text:gsub("#", ""):gsub("%s", "")
						if #hex == 6 then
							local c = colorFromHexValue(hex)
							if c then
								currentColor = c
								currentHue, currentSat, currentVal = Color3.toHSV(currentColor)
								spr.target(HueKnob, 0.8, 5, { Position = UDim2.new(currentHue, 0, 0.5, 0) })
								spr.target(SVKnob, 0.8, 5, { Position = UDim2.new(currentSat, 0, 1 - currentVal, 0) })
								updateColor()
							end
						end
					end

					RInput.FocusLost:Connect(onRGBInput)
					GInput.FocusLost:Connect(onRGBInput)
					BInput.FocusLost:Connect(onRGBInput)
					HexInput.FocusLost:Connect(onHexInput)

					local PANEL_W_RATIO = 0.96

					local function updatePanelPos()
						if not (Button and Button.Parent and Page and Page.Parent) then
							return
						end
						local btnPos = Button.AbsolutePosition
						local btnSize = Button.AbsoluteSize
						local pagePos = Page.AbsolutePosition
						local pageSize = Page.AbsoluteSize
						local scrollY = (Page:IsA("ScrollingFrame") and Page.CanvasPosition.Y or 0)

						local panelW = math.floor(btnSize.X * PANEL_W_RATIO + 0.5)
						local relX = math.clamp(btnPos.X - pagePos.X, 8, math.max(8, pageSize.X - panelW - 8))
						local relY = (btnPos.Y - pagePos.Y) + scrollY + btnSize.Y + 6

						if relY + PANEL_H > pageSize.Y + scrollY - 8 then
							relY = (btnPos.Y - pagePos.Y) + scrollY - PANEL_H - 6
						end

						PickerPanel.Position = UDim2.fromOffset(math.floor(relX + 0.5), math.floor(relY + 0.5))
						PickerPanel.Size = UDim2.new(0, panelW, 0, PANEL_H)
					end

					local function closePicker()
						isOpen = false
						spr.target(PanelScale, 0.75, 7, { Scale = 0.94 })
						spr.target(PickerPanel, 0.75, 7, { BackgroundTransparency = 1 })
						spr.target(ChevronCP, 0.65, 6, { Rotation = 0 })
						task.delay(0.16, function()
							if not isOpen then
								PickerPanel.Visible = false
								PickerPanel.BackgroundTransparency = 0
							end
						end)
					end

					local function openPicker()
						isOpen = true
						savedColor = currentColor
						updatePanelPos()
						syncInputs()
						PickerPanel.Visible = true
						PickerPanel.BackgroundTransparency = 0.08
						PanelScale.Scale = 0.94
						spr.target(PanelScale, 0.72, 7, { Scale = 1 })
						spr.target(PickerPanel, 0.72, 7, { BackgroundTransparency = 0 })
						spr.target(ChevronCP, 0.65, 6, { Rotation = 180 })
					end

					local function toggle()
						if isOpen then
							closePicker()
						else
							openPicker()
						end
					end

					ClickDetector.Activated:Connect(toggle)
					PanelCloseBtn.Activated:Connect(closePicker)
					CancelBtn.Activated:Connect(function()
						currentColor = savedColor
						currentHue, currentSat, currentVal = Color3.toHSV(savedColor)
						spr.target(HueKnob, 0.8, 5, { Position = UDim2.new(currentHue, 0, 0.5, 0) })
						spr.target(SVKnob, 0.8, 5, { Position = UDim2.new(currentSat, 0, 1 - currentVal, 0) })
						updateColor()
						closePicker()
					end)
					ApplyBtn.Activated:Connect(function()
						savedColor = currentColor
						Callback(currentColor)
						closePicker()
					end)

					ClickDetector.MouseEnter:Connect(function()
						if not isOpen then
							spr.target(Button, 0.6, 6, { BackgroundColor3 = GetTheme().Secondary })
						end
					end)
					ClickDetector.MouseLeave:Connect(function()
						if not isOpen then
							spr.target(Button, 0.6, 6, { BackgroundColor3 = GetTheme().Primary })
						end
					end)

					UserInputService.InputBegan:Connect(function(input, gp)
						if gp or not isOpen then
							return
						end
						if
							input.UserInputType ~= Enum.UserInputType.MouseButton1
							and input.UserInputType ~= Enum.UserInputType.Touch
						then
							return
						end
						local cp = input.Position
						local pp = PickerPanel.AbsolutePosition
						local ps = PickerPanel.AbsoluteSize
						local bp = Button.AbsolutePosition
						local bs = Button.AbsoluteSize
						local inPanel = cp.X >= pp.X and cp.X <= pp.X + ps.X and cp.Y >= pp.Y and cp.Y <= pp.Y + ps.Y
						local inButton = cp.X >= bp.X and cp.X <= bp.X + bs.X and cp.Y >= bp.Y and cp.Y <= bp.Y + bs.Y
						if not inPanel and not inButton then
							closePicker()
						end
					end)

					local pageMain = GetPageMain()
					if pageMain then
						pageMain:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
							if isOpen then
								updatePanelPos()
							end
						end)
					end
					Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
						if isOpen then
							updatePanelPos()
						end
					end)
					local draggingSV = false
					SVSquare.InputBegan:Connect(function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
						then
							draggingSV = true
							local relX = math.clamp(
								(input.Position.X - SVSquare.AbsolutePosition.X) / SVSquare.AbsoluteSize.X,
								0,
								1
							)
							local relY = math.clamp(
								(input.Position.Y - SVSquare.AbsolutePosition.Y) / SVSquare.AbsoluteSize.Y,
								0,
								1
							)
							currentSat = relX
							currentVal = 1 - relY
							spr.target(SVKnob, 1, 6, { Position = UDim2.new(relX, 0, relY, 0) })
							updateColor()
						end
					end)
					SVSquare.InputEnded:Connect(function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
						then
							draggingSV = false
						end
					end)

					local draggingHue = false
					HueSlider.InputBegan:Connect(function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
						then
							draggingHue = true
							local relX = math.clamp(
								(input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X,
								0,
								1
							)
							currentHue = relX
							spr.target(HueKnob, 1, 6, { Position = UDim2.new(relX, 0, 0.5, 0) })
							updateColor()
						end
					end)
					HueSlider.InputEnded:Connect(function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
						then
							draggingHue = false
						end
					end)

					UserInputService.InputChanged:Connect(function(input)
						if
							input.UserInputType ~= Enum.UserInputType.MouseMovement
							and input.UserInputType ~= Enum.UserInputType.Touch
						then
							return
						end
						if draggingSV then
							local relX = math.clamp(
								(input.Position.X - SVSquare.AbsolutePosition.X) / SVSquare.AbsoluteSize.X,
								0,
								1
							)
							local relY = math.clamp(
								(input.Position.Y - SVSquare.AbsolutePosition.Y) / SVSquare.AbsoluteSize.Y,
								0,
								1
							)
							currentSat = relX
							currentVal = 1 - relY
							spr.target(SVKnob, 1, 8, { Position = UDim2.new(relX, 0, relY, 0) })
							updateColor()
						end
						if draggingHue then
							local relX = math.clamp(
								(input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X,
								0,
								1
							)
							currentHue = relX
							spr.target(HueKnob, 1, 8, { Position = UDim2.new(relX, 0, 0.5, 0) })
							updateColor()
						end
					end)

					function ColorPickerFunctions:Set(color)
						local c = NormalizeColorValue(color)
						if not c then
							return
						end
						currentColor = c
						savedColor = c
						currentHue, currentSat, currentVal = Color3.toHSV(c)
						spr.target(HueKnob, 0.8, 5, { Position = UDim2.new(currentHue, 0, 0.5, 0) })
						spr.target(SVKnob, 0.8, 5, { Position = UDim2.new(currentSat, 0, 1 - currentVal, 0) })
						updateColor()
					end
					function ColorPickerFunctions:Toggle()
						toggle()
					end
					function ColorPickerFunctions:Open()
						if not isOpen then
							openPicker()
						end
					end
					function ColorPickerFunctions:Close()
						if isOpen then
							closePicker()
						end
					end

					HueKnob.Position = UDim2.new(currentHue, 0, 0.5, 0)
					SVKnob.Position = UDim2.new(currentSat, 0, 1 - currentVal, 0)
					SVSquare.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
					InlinePreview.BackgroundColor3 = Default
					BigPreview.BackgroundColor3 = Default
					syncInputs()

					Library.Features_Table[Button.Info.Title.Text] = ColorPickerFunctions
					return ColorPickerFunctions
				end
				function Handle:AddDropdown(config)
					local DropdownFunctions = {}
					DropdownFunctions.Options = config and (config[3] or config.Options) or {}
					DropdownFunctions.Callback = get_callback(config, 4)
					DropdownFunctions.Selected = config and (config[2] or config.Default) or ""
					DropdownFunctions.Callback_OnDeletion = config.Callback_OnDeletion or true

					local BASE_HEIGHT = 50
					local uniqueId = HttpService:GenerateGUID(false):sub(1, 8)
					local theme = GetTheme()

					local Dropdown = Instance.new("Frame")
					Dropdown.Name = "Dropdown"
					Dropdown.Parent = ResolveElementParent(self)
					Dropdown.BackgroundTransparency = 1
					Dropdown.BorderSizePixel = 0
					Dropdown.Size = UDim2.new(1, -5, 0, BASE_HEIGHT * CalculateUIScale())
					Dropdown.ClipsDescendants = false

					local Main_D = Instance.new("Frame")
					Main_D.Name = "Main"
					Main_D.Parent = Dropdown
					Main_D.BackgroundColor3 = theme.Primary
					Main_D.BorderSizePixel = 0
					Main_D.Size = UDim2.new(1, 0, 1, 0)
					Main_D.ClipsDescendants = false
					MakeCorner(Main_D, 12)

					local Info = Instance.new("Frame")
					Info.Name = "Info"
					Info.Parent = Main_D
					Info.AnchorPoint = Vector2.new(0, 0.5)
					Info.BackgroundTransparency = 1
					Info.Position = UDim2.new(0.04, 0, 0.5, 0)
					Info.Size = UDim2.new(0.6, 0, 0.65, 0)

					local Title_D = Instance.new("TextLabel")
					Title_D.FontFace =
						Font.new("rbxassetid://16658221428", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					Title_D.Text = config and (config[1] or config.Title or config.Name) or "Dropdown"
					Title_D.TextColor3 = Color3.fromRGB(255, 255, 255)
					Title_D.TextScaled = true
					Title_D.TextSize = 20
					Title_D.TextWrapped = true
					Title_D.TextXAlignment = Enum.TextXAlignment.Left
					Title_D.Name = "Title"
					Title_D.Parent = Info
					Title_D.BackgroundTransparency = 1
					Title_D.Size = UDim2.new(1, 0, 1, 0)

					local Data_D = Instance.new("Frame")
					Data_D.Name = "Data"
					Data_D.Parent = Main_D
					Data_D.AnchorPoint = Vector2.new(0, 0.5)
					Data_D.BackgroundColor3 = theme.Secondary
					Data_D.BorderSizePixel = 0
					Data_D.Position = UDim2.new(0.66, 0, 0.5, 0)
					Data_D.Size = UDim2.new(0.32, 0, 0.65, 0)
					Data_D.ClipsDescendants = false
					MakeCorner(Data_D, 6)

					local SelectedLabel = Instance.new("TextLabel")
					SelectedLabel.FontFace =
						Font.new("rbxassetid://16658221428", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					SelectedLabel.Text = DropdownFunctions.Selected or "None"
					SelectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					SelectedLabel.TextScaled = true
					SelectedLabel.TextWrapped = true
					SelectedLabel.Name = "Selected"
					SelectedLabel.Parent = Data_D
					SelectedLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					SelectedLabel.BackgroundTransparency = 1
					SelectedLabel.Position = UDim2.new(0.45, 0, 0.5, 0)
					SelectedLabel.Size = UDim2.new(0.75, 0, 0.75, 0)

					local ChevronIcon = Instance.new("ImageLabel")
					ChevronIcon.Name = "Chevron"
					ChevronIcon.Parent = Data_D
					ChevronIcon.Image = "rbxassetid://10709790948"
					ChevronIcon.ScaleType = Enum.ScaleType.Fit
					ChevronIcon.BackgroundTransparency = 1
					ChevronIcon.Position = UDim2.new(0.88, 0, 0.5, 0)
					ChevronIcon.AnchorPoint = Vector2.new(0.5, 0.5)
					ChevronIcon.Size = UDim2.new(0, 12, 0, 12)
					ChevronIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)

					local ClickDetector_D = Instance.new("TextButton")
					ClickDetector_D.Text = ""
					ClickDetector_D.Name = "ClickDetector"
					ClickDetector_D.Parent = Main_D
					ClickDetector_D.BackgroundTransparency = 1
					ClickDetector_D.Size = UDim2.new(1, 0, 1, 0)
					ClickDetector_D.ZIndex = 2

					local OptionsPanelContainer = Instance.new("Folder")
					OptionsPanelContainer.Name = "Dropdown_" .. uniqueId
					OptionsPanelContainer.Parent = Page

					local OptionsPanel = Instance.new("Frame")
					OptionsPanel.Name = "OptionsPanel"
					OptionsPanel.Parent = OptionsPanelContainer
					OptionsPanel.BackgroundColor3 = BlendColor(theme.Primary, theme.Secondary, 0.25)
					OptionsPanel.BorderSizePixel = 0
					OptionsPanel.ClipsDescendants = true
					OptionsPanel.Size = UDim2.new(0, 0, 0, 0)
					OptionsPanel.Visible = false
					OptionsPanel.ZIndex = 1000
					MakeCorner(OptionsPanel, 10)
					MakeStroke(OptionsPanel, theme.Accent, 1, 0.42)

					local OptionsScroll = Instance.new("ScrollingFrame")
					OptionsScroll.Name = "OptionsScroll"
					OptionsScroll.Parent = OptionsPanel
					OptionsScroll.BackgroundTransparency = 1
					OptionsScroll.BorderSizePixel = 0
					OptionsScroll.Size = UDim2.new(1, 0, 1, 0)
					OptionsScroll.ScrollBarThickness = 4
					OptionsScroll.ScrollBarImageColor3 = theme.Accent
					OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
					OptionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

					local OptionsLayout = Instance.new("UIListLayout")
					OptionsLayout.Padding = UDim.new(0, 3)
					OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
					OptionsLayout.Parent = OptionsScroll

					local OptionsPadding = Instance.new("UIPadding")
					OptionsPadding.PaddingTop = UDim.new(0, 6)
					OptionsPadding.PaddingBottom = UDim.new(0, 6)
					OptionsPadding.PaddingLeft = UDim.new(0, 6)
					OptionsPadding.PaddingRight = UDim.new(0, 6)
					OptionsPadding.Parent = OptionsScroll

					RegisterElementSize(Dropdown, BASE_HEIGHT, "Dropdown")

					local isOpen = false

					local function getPanelWidth()
						return math.max(math.floor(Data_D.AbsoluteSize.X + 0.5), 120)
					end
					local function calculatePanelHeight(optionCount)
						local OPTION_HEIGHT = 42
						local PADDING = 20
						return math.clamp(optionCount * OPTION_HEIGHT + PADDING, 80, 280)
					end

					local function updatePanelPosition(panelHeight)
						if
							not (
								Data_D
								and Data_D.Parent
								and OptionsPanel
								and OptionsPanel.Parent
								and Page
								and Page.Parent
							)
						then
							return
						end
						local dataPos = Data_D.AbsolutePosition
						local dataSize = Data_D.AbsoluteSize
						local pagePos = Page.AbsolutePosition
						local pageSize = Page.AbsoluteSize
						if dataSize.X <= 0 or dataSize.Y <= 0 or pageSize.X <= 0 or pageSize.Y <= 0 then
							return
						end
						local panelWidth = getPanelWidth()
						panelHeight = math.max(panelHeight or 0, 0)
						local sidePadding = 8
						local scrollOffsetY = (Page:IsA("ScrollingFrame") and Page.CanvasPosition.Y or 0)
						local scrollOffsetX = (Page:IsA("ScrollingFrame") and Page.CanvasPosition.X or 0)
						local relativeX = math.clamp(
							(dataPos.X - pagePos.X) + scrollOffsetX,
							sidePadding,
							math.max(sidePadding, pageSize.X - panelWidth - sidePadding)
						)
						local relativeDataY = (dataPos.Y - pagePos.Y) + scrollOffsetY
						local belowY = relativeDataY + dataSize.Y + 4
						local aboveY = relativeDataY - panelHeight - 4
						local spaceBelow = pageSize.Y + scrollOffsetY - belowY - sidePadding
						local spaceAbove = aboveY - scrollOffsetY - sidePadding
						local placeBelow = spaceBelow >= panelHeight or spaceBelow >= spaceAbove
						local relativeY = placeBelow and belowY or aboveY
						ChevronIcon.Rotation = placeBelow and 180 or -180
						local maxY = math.max(sidePadding, pageSize.Y + scrollOffsetY - panelHeight - sidePadding)
						relativeY = math.clamp(relativeY, sidePadding + scrollOffsetY, maxY)
						OptionsPanel.Position =
							UDim2.fromOffset(math.floor(relativeX + 0.5), math.floor(relativeY + 0.5))
						OptionsPanel.Size = UDim2.new(0, panelWidth, 0, OptionsPanel.Size.Y.Offset)
					end

					local function updateOptions()
						for _, child in ipairs(OptionsScroll:GetChildren()) do
							if child:IsA("TextButton") then
								child:Destroy()
							end
						end
						local t = GetTheme()
						for index, option in ipairs(DropdownFunctions.Options) do
							local isSelected = tostring(option) == tostring(DropdownFunctions.Selected)
							local OptionButton = Instance.new("TextButton")
							OptionButton.Name = "Option_" .. index
							OptionButton.Parent = OptionsScroll
							OptionButton.BackgroundColor3 = isSelected and t.Accent or t.Secondary
							OptionButton.BorderSizePixel = 0
							OptionButton.Size = UDim2.new(1, -4, 0, 42)
							OptionButton.AutoButtonColor = false
							OptionButton.Font = Enum.Font.Gotham
							OptionButton.Text = ""
							OptionButton.TextSize = 13
							OptionButton.TextXAlignment = Enum.TextXAlignment.Left
							OptionButton.ZIndex = 1001
							MakeCorner(OptionButton, 7)
							OptionButton:SetAttribute("IsSelected", isSelected)

							local OptionLayout = Instance.new("UIListLayout")
							OptionLayout.FillDirection = Enum.FillDirection.Horizontal
							OptionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
							OptionLayout.Padding = UDim.new(0, 6)
							OptionLayout.Parent = OptionButton

							local OptionPad = Instance.new("UIPadding")
							OptionPad.PaddingLeft = UDim.new(0, 20)
							OptionPad.PaddingRight = UDim.new(0, 8)
							OptionPad.Parent = OptionButton

							local CheckIcon = Instance.new("ImageLabel")
							CheckIcon.Size = UDim2.fromOffset(12, 12)
							CheckIcon.BackgroundTransparency = 1
							CheckIcon.ImageColor3 = t.Text
							CheckIcon.ScaleType = Enum.ScaleType.Fit
							CheckIcon.Visible = isSelected
							CheckIcon.ZIndex = 1002
							do
								local ok, ic = pcall(Lucide.GetAsset, "check")
								if ok and ic then
									CheckIcon.Image = ic.Url
									CheckIcon.ImageRectSize = ic.ImageRectSize
									CheckIcon.ImageRectOffset = ic.ImageRectOffset
								end
							end
							CheckIcon.Parent = OptionButton

							local OptionText = Instance.new("TextLabel")
							OptionText.BackgroundTransparency = 1
							OptionText.Text = option
							OptionText.TextColor3 = t.Text
							OptionText.Font = Enum.Font.Gotham
							OptionText.TextSize = 15
							OptionText.TextXAlignment = Enum.TextXAlignment.Left
							OptionText.Size = UDim2.new(1, 0, 1, 0)
							OptionText.ZIndex = 1002
							OptionText.Parent = OptionButton

							applyCurrentTextFont(OptionButton)

							OptionButton.Activated:Connect(function()
								DropdownFunctions.Selected = option
								SelectedLabel.Text = option
								for _, btn in ipairs(OptionsScroll:GetChildren()) do
									if btn:IsA("TextButton") and btn.Name:find("^Option_") then
										local sel = btn == OptionButton
										btn:SetAttribute("IsSelected", sel)
										local tt = GetTheme()
										spr.target(
											btn,
											0.6,
											6,
											{ BackgroundColor3 = sel and tt.Accent or tt.Secondary }
										)
										local ci = btn:FindFirstChildOfClass("ImageLabel")
										if ci then
											ci.Visible = sel
										end
									end
								end
								if DropdownFunctions.Callback then
									task.spawn(DropdownFunctions.Callback, option)
								end
								isOpen = false
								spr.target(OptionsPanel, 0.6, 5, { Size = UDim2.new(0, getPanelWidth(), 0, 0) })
								spr.target(ChevronIcon, 0.6, 5, { Rotation = 0 })
								spr.target(Main_D, 0.6, 6, { BackgroundColor3 = GetTheme().Primary })
								task.wait(0.3)
								if not isOpen then
									OptionsPanel.Visible = false
									EnableScrolling(GetPageMain())
								end
							end)

							AttachButtonSpring(OptionButton, OptionButton, function(state, currentT)
								local sel = OptionButton:GetAttribute("IsSelected")
								if state.down then
									return currentT.Button.Hover
								end
								if state.hover then
									return BlendColor(currentT.Accent, currentT.Secondary, 0.35)
								end
								return sel and currentT.Accent or currentT.Secondary
							end)
						end
					end

					local function toggle()
						isOpen = not isOpen
						if isOpen then
							local panelHeight = calculatePanelHeight(#DropdownFunctions.Options)
							updatePanelPosition(panelHeight)
							OptionsPanel.Visible = true
							DisableScrolling(GetPageMain())
							spr.target(OptionsPanel, 0.7, 5, { Size = UDim2.new(0, getPanelWidth(), 0, panelHeight) })
							spr.target(Main_D, 0.6, 6, { BackgroundColor3 = GetTheme().Secondary })
						else
							spr.target(OptionsPanel, 0.7, 5, { Size = UDim2.new(0, getPanelWidth(), 0, 0) })
							spr.target(ChevronIcon, 0.7, 5, { Rotation = 0 })
							spr.target(Main_D, 0.6, 6, { BackgroundColor3 = GetTheme().Primary })
							task.wait(0.3)
							if not isOpen then
								OptionsPanel.Visible = false
								EnableScrolling(GetPageMain())
							end
						end
					end

					ClickDetector_D.Activated:Connect(toggle)
					AttachButtonSpring(ClickDetector_D, Main_D, function(state, t)
						if isOpen then
							return t.Secondary
						end
						if state.down then
							return t.Button.Hover
						end
						if state.hover then
							return t.Secondary
						end
						return t.Primary
					end)

					local pageMain = GetPageMain()
					if pageMain then
						pageMain:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
							if isOpen then
								updatePanelPosition(calculatePanelHeight(#DropdownFunctions.Options))
							end
						end)
					end
					Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
						if isOpen then
							updatePanelPosition(calculatePanelHeight(#DropdownFunctions.Options))
						end
					end)
					UserInputService.InputBegan:Connect(function(input, gameProcessed)
						if gameProcessed or not isOpen then
							return
						end
						if
							input.UserInputType ~= Enum.UserInputType.Touch
							and input.UserInputType ~= Enum.UserInputType.MouseButton1
						then
							return
						end
						local cursorPos = input.Position
						local panelPos = OptionsPanel.AbsolutePosition
						local panelSize = OptionsPanel.AbsoluteSize
						local insidePanel = cursorPos.X >= panelPos.X
							and cursorPos.X <= panelPos.X + panelSize.X
							and cursorPos.Y >= panelPos.Y
							and cursorPos.Y <= panelPos.Y + panelSize.Y
						local dataPos = Data_D.AbsolutePosition
						local dataSize = Data_D.AbsoluteSize
						local insideData = cursorPos.X >= dataPos.X
							and cursorPos.X <= dataPos.X + dataSize.X
							and cursorPos.Y >= dataPos.Y
							and cursorPos.Y <= dataPos.Y + dataSize.Y
						if not insidePanel and not insideData then
							toggle()
						end
					end)

					function DropdownFunctions:AddOption(name)
						for _, opt in ipairs(DropdownFunctions.Options) do
							if tostring(opt) == tostring(name) then
								updateOptions()
								return
							end
						end
						table.insert(DropdownFunctions.Options, name)
						updateOptions()
					end
					function DropdownFunctions:RemoveOption(name)
						local newOptions = {}
						for _, opt in ipairs(DropdownFunctions.Options) do
							if opt ~= name then
								table.insert(newOptions, opt)
							end
						end

						local wasSelected = DropdownFunctions.Selected == name
						DropdownFunctions.Options = newOptions

						if wasSelected then
							DropdownFunctions:SetSelected(
								#newOptions > 0 and newOptions[1] or "None",
								config.Callback_OnDeletion == true
							)
						end

						updateOptions()
					end
					function DropdownFunctions:ClearOptions()
						DropdownFunctions.Options = {}
						DropdownFunctions.Selected = "None"
						SelectedLabel.Text = "None"
						updateOptions()
					end
					function DropdownFunctions:AddOptionsFromList(list)
						for _, opt in ipairs(list) do
							local exists = false
							for _, current in ipairs(DropdownFunctions.Options) do
								if tostring(current) == tostring(opt) then
									exists = true
									break
								end
							end
							if not exists then
								table.insert(DropdownFunctions.Options, opt)
							end
						end
						updateOptions()
					end
					function DropdownFunctions:GetSelected()
						return DropdownFunctions.Selected
					end
					function DropdownFunctions:SetSelected(value, entercallback)
						entercallback = entercallback or false
						DropdownFunctions.Selected = value
						SelectedLabel.Text = value
						for _, btn in ipairs(OptionsScroll:GetChildren()) do
							if btn:IsA("TextButton") and btn.Name:find("^Option_") then
								local sel = btn.Text == tostring(value)
									or (
										btn:FindFirstChildOfClass("TextLabel")
										and btn:FindFirstChildOfClass("TextLabel").Text == tostring(value)
									)
								btn:SetAttribute("IsSelected", sel)
								local t = GetTheme()
								spr.target(btn, 0.6, 6, { BackgroundColor3 = sel and t.Accent or t.Secondary })
								local ci = btn:FindFirstChildOfClass("ImageLabel")
								if ci then
									ci.Visible = sel
								end
							end
						end
						if entercallback and DropdownFunctions.Callback then
							task.spawn(DropdownFunctions.Callback)
						end
					end
					function DropdownFunctions:Set(value)
						DropdownFunctions:SetSelected(value, false)
					end
					function DropdownFunctions:Toggle()
						toggle()
					end
					function DropdownFunctions:Close()
						if isOpen then
							toggle()
						end
					end
					function DropdownFunctions:Open()
						if not isOpen then
							toggle()
						end
					end

					updateOptions()
					if DropdownFunctions.Selected and DropdownFunctions.Selected ~= "" then
						SelectedLabel.Text = DropdownFunctions.Selected
					end

					return DropdownFunctions
				end
			end

			return Elements
		end

		do
			UI = Instance.new("ScreenGui")

			local Window = Instance.new("Frame")
			local AutoScale = Instance.new("UIScale")
			local UICorner = Instance.new("UICorner")
			local Info = Instance.new("Frame")
			local Title = Instance.new("TextLabel")
			local UIGradient = Instance.new("UIGradient")
			local Description = Instance.new("TextLabel")
			local UIPadding = Instance.new("UIPadding")
			local UIListLayout = Instance.new("UIListLayout")
			local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")

			Main = Instance.new("Frame")

			local Pages = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UIStroke1 = Instance.new("UIStroke")
			local UIStroke2 = Instance.new("UIStroke")
			local UIPadding_2 = Instance.new("UIPadding")
			local TabsSection = Instance.new("ScrollingFrame")
			local UIGridLayout = Instance.new("UIGridLayout")
			local UIPadding_3 = Instance.new("UIPadding")
			local UICorner_3 = Instance.new("UICorner")
			local UIStroke2_2 = Instance.new("UIStroke")
			local UIStroke1_2 = Instance.new("UIStroke")
			local Folder = Instance.new("Folder")
			local EnabledFrame = Instance.new("Frame")
			local UICorner_4 = Instance.new("UICorner")
			local UIPadding_4 = Instance.new("UIPadding")
			local Loading = Instance.new("Frame")
			local UICorner_5 = Instance.new("UICorner")
			local UIStroke1_3 = Instance.new("UIStroke")
			local UIStroke2_3 = Instance.new("UIStroke")
			local Icon = Instance.new("ImageLabel")
			local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
			local Requirements = Instance.new("CanvasGroup")
			local UIListLayout_2 = Instance.new("UIListLayout")
			local Configuration = Instance.new("Configuration")
			local RequirementText = Instance.new("TextLabel")
			local UIPadding_5 = Instance.new("UIPadding")
			local BusyOverlay = Instance.new("Frame")
			local BusyOverlayCorner = Instance.new("UICorner")
			local BusyCard = Instance.new("Frame")
			local BusyCardCorner = Instance.new("UICorner")
			local BusyCardStroke = Instance.new("UIStroke")
			local BusyIcon = Instance.new("ImageLabel")
			local BusyIconAspect = Instance.new("UIAspectRatioConstraint")
			local BusyText = Instance.new("TextLabel")
			local Line = Instance.new("Frame")
			local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
			local UIStroke = Instance.new("UIStroke")
			local UIStroke1_4 = Instance.new("UIStroke")
			local Toggle = Instance.new("ImageButton")
			local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
			local UICorner_6 = Instance.new("UICorner")
			local UIStroke1_5 = Instance.new("UIStroke")
			local UIStroke2_4 = Instance.new("UIStroke")
			local ResizeDragInput = nil
			local ResizeDragActive = false
			local ResizeDragStartPos = nil
			local ResizeDragStartSize = nil
			local RESIZE_MIN_WIDTH = 560
			local RESIZE_MIN_HEIGHT = 340
			local RESIZE_MAX_VIEWPORT_RATIO = 0.96

			UI.IgnoreGuiInset = true
			UI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
			UI.ResetOnSpawn = false
			UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			UI.Name = ""
			UI.Parent = gethui() or game.CoreGui or lp.PlayerGui
			_G.Vanish_UI_Instance = UI

			local CustomBackground = Instance.new("Frame")
			local CustomBackgroundImage = Instance.new("ImageLabel")
			local CustomBackgroundVideo = Instance.new("VideoFrame")
			local CustomBackgroundOverlay = Instance.new("Frame")
			local CustomBackgroundCorner = Instance.new("UICorner")
			local customBackgroundDim = 0.35
			local customBackgroundScaleMode = "Crop"
			local customBackgroundPauseOnHide = true

			local function getCustomBackgroundScaleType()
				if customBackgroundScaleMode == "Fit" then
					return Enum.ScaleType.Fit
				end

				return Enum.ScaleType.Crop
			end
			local function syncCustomBackgroundPlayback()
				local shouldPlay = CustomBackground.Visible
					and CustomBackgroundVideo.Visible
					and CustomBackgroundVideo.Video ~= ""

				if customBackgroundPauseOnHide and not Window.Visible then
					shouldPlay = false
				end

				pcall(function()
					if shouldPlay then
						CustomBackgroundVideo:Play()
					else
						CustomBackgroundVideo:Pause()
					end
				end)
			end
			local function applyCustomBackgroundComfort()
				CustomBackgroundOverlay.BackgroundTransparency = math.clamp(customBackgroundDim, 0, 0.95)

				local scaleType = getCustomBackgroundScaleType()

				CustomBackgroundImage.ScaleType = scaleType

				pcall(function()
					CustomBackgroundVideo.ScaleType = scaleType
				end)
				syncCustomBackgroundPlayback()
			end
			local function refreshCustomBackgroundVisibility()
				local hasMedia = CustomBackgroundImage.Visible or CustomBackgroundVideo.Visible

				CustomBackground.Visible = hasMedia and Window.Visible

				syncCustomBackgroundPlayback()
			end

			CustomBackground.Name = "CustomBackground"
			CustomBackground.Parent = Window
			CustomBackground.BackgroundTransparency = 1
			CustomBackground.BorderSizePixel = 0
			CustomBackground.Size = UDim2.fromScale(1, 1)
			CustomBackground.Position = UDim2.fromScale(0, 0)
			CustomBackground.ClipsDescendants = true
			CustomBackground.Visible = false
			CustomBackground.ZIndex = 0
			CustomBackgroundCorner.CornerRadius = UDim.new(0, 12)
			CustomBackgroundCorner.Parent = CustomBackground
			CustomBackgroundImage.Name = "Image"
			CustomBackgroundImage.Parent = CustomBackground
			CustomBackgroundImage.BackgroundTransparency = 1
			CustomBackgroundImage.BorderSizePixel = 0
			CustomBackgroundImage.Size = UDim2.fromScale(1, 1)
			CustomBackgroundImage.ScaleType = Enum.ScaleType.Crop
			CustomBackgroundImage.Visible = false
			CustomBackgroundImage.ZIndex = 0
			CustomBackgroundVideo.Name = "Video"
			CustomBackgroundVideo.Parent = CustomBackground
			CustomBackgroundVideo.BackgroundTransparency = 1
			CustomBackgroundVideo.BorderSizePixel = 0
			CustomBackgroundVideo.Size = UDim2.fromScale(1, 1)
			CustomBackgroundVideo.Visible = false
			CustomBackgroundVideo.Looped = true
			CustomBackgroundVideo.Volume = 0
			CustomBackgroundVideo.ZIndex = 0
			CustomBackgroundOverlay.Name = "Overlay"
			CustomBackgroundOverlay.Parent = CustomBackground
			CustomBackgroundOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			CustomBackgroundOverlay.BackgroundTransparency = 0.35
			CustomBackgroundOverlay.BorderSizePixel = 0
			CustomBackgroundOverlay.Size = UDim2.fromScale(1, 1)
			CustomBackgroundOverlay.ZIndex = 1
			Window.Name = "Window"
			Window.Parent = UI
			Window.AnchorPoint = Vector2.new(0.5, 0.5)
			Window.BackgroundColor3 = GetTheme().Primary
			Window.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Window.BorderSizePixel = 0
			Window.Position = UDim2.new(0.5, 0, 0.5, 0)
			Window.Size = UDim2.new(0.75999999, 0, 0.670000017, 0)

			Window:SetAttribute("Bind", bind)
			Window:GetPropertyChangedSignal("Visible"):Connect(refreshCustomBackgroundVisibility)
			applyCustomBackgroundComfort()
			refreshCustomBackgroundVisibility()

			AutoScale.Name = "AutoScale"
			AutoScale.Parent = Window
			AutoScale.Scale = CalculateUIScale()
			UICorner.CornerRadius = UDim.new(0, 12)
			UICorner.Parent = Window
			Info.Name = "Info"
			Info.Parent = Window
			Info.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
			Info.BackgroundTransparency = 1
			Info.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Info.BorderSizePixel = 0
			Info.Position = UDim2.new(0.0219999999, 0, 0.00899999961, 0)
			Info.Size = UDim2.new(0.958999991, 0, 0.173999995, 0)
			Title.FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			Title.Text = Config.Title or Config.Name or "Vanish Studios"
			Title.TextColor3 = GetTheme().Text
			Title.TextScaled = true
			Title.TextSize = 20
			Title.TextWrapped = true
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.TextYAlignment = Enum.TextYAlignment.Bottom
			Title.Name = "Title"
			Title.Parent = Info
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1
			Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Title.BorderSizePixel = 0
			Title.Position = UDim2.new(-4.94271591E-2, 0, 0.349435002, 0)
			Title.Size = UDim2.new(1, 0, 0.597340405, 0)
			UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, GetTheme().Accent),
				ColorSequenceKeypoint.new(1, BlendColor(GetTheme().Text, GetTheme().Accent, 0.35)),
			})
			UIGradient.Rotation = 270
			UIGradient.Parent = Title
			Description.FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			Description.Text = Config.SubTitle or "by Gregory909 & NotDmel"
			Description.TextColor3 = GetTheme().SubText
			Description.TextScaled = true
			Description.TextSize = 14
			Description.TextWrapped = true
			Description.TextXAlignment = Enum.TextXAlignment.Left
			Description.TextYAlignment = Enum.TextYAlignment.Top
			Description.Name = "Description"
			Description.Parent = Info
			Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description.BackgroundTransparency = 1
			Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Description.BorderSizePixel = 0
			Description.Position = UDim2.new(-7.908345199999999E-3, 0, 0.630582631, 0)
			Description.Size = UDim2.new(1, 0, 0.336175263, 0)
			UIPadding.PaddingBottom = UDim.new(0, 8)
			UIPadding.PaddingLeft = UDim.new(0, 5)
			UIPadding.PaddingTop = UDim.new(0, 5)
			UIPadding.Parent = Info
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Parent = Info
			UIAspectRatioConstraint.AspectRatio = 9.133333206176758
			UIAspectRatioConstraint.Parent = Info
			Main.Name = "Main"
			Main.Parent = Window
			Main.BackgroundTransparency = 1
			Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Main.BorderSizePixel = 0
			Main.Position = UDim2.new(0, 0, 0.213657051, 0)
			Main.Size = UDim2.new(1, 0, 0.746428549, 0)
			Pages.Name = "Pages"
			Pages.Parent = Main
			Pages.BackgroundColor3 = GetTheme().Secondary
			Pages.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Pages.BorderSizePixel = 0
			Pages.ClipsDescendants = true
			Pages.Position = UDim2.new(0.271008462, 0, 0, 0)
			Pages.Size = UDim2.new(0.726293087, 0, 1, 0)
			UICorner_2.CornerRadius = UDim.new(0, 12)
			UICorner_2.Parent = Pages
			UIStroke1.Thickness = 3
			UIStroke1.Transparency = 0.699999988079071
			UIStroke1.Name = "UIStroke1"
			UIStroke1.Parent = Pages
			UIStroke2.Color = Color3.fromRGB(255, 255, 255)
			UIStroke2.Thickness = 1.5
			UIStroke2.Transparency = 0.8999999761581421
			UIStroke2.Name = "UIStroke2"
			UIStroke2.Parent = Pages
			UIPadding_2.PaddingRight = UDim.new(0, 6)
			UIPadding_2.Parent = Pages
			TabsSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
			TabsSection.CanvasSize = UDim2.new(0, 0, 0, 0)
			TabsSection.ScrollBarImageTransparency = 1
			TabsSection.ScrollBarThickness = 0
			TabsSection.Name = "Tabs"
			TabsSection.Parent = Main
			TabsSection.Active = true
			TabsSection.BackgroundColor3 = GetTheme().Secondary
			TabsSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TabsSection.BorderSizePixel = 0
			TabsSection.Size = UDim2.new(0.256465524, 0, 1, 0)
			UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 2)
			UIGridLayout.CellSize = UDim2.new(1, 0, 0, GetTabCellHeight())
			UIGridLayout.Parent = TabsSection
			TabsGridLayout = UIGridLayout
			UIPadding_3.PaddingBottom = UDim.new(0, 6)
			UIPadding_3.PaddingLeft = UDim.new(0, 6)
			UIPadding_3.PaddingRight = UDim.new(0, 6)
			UIPadding_3.PaddingTop = UDim.new(0, 6)
			UIPadding_3.Parent = TabsSection
			UICorner_3.CornerRadius = UDim.new(0, 12)
			UICorner_3.Parent = TabsSection
			UIStroke2_2.Color = Color3.fromRGB(255, 255, 255)
			UIStroke2_2.Thickness = 1.5
			UIStroke2_2.Transparency = 0.8999999761581421
			UIStroke2_2.Name = "UIStroke2"
			UIStroke2_2.Parent = TabsSection
			UIStroke1_2.Thickness = 3
			UIStroke1_2.Transparency = 0.699999988079071
			UIStroke1_2.Name = "UIStroke1"
			UIStroke1_2.Parent = TabsSection
			Folder.Parent = TabsSection
			EnabledFrame.Name = "EnabledFrame"
			EnabledFrame.Parent = Folder
			EnabledFrame.BackgroundColor3 = GetTheme().Primary
			EnabledFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			EnabledFrame.BorderSizePixel = 0
			EnabledFrame.Position = UDim2.new(0, 0, 0, 178)
			EnabledFrame.Size = UDim2.new(0, 124, 0, 28)
			EnabledFrame.Visible = false
			EnabledFrame.ZIndex = 0
			UICorner_4.CornerRadius = UDim.new(0, 12)
			UICorner_4.Parent = EnabledFrame
			UIPadding_4.PaddingLeft = UDim.new(0, 12)
			UIPadding_4.PaddingRight = UDim.new(0, 12)
			UIPadding_4.Parent = Main
			Loading.Name = "Loading"
			Loading.Parent = Main
			Loading.BackgroundColor3 = GetTheme().Secondary
			Loading.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Loading.BorderSizePixel = 0
			Loading.Size = UDim2.new(1, 0, 1, 0)
			Loading.Visible = false
			Loading.ZIndex = 1999999999
			UICorner_5.CornerRadius = UDim.new(0, 12)
			UICorner_5.Parent = Loading
			UIStroke1_3.Color = GetTheme().Accent
			UIStroke1_3.Thickness = 3
			UIStroke1_3.Transparency = 0.699999988079071
			UIStroke1_3.Name = "UIStroke1"
			UIStroke1_3.Parent = Loading
			UIStroke2_3.Color = GetTheme().SubText
			UIStroke2_3.Thickness = 1.5
			UIStroke2_3.Transparency = 0.8999999761581421
			UIStroke2_3.Name = "UIStroke2"
			UIStroke2_3.Parent = Loading
			Icon.Name = "Icon"
			Icon.Parent = Loading
			Icon.Image = "rbxassetid://117102312939397"
			Icon.ImageTransparency = 1
			Icon.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Icon.BackgroundTransparency = 1
			Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Icon.BorderSizePixel = 0
			Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
			Icon.Size = UDim2.new(0.600000024, 0, 0.600000024, 0)
			UIAspectRatioConstraint_2.Parent = Icon
			Requirements.Name = "Requirements"
			Requirements.Parent = Loading
			Requirements.AnchorPoint = Vector2.new(0.5, 0.5)
			Requirements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Requirements.BackgroundTransparency = 1
			Requirements.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Requirements.BorderSizePixel = 0
			Requirements.Position = UDim2.new(0.65531832, 0, 0.49999994, 0)
			Requirements.Size = UDim2.new(0.600000024, 0, 0.600000024, 0)
			UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_2.Parent = Requirements
			Configuration.Parent = Loading
			RequirementText.FontFace =
				Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			RequirementText.Text = "\u{420}\u{406}\u{421}\u{459}\u{432}\u{402}\u{a6} Requirements Successfully"
			RequirementText.TextColor3 = Color3.fromRGB(255, 255, 255)
			RequirementText.TextScaled = true
			RequirementText.TextSize = 37
			RequirementText.TextWrapped = true
			RequirementText.TextXAlignment = Enum.TextXAlignment.Left
			RequirementText.Name = "RequirementText"
			RequirementText.Parent = Configuration
			RequirementText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			RequirementText.BackgroundTransparency = 1
			RequirementText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			RequirementText.BorderSizePixel = 0
			RequirementText.Size = UDim2.new(0, 305, 0, 33)
			UIPadding_5.PaddingBottom = UDim.new(0, 5)
			UIPadding_5.PaddingTop = UDim.new(0, 5)
			UIPadding_5.Parent = RequirementText
			BusyOverlay.Name = "BusyOverlay"
			BusyOverlay.Parent = Main
			BusyOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			BusyOverlay.BackgroundTransparency = 1
			BusyOverlay.BorderSizePixel = 0
			BusyOverlay.Size = UDim2.fromScale(1, 1)
			BusyOverlay.Visible = false
			BusyOverlay.Active = false
			BusyOverlay.ZIndex = 140
			BusyOverlayCorner.CornerRadius = UDim.new(0, 12)
			BusyOverlayCorner.Parent = BusyOverlay
			BusyCard.Name = "BusyCard"
			BusyCard.Parent = BusyOverlay
			BusyCard.AnchorPoint = Vector2.new(0.5, 0.5)
			BusyCard.Position = UDim2.fromScale(0.5, 0.5)
			BusyCard.Size = UDim2.fromOffset(220, 56)
			BusyCard.BackgroundColor3 = GetTheme().Secondary
			BusyCard.BackgroundTransparency = 1
			BusyCard.BorderSizePixel = 0
			BusyCard.ZIndex = 141
			BusyCard.ClipsDescendants = true
			BusyCardCorner.CornerRadius = UDim.new(0, 12)
			BusyCardCorner.Parent = BusyCard
			BusyCardStroke.Color = BlendColor(GetTheme().Accent, GetTheme().Secondary, 0.38)
			BusyCardStroke.Transparency = 1
			BusyCardStroke.Thickness = 1
			BusyCardStroke.Parent = BusyCard
			local BusyAccentBar
			do
				BusyAccentBar = Instance.new("Frame")
				BusyAccentBar.Name = "AccentBar"
				BusyAccentBar.Parent = BusyCard
				BusyAccentBar.AnchorPoint = Vector2.new(0.5, 0)
				BusyAccentBar.Position = UDim2.new(0.5, 0, 0, 0)
				BusyAccentBar.Size = UDim2.new(0.5, 0, 0, 2)
				BusyAccentBar.BackgroundColor3 = GetTheme().Accent
				BusyAccentBar.BackgroundTransparency = 1
				BusyAccentBar.BorderSizePixel = 0
				BusyAccentBar.ZIndex = 143
				local AccentBarCorner = Instance.new("UICorner")
				AccentBarCorner.CornerRadius = UDim.new(1, 0)
				AccentBarCorner.Parent = BusyAccentBar
			end
			BusyIcon.Name = "BusyIcon"
			BusyIcon.Parent = BusyCard
			BusyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			BusyIcon.Position = UDim2.new(0.13, 0, 0.5, 0)
			BusyIcon.Size = UDim2.fromOffset(16, 16)
			BusyIcon.BackgroundTransparency = 1
			BusyIcon.Image = "rbxassetid://89142505387395"
			BusyIcon.ImageColor3 = GetTheme().Accent
			BusyIcon.ImageTransparency = 1
			BusyIcon.ScaleType = Enum.ScaleType.Fit
			BusyIcon.ZIndex = 142
			BusyIconAspect.Parent = BusyIcon
			BusyText.Name = "BusyText"
			BusyText.Parent = BusyCard
			BusyText.BackgroundTransparency = 1
			BusyText.AnchorPoint = Vector2.new(0, 0.5)
			BusyText.Position = UDim2.new(0.22, 0, 0.5, 0)
			BusyText.Size = UDim2.new(0.74, 0, 0.72, 0)
			BusyText.Font = Enum.Font.GothamMedium
			BusyText.Text = "Loading..."
			BusyText.TextColor3 = GetTheme().Text
			BusyText.TextSize = 13
			BusyText.TextTransparency = 1
			BusyText.TextWrapped = true
			BusyText.TextXAlignment = Enum.TextXAlignment.Left
			BusyText.TextYAlignment = Enum.TextYAlignment.Center
			BusyText.ZIndex = 142
			Line.Name = "Line"
			Line.Parent = Window
			Line.AnchorPoint = Vector2.new(0.5, 0.5)
			Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Line.BackgroundTransparency = 0.8999999761581421
			Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Line.BorderSizePixel = 0
			Line.Position = UDim2.new(0.5, 0, 0.172000006, 0)
			Line.Size = UDim2.new(0.949999988, 0, 0, 1)
			UIAspectRatioConstraint_3.AspectRatio = 1.6257143020629883
			UIAspectRatioConstraint_3.Parent = Window
			UIStroke.Color = Color3.fromRGB(255, 255, 255)
			UIStroke.Thickness = 2
			UIStroke.Transparency = 0.699999988079071
			UIStroke.Parent = Window
			UIStroke1_4.Thickness = 4
			UIStroke1_4.Transparency = 0.5
			UIStroke1_4.Name = "UIStroke1"
			UIStroke1_4.Parent = Window

			local CloseButton = Instance.new("TextButton")

			CloseButton.Name = "CloseButton"
			CloseButton.AnchorPoint = Vector2.new(1, 0)
			CloseButton.Position = UDim2.new(1, -10, 0, 8)
			CloseButton.Size = UDim2.fromOffset(28, 24)
			CloseButton.BackgroundColor3 = BlendColor(GetTheme().Primary, GetTheme().Secondary, 0.15)
			CloseButton.Text = ""
			CloseButton.AutoButtonColor = false
			CloseButton.BorderSizePixel = 0
			CloseButton.ZIndex = 12
			CloseButton.Parent = Window

			local CloseButtonCorner = Instance.new("UICorner")
			CloseButtonCorner.CornerRadius = UDim.new(0, 8)
			CloseButtonCorner.Parent = CloseButton

			local CloseButtonStroke = Instance.new("UIStroke")
			CloseButtonStroke.Color = BlendColor(GetTheme().Accent, GetTheme().Secondary, 0.42)
			CloseButtonStroke.Thickness = 1
			CloseButtonStroke.Transparency = 0.2
			CloseButtonStroke.Parent = CloseButton

			local CloseButtonText = Instance.new("TextLabel")
			CloseButtonText.Name = "Text"
			CloseButtonText.Size = UDim2.fromScale(1, 1)
			CloseButtonText.BackgroundTransparency = 1
			CloseButtonText.Text = "X"
			CloseButtonText.TextColor3 = GetTheme().Text
			CloseButtonText.Font = Enum.Font.GothamBold
			CloseButtonText.TextSize = 13
			CloseButtonText.ZIndex = 13
			CloseButtonText.Parent = CloseButton

			local GearButton = Instance.new("TextButton")
			GearButton.Name = "GearButton"
			GearButton.AnchorPoint = Vector2.new(1, 0)
			GearButton.Position = UDim2.new(1, -44, 0, 8)
			GearButton.Size = UDim2.fromOffset(28, 24)
			GearButton.BackgroundColor3 = BlendColor(GetTheme().Primary, GetTheme().Secondary, 0.15)
			GearButton.Text = ""
			GearButton.AutoButtonColor = false
			GearButton.BorderSizePixel = 0
			GearButton.ZIndex = 12
			GearButton.Visible = false
			GearButton.Parent = Window

			local GearButtonCorner = Instance.new("UICorner")
			GearButtonCorner.CornerRadius = UDim.new(0, 8)
			GearButtonCorner.Parent = GearButton

			local GearButtonStroke = Instance.new("UIStroke")
			GearButtonStroke.Color = BlendColor(GetTheme().Accent, GetTheme().Secondary, 0.42)
			GearButtonStroke.Thickness = 1
			GearButtonStroke.Transparency = 0.2
			GearButtonStroke.Parent = GearButton

			local GearIcon = Instance.new("ImageLabel")
			GearIcon.Name = "GearIcon"
			GearIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			GearIcon.Position = UDim2.fromScale(0.5, 0.5)
			GearIcon.Size = UDim2.fromOffset(13, 13)
			GearIcon.BackgroundTransparency = 1
			GearIcon.ImageColor3 = GetTheme().SubText
			GearIcon.ScaleType = Enum.ScaleType.Fit
			GearIcon.ZIndex = 13
			GearIcon.Parent = GearButton
			do
				local ok, ic = pcall(Lucide.GetAsset, "settings")
				if ok and ic then
					GearIcon.Image = ic.Url
					GearIcon.ImageRectSize = ic.ImageRectSize
					GearIcon.ImageRectOffset = ic.ImageRectOffset
				end
			end

			local AdvPanel = Instance.new("Frame")
			AdvPanel.Name = "AdvancedSettingsPanel"
			AdvPanel.AnchorPoint = Vector2.new(0.5, 0)
			AdvPanel.Position = UDim2.new(0.5, 0, 0, -8)
			AdvPanel.Size = UDim2.new(1, -20, 0, 0)
			AdvPanel.AutomaticSize = Enum.AutomaticSize.Y
			AdvPanel.BackgroundColor3 = GetTheme().Secondary
			AdvPanel.BorderSizePixel = 0
			AdvPanel.ZIndex = 35
			AdvPanel.Visible = false
			AdvPanel.ClipsDescendants = false
			AdvPanel.Parent = Window

			local AdvPanelCorner = Instance.new("UICorner")
			AdvPanelCorner.CornerRadius = UDim.new(0, 10)
			AdvPanelCorner.Parent = AdvPanel

			local AdvPanelStroke = Instance.new("UIStroke")
			AdvPanelStroke.Color = GetTheme().Accent
			AdvPanelStroke.Thickness = 1
			AdvPanelStroke.Transparency = 0.45
			AdvPanelStroke.Parent = AdvPanel

			local AdvPanelLayout = Instance.new("UIListLayout")
			AdvPanelLayout.Padding = UDim.new(0, 0)
			AdvPanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
			AdvPanelLayout.Parent = AdvPanel

			local AdvPanelHeader = Instance.new("Frame")
			AdvPanelHeader.Size = UDim2.new(1, 0, 0, 36)
			AdvPanelHeader.BackgroundColor3 = BlendColor(GetTheme().Secondary, GetTheme().Primary, 0.4)
			AdvPanelHeader.BorderSizePixel = 0
			AdvPanelHeader.LayoutOrder = 0
			AdvPanelHeader.Parent = AdvPanel
			local AdvPanelHeaderCorner = Instance.new("UICorner")
			AdvPanelHeaderCorner.CornerRadius = UDim.new(0, 10)
			AdvPanelHeaderCorner.Parent = AdvPanelHeader

			local AdvPanelTitle = Instance.new("TextLabel")
			AdvPanelTitle.Size = UDim2.new(1, -16, 1, 0)
			AdvPanelTitle.Position = UDim2.fromOffset(12, 0)
			AdvPanelTitle.BackgroundTransparency = 1
			AdvPanelTitle.Text = "Advanced Settings"
			AdvPanelTitle.TextColor3 = GetTheme().Text
			AdvPanelTitle.Font = Enum.Font.GothamBold
			AdvPanelTitle.TextSize = 13
			AdvPanelTitle.TextXAlignment = Enum.TextXAlignment.Left
			AdvPanelTitle.ZIndex = 36
			AdvPanelTitle.Parent = AdvPanelHeader

			local AdvPanelContent = Instance.new("ScrollingFrame")
			AdvPanelContent.Name = "AdvContent"
			AdvPanelContent.Size = UDim2.new(1, 0, 0, 0)
			AdvPanelContent.CanvasSize = UDim2.new(0, 0, 0, 0)
			AdvPanelContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
			AdvPanelContent.BackgroundTransparency = 1
			AdvPanelContent.BorderSizePixel = 0
			AdvPanelContent.ScrollBarThickness = 4
			AdvPanelContent.ScrollBarImageColor3 = GetTheme().Accent
			AdvPanelContent.LayoutOrder = 1
			AdvPanelContent.ZIndex = 36
			AdvPanelContent.Parent = AdvPanel
			AdvPanelContent.Size = UDim2.new(1, 0, 0, 240)

			local AdvContentLayout = Instance.new("UIListLayout")
			AdvContentLayout.Padding = UDim.new(0, 6)
			AdvContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			AdvContentLayout.Parent = AdvPanelContent

			local AdvContentPadding = Instance.new("UIPadding")
			AdvContentPadding.PaddingTop = UDim.new(0, 6)
			AdvContentPadding.PaddingBottom = UDim.new(0, 6)
			AdvContentPadding.PaddingLeft = UDim.new(0, 6)
			AdvContentPadding.PaddingRight = UDim.new(0, 6)
			AdvContentPadding.Parent = AdvPanelContent

			local advSyncedElements = {}
			local advPanelSettingsPage = nil
			local advPanelOpen = false

			local function setAdvPanelOpen(state)
				advPanelOpen = state
				if state then
					AdvPanel.Visible = true
					AdvPanel.Position = UDim2.new(0.5, 0, 0, -8)
					spr.target(AdvPanel, 0.72, 7, { Position = UDim2.new(0.5, 0, 0, 44) })
					spr.target(GearIcon, 0.65, 6, { ImageColor3 = GetTheme().Accent })
				else
					spr.target(AdvPanel, 0.72, 7, { Position = UDim2.new(0.5, 0, 0, -8) })
					spr.target(GearIcon, 0.65, 6, { ImageColor3 = GetTheme().SubText })
					task.delay(0.15, function()
						if not advPanelOpen then
							AdvPanel.Visible = false
						end
					end)
				end
			end

			AttachButtonSpring(GearButton, GearButton, function(state, t)
				if state.down then
					return BlendColor(t.Primary, t.Accent, 0.22)
				end
				if state.hover then
					return BlendColor(t.Primary, t.Secondary, 0.5)
				end
				return BlendColor(t.Primary, t.Secondary, 0.15)
			end)

			GearButton.Activated:Connect(function()
				setAdvPanelOpen(not advPanelOpen)
			end)

			function Tabs:ToggleAdvancedSettings(settingsTabHandle, config)
				config = config or {}
				local settingsTabFrame = nil
				for _, child in ipairs(Main.Tabs:GetChildren()) do
					local n = child.Name:lower()
					if n == "settings" or n:find("setting") then
						settingsTabFrame = child
						break
					end
				end
				if settingsTabFrame then
					settingsTabFrame.Visible = false
				end

				GearButton.Visible = true
				local settingsPage = nil
				for _, child in ipairs(Main.Pages:GetChildren()) do
					local n = child.Name:lower()
					if n == "settings" or n:find("setting") then
						settingsPage = child
						break
					end
				end

				if settingsPage then
					local pageMain = settingsPage:FindFirstChild("Main")
					if pageMain and pageMain:IsA("ScrollingFrame") then
						AdvPanelContent:Destroy()

						pageMain.Parent = AdvPanel
						pageMain.LayoutOrder = 1
						pageMain.Size = UDim2.new(1, 0, 0, 240)
						pageMain.ZIndex = 36
						pageMain.Visible = true

						local origPageVisible = settingsPage.Visible
						settingsPage.Visible = false
					end
				end
			end

			local WindowTransitionOverlay = Instance.new("Frame")

			WindowTransitionOverlay.Name = "WindowTransitionOverlay"
			WindowTransitionOverlay.Size = UDim2.fromScale(1, 1)
			WindowTransitionOverlay.BackgroundColor3 = BlendColor(GetTheme().Secondary, Color3.fromRGB(0, 0, 0), 0.35)
			WindowTransitionOverlay.BackgroundTransparency = 1
			WindowTransitionOverlay.BorderSizePixel = 0
			WindowTransitionOverlay.Visible = false
			WindowTransitionOverlay.ZIndex = 39
			WindowTransitionOverlay.Parent = Window

			local WindowTransitionCorner = Instance.new("UICorner")

			WindowTransitionCorner.CornerRadius = UDim.new(0, 12)
			WindowTransitionCorner.Parent = WindowTransitionOverlay

			local CloseConfirmOverlay = Instance.new("Frame")

			CloseConfirmOverlay.Name = "CloseConfirmOverlay"
			CloseConfirmOverlay.Size = UDim2.fromScale(1, 1)
			CloseConfirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			CloseConfirmOverlay.BackgroundTransparency = 0.32
			CloseConfirmOverlay.BorderSizePixel = 0
			CloseConfirmOverlay.Active = true
			CloseConfirmOverlay.Visible = false
			CloseConfirmOverlay.ZIndex = 40
			CloseConfirmOverlay.Parent = Window

			local CloseConfirmCard = Instance.new("Frame")

			CloseConfirmCard.Name = "Card"
			CloseConfirmCard.AnchorPoint = Vector2.new(0.5, 0.5)
			CloseConfirmCard.Position = UDim2.fromScale(0.5, 0.5)
			CloseConfirmCard.Size = UDim2.fromOffset(322, 170)
			CloseConfirmCard.BackgroundColor3 = GetTheme().Secondary
			CloseConfirmCard.BorderSizePixel = 0
			CloseConfirmCard.ZIndex = 41
			CloseConfirmCard.Parent = CloseConfirmOverlay

			local CloseConfirmCardScale = Instance.new("UIScale")

			CloseConfirmCardScale.Name = "CardScale"
			CloseConfirmCardScale.Scale = 1
			CloseConfirmCardScale.Parent = CloseConfirmCard

			local CloseConfirmCardCorner = Instance.new("UICorner")

			CloseConfirmCardCorner.CornerRadius = UDim.new(0, 12)
			CloseConfirmCardCorner.Parent = CloseConfirmCard

			local CloseConfirmCardStroke = Instance.new("UIStroke")

			CloseConfirmCardStroke.Color = BlendColor(GetTheme().Accent, GetTheme().Secondary, 0.35)
			CloseConfirmCardStroke.Thickness = 1.25
			CloseConfirmCardStroke.Transparency = 0.12
			CloseConfirmCardStroke.Parent = CloseConfirmCard

			local CloseConfirmTitle = Instance.new("TextLabel")

			CloseConfirmTitle.Name = "Title"
			CloseConfirmTitle.Size = UDim2.new(1, -20, 0, 28)
			CloseConfirmTitle.Position = UDim2.fromOffset(10, 12)
			CloseConfirmTitle.BackgroundTransparency = 1
			CloseConfirmTitle.Text = "Unload Vanish?"
			CloseConfirmTitle.TextColor3 = GetTheme().Text
			CloseConfirmTitle.TextXAlignment = Enum.TextXAlignment.Left
			CloseConfirmTitle.Font = Enum.Font.GothamBold
			CloseConfirmTitle.TextSize = 17
			CloseConfirmTitle.ZIndex = 42
			CloseConfirmTitle.Parent = CloseConfirmCard

			local CloseConfirmBody = Instance.new("TextLabel")

			CloseConfirmBody.Name = "Body"
			CloseConfirmBody.Size = UDim2.new(1, -20, 0, 64)
			CloseConfirmBody.Position = UDim2.fromOffset(10, 42)
			CloseConfirmBody.BackgroundTransparency = 1
			CloseConfirmBody.Text =
				"This will disable all runtime features, disconnect active connections, reset visual/runtime effects, and close the UI."
			CloseConfirmBody.TextColor3 = GetTheme().SubText
			CloseConfirmBody.TextWrapped = true
			CloseConfirmBody.TextXAlignment = Enum.TextXAlignment.Left
			CloseConfirmBody.TextYAlignment = Enum.TextYAlignment.Top
			CloseConfirmBody.Font = Enum.Font.Gotham
			CloseConfirmBody.TextSize = 13
			CloseConfirmBody.ZIndex = 42
			CloseConfirmBody.Parent = CloseConfirmCard

			local CloseCancelButton = Instance.new("TextButton")

			CloseCancelButton.Name = "Cancel"
			CloseCancelButton.Size = UDim2.fromOffset(138, 34)
			CloseCancelButton.Position = UDim2.new(0, 10, 1, -46)
			CloseCancelButton.BackgroundColor3 = GetTheme().Primary
			CloseCancelButton.Text = "Cancel"
			CloseCancelButton.TextColor3 = GetTheme().Text
			CloseCancelButton.AutoButtonColor = false
			CloseCancelButton.Font = Enum.Font.GothamBold
			CloseCancelButton.TextSize = 13
			CloseCancelButton.BorderSizePixel = 0
			CloseCancelButton.ZIndex = 42
			CloseCancelButton.Parent = CloseConfirmCard

			local CloseCancelCorner = Instance.new("UICorner")

			CloseCancelCorner.CornerRadius = UDim.new(0, 8)
			CloseCancelCorner.Parent = CloseCancelButton

			local CloseConfirmButton = Instance.new("TextButton")

			CloseConfirmButton.Name = "Confirm"
			CloseConfirmButton.Size = UDim2.fromOffset(154, 34)
			CloseConfirmButton.Position = UDim2.new(1, -164, 1, -46)
			CloseConfirmButton.BackgroundColor3 = Color3.fromRGB(153, 44, 44)
			CloseConfirmButton.Text = "Confirm Unload"
			CloseConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			CloseConfirmButton.AutoButtonColor = false
			CloseConfirmButton.Font = Enum.Font.GothamBold
			CloseConfirmButton.TextSize = 13
			CloseConfirmButton.BorderSizePixel = 0
			CloseConfirmButton.ZIndex = 42
			CloseConfirmButton.Parent = CloseConfirmCard

			local CloseConfirmCorner = Instance.new("UICorner")

			CloseConfirmCorner.CornerRadius = UDim.new(0, 8)
			CloseConfirmCorner.Parent = CloseConfirmButton

			AttachButtonSpring(CloseCancelButton, CloseCancelButton, function(state, theme)
				if state.down then
					return BlendColor(theme.Primary, theme.Secondary, 0.28)
				elseif state.hover then
					return BlendColor(theme.Primary, theme.Accent, 0.08)
				end

				return theme.Primary
			end)
			AttachButtonSpring(CloseConfirmButton, CloseConfirmButton, function(state)
				local base = Color3.fromRGB(153, 44, 44)

				if state.down then
					return BlendColor(base, Color3.fromRGB(255, 255, 255), 0.08)
				elseif state.hover then
					return BlendColor(base, Color3.fromRGB(255, 255, 255), 0.14)
				end

				return base
			end)

			local closeInProgress = false
			local closeConfirmToken = 0

			local function HideCloseConfirm(immediate)
				closeConfirmToken += 1

				local activeToken = closeConfirmToken

				if immediate then
					CloseConfirmOverlay.Visible = false
					CloseConfirmOverlay.BackgroundTransparency = 0.32
					CloseConfirmCard.Position = UDim2.fromScale(0.5, 0.5)
					CloseConfirmCard.BackgroundTransparency = 0
					CloseConfirmCardScale.Scale = 1
					CloseConfirmCardStroke.Transparency = 0.12

					return
				end

				spr.target(CloseConfirmOverlay, 0.78, 6, { BackgroundTransparency = 1 })
				spr.target(CloseConfirmCard, 0.82, 6, {
					Position = UDim2.fromScale(0.5, 0.535),
					BackgroundTransparency = 0.08,
				})
				spr.target(CloseConfirmCardScale, 0.82, 6, { Scale = 0.96 })
				spr.target(CloseConfirmCardStroke, 0.82, 6, { Transparency = 0.42 })
				task.delay(0.16, function()
					if closeConfirmToken ~= activeToken then
						return
					end

					HideCloseConfirm(true)
				end)
			end
			local function ShowCloseConfirm()
				if closeInProgress then
					return
				end

				closeConfirmToken += 1

				CloseConfirmOverlay.Visible = true
				CloseConfirmOverlay.BackgroundTransparency = 1
				CloseConfirmCard.Position = UDim2.fromScale(0.5, 0.535)
				CloseConfirmCard.BackgroundTransparency = 0.08
				CloseConfirmCardScale.Scale = 0.96
				CloseConfirmCardStroke.Transparency = 0.42

				spr.target(CloseConfirmOverlay, 0.78, 6, { BackgroundTransparency = 0.32 })
				spr.target(CloseConfirmCard, 0.82, 6, {
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 0,
				})
				spr.target(CloseConfirmCardScale, 0.82, 6, { Scale = 1 })
				spr.target(CloseConfirmCardStroke, 0.82, 6, { Transparency = 0.12 })
			end
			local function ConfirmAndClose()
				if closeInProgress then
					return
				end

				closeInProgress = true

				HideCloseConfirm(true)

				WindowTransitionOverlay.Visible = true
				WindowTransitionOverlay.BackgroundTransparency = 1

				spr.target(WindowTransitionOverlay, 0.72, 6, { BackgroundTransparency = 0.05 })
				spr.target(Window, 0.8, 6, { BackgroundTransparency = 0.04 })
				task.delay(0.14, function()
					pcall(function()
						Config.Unload()
					end)
					pcall(function()
						if UI and UI.Parent then
							UI:Destroy()
						end
					end)
				end)
			end

			Library.ConnectionsList[Title.Text .. " ActiveClose"] = CloseButton.Activated:Connect(function()
				if closeInProgress then
					return
				end

				ShowCloseConfirm()
			end)
			Library.ConnectionsList[Title.Text .. " HideClose"] = CloseCancelButton.Activated:Connect(HideCloseConfirm)
			Library.ConnectionsList[Title.Text .. " CloseComfirmYes"] =
				CloseConfirmButton.Activated:Connect(ConfirmAndClose)
			Library.ConnectionsList[Title.Text .. " CloseComfirmHide"] = CloseConfirmOverlay.InputBegan:Connect(
				function(input)
					if
						input.UserInputType ~= Enum.UserInputType.MouseButton1
						and input.UserInputType ~= Enum.UserInputType.Touch
					then
						return
					end

					local cursorPos = input.Position
					local cardPos = CloseConfirmCard.AbsolutePosition
					local cardSize = CloseConfirmCard.AbsoluteSize
					local insideCard = cursorPos.X >= cardPos.X
						and cursorPos.X <= cardPos.X + cardSize.X
						and cursorPos.Y >= cardPos.Y
						and cursorPos.Y <= cardPos.Y + cardSize.Y

					if not insideCard then
						HideCloseConfirm()
					end
				end
			)

			local ResizeHandle = Instance.new("Frame")

			ResizeHandle.Name = "ResizeHandle"
			ResizeHandle.AnchorPoint = Vector2.new(1, 1)
			ResizeHandle.Position = UDim2.new(1, -8, 1, -8)
			ResizeHandle.Size = UDim2.fromOffset(36, 36)
			ResizeHandle.BackgroundTransparency = 1
			ResizeHandle.BorderSizePixel = 0
			ResizeHandle.ZIndex = 9
			ResizeHandle.Visible = true
			ResizeHandle.Parent = Window

			local ResizeHandleScale = Instance.new("UIScale")

			ResizeHandleScale.Name = "ResizeHandleScale"
			ResizeHandleScale.Scale = 1
			ResizeHandleScale.Parent = ResizeHandle

			local ResizePill = Instance.new("Frame")

			ResizePill.Name = "ResizePill"
			ResizePill.AnchorPoint = Vector2.new(0.5, 0.5)
			ResizePill.Position = UDim2.fromScale(0.5, 0.5)
			ResizePill.Size = UDim2.fromOffset(24, 24)
			ResizePill.BackgroundColor3 = BlendColor(GetTheme().Secondary, GetTheme().Accent, 0.12)
			ResizePill.BackgroundTransparency = 0.15
			ResizePill.BorderSizePixel = 0
			ResizePill.ZIndex = 9
			ResizePill.Parent = ResizeHandle

			local ResizePillCorner = Instance.new("UICorner")

			ResizePillCorner.CornerRadius = UDim.new(0, 12)
			ResizePillCorner.Parent = ResizePill

			local ResizePillStroke = Instance.new("UIStroke")

			ResizePillStroke.Name = "ResizePillStroke"
			ResizePillStroke.Color = GetTheme().Accent
			ResizePillStroke.Thickness = 1.2
			ResizePillStroke.Transparency = 0.35
			ResizePillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ResizePillStroke.Parent = ResizePill

			local ResizeButton = Instance.new("TextButton")

			ResizeButton.Name = "ResizeButton"
			ResizeButton.Size = UDim2.fromScale(1, 1)
			ResizeButton.BackgroundTransparency = 1
			ResizeButton.Text = ""
			ResizeButton.ZIndex = 11
			ResizeButton.AutoButtonColor = false
			ResizeButton.Parent = ResizeHandle

			local gripLinePositions = { 0.35, 0.65 }
			local ResizeGripLines = {}

			for i, yScale in ipairs(gripLinePositions) do
				local line = Instance.new("Frame")

				line.Name = "GripLine" .. i
				line.AnchorPoint = Vector2.new(0.5, 0.5)
				line.Position = UDim2.new(0.5, 0, yScale, 0)
				line.Size = UDim2.new(0.45, 0, 0, 1.2)
				line.BackgroundColor3 = GetTheme().Accent
				line.BackgroundTransparency = 0.25
				line.BorderSizePixel = 0
				line.ZIndex = 10
				line.Parent = ResizePill

				local lineCorner = Instance.new("UICorner")

				lineCorner.CornerRadius = UDim.new(1, 0)
				lineCorner.Parent = line
				ResizeGripLines[i] = line
			end

			local function UpdateResizeButtonPosition()
				if not ResizeHandle then
					return
				end

				local resizeEnabled = true

				ResizeHandle.Visible = resizeEnabled

				if not resizeEnabled then
					return
				end

				ResizeHandle.Position = UDim2.new(1, -8, 1, -8)
			end

			local lastAppliedScale = nil
			local lastResizeEnabled = nil

			local function IsResizeEnabled()
				return true
			end
			local function ApplyWindowResizeDelta(deltaX)
				if not IsResizeEnabled() then
					return
				end
				if not ResizeDragStartSize then
					return
				end

				local viewport = Camera.ViewportSize
				local aspect = UIAspectRatioConstraint_3.AspectRatio

				if aspect <= 0 then
					aspect = 1.6257
				end

				local maxWidth = math.max(400, math.floor(viewport.X * RESIZE_MAX_VIEWPORT_RATIO))
				local rawMin = math.max(RESIZE_MIN_WIDTH, math.floor(viewport.X * 0.36))
				local minWidth = math.min(rawMin, maxWidth)
				local width = math.clamp(ResizeDragStartSize.X + deltaX, minWidth, maxWidth)
				local height = math.floor(width / aspect + 0.5)
				local maxHeight = math.max(220, math.floor(viewport.Y * 0.96))
				local minHeight = math.min(math.max(RESIZE_MIN_HEIGHT, math.floor(minWidth / aspect + 0.5)), maxHeight)

				if height < minHeight then
					height = minHeight
					width = math.floor(height * aspect + 0.5)
				elseif height > maxHeight then
					height = maxHeight
					width = math.floor(height * aspect + 0.5)
				end

				width = math.clamp(width, minWidth, maxWidth)
				height = math.clamp(math.floor(width / aspect + 0.5), minHeight, maxHeight)
				Window.Size = UDim2.fromOffset(width, height)

				UpdateTabsFunction()
				UpdateResizeButtonPosition()
			end

			local resizeVisualState = {
				hover = false,
				dragging = false,
			}

			local function ApplyResizeVisualState()
				local theme = GetTheme()
				local isDragging = resizeVisualState.dragging
				local isHover = resizeVisualState.hover
				local pillColor

				if isDragging then
					pillColor = BlendColor(theme.Accent, theme.Secondary, 0.25)
				elseif isHover then
					pillColor = BlendColor(theme.Secondary, theme.Accent, 0.18)
				else
					pillColor = BlendColor(theme.Secondary, theme.Accent, 0.08)
				end

				spr.target(ResizePill, 0.65, 7, {
					BackgroundColor3 = pillColor,
					BackgroundTransparency = isDragging and 0.05 or (isHover and 0.1 or 0.18),
				})

				local strokeTrans = isDragging and 0.08 or (isHover and 0.25 or 0.55)

				spr.target(ResizePillStroke, 0.65, 7, {
					Color = theme.Accent,
					Transparency = strokeTrans,
				})

				local lineTrans = isDragging and 0.1 or (isHover and 0.25 or 0.45)

				for _, line in ipairs(ResizeGripLines) do
					spr.target(line, 0.65, 7, {
						BackgroundColor3 = theme.Accent,
						BackgroundTransparency = lineTrans,
					})
				end

				local scaleGoal = isDragging and 1.12 or (isHover and 1.07 or 1)

				spr.target(ResizeHandleScale, 0.65, 7, { Scale = scaleGoal })

				local pillSize = isDragging and 18 or (isHover and 17 or 16)

				spr.target(ResizePill, 0.65, 7, {
					Size = UDim2.fromOffset(pillSize, pillSize),
				})
			end

			Library.ConnectionsList[Title.Text .. " ResizeEnter"] = ResizeButton.MouseEnter:Connect(function()
				resizeVisualState.hover = true

				ApplyResizeVisualState()
			end)
			Library.ConnectionsList[Title.Text .. " ResizeLeave"] = ResizeButton.MouseLeave:Connect(function()
				resizeVisualState.hover = false

				if not ResizeDragActive then
					ApplyResizeVisualState()
				end
			end)
			Library.ConnectionsList[Title.Text .. " MobileResizeStart"] = ResizeButton.InputBegan:Connect(
				function(input)
					if not ResizeHandle.Visible then
						return
					end
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						ResizeDragActive = true
						ResizeDragInput = input
						ResizeDragStartPos = input.Position
						ResizeDragStartSize = Window.AbsoluteSize
						resizeVisualState.dragging = true

						ApplyResizeVisualState()
						Library.ConnectionsList[Title.Text .. " MobileResizeEnd"] = input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								ResizeDragActive = false
								ResizeDragInput = nil
								ResizeDragStartPos = nil
								ResizeDragStartSize = nil
								resizeVisualState.dragging = false
								resizeVisualState.hover = false

								ApplyResizeVisualState()
							end
						end)
					end
				end
			)
			Library.ConnectionsList[Title.Text .. " Resize InputChange"] = ResizeButton.InputChanged:Connect(
				function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						ResizeDragInput = input
					end
				end
			)
			Library.ConnectionsList[Title.Text .. " Resize InputChanged"] = UserInputService.InputChanged:Connect(
				function(input)
					if not ResizeHandle.Visible then
						return
					end
					if not ResizeDragActive then
						return
					end
					if not ResizeDragStartPos then
						return
					end
					local isSameInput = (input == ResizeDragInput)
						or (
							ResizeDragInput
							and ResizeDragInput.UserInputType == Enum.UserInputType.Touch
							and input.UserInputType == Enum.UserInputType.Touch
						)
					if not isSameInput then
						return
					end

					local deltaX = input.Position.X - ResizeDragStartPos.X

					ApplyWindowResizeDelta(deltaX)
				end
			)
			Library.ConnectionsList[Title.Text .. " Resize InputEnd"] = UserInputService.InputEnded:Connect(
				function(input)
					if input == ResizeDragInput then
						ResizeDragActive = false
						ResizeDragInput = nil
						ResizeDragStartPos = nil
						ResizeDragStartSize = nil
						resizeVisualState.dragging = false
						resizeVisualState.hover = false

						ApplyResizeVisualState()
					end
				end
			)
			local function UpdateLayoutScale()
				local scale = CalculateUIScale()
				local isMobile = GetDeviceType() == "Mobile"

				local tabHeight = isMobile and (37 * scale) or (42.5 * scale)
				TabsGridLayout.CellSize = UDim2.new(1, 0, 0, tabHeight)

				UIPadding_3.PaddingBottom = UDim.new(0, 6 * scale)
				UIPadding_3.PaddingLeft = UDim.new(0, 6 * scale)
				UIPadding_3.PaddingRight = UDim.new(0, 6 * scale)
				UIPadding_3.PaddingTop = UDim.new(0, 6 * scale)

				if TabsGridLayout then
					TabsGridLayout:ApplyLayout()
				end
				if Main:GetChildren() then
					for _, child in ipairs(Main:GetChildren()) do
						if child:IsA("UIListLayout") or child:IsA("UIGridLayout") then
							child:ApplyLayout()
						end
					end
				end
			end

			Library.ConnectionsList[Title.Text .. " Changed AbsoluteSize"] =
				Window:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateLayoutScale)
			UpdateLayoutScale()
			Library.ConnectionsList[Title.Text .. " Changed Camera"] = Camera:GetPropertyChangedSignal("ViewportSize")
				:Connect(function()
					UpdateAllElementSizes()
					UpdateTabsFunction()
					UpdateResizeButtonPosition()
					UpdateLayoutScale()
				end)
			UpdateResizeButtonPosition()
			task.spawn(function()
				local dragging
				local dragInput
				local dragStart
				local startPos

				local function Lerp(a, b, m)
					return a + (b - a) * m
				end

				local lastMousePos
				local lastGoalPos
				local DRAG_SPEED = 8
				local heartbeatConnection

				local function Slider_ColorPickerCheck()
					if not Main or not Main.Parent then
						return false
					end

					local pagesObj = Main:FindFirstChild("Pages")

					if not pagesObj then
						return false
					end

					for i, v in pairs(pagesObj:GetChildren()) do
						if v:IsA("Frame") and v.Visible == true then
							for a, b in pairs(v:GetChildren()) do
								if
									b:IsA("Frame")
									and (b.Name == "ColorPicker" or b.Name == "Slider")
									and b:GetAttribute("Working") == true
								then
									return true
								end
							end
						end
					end

					return false
				end
				local function Update(dt)
					if not Window or not Window.Parent or not Main or not Main.Parent then
						if heartbeatConnection then
							heartbeatConnection:Disconnect()

							heartbeatConnection = nil
						end

						return
					end
					if not startPos then
						return
					end
					if Slider_ColorPickerCheck() then
						return
					end
					if not dragging and lastGoalPos then
						Window.Position = UDim2.new(
							startPos.X.Scale,
							Lerp(Window.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED),
							startPos.Y.Scale,
							Lerp(Window.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED)
						)

						return
					end

					local delta = (lastMousePos - UserInputService:GetMouseLocation())
					local xGoal = (startPos.X.Offset - delta.X)
					local yGoal = (startPos.Y.Offset - delta.Y)

					lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
					Window.Position = UDim2.new(
						startPos.X.Scale,
						Lerp(Window.Position.X.Offset, xGoal, dt * DRAG_SPEED),
						startPos.Y.Scale,
						Lerp(Window.Position.Y.Offset, yGoal, dt * DRAG_SPEED)
					)
				end

				Info.InputBegan:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						dragging = true
						dragStart = input.Position
						startPos = Window.Position
						lastMousePos = UserInputService:GetMouseLocation()

						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								dragging = false
							end
						end)
					end
				end)
				Info.InputChanged:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					then
						dragInput = input
					end
				end)

				heartbeatConnection = RunService.Heartbeat:Connect(Update)
			end)

			local isopened = true
			local lastActivation = 0
			local windowTransitionActive = false
			local storedWindowPosition = Window.Position
			local storedInfoPosition = Info.Position
			local storedMainPosition = Main.Position
			local BusyIconTween = nil

			local function offsetY(pos, amount)
				return UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + amount)
			end
			local function SetBusyOverlayVisible(visible, message)
				if message ~= nil and tostring(message) ~= "" then
					BusyText.Text = tostring(message)
				end

				if BusyIconTween then
					BusyIconTween:Cancel()
					BusyIconTween = nil
				end

				BusyOverlay:SetAttribute("Busy", visible == true)
				if visible then
					BusyOverlay.Visible = true
					BusyOverlay.Active = true
					BusyOverlay.BackgroundTransparency = 1
					BusyCard.BackgroundTransparency = 1
					BusyCard.Position = UDim2.fromScale(0.5, 0.54)
					BusyCardStroke.Transparency = 1
					BusyText.TextTransparency = 1
					BusyIcon.ImageTransparency = 1
					BusyIcon.Rotation = 0
					if BusyAccentBar then
						BusyAccentBar.BackgroundTransparency = 1
					end

					spr.target(BusyOverlay, 0.78, 6, { BackgroundTransparency = 0.22 })
					spr.target(BusyCard, 0.8, 6, {
						BackgroundTransparency = 0.06,
						Position = UDim2.fromScale(0.5, 0.5),
					})
					spr.target(BusyCardStroke, 0.8, 6, { Transparency = 0.16 })
					spr.target(BusyText, 0.82, 6, { TextTransparency = 0 })
					spr.target(BusyIcon, 0.82, 6, { ImageTransparency = 0 })
					if BusyAccentBar then
						spr.target(BusyAccentBar, 0.8, 6, { BackgroundTransparency = 0.2 })
					end

					BusyIconTween = TweenService:Create(
						BusyIcon,
						TweenInfo.new(1.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
						{ Rotation = 360 }
					)
					BusyIconTween:Play()
					return
				end

				spr.target(BusyOverlay, 0.72, 6, { BackgroundTransparency = 1 })
				spr.target(BusyCard, 0.76, 6, {
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.46),
				})
				spr.target(BusyCardStroke, 0.72, 6, { Transparency = 1 })
				spr.target(BusyText, 0.72, 6, { TextTransparency = 1 })
				spr.target(BusyIcon, 0.72, 6, { ImageTransparency = 1 })
				if BusyAccentBar then
					spr.target(BusyAccentBar, 0.72, 6, { BackgroundTransparency = 1 })
				end
				task.delay(0.22, function()
					if BusyOverlay and BusyOverlay.Parent and BusyOverlay:GetAttribute("Busy") ~= true then
						BusyOverlay.Visible = false
						BusyOverlay.Active = false
						BusyIcon.Rotation = 0
						if BusyAccentBar then
							BusyAccentBar.BackgroundTransparency = 1
						end
					end
				end)
			end
			local function animateWindowVisibility(show)
				if windowTransitionActive then
					return
				end

				windowTransitionActive = true

				if show then
					Window.Visible = true
					Window.Position = offsetY(storedWindowPosition, 16)
					Info.Position = offsetY(storedInfoPosition, -5)
					Main.Position = offsetY(storedMainPosition, 8)
					Window.BackgroundTransparency = 0.05
					WindowTransitionOverlay.Visible = true
					WindowTransitionOverlay.BackgroundTransparency = 0.1

					spr.target(Window, 0.8, 7, {
						Position = storedWindowPosition,
						BackgroundTransparency = 0,
					})
					spr.target(Info, 0.8, 7, { Position = storedInfoPosition })
					spr.target(Main, 0.8, 7, { Position = storedMainPosition })
					spr.target(WindowTransitionOverlay, 0.8, 7, { BackgroundTransparency = 1 })
					task.delay(0.18, function()
						WindowTransitionOverlay.Visible = false
						windowTransitionActive = false
						UpdateResizeButtonPosition()
						refreshCustomBackgroundVisibility()
					end)
				else
					storedWindowPosition = Window.Position
					storedInfoPosition = Info.Position
					storedMainPosition = Main.Position

					HideCloseConfirm(true)

					WindowTransitionOverlay.Visible = true
					WindowTransitionOverlay.BackgroundTransparency = 1

					spr.target(WindowTransitionOverlay, 0.75, 7, { BackgroundTransparency = 0.1 })
					spr.target(Window, 0.78, 7, {
						Position = offsetY(storedWindowPosition, 16),
						BackgroundTransparency = 0.05,
					})
					spr.target(Info, 0.78, 7, {
						Position = offsetY(storedInfoPosition, -5),
					})
					spr.target(Main, 0.78, 7, {
						Position = offsetY(storedMainPosition, 8),
					})
					task.delay(0.17, function()
						Window.Visible = false
						Window.Position = storedWindowPosition
						Info.Position = storedInfoPosition
						Main.Position = storedMainPosition
						Window.BackgroundTransparency = 0
						WindowTransitionOverlay.BackgroundTransparency = 1
						WindowTransitionOverlay.Visible = false
						windowTransitionActive = false
						refreshCustomBackgroundVisibility()
					end)
				end
			end

			function Tabs:ToggleUi()
				local currentTime = tick()

				if currentTime - lastActivation < 0.35 or windowTransitionActive then
					return
				end

				lastActivation = currentTime
				isopened = not isopened

				animateWindowVisibility(isopened)
			end

			local function resolveWindowBindKeyCode(bind)
				local bindName = tostring(bind or "RightControl")
				local ok, keyCode = pcall(function()
					return Enum.KeyCode[bindName]
				end)

				if ok and keyCode ~= nil and keyCode ~= Enum.KeyCode.Unknown then
					return keyCode
				end

				return Enum.KeyCode.RightControl
			end

			function Tabs:SetBind(bind)
				Window:SetAttribute("Bind", bind)
			end
			function Tabs:SetBusyState(isBusy, message)
				SetBusyOverlayVisible(isBusy == true, message)
			end
			function Tabs:ShowBusy(message)
				SetBusyOverlayVisible(true, message)
			end
			function Tabs:HideBusy()
				SetBusyOverlayVisible(false)
			end

			Library.ConnectionsList["Windows_InputBeganToToggle"] = UserInputService.InputBegan:Connect(
				function(input, gameProcessed)
					if gameProcessed or windowTransitionActive or closeInProgress then
						return
					end
					if UserInputService:GetFocusedTextBox() then
						return
					end
					if input.UserInputType ~= Enum.UserInputType.Keyboard then
						return
					end

					local keyCode = resolveWindowBindKeyCode(Window:GetAttribute("Bind"))

					if input.KeyCode ~= keyCode then
						return
					end

					Tabs:ToggleUi()
				end
			)

			function Tabs:SetTheme(themeName)
				if themeName == "Custom" then
					RefreshCustomTheme()
				end
				if not ThemeColors[themeName] then
					warn("Invalid theme:", themeName)

					return
				end

				currentTheme = themeName

				Library:RefreshMobileButtonsTheme(themeName)
				Library:RefreshNotificationsTheme(themeName)

				local theme = GetTheme()

				spr.target(Window, 0.8, 4, {
					BackgroundColor3 = theme.Primary,
				})

				Title.TextColor3 = theme.Text
				Description.TextColor3 = theme.SubText

				if UIGradient and UIGradient:IsA("UIGradient") then
					UIGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, theme.Accent),
						ColorSequenceKeypoint.new(1, BlendColor(theme.Text, theme.Accent, 0.35)),
					})
				end

				spr.target(Main.Pages, 0.8, 4, {
					BackgroundColor3 = theme.Secondary,
				})
				spr.target(Main.Tabs, 0.8, 4, {
					BackgroundColor3 = theme.Secondary,
				})

				if ResizePill then
					spr.target(ResizePill, 0.8, 4, {
						BackgroundColor3 = BlendColor(theme.Secondary, theme.Accent, 0.08),
					})
				end
				if ResizePillStroke then
					ResizePillStroke.Color = theme.Accent
				end

				for _, line in ipairs(ResizeGripLines) do
					spr.target(line, 0.8, 4, {
						BackgroundColor3 = theme.Accent,
					})
				end

				if CloseButton and CloseButton.Parent then
					spr.target(CloseButton, 0.8, 4, {
						BackgroundColor3 = BlendColor(theme.Primary, theme.Secondary, 0.15),
					})
				end
				if CloseButtonStroke and CloseButtonStroke.Parent then
					spr.target(CloseButtonStroke, 0.8, 4, {
						Color = BlendColor(theme.Accent, theme.Secondary, 0.42),
					})
				end
				if CloseButtonText and CloseButtonText.Parent then
					CloseButtonText.TextColor3 = theme.Text
				end
				if CloseConfirmCard and CloseConfirmCard.Parent then
					spr.target(CloseConfirmCard, 0.8, 4, {
						BackgroundColor3 = theme.Secondary,
					})
				end
				if WindowTransitionOverlay and WindowTransitionOverlay.Parent then
					spr.target(WindowTransitionOverlay, 0.8, 4, {
						BackgroundColor3 = BlendColor(theme.Secondary, Color3.fromRGB(0, 0, 0), 0.35),
					})
				end
				if CloseConfirmCardStroke and CloseConfirmCardStroke.Parent then
					spr.target(CloseConfirmCardStroke, 0.8, 4, {
						Color = BlendColor(theme.Accent, theme.Secondary, 0.35),
					})
				end
				if CloseConfirmTitle and CloseConfirmTitle.Parent then
					CloseConfirmTitle.TextColor3 = theme.Text
				end
				if CloseConfirmBody and CloseConfirmBody.Parent then
					CloseConfirmBody.TextColor3 = theme.SubText
				end
				if CloseCancelButton and CloseCancelButton.Parent then
					spr.target(CloseCancelButton, 0.8, 4, {
						BackgroundColor3 = theme.Primary,
					})

					CloseCancelButton.TextColor3 = theme.Text
				end
				if Loading and Loading.Parent then
					spr.target(Loading, 0.8, 4, {
						BackgroundColor3 = theme.Secondary,
					})

					local loadingStroke1 = Loading:FindFirstChild("UIStroke1")

					if loadingStroke1 and loadingStroke1:IsA("UIStroke") then
						spr.target(loadingStroke1, 0.8, 4, {
							Color = theme.Accent,
						})
					end

					local loadingStroke2 = Loading:FindFirstChild("UIStroke2")

					if loadingStroke2 and loadingStroke2:IsA("UIStroke") then
						spr.target(loadingStroke2, 0.8, 4, {
							Color = theme.SubText,
						})
					end
				end
				if BusyOverlay and BusyOverlay.Parent then
					spr.target(BusyOverlay, 0.8, 4, {
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					})
				end
				if BusyCard and BusyCard.Parent then
					spr.target(BusyCard, 0.8, 4, {
						BackgroundColor3 = theme.Secondary,
					})
				end
				if BusyCardStroke and BusyCardStroke.Parent then
					spr.target(BusyCardStroke, 0.8, 4, {
						Color = BlendColor(theme.Accent, theme.Secondary, 0.38),
					})
				end
				if BusyIcon and BusyIcon.Parent then
					spr.target(BusyIcon, 0.8, 4, {
						ImageColor3 = theme.Accent,
					})
				end
				if BusyText and BusyText.Parent then
					BusyText.TextColor3 = theme.Text
				end

				local function ApplyThemeToElement(element)
					if not element:IsA("Frame") or element.Name == "Line" then
						return
					end
					if element.Name == "Toggle" then
						spr.target(element, 0.6, 4, {
							BackgroundColor3 = theme.Primary,
						})

						local toggleFrame = element:FindFirstChild("Info")

						if toggleFrame then
							local toggle = toggleFrame:FindFirstChild("Toggle")

							if toggle then
								local circle = toggle:FindFirstChild("Circle")

								if circle then
									local toggleData = Library.Features_Table[element
										:FindFirstChild("Info")
										:FindFirstChild("Title").Text]

									if toggleData and toggleData.Toggled then
										spr.target(circle, 0.6, 4, {
											BackgroundColor3 = theme.Accent,
										})
									else
										spr.target(circle, 0.6, 4, {
											BackgroundColor3 = theme.SubText,
										})
									end
								end

								spr.target(toggle, 0.6, 4, {
									BackgroundColor3 = theme.Secondary,
								})
							end
						end
					elseif element.Name == "Dropdown" then
						spr.target(element.Main, 0.6, 4, {
							BackgroundColor3 = theme.Primary,
						})

						local data = element.Main:FindFirstChild("Data", true)

						if data then
							spr.target(data, 0.6, 4, {
								BackgroundColor3 = theme.Secondary,
							})
						end
					elseif element.Name == "ColorPicker" then
						spr.target(element, 0.6, 4, {
							BackgroundColor3 = theme.Primary,
						})
						ApplyStroke(element, theme)

						local pickerPanel = element:FindFirstChild("PickerPanel")

						if pickerPanel then
							spr.target(pickerPanel, 0.6, 4, {
								BackgroundColor3 = theme.Primary,
							})

							local panelStroke = pickerPanel:FindFirstChild("PanelStroke")

							if panelStroke and panelStroke:IsA("UIStroke") then
								spr.target(panelStroke, 0.6, 4, {
									Color = theme.Accent,
								})
							end

							local content = pickerPanel:FindFirstChild("Content")

							if content then
								for _, item in ipairs(content:GetDescendants()) do
									if item:IsA("Frame") and item.Name:find("^InputFrame_") then
										spr.target(item, 0.6, 4, {
											BackgroundColor3 = theme.Secondary,
										})

										for _, sub in ipairs(item:GetChildren()) do
											if sub:IsA("TextLabel") then
												sub.TextColor3 = theme.SubText
											elseif sub:IsA("TextBox") then
												sub.TextColor3 = theme.Text
											end
										end
									end
								end

								local buttonsContainer = content:FindFirstChild("ButtonsContainer")

								if buttonsContainer then
									for _, btn in ipairs(buttonsContainer:GetChildren()) do
										if btn:IsA("TextButton") then
											spr.target(btn, 0.6, 4, {
												BackgroundColor3 = theme.Button.Primary,
											})
										end
									end
								end
							end
						end
					elseif element.Name == "Information" then
						local infoBackground = element:FindFirstChild("BackgroundFrame")

						if infoBackground then
							spr.target(infoBackground, 0.6, 4, {
								BackgroundColor3 = theme.Secondary,
							})

							local infoStroke = infoBackground:FindFirstChildWhichIsA("UIStroke")

							if infoStroke then
								spr.target(infoStroke, 0.6, 4, {
									Color = theme.Accent,
								})
							end
						end

						local userCard = element:FindFirstChild("UserCard", true)

						if userCard then
							spr.target(userCard, 0.6, 4, {
								BackgroundColor3 = theme.Secondary,
							})

							local userCardStroke = userCard:FindFirstChild("UserCardStroke")

							if userCardStroke and userCardStroke:IsA("UIStroke") then
								spr.target(userCardStroke, 0.6, 4, {
									Color = theme.Accent,
								})
							end
						end

						local userLine = element:FindFirstChild("UserLine", true)

						if userLine and userLine:IsA("Frame") then
							spr.target(userLine, 0.6, 4, {
								BackgroundColor3 = theme.SubText,
							})
						end

						local versionLabel = element:FindFirstChild("VersionLabel", true)

						if versionLabel and versionLabel:IsA("TextLabel") then
							versionLabel.TextColor3 = theme.Accent

							local versionGradient = versionLabel:FindFirstChildWhichIsA("UIGradient")

							if versionGradient then
								versionGradient.Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, theme.Accent),
									ColorSequenceKeypoint.new(1, BlendColor(theme.Accent, theme.Text, 0.35)),
								})
							end
						end

						ApplyStroke(element, theme)
					elseif element.Name == "ElementsSection" then
						spr.target(element, 0.6, 4, {
							BackgroundColor3 = theme.Primary,
						})

						local header = element:FindFirstChild("Header")

						if header then
							spr.target(header, 0.6, 4, {
								BackgroundColor3 = theme.Secondary,
							})
						end

						local contentShell = element:FindFirstChild("ContentShell")

						if contentShell then
							spr.target(contentShell, 0.6, 4, {
								BackgroundColor3 = theme.Secondary,
							})
						end

						local titleRow = header and header:FindFirstChild("TitleRow")
						local titleLabel = titleRow and titleRow:FindFirstChild("Title")

						if titleLabel and titleLabel:IsA("TextLabel") then
							titleLabel.TextColor3 = theme.Text
						end

						local descriptionLabel = header and header:FindFirstChild("Description")

						if descriptionLabel and descriptionLabel:IsA("TextLabel") then
							descriptionLabel.TextColor3 = theme.SubText
						end

						local toggleButton = titleRow and titleRow:FindFirstChild("ToggleButton")

						if toggleButton and toggleButton:IsA("TextButton") then
							spr.target(toggleButton, 0.6, 4, {
								BackgroundColor3 = theme.Primary,
							})

							if toggleButton.Visible then
								toggleButton.Text = (contentShell and contentShell.Visible) and "-" or "+"
								toggleButton.TextColor3 = theme.Text
							end
						end

						local content = contentShell and contentShell:FindFirstChild("Content")

						if content then
							for _, nestedElement in ipairs(content:GetChildren()) do
								ApplyThemeToElement(nestedElement)
							end
						end

						return
					elseif IsSlider(element) then
						local bar = element:FindFirstChild("Gutter")
						local fill = bar and bar:FindFirstChild("Fill")

						if bar then
							bar.BackgroundColor3 = theme.Secondary
						end
						if fill then
							fill.BackgroundColor3 = theme.Accent
						end

						spr.target(element, 0.6, 4, {
							BackgroundColor3 = theme.Primary,
						})
						ApplyStroke(element, theme)
					else
						spr.target(element, 0.6, 4, {
							BackgroundColor3 = theme.Primary,
						})
						ApplyStroke(element, theme)
					end

					for _, child in ipairs(element:GetDescendants()) do
						if child:IsA("TextLabel") or child:IsA("TextButton") then
							if element.Name == "Information" and child:IsA("TextLabel") then
								local nameLower = string.lower(child.Name or "")

								if nameLower:find("sub") or nameLower:find("role") or nameLower:find("meta") then
									child.TextColor3 = theme.SubText
								elseif nameLower:find("version") then
									child.TextColor3 = theme.Accent
								else
									child.TextColor3 = theme.Text
								end
							else
								child.TextColor3 = theme.Text
							end
						end
					end
				end

				for _, page in ipairs(Main.Pages:GetChildren()) do
					if not (page:IsA("Frame") or page:IsA("ScrollingFrame")) then
						continue
					end

					for _, dropdown in ipairs(page:GetChildren()) do
						if dropdown:IsA("Folder") and dropdown.Name:find("Dropdown_") then
							local optionsPanel = dropdown:FindFirstChild("OptionsPanel")

							if optionsPanel then
								spr.target(optionsPanel, 0.6, 4, {
									BackgroundColor3 = theme.Primary,
								})

								local optionsScroll = optionsPanel:FindFirstChild("OptionsScroll")

								if optionsScroll then
									for _, optionButton in ipairs(optionsScroll:GetChildren()) do
										if optionButton:IsA("TextButton") and optionButton.Name:find("Option_") then
											local optionSelected = optionButton:GetAttribute("IsSelected")

											spr.target(optionButton, 0.6, 4, {
												BackgroundColor3 = optionSelected and theme.Accent or theme.Secondary,
												TextColor3 = theme.Text,
											})
										end
									end
								end
							end
						end
					end

					if page:GetAttribute("IsChat") then
						ApplyChatTheme(page, theme)

						continue
					end

					local container = page:FindFirstChild("Main")

					if not container then
						continue
					end

					for _, element in ipairs(container:GetChildren()) do
						ApplyThemeToElement(element)
					end
				end

				if Main.Tabs.Folder:FindFirstChild("EnabledFrame") then
					spr.target(Main.Tabs.Folder.EnabledFrame, 0.8, 4, {
						BackgroundColor3 = theme.Primary,
					})
				end
			end
			function Tabs:SetCustomColors(colors)
				Library:SetCustomColors(colors, false)

				if currentTheme == "Custom" then
					self:SetTheme("Custom")
				end

				return ThemeColors.Custom
			end
			function Tabs:SetCustomColor(name, value)
				Library:SetCustomColor(name, value, false)

				if currentTheme == "Custom" then
					self:SetTheme("Custom")
				end

				return ThemeColors.Custom
			end
			function Tabs:SetTextFont(fontName)
				local resolvedFont = Enum.Font.BuilderSansBold

				if typeof(fontName) == "EnumItem" then
					resolvedFont = fontName
				elseif type(fontName) == "string" then
					local ok, fontEnum = pcall(function()
						return Enum.Font[fontName]
					end)

					if ok and fontEnum then
						resolvedFont = fontEnum
					end
				end

				currentTextFont = resolvedFont

				applyCurrentTextFont(UI)
			end
			function Tabs:SetCustomBackgroundDim(value)
				customBackgroundDim = math.clamp(tonumber(value) or 0.35, 0, 0.95)

				applyCustomBackgroundComfort()
			end
			function Tabs:SetCustomBackgroundMode(mode)
				customBackgroundScaleMode = tostring(mode) == "Fit" and "Fit" or "Crop"

				applyCustomBackgroundComfort()
			end
			function Tabs:SetCustomBackgroundPauseOnHide(toggle)
				customBackgroundPauseOnHide = toggle == true

				syncCustomBackgroundPlayback()
			end
			function Tabs:SetCustomBackground(source)
				local cleanedSource = trimBackgroundValue(source)

				if cleanedSource == "" then
					CustomBackgroundImage.Image = ""
					CustomBackgroundImage.Visible = false

					pcall(function()
						CustomBackgroundVideo:Pause()
					end)

					CustomBackgroundVideo.Video = ""
					CustomBackgroundVideo.Visible = false

					refreshCustomBackgroundVisibility()

					return true
				end

				local asset, mediaTypeOrError = resolveCustomBackgroundSource(cleanedSource)

				if not asset then
					warn("Failed to apply custom background: " .. tostring(mediaTypeOrError))

					return false
				end
				if mediaTypeOrError == "video" then
					CustomBackgroundImage.Image = ""
					CustomBackgroundImage.Visible = false
					CustomBackgroundVideo.Video = asset
					CustomBackgroundVideo.Visible = true
				else
					pcall(function()
						CustomBackgroundVideo:Pause()
					end)

					CustomBackgroundVideo.Video = ""
					CustomBackgroundVideo.Visible = false
					CustomBackgroundImage.Image = asset
					CustomBackgroundImage.Visible = true
				end

				applyCustomBackgroundComfort()
				refreshCustomBackgroundVisibility()

				return true
			end
			function Tabs:GetCurrentTheme()
				return currentTheme
			end
			function Tabs:GetScreenUI()
				return UI
			end

			local function ToggleButton()
				if GetDeviceType() == "Mobile" then
					Toggle.Name = "MobileToggle"
					Toggle.Parent = UI
					Toggle.Image = "rbxassetid://137827218584732"
					Toggle.AnchorPoint = Vector2.new(0.5, 0.5)
					Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Toggle.BackgroundTransparency = 1
					Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Toggle.BorderSizePixel = 0
					Toggle.Position = UDim2.new(0.5, 0, 0.075000003, 0)
					Toggle.Size = UDim2.new(0, 200, 0, 50)
					UIAspectRatioConstraint_4.Parent = Toggle
					UICorner_6.CornerRadius = UDim.new(0, 12)
					UICorner_6.Parent = Toggle
					UIStroke1_5.Thickness = 3
					UIStroke1_5.Transparency = 0.699999988079071
					UIStroke1_5.Name = "UIStroke1"
					UIStroke1_5.Parent = Toggle
					UIStroke2_4.Color = Color3.fromRGB(255, 255, 255)
					UIStroke2_4.Thickness = 1.5
					UIStroke2_4.Transparency = 0.699999988079071
					UIStroke2_4.Name = "UIStroke2"
					UIStroke2_4.Parent = Toggle

					local script = Instance.new("Configuration", Toggle)

					script.Parent.Activated:Connect(function()
						Tabs:ToggleUi()
					end)

					local gui = script.Parent
					local dragging
					local dragInput
					local dragStart
					local startPos

					local function Lerp(a, b, m)
						return a + (b - a) * m
					end

					local lastMousePos
					local lastGoalPos
					local DRAG_SPEED = 8
					local mobileDragConnection

					local function Update(dt)
						if not gui or not gui.Parent then
							if mobileDragConnection then
								mobileDragConnection:Disconnect()

								mobileDragConnection = nil
							end

							return
						end
						if not startPos then
							return
						end
						if not dragging and lastGoalPos then
							gui.Position = UDim2.new(
								startPos.X.Scale,
								Lerp(gui.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED),
								startPos.Y.Scale,
								Lerp(gui.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED)
							)

							return
						end

						local delta = (lastMousePos - UserInputService:GetMouseLocation())
						local xGoal = (startPos.X.Offset - delta.X)
						local yGoal = (startPos.Y.Offset - delta.Y)

						lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
						gui.Position = UDim2.new(
							startPos.X.Scale,
							Lerp(gui.Position.X.Offset, xGoal, dt * DRAG_SPEED),
							startPos.Y.Scale,
							Lerp(gui.Position.Y.Offset, yGoal, dt * DRAG_SPEED)
						)
					end

					gui.InputBegan:Connect(function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
						then
							dragging = true
							dragStart = input.Position
							startPos = gui.Position
							lastMousePos = UserInputService:GetMouseLocation()

							input.Changed:Connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									dragging = false
								end
							end)
						end
					end)
					gui.InputChanged:Connect(function(input)
						if
							input.UserInputType == Enum.UserInputType.MouseMovement
							or input.UserInputType == Enum.UserInputType.Touch
						then
							dragInput = input
						end
					end)

					mobileDragConnection = RunService.Heartbeat:Connect(Update)
				end
			end
			local function LoadStart()
				local theme = GetTheme()
				local frame = Loading
				frame.Visible = true

				for _, v in pairs(frame.Parent:GetChildren()) do
					if v ~= frame and not v:IsA("UIPadding") then
						v.Visible = false
					end
				end

				local LoadCard = Instance.new("Frame")
				LoadCard.Name = "LoadCard"
				LoadCard.AnchorPoint = Vector2.new(0.5, 0.5)
				LoadCard.Position = UDim2.fromScale(0.5, 0.5)
				LoadCard.Size = UDim2.fromOffset(280, 180)
				LoadCard.BackgroundColor3 = theme.Secondary
				LoadCard.BackgroundTransparency = 1
				LoadCard.BorderSizePixel = 0
				LoadCard.ZIndex = 10
				LoadCard.Parent = frame
				MakeCorner(LoadCard, 16)
				MakeStroke(LoadCard, theme.Accent, 1.5, 0.32)

				local LogoIcon = Instance.new("ImageLabel")
				LogoIcon.Name = "Logo"
				LogoIcon.AnchorPoint = Vector2.new(0.5, 0.5)
				LogoIcon.Position = UDim2.new(0.5, 0, 0.5, -22)
				LogoIcon.Size = UDim2.fromOffset(48, 48)
				LogoIcon.BackgroundTransparency = 1
				LogoIcon.Image = "rbxassetid://117102312939397"
				LogoIcon.ImageTransparency = 1
				LogoIcon.ScaleType = Enum.ScaleType.Fit
				LogoIcon.ZIndex = 12
				LogoIcon.Parent = LoadCard

				local RingFrame = Instance.new("Frame")
				RingFrame.Name = "RingFrame"
				RingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
				RingFrame.Position = UDim2.new(0.5, 0, 0.5, -22)
				RingFrame.Size = UDim2.fromOffset(68, 68)
				RingFrame.BackgroundTransparency = 1
				RingFrame.BorderSizePixel = 0
				RingFrame.ZIndex = 11
				RingFrame.Parent = LoadCard

				local RingCircle = Instance.new("Frame")
				RingCircle.Size = UDim2.fromScale(1, 1)
				RingCircle.BackgroundTransparency = 1
				RingCircle.BorderSizePixel = 0
				RingCircle.ZIndex = 11
				RingCircle.Parent = RingFrame
				MakeCorner(RingCircle, 34)

				local RingStroke = Instance.new("UIStroke")
				RingStroke.Color = theme.Accent
				RingStroke.Thickness = 2.5
				RingStroke.Transparency = 0.22
				RingStroke.Parent = RingCircle

				local DOT_COUNT = 8
				for i = 1, DOT_COUNT do
					local angle = (i - 1) / DOT_COUNT * math.pi * 2
					local dot = Instance.new("Frame")
					dot.Size = UDim2.fromOffset(4, 4)
					dot.AnchorPoint = Vector2.new(0.5, 0.5)
					dot.Position = UDim2.new(0.5, math.cos(angle) * 30, 0.5, math.sin(angle) * 30)
					dot.BackgroundColor3 = theme.Accent
					dot.BackgroundTransparency = 0.55 + (i / DOT_COUNT) * 0.35
					dot.BorderSizePixel = 0
					dot.ZIndex = 11
					MakeCorner(dot, 2)
					dot.Parent = RingFrame
				end

				local StatusText = Instance.new("TextLabel")
				StatusText.AnchorPoint = Vector2.new(0.5, 0)
				StatusText.Position = UDim2.new(0.5, 0, 0.5, 36)
				StatusText.Size = UDim2.new(0.9, 0, 0, 18)
				StatusText.BackgroundTransparency = 1
				StatusText.Text = "Initializing..."
				StatusText.TextColor3 = theme.SubText
				StatusText.Font = Enum.Font.GothamMedium
				StatusText.TextSize = 13
				StatusText.TextTransparency = 1
				StatusText.ZIndex = 12
				StatusText.Parent = LoadCard

				local ProgressTrack = Instance.new("Frame")
				ProgressTrack.AnchorPoint = Vector2.new(0.5, 1)
				ProgressTrack.Position = UDim2.new(0.5, 0, 1, -16)
				ProgressTrack.Size = UDim2.new(0.8, 0, 0, 3)
				ProgressTrack.BackgroundColor3 = BlendColor(theme.Secondary, theme.Primary, 0.5)
				ProgressTrack.BackgroundTransparency = 0.5
				ProgressTrack.BorderSizePixel = 0
				ProgressTrack.ZIndex = 12
				ProgressTrack.Parent = LoadCard
				MakeCorner(ProgressTrack, 3)

				local ProgressFill = Instance.new("Frame")
				ProgressFill.Size = UDim2.new(0, 0, 1, 0)
				ProgressFill.BackgroundColor3 = theme.Accent
				ProgressFill.BorderSizePixel = 0
				ProgressFill.ZIndex = 13
				ProgressFill.Parent = ProgressTrack
				MakeCorner(ProgressFill, 3)

				local ReqContainer = Instance.new("Frame")
				ReqContainer.Name = "ReqContainer"
				ReqContainer.Position = UDim2.new(0, 16, 0, 16)
				ReqContainer.Size = UDim2.new(1, -32, 1, -80)
				ReqContainer.BackgroundTransparency = 1
				ReqContainer.Visible = false
				ReqContainer.ZIndex = 12
				ReqContainer.Parent = LoadCard

				local ReqLayout = Instance.new("UIListLayout")
				ReqLayout.Padding = UDim.new(0, 5)
				ReqLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ReqLayout.Parent = ReqContainer

				LoadCard.BackgroundTransparency = 1
				frame.BackgroundTransparency = 1
				frame.Position = UDim2.fromScale(0.5, 0.5)
				frame.AnchorPoint = Vector2.new(0.5, 0.5)

				spr.target(LoadCard, 0.78, 5, { BackgroundTransparency = 0.06 })
				spr.target(LogoIcon, 0.7, 4, { ImageTransparency = 0 })
				spr.target(StatusText, 0.7, 4, { TextTransparency = 0 })
				spr.target(frame, 0.75, 5, { BackgroundTransparency = 0.5 })

				local ringSpinTween = TweenService:Create(
					RingFrame,
					TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
					{ Rotation = 360 }
				)
				ringSpinTween:Play()

				task.wait(0.8)

				StatusText.Text = "Checking environment..."
				ReqContainer.Visible = true

				local totalReqs = #CheckingFunctions
				local passedReqs = 0

				for i, v in ipairs(CheckingFunctions) do
					local reqRow = Instance.new("Frame")
					reqRow.Size = UDim2.new(1, 0, 0, 20)
					reqRow.BackgroundTransparency = 1
					reqRow.BorderSizePixel = 0
					reqRow.ZIndex = 13
					reqRow.LayoutOrder = i
					reqRow.Parent = ReqContainer

					local reqLayout = Instance.new("UIListLayout")
					reqLayout.FillDirection = Enum.FillDirection.Horizontal
					reqLayout.Padding = UDim.new(0, 5)
					reqLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					reqLayout.Parent = reqRow

					local reqDot = Instance.new("Frame")
					reqDot.Size = UDim2.fromOffset(8, 8)
					reqDot.BackgroundColor3 = theme.SubText
					reqDot.BackgroundTransparency = 0.4
					reqDot.BorderSizePixel = 0
					reqDot.ZIndex = 14
					MakeCorner(reqDot, 4)
					reqDot.Parent = reqRow

					local reqLabel = Instance.new("TextLabel")
					reqLabel.BackgroundTransparency = 1
					reqLabel.Text = v.Name
					reqLabel.TextColor3 = theme.SubText
					reqLabel.Font = Enum.Font.Gotham
					reqLabel.TextSize = 11
					reqLabel.Size = UDim2.new(1, -16, 1, 0)
					reqLabel.TextXAlignment = Enum.TextXAlignment.Left
					reqLabel.ZIndex = 14
					reqLabel.TextTransparency = 0.5
					reqLabel.Parent = reqRow

					task.wait(0.08)
					spr.target(reqLabel, 0.6, 5, { TextTransparency = 0 })

					local succeed = RunCheckingFunctions(v)
					task.wait(0.12)

					if succeed == true then
						passedReqs += 1
						reqDot.BackgroundColor3 = Color3.fromRGB(85, 205, 132)
						reqLabel.TextColor3 = Color3.fromRGB(85, 205, 132)
					elseif succeed == "Maybe" then
						passedReqs += 0.5
						reqDot.BackgroundColor3 = Color3.fromRGB(255, 196, 74)
						reqLabel.TextColor3 = Color3.fromRGB(255, 196, 74)
					else
						reqDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
						reqLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
						task.wait(0.3)
						Players.LocalPlayer:Kick(v.Name .. " Missing.")
						return
					end

					local progress = i / totalReqs
					spr.target(ProgressFill, 0.7, 5, { Size = UDim2.new(progress, 0, 1, 0) })
				end

				task.wait(0.4)
				StatusText.Text = "All checks passed ✓"
				StatusText.TextColor3 = Color3.fromRGB(85, 205, 132)

				task.wait(0.5)

				ringSpinTween:Cancel()

				game.ContentProvider:PreloadAsync({ "rbxassetid://89142505387395" }, function()
					for _, v in pairs(frame.Parent:GetChildren()) do
						if v ~= frame and not v:IsA("UIPadding") then
							v.Visible = true
						end
					end
					LogoIcon.Image = "rbxassetid://89142505387395"
					spr.target(LogoIcon, 0.6, 4, { ImageColor3 = theme.Accent })
					spr.target(frame, 0.75, 5, { BackgroundTransparency = 0.5 })
					task.wait(0.35)
					spr.target(LoadCard, 0.72, 5, { BackgroundTransparency = 1 })
					spr.target(frame, 0.8, 5, { BackgroundTransparency = 1 })
					task.wait(0.65)
					frame.Visible = false
				end)
			end

			Library._ThemeWindows = Library._ThemeWindows or {}
			table.insert(Library._ThemeWindows, Tabs)

			Tabs:SetTheme(Tabs:GetCurrentTheme())
			task.spawn(LoadStart)
			task.spawn(ToggleButton)
		end

		return Tabs
	end

	return Library
end)()
return UiLibrary
