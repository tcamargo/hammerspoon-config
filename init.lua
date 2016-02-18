local log = hs.logger.new('discworld','debug')

local workSSID = "SAP-Corporate"
local proxyLocation = {"Apple", "Location", "SAP"}
local noProxyLocation = {"Apple", "Location", "No proxy"}

-- Location based settings
-- @work: mute speakers, enable proxy
-- elsewhere: disable proxy
function atWorkCallback()
  local newSSID = hs.wifi.currentNetwork()
  local finder = hs.appfinder.appFromName("Finder")

  -- do nothing on disconnections
  if newSSID == nil then
    return
  end

  if newSSID == workSSID then
    -- @work settings
    hs.alert("@work")
    hs.audiodevice.defaultOutputDevice():setVolume(0)
    finder:selectMenuItem(proxyLocation)
    -- hs.alert("Proxy enabled")
  else
    finder:selectMenuItem(noProxyLocation)
    -- hs.alert("Proxy disabled")
  end
end
wifiWatcher = hs.wifi.watcher.new(atWorkCallback)
wifiWatcher:start()

-- ctrl+alt+del :)
hs.hotkey.bind({"ctrl", "cmd"}, "delete", nil, function()
  hs.caffeinate.startScreensaver()
end)

-- Fancy configuration reloading
hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.notify.new({title="Hammerspoon", informativeText="Config Reloaded"}):send()
