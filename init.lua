local wifiWatcher = nil
local SAPSSID = "SAP-Corporate"

function muteSpeakersAtWorkCallback()
    newSSID = hs.wifi.currentNetwork()

    if newSSID == SAPSSID then
        hs.audiodevice.defaultOutputDevice():setVolume(0)
    else
        hs.audiodevice.defaultOutputDevice():setVolume(25)
    end
end

wifiWatcher = hs.wifi.watcher.new(muteSpeakersAtWorkCallback)
wifiWatcher:start()
