if Config.Locale ~= 'en' then return end

Lang = {
    npc_interest      = "Hmm, I'm interested. Let's negotiate the price...",
    npc_reject        = "Thanks, but no. Not right now.",
    npc_success       = "Good deal. Stay safe.",

    ui_select_drug    = 'What do you want to sell?',
    ui_negotiate      = "Hmm, I'm interested. Let's negotiate the price...",
    ui_success_chance = 'Success chance',
    ui_no_affect      = 'Base price',
    ui_price_piece    = 'Price per piece',
    ui_quantity       = 'Quantity',
    ui_reject         = 'Reject',
    ui_make_offer     = 'Make Offer',
    ui_you_have       = 'You have: {count} pieces',
    ui_per_extra      = 'Each additional piece reduces chance by {chance}%',
    ui_day_bonus      = '+{bonus}% because it\'s day',
    ui_night_bonus    = '+{bonus}% because it\'s night',
    ui_level_bonus    = '+{bonus}% dealer bonus (level {level})',

    notify_no_drugs   = "You don't have any drugs on you.",
    notify_cooldown   = "This person doesn't want to hear from you right now.",
    notify_selling    = 'Transaction in progress...',
    notify_success    = 'Sale successful! You received {amount}.',
    notify_fail       = 'Sale failed. Try again later.',
    notify_police     = 'Police has been called!',
    notify_not_enough = "You don't have enough {item}.",

    xp_gained         = '+{xp} XP',
    xp_levelup        = 'You reached level {level}!',

    dispatch_message  = '🚨 Suspicious activity | Possible drug deal',

    day               = 'day',
    night             = 'night',
    interact_label    = 'Offer drugs',
}
