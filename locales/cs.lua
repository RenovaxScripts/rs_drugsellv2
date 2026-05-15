if Config.Locale ~= 'cs' then return end

Lang = {
    npc_interest      = 'Hmm, mám zájem. Pojďme se domluvit na ceně...',
    npc_reject        = 'Díky, ale ne. Teď ne.',
    npc_success       = 'Dobrý obchod. Drž se.',

    ui_select_drug    = 'Co chceš prodat?',
    ui_negotiate      = "Hmm, mám zájem. Pojďme se domluvit...",
    ui_success_chance = 'Šance na úspěch',
    ui_no_affect      = 'Základní cena',
    ui_price_piece    = 'Cena za kus',
    ui_quantity       = 'Množství',
    ui_reject         = 'Odmítnout',
    ui_make_offer     = 'Nabídnout',
    ui_you_have       = 'Máš: {count} kusů',
    ui_per_extra      = 'Každý extra kus snižuje šanci o {chance}%',
    ui_day_bonus      = '+{bonus}% protože je den',
    ui_night_bonus    = '+{bonus}% protože je noc',
    ui_level_bonus    = '+{bonus}% dealer bonus (level {level})',

    notify_no_drugs   = 'Nemáš u sebe žádné drogy.',
    notify_cooldown   = 'Tento člověk tě momentálně nechce slyšet.',
    notify_selling    = 'Probíhá transakce...',
    notify_success    = 'Prodej úspěšný! Obdržel jsi {amount}.',
    notify_fail       = 'Prodej se nezdařil. Zkus to jindy.',
    notify_police     = 'Přivolána policie!',
    notify_not_enough = 'Nemáš dostatek {item}.',

    xp_gained         = '+{xp} XP',
    xp_levelup        = 'Dosáhl jsi level {level}!',

    dispatch_message  = '🚨 Podezřelá aktivita | Možný prodej drog',

    day               = 'den',
    night             = 'noc',
    interact_label    = 'Nabídnout drogu',
}
