Config = {}

Config.Locale = 'en'           -- 'en', 'de', 'es', 'fr', 'pl', 'pt', 'tr'
Config.Theme = 'default'       -- 'default', 'green', 'yellow', 'silver', 'red'
Config.TargetSystem = 'none'   -- 'none', 'qb-target', 'ox-target'
Config.LogType = 'discord'     -- 'discord' or 'fivemanage'

Config.WebhookURL = ''
Config.FivemanageToken = ''

Config.Shops = {
    ['247_supermarket'] = {
        name = '24/7 Supermarket',
        coords = vector3(-263.18, -2415.76, 121.37),
        Blipname = 'Supermarket', -- remove to disable blip
        BlipSprite = 52,
        BlipColor = 2,
        BlipMinimapOnly = true,
        MarkerType = 1, -- remove to disable marker (only used when TargetSystem = 'none')
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        PedModel = 'mp_m_shopkeep_01', -- spawns a ped instead of marker
        PedHeading = 146.37,               -- facing direction (0-360)
        PedScenario = '',               -- idle animation, e.g. 'WORLD_HUMAN_STAND_IMPATIENT'
        items = {
            { name = 'water_bottle', label = 'Juice', price = 5, image = 'berriesjuice.png', maxQty = 999, category = 'Food & Snacks' },
            { name = 'Burger', label = 'Burger', price = 4, image = 'burger.png', maxQty = 50, category = 'Food & Snacks' },
            { name = 'vanbottle', label = 'Gin', price = 500, image = 'vanbottle.png', maxQty = 5, category = 'Food & Snacks' },
            { name = 'repairkit', label = 'Repair Kit', price = 250, image = 'lockpick.png', maxQty = 10, category = 'Equipment' },
            { name = 'medikit', label = 'Medikit', price = 50, image = 'firstaid.png', maxQty = 3, category = 'Equipment' },
            { name = 'radio', label = 'Radio', price = 250, image = 'radio.png', maxQty = 10, category = 'Equipment' },
        }
    },
    ['police_armory'] = {
        name = 'LSPD Armory',
        coords = vector3(452.19, -980.0, 30.68),
        JobRestriction = { 'police' }, -- set to false or remove to make public
        Blipname = 'Police Armory',
        BlipSprite = 175,
        BlipColor = 38,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 100, b = 255, a = 100 },
        items = {
            { name = 'weapon_nightstick', label = 'Nightstick', price = 0, image = 'nightstick.png', maxQty = 1, grade = 0 },
            { name = 'weapon_pistol', label = 'Combat Pistol', price = 0, image = 'pistol.png', maxQty = 1, grade = 0 },
            { name = 'weapon_carbinerifle', label = 'Carbine Rifle', price = 0, image = 'rifle.png', maxQty = 1, grade = 2 },
            { name = 'ammo-9', label = '9mm Ammo', price = 0, image = 'ammo.png', maxQty = 10, grade = 0 },
            { name = 'ammo-rifle', label = 'Rifle Ammo', price = 0, image = 'ammo.png', maxQty = 5, grade = 2 },
        }
    }
}

-- Replace this with your notification system (okokNotify, mythic_notify, mizu_interface, etc.)
Config.Notify = function(msg, type, title)
    local notifyTitle = title or 'SmartShop'
    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Notify(msg, type)
    elseif GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({ title = notifyTitle, description = msg, type = type })
    elseif GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.ShowNotification(msg)
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(0, 1)
    end
end

function _U(key, ...)
    if Locales and Locales[Config.Locale] and Locales[Config.Locale][key] then
        return string.format(Locales[Config.Locale][key], ...)
    end
    return "Locale error: " .. key
end
