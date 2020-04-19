-- ===============================================
-- InfoPanel    v2.0                 (19 APR 2020)
-- Author:      Dev1lroot
-- Description: Advanced Multiscreen Infopanel
-- ===============================================

local com = require("component")
local unicode = require("unicode")
local fs = require("filesystem")
local screens = com.list('screen', true)
local gpu = com.gpu
local defaultscreen = gpu.getScreen()
local w, h = 0

function strFromFile(path)
    local file = io.open(path, "rb")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

function strSplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function listScreens()
  i = 1;
  for address in screens do
    if address == defaultscreen then
      print(i.."). "..address.." *")
    else
      print(i.."). "..address)
    end
    i = i + 1
  end
end

function bindScreen(addr)
  local i = 1
  local text = {}
  ::selectfile::
  io.write("выберите файл:")
  path = io.read()
  if fs.exists(path) then
    text = strFromFile(path)
  else
    print("файл не найден!")
    goto selectfile
  end
  for address in screens do
    if i == tonumber(addr) then
      gpu.bind(address)
      lines = strSplit(text,"\n")
      for i,line in ipairs(lines) do
        h = i
        len = unicode.len(line)
        if len >= w then
          w = len
        end
      end
      w = w + 15
      gpu.setResolution(w,h)
      for i,line in ipairs(lines) do
        w = 1
        for char=1,unicode.len(line) do
          if unicode.sub(line,char-1,char-1) == "&" then
            if unicode.lower(unicode.sub(line,char,char)) == "0" then
              gpu.setForeground(0x000000)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "1" then
              gpu.setForeground(0x0000AA)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "2" then
              gpu.setForeground(0x00AA00)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "3" then
              gpu.setForeground(0x00AAAA)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "4" then
              gpu.setForeground(0xAA0000)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "5" then
              gpu.setForeground(0xAA00AA)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "6" then
              gpu.setForeground(0xFFAA00)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "7" then
              gpu.setForeground(0xAAAAAA)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "8" then
              gpu.setForeground(0x555555)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "9" then
              gpu.setForeground(0x5555FF)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "a" then
              gpu.setForeground(0x55FF55)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "b" then
              gpu.setForeground(0x55FFFF)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "c" then
              gpu.setForeground(0xFF5555)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "d" then
              gpu.setForeground(0xFF55FF)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "e" then
              gpu.setForeground(0xFFFF55)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "f" then
              gpu.setForeground(0xFFFFFF)
            end
          end
          if unicode.sub(line,char-1,char-1) == "#" then
            if unicode.lower(unicode.sub(line,char,char)) == "0" then
              gpu.setBackground(0x000000)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "1" then
              gpu.setBackground(0x0000AA)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "2" then
              gpu.setBackground(0x00AA00)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "3" then
              gpu.setBackground(0x00AAAA)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "4" then
              gpu.setBackground(0xAA0000)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "5" then
              gpu.setBackground(0xAA00AA)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "6" then
              gpu.setBackground(0xFFAA00)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "7" then
              gpu.setBackground(0xAAAAAA)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "8" then
              gpu.setBackground(0x555555)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "9" then
              gpu.setBackground(0x5555FF)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "a" then
              gpu.setBackground(0x55FF55)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "b" then
              gpu.setBackground(0x55FFFF)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "c" then
              gpu.setBackground(0xFF5555)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "d" then
              gpu.setBackground(0xFF55FF)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "e" then
              gpu.setBackground(0xFFFF55)
            end
            if unicode.lower(unicode.sub(line,char,char)) == "f" then
              gpu.setBackground(0xFFFFFF)
            end
          end
          if (unicode.sub(line,char,char) ~= "&") and (unicode.sub(line,char,char) ~= "#") then
            if (unicode.sub(line,char-1,char-1) ~= "&") and (unicode.sub(line,char-1,char-1) ~= "#") then
              gpu.set(7+w,i,unicode.sub(line,char,char))
              w = w + 1
            end
          end
        end
      end
      gpu.bind(defaultscreen)
    end
    i = i + 1
  end
end

listScreens()
io.write("выберите экран для отображения:")
addr = io.read()
bindScreen(addr)
