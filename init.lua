require 'tabletools'

logger = hs.logger.new('discworld','debug')

local workSSID = "SAP-Corporate"

function setNetworkLocation(location)
  local finder = hs.application"Finder"
  finder:selectMenuItem(location)
end

-- Location based settings
-- @work: mute speakers
-- elsewhere: 
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
  else
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
  logger.df("audiodevwatch args: %s, %s, %s, %s", dev_uid, event_name, event_scope, event_element)
  dev = hs.audiodevice.findDeviceByUID(dev_uid)
  if event_name == 'jack' then
    -- mute on headphones out
    if dev:jackConnected() then
      hs.audiodevice.defaultOutputDevice():setMuted(false)
    else
      hs.audiodevice.defaultOutputDevice():setMuted(true)
    end
  end
end
hs.audiodevice.current()['device']:watcherCallback(audiodevwatch):watcherStart()

-- TODO: Watcher to mute volume if USD headset is removed
function usbwatch(event)
  logger.df("usbwatch args: %s, %s, %s, %s, %s", event["eventType"],
    event["productName"], event["vendorName"], event["vendorID"],
    event["productID"])
end
hs.usb.watcher.new(usbwatch):start()

-- Force wifi callback on (re)load
atWorkWifiCallback()
