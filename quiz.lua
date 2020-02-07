--  
--  General Public License v3.0
--  Developer: Dev1lroot (c) 2020
--  Mods: Open Computers, Computronics, OpenCommandBlock
--  Developed special for McSkill
--

--
--  Includes
--
local os = require("os")
local com = require("component")
local cmd = com.opencb
local event = require("event")
local sides = require("sides")
local shell = require("shell")
local box = com.chat_box
box.setDistance(128)

--
-- Predefinitions
--
questionnow = 1;
questions={}
winners={}

local function bc(q)
  if q ~= nil then
    cmd.execute("bc &6"..q)
  end
end

local function ask(q)
  if q ~= nil then
    box.setName("§4ВОПРОС§7")
    box.say("§a"..q)
  end
end

local function ans(q)
  if q ~= nil then
    box.setName("§4ВИКТОРИНА§7")
    box.say("§a"..q)
  end
end

local function getTheBestOf(array)
  top = "";
  val = 1
  for i,player in ipairs(array) do
    if player[2] > val then
      val = player[2]
      top = player[1]
    end
  end
  return top
end

local function excludePlayer(array,username)
  for i,player in ipairs(array) do
    if player[1] == username then
      table.remove(array,i)
    end
  end
  return array
end

local function getTrio()
  len = 0
  first = ""
  second = ""
  third = ""
  for i,kek in ipairs(winners) do
    len = len + i
  end
  if len >= 1 then
    first = getTheBestOf(winners)
  end
  if len >= 2 then
    tier2 = excludePlayer(winners,first)
    second = getTheBestOf(tier2)
  end
  if len >= 3 then
    tier3 = excludePlayer(winners,second)
    third = getTheBestOf(tier3)
  end
  win = "Победители: "
  if first ~= "" then
    cmd.execute("money give "..first.." 100")
    cmd.execute("w "..first.." &aВы получили &b100 &aэмов")
    win = win .. "&d" .. first
  end
  if second ~= "" then
    cmd.execute("money give "..second.." 75")
    cmd.execute("w "..second.." &aВы получили &b75 &aэмов")
    win = win .. "&a, &d" .. second
  end
  if third ~= "" then
    cmd.execute("money give "..third.." 50")
    cmd.execute("w "..third.." &aВы получили &b50 &aэмов")
    win = win .. "&a и &d" .. third
  end
  ans(win)
end

local function addPoint(username)
  is = 0
  for i,user in ipairs(winners) do
    if user[1] == username then
      is = i
    end
  end
  if is == 0 then
    user = {}
    table.insert(user,username)
    table.insert(user,1)
    table.insert(winners,user)
  else
    winners[is][2] = winners[is][2] + 1
  end
end

local function strsplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local function doOnEvent(event, ...)
  local id, user, msg = ...
  if string.match(string.lower(msg),questions[questionnow][2]) then
    ans("§b"..user.." §aответил верно!")
    addPoint(user)
    os.sleep(1)
    questionnow = questionnow + 1
    if questions[questionnow] ~= nil then
      ask(questions[questionnow][1])
    else
      getTrio()
      ans("ивент окончен")
      event.ignore('chat_message', doOnEvent)
    end
  end
end

--
-- QuestionList Syntax
--
-- question1:answer1;
-- question2:answer2;
-- question3:answer3;
--

local function getQuestionList()
  io.write("Перед тем как работать, убедитесь что рядом никого нет\n")
  io.write("Вставьте список при помощи INSERT: ")
  query = io.read()
  rows = strsplit(query,";")
  for i,row in ipairs(rows) do
    question = {}
    table.insert(question, strsplit(row,":")[1])
    table.insert(question, strsplit(row,":")[2])
    table.insert(questions, question)
  end
  shell.execute("cls")
  io.write("Список экстраполирован, ивент готов к работе\n")
    io.write("Напишите Y/n чтобы использовать или не использовать броадкаст или CTRL+ALT+C для отмены\n")
  x = io.read()
  if string.lower(x) == "y" then
    shell.execute("cls")
    io.write("Броадкастинг викторины запущен")
    bc("До запуска викторины осталось &b10 минут")
    os.sleep(300)
    bc("До запуска викторины осталось &b5 минут")
    os.sleep(300)
    bc("Викторина началась, поехали!")
    io.write("Броадкастинг викторины завершен")
    os.sleep(5)
  else
    io.write("Броадкастинг отменен")
  end
end

local function doStart()
  getQuestionList()
  io.write("Ивент начат!\n")
  io.write("Нажмите ENTER чтобы прекратить\n")
  event.listen('chat_message', doOnEvent)
  ask(questions[questionnow][1])
  x = io.read()
  event.ignore('chat_message', doOnEvent)
end

doStart()
