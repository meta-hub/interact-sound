
------
-- Interaction Sounds by Scott
-- Version: v0.0.1
-- Path: server/main.lua
--
-- Allows sounds to be played on single clients, all clients, or all clients within
-- a specific range from the entity to which the sound has been created. Triggers
-- client events only. Used to trigger sounds on other clients from the client or
-- server without having to pass directly to another client.
------

------
-- RegisterServerEvent InteractSound_SV:PlayOnOne
-- Triggers -> ClientEvent InteractSound_CL:PlayOnOne
--
-- @param clientNetId  - The network id of the client that the sound should be played on.
-- @param soundFile    - The name of the soundfile within the client/html/sounds/ folder.
--                     - Can also specify a folder/sound file.
-- @param soundVolume  - The volume at which the soundFile should be played. Nil or don't
--                     - provide it for the default of standardVolumeOutput. Should be between
--                     - 0.1 to 1.0.
--                     - Can also specify a folder/sound file.
--
-- Starts playing a sound locally on a single client.
------
RegisterNetEvent('InteractSound_SV:PlayOnOne')
AddEventHandler('InteractSound_SV:PlayOnOne', function(clientNetId, soundFile, soundVolume, soundId)
    TriggerClientEvent('InteractSound_CL:PlayOnOne', clientNetId, soundFile, soundVolume, soundId)
end)

------
-- RegisterServerEvent InteractSound_SV:PlayOnSource
-- Triggers -> ClientEvent InteractSound_CL:PlayOnSource
--
-- @param soundFile    - The name of the soundfile within the client/html/sounds/ folder.
--                     - Can also specify a folder/sound file.
-- @param soundVolume  - The volume at which the soundFile should be played. Nil or don't
--                     - provide it for the default of standardVolumeOutput. Should be between
--                     - 0.1 to 1.0.
--                     - Can also specify a folder/sound file.
--
-- Starts playing a sound locally on a single client, which is the source of the event.
------
RegisterNetEvent('InteractSound_SV:PlayOnSource')
AddEventHandler('InteractSound_SV:PlayOnSource', function(soundFile, soundVolume, soundId)
    TriggerClientEvent('InteractSound_CL:PlayOnOne', source, soundFile, soundVolume, soundId)
end)

------
-- RegisterServerEvent InteractSound_SV:PlayOnAll
-- Triggers -> ClientEvent InteractSound_CL:PlayOnAll
--
-- @param soundFile     - The name of the soundfile within the client/html/sounds/ folder.
--                      - Can also specify a folder/sound file.
-- @param soundVolume   - The volume at which the soundFile should be played. Nil or don't
--                      - provide it for the default of standardVolumeOutput. Should be between
--                      - 0.1 to 1.0.
--
-- Starts playing a sound on all clients who are online in the server.
------
RegisterNetEvent('InteractSound_SV:PlayOnAll')
AddEventHandler('InteractSound_SV:PlayOnAll', function(soundFile, soundVolume, soundId)
    TriggerClientEvent('InteractSound_CL:PlayOnAll', -1, soundFile, soundVolume, soundId)
end)

------
-- RegisterServerEvent InteractSound_SV:PlayWithinDistance
-- Triggers -> ClientEvent InteractSound_CL:PlayWithinDistance
--
-- @param playOnEntity    - The entity network id (will be converted from net id to entity on client)
--                        - of the entity for which the max distance is to be drawn from.
-- @param maxDistance     - The maximum float distance (client uses Vdist) to allow the player to
--                        - hear the soundFile being played.
-- @param soundFile       - The name of the soundfile within the client/html/sounds/ folder.
--                        - Can also specify a folder/sound file.
-- @param soundVolume     - The volume at which the soundFile should be played. Nil or don't
--                        - provide it for the default of standardVolumeOutput. Should be between
--                        - 0.1 to 1.0.
--
-- Starts playing a sound on a client if the client is within the specificed maxDistance from the playOnEntity.
-- @TODO Change sound volume based on the distance the player is away from the playOnEntity.
------
RegisterNetEvent('InteractSound_SV:PlayWithinDistance')
AddEventHandler('InteractSound_SV:PlayWithinDistance', function(maxDistance, soundFile, soundVolume, soundId)
  TriggerClientEvent('InteractSound_CL:PlayWithinDistance', -1, GetEntityCoords(GetPlayerPed(source)), maxDistance, soundFile, soundVolume, soundId)
end)

RegisterNetEvent('InteractSound_SV:Play3D')
AddEventHandler('InteractSound_SV:Play3D', function(targetCoords, maxDistance, soundFile, soundVolume, soundId)
  TriggerClientEvent('InteractSound_CL:Play3D', -1, targetCoords, maxDistance, soundFile, soundVolume, soundId)
end)

RegisterNetEvent('InteractSound_SV:Stop3D')
AddEventHandler('InteractSound_SV:Stop3D', function(soundId)
  TriggerClientEvent('InteractSound_CL:Stop3D', -1, soundId)
end)

RegisterNetEvent('InteractSound_SV:Stop')
AddEventHandler('InteractSound_SV:Stop', function(soundId)
  TriggerClientEvent('InteractSound_CL:Stop', -1, soundId)
end)

RegisterNetEvent('InteractSound_SV:StopAll')
AddEventHandler('InteractSound_SV:StopAll', function()
  TriggerClientEvent('InteractSound_CL:StopAll', -1)
end)
