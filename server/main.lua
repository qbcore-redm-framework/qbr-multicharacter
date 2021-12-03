local QBCore = exports['qbr-core']:GetCoreObject()

RegisterServerEvent('qbr-multicharacter:server:disconnect')
AddEventHandler('qbr-multicharacter:server:disconnect', function()
    local src = source
    DropPlayer(src, "You have disconnected from QBCore RedM")
end)

RegisterServerEvent('qbr-multicharacter:server:loadUserData')
AddEventHandler('qbr-multicharacter:server:loadUserData', function(cData)
    local src = source
    if QBCore.Player.Login(src, cData.citizenid) then
        print('^2[qbr-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        QBCore.Commands.Refresh(src)

        TriggerClientEvent("qbr-multicharacter:client:closeNUI", src)
        TriggerClientEvent('qbr-spawn:client:setupSpawnUI', src, cData, false)
        TriggerEvent("qbr-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(src) .. "** ("..cData.citizenid.." | "..src..") loaded..")
	end
end)

RegisterServerEvent('qbr-multicharacter:server:createCharacter')
AddEventHandler('qbr-multicharacter:server:createCharacter', function(data, enabledhouses)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    if QBCore.Player.Login(src, false, newData) then
        print('^2[qbr-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
        QBCore.Commands.Refresh(src)
        --[[if enabledhouses then
            loadHouseData()
        end]]

        TriggerClientEvent("qbr-multicharacter:client:closeNUI", src)
        TriggerClientEvent('qbr-spawn:client:setupSpawnUI', src, newData, true)
        --GiveStarterItems(src)
	end
end)

RegisterServerEvent('qbr-multicharacter:server:deleteCharacter')
AddEventHandler('qbr-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    QBCore.Player.DeleteCharacter(src, citizenid)
end)

QBCore.Functions.CreateCallback("qbr-multicharacter:server:loadUserInfo", function(source, cb)
    local license = QBCore.Functions.GetIdentifier(source, 'license')
    local plyChars = {}

    exports.oxmysql:execute('SELECT * FROM players WHERE license = @license', {['@license'] = license}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)

            table.insert(plyChars, result[i])
        end
        cb(plyChars)
    end)
end)

QBCore.Functions.CreateCallback("qbr-multicharacter:server:getSkin", function(source, cb, cid)
    exports.oxmysql:execute('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1}, function(result)
        result[1].skin = json.decode(result[1].skin)
        result[1].clothes = json.decode(result[1].clothes)
        cb(result[1])
    end)
end)

QBCore.Commands.Add("logout", "Logout of Character (Admin Only)", {}, false, function(source, args)
    QBCore.Player.Logout(source)
    TriggerClientEvent('qbr-multicharacter:client:chooseChar', source)
end, "admin")

function GiveStarterItems(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for k, v in pairs(QBCore.Shared.StarterItems) do
        Player.Functions.AddItem(v.item, 1)
    end
end

function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
    local result = exports.oxmysql:executeSync('SELECT * FROM houselocations')
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = v.garage ~= nil and json.decode(v.garage) or {}
            Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = v.owned,
                price = v.price,
                locked = true,
                adress = v.label, 
                tier = v.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[v.name] = {
                label = v.label,
                takeVehicle = garage,
            }
        end
    end
    TriggerClientEvent("qbr-garages:client:houseGarageConfig", -1, HouseGarages)
    TriggerClientEvent("qbr-houses:client:setHouseConfig", -1, Houses)
end