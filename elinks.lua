-- =================================================================
-- OpenComputers Lua ELinks Implementation v Alpha 0.0.4-27-MAY-2020
-- Developed by: Dev1lroot               Licensed under: MIT License
-- =================================================================
local net = require("internet")
local os = require("os")
local com = require("component")
local term = require("term")
local gpu = com.gpu
local event = require("event")
local unicode = require("unicode")
local shell = require("shell")
local args, ops = shell.parse(...)
local domain = ""
local wt = true
local w, h = gpu.getResolution()
local location = nil

buttons = {}
function exists(what,T)
  o = false
  for i in ipairs(T) do
    if what == T[i] then
      o = true
    end
  end
  return o
end
function tlen(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function tilbake(u)
  local nu = ""
  if u:sub(1,4) == "http" then
    u = u:gsub("//", "/")
    u = u:gsub(":/", ":")
    o = {}
    for s in u:gmatch("([^/]+)") do
       table.insert(o, s)
    end
    for i=1,tlen(o)-1 do
       nu = nu .. o[i] .. "/"
    end
    nu = nu:gsub("%:","://")
    nu = nu:sub(1,nu:len()-1)
  else
    nu = u
  end
  return nu
end
function status(s)
  w, h = gpu.getResolution()
  term.setCursor(1,h)
  gpu.setForeground(0x000000)
  gpu.setBackground(0xFFFFFF)
  gpu.fill(1,h,w,1," ")
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.setForeground(0x000000)
  gpu.setBackground(0xFFFFFF)
  gpu.set(1,h,s)
  tip = "(G)o (C)lose"
  gpu.set(w-tip:len(),h,tip)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
end
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
    gpu.setForeground(0x0066FF)
    gpu.setBackground(0x000000)
  elseif string.lower(state) == "hover" then
    gpu.setForeground(0x000000)
    gpu.setBackground(0xFFFFFF)
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
    html = html:gsub("%<","_!_html_divider_!_<")
    html = html:gsub("%>",">_!_html_divider_!_")
    local tags = strSplit(html,"_!_html_divider_!_")
    for tag in tags do
      tag = trim(tag)
      if tag:len() >= 1 then
        table.insert(global_tags,tag)
      end
    end
  end
  return global_tags
end

function tabulator(by,char)
  strout = ""
  for i = 0, by do
    strout = strout .. char
  end
  return strout
end

function directRequest(url)
  buttons = {}
  if url == nil then
    w, h = gpu.getResolution()
    gpu.setForeground(0x000000)
    gpu.setBackground(0x000000)
    gpu.fill(1,1,w,h-1," ")
    gpu.setBackground(0xFFFFFF)
    gpu.fill(10,18,w-20,h-36," ")
    term.setCursor(w/2-5,h/2-2)
    print("Enter URL")
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(0x000000)
    gpu.fill(16,h/2,w-32,1," ")
    term.setCursor(16,h/2)
    url = io.read()
    if url:sub(1,4) == "http" then
      domain = url
    else
      status("Unvalid URL")
      directRequest(nil)
    end
  else
    location = url
  end
  local status, result = file_get_contents(url)
  if status then
      event.ignore('touch', onClick)
      displayHTML(result)
      term.setCursor(1,h-1)
  else
    status("Page not found")
  end
  while(wt) do
    os.sleep(1)
  end
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
          domain = button.name
          status("goto.. "..domain)
          directRequest(domain)
        else
          if button.name:sub(1,1) == "/" then
            if button.name:len() ~= 1 then
              if button.name:sub(2,2) ~= "?" then
                domain = domain..button.name
                domain = domain:gsub("%//", "/")
                domain = domain:gsub("%:/", "://")
                status("goto.. "..domain)
              else
                status("goto.. "..domain..button.name)
                directRequest(domain..button.name)
              end
            end
          else
            status("goto.. "..domain..button.name)
            if domain:sub(domain:len(),domain:len()) == "/" then
              domain = domain..button.name
            else
              domain = domain.."/"..button.name
            end
            domain = domain:gsub("%//", "/")
            domain = domain:gsub("%:/", "://")
          end
          directRequest(domain)
        end
        os.sleep(1)
        anchor = true
      end
    end
  end
  if anchor then
    anchor = false
    buttons = {}
    drawGUI()
  end
end

function navigation(state, adress, char, code)
  w, h = gpu.getResolution()
  status("Char:"..char.." Code:"..code)
  if code == 46 then
    status("exit the system")
    wt = false
    event.ignore('touch', onClick)
    event.ignore("key_up", navigation)
    os.exit()
  end
  if code == 34 then
    event.ignore('touch', onClick)
    event.ignore("key_up", navigation)
    directRequest(nil)
  end
  if code == 14 then
    if location ~= nil and location:len() >= 6 then
      location = tilbake(location)
      domain = location
      status(location)
      directRequest(location)
    end
  end
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
end
function recognizeTag(tag,depth)
  r = false
  t = {["name"] = nil}
  if tag:sub(1,5) == "<html" then
    t = {["name"] = "html"}
    r = false
  end
  if tag:sub(1,4) == "<div" then
    t = {["name"] = "div"}
    r = false
  end
  if tag:sub(1,4) == "<pre" then
    t = {["name"] = "pre"}
    r = false
  end
  if tag:sub(1,4) == "<img" then
    t = {["name"] = "img"}
    r = false
  end
  if tag:sub(1,3) == "<br" then
    t = {["name"] = "br"}
    r = true
  end
  if tag:sub(1,3) == "<hr" then
    t = {["name"] = "hr"}
    r = true
  end
  if tag:sub(1,2) == "<p" then
    t = {["name"] = "p"}
    r = true
  end
  if exists(tag:sub(1,3),{"<h1","<h2","<h3"}) then
    t = {["name"] = "header"}
    r = true
  end
  if tag:sub(1,2) == "<a" then
    local link = tag:sub(10,tag:len()-1)
    if link:match("\"") then
      for str in string.gmatch(link, "([^\"]+)") do
        link = str
        break
      end
    end
    link = trim(link)
    t = {["name"] = "a",["link"] = link}
    r = true
  end
  return r, t
end
function displayHTML(html)
  term.clear()
  if domain:match(".txt") then
    status("Long file! Please wait..")
    local status, result = file_get_contents(domain)
    if status then
      term.setCursor(1,1)
      print(result)
      status("Ready")
      event.listen("key_up", navigation)
    else
      status("Failure")
    end
  else
    local displaylines = 0
    local tags = parseHTML(html)
    local depth = 1
    local displaycontent = false
    local tag = {}
    local inside = false
    w, h = gpu.getResolution()
    gpu.fill(1,1,w,h," ")
    print(" ")
    for i in pairs(tags) do
      if displaylines >= h-2 then
        --mb later
      else
        if tags[i]:sub(1,1) == "<" then
          if tags[i]:sub(2,2) == "/" then
            inside = false
            tag = {}
            displaycontent = false
            --print(tabulator(depth," ")..tags[i])
            if depth > 1 then depth = depth - 1 end
          else
            inside = true
            displaycontent, tag = recognizeTag(tags[i],depth)
            if tag["name"] == "br" then
              displaylines = displaylines + 1
              tag = {}
            end
            if tag["name"] == "hr" then
              print("  "..tabulator(w-5,"-"))
              displaylines = displaylines + 1
              tag = {}
            end
            if exists(tag["name"],{"br","hr","img","body","html"}) == false then
              depth = depth + 1
            end
            --print(tabulator(depth," ")..tags[i])
          end
        else
          if displaycontent == true then
            if exists(tag["name"],{"header","p"}) then
              displaylines = displaylines + 1
              print(tabulator(depth," ")..tags[i])
              tag = {}
            end
            if tag["name"] == "a" then
              print(" ")
              displaylines = displaylines + 1
              mv = 0
              while exists(tags[i+mv]:sub(1,4),{"<div","<pre"}) or exists(tags[i+mv]:sub(1,5),{"</div","</pre"}) do
                mv = mv + 1
              end
              addButton(depth+2,displaylines+1,tag["link"],tags[i+mv])
              tag = {}
            end
          else
            if inside == false then
              gpu.set(w-((depth*2)+tags[i]:len()),displaylines+1,tags[i])
            end
          end
        end
      end
    end
    drawGUI()
    event.listen('touch', onClick)
    event.listen("key_up", navigation)
    status("Ready")
  end
end

function launchRequest()
  local url = args[1]
  if url == nil then
    directRequest(nil)
  else
    domain = url
    if url:sub(1,4) ~= "http" then
      status("Unvalid URL!")
      directRequest(nil)
    else
      directRequest(url)
    end
    url = nil
    while(wt) do
      os.sleep(1)
    end
  end
end
launchRequest()
