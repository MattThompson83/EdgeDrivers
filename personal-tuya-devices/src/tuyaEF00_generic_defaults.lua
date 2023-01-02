local log = require "log"
local utils = require "st.utils"

local zcl_clusters = require "st.zigbee.zcl.clusters"

local tuyaEF00_defaults = require "tuyaEF00_defaults"
local myutils = require "utils"

local capabilities = require "st.capabilities"
local info = capabilities["valleyboard16460.info"]

local datapoint_types_to_fn = {
  booleanDatapoints = tuyaEF00_defaults.on_off,
  enumerationDatapoints = tuyaEF00_defaults.enum,
  valueDatapoints = tuyaEF00_defaults.value,
  stringDatapoints = tuyaEF00_defaults.string,
  bitmapDatapoints = tuyaEF00_defaults.bitmap,
}

local function get_datapoints (device)
  local o = {}
  for name,fn in pairs(datapoint_types_to_fn) do
    if device.preferences[name] ~= nil then
      for dpid in device.preferences[name]:gmatch("[^,]+") do
        o[tonumber(dpid, 10)] = fn
      end
    end
  end
  return o
end

local child_types_to_profile = {
  booleanDatapoints = "child-switch-v1",
  bitmapDatapoints = "child-bitmap-v1",
  enumerationDatapoints = "child-enum-v1",
  stringDatapoints = "child-string-v1",
  valueDatapoints = "child-value-v1",
}

local lifecycle_handlers = {}

function lifecycle_handlers.infoChanged (driver, device, event, args)
  for name, profile in pairs(child_types_to_profile) do
    if device.preferences[name] ~= nil and args.old_st_store.preferences[name] ~= device.preferences[name] then
      for ndpid in device.preferences[name]:gmatch("[^,]+") do
        local dpid = string.format("%02X", ndpid)
        local created = device:get_child_by_parent_assigned_key(dpid)
        if not created then
          driver:try_create_device({
            type = "EDGE_CHILD",
            device_network_id = nil,
            parent_assigned_child_key = dpid,
            label = "Child " .. tonumber(dpid, 16),
            profile = profile,
            parent_device_id = device.id,
            manufacturer = driver.NAME,
            model = profile,
            vendor_provided_label = "Child " .. tonumber(dpid, 16),
          })
        end
      end
    end
  end
end

local defaults = {
  lifecycle_handlers = lifecycle_handlers
}

function defaults.can_handle (opts, driver, device, ...)
  return device:supports_server_cluster(zcl_clusters.tuya_ef00_id)
end

local function send_command(fn, driver, device, ...)
  if device.parent_device_id ~= nil then
    --local datapoints = {}
    local datapoints = get_datapoints(device:get_parent_device())
    if #datapoints > 0 then
      fn(datapoints)(driver, device, ...)
    end
  end
end

function defaults.command_data_report_handler(driver, device, ...)
  local datapoints = get_datapoints(device)
  if #datapoints > 0 then
    tuyaEF00_defaults.command_data_report_handler(datapoints)(driver, device, ...)
  end
end

function defaults.command_on_handler(...)
  send_command(tuyaEF00_defaults.command_on_handler, ...)
end

function defaults.command_off_handler(...)
  send_command(tuyaEF00_defaults.command_off_handler, ...)
end

function defaults.command_string_handler(...)
  send_command(tuyaEF00_defaults.command_string_handler, ...)
end

function defaults.command_enum_handler(...)
  send_command(tuyaEF00_defaults.command_enum_handler, ...)
end

function defaults.command_value_handler(...)
  send_command(tuyaEF00_defaults.command_value_handler, ...)
end

function defaults.command_raw_handler(...)
  send_command(tuyaEF00_defaults.command_raw_handler, ...)
end

function defaults.command_bitmap_handler(...)
  send_command(tuyaEF00_defaults.command_bitmap_handler, ...)
end

return defaults