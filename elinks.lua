-- =================================================================
-- OpenComputers Lua ELinks Implementation v Alpha 0.0.1-24-MAY-2020
-- Developed by: Dev1lroot               Licensed under: MIT License
-- =================================================================
local net = require("internet")
local function file_get_contents(url)
  local handle = net.request(url)
  local result = ""
  for chunk in handle do result = result..chunk end
  return true, result
end
local function doRequest()
  url = io.read()
  local status, result = file_get_contents(url)
  if status then
  	print(result)
  end
end
doRequest()
