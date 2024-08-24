ESX = nil
QBCore = nil

if Config.Version == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Version == "esx-legacy" then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.Version == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end


local function openUIwithCorrectJob_internal(src, jobs, playerJob, vCADnet)
    for _, job in pairs(jobs) do
        if job == playerJob then
            TriggerClientEvent('vCAD:openUI', src, vCADnet, Config.OpenType)
            return true
        end
    end

    return false
end

local function openUIwithCorrectJob(src, job)
    if openUIwithCorrectJob_internal(src, Config.CopNetJob, job, 'cop') then return end
    if openUIwithCorrectJob_internal(src, Config.MedicNetJob, job, 'medic') then return end
    if openUIwithCorrectJob_internal(src, Config.CarNetJob, job, 'car') then return end
    if openUIwithCorrectJob_internal(src, Config.FireNetJob, job, 'fd') then return end
end

local function registerFrameworkItemCallback(itemname)
    if Config.Version == "qb" then
        QBCore.Functions.CreateUseableItem(itemname, function(src, item)
            local Player = QBCore.Functions.GetPlayer(src)

            if Player.Functions.GetItemByName(item.name) then
                openUIwithCorrectJob(src, Player.PlayerData.job.name)
            end
        end)
    elseif Config.Version == "esx" or Config.Version == "esx-legacy" then
        ESX.RegisterUsableItem(itemname, function(src)
            local xPlayer = ESX.GetPlayerFromId(src)

            openUIwithCorrectJob(src, xPlayer.job.name)
        end)
    end
end

local function registerIfItemInTable(tableToCheck, itemname)
    for _, itemFromTable in pairs(tableToCheck) do
        if itemFromTable == itemname then
            registerFrameworkItemCallback(itemname)
            return true
        end
    end

    return false
end

if Config.CanUseItem and Config.Version and (Config.Version == "esx-legacy" or Config.Version == "esx" or Config.Version == "qb") then
    local canUseItemDataType = type(Config.CanUseItem)
    local neededItemDataType = type(Config.NeededItem)

    if canUseItemDataType == "string" and neededItemDataType == "string" then
        if Config.CanUseItem == Config.NeededItem then
            registerFrameworkItemCallback(Config.CanUseItem)
        end

        return
    end

    if canUseItemDataType == "string" and neededItemDataType == "table" then
        registerIfItemInTable(Config.NeededItem, Config.CanUseItem)
        return
    end

    if canUseItemDataType == "table" and neededItemDataType == "string" then
        registerIfItemInTable(Config.CanUseItem, Config.NeededItem)
        return
    end

    if canUseItemDataType == "table" and neededItemDataType == "table" then
        for _, canUseItemname in pairs(Config.CanUseItem) do
            if registerIfItemInTable(Config.NeededItem, canUseItemname) then
                break
            end
        end

        return
    end
end
