--local log = require "log"
--local utils = require "st.utils"

local capabilities = require "st.capabilities"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local zcl_global_commands = require "st.zigbee.zcl.global_commands"

local tuyaEF00_model_defaults = require "tuyaEF00_model_defaults"
local REPORT_BY_DP = require "sub_drivers.TS0601.datapoints"

local NAME = "TS0601"

return {
  NAME = NAME,
  can_handle = tuyaEF00_model_defaults.can_handle(NAME),
  lifecycle_handlers = tuyaEF00_model_defaults.lifecycle_handlers,
  supported_capabilities = {
    capabilities.switch,
    capabilities.doorControl,
    capabilities.switchLevel,
  },
  zigbee_handlers = {
    global = {
      [zcl_clusters.TuyaEF00.ID] = {
        [zcl_global_commands.WRITE_ATTRIBUTE_ID] = tuyaEF00_model_defaults.command_data_report_handler,
      },
    },
    cluster = {
      [zcl_clusters.TuyaEF00.ID] = {
        [zcl_clusters.TuyaEF00.commands.DataReport.ID] = tuyaEF00_model_defaults.command_data_report_handler,
      }
    },
  },
  capability_handlers = {
    [capabilities.switch.ID] = {
      [capabilities.switch.commands.on.NAME] = tuyaEF00_model_defaults.command_on_handler,
      [capabilities.switch.commands.off.NAME] = tuyaEF00_model_defaults.command_off_handler,
    },
    [capabilities.doorControl.ID] = {
      [capabilities.doorControl.commands.open.NAME] = tuyaEF00_model_defaults.command_open_handler,
      [capabilities.doorControl.commands.close.NAME] = tuyaEF00_model_defaults.command_close_handler,
    },
    [capabilities.switchLevel.ID] = {
      [capabilities.switchLevel.commands.setLevel.NAME] = tuyaEF00_model_defaults.command_level_handler,
    },
  },
}