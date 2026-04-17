-- Framework auto-detection
local Framework = 'none'
local ESX, QBCore = nil, nil

if GetResourceState('es_extended') == 'started' then
    Framework = 'esx'
    ESX = exports['es_extended']:getSharedObject()
    print('^2[mizu_smartshop] ESX Framework detected.^0')
elseif GetResourceState('qbx_core') == 'started' then
    Framework = 'qbox'
    print('^2[mizu_smartshop] QBox Framework detected.^0')
elseif GetResourceState('qb-core') == 'started' then
    Framework = 'qbcore'
    QBCore = exports['qb-core']:GetCoreObject()
    print('^2[mizu_smartshop] QB-Core Framework detected.^0')
else
    print('^3[mizu_smartshop] No accepted framework detected, running standalone if applicable.^0')
end

local Log = {}

function Log.Send(title, message, color, plainMsg)
    if Config.LogType == 'discord' and Config.WebhookURL ~= '' then
        local embed = {
            {
                ["color"] = color or 16711680,
                ["title"] = title,
                ["description"] = message,
                ["footer"] = {
                    ["text"] = "Mizu SmartShop",
                },
            }
        }
        PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, 'POST', json.encode({username = "SmartShop Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
    elseif Config.LogType == 'fivemanage' and Config.FivemanageToken ~= '' then
        local cleanMsg = plainMsg
        if not cleanMsg then
            cleanMsg = string.gsub(message, "%*%*", "")
            cleanMsg = string.gsub(cleanMsg, "\n\n", " | ")
            cleanMsg = string.gsub(cleanMsg, "\n", " | ")
        end
        local payload = {
            {
                level = color == 16711680 and "error" or "info",
                message = title .. " | " .. cleanMsg,
                resource = "mizu_smartshop"
            }
        }
        PerformHttpRequest('https://api.fivemanage.com/api/v3/logs', function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json', ['Authorization'] = Config.FivemanageToken })
    end
end

-- Dynamic Pricing Engine
local DynamicPrices = {} -- DynamicPrices[shopId][itemName] = currentPrice
local DynamicLastRefresh = {} -- DynamicLastRefresh[shopId] = os.time() of last refresh

local function CalculateDynamicPrice(basePrice, shop, item)
    if item.minPrice and item.maxPrice then
        return math.random(item.minPrice, item.maxPrice)
    end
    local range = shop.DynamicPriceRange or 30
    local minP = math.floor(basePrice * (1 - range / 100))
    local maxP = math.ceil(basePrice * (1 + range / 100))
    if minP < 0 then minP = 0 end
    if maxP < minP then maxP = minP end
    return math.random(minP, maxP)
end

local function RefreshDynamicPrices(shopId)
    local shop = Config.Shops[shopId]
    if not shop or not shop.DynamicPricing then
        DynamicPrices[shopId] = nil
        DynamicLastRefresh[shopId] = nil
        return
    end
    DynamicPrices[shopId] = {}
    for _, item in ipairs(shop.items or {}) do
        DynamicPrices[shopId][item.name] = CalculateDynamicPrice(item.price, shop, item)
    end
    DynamicLastRefresh[shopId] = os.time()
end

local function RefreshAllDynamicPrices()
    for shopId, shop in pairs(Config.Shops) do
        if shop.DynamicPricing then
            RefreshDynamicPrices(shopId)
        end
    end
end

local function GetDynamicPrice(shopId, itemName, basePrice)
    if DynamicPrices[shopId] and DynamicPrices[shopId][itemName] then
        return DynamicPrices[shopId][itemName]
    end
    return basePrice
end

-- Seed random number generator
math.randomseed(os.time())

-- Price update thread — checks each shop's individual interval
CreateThread(function()
    while true do
        Wait(60 * 1000) -- Check every minute
        local now = os.time()
        local globalInterval = (Config.DynamicPriceInterval or 30) * 60
        for shopId, shop in pairs(Config.Shops) do
            if shop.DynamicPricing then
                local shopInterval = (shop.DynamicPriceInterval or globalInterval / 60) * 60
                if shopInterval <= 0 then shopInterval = globalInterval end
                local lastRefresh = DynamicLastRefresh[shopId] or 0
                if (now - lastRefresh) >= shopInterval then
                    RefreshDynamicPrices(shopId)
                end
            end
        end
    end
end)

-- Checkout handler
RegisterNetEvent('mizu_smartshop:server:checkoutCart', function(shopId, cart, paymentType)
    local src = source

    local shop = Config.Shops[shopId]
    if not shop then return end

    local PlayerJobName = 'unemployed'
    local PlayerJobGrade = 0

    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            PlayerJobName = xPlayer.job.name
            PlayerJobGrade = xPlayer.job.grade
        end
    elseif Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            PlayerJobName = Player.PlayerData.job.name
            PlayerJobGrade = Player.PlayerData.job.grade.level
        end
    elseif Framework == 'qbox' then
        local Player = exports.qbx_core:GetPlayer(src)
        if Player then
            PlayerJobName = Player.PlayerData.job.name
            PlayerJobGrade = Player.PlayerData.job.grade.level
        end
    end

    if shop.JobRestriction then
        local hasJob = false
        if type(shop.JobRestriction) == 'table' then
            for _, j in ipairs(shop.JobRestriction) do
                if PlayerJobName == j then hasJob = true; break end
            end
        elseif shop.JobRestriction == PlayerJobName then
            hasJob = true
        end

        if not hasJob then
            Log.Send("Access Denied: " .. shop.name, "Player " .. GetPlayerName(src) .. " tried to checkout at a restricted shop without the correct job.", 16711680)
            return
        end
    end

    local totalCost = 0
    local validatedItems = {}

    for _, cartItem in ipairs(cart) do
        local itemData = nil
        for _, shopItem in ipairs(shop.items) do
            if shopItem.name == cartItem.name then
                itemData = shopItem
                break
            end
        end

        if itemData and cartItem.qty and cartItem.qty > 0 then
            local reqGrade = itemData.grade or 0
            if PlayerJobGrade >= reqGrade then
                local pQty = cartItem.qty
                local maxQ = itemData.maxQty or 999
                if pQty > maxQ then pQty = maxQ end
                
                local actualPrice = shop.DynamicPricing and GetDynamicPrice(shopId, itemData.name, itemData.price) or itemData.price
                totalCost = totalCost + (actualPrice * pQty)
                table.insert(validatedItems, { name = itemData.name, label = itemData.label, qty = pQty, price = actualPrice })
            else
                Log.Send("Grade Restricted", "Player " .. GetPlayerName(src) .. " tried to buy ["..itemData.name.."] but lacks grade "..tostring(reqGrade)..".", 16711680)
            end
        end
    end

    if totalCost <= 0 or #validatedItems == 0 then return end

    local success = false

    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        local account = paymentType == 'cash' and 'money' or 'bank'
        
        if xPlayer.getAccount(account).money >= totalCost then
            local canCarryAll = true
            for _, item in ipairs(validatedItems) do
                if not xPlayer.canCarryItem(item.name, item.qty) then
                    canCarryAll = false
                    break
                end
            end

            if canCarryAll then
                xPlayer.removeAccountMoney(account, totalCost)
                for _, item in ipairs(validatedItems) do
                    xPlayer.addInventoryItem(item.name, item.qty)
                end
                success = true
            else
                TriggerClientEvent('mizu_smartshop:client:notify', src, _U('inventory_full'), 'error', shop.name)
            end
        else
            TriggerClientEvent('mizu_smartshop:client:notify', src, _U('not_enough_money'), 'error', shop.name)
        end
    elseif Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.Functions.GetMoney(paymentType) >= totalCost then
            local successfulItems = {}
            local failedItems = false
            local refundedCost = 0

            for _, item in ipairs(validatedItems) do
                if Player.Functions.AddItem(item.name, item.qty) then
                    table.insert(successfulItems, item)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add", item.qty)
                else
                    failedItems = true
                    refundedCost = refundedCost + (item.price * item.qty)
                    local adminWarn = "Failed to give item '" .. tostring(item.name) .. "' to " .. GetPlayerName(src) .. " (Missing in DB or Inventory Full). Refunded automatically."
                    print("^1[mizu_smartshop ERROR] " .. adminWarn .. "^0")
                    Log.Send("Shop Warning: " .. shop.name, "**Warning:** " .. adminWarn, 16711680, "Warning: " .. adminWarn)
                end
            end

            local actualCost = totalCost - refundedCost

            if #successfulItems > 0 then
                Player.Functions.RemoveMoney(paymentType, actualCost, "smartshop-checkout")
                success = true
                validatedItems = successfulItems -- update the cart to only reflect what they actually received
                totalCost = actualCost
            end

            if failedItems then
                TriggerClientEvent('mizu_smartshop:client:notify', src, _U('inventory_full'), 'error', shop.name)
            end
        else
            TriggerClientEvent('mizu_smartshop:client:notify', src, _U('not_enough_money'), 'error', shop.name)
        end
    elseif Framework == 'qbox' then
        local Player = exports.qbx_core:GetPlayer(src)
        if Player.Functions.GetMoney(paymentType) >= totalCost then
            local canCarryAll = true
            for _, item in ipairs(validatedItems) do
                if not exports.ox_inventory:CanCarryItem(src, item.name, item.qty) then
                    canCarryAll = false
                    local adminWarn = "Failed to give item '" .. tostring(item.name) .. "' to " .. GetPlayerName(src) .. " (Missing in DB or Inventory Full)."
                    print("^1[mizu_smartshop ERROR] " .. adminWarn .. "^0")
                    Log.Send("Shop Warning: " .. shop.name, "**Warning:** " .. adminWarn, 16711680, "Warning: " .. adminWarn)
                    break
                end
            end

            if canCarryAll then
                Player.Functions.RemoveMoney(paymentType, totalCost, "smartshop-checkout")
                for _, item in ipairs(validatedItems) do
                    exports.ox_inventory:AddItem(src, item.name, item.qty)
                end
                success = true
            else
                TriggerClientEvent('mizu_smartshop:client:notify', src, _U('inventory_full'), 'error', shop.name)
            end
        else
            TriggerClientEvent('mizu_smartshop:client:notify', src, _U('not_enough_money'), 'error', shop.name)
        end
    end

    if success then
        local pTypeLabel = paymentType == 'cash' and 'Cash' or 'Card'
        
        local totalItems = 0
        local lastItemLabel = "Item"
        for _, it in ipairs(validatedItems) do 
            totalItems = totalItems + it.qty 
            lastItemLabel = it.label
        end

        if totalItems == 1 then
            TriggerClientEvent('mizu_smartshop:client:notify', src, _U('success_purchase', lastItemLabel, totalCost), 'success', shop.name)
        else
            TriggerClientEvent('mizu_smartshop:client:notify', src, _U('success_purchase_multiple', totalCost), 'success', shop.name)
        end
        
        local itemList = ""
        for _, it in ipairs(validatedItems) do itemList = itemList .. it.qty .. "x " .. it.label .. ", " end
        if string.len(itemList) > 2 then itemList = string.sub(itemList, 1, -3) end

        local steamId = "N/A"
        local discordId = "N/A"
        local license = "N/A"
        local fivemId = "N/A"
        for _, id in ipairs(GetPlayerIdentifiers(src)) do
            if string.match(id, "^steam:") then
                steamId = id
            elseif string.match(id, "^discord:") then
                discordId = string.sub(id, 9)
            elseif string.match(id, "^license:") then
                if license == "N/A" then license = id end
            elseif string.match(id, "^fivem:") then
                fivemId = id
            end
        end

        local coordsTxt = string.format("%.2f, %.2f, %.2f", shop.coords.x, shop.coords.y, shop.coords.z)
        local logMsg = string.format("**Player:** %s\n**Items:** %s\n**Payment:** %s ($%s)\n\n**Location:** %s\n**License:** %s\n**FiveM:** %s\n**Steam ID:** %s\n**Discord:** %s", 
            GetPlayerName(src), itemList, pTypeLabel, totalCost, coordsTxt, license, fivemId, steamId, discordId)
            
        local plainMsg = string.format("Player: %s | Items: %s| Payment: %s ($%s) | Loc: %s | Lic: %s | FiveM: %s | Steam: %s | DC: %s", 
            GetPlayerName(src), itemList, pTypeLabel, totalCost, coordsTxt, license, fivemId, steamId, discordId)
            
        Log.Send("Shop Checkout: " .. shop.name, logMsg, 65280, plainMsg)
    end
end)

-- Dynamic Shop Management (saved shops persist across restarts)

local ConfigShopIds = {} -- Track which shops come from config.lua
for id, _ in pairs(Config.Shops) do
    ConfigShopIds[id] = true
end

local function DeserializeVectors(shop)
    if shop.coords and type(shop.coords) == 'table' and not shop.coords.x then
        shop.coords = vector3(shop.coords[1], shop.coords[2], shop.coords[3])
    end
    shop.MarkerPos = nil -- deprecated, use coords
    if shop.MarkerSize and type(shop.MarkerSize) == 'table' and not shop.MarkerSize.x then
        shop.MarkerSize = vector3(shop.MarkerSize[1], shop.MarkerSize[2], shop.MarkerSize[3])
    end
    return shop
end

local function SerializeShop(shop)
    local s = {}
    for k, v in pairs(shop) do
        if type(v) == 'table' then
            s[k] = {}
            for ik, iv in pairs(v) do
                if type(iv) == 'table' then
                    s[k][ik] = {}
                    for iik, iiv in pairs(iv) do
                        s[k][ik][iik] = iiv
                    end
                else
                    s[k][ik] = iv
                end
            end
        else
            s[k] = v
        end
    end
    if s.coords then s.coords = { s.coords.x, s.coords.y, s.coords.z } end

    if s.MarkerSize then s.MarkerSize = { s.MarkerSize.x, s.MarkerSize.y, s.MarkerSize.z } end
    return s
end

local function DeepCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        if type(v) == 'table' then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function LoadSavedShops()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'saved_shops.json')
    if not raw or raw == '' then return end

    local saved = json.decode(raw)
    if not saved then return end

    local overrideCount, dynamicCount = 0, 0
    for id, shop in pairs(saved) do
        shop = DeserializeVectors(shop)
        if shop._dynamic then
            Config.Shops[id] = shop
            dynamicCount = dynamicCount + 1
        elseif shop._override and ConfigShopIds[id] then
            for k, v in pairs(shop) do
                if k ~= '_override' then
                    Config.Shops[id][k] = v
                end
            end
            Config.Shops[id]._override = true
            overrideCount = overrideCount + 1
        end
    end
    print('^2[mizu_smartshop] Loaded ' .. dynamicCount .. ' dynamic shop(s) and ' .. overrideCount .. ' override(s) from saved_shops.json^0')
end

local function SaveAllShops()
    local data = {}
    for id, shop in pairs(Config.Shops) do
        if shop._dynamic or shop._override then
            data[id] = SerializeShop(shop)
        end
    end
    SaveResourceFile(GetCurrentResourceName(), 'saved_shops.json', json.encode(data), -1)
end

LoadSavedShops()
RefreshAllDynamicPrices() -- Refresh after saved shops are loaded

-- Image Scanner — collects available images at startup

local AvailableImages = {}
local ImagePathMap = {}

local function ScanImages()
    local images = {}
    local pathMap = {}
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local resName = GetCurrentResourceName()
    local scanPaths = {
        { path = resourcePath .. '/html/images', nui = 'nui://' .. resName .. '/html/images/' },
    }

    -- Also scan common inventory image folders
    local inventoryPaths = {
        { res = 'qb-inventory', sub = '/html/images', nuiSub = '/html/images/' },
        { res = 'ox_inventory', sub = '/web/images', nuiSub = '/web/images/' },
        { res = 'qs-inventory', sub = '/html/images', nuiSub = '/html/images/' },
        { res = 'ps-inventory', sub = '/html/images', nuiSub = '/html/images/' },
        { res = 'lj-inventory', sub = '/html/images', nuiSub = '/html/images/' },
        { res = 'esx_inventory', sub = '/html/images', nuiSub = '/html/images/' },
    }

    for _, inv in ipairs(inventoryPaths) do
        if GetResourceState(inv.res) ~= 'missing' then
            local invPath = GetResourcePath(inv.res)
            if invPath then
                table.insert(scanPaths, { path = invPath .. inv.sub, nui = 'nui://' .. inv.res .. inv.nuiSub })
            end
        end
    end

    local isWindows = resourcePath:find('\\') ~= nil
    local seen = {}
    for _, sp in ipairs(scanPaths) do
        local cmd
        if isWindows then
            cmd = 'dir "' .. sp.path .. '" /b /a-d 2>nul'
        else
            cmd = 'ls -1 "' .. sp.path .. '" 2>/dev/null'
        end
        local handle = io.popen(cmd)
        if handle then
            for file in handle:lines() do
                file = file:gsub('%s+$', '')
                local lower = file:lower()
                if (lower:match('%.png$') or lower:match('%.jpg$') or lower:match('%.jpeg$') or lower:match('%.webp$')) and not seen[lower] then
                    seen[lower] = true
                    table.insert(images, file)
                    local nuiUrl = sp.nui .. file
                    pathMap[file] = nuiUrl
                    pathMap[lower] = nuiUrl
                end
            end
            handle:close()
        end
    end

    table.sort(images, function(a, b) return a:lower() < b:lower() end)
    return images, pathMap
end

AvailableImages, ImagePathMap = ScanImages()
print('^2[mizu_smartshop] Scanned ' .. #AvailableImages .. ' available images.^0')

-- Admin Panel Events

local function GetAllJobs()
    local jobs = {}
    if Framework == 'qbcore' then
        local shared = QBCore.Shared.Jobs
        if shared then
            for name, data in pairs(shared) do
                table.insert(jobs, { name = name, label = data.label or name })
            end
        end
    elseif Framework == 'qbox' then
        local shared = exports.qbx_core:GetJobs()
        if shared then
            for name, data in pairs(shared) do
                table.insert(jobs, { name = name, label = data.label or name })
            end
        end
    elseif Framework == 'esx' then
        local result = MySQL and MySQL.query and MySQL.query.await('SELECT name, label FROM jobs') or {}
        for _, row in ipairs(result) do
            table.insert(jobs, { name = row.name, label = row.label or row.name })
        end
    end
    table.sort(jobs, function(a, b) return a.label:lower() < b.label:lower() end)
    return jobs
end

local function GetAllItems()
    local items = {}
    local seen = {}

    -- 1) Framework items
    if Framework == 'qbcore' then
        local shared = QBCore.Shared.Items
        if shared then
            for name, data in pairs(shared) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(items, { name = name, label = data.label or name })
                end
            end
        end
    elseif Framework == 'qbox' then
        if GetResourceState('ox_inventory') == 'started' then
            local ok, shared = pcall(exports.ox_inventory.Items, exports.ox_inventory)
            if ok and shared then
                for name, data in pairs(shared) do
                    if not seen[name] then
                        seen[name] = true
                        table.insert(items, { name = name, label = data.label or name })
                    end
                end
            end
        end
    elseif Framework == 'esx' then
        local result = MySQL and MySQL.query and MySQL.query.await('SELECT name, label FROM items') or {}
        for _, row in ipairs(result) do
            if not seen[row.name] then
                seen[row.name] = true
                table.insert(items, { name = row.name, label = row.label or row.name })
            end
        end
    end

    -- 2) Inventory resource items (additional/authoritative source)
    if GetResourceState('ox_inventory') == 'started' then
        local ok, invItems = pcall(exports.ox_inventory.Items, exports.ox_inventory)
        if ok and invItems then
            for name, data in pairs(invItems) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(items, { name = name, label = data.label or name })
                end
            end
        end
    elseif GetResourceState('qb-inventory') == 'started' then
        if QBCore and QBCore.Shared and QBCore.Shared.Items then
            for name, data in pairs(QBCore.Shared.Items) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(items, { name = name, label = data.label or name })
                end
            end
        end
    elseif GetResourceState('qs-inventory') == 'started' then
        local ok, invItems = pcall(exports['qs-inventory'].GetItemList, exports['qs-inventory'])
        if ok and invItems then
            for name, data in pairs(invItems) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(items, { name = name, label = data.label or name })
                end
            end
        end
    elseif GetResourceState('ps-inventory') == 'started' then
        local ok, invItems = pcall(exports['ps-inventory'].Items, exports['ps-inventory'])
        if ok and invItems then
            for name, data in pairs(invItems) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(items, { name = name, label = data.label or name })
                end
            end
        end
    elseif GetResourceState('lj-inventory') == 'started' then
        local ok, invItems = pcall(exports['lj-inventory'].Items, exports['lj-inventory'])
        if ok and invItems then
            for name, data in pairs(invItems) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(items, { name = name, label = data.label or name })
                end
            end
        end
    end

    table.sort(items, function(a, b) return a.label:lower() < b.label:lower() end)
    return items
end

local function IsAdmin(src)
    return IsPlayerAceAllowed(src, 'command.smartshopedit')
end

local function SanitizeShopId(id)
    if type(id) ~= 'string' then return nil end
    id = id:gsub('[^%w_%-]', '')
    if #id == 0 or #id > 64 then return nil end
    return id
end

RegisterNetEvent('mizu_smartshop:server:requestSavedShops', function()
    local src = source
    local shops = {}
    for id, shop in pairs(Config.Shops) do
        if shop._dynamic or shop._override then
            shops[id] = SerializeShop(shop)
        end
    end
    TriggerClientEvent('mizu_smartshop:client:receiveSavedShops', src, shops)
end)

RegisterNetEvent('mizu_smartshop:server:requestDynamicPrices', function(shopId)
    local src = source
    local shop = Config.Shops[shopId]
    if not shop or not shop.DynamicPricing then
        TriggerClientEvent('mizu_smartshop:client:receiveDynamicPrices', src, shopId, nil)
        return
    end
    if not DynamicPrices[shopId] then
        RefreshDynamicPrices(shopId)
    end
    TriggerClientEvent('mizu_smartshop:client:receiveDynamicPrices', src, shopId, DynamicPrices[shopId])
end)

RegisterNetEvent('mizu_smartshop:server:requestAdminData', function()
    local src = source
    if not IsAdmin(src) then return end
    -- Serialize all shops for NUI
    local shops = {}
    for id, shop in pairs(Config.Shops) do
        local s = SerializeShop(shop)
        s._isConfig = ConfigShopIds[id] or false
        shops[id] = s
    end
    TriggerClientEvent('mizu_smartshop:client:receiveAdminData', src, shops, AvailableImages, GetAllJobs(), GetAllItems(), ImagePathMap)
end)

RegisterNetEvent('mizu_smartshop:server:saveShop', function(shopId, shopData)
    local src = source
    if not IsAdmin(src) then return end
    shopId = SanitizeShopId(shopId)
    if not shopId or not shopData then return end

    shopData = DeserializeVectors(shopData)

    if ConfigShopIds[shopId] then
        shopData._override = true
        shopData._dynamic = nil
    else
        shopData._dynamic = true
        shopData._override = nil
    end

    Config.Shops[shopId] = shopData
    SaveAllShops()
    RefreshDynamicPrices(shopId)

    TriggerClientEvent('mizu_smartshop:client:registerShop', -1, shopId, SerializeShop(shopData))
    TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop "' .. shopId .. '" saved.', 'success')
    print('^2[mizu_smartshop] Shop "' .. shopId .. '" saved by ' .. GetPlayerName(src) .. '^0')
end)

RegisterNetEvent('mizu_smartshop:server:deleteShop', function(shopId)
    local src = source
    if not IsAdmin(src) then return end
    shopId = SanitizeShopId(shopId)
    if not shopId then return end

    if ConfigShopIds[shopId] then
        TriggerClientEvent('mizu_smartshop:client:notify', src, 'Cannot delete config shop. Use "Reset" instead.', 'error')
        return
    end

    Config.Shops[shopId] = nil
    SaveAllShops()

    TriggerClientEvent('mizu_smartshop:client:unregisterShop', -1, shopId)
    TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop "' .. shopId .. '" deleted.', 'success')
    print('^3[mizu_smartshop] Shop "' .. shopId .. '" deleted by ' .. GetPlayerName(src) .. '^0')
end)

RegisterNetEvent('mizu_smartshop:server:resetShop', function(shopId)
    local src = source
    if not IsAdmin(src) then return end
    shopId = SanitizeShopId(shopId)
    if not shopId or not ConfigShopIds[shopId] then
        TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop "' .. tostring(shopId) .. '" is not a config shop.', 'error')
        return
    end

    Config.Shops[shopId]._override = nil
    SaveAllShops()

    TriggerClientEvent('mizu_smartshop:client:notify', src, 'Override removed for "' .. shopId .. '". Original config will restore on next restart.', 'success')
    print('^3[mizu_smartshop] Override removed for "' .. shopId .. '" by ' .. GetPlayerName(src) .. '^0')
end)

RegisterNetEvent('mizu_smartshop:server:createNewShop', function(shopId)
    local src = source
    if not IsAdmin(src) then return end
    shopId = SanitizeShopId(shopId)
    if not shopId then
        TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop ID cannot be empty.', 'error')
        return
    end

    if Config.Shops[shopId] then
        TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop ID "' .. shopId .. '" already exists.', 'error')
        return
    end

    local ped = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(ped)

    local newShop = {
        name = 'New Shop',
        coords = vector3(playerCoords.x, playerCoords.y, playerCoords.z - 1.0),
        _dynamic = true,
        items = {},
    }

    Config.Shops[shopId] = newShop
    SaveAllShops()

    TriggerClientEvent('mizu_smartshop:client:registerShop', -1, shopId, SerializeShop(newShop))
    TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop "' .. shopId .. '" created.', 'success')
    print('^2[mizu_smartshop] New empty shop "' .. shopId .. '" created by ' .. GetPlayerName(src) .. '^0')
end)

-- Version Checker
local function CheckVersion()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    if not currentVersion then
        print('^3[mizu_smartshop] ⚠ Could not read current version from fxmanifest.lua^0')
        return
    end

    PerformHttpRequest('https://api.github.com/repos/1337Mizu/mizu_smartshop/releases/latest', function(statusCode, response, headers)
        if statusCode ~= 200 or not response then
            print('^3[mizu_smartshop] ⚠ Could not check for updates (HTTP ' .. tostring(statusCode) .. ')^0')
            return
        end

        local data = json.decode(response)
        if not data or not data.tag_name then
            print('^3[mizu_smartshop] ⚠ Could not parse update response^0')
            return
        end

        local latestVersion = data.tag_name:gsub('^v', '')

        if latestVersion == currentVersion then
            print('^2[mizu_smartshop] ✓ Up to date (v' .. currentVersion .. ')^0')
        else
            print('^1[mizu_smartshop] ✗ Update available! Current: v' .. currentVersion .. ' → Latest: v' .. latestVersion .. '^0')
            print('^1[mizu_smartshop] Download: https://github.com/1337Mizu/mizu_smartshop/releases/latest^0')
        end
    end, 'GET', '', { ['Content-Type'] = 'application/json', ['User-Agent'] = 'mizu_smartshop' })
end

CreateThread(function()
    Wait(5000)
    CheckVersion()
end)

-- /smartshopcreate <sourceShopId> [newShopId]
-- Copies an existing shop to the player's current position
RegisterCommand('smartshopcreate', function(source, args)
    local src = source
    if src == 0 then
        print('^1[mizu_smartshop] This command must be used in-game.^0')
        return
    end

    local sourceId = args[1]
    if not sourceId then
        TriggerClientEvent('mizu_smartshop:client:notify', src, 'Usage: /smartshopcreate <shopId> [newId]', 'error')
        return
    end

    local sourceShop = Config.Shops[sourceId]
    if not sourceShop then
        TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop "' .. sourceId .. '" not found.', 'error')
        return
    end

    local newId = args[2] or (sourceId .. '_' .. os.time())

    if Config.Shops[newId] then
        TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop ID "' .. newId .. '" already exists.', 'error')
        return
    end

    local ped = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(ped)

    local newShop = DeepCopy(sourceShop)

    newShop.coords = vector3(playerCoords.x, playerCoords.y, playerCoords.z - 1.0)
    newShop.MarkerPos = nil
    newShop._dynamic = true
    newShop._override = nil

    Config.Shops[newId] = newShop
    SaveAllShops()

    -- Tell all clients to register the new shop (blips, targets, etc.)
    TriggerClientEvent('mizu_smartshop:client:registerShop', -1, newId, SerializeShop(newShop))
    TriggerClientEvent('mizu_smartshop:client:notify', src, 'Shop "' .. newId .. '" created at your position!', 'success')
    print('^2[mizu_smartshop] Shop "' .. newId .. '" created by ' .. GetPlayerName(src) .. ' at ' .. tostring(newShop.coords) .. '^0')
end, true) -- restricted = true (requires ace permission: command.smartshopcreate)

-- /smartshopedit — opens admin panel (ACE restricted)
RegisterCommand('smartshopedit', function(source, args)
    TriggerClientEvent('mizu_smartshop:client:openAdminPanel', source)
end, true) -- restricted = true (requires ace permission: command.smartshopedit)

-- /smartshoplist — prints all shops + positions to F8 console
RegisterCommand('smartshoplist', function(source, args)
    local src = source
    local lines = { '^3========== [mizu_smartshop] All Shops ==========^0' }

    for shopId, shop in pairs(Config.Shops) do
        local c = shop.coords
        local coordStr = string.format('%.2f, %.2f, %.2f', c.x, c.y, c.z)
        local dynamic = shop._dynamic and ' ^5[dynamic]^0' or ''
        local job = ''
        if shop.JobRestriction then
            if type(shop.JobRestriction) == 'table' then
                job = ' ^1[job: ' .. table.concat(shop.JobRestriction, ', ') .. ']^0'
            else
                job = ' ^1[job: ' .. shop.JobRestriction .. ']^0'
            end
        end
        table.insert(lines, string.format('^2%s^0 (%s) — %s%s%s', shop.name or shopId, shopId, coordStr, job, dynamic))
    end

    table.insert(lines, '^3================================================^0')

    -- If run from server console (src=0) or from in-game
    for _, line in ipairs(lines) do
        if src == 0 then
            print(line)
        else
            -- F8 console on client side
            TriggerClientEvent('mizu_smartshop:client:printF8', src, line)
        end
    end
end, false) -- not restricted, everyone can list
