local data    = {}
local emptAng = Angle()
local enabled = CreateConVar("cl_playerlook", 1, nil, "Enables player models to look at nearby objects automatically."):GetBool()

cvars.AddChangeCallback("cl_playerlook", function(cvar, old, new)
	enabled = tobool(new)
end, "Default")

local function Data(pl)
	return data[pl:UserID()]
end

local function Reset(pl)
	data[isentity(pl) and pl:UserID() or pl] = {
		time = 0,
		ent = NULL,
		ang = Angle(),
		active = false,
	}
end

local function Update(pl)
	local data = Data(pl)
	local time = CurTime()
	local pos = pl:EyePos()
	local aim = pl:GetAimVector()
	local minDist = 0
	local maxDot = 0

	data.ent = NULL
	data.time = time + 1

	for i, ent in pairs(ents.FindInSphere(pos, 512)) do
		local entPos = isfunction(ent.EyePos) and ent:EyePos() or ent:GetPos()
		local entClass = ent:GetClass()
		local entMdl = ent:GetModel()

		if ent == pl or (not entMdl or not util.IsValidModel(entMdl)) or not IsValid(ent) or (ent:IsPlayer() and (not ent:Alive() or ent:GetObserverMode() ~= OBS_MODE_NONE)) or (IsValid(ent:GetOwner()) or IsValid(ent:GetParent())) then continue end

		local dist = pos:Distance(entPos)
		local dot = aim:Dot((entPos - pos):GetNormalized())

		if dot < 0 then continue end

		if IsValid(data.ent) then
			if dist < minDist or dot > maxDot then
				data.ent = ent
				minDist = dist
				maxDot = dot
			end
		else
			data.ent = ent
			minDist = dist
			maxDot = dot
		end
	end
end

for i, pl in pairs(player.GetAll()) do
	Reset(pl)
end

gameevent.Listen "player_spawn"
hook.Add("player_spawn", "player_look", function(data)
	Reset(data.userid)
end)

hook.Add("PrePlayerDraw", "player_look", function(pl)
	local eyePos = EyePos()
	local pos = pl:EyePos()
	local ang = pl:EyeAngles()
	local head = pl:LookupBone "ValveBiped.Bip01_Head1"

	if not enabled or eyePos:Distance(pos) > 512 then
		if data.active then
			data.active = false
			pl:ManipulateBoneAngles(head, Angle())
			pl:SetEyeTarget(pos + ang:Forward() * 512)
		end

		return
	end

	data.active = true

	local data = Data(pl)
	local time = CurTime()

	if time > data.time then
		Update(pl)
	end

	if IsValid(data.ent) then
		local entPos = isfunction(data.ent.EyePos) and data.ent:EyePos() or data.ent:GetPos() + data.ent:OBBCenter()
		local newPos, newAng = WorldToLocal(Vector(), (entPos - pos):Angle(), Vector(), Angle(0, ang.y, 0))

		newAng.y = math.Clamp(newAng.y, -45, 45)
		newAng.x = math.Clamp(newAng.x / 2, -25, 25)

		data.ang = LerpAngle(FrameTime() * 1, data.ang, newAng)
		pl:SetEyeTarget(entPos)
	else
		data.ang = LerpAngle(FrameTime() * 1, data.ang, emptAng)
	end

	pl:ManipulateBoneAngles(head, Angle(0, -data.ang.x, data.ang.y))
end)
