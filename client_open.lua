local Framework = 'none'
local ESX, QBCore = nil, nil
local PlayerJob = { name = 'unemployed', grade = 0 }
local ActiveBlips = {}
local ActivePeds = {}
local ShopsSynced = false

-- Safely convert any coord value (table, array, or vector3) to a proper vector3
local function EnsureVector3(v)
    if not v then return nil end
    local t = type(v)
    if t == 'vector3' then return v end
    if t == 'table' then
        if v.x then
            return vector3(v.x + 0.0, v.y + 0.0, v.z + 0.0)
        else
            return vector3((v[1] or 0) + 0.0, (v[2] or 0) + 0.0, (v[3] or 0) + 0.0)
        end
    end
    return v
end

-- Normalize all vector fields of a shop table to proper vector3
local function NormalizeShopVectors(shop)
    shop.coords = EnsureVector3(shop.coords)
    shop.MarkerSize = EnsureVector3(shop.MarkerSize)
    shop.MarkerPos = nil -- deprecated, use coords
end

function HasShopAccess(shop)
    if not shop.JobRestriction then return true end
    if type(shop.JobRestriction) == 'table' then
        for _, j in ipairs(shop.JobRestriction) do
            if PlayerJob.name == j then return true end
        end
        return false
    elseif shop.JobRestriction == PlayerJob.name then
        return true
    end
    return false
end

local function GetQBTargetJob(shop)
    if not shop.JobRestriction then return nil end
    local jobs = {}
    if type(shop.JobRestriction) == 'table' then
        for _, jobName in ipairs(shop.JobRestriction) do
            jobs[jobName] = 0
        end
    else
        jobs[shop.JobRestriction] = 0
    end
    return jobs
end

local function GetOxTargetGroups(shop)
    if not shop.JobRestriction then return nil end
    local groups = {}
    if type(shop.JobRestriction) == 'table' then
        for _, jobName in ipairs(shop.JobRestriction) do
            groups[jobName] = 0
        end
    else
        groups[shop.JobRestriction] = 0
    end
    return groups
end

function RefreshBlips()
    for shopId, shop in pairs(Config.Shops) do
        if shop.Blipname then
            local hasAccess = HasShopAccess(shop)
            if hasAccess then
                -- Remove old blip so it gets recreated with current data
                if ActiveBlips[shopId] then
                    RemoveBlip(ActiveBlips[shopId])
                    ActiveBlips[shopId] = nil
                end
                local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
                SetBlipSprite(blip, shop.BlipSprite or 52)
                if shop.BlipMinimapOnly then SetBlipDisplay(blip, 5) else SetBlipDisplay(blip, 4) end
                SetBlipScale(blip, 0.7)
                SetBlipColour(blip, shop.BlipColor or 2)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(shop.Blipname)
                EndTextCommandSetBlipName(blip)
                ActiveBlips[shopId] = blip
            elseif ActiveBlips[shopId] then
                RemoveBlip(ActiveBlips[shopId])
                ActiveBlips[shopId] = nil
            end
        else
            -- Shop has no Blipname (anymore) — remove stale blip if it exists
            if ActiveBlips[shopId] then
                RemoveBlip(ActiveBlips[shopId])
                ActiveBlips[shopId] = nil
            end
        end
    end
    -- Also refresh peds when job changes
    if RefreshShopPeds then RefreshShopPeds() end
end

-- Receive saved shops (dynamic + overrides) from server on connect
RegisterNetEvent('mizu_smartshop:client:receiveSavedShops', function(shops)
    for id, shop in pairs(shops) do
        NormalizeShopVectors(shop)
        Config.Shops[id] = shop
    end
    ShopsSynced = true
    RefreshBlips()
    RefreshShopPeds()
end)

local function SyncAndRefresh()
    TriggerServerEvent('mizu_smartshop:server:requestSavedShops')
end

if GetResourceState('es_extended') == 'started' then
    Framework = 'esx'
    ESX = exports['es_extended']:getSharedObject()
    CreateThread(function()
        while ESX.GetPlayerData().job == nil do Wait(100) end
        PlayerJob = { name = ESX.GetPlayerData().job.name, grade = ESX.GetPlayerData().job.grade }
        SyncAndRefresh()
    end)
    RegisterNetEvent('esx:setJob', function(job)
        PlayerJob = { name = job.name, grade = job.grade }
        RefreshBlips()
    end)
elseif GetResourceState('qbx_core') == 'started' then
    Framework = 'qbox'
    CreateThread(function()
        while exports.qbx_core:GetPlayerData().job == nil do Wait(100) end
        local job = exports.qbx_core:GetPlayerData().job
        PlayerJob = { name = job.name, grade = job.grade.level }
        SyncAndRefresh()
    end)
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        PlayerJob = { name = job.name, grade = job.grade.level }
        RefreshBlips()
    end)
elseif GetResourceState('qb-core') == 'started' then
    Framework = 'qbcore'
    QBCore = exports['qb-core']:GetCoreObject()
    CreateThread(function()
        while QBCore.Functions.GetPlayerData().job == nil do Wait(100) end
        local job = QBCore.Functions.GetPlayerData().job
        PlayerJob = { name = job.name, grade = job.grade.level }
        SyncAndRefresh()
    end)
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        PlayerJob = { name = job.name, grade = job.grade.level }
        RefreshBlips()
    end)
else
    -- Standalone: sync shops immediately
    CreateThread(function()
        SyncAndRefresh()
    end)
end

-- Fallback job poll — catches job changes that don't fire events (e.g. admin commands)
CreateThread(function()
    while true do
        Wait(5000)
        local newJob = nil
        if Framework == 'qbcore' then
            local pd = QBCore.Functions.GetPlayerData()
            if pd and pd.job then newJob = { name = pd.job.name, grade = pd.job.grade.level } end
        elseif Framework == 'qbox' then
            local pd = exports.qbx_core:GetPlayerData()
            if pd and pd.job then newJob = { name = pd.job.name, grade = pd.job.grade.level } end
        elseif Framework == 'esx' then
            local pd = ESX.GetPlayerData()
            if pd and pd.job then newJob = { name = pd.job.name, grade = pd.job.grade } end
        end
        if newJob and (newJob.name ~= PlayerJob.name or newJob.grade ~= PlayerJob.grade) then
            PlayerJob = newJob
            RefreshBlips()
        end
    end
end)

-- Ped Management
function SpawnShopPed(shopId, shop)
    DeleteShopPed(shopId)

    if not shop.PedModel or shop.PedModel == '' then return end
    if not HasShopAccess(shop) then return end

    local modelHash = GetHashKey(shop.PedModel)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 50 do
        Wait(100)
        timeout = timeout + 1
    end
    if not HasModelLoaded(modelHash) then
        print('^1[mizu_smartshop] Failed to load ped model: ' .. shop.PedModel .. '^0')
        return
    end

    local coords = shop.coords
    local ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z, shop.PedHeading or 0.0, false, true)
    SetModelAsNoLongerNeeded(modelHash)

    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedCanRagdoll(ped, false)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    FreezeEntityPosition(ped, true)

    if shop.PedScenario and shop.PedScenario ~= '' then
        TaskStartScenarioInPlace(ped, shop.PedScenario, 0, true)
    end

    ActivePeds[shopId] = ped

    -- Set up target interaction
    if Config.TargetSystem == 'qb-target' and GetResourceState('qb-target') == 'started' then
        pcall(function()
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        type = "client",
                        action = function()
                            OpenShop(shopId)
                        end,
                        icon = "fas fa-shopping-cart",
                        label = _U('target_open_shop'),
                        job = GetQBTargetJob(shop),
                    },
                },
                distance = 2.5
            })
        end)
    elseif Config.TargetSystem == 'ox-target' and GetResourceState('ox_target') == 'started' then
        pcall(function()
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = shopId .. '_smartshop_ped',
                    icon = 'fas fa-shopping-cart',
                    label = _U('target_open_shop'),
                    groups = GetOxTargetGroups(shop),
                    onSelect = function()
                        OpenShop(shopId)
                    end
                }
            })
        end)
    end
end

function DeleteShopPed(shopId)
    if ActivePeds[shopId] then
        if DoesEntityExist(ActivePeds[shopId]) then
            DeleteEntity(ActivePeds[shopId])
        end
        ActivePeds[shopId] = nil
    end
end

function RefreshShopPeds()
    -- Remove all active peds
    for shopId, ped in pairs(ActivePeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    ActivePeds = {}

    -- Respawn peds where PedModel is set
    for shopId, shop in pairs(Config.Shops) do
        if shop.PedModel and shop.PedModel ~= '' then
            SpawnShopPed(shopId, shop)
        end
    end
end

local CurrentShop = nil

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    CurrentShop = nil
    cb('ok')
end)

RegisterNUICallback('checkoutCart', function(data, cb)
    if CurrentShop and data.cart and #data.cart > 0 and data.paymentType then
        TriggerServerEvent('mizu_smartshop:server:checkoutCart', CurrentShop, data.cart, data.paymentType)
    end
    cb('ok')
end)

function OpenShop(shopId)
    local shop = Config.Shops[shopId]
    if not shop then return end

    if not HasShopAccess(shop) then
        TriggerEvent('mizu_smartshop:client:notify', _U('no_permission') or 'You do not have permission.', 'error')
        return
    end

    local filteredItems = {}
    for _, item in ipairs(shop.items) do
        local requiredGrade = item.grade or 0
        if PlayerJob.grade >= requiredGrade then
            table.insert(filteredItems, item)
        end
    end

    CurrentShop = shopId
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openShop',
        shopName = shop.name,
        items = filteredItems,
        locales = Locales[Config.Locale],
        theme = Config.Theme or 'default'
    })
end

-- Marker fallback (when no target system is used)
if Config.TargetSystem == 'none' then
    CreateThread(function()
        while true do
            local sleep = 1500
            
            -- hide marker and stop distance checks while shop ui is open
            if not CurrentShop then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)

                for shopId, shop in pairs(Config.Shops) do
                    if HasShopAccess(shop) then
                        -- Ped shops use direct interaction instead of marker
                        local hasPed = shop.PedModel and shop.PedModel ~= ''

                        if hasPed then
                            -- Distance check to ped entity
                            local pedEntity = ActivePeds[shopId]
                            if pedEntity and DoesEntityExist(pedEntity) then
                                local pedCoords = GetEntityCoords(pedEntity)
                                local dist = #(pos - pedCoords)
                                if dist < 3.0 then
                                    sleep = 0
                                    if dist < 1.8 then
                                        if GetResourceState('mizu_interface') == 'started' then
                                            exports['mizu_interface']:TextUI('E', _U('open_shop_prompt') or 'Shop öffnen')
                                        else
                                            DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, _U('open_shop_prompt'))
                                        end
                                        if IsControlJustReleased(0, 38) then -- E key
                                            OpenShop(shopId)
                                        end
                                    end
                                end
                            end
                        else
                            local dist = #(pos - shop.coords)

                            if dist < 10.0 then
                                sleep = 0
                                if shop.MarkerType then
                                    local mPos = shop.coords
                                    local mSize = shop.MarkerSize or vector3(0.3, 0.2, 0.15)
                                    local r = shop.MarkerColor and shop.MarkerColor.r or 30
                                    local g = shop.MarkerColor and shop.MarkerColor.g or 150
                                    local b = shop.MarkerColor and shop.MarkerColor.b or 30
                                    local a = shop.MarkerColor and shop.MarkerColor.a or 100
                                    DrawMarker(shop.MarkerType, mPos.x, mPos.y, mPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mSize.x, mSize.y, mSize.z, r, g, b, a, false, true, 2, false, nil, nil, false)
                                end
                                
                                if dist < 1.5 then
                                    if GetResourceState('mizu_interface') == 'started' then
                                        exports['mizu_interface']:TextUI('E', _U('open_shop_prompt') or 'Shop öffnen')
                                    else
                                        DrawText3D(shop.coords.x, shop.coords.y, shop.coords.z + 0.3, _U('open_shop_prompt'))
                                    end
                                    if IsControlJustReleased(0, 38) then -- E key
                                        OpenShop(shopId)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            Wait(sleep)
        end
    end)
end

-- Target system setup
CreateThread(function()
    -- Wait for saved shops to sync from server
    while not ShopsSynced do Wait(100) end

    if Config.TargetSystem == 'qb-target' then
        if GetResourceState('qb-target') ~= 'started' then
            print('^1[mizu_smartshop] Config warns qb-target, but resource is not started or missing!^0')
            return
        end
        for shopId, shop in pairs(Config.Shops) do
            -- Ped shops use entity target, skip box zone
            if not shop.PedModel or shop.PedModel == '' then
                pcall(function()
                    exports['qb-target']:AddBoxZone(shopId .. "_smartshop", shop.coords, 1.5, 1.5, {
                    name = shopId .. "_smartshop",
                    heading = 0,
                    debugPoly = false,
                    minZ = shop.coords.z - 1.0,
                    maxZ = shop.coords.z + 1.0,
                }, {
                    options = {
                        {
                            type = "client",
                            action = function()
                                OpenShop(shopId)
                            end,
                            icon = "fas fa-shopping-cart",
                            label = _U('target_open_shop'),
                            job = GetQBTargetJob(shop),
                        },
                    },
                    distance = 2.0
                })
            end)
            end
        end
    elseif Config.TargetSystem == 'ox-target' then
        if GetResourceState('ox_target') ~= 'started' then
            print('^1[mizu_smartshop] Config warns ox-target, but resource is not started or missing!^0')
            return
        end
        for shopId, shop in pairs(Config.Shops) do
            -- Ped shops use entity target, skip sphere zone
            if not shop.PedModel or shop.PedModel == '' then
            pcall(function()
                exports.ox_target:addSphereZone({
                    coords = shop.coords,
                    radius = 1.0,
                    debug = false,
                    options = {
                        {
                            name = shopId .. '_smartshop',
                            icon = 'fas fa-shopping-cart',
                            label = _U('target_open_shop'),
                            groups = GetOxTargetGroups(shop),
                            onSelect = function()
                                OpenShop(shopId)
                            end
                        }
                    }
                })
            end)
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

RegisterNetEvent('mizu_smartshop:client:notify', function(msg, type, title)
    if Config.Notify then
        Config.Notify(msg, type, title)
    else
        print((title or 'mizu_smartshop') .. ': ' .. msg)
    end
end)

exports('OpenShop', function(shopId)
    OpenShop(shopId)
end)

exports('CloseShop', function()
    if CurrentShop then
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'closeShop'
        })
        CurrentShop = nil
    end
end)

-- Receive dynamically created shops from server
RegisterNetEvent('mizu_smartshop:client:registerShop', function(shopId, shop)
    NormalizeShopVectors(shop)

    Config.Shops[shopId] = shop
    RefreshBlips()

    -- Ped spawn/cleanup
    DeleteShopPed(shopId)
    if shop.PedModel and shop.PedModel ~= '' then
        SpawnShopPed(shopId, shop)
        return -- ped has its own target
    end

    -- Remove old target zone before re-registering
    if Config.TargetSystem == 'qb-target' and GetResourceState('qb-target') == 'started' then
        pcall(function()
            exports['qb-target']:RemoveZone(shopId .. "_smartshop")
        end)
        pcall(function()
            exports['qb-target']:AddBoxZone(shopId .. "_smartshop", shop.coords, 1.5, 1.5, {
                name = shopId .. "_smartshop",
                heading = 0,
                debugPoly = false,
                minZ = shop.coords.z - 1.0,
                maxZ = shop.coords.z + 1.0,
            }, {
                options = {
                    {
                        type = "client",
                        action = function()
                            OpenShop(shopId)
                        end,
                        icon = "fas fa-shopping-cart",
                        label = _U('target_open_shop'),
                        job = GetQBTargetJob(shop),
                    },
                },
                distance = 2.0
            })
        end)
    elseif Config.TargetSystem == 'ox-target' and GetResourceState('ox_target') == 'started' then
        pcall(function()
            exports.ox_target:removeZone(shopId .. '_smartshop')
        end)
        pcall(function()
            exports.ox_target:addSphereZone({
                coords = shop.coords,
                radius = 1.0,
                debug = false,
                options = {
                    {
                        name = shopId .. '_smartshop',
                        icon = 'fas fa-shopping-cart',
                        label = _U('target_open_shop'),
                        groups = GetOxTargetGroups(shop),
                        onSelect = function()
                            OpenShop(shopId)
                        end
                    }
                }
            })
        end)
    end
end)

-- Print to F8 console (from server /smartshoplist)
RegisterNetEvent('mizu_smartshop:client:printF8', function(msg)
    print(msg)
end)

-- Unregister a deleted shop (remove blip, ped & config entry)
RegisterNetEvent('mizu_smartshop:client:unregisterShop', function(shopId)
    if ActiveBlips[shopId] then
        RemoveBlip(ActiveBlips[shopId])
        ActiveBlips[shopId] = nil
    end
    DeleteShopPed(shopId)
    Config.Shops[shopId] = nil
end)

-- =============================================================================
-- Admin Panel
-- =============================================================================

local AdminOpen = false

RegisterNetEvent('mizu_smartshop:client:receiveAdminData', function(shops, images, jobs, items)
    AdminOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openAdmin',
        shops = shops,
        images = images or {},
        jobs = jobs or {},
        items = items or {},
        locales = Locales[Config.Locale],
        theme = Config.Theme or 'default'
    })
end)

RegisterNUICallback('closeAdmin', function(data, cb)
    SetNuiFocus(false, false)
    AdminOpen = false
    cb('ok')
end)

RegisterNUICallback('adminSaveShop', function(data, cb)
    if data.shopId and data.shopData then
        TriggerServerEvent('mizu_smartshop:server:saveShop', data.shopId, data.shopData)
    end
    cb('ok')
end)

RegisterNUICallback('adminDeleteShop', function(data, cb)
    if data.shopId then
        TriggerServerEvent('mizu_smartshop:server:deleteShop', data.shopId)
    end
    cb('ok')
end)

RegisterNUICallback('adminResetShop', function(data, cb)
    if data.shopId then
        TriggerServerEvent('mizu_smartshop:server:resetShop', data.shopId)
    end
    cb('ok')
end)

RegisterNUICallback('adminCreateShop', function(data, cb)
    if data.shopId and data.shopId ~= '' then
        TriggerServerEvent('mizu_smartshop:server:createNewShop', data.shopId)
    end
    cb('ok')
end)

RegisterNUICallback('adminGetPlayerCoords', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    cb({ x = coords.x, y = coords.y, z = coords.z })
end)

RegisterNUICallback('adminGetPlayerHeading', function(data, cb)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    cb({ heading = heading })
end)

RegisterNUICallback('adminGotoShop', function(data, cb)
    local ped = PlayerPedId()
    SetEntityCoords(ped, data.x + 0.0, data.y + 0.0, data.z + 0.0, false, false, false, true)
    cb('ok')
end)

RegisterNetEvent('mizu_smartshop:client:openAdminPanel', function()
    TriggerServerEvent('mizu_smartshop:server:requestAdminData')
end)

-- Clean up peds when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for shopId, ped in pairs(ActivePeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    ActivePeds = {}
end)


