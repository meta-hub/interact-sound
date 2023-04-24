
------
-- InteractionSound by Scott
-- Version: v0.0.1
-- Path: client/main.lua
--
-- Allows sounds to be played on single clients, all clients, or all clients within
-- a specific range from the entity to which the sound has been created.
------

------
-- function getSoundId
--
-- @return string - A unique sound id to be used for the sound being played.
--
-- Returns a unique sound id, to be used automatically for legacy systems.
------
local curSoundId = 0

local function getSoundId()
    curSoundId = curSoundId + 1

    if curSoundId == 0xFFFF then
        curSoundId = 0
    end

    return "legacy_sound_" .. curSoundId
end

------
-- Track the player's loading state
------
local standardVolumeOutput = 0.3
local hasPlayerLoaded = false

Citizen.CreateThread(function()
	Wait(1000)
	hasPlayerLoaded = true
end)

------
-- RegisterNetEvent LIFE_CL:Sound:PlayOnOne
--
-- @param soundFile    - The name of the soundfile within the client/html/sounds/ folder.
--                     - Can also specify a folder/sound file.
-- @param soundVolume  - The volume at which the soundFile should be played. Nil or don't
--                     - provide it for the default of standardVolumeOutput. Should be between
--                     - 0.1 to 1.0.
-- @param soundId      - The id of the sound to be played. If not provided, a random id will be generated.
--
-- Starts playing a sound locally on a single client.
------
RegisterNetEvent('InteractSound_CL:PlayOnOne', function(soundFile, soundVolume, soundId)
    if hasPlayerLoaded then
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile  = soundFile,
            transactionVolume = soundVolume or standardVolumeOutput,
            transactionId = soundId or getSoundId()
        })
    end
end)

------
-- RegisterNetEvent LIFE_CL:Sound:PlayOnAll
--
-- @param soundFile    - The name of the soundfile within the client/html/sounds/ folder.
--                     - Can also specify a folder/sound file.
-- @param soundVolume  - The volume at which the soundFile should be played. Nil or don't
--                     - provide it for the default of standardVolumeOutput. Should be between
--                     - 0.1 to 1.0.
-- @param soundId      - The id of the sound to be played. If not provided, a random id will be generated.
--
-- Starts playing a sound on all clients who are online in the server.
------
RegisterNetEvent('InteractSound_CL:PlayOnAll', function(soundFile, soundVolume, soundId)
    if hasPlayerLoaded then
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile = soundFile,
            transactionVolume = soundVolume or standardVolumeOutput,
            transactionId = soundId or getSoundId()
        })
    end
end)

------
-- RegisterNetEvent LIFE_CL:Sound:PlayWithinDistance
--
-- @param targetCoords    - The coordinates for which the max distance is to be drawn from.
-- @param maxDistance     - The maximum float distance (client uses Vdist) to allow the player to
--                        - hear the soundFile being played.
-- @param soundFile       - The name of the soundfile within the client/html/sounds/ folder.
--                        - Can also specify a folder/sound file.
-- @param soundVolume     - The maximum volume at which the soundFile should be played. Nil or don't
--                        - provide it for the default of standardVolumeOutput. Should be between
--                        - 0.1 to 1.0.
-- @param soundId         - The id of the sound to be played. If not provided, a random id will be generated.
--
-- Starts playing a sound on a client if the client is within the specificed maxDistance from the playOnEntity.
-- @TODO Change sound volume based on the distance the player is away from the playOnEntity.
------
RegisterNetEvent('InteractSound_CL:PlayWithinDistance', function(targetCoords, maxDistance, soundFile, soundVolume, soundId)
	if hasPlayerLoaded then
		local myCoords = GetEntityCoords(PlayerPedId())
		local distance = #(myCoords - targetCoords)

		if distance < maxDistance then
			SendNUIMessage({
				transactionType = 'playSound',
				transactionFile  = soundFile,
				transactionVolume = soundVolume or standardVolumeOutput,
                transactionId = soundId or getSoundId()
			})
		end
	end
end)

------
-- Track 3d sounds (only when required, thread closes once no sounds are playing)
-- Thread is self-closing to ensure legacy users don't notice any increase in CPU usage.
------
local sounds3d = {}

local function setVolume(sound, volume)
    SendNUIMessage({
        transactionType = 'setVolume',
        transactionId = sound.id,
        transactionVolume = volume
    })
end

local function playSound(sound, volume)
    SendNUIMessage({
        transactionType = 'playSound',
        transactionId = sound.id,
        transactionFile = sound.file,
        transactionVolume = volume
    })

    print("Play", sound.id, volume)
end

local function stopSound(sound)
    SendNUIMessage({
        transactionType = 'stopSound',
        transactionId = sound.id
    })
end

local function trackSounds()
    if #sounds3d > 1 then return end
    
    while #sounds3d > 0 do
        Wait(200)
        local plyPos = GetEntityCoords(PlayerPedId())

        for i,sound in ipairs(sounds3d) do
            local distance = #(plyPos - sound.coords)

            if distance < sound.maxDistance then
                local volumeMod = (sound.maxDistance - distance) / sound.maxDistance
                local volume = volumeMod * (sound.volume or standardVolumeOutput)
                
                if sound.playing then
                    if volume ~= sound.prevVolume then
                        setVolume(sound, volume)
                    end
                else
                    sound.playing = true
                    playSound(sound, volume)
                end

                sound.prevVolume = volume
            elseif sound.playing then
                sound.playing = false
                stopSound(sound)
            end
        end
    end
end

------
-- RegisterNetEvent LIFE_CL:Sound:Play3D
--
-- @param targetCoords    - The coordinates for which the max distance is to be drawn from.
-- @param maxDistance     - The maximum float distance (client uses Vdist) to allow the player to
--                        - hear the soundFile being played.
-- @param soundFile       - The name of the soundfile within the client/html/sounds/ folder.
--                        - Can also specify a folder/sound file.
-- @param soundVolume     - The maximum volume at which the soundFile should be played. Nil or don't
--                        - provide it for the default of standardVolumeOutput. Should be between
--                        - 0.1 to 1.0.
-- @param soundId         - The id of the sound to be played. If not provided, a random id will be generated.
--
-- Starts playing and tracking a sound from a 3D position, changing the volume to desired levels at distances.
------
RegisterNetEvent('InteractSound_CL:Play3D', function(targetCoords, maxDistance, soundFile, soundVolume, soundId)
    if not hasPlayerLoaded then return end

    table.insert(sounds3d, {
        id = soundId or getSoundId(),
        coords = targetCoords,
        maxDistance = maxDistance,
        file = soundFile,
        volume = soundVolume,
        playing = false
    })

    trackSounds()
end)

------
-- RegisterNetEvent LIFE_CL:Sound:Stop3D
--
-- @param soundId - The id of the sound to be stopped.
--
-- Starts playing and tracking a sound from a 3D position, changing the volume to desired levels at distances.
------
RegisterNetEvent('InteractSound_CL:Stop3D', function(id)
    if not hasPlayerLoaded or not id then return end

    local index

    for i=1,#sounds3d do
        if sounds3d[i].id == id then
            index = i
            break
        end
    end

    if not index then return end
    
    table.remove(sounds3d, index)

    SendNUIMessage({
        transactionType = 'stopSound',
        transactionId = id
    })
end)

------
-- RegisterNetEvent LIFE_CL:Sound:Stop
--
-- Stop a specific sound that is currently playing.
------
RegisterNetEvent('InteractSound_CL:Stop', function(id)
    if not hasPlayerLoaded then return end

    SendNUIMessage({
        transactionType = 'stopSound',
        transactionid = id
    })
end)

------
-- RegisterNetEvent LIFE_CL:Sound:StopAll
--
-- Stops all sounds that are currently playing.
------
RegisterNetEvent('InteractSound_CL:StopAll', function()
    if not hasPlayerLoaded then return end

    SendNUIMessage({
        transactionType = 'stopAll'
    })
end)