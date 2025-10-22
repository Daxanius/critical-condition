-- Purposeful desync
local player_health = 0
local player_zoom = 0
local shake_ticks_left = 0
local shake_cooldown_remaining = 0
local hurt_sound_cooldown_remaining = 0

local shake_duration = 10 -- ticks (60 ticks = 1 second)
local shake_intensity = 0.1
local shake_cooldown = 60
local hurt_sound_cooldown = 60

local hurt_sounds = {
    "player-hurt-sound-male-1",
    "player-hurt-sound-male-2",
    "player-hurt-sound-male-3",
    "player-hurt-sound-male-4"
}

-- Listen to all player health modified events
script.on_event(defines.events.on_tick, function(event)
    local player = game.get_player(1) -- Get the current local player

    if player.character then
        local current_hp = player.character.health

        if current_hp < player_health then
            on_player_damaged(player, player_health - current_hp)
        end

        player_health = current_hp
        update_camera_shake(player)
        update_sound()
    end
end)

function on_player_damaged(player, damage_amount)
    player.create_local_flying_text{
        text = "-" .. math.floor(damage_amount + 0.5), -- Round damage amount
        position = player.position,
        surface = player.surface,
        color = {r=1,g=0,b=0}
    }

    play_sound(player)
    shake_camera(player)
end

function play_sound(player)
    if hurt_sound_cooldown_remaining > 0 then
        return
    end

    -- Pick a random sound from the list
    local sound = hurt_sounds[math.random(#hurt_sounds)]

    player.play_sound{ path = sound }
    hurt_sound_cooldown_remaining = hurt_sound_cooldown
end

function shake_camera(player)
    if shake_ticks_left > 0 or shake_cooldown_remaining > 0 then
        return
    end

    player_zoom = player.zoom
    shake_ticks_left = shake_duration
    shake_cooldown_remaining = shake_cooldown
end

function update_camera_shake(player)
    if shake_cooldown_remaining > 0 then
        shake_cooldown_remaining = shake_cooldown_remaining - 1
    end

    if shake_ticks_left <= 0 then
        return
    end

    local offset = (math.random() - 0.5) * shake_intensity
    player.zoom = player_zoom + offset
    shake_ticks_left = shake_ticks_left - 1

    if shake_ticks_left <= 0 then
        player.zoom = player_zoom
    end
end

function update_sound() 
    if hurt_sound_cooldown_remaining > 0 then
        hurt_sound_cooldown_remaining = hurt_sound_cooldown_remaining - 1
    end
end