function isVehicleOnRoof(vehicle)
    local rotation_asix_x, rotation_velocity_y = getElementRotation(vehicle)
        if (rotation_asix_x > 90 and rotation_asix_x < 270) or (rotation_velocity_y > 90 and rotation_velocity_y < 270) then
                return true
        end
        return false
end

function jumping_car(player, key)
    player = getElementsByType('player')
    local vehicle = getPedOccupiedVehicle(player[1])
    if isElement(vehicle) then 
        if getVehicleEngineState(vehicle) then
            if isVehicleOnGround(vehicle) then 
                if isVehicleOnRoof(vehicle) then return end
                velocity_asix_x, velocity_asix_y, velocity_asix_z = getElementVelocity(vehicle)
                rotation_asix_x, rotation_asix_y, rotation_asix_z = getElementRotation(vehicle)
                setElementVelocity(vehicle, velocity_asix_x, velocity_asix_y, velocity_asix_z + 0.3)
                setElementRotation(vehicle, rotation_asix_x + 15, rotation_asix_y, rotation_asix_z)
            end
        end
    end
end

function operate_values(handler_function_getter, handler_function_setter, enabled_value, disabled_value, text_when_enabled, text_when_disabled)
    if handler_function_getter(vehicle) == disabled_value then
        handler_function_setter(vehicle, enabled_value); outputChatBox(text_when_enabled, player, 0, 255, 0)
    else handler_function_setter(vehicle, disabled_value); outputChatBox(text_when_disabled, player, 255, 0, 0)
    end
end

function determine_main_objects(player, vehicle)
    player = getElementsByType('player')
    vehicle = getPedOccupiedVehicle(player[1])
    return player, vehicle
end

function switch_vehicle_lights()
    player, vehicle = determine_main_objects(player, vehicle)
    if vehicle ~= false then
        operate_values(getVehicleOverrideLights, setVehicleOverrideLights, 2, 1, "Фары РАБОТАЮТ!", "Фары ВЫКЛЮЧЕНЫ")
    end
end

function switch_vehicle_engine()
    player, vehicle = determine_main_objects(player, vehicle)
    if vehicle ~= false then
        operate_values(getVehicleEngineState, setVehicleEngineState, true, false, "Двигатель РАБОТАЕТ!", "Двигатель ВЫКЛЮЧЕН!")
        latest_vehicle_engine_status = getVehicleEngineState(vehicle)
    end
    if latest_vehicle_engine_status == true then string_latest_vehicle_engine_status = 'enabled'  
    else string_latest_vehicle_engine_status = 'disabled' end
end

function final_enter_vehicle(vehicle, latest_vehicle_engine_status)
    if firts_time_in_the_new_car == true then setVehicleEngineState(vehicle, false); setVehicleOverrideLights(vehicle, 1); firts_time_in_the_new_car = false
    else 
        if string_latest_vehicle_engine_status == 'enabled' then setVehicleEngineState(vehicle, true)
        else setVehicleEngineState(vehicle, false) end
    end
end

function start_enter_vehicle(player, root)                      -- Наивная проверка, мне кажется на практике хорошо бы реализовать проверку по id : if player_account_id ~= owner_account_id
    current_player = getPlayerName(player)
    if current_player ~= getElementData(vehicle, "owner") then
        outputChatBox("КЫШ! Только " .. getElementData(vehicle, "owner") .. " может пользоваться этим транспортом!", player, 255, 0, 0)
        cancelEvent()
    end
end

function delete_car_when_quit(quitType)
    if isElement(vehicle) == true then destroyElement(vehicle) end 
end

function spawn_player()
    player = getElementsByType('player')
    bindKey(player[1], "e", "down", switch_vehicle_engine)
    bindKey(player[1], "l", "down", switch_vehicle_lights)
    bindKey(player[1], "lshift", "up", jumping_car)
    --bindKey(player[1], "p", "down", jumping_car)          К сожалению, я не понял, как биндятся сочетания клавиш =С
    player_nickname = getPlayerName(source)
    outputChatBox('Привет, '.. player_nickname .. '!')
    spawnPlayer(player[1], 0.0, 0.0, 5.0, 90.0, 0)
end

function calculate_spawn_positions(player_position_x, player_position_y, player_rotation_z, distance)
    player_position_x = player_position_x - math.sin(math.rad(player_rotation_z)) * distance
    player_position_y = player_position_y + math.cos(math.rad(player_rotation_z)) * distance
    player_rotation = player_rotation_z + math.cos(math.rad(player_rotation_z))
    return player_position_x, player_position_y, player_rotation
end

function spawn_car_after_validations(vehicle_identifier, player_position_x, player_position_y, player_position_z, player_rotation_x, player_rotation_y, player_rotation_z)
    vehicle_id = getVehicleModelFromName(vehicle_name)
    vehicle = createVehicle(vehicle_identifier, player_position_x, player_position_y, player_position_z, 0, 0, player_rotation + 90)
    setElementData(vehicle, "owner", vehicle_owner_nickname)
    return vehicle_owner_nickname
end

function create_car(player, cmd, ...)
    local distance = 5
    local player_position_x, player_position_y, player_position_z = getElementPosition(player) 
    local player_rotation_x, player_rotation_y, player_rotation_z = getElementRotation(player)
    firts_time_in_the_new_car = true
    vehicle_owner_nickname = getPlayerName(player)

    if isElement(vehicle) == true then destroyElement(vehicle) end

    player_position_x, player_position_y, player_rotation = calculate_spawn_positions(player_position_x, player_position_y, player_rotation_z, distance)

    vehicle_name = table.concat({...}, " ")

    if type(tonumber(vehicle_name)) == 'number' and (tonumber(vehicle_name) >= 400 and tonumber(vehicle_name) <= 611) then 
        vehicle_id = tonumber(vehicle_name)
        vehicle_owner_nickname = spawn_car_after_validations(vehicle_id, player_position_x, player_position_y, player_position_z, player_rotation_x, player_rotation_y, player_rotation_z)
    elseif type(tostring(vehicle_name)) == 'string' and getVehicleModelFromName(vehicle_name) then 
        vehicle_owner_nickname = spawn_car_after_validations(getVehicleModelFromName(vehicle_name), player_position_x, player_position_y, player_position_z, player_rotation_x, player_rotation_y, player_rotation_z)
    else outputChatBox("Синтаксис : /veh <id (400-611) > или /veh <валидное имя>", player, 255, 0, 0)
    end

    return vehicle_owner_nickname 
end

vehicle_owner_nickname = addCommandHandler("veh", create_car)

addEventHandler("onPlayerJoin", root, spawn_player)

addEventHandler("onVehicleStartEnter", root, start_enter_vehicle)

addEventHandler("onPlayerVehicleEnter", root, final_enter_vehicle)

addEventHandler("onPlayerQuit", root, delete_car_when_quit)