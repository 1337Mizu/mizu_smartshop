Config = {}

Config.Locale = 'en'           -- 'en', 'de', 'es', 'fr', 'pl', 'pt', 'tr'
Config.Theme = 'default'       -- 'default', 'green', 'yellow', 'silver', 'red'
Config.TargetSystem = 'none'   -- 'none', 'qb-target', 'ox-target'
Config.LogType = 'discord'     -- 'discord' or 'fivemanage'
Config.DynamicPriceInterval = 30 -- Minutes between price updates (global default)

Config.WebhookURL = ''
Config.FivemanageToken = ''

Config.Shops = {
    -- 24/7 Supermarkets
    ['247_davis'] = {
        name = '24/7 Supermarket',
        coords = vector3(24.47, -1346.62, 28.5),
        PedModel = 'mp_m_shopkeep_01', -- spawns a ped instead of marker
        PedHeading = 271.66, -- facing direction (0-360)
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE', -- idle animation, e.g. 'WORLD_HUMAN_STAND_IMPATIENT'
        DynamicPricing = true,          -- Enable dynamic pricing for this shop
        DynamicPriceRange = 30,          -- ±30% price fluctuation (default range)
        --DynamicPriceInterval = 30,    -- Override global interval for this shop (minutes)
        Blipname = 'Supermarket', -- remove to disable blip
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1, -- remove to disable marker (only used when TargetSystem = 'none')
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {
            { name = 'water_bottle', label = 'Juice', price = 5, image = 'berriesjuice.png', maxQty = 999, category = 'Food & Snacks' },
            { name = 'Burger', label = 'Burger', price = 4, image = 'burger.png', maxQty = 50, category = 'Food & Snacks' },
            { name = 'vanbottle', label = 'Gin', price = 500, image = 'vanbottle.png', maxQty = 5, category = 'Food & Snacks', minPrice = 555, maxPrice = 666 }, -- dynamic pricing override
            { name = 'repairkit', label = 'Repair Kit', price = 250, image = 'lockpick.png', maxQty = 10, category = 'Equipment' },
            { name = 'medikit', label = 'Medikit', price = 50, image = 'firstaid.png', maxQty = 3, category = 'Equipment' },
            { name = 'radio', label = 'Radio', price = 250, image = 'radio.png', maxQty = 10, category = 'Equipment' },
            -- category = '...' creates a tab in the shop UI for that category name.
            -- Name it however you like (e.g. 'Food & Snacks', 'Equipment', 'Weapons').
            -- Items sharing the same category name appear together under that tab.
            -- Categories are set per item here in the config or via /smartshopedit in-game.
            -- The 'All' tab in the locale is just the default "show everything" tab - no extra locale entries needed.
        }
    },
    ['247_pacificbluffs'] = {
        name = '24/7 Supermarket',
        coords = vector3(-3039.54, 584.38, 6.91),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 17.27,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'Supermarket',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['247_banhamcanyon'] = {
        name = '24/7 Supermarket',
        coords = vector3(-3242.97, 1000.01, 11.83),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 357.57,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'Supermarket',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['247_paletobay'] = {
        name = '24/7 Supermarket',
        coords = vector3(1728.07, 6415.63, 34.04),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 242.95,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'Supermarket',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['247_sandyshores'] = {
        name = '24/7 Supermarket',
        coords = vector3(1959.82, 3740.48, 31.34),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 301.57,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'Supermarket',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['247_harmony'] = {
        name = '24/7 Supermarket',
        coords = vector3(549.13, 2670.85, 41.16),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 99.39,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'Supermarket',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['247_grapeseed'] = {
        name = '24/7 Supermarket',
        coords = vector3(2677.47, 3279.76, 54.24),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 335.08,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'Supermarket',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['247_tataviam'] = {
        name = '24/7 Supermarket',
        coords = vector3(2556.66, 380.84, 107.62),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 356.67,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'Supermarket',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['247_eastvinewood'] = {
        name = '24/7 Supermarket',
        coords = vector3(372.66, 326.98, 102.57),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 253.73,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'Supermarket',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },

    -- LTD Gasoline
    ['ltd_strawberry'] = {
        name = 'LTD Gasoline',
        coords = vector3(-47.02, -1758.23, 28.42),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 45.05,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'LTD Gasoline',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ltd_vespucci'] = {
        name = 'LTD Gasoline',
        coords = vector3(-706.06, -913.97, 18.22),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 88.04,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'LTD Gasoline',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ltd_vinewoodhills'] = {
        name = 'LTD Gasoline',
        coords = vector3(-1820.02, 794.03, 137.09),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 135.45,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'LTD Gasoline',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ltd_eastvinewood'] = {
        name = 'LTD Gasoline',
        coords = vector3(1164.71, -322.94, 68.21),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 101.72,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'LTD Gasoline',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ltd_northsandyshores'] = {
        name = 'LTD Gasoline',
        coords = vector3(1697.87, 4922.96, 41.06),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 324.71,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = 'LTD Gasoline',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },

    -- Rob's Liquor
    ['robs_littleseoul'] = {
        name = "Rob's Liquor",
        coords = vector3(-1221.58, -908.15, 11.33),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 35.49,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = "Rob's Liquor",
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['robs_westvinewood'] = {
        name = "Rob's Liquor",
        coords = vector3(-1486.59, -377.68, 39.16),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 139.51,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = "Rob's Liquor",
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['robs_chumash'] = {
        name = "Rob's Liquor",
        coords = vector3(-2966.39, 391.42, 14.04),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 87.48,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = "Rob's Liquor",
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['robs_grandsenora'] = {
        name = "Rob's Liquor",
        coords = vector3(1165.17, 2710.88, 37.16),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 179.43,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = "Rob's Liquor",
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['robs_mirrorpark'] = {
        name = "Rob's Liquor",
        coords = vector3(1134.2, -982.91, 45.42),
        PedModel = 'mp_m_shopkeep_01',
        PedHeading = 277.24,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        Blipname = "Rob's Liquor",
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },

    -- Hardware Stores
    ['hardware_strawberry'] = {
        name = 'Hardware Store',
        coords = vector3(45.68, -1749.04, 28.61),
        PedModel = 'mp_m_waremech_01',
        PedHeading = 53.13,
        PedScenario = 'WORLD_HUMAN_CLIPBOARD',
        Blipname = 'Hardware Store',
        BlipSprite = 402,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['hardware_grapeseed'] = {
        name = 'Hardware Store',
        coords = vector3(2747.71, 3472.85, 54.67),
        PedModel = 'mp_m_waremech_01',
        PedHeading = 255.08,
        PedScenario = 'WORLD_HUMAN_CLIPBOARD',
        Blipname = 'Hardware Store',
        BlipSprite = 402,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['hardware_paletobay'] = {
        name = 'Hardware Store',
        coords = vector3(-421.83, 6136.13, 30.88),
        PedModel = 'mp_m_waremech_01',
        PedHeading = 228.2,
        PedScenario = 'WORLD_HUMAN_CLIPBOARD',
        Blipname = 'Hardware Store',
        BlipSprite = 402,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },

    -- Ammunation
    ['ammu_vespucci'] = {
        name = 'Ammunation',
        coords = vector3(-661.96, -933.53, 20.83),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 177.05,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_cypressflats'] = {
        name = 'Ammunation',
        coords = vector3(809.68, -2159.13, 28.62),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 1.43,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_sandyshores'] = {
        name = 'Ammunation',
        coords = vector3(1692.67, 3761.38, 33.71),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 227.65,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_paletobay'] = {
        name = 'Ammunation',
        coords = vector3(-331.23, 6085.37, 30.45),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 228.02,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_pillboxhill'] = {
        name = 'Ammunation',
        coords = vector3(253.63, -51.02, 68.94),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 72.91,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_littleseoul'] = {
        name = 'Ammunation',
        coords = vector3(23.0, -1105.67, 28.8),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 162.91,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_tataviam'] = {
        name = 'Ammunation',
        coords = vector3(2567.48, 292.59, 107.73),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 349.68,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_chiliad'] = {
        name = 'Ammunation',
        coords = vector3(-1118.59, 2700.05, 17.55),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 221.89,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_lamesa'] = {
        name = 'Ammunation',
        coords = vector3(841.92, -1035.32, 27.19),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 1.56,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_westvinewood'] = {
        name = 'Ammunation',
        coords = vector3(-1304.19, -395.12, 35.7),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 75.03,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },
    ['ammu_chumash'] = {
        name = 'Ammunation',
        coords = vector3(-3173.31, 1088.85, 19.84),
        PedModel = 's_m_y_ammucity_01',
        PedHeading = 244.18,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        Blipname = 'Ammunation',
        BlipSprite = 110,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },    -- Smoke On The Water
    ['weedshop'] = {
        name = 'Smoke On The Water',
        coords = vector3(-1168.26, -1573.2, 3.66),
        PedModel = 'a_m_y_hippy_01',
        PedHeading = 105.24,
        PedScenario = 'WORLD_HUMAN_AA_SMOKE',
        Blipname = 'Smoke On The Water',
        BlipSprite = 140,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },

    -- Sea Word
    ['seaword'] = {
        name = 'Sea Word',
        coords = vector3(-1687.03, -1072.18, 12.15),
        PedModel = 'a_m_y_beach_01',
        PedHeading = 52.93,
        PedScenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        Blipname = 'Sea Word',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },

    -- Leisure Shop
    ['leisureshop'] = { --
        name = 'Leisure Shop',
        coords = vector3(-1505.91, 1511.95, 114.29),
        PedModel = 'a_m_y_beach_01',
        PedHeading = 257.13,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE_CLUBHOUSE',
        Blipname = 'Leisure Shop',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = false,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },

    -- Ambulance Armory
    ['ambulance_armory'] = {
        name = 'Ambulance Armory',
        coords = vector3(309.93, -602.94, 42.29),
        PedModel = 's_m_m_doctor_01',
        PedHeading = 71.082,
        PedScenario = 'WORLD_HUMAN_STAND_MOBILE',
        JobRestriction = { 'ambulance' }, -- set to false or remove to make public
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 255, g = 255, b = 255, a = 100 },
        items = {}
    },
    -- Police Armory
    ['police_armory'] = {
        name = 'Police Armory',
        coords = vector3(461.8498, -981.0677, 29.6896),
        PedModel = 'mp_m_securoguard_01',
        PedHeading = 91.5892,
        PedScenario = 'WORLD_HUMAN_COP_IDLES',
        JobRestriction = { 'police' }, -- set to false or remove to make public
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 100, b = 255, a = 100 },
        items = {}
    },

    -- Mechanic Shops
    ['mechanic'] = {
        name = 'Mechanic Shop',
        coords = vector3(-342.75, -140.24, 38.01),
        PedHeading = 0.0,
        --JobRestriction = { 'mechanic' }, -- set to false or remove to make public
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 255, g = 165, b = 0, a = 100 },
        items = {}
    },
    ['mechanic2'] = {
        name = 'Mechanic Shop',
        coords = vector3(1188.57, 2640.95, 37.4),
        PedHeading = 0.0,
        --JobRestriction = { 'mechanic2' }, -- set to false or remove to make public
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 255, g = 165, b = 0, a = 100 },
        items = {}
    },
    ['mechanic3'] = {
        name = 'Mechanic Shop',
        coords = vector3(-1156.45, -2000.95, 12.18),
        PedHeading = 0.0,
        --JobRestriction = { 'mechanic3' }, -- set to false or remove to make public
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 255, g = 165, b = 0, a = 100 },
        items = {}
    },
    ['bennys'] = {
        name = "Benny's Original Motor Works",
        coords = vector3(-196.75, -1318.37, 30.09),
        PedHeading = 0.0,
        --JobRestriction = { 'bennys' }, -- set to false or remove to make public
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 255, g = 165, b = 0, a = 100 },
        items = {}
    },
    ['beeker'] = {
        name = "Beeker's Garage",
        coords = vector3(101.42, 6616.59, 31.44),
        PedHeading = 0.0,
        --JobRestriction = { 'beeker' }, -- set to false or remove to make public
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 255, g = 165, b = 0, a = 100 },
        items = {}
    },

    -- Prison Canteen
    ['prison_canteen'] = {
        name = 'Canteen',
        coords = vector3(1778.24, 2557.29, 44.62),
        PedHeading = 187.83,
        Blipname = 'Canteen',
        BlipSprite = 52,
        BlipColor = 0,
        BlipMinimapOnly = true,
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 0, g = 255, b = 255, a = 100 },
        items = {}
    },

    -- Black Market
    ['blackmarket'] = {
        name = 'Black Market',
        coords = vector3(-594.7032, -1616.3647, 32.0105),
        PedModel = 'a_m_y_smartcaspat_01',
        PedHeading = 170.6846,
        PedScenario = 'WORLD_HUMAN_AA_SMOKE',
        MarkerType = 1,
        MarkerSize = vector3(1.0, 1.0, 0.5),
        MarkerColor = { r = 255, g = 0, b = 0, a = 100 },
        items = {}
    },
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
