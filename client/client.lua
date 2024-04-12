local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["F11"] = 344,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local SystemTitel = 'Copnet, Medicnet, Firenet oder Carnet?'
local PID_Titel = 'Public ID'

local tabEnabled, tabLoaded, isDead, lastOpend, site, subSite = false, false, false, 0, 'nil', 'tab'
local PublicID, tab = nil, nil
local hasAlreadyEnteredMarker = false
local PlayerData

if Config.NativeUIEnabled then
	_menuPool  = NativeUI.CreatePool()
end

if (Config.Version == 'esx' or Config.Version == 'esx-legacy') then
	if Config.Version == 'esx' then
		ESX = exports["es_extended"]:getSharedObject()
	elseif Config.Version == 'esx-legacy' then
		Citizen.CreateThread(function()
			while ESX == nil do
				TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
				Citizen.Wait(0)
			end
		end)
	end
end

if Config.Version == 'qb' then
	QBCore = exports['qb-core']:GetCoreObject()
end

function ShowNotification(msg, type)
	if Config.Version == 'qb' then
		QBCore.Functions.Notify(msg, type, 7500)
	else
		SetNotificationTextEntry('STRING')
		AddTextComponentSubstringPlayerName(msg)
		DrawNotification(false, true)
	end
end

RegisterNetEvent('vCAD:ShowNotification')
AddEventHandler('vCAD:ShowNotification', function(msg, type)
	ShowNotification(msg, type)
end)

function ShowHelpNotification(msg)
	BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, false, true, -1)
end

function CreateDialog(OnScreenDisplayTitle_shopmenu) --general OnScreenDisplay for KeyboardInput
	AddTextEntry(OnScreenDisplayTitle_shopmenu, OnScreenDisplayTitle_shopmenu)
	DisplayOnscreenKeyboard(1, OnScreenDisplayTitle_shopmenu, "", "", "", "", "", 32)
	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0);
		Wait(0);
	end
	if (GetOnscreenKeyboardResult()) then
		local displayResult = GetOnscreenKeyboardResult()
		return displayResult
	end
end

function TOGGLE_NUI_FOCUS(bool, reload)
	if (site ~= 'cop' and 
		site ~= 'medic' and 
		site ~= 'car' and 
		site ~= 'fd') 
		or (
		subSite ~= 'tab' and 
		subSite ~= 'pc' and 
		subSite ~= 'katalog' and 
		subSite ~= 'strafen' and 
		subSite ~= 'bewerben' and 
		subSite ~= 'beschweren' and 
		subSite ~= 'wanted' and 
		subSite ~= 'calendar' and 
		subSite ~= 'hp' and
		subSite ~= 'rechnung'
		) then

		ShowNotification('~r~Fehler beim einrichten des vCAD UIs.', "error")
		ShowNotification('~r~Fehler beim einrichten des vCAD UIs!', "error")
		return
	end

	local PlayerPed = PlayerPedId()

	if bool == true then
		local openSite = GetURL(site)

		if 
		subSite == 'katalog' or 
		subSite == 'bewerben' or 
		subSite == 'strafen' or 
		subSite == "calendar" or 
		subSite == "wanted" or 
		subSite == "beschweren" or 
		subSite == "hp" or
		subSite == "rechnung" then
			if PublicID ~= nil then
				if site == 'car' and subSite == 'katalog' then
					openSite = openSite..'shop?sp='..PublicID
				elseif site == 'cop' and subSite == 'strafen' then
					openSite = openSite..'strafen?c='..PublicID
				else 
					openSite = openSite..subSite..'?c='..PublicID
				end
			else
				print('[vCAD_UI] Error: `PublicID` ist ungültig oder nicht angegeben.')
				return
			end
		end

		if reload then
			SendNUIMessage({showtab = true, design = Config.Design, autoscale = Config.AutoScale and subSite == 'tab', site = openSite})
		else
			SendNUIMessage({showtab = true, design = Config.Design, autoscale = Config.AutoScale and subSite == 'tab'})
		end

		SetNuiFocus(bool, bool)

		if Config.Animation == true and subSite == 'tab' and not IsPedInAnyVehicle(PlayerPed, false) then
			SetCurrentPedWeapon(PlayerPed, GetHashKey('WEAPON_UNARMED'), true)
			RequestAnimDict("amb@world_human_seat_wall_tablet@female@base")

			while not HasAnimDictLoaded("amb@world_human_seat_wall_tablet@female@base") do
				Citizen.Wait(1)
			end

			TaskPlayAnim(PlayerPed, "amb@world_human_seat_wall_tablet@female@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)
			attachObject()
		end
    else
        CloseTab()
    end
end

function GetURL(system)
	if system == "cop" then
		if Config.Beta then
			return "https://beta.copnet.ch/"
		else
			return "https://copnet.ch/"
		end
	elseif system == "medic" then
		return "https://medicnet.ch/"
	elseif system == "car" then
		return "https://mechnet.ch/"
	elseif system == "fd" then
		return "https://fdnet.ch/"
	end
end

function attachObject()
	if tab ~= nil then 
		DeleteObject(tab)
	end

	local PlayerPed = PlayerPedId()
	
	tab = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
	AttachEntityToEntity(tab, PlayerPed, GetPedBoneIndex(PlayerPed, 57005), 0.17, 0.10, -0.13, 20.0, 180.0, 180.0, true, true, false, true, 1, true)
end

RegisterNUICallback("tablet-bus", function(data)
	if data.load then
		tabLoaded = true
	elseif data.hide then
		TOGGLE_NUI_FOCUS(false)
		tabEnabled = false
	elseif data.click then
		lastOpend = GetGameTimer()
	end
end)

function CloseTab()
	SendNUIMessage({hidetab = true})
	SetNuiFocus(false, false)
	
	if Config.Animation == true or tab ~= nil then
		ClearPedTasks(PlayerPedId())
		DeleteObject(tab)
		tab = nil
	end
	
	PublicID = nil
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if tabEnabled then
			CloseTab()
		end
	end
end)

function canOpenTablet(system, newSite, pos)
	local PlayerPed = PlayerPedId()
	local canOpen = not Config.OnlyInVehicle
	local canOpenType = newSite

	if newSite == 'katalog' 
	or newSite == 'bewerben' 
	or newSite == 'strafen' 
	or newSite == 'wanted'
	or newSite == 'beschweren'
	or newSite == 'calendar'
	or newSite == 'hp'
	or newSite == 'rechnung' then
		return true, canOpenType
	end
	
	if Config.OnlyInVehicle == true and IsPedInAnyVehicle(PlayerPed, false) then
		if Config.InEmergencyVehicle == true then
			if GetVehicleClass(GetVehiclePedIsIn(PlayerPed, false)) == 18 then
				canOpen = true
				canOpenType = Config.VehicleOpenType
			end
		end

		if #Config.Vehicles[system] > 0 then
			local vehHash = GetEntityModel(GetVehiclePedIsIn(PlayerPed, false))
			for k,v in pairs(Config.Vehicles[system]) do
				if (tonumber(v) and v == vehHash) or (tostring(v) and GetHashKey(v) == vehHash) then
					canOpen = true
					canOpenType = Config.VehicleOpenType
					break
				end
			end
		end
	end
	if (Config.Version == 'esx' or Config.Version == 'esx-legacy') then
		PlayerData = ESX.GetPlayerData()

		if newSite == 'tab' and Config.NeededItem ~= nil and Config.NeededItem ~= 'nil' then 
			local found = false
	
			for k,v in pairs(PlayerData.inventory) do
				if found == true then
					break
				elseif type(Config.NeededItem) == 'table' then
					for key,value in pairs(Config.NeededItem) do
						if v.name ~= nil and v.name ~= 'nil' and v.name == value and v.count > 0 then
							found = true
							break
						end
					end
				elseif v.name == Config.NeededItem and v.count > 0 then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		end
	
		if system == 'cop' and Config.CopNetJob ~= nil and Config.CopNetJob ~= 'nil' and PlayerData.job ~= nil then
			local found = false
	
			for k,v in pairs(Config.CopNetJob) do
				if PlayerData.job.name == v then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		elseif system == 'medic' and Config.MedicNetJob ~= nil and Config.MedicNetJob ~= 'nil' and PlayerData.job ~= nil then
			local found = false
			
			for k,v in pairs(Config.MedicNetJob) do
				if PlayerData.job.name == v then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		elseif system == 'car' and newSite ~= 'katalog' and Config.CarNetJob ~= nil and Config.CarNetJob ~= 'nil' and PlayerData.job ~= nil then
			local found = false
			
			for k,v in pairs(Config.CarNetJob) do
				if PlayerData.job.name == v then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		elseif system == 'fd' and newSite ~= 'katalog' and Config.FireNetJob ~= nil and Config.FireNetJob ~= 'nil' and PlayerData.job ~= nil then
			local found = false
			
			for k,v in pairs(Config.FireNetJob) do
				if PlayerData.job.name == v then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		end
	elseif Config.Version == 'qb' then
		PlayerData = QBCore.Functions.GetPlayerData()

		if newSite == 'tab' and Config.NeededItem ~= nil and Config.NeededItem ~= 'nil' then 
			local found = false
	
			for k,v in pairs(PlayerData.items) do
				if found == true then
					break
				elseif type(Config.NeededItem) == 'table' then
					for key,value in pairs(Config.NeededItem) do
						if v.name ~= nil and v.name ~= 'nil' and v.name == value and tonumber(v.amount) > 0 then
							found = true
							break
						end
					end
				elseif v.name == Config.NeededItem and tonumber(v.amount) > 0 then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		end
	
		if system == 'cop' and Config.CopNetJob ~= nil and Config.CopNetJob ~= 'nil' and PlayerData.job ~= nil then
			local found = false
	
			for k,v in pairs(Config.CopNetJob) do
				if PlayerData.job.name == v then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		elseif system == 'medic' and Config.MedicNetJob ~= nil and Config.MedicNetJob ~= 'nil' and PlayerData.job ~= nil then
			local found = false
			
			for k,v in pairs(Config.MedicNetJob) do
				if PlayerData.job.name == v then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		elseif system == 'car' and newSite ~= 'katalog' and Config.CarNetJob ~= nil and Config.CarNetJob ~= 'nil' and PlayerData.job ~= nil then
			local found = false
			
			for k,v in pairs(Config.CarNetJob) do
				if PlayerData.job.name == v then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		elseif system == 'fd' and newSite ~= 'katalog' and Config.FireNetJob ~= nil and Config.FireNetJob ~= 'nil' and PlayerData.job ~= nil then
			local found = false
			
			for k,v in pairs(Config.FireNetJob) do
				if PlayerData.job.name == v then
					found = true
					break
				end
			end
	
			if found == false then
				return false
			end
		end
	end
	
	return canOpen, canOpenType
end

RegisterNetEvent('vCAD:openUI')
AddEventHandler('vCAD:openUI', function(system, newSite, publicid)
	local reloadTab = false


	if not system then
		print('[vCAD_UI] Error: `SYSTEM` Argument ist ungültig oder nicht angegeben.')
		return
	end

	if not newSite then
		print('[vCAD_UI] Error: `TYPE` Argument ist ungültig oder nicht angegeben.')
		return
	end

	if not isDead then
		local canOpen, canOpenType = canOpenTablet(system, newSite, publicid)

		if canOpen == true then
			if (GetGameTimer() - lastOpend) > 250 then
				if site ~= system then
					site = system
					reloadTab = true
				end

				if subSite ~= canOpenType then
					subSite = canOpenType
					reloadTab = true
				end

				if publicid ~= true and publicid ~= false and PublicID ~= publicid then
					PublicID = publicid
					reloadTab = true
				end
				
				lastOpend = GetGameTimer()
				tabEnabled = true
				TOGGLE_NUI_FOCUS(true, reloadTab)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if Config.NativeUIEnabled then
			_menuPool:ProcessMenus()
		end

		if NetworkIsPlayerActive(PlayerId()) then
			local PlayerPed = PlayerPedId()

			if IsPedFatallyInjured(PlayerPed) and not isDead then
				isDead = true
					
				if tabEnabled then
					tabEnabled = false
					TOGGLE_NUI_FOCUS(false)
				end
			elseif not IsPedFatallyInjured(PlayerPed) then
				isDead = false
			end
		end
	end
end)

Citizen.CreateThread(function()
	while #Config.Zones > 0 do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		for k,v in ipairs(Config.Zones) do
			local distance = #(playerCoords - v.Coords)
		
			if distance < 50.0 then
				DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
				letSleep = false

				
				if distance <= Config.Marker.x then
					ShowHelpNotification(v.Prompt)

					if IsControlJustReleased(0, Keys['E']) then
						TriggerEvent('vCAD:openUI', v.System, v.OpenType, v.PublicID or true)
					end
				end
			end
		end

		if letSleep then
			Citizen.Wait(2500)
		end
	end
end)

if Config.Hotkey ~= nil and Config.Hotkey ~= "nil" then
	RegisterKeyMapping('copnet', 'Copnet Tablet', 'keyboard', string.upper(Config.Hotkey))
end

if Config.MedicHotkey ~= nil and Config.MedicHotkey ~= "nil" then
	RegisterKeyMapping('medicnet', 'Medicnet Tablet', 'keyboard', string.upper(Config.MedicHotkey))
end

if Config.CarHotkey ~= nil and Config.CarHotkey ~= "nil" then
	RegisterKeyMapping('carnet', 'Carnet Tablet', 'keyboard', string.upper(Config.CarHotkey))
end

if Config.FDHotkey ~= nil and Config.FDHotkey ~= "nil" then
	RegisterKeyMapping('firenet', 'FireNet Tablet', 'keyboard', string.upper(Config.FDHotkey))
end

if Config.Commands.Tablet == true or (Config.Hotkey ~= nil and Config.Hotkey ~= "nil") then
	RegisterCommand('copnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'cop', Config.OpenType)
	end, false)
end

if Config.Commands.Tablet == true or (Config.MedicHotkey ~= nil and Config.MedicHotkey ~= "nil") then
	RegisterCommand('medicnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'medic', Config.OpenType)
	end, false)
end

if Config.Commands.Tablet == true or (Config.CarHotkey ~= nil and Config.CarHotkey ~= "nil") then
	RegisterCommand('carnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'car', Config.OpenType)
	end, false)
end

if Config.Commands.Tablet == true or (Config.FDHotkey ~= nil and Config.FDHotkey ~= "nil") then
	RegisterCommand('firenet',function(source, args)
		TriggerEvent('vCAD:openUI', 'fd', Config.OpenType)
	end, false)
end

if Config.Commands.Gesetze ~= nil and Config.Commands.Gesetze ~= 'nil' then
	RegisterCommand("gesetze", function(source, args, rawCommand)
		TriggerEvent('vCAD:openUI', 'cop', 'strafen', Config.Commands.Gesetze)
	end)
end

RegisterNetEvent('vCAD:AddPunkt')
AddEventHandler('vCAD:AddPunkt', function(rs) 
	--[[
		table.insert(Config.Zones, {
        Coords = rs.Coords,
        Prompt = rs.Prompt,
        System = rs.System,
        OpenType = rs.Type,
        PublicID = rs.PublicID
    })
	]]
	ShowNotification("!!!Damit dies Funktioniert, restarte bitte das Tablet!!!", "info")
end)

function CheckSystem(System)
	local Variables = {
		["cop"] = "Copnet",
		["medic"] = "Medicnet",
		["car"] = "Carnet",
		["fd"] = "Firenet"
	}

	for k, v in pairs(Variables) do
		if k == System or v == System then
			return k
		end
	end
	return false
end

function CheckPrompt(Prompt)
	local Variables = {
		["pc"] = "Drücke ~INPUT_CONTEXT~ um den Pc zu Benutzen.",
		["hp"] = "Drücke ~INPUT_CONTEXT~ um die Öffentliche Homepage einzusehen.",
		["bewerben"] = "Drücke ~INPUT_CONTEXT~ um dich zu Bewerben.",
		["katalog"] = "Drücke ~INPUT_CONTEXT~ um den Katalog zu öffnen.",
		["calendar"] = "Drücke ~INPUT_CONTEXT~ um den Öffentlichen Kalender einzusehen.",
		["wanted"] = "Drücke ~INPUT_CONTEXT~ um die Öffentlichen Fahndung zu sehen.",
		["beschweren"] = "Drücke ~INPUT_CONTEXT~ um dich zu Beschweren.",
		["rechnung"] = "Drücke ~INPUT_CONTEXT~ um deine Rechnung einzusehen."
	}

	for k, v in pairs(Variables) do
		if k == Prompt then
			return v
		end
	end
	return false
end

RegisterNetEvent('vCAD:CreateZone')
AddEventHandler('vCAD:CreateZone', function(args)
	if Config.NativeUIEnabled then
		OpenMenu()
		Wait(100)
		xOpenMenu:Visible(not xOpenMenu:Visible())
	else
		OpenMenu(args)
	end
end)

if Config.NativeUIEnabled and not Config.OxMySQL then
	function OpenMenu()
		_menuPool:Remove()
	
		local System = 'cop'
		local PublicID = nil
	
		if xOpenMenu ~= nil and xOpenMenu:Visible() then
			xOpenMenu:Visible(false)
			return
		end
	
		xOpenMenu = NativeUI.CreateMenu('vCAD', 'Hier kannst du Positionen Hinzufügen für das Tablet.', 5, 100)
		_menuPool:Add(xOpenMenu)

	
		local auswahl = {"~b~CopNet", "~r~MedicNet", "~y~CarNet", "~o~FireNet"}
		local xSystem = NativeUI.CreateListItem("System:", auswahl, 1)
		xOpenMenu:AddItem(xSystem)
	
		local xfrei = NativeUI.CreateItem('----------------------------------', '')
		xOpenMenu:AddItem(xfrei)
	
		local xPcSetzen = NativeUI.CreateItem('🖥️ Pc setzen', 'Setzt den PC für das System (~r~siehe oben~s~)')
		xPcSetzen.Activated = function(sender, item)
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)

			local Prompt = CheckPrompt('pc')


			TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, 'pc', Prompt, System)
		end
		xOpenMenu:AddItem(xPcSetzen)
	
		local BewerbungenAdd = NativeUI.CreateItem('📓 Bewerbungspunkt Hinzufügen', 'Fügt ein PC Hinzu wo sich die Personen Bewerben können für das System (~r~siehe oben~s~).')
		BewerbungenAdd.Activated = function(sender, item)
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")
	
			if PublicID == nil or PublicID == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = CheckPrompt('bewerben')
	
			TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, 'bewerben', Prompt, System)
		end
		xOpenMenu:AddItem(BewerbungenAdd)
	
		-------------------------------------------------------------------------------------------------------------------------
		local BeschwerdenAdd = NativeUI.CreateItem('🤬 Beschwerdepunkt Hinzufügen', 'Fügt ein PC Hinzu wo sich die Personen Beschwerden können für das System (~r~siehe oben~s~).')
		BeschwerdenAdd.Activated = function(sender, item)
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")
	
			if PublicID == nil or PublicID == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = CheckPrompt('beschweren')
	
			TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, 'beschweren', Prompt, System)
		end
		xOpenMenu:AddItem(BeschwerdenAdd)
	
		local CalendarAdd = NativeUI.CreateItem('🗓️ Kalenderpunkt Hinzufügen', 'Fügt ein Punkt Hinzu, wo Spieler den Öffentlichen Kalender einsehen können. Für das System (~r~siehe oben~s).')
		CalendarAdd.Activated = function(sender, item)
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")
	
			if PublicID == nil or PublicID == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = CheckPrompt('calendar')
	
			TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, 'calendar', Prompt, System)
		end
		xOpenMenu:AddItem(CalendarAdd)

		local HpAdd = NativeUI.CreateItem('🖥️ Homepage Hinzufügen', 'Fügt ein Punkt Hinzu, wo Spieler die Öffentliche Homepage aufrufen können. Für das System (~r~siehe oben~s).')
        HpAdd.Activated = function(sender, item)
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")
	
			if PublicID == nil or PublicID == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = CheckPrompt('hp')
	
			TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, 'hp', Prompt, System)
		end
		xOpenMenu:AddItem(HpAdd)
		-------------------------------------------------------------------------------------------------------------------------
	
	
	
		local xfrei = NativeUI.CreateItem('----------------------------------', '')
		xOpenMenu:AddItem(xfrei)
	
		local StrafenKatalogAdd = NativeUI.CreateItem('🔎 Strafen Katalog Hinzufügen', 'An diesem Punkt können die Spieler dann die Strafen einsehen.')
		StrafenKatalogAdd.Activated = function(sender, item)
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")
	
			if PublicID == nil or PublicID == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = CheckPrompt('strafen')

			TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, 'strafen', Prompt, System)
		end
		xOpenMenu:AddItem(StrafenKatalogAdd)
	
		local FahndungAdd = NativeUI.CreateItem('🚨 Fahndungspunkt Hinzufügen', 'An diesem Punkt können die Spieler die Öffentlichen Fahndungen einsehen.')
		FahndungAdd.Activated = function(sender, item)
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")
	
			if PublicID == nil or PublicID == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = CheckPrompt('wanted')
	
			TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, 'wanted', Prompt, System)
		end
		xOpenMenu:AddItem(FahndungAdd)
	
		local CarNetKatalogAdd = NativeUI.CreateItem('🚘 CarNet Katalog Hinzufügen', 'Hier ist es möglich den ~y~CarNet~s~ Katalog einzusehen.')
		CarNetKatalogAdd.Activated = function(sender, item)
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")
	
			if PublicID == nil or PublicID == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = CheckPrompt('katalog')
	
			TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, 'katalog', Prompt, System)
		end
		xOpenMenu:AddItem(CarNetKatalogAdd)
	
	
	
		xOpenMenu.OnListChange = function(sender, item, index)
			if item == xSystem then
				System = item:IndexToItem(index)
	
				if System == '~b~CopNet' then
					System = 'cop'
				elseif System == '~r~MedicNet' then
					System = 'medic'
				elseif System == '~y~CarNet' then
					System = 'car'
				elseif System == '~o~FireNet' then
					System = 'fd'
				end
	
				print(System)
			end
		end
	
	
		_menuPool:RefreshIndex()
		_menuPool:MouseControlsEnabled (false);
		_menuPool:MouseEdgeEnabled (false);
		_menuPool:ControlDisablingEnabled(false);
	end
end

if not Config.NativeUIEnabled and not Config.OxMySQL then

	Citizen.CreateThread(function()
		TriggerEvent("chat:addSuggestion", "/vcad", "Generiert ein punkt mit dem zugang für ein PC, Strafen, Bewerber, Beschwerde, Kalender, Fahndung, Katalog oder für die Homepage",{ 
			{name = "möglichkeiten:", help = "pc, strafen, bewerben, katalog, beschwerden, kalender, fahndung, hp"},
		})
	end)

	function OpenMenu(args)
		local PublicID = nil

		if args[1] == "pc" then
			local System = CreateDialog('Copnet, Medicnet, Firenet oder Carnet?')

			System = CheckSystem(System)
			if System == false then
				ShowNotification('Falsche angabe [System]', "error")
			end

			if pid ~= nil or pid ~= '' then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z - 1.0)

				local Prompt = CheckPrompt(args[1])

				if Prompt == false then
					ShowNotification("Hier ist ein Fehler aufgetaucht [Prompt]", "error")
					return
				end

				TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, args[1], Prompt, System)
				return
			else
				ShowNotification("Es wurde keine PublicID eingegeben!", "error")
				return
			end
		end

		if args[1] == "strafen" then
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")

			if PublicID ~= nil or PublicID ~= "" then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z - 1.0)
				local Prompt = 'Drücke ~INPUT_CONTEXT~ um dir die Strafen anzuschauen.'

				TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, args[1], Prompt, 'cop')
				return
			else
				ShowNotification("Es wurde keine PublicID eingegeben!", "error")
				return
			end
		end
		if args[1] == "katalog" then
			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")

			if PublicID ~= nil or PublicID ~= "" then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z - 1.0)
				local Prompt = 'Drücke ~INPUT_CONTEXT~ um den Katalog zu öffnen.'

				TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, args[1], Prompt, 'car')
				return
			else
				ShowNotification("Es wurde keine PublicID eingegeben!", "error")
				return
			end
		end
		if args[1] == "hp" or args[1] == "bewerben" or args[1] == "pc" or args[1] == "calendar" or args[1] == "wanted" or args[1] == "beschweren" then
			local System = CreateDialog('Copnet, Medicnet, Firenet oder Carnet?')

			System = CheckSystem(System)
			if System == false then
				ShowNotification('Falsche angabe [System]', "error")
			end

			ShowNotification("Gib nun die PublicID ein!", "info")
			Wait(500)
			PublicID = CreateDialog("PublicID")

			if pid ~= nil or pid ~= '' then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z - 1.0)

				local Prompt = CheckPrompt(args[1])

				if Prompt == false then
					ShowNotification("Hier ist ein Fehler aufgetaucht [Prompt]", "error")
					return
				end

				TriggerServerEvent('vCAD:SaveZonenConfig', posi, PublicID, args[1], Prompt, System)
				return
			else
				ShowNotification("Es wurde keine PublicID eingegeben!", "error")
				return
			end
		end
	end
end