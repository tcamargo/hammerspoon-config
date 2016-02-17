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
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
