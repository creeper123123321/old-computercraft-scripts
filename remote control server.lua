pass = "123"
precisasenha = true
whitelist = false
idsaceitos = {3,5}
blacklist = {4}

mdm = false
for k,v in pairs(redstone.getSides()) do
 if peripheral.getType(v) == "modem" then
   rednet.open(v)
   mdm = true
 end
end
 
if not mdm then
  error("Nenhum modem detectado, coloque em qualquer lado")
end

id = 0
idac = {}
hist = {}

old = {}

function sendclients(a)
  table.insert(hist,a)
  for i2=1,#idac do
    rednet.send(idac[i2],a)
  end
end

old.termwrite = term.write
term.write = function(msg)
  sendclients({"term.write",msg})
  old.termwrite(msg)
end
old.termclear = term.clear
term.clear = function()
  sendclients({"term.clear"})
  old.termclear()
end
old.termclearLine = term.clearLine
term.clearLine = function()
  sendclients({"term.clearLine"})
  old.termclearLine()
end
old.termsetCursorPos = term.setCursorPos
term.setCursorPos = function(x,y)
  sendclients({"term.setCursorPos",x,y})
  old.termsetCursorPos(x,y)
end
old.termsetCursorBlink = term.setCursorBlink
term.setCursorBlink = function(valor)
  sendclients({"term.setCursorBlink",valor})
  old.termsetCursorBlink(valor)
end
old.termscroll = term.scroll
term.scroll = function(nume)
  sendclients({"term.scroll",nume})
  old.termscroll(nume)
end
old.termsetTextColor = term.setTextColor
term.setTextColor = function(tcid)
  sendclients({"term.setTextColor",tcid})
  old.termsetTextColor(tcid)
end
term.setTextColour = term.setTextColor
old.termsetBackgroundColor = term.setBackgroundColor
term.setBackgroundColor = function(bcid)
  sendclients({"term.setBackgroundColor",bcid})
  old.termsetBackgroundColor(bcid)
end
term.setBackgroundColour = term.setBackgroundColor

function writeend(...)
  local w,h = term.getSize()
  local x,y = term.getCursorPos()
  term.setCursorPos(1,h)
  term.clearLine()
  write(...)
  term.setCursorPos(x,y)
end

term.clear()
term.setCursorPos(1,1)
print("RemoteControl server versao: WIP 0.1.8")
print("feito por creeper123123321")

rcmd = function()
  while true do
    local id,msg = rednet.receive()
    if msg[1] == "key" 
      or msg[1] == "char"
      or msg[1] == "mouse_click"
      or msg[1] == "mouse_scroll"
      or msg[1] == "mouse_drag"
      or msg[1] == "mouse_up" then
      for i15=1,#idac do
        if id == idac[i15] then
          os.queueEvent(msg[1],msg[2],msg[3],msg[4])
          break
        end
      end
    elseif msg == "request" then
      writeend(id.." esta tentando estabelecer uma conexao")
      whitelisted = false
      if whitelist then
        for num, key in ipairs(idsaceitos) do
          if id == key then
            whitelisted = true
            break
          end
        end
      else
        whitelisted = true
      end
      for num, key in ipairs(blacklist) do
        if key == id then
          whitelisted = false
          break
        end
      end
      if whitelisted then
        aceitar = false
        if precisasenha then
          rednet.send(id,"senha")
          idpass, msgpass = rednet.receive(60)
          if msgpass == pass and idpass == id then
            aceitar = true
          else
            writeend(idpass.." recusado")
          end
        else
          aceitar = true
          rednet.send(id,"naoprecisasenha")
        end
        if aceitar then
          rednet.send(id ,"accepted")
          writeend(id.." foi aceito!")
          table.insert(idac,id)
          for ihist=1,#hist do
            rednet.send(id,hist[ihist])
          end
        end
      else
        writeend(id.." foi ignorado")
      end
    elseif msg == "ping" then
      rednet.send(id,"pong")
    end
  end
end
rcshell = function()
  shell.run("shell")
end

pingtestsv = function()
  while true do
    sleep(10)
    for iping=1,#idac do
      rednet.send(idac[iping],"ping")
      if rednet.receive(0.2) == nil then
        writeend("O cliente "..idac[iping].." nao esta respondendo!")
        table.remove(idac,iping)
      end
    end
  end
end

certo,infoerro = pcall(function() parallel.waitForAny(rcmd,rcshell,pingtestsv) end)
if not certo then
  term.clear()
  print("ERRO:")
  printError(infoerro)
end
print("Servidor encerrado.")
term.write = old.termwrite
term.clear = old.termclear
term.clearLine = old.termclearLine
term.setCursorPos = old.termsetCursorPos
term.setCursorBlink = old.termsetCursorBlink
term.scroll = old.termscroll
term.setTextColor = old.termsetTextColor
term.setTextColour = old.termsetTextColour
term.setBackgroundColor = old.termsetBackgroundColor
term.setBackgroundColour = old.termsetBackgroundColour
old = nil
