local log = hs.logger.new('discworld','debug')

local wifiWatcher = nil
local SAPSSID = "SAP-Corporate"

function muteSpeakersAtWorkCallback()
  newSSID = hs.wifi.currentNetwork()

  if newSSID == SAPSSID then
    log.d("Setting volume to 0")
    hs.audiodevice.defaultOutputDevice():setVolume(0)
  else
    log.d("Setting volume to 25")
    hs.audiodevice.defaultOutputDevice():setVolume(25)
  end
end
wifiWatcher = hs.wifi.watcher.new(muteSpeakersAtWorkCallback)
wifiWatcher:start()

-- Fancy configuration reloading
hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.alert.show("Config Reloaded")
