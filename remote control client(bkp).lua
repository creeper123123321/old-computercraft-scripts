--bkp
print("RemoteControl client versao: WIP 0.1.6")
print("feito por creeper123123321")
print("Para sair do programa aperte [F12]")
mdm = false
for k,v in pairs(redstone.getSides()) do
 if peripheral.getType(v) == "modem" then
   rednet.open(v)
   mdm = true
 end
end

certo = true
if mdm == false then
  error("Nenhum modem detectado. Coloque em qualquer lado")
end

PcControlledID = {...}
rcv = function()
  while true do
    id,msg = rednet.receive()
    if id == idc then
      if msg[1] == "term.write" then
        term.write(msg[2])
      elseif msg[1] == "term.clear" then
        term.clear()
      elseif msg[1] == "term.clearLine" then
        term.clearLine()
      elseif msg[1] == "term.setCursorPos" then
        term.setCursorPos(msg[2],msg[3])
      elseif msg[1] == "term.setCursorBlink" then
        if msg[2] == "true" then
          term.setCursorBlink(true)
        elseif msg[2] == "false" then
          term.setCursorBlink(false)
        end
      elseif msg[1] == "term.scroll" then
        term.scroll(msg[2])
      elseif msg[1] == "term.setBackgroundColor" then
        bcol = msg[2]
        if term.isColor() then
          term.setBackgroundColor(bcol)
        elseif bcol == colors.white or bcol == colors.black or bcol == colors.gray then
          term.setBackgroundColor(bcol)
        else
          term.setBackgroundColor(colors.lightGray)
        end
      elseif msg[1] == "term.setTextColor" then
        tcol = msg[2]
        if term.isColor() then
          term.setTextColor(tcol)
        elseif tcol == colors.white or tcol == colors.black or tcol == colors.gray then
          term.setTextColor(tcol)
        else
          term.setTextColor(colors.lightGray)
        end
      elseif msg == "ping" then
        rednet.send(id,"pong")
      end
    end
  end
end
event_hand = function()
  while true do
    event,code1,code2,code3 = os.pullEvent()
    if event == "key" then
      rednet.send(idc,{event,code1,code2})
    elseif event == "char" then
      rednet.send(idc,{event,code1})
    elseif event == "mouse_click" then
      rednet.send(idc,{event,code1,code2,code3})
    elseif event == "mouse_scroll" then
      rednet.send(idc,{event,code1,code2,code3})
    elseif event == "mouse_drag" then
      rednet.send(idc,{event,code1,code2,code3})
    elseif event == "mouse_up" then
      rednet.send(idc,{event,code1,code2,code3})
    end
  end
end

pingtestcnt = function()
  online = true
  while online do
    sleep(10)
    rednet.send(idc,"ping")
    if rednet.receive(1) == nil then
      online = false
      print("O servidor "..idc.." parou de responder!")
    end
  end
end

sairprograma = function()
  looping = true
  while looping do
    eventosair, codigosair = os.pullEvent("key")
    if codigosair == keys.f12 then
      looping = false
    end
  end
end

if PcControlledID[1] == nil then
  print("Uso: <nome do programa> <id do server>")
else
  idc = tonumber(PcControlledID[1])
  rednet.send(tonumber(PcControlledID[1]),"request")
  id,msg = rednet.receive(0.2)
  if msg == "senha" then
    term.write("Digite a senha do host: ")
    rednet.send(idc,read("*"))
  end
  id, volta = rednet.receive(0.2)
  if id == idc and volta == "accepted" then
    term.clear()
    term.setCursorBlink(true)
    certo,infoerro = pcall(function() parallel.waitForAny(rcv,event_hand,pingtestcnt,sairprograma) end)
  elseif id == idc then
    print("[Servidor] "..volta)
  else
    print("O server nao respondeu!")
  end
end
if not certo then
  term.clear()
  print("ERRO:")
  printError(infoerro)
end
