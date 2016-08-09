require 'tabletools'

logger = hs.logger.new('discworld','debug')

local workSSID = "SAP-Corporate"
local networkLocation = {
  Proxy = {"Apple", "Location", "SAP"},
  NoProxy = {"Apple", "Location", "Automatic"}
}
local lyncStatus = {
  DND = {"Status", "Do Not Disturb"},
  Available = {"Status", "Available"},
  OffWork = {"Status", "Off Work"}
}

-- function to set Microsoft Lync status
function setLyncStatus(statusEntry)
  lyncApp = hs.application"lync"
  if lyncApp == nil then
    -- lync not running
    return
  end
  lyncApp:activate()
  lyncApp:selectMenuItem(statusEntry)
  -- lyncApp:hide()
end

function setNetworkLocation(location)
  local finder = hs.application"Finder"
  finder:selectMenuItem(location)
end

-- Location based settings
-- @work: mute speakers, enable proxy, lync available
-- elsewhere: disable proxy, lync dnd
function atWorkWifiCallback()
  local newSSID = hs.wifi.currentNetwork()

  -- do nothing on disconnections
  if newSSID == nil then
    return
  end

  if newSSID == workSSID then
    -- @work settings
    logger.d("@work")
    hs.audiodevice.defaultOutputDevice():setMuted(true)
    setNetworkLocation(networkLocation["Proxy"])
    setLyncStatus(lyncStatus["Available"])
  else
    setNetworkLocation(networkLocation["NoProxy"])
    setLyncStatus(lyncStatus["OffWork"])
  end
end
wifiWatcher = hs.wifi.watcher.new(atWorkWifiCallback)
wifiWatcher:start()

-- ctrl+alt+del :)
hs.hotkey.bind({"ctrl", "cmd"}, "delete", nil, function()
  hs.caffeinate.startScreensaver()
end)

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
hs.pathwatcher.new(hs.configdir, reloadConfig):start()
hs.notify.new({title="Hammerspoon", informativeText="Config Reloaded"}):send()

-- Per-device watcher to detect headphones in/out
function audiodevwatch(dev_uid, event_name, event_scope, event_element)
   logger.df("Audiodevwatch args: %s, %s, %s, %s", dev_uid, event_name, event_scope, event_element)
   dev = hs.audiodevice.findDeviceByUID(dev_uid)
   if event_name == 'jack' then
      if dev:jackConnected() then
        hs.audiodevice.defaultOutputDevice():setMuted(false)
      else
        hs.audiodevice.defaultOutputDevice():setMuted(true)
      end
   end
end
hs.audiodevice.current()['device']:watcherCallback(audiodevwatch):watcherStart()

-- Force wifi callback on (re)load
atWorkWifiCallback()
