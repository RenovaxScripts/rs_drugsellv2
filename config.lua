Config             = {}

-- ═══════════════════════════════════════════════════════════════
--  CORE SETTINGS
-- ═══════════════════════════════════════════════════════════════
Config.Framework   = 'esx'       -- 'esx' | 'qbcore'
Config.Locale      = 'cs'        -- 'cs' | 'en'
Config.Interaction = 'target'    -- 'target' | 'textui' | 'drawtext'
Config.Target      = 'ox_target' -- 'ox_target' | 'qb-target'  (only if your interaction = 'target')
Config.Inventory   = 'auto'      -- 'ox' | 'qb' | 'codem' | 'auto'
Config.Debug       = false       -- show debug messages in console

-- ═══════════════════════════════════════════════════════════════
--  NEARBY PED MECHANIC
--  Player can sell drugs to ANY ped in the area
--  (except blacklisted models / types)
-- ═══════════════════════════════════════════════════════════════
Config.NearbyPed   = {
    scanRadius      = 5.0, --  meters – how far it scans nearby peds
    interactKey     = 38,  -- E key (only for drawtext/textui)
    targetIcon      = 'fas fa-hand-holding',

    -- % chance, that NPC will IMMEDIATELY refuse (even before opening UI)
    -- 0 = never refuses, 100 = always refuses
    refusalChance   = 25,

    -- Types of peds that CANNOT be used
    -- PedType: 6 = ARMY, 27 = ANIMAL...
    blacklistTypes  = { 6 },

    -- Models that CANNOT be used (police, medics, army...)
    blacklistModels = {
        -- police
        `s_m_y_cop_01`, `s_f_y_cop_01`, `s_m_y_hwaycop_01`,
        `s_m_y_sheriff_01`, `s_f_y_sheriff_01`,
        `s_m_y_swat_01`, `u_m_y_fbisuit_01`,
        -- EMS / medics
        `s_m_m_paramedic_01`, `s_f_m_paramedic_01`,
        `s_m_m_doctor_01`, `s_f_m_nurse_01`, `s_f_y_nurse_01`,
        -- Army
        `s_m_y_marine_01`, `s_m_y_marine_02`, `s_m_y_marine_03`,
        `s_m_y_ranger_01`, `s_f_y_ranger_01`,
        -- Security
        `s_m_y_security_01`, `s_f_y_security_01`,
        -- Misc
        `u_m_m_filmdirector`,
    },

    -- Random buyers – label + quotes + refusal quotes assigned randomly to ped
    buyers          = {
        {
            label         = 'Taxi Driver',
            quotes        = {
                'I heard you got something good. What is it?',
                'Man, I\'m interested... what do you have?',
                'Keep it quiet, what do you have?',
            },
            refusalQuotes = {
                'Not now, man. I\'m busy.',
                'I don\'t want to hear it. Get lost.',
                'You got the wrong guy.',
            },
        },
        {
            label         = 'Mechanic',
            quotes        = {
                'Yo, I need something to take the edge off.',
                'I heard you sell. Come here...',
                "Don't make it obvious, show me what you've got.",
            },
            refusalQuotes = {
                'Not interested. Keep walking.',
                'Bad day, bad person. Get lost.',
                'I don\'t know what you\'re talking about.',
            },
        },
        {
            label         = 'Businessman',
            quotes        = {
                "I'll have two number 9s... wait, wrong order. What you sellin?",
                "Make it quick, I ain't got all day.",
                "Name your price, I'm listening.",
            },
            refusalQuotes = {
                'Wrong time, wrong place, homie.',
                'I got eyes on me. Not today.',
                'Come back when I\'m not so... exposed.',
            },
        },
        {
            label         = 'Construction Worker',
            quotes        = {
                'After a long shift, a man needs something...',
                'Calm down, I\'m just looking what you have.',
                'You got the good stuff?',
            },
            refusalQuotes = {
                'Not here, someone\'s watching.',
                'Not today, I have problems.',
                'Get lost before someone sees us.',
            },
        },
        {
            label         = 'Street Vendor',
            quotes        = {
                'Shh, not so loud. What do you want to sell?',
                'I know a guy who knows a guy... wait, that\'s me.',
                'Let\'s make this quick and quiet.',
            },
            refusalQuotes = {
                'Move along, nothing here.',
                'You don\'t know me, I don\'t know you.',
                'Too hot right now. Not interested.',
            },
        },
        {
            label         = 'Club Owner',
            quotes        = {
                'My clients are always thirsty for something new.',
                'Come closer, don\'t be afraid.',
                'Business is business. Show me.',
            },
            refusalQuotes = {
                'I run a legitimate business. Get out.',
                'Not in front of my place. Are you crazy?',
                'Not now. And you know why? Because I said no.',
            },
        },
    },
}

-- ═══════════════════════════════════════════════════════════════
-- DRUGS
-- ═══════════════════════════════════════════════════════════════
Config.Drugs       = {
    ['weed_bag'] = {
        label            = 'OG Kush Bag', -- label to diplay in the menu
        basePrice        = 259,           -- base price of the drugData
        priceMin         = 207,           -- minimum on slider
        priceMax         = 311,           -- maximum on slider
        baseChance       = 52,            -- base % chance of success
        chancePerExtra   = 5,             -- % decrease for each extra item (above 1)
        priceChanceBonus = 15,            -- max % bonus/penalty for price (slider influence)
        maxUnits         = 10,            -- max units per sale
        dayBonus         = 0,             -- % bonus for day
        nightBonus       = 10,            -- % bonus for night
        policeChance     = 15,            -- % chance for police alert
        minQuantity      = 1,             -- minimum quantity
    },
    ['coke_bag'] = {
        label            = 'Cocaine Bag',
        basePrice        = 450,
        priceMin         = 360,
        priceMax         = 540,
        baseChance       = 40,
        chancePerExtra   = 7,
        priceChanceBonus = 20,
        maxUnits         = 5,
        dayBonus         = 5,
        nightBonus       = 15,
        policeChance     = 25,
        minQuantity      = 1,
    },
    ['meth_bag'] = {
        label            = 'Blue Sky',
        basePrice        = 380,
        priceMin         = 300,
        priceMax         = 460,
        baseChance       = 45,
        chancePerExtra   = 6,
        priceChanceBonus = 18,
        maxUnits         = 8,
        dayBonus         = 0,
        nightBonus       = 12,
        policeChance     = 20,
        minQuantity      = 1,
    },
    ['garbage'] = {
        label            = 'Blue Sky',
        basePrice        = 380,
        priceMin         = 300,
        priceMax         = 460,
        baseChance       = 45,
        chancePerExtra   = 6,
        priceChanceBonus = 18,
        maxUnits         = 8,
        dayBonus         = 0,
        nightBonus       = 12,
        policeChance     = 20,
        minQuantity      = 1,
    },
    ['heroin_bag'] = {
        label            = 'Brown Sugar',
        basePrice        = 500,
        priceMin         = 400,
        priceMax         = 600,
        baseChance       = 35,
        chancePerExtra   = 8,
        priceChanceBonus = 22,
        maxUnits         = 5,
        dayBonus         = 0,
        nightBonus       = 20,
        policeChance     = 30,
        minQuantity      = 1,
    },
}

-- ═══════════════════════════════════════════════════════════════
--  ECONOMY
-- ═══════════════════════════════════════════════════════════════
Config.Economy     = {
    -- 'cash'         = cash (ESX: addMoney / QB: addMoney cash)
    -- 'black_money'  = black money (ESX: addAccountMoney black_money)
    -- 'bank'         = bank account
    paymentMethod = 'cash',
    taxRate       = 0, -- % tax from sale (0 = no tax)
}

-- ═══════════════════════════════════════════════════════════════
--  XP SYSTEM
-- ═══════════════════════════════════════════════════════════════
Config.XP          = {
    enabled   = true,
    xpPerSale = 10,                              -- XP for successful sale (1 unit)
    xpPerUnit = 2,                               -- bonus XP for each unit sold
    levels    = {
        [1] = { xpRequired = 0, bonus = 0 },     -- 0% bonus to chance
        [2] = { xpRequired = 100, bonus = 3 },   -- +3%
        [3] = { xpRequired = 300, bonus = 6 },   -- +6%
        [4] = { xpRequired = 700, bonus = 10 },  -- +10%
        [5] = { xpRequired = 1500, bonus = 15 }, -- +15%
    },
}

-- ═══════════════════════════════════════════════════════════════
--  POLICE DISPATCH
-- ═══════════════════════════════════════════════════════════════
Config.Police      = {
    enabled       = true,
    -- 'ps-dispatch'   = https://github.com/SkullFace22/ps-dispatch
    -- 'cd_dispatch'   = codesign dispatch
    -- 'lspd_dispatch' = lspd dispatch
    -- false           = dispatch off
    dispatch      = 'cd_dispatch',
    jobNames      = { 'police', 'sheriff', 'bcso' },
    alertMessage  = 'Suspicious activity | Possible drug dealing',
    blipSprite    = 51,
    blipColor     = 1,
    blipScale     = 0.8,
    alertDuration = 10000,
}

-- ═══════════════════════════════════════════════════════════════
--  COOLDOWNS (in seconds)
-- ═══════════════════════════════════════════════════════════════
Config.Cooldowns   = {
    afterFail    = 120, -- ped refuses you after fail
    afterSuccess = 300, -- ped has had enough after success
    global       = 30,  -- anti-spam between attempts (server-side)
}

-- ═══════════════════════════════════════════════════════════════
--  ANIMATIONS (plays during transaction)
-- ═══════════════════════════════════════════════════════════════
Config.Animation   = {
    enabled  = true,
    dict     = 'mp_common',
    clip     = 'givetake1_a',
    duration = 3000,
    flag     = 49,
}

-- ═══════════════════════════════════════════════════════════════
--  NUI
-- ═══════════════════════════════════════════════════════════════
Config.NUI         = {
    animationsEnabled = true,
    soundEnabled      = false,
}
