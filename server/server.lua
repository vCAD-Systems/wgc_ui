local Categories = {}
local Zones = {}


ESX = nil
QBCore = nil

if Config.Version == "esx" then
	ESX = exports["es_extended"]:getSharedObject()
elseif Config.Version == "esx-legacy" then
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.Version == "qb" then
	QBCore = exports['qb-core']:GetCoreObject()
end


if Config.OxMySQL then
	function CallDbData()
		MySQL.query("SELECT * FROM vcad_categories", {}, function(rs)
			for k, v in pairs(rs) do
				table.insert(Categories, { name = v.name, label = v.label })
			end
		end)

		MySQL.query("SELECT * FROM vcad_zonen", {}, function(rs)
			for k, v in pairs(rs) do
				table.insert(Zones,
					{ Id = v.id, Coords = v.coords, Prompt = v.prompt, System = v.system, OpenType = v.opentype, PublicID =
					v.publicid, Label = v.label })
			end
		end)
	end
end

if Config.CustomAdmin then
	RegisterCommand("vcad", function(source, args, raw)
		if Checkusr(GetPlayerIdentifiers(source)) then
			TriggerClientEvent('vCAD:CreateZone', source, args)
		else
			print("[vCAD-Tablet]Es Versucht jemand ein Befehl einzugeben der keine Rechte besitzt...")
			print(json.encode(GetPlayerIdentifiers(source)))
		end
	end, false)
else
	RegisterCommand("vcad", function(source, args, raw)
		TriggerClientEvent('vCAD:CreateZone', source, args)
	end, true)
end

function Checkusr(Identifier)
	local steamid = false
	local license = false

	for k, v in pairs(Identifier) do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			steamid = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		end
	end

	for k, v in pairs(Config.EnabledIdentifier) do
		if steamid == v or license == v then
			return true
		end
	end
	return false
end

-- Config Bearbeiten
-- Zones
RegisterServerEvent('vCAD:SaveZonenConfig')
AddEventHandler('vCAD:SaveZonenConfig', function(Coords, PublicID, Type, Prompt, System)
	local path = GetResourcePath(GetCurrentResourceName())
	local lines_config = lines_from(path .. "/config/zonen.lua")


	for k, v in pairs(lines_config) do
		if k == #lines_config then
			DeleteString(path .. "/config/zonen.lua", "}")
		end
	end

	local file = io.open(path .. "/config/zonen.lua", "a")

	file:write("\n	{")
	file:write("\n		Coords = " .. Coords .. ",")
	file:write("\n		Prompt = '" .. Prompt .. "',")
	file:write("\n		System = '" .. System .. "',")
	file:write("\n		OpenType = '" .. Type .. "',")
	if PublicID == nil then
		file:write("\n		PublicID = '',")
	else
		file:write("\n		PublicID = '" .. PublicID .. "',")
	end
	file:write("\n  },")
	file:write("\n}")
	file:close()

	TriggerClientEvent('vCAD:AddPunkt', -1, {
		Coords = Coords,
		Prompt = Prompt,
		System = System,
		OpenType = Type,
		PublicID = PublicID
	})
end)

function DeleteString(path, before)
	local inf = assert(io.open(path, "r+"), "Fehler beim Öffnen der Datei.")
	local lines = ""
	while true do
		local line = inf:read("*line")
		if not line then break end

		if line ~= before then lines = lines .. line .. "\n" end
	end
	inf:close()
	file = io.open(path, "w")
	file:write(lines)
	file:close()
end

function lines_from(file)
	lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end

function firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end
