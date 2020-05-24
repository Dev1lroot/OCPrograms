-- =================================================================
-- OpenComputers Lua ELinks Implementation v Alpha 0.0.2-24-MAY-2020
-- Developed by: Dev1lroot               Licensed under: MIT License
-- =================================================================
llocal net = require("internet")
local os = require("os")
local com = require("component")
local term = require("term")
local gpu = com.gpu
local event = require("event")
local unicode = require("unicode")
local shell = require("shell")
local args, ops = shell.parse(...)
local domain = ""

buttons = {}

function addButton(x,y,name,label)
  local button = {}
  button.x = x
  button.y = y
  button.name = name
  button.label = label
  table.insert(buttons,button)
end

function drawButton(button,state)
  if string.lower(state) == "free" then
    gpu.setForeground(0x0022FF)
    gpu.setBackground(0x000000)
  elseif string.lower(state) == "hover" then
    gpu.setForeground(0x000000)
    gpu.setBackground(0x0022FF)
  end
  x = button.x
  y = button.y
  label = button.label
  gpu.set(x,y,"["..label.."]")
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
end

function drawGUI()
  for i,button in ipairs(buttons) do
    drawButton(button,"free")
  end
end

function file_get_contents(url)
  local handle = net.request(url)
  local result = ""
  for chunk in handle do result = result..chunk end
  return true, result
end

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function strSplit(s,sep)
  if s:sub(-1)~=sep then s=s..sep end
  return s:gmatch("(.-)"..sep)
end

function parseHTML(html)
  local global_tags = {}
  if html:match("<") and html:match(">") then
    local tags = strSplit(html,"<")
    for tag in tags do
      local tagt = strSplit(tag,">")
      for t in tagt do
        t = trim(t)
        if t:len() >= 1 then
          table.insert(global_tags,t)
        end
      end
    end
  else
  	global_tags = strSplit(html,"\n")
  end
  return global_tags
end

function tabulator(by)
  strout = ""
  for i = 0, by do
    strout = strout .. " "
  end
  return strout
end

function directRequest(url)
  buttons = {}
  event.ignore('touch', onClick)
  local status, result = file_get_contents(url)
  if status then
  	  displayHTML(result)
  	  term.setCursor(1,h-1)
  else
  	print("fatal error while reading file")
  end
  os.sleep(1000000)
end

function onClick(event, ...)
  local anchor = false
  local addr, x, y = ...
  for i,button in ipairs(buttons) do
    if y == button.y and x >= button.x then
      if button.x + unicode.len(button.label) + 4 > x then
        drawButton(button,"hover")
        os.sleep(0.2)
        drawButton(button,"free")
        if button.name:match("http") then
          directRequest(button.name)
          print("goto.. "..button.name)
        else
          directRequest(domain..button.name)
          event.ignore('touch', onClick)
          if button.name:sub(1,1) == "/" then
            print("goto.. "..domain..button.name)
          else
          	print("goto.. "..domain..button.name)
          	domain = url
          end
        end
        os.sleep(0.2)
        anchor = true
      end
    end
  end
  if anchor then
    anchor = false
    buttons = {}
    event.ignore('touch', onClick)
    drawGUI()
  end
end

function displayHTML(html)
  local displaylines = 0
  local tags = parseHTML(html)
  local depth = 0
  term.clear()
  if domain:match(".txt") then
  	for i in pairs(tags) do
  	  print(tags[i])
  	end
  else
  	w, h = gpu.getResolution()
  	gpu.fill(1,1,w,h," ")
	  for i in pairs(tags) do
	  	if tags[i]:sub(1,4) == "/div" then
	  	  if depth >= 1 then
	  	  	depth = depth - 1
	  	  end
	  	end
	  	if tags[i]:sub(1,3) == ("div") then
	  	  depth = depth + 1
	  	end
	  	if tags[i]:sub(1,1) == "p" and tags[i]:sub(2,2) ~= "r" then
	  	  print(tabulator(depth)..tags[i+1])
	  	  displaylines = displaylines + 1
	  	end
	  	if tags[i]:sub(1,2) == ("h1" or "h2" or "h3") then
	  	  print(tabulator(depth)..tags[i+1])
	  	  displaylines = displaylines + 1
	  	end
	  	if tags[i]:sub(1,1) == "a" then
	  	  addButton(depth+1,displaylines+1,tags[i]:sub(9,tags[i]:len()-1),tags[i+1])
        displaylines = displaylines + 1
	  	end
	  end
	  drawGUI()
    event.listen('touch', onClick)
  end
end

function firstRequest()
  local url = args[1]
  if url == nil then
  	print("Usage: elinks http://url/")
    url = io.read()
  end
  if url:sub(1,4) ~= "http" then
  	print("Unvalid URL!")
    url = io.read()
  else
    local status, result = file_get_contents(url)
    if status then
  	  domain = url
  	  displayHTML(result)
  	  w, h = gpu.getResolution()
  	  gpu.setForeground(0xFFFFFF)
  	  term.setCursor(1,h-1)
    end
  end
  url = nil
  os.sleep(1000000)
end
firstRequest()
