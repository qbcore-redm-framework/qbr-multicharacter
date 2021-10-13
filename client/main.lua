local QBCore = exports['qbr-core']:GetCoreObject()
local charPed = nil
local choosingCharacter = false
local cams = {
    {
        type = "customization",
        x = -561.8157,
        y = -3780.966,
        z = 239.0805,
        rx = -4.2146,
        ry = -0.0007,
        rz = -87.8802,
        fov = 30.0
    },
    {
        type = "selection",
        x = -562.8157,
        y = -3776.266,
        z = 239.0805,
        rx = -4.2146,
        ry = -0.0007,
        rz = -87.8802,
        fov = 30.0
    }
}

-- Config = {
--     PedCoords = vector4(-558.9098, -3775.616, 238.59, 137.98),
--     HiddenCoords = vector4(-558.9098, -3775.616, 238.59, 137.98),
--     -- CamCoords = vector4(-814.02, 179.56, 76.74, 198.5),
-- }

Citizen.CreateThread(function()
    RequestImap(-1699673416)
    RequestImap(1679934574)
    RequestImap(183712523)

	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('qbr-multicharacter:client:chooseChar')
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
            NetworkStartSoloTutorialSession()
            print('Adding to tutorial session')
            exports['qbr-weathersync']:disableSync()
			return
		end
	end
end)
local currentSkin = nil
local currentClothes = nil
local selectingChar = true
RegisterNUICallback('cDataPed', function(data) -- Visually seeing the char
    local cData = data.cData
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)

    if cData then
        QBCore.Functions.TriggerCallback('qbr-multicharacter:server:getSkin', function(data)
            model = data.model ~= nil and tonumber(data.model) or false
            currentSkin = data.skin
            currentClothes = data.clothes
            if model then
                CreateThread(function()
                    while not HasModelLoaded(model) do
                        RequestModel(model)
                        Wait(0)
                    end
                    charPed = CreatePed(model, -558.91, -3776.25, 237.63, 90.0, false, false)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    while not DoesEntityExist(charPed) do
                        Wait(10)
                    end
                    while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, charPed) do
                        Wait(5)
                    end
                    Wait(100)
                    -- This seems to happen only on the first login
                    exports['qbr-clothing']:loadSkin(charPed, currentSkin, true)
                    Wait(500)

                    while not exports['qbr-clothing']:isPedUsingComponent(charPed) do
                        Wait(500)
                    end
                    exports['qbr-clothing']:loadClothes(charPed, currentClothes, false)
                end)
            else
                CreateThread(function()
                    local randommodels = {
                        "mp_male",
                        "mp_female",
                    }
                    local randomModel = randommodels[math.random(1, #randommodels)]
                    local model = GetHashKey(randomModel)
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    charPed = CreatePed(model, -558.91, -3776.25, 237.63, 90.0, false, false)
                    Wait(100)
                    exports['qbr-clothing']:doesThisFixWorks(charPed, sex)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    NetworkSetEntityInvisibleToNetwork(charPed, true);
                end)
            end
        end, cData.citizenid)
    else
        CreateThread(function()
            local randommodels = {
                "mp_male",
                "mp_female",
            }
            local randomModel = randommodels[math.random(1, #randommodels)]
            local model = GetHashKey(randomModel)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end
            charPed = CreatePed(model, -558.91, -3776.25, 237.63, 90.0, false, false)
            Wait(100)
            local sex = IsPedMale(charPed) and 'Male' or 'Female'
            exports['qbr-clothing']:doesThisFixWorks(charPed, sex)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            NetworkSetEntityInvisibleToNetwork(charPed, true);
            SetBlockingOfNonTemporaryEvents(charPed, true)
        end)
    end
end)

function tprint (tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
        toprint = toprint .. string.rep(" ", indent)
        if (type(k) == "number") then
            toprint = toprint .. "[" .. k .. "] = "
        elseif (type(k) == "string") then
            toprint = toprint  .. k ..  "= "
        end
        if (type(v) == "number") then
            toprint = toprint .. v .. ",\r\n"
        elseif (type(v) == "string") then
            toprint = toprint .. "\"" .. v .. "\",\r\n"
        elseif (type(v) == "table") then
            toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
        else
            toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
        end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
end

RegisterNUICallback('selectCharacter', function(data) -- When a char is selected and confirmed to use
    Citizen.CreateThread(function()
        selectingChar = false
        local cData = data.cData
        DoScreenFadeOut(10)
        exports['qbr-weathersync']:enableSync()
        TriggerServerEvent('qbr-multicharacter:server:loadUserData', cData)
        giveUI(false)
        local model = IsPedMale(charPed) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        Wait(5000)
        exports['qbr-clothing']:RequestAndSetModel(model)
        Wait(200)
        exports['qbr-clothing']:loadSkin(PlayerPedId(), currentSkin, true)
            Wait(500)
        while not exports['qbr-clothing']:loadClothes(PlayerPedId(), currentClothes, false) do
            Wait(500)
        end
        SetModelAsNoLongerNeeded(model)
    end)
end)

RegisterNUICallback('setupCharacters', function() -- Present char info
    QBCore.Functions.TriggerCallback("qbr-multicharacter:server:loadUserInfo", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
    end)
end)

RegisterNUICallback('removeBlur', function()
    SetTimecycleModifier('default')
end)

RegisterNUICallback('createNewCharacter', function(data) -- Creating a char
    DoScreenFadeOut(150)
    Wait(200)
    DestroyAllCams(true)
    if data.gender == "Male" then
        data.gender = 0
    elseif data.gender == "Female" then
        data.gender = 1
    end
    createCharacter(data.gender)

    TriggerServerEvent('qbr-multicharacter:server:createCharacter', data)
    SetEntityCoords(PlayerPedId(), -558.71, -3781.6, 238.6 - 1.0)
    TriggerEvent('qbr-clothing:client:newPlayer')
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
end)

function createCharacter(sex)
    if (sex == 0) then
        local model = 'mp_male'
        exports['qbr-clothing']:RequestAndSetModel(model)
        Wait(1000)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x158cb7f2, true, true, true); --head
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x16e292a1, true, true, true); --torso
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0xa615e02, true, true, true); --legs
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x105ddb4, true, true, true); --hair
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x10404a83, true, true, true); --mustache
        SetModelAsNoLongerNeeded(model)
    else
        local model = 'mp_female'
        exports['qbr-clothing']:RequestAndSetModel(model)
        Wait(1000)
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x11567c3, true, true, true); --head
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x2c4fe0c5, true, true, true); --torso
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0xaa25eca7, true, true, true); --legs
        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0x104293ea, true, true, true); --hair
        SetModelAsNoLongerNeeded(model)
    end
    selectingChar = false
    DeleteEntity(charPed)
    SetModelAsNoLongerNeeded(charPed)
end

RegisterNUICallback('removeCharacter', function(data) -- Removing a char
    TriggerServerEvent('qbr-multicharacter:server:deleteCharacter', data.citizenid)
    TriggerEvent('qbr-multicharacter:client:chooseChar')
end)

RegisterNUICallback('disconnectButton', function() -- Disconnect
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    TriggerServerEvent('qbr-multicharacter:server:disconnect')
end)

RegisterNetEvent('qbr-multicharacter:client:chooseChar')
AddEventHandler('qbr-multicharacter:client:chooseChar', function()
    SetEntityVisible(PlayerPedId(), false, false)
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Citizen.Wait(1000)
    GetInteriorAtCoords(-558.9098, -3775.616, 238.59, 137.98)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), -562.91,-3776.25,237.63)
    Citizen.Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Citizen.Wait(10)
    giveUI(true)
    while selectingChar do
        Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
        DrawLightWithRange(coords.x, coords.y , coords.z + 1.0 , 255, 255, 255, 5.5, 50.0)
    end
end)

RegisterNetEvent('qbr-multicharacter:client:closeNUI')
AddEventHandler('qbr-multicharacter:client:closeNUI', function()
    SetNuiFocus(false, false)
end)

function giveUI(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        toggle = bool,
    })
    choosingCharacter = bool
    Citizen.Wait(100)
    skyCam(bool)
end

function skyCam(bool)
    if bool then
        DoScreenFadeIn(1000)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        SetCamCoord(cam, -555.925,-3778.709,238.597)
        SetCamRot(cam, -20.0, 0.0, 83)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
        fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
        SetCamCoord(fixedCam, -561.206,-3776.224,239.597)
        SetCamRot(fixedCam, -20.0, 0, 270.0)
        SetCamActive(fixedCam, true)
        SetCamActiveWithInterp(fixedCam, cam, 3900, true, true)
        Wait(3900)
        DestroyCam(groundCam)
        InterP = true
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end


AddEventHandler('onResourceStop', function(resource)
    if (GetCurrentResourceName() == resource) then
        DeleteEntity(charPed)
        SetModelAsNoLongerNeeded(charPed)
    end
end)
