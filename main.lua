-- pour écrire dans la console au fur et à mesure, facilitant ainsi le débogage
io.stdout:setvbuf('no')
require('const')
require('func/ini')

local debug = false

local defaultSpeed = 7
local debloc= {d=false, g=false, h=false, b=false}
local Tserial = require('func/TSerial')
local anim8 = require('anim8-master/anim8')
local winWidth
local winHeight
local tileset
local tilesets = {
    ["classic"] = love.graphics.newImage("img/tileset/classic.png"),
    ["neige"] = love.graphics.newImage("img/tileset/neige2.png"),
    ["plage"] = love.graphics.newImage("img/tileset/plage.png")
  }
local mapTable
local Q = {}
local basicTiles = love.graphics.newImage("img/tileset/tlst.png")
local conv = {b=false, n=0}
local conv2 = {b=false, n=0}
local actDir = "bas"
local pixelMedium = love.graphics.newFont('fonts/jouli.ttf', 30)
local normalMedium = love.graphics.newFont(20)
local font = {pixel={medium=pixelMedium}, normal={medium=normalMedium}}
local menu = false
local QS192
local QS96
local montureQ = MontureQuads(80)
local animationMonture = {}
local montureBoolean = false
local perso
local animation = {}
local animationActuelle = {}
local mapAnimations = {}
local bool = {move = false, ani = {G = false, D = false, AR = false, AV = false}}
local KEY = ""
local bordureX
local bordureY
local imagePerso
local imagePersoActuelle
local posMap = {x=0, y=0}
local jump = {can = false, bol = true, jump = 0, goal = 0, frame = 0, pushed = false}
local plat = {value = 0, pushed = 0}

local runTimer = {start=0, finish=0}

function math.ceil(n)
  return math.floor(n + 0.5)
end
function Save()
  local objectToSave = {perso = perso, posMap = posMap}
  love.filesystem.write('game.sav', Tserial.pack(objectToSave) )
end
local timer = {t=0, b=true}
local initAnims = function ()
  mapAnimations = {}
  for i=1, #mapTable.animations do
    local limage = mapTable.animations[i].src 
    local g = anim8.newGrid(mapTable.animations[i].w, mapTable.animations[i].h, limage:getWidth(), limage:getHeight())
    local num = limage:getWidth() / mapTable.animations[i].w
    local ani = anim8.newAnimation(g('1-'..num, 1), mapTable.animations[i].time)
    local obj = {img=limage, x=mapTable.animations[i].x, y=mapTable.animations[i].y, animation = ani}
    table.insert(mapAnimations, obj)
  end
end

function Reset()
  love.filesystem.remove('game.sav')
  perso = {localisation='e', name="Faith", fname="Rudo", rx=420, ry=420, speed=defaultSpeed}
  timer.b = false
  posMap.x = 0
  posMap.y = 0
  mapTable = require('map/m'..perso.localisation..posMap.x..'_'..posMap.y) -- on charge la bonne map
  tileset = tilesets[mapTable.tileset]
  timer.t = love.timer.getTime( )
  initAnims()
  local objectToSave = {perso = perso, posMap = posMap}
  love.filesystem.write('game.sav', Tserial.pack(objectToSave) )
  animationActuelle = animation
  imagePersoActuelle = imagePerso
  montureBoolean = false
  menu = false
  runTimer.start = love.timer.getTime()
end

function EndRun()
  if runTimer.start == 0 then
    return
  end
  runTimer.finish = love.timer.getTime()
  local totalTime = runTimer.finish - runTimer.start
  print(totalTime)
  runTimer.start = 0
end

local changeMap = {
  
  gauche = function ()
    if timer.b == true then
      timer.b = false
      posMap.x = posMap.x-1
      mapTable = require('map/m'..perso.localisation..posMap.x..'_'..posMap.y) -- on charge la bonne map
      perso.rx = 1344-20
      tileset = tilesets[mapTable.tileset]
      timer.t = love.timer.getTime( )
      initAnims()
    end
  end
  ,
  droite = function ()
    if timer.b == true then
      timer.b = false
      posMap.x = posMap.x+1
      mapTable = require('map/m'..perso.localisation..posMap.x..'_'..posMap.y) -- on charge la bonne map
      perso.rx = 20
      tileset = tilesets[mapTable.tileset]
      timer.t = love.timer.getTime( )
      initAnims()
    end
  end
  ,
  haut = function ()
    if timer.b == true then
      timer.b = false
      posMap.y = posMap.y-1
      mapTable = require('map/m'..perso.localisation..posMap.x..'_'..posMap.y) -- on charge la bonne map
      perso.ry = 768-20
      tileset = tilesets[mapTable.tileset]
      timer.t = love.timer.getTime()
      initAnims()
    end
  end
  ,
  bas = function ()
    if timer.b == true then
      timer.b = false
      posMap.y = posMap.y+1
      mapTable = require('map/m'..perso.localisation..posMap.x..'_'..posMap.y) -- on charge la bonne map
      perso.ry = 20
      tileset = tilesets[mapTable.tileset]
      timer.t = love.timer.getTime( )
      initAnims()
    end
  end
  
  }


local collision = function (dir, dif)
  if dif == nil then
    dif = 0
  end
  local ligne
  local colonne
  if dir == "bas" then
    ligne = (math.ceil((perso.rx+25) / 32))
    colonne = (math.ceil((perso.ry+17+dif) / 32))
    if colonne > 24 then
      return true 
    end
    if timer.b == true then
      if mapTable.collisions[colonne] ~= nil then
        if mapTable.collisions[colonne][ligne] ~= nil then
          if mapTable.collisions[colonne][ligne] ~= 2 then
            return false
          end
        end
      end
    end
    ligne = (math.ceil((perso.rx+40) / 32))
  end
  if dir == "haut" then
    ligne = (math.ceil((perso.rx+25) / 32))
    colonne = (math.floor((perso.ry-0+dif) / 32))
    if colonne < 1 then
      return true 
    end
    if timer.b == true then
      if mapTable.collisions[colonne] ~= nil then
        if mapTable.collisions[colonne][ligne] ~= nil then
          if mapTable.collisions[colonne][ligne] ~= 2 then
            return false
          end
        end
      end
    end
    ligne = (math.ceil((perso.rx+40) / 32))
  end
  if dir == "gauche" then
    ligne = (math.floor((perso.rx+25) / 32))
    colonne = (math.ceil((perso.ry+13+dif) / 32))
    if ligne < 1 then
      return true 
    end
    if timer.b == true then
      if mapTable.collisions[colonne] ~= nil then
        if mapTable.collisions[colonne][ligne] ~= nil then
          if mapTable.collisions[colonne][ligne] ~= 2 then
            return false
          end
        end
      end
    end
    colonne = (math.ceil((perso.ry-13+dif) / 32))
  end
  if dir == "droite" then
    ligne = (math.ceil((perso.rx+50) / 32)) 
    colonne = (math.ceil((perso.ry+13+dif) / 32))
    if ligne > 42 then
      return true 
    end
    if timer.b == true then
      if mapTable.collisions[colonne] ~= nil then
        if mapTable.collisions[colonne][ligne] ~= nil then
          if mapTable.collisions[colonne][ligne] ~= 2 then
            return false
          end
        end
      end
    end
    colonne = (math.ceil((perso.ry-13+dif) / 32))
  end
  if timer.b == false then 
    return false
  end
  if timer.b == true then
    if ligne < 1 or colonne < 1 or ligne > 42 or colonne > 24 then
      return true
    end
    if mapTable.collisions[colonne] ~= nil then
      if mapTable.collisions[colonne][ligne] ~= nil then
        if mapTable.collisions[colonne][ligne] ~= 2 then
          return false
        end
      end
    end
  end
  return true
end

function love.load()
  -- Fonction pour initialiser le jeu (appelée au début de celui-ci)
  local _, _, flags = love.window.getMode() 
  -- The window's flags contain the index of the monitor it's currently in.
  winWidth, winHeight = love.window.getDesktopDimensions(flags.display)  
  
  bordureX = ((winWidth-1344)/2)
  bordureY = ((winHeight-768)/2)
  love.window.setMode(winWidth, winHeight)
  --love.window.setMode(winWidth-(bordureX*2), winHeight-(bordureY*2)) -- Change les dimensions de la fenêtre
--bordureX =0
--bordureY =0
  Q = IniQ()
  QS192 = IniQS192()
  QS96 = IniQS96()
  imagePerso = { sprite = love.graphics.newImage("sprites/rudo.png"), frame = QS96.AV[1]}
  imagePersoActuelle = imagePerso
  perso = {localisation='e', name="Faith", fname="Rudo", rx=420, ry=420, speed=defaultSpeed}
  
  if love.filesystem.getInfo('game.sav') == nil then
    perso.ry = 500
    local objectToSave = {perso = perso, posMap = posMap}
    love.filesystem.write('game.sav', Tserial.pack(objectToSave) )
  else
    --objectToSave = {perso = perso, posMap = {x=1, y=0}}
    --love.filesystem.write('game.sav', Tserial.pack(objectToSave) )
    local gameInfos = Tserial.unpack( love.filesystem.read( 'game.sav' ) )
    perso = gameInfos.perso
    posMap = gameInfos.posMap
  end
  MenuImage = love.graphics.newImage("img/menu.png")
  mapTable = require('map/m'..perso.localisation..posMap.x..'_'..posMap.y) -- on charge la bonne map
  tileset = tilesets[mapTable.tileset]
  
  -- animation CHANGER SELON LE SPRITE
  animation.G = anim8.newAnimation({QS96.G[2], QS96.G[1], QS96.G[3], QS96.G[1]},  {0.2, 0.2, 0.2, 0.2})
  animation.D = anim8.newAnimation({QS96.D[2], QS96.D[1], QS96.D[3], QS96.D[1]}, {0.2, 0.2, 0.2, 0.2})
  animation.AV = anim8.newAnimation({QS96.AV[2],QS96.AV[3]}, 0.2)
  animation.AR = anim8.newAnimation({QS96.AR[2],QS96.AR[3]}, 0.2)
  animationActuelle = animation
  -- animation de monture
  animationMonture.G = anim8.newAnimation({montureQ.G[2], montureQ.G[1], montureQ.G[3], montureQ.G[1]},  {0.2, 0.2, 0.2, 0.2})
  animationMonture.D = anim8.newAnimation({montureQ.D[2], montureQ.D[1], montureQ.D[3], montureQ.D[1]}, {0.2, 0.2, 0.2, 0.2})
  animationMonture.AV = anim8.newAnimation({montureQ.AV[2], montureQ.AV[3]}, 0.2)
  animationMonture.AR = anim8.newAnimation({montureQ.AR[2], montureQ.AR[3]}, 0.2)
  initAnims()
end

function love.update(dt)
  for i=1, #mapTable.tp do
    if mapTable.tp[i].x == (math.floor((perso.rx+15) / 32)) then
      if mapTable.tp[i].y == (math.ceil((perso.ry+4) / 32)) then
        perso.rx = mapTable.tp[i].change.x * 32 + 32
        perso.ry = mapTable.tp[i].change.y * 32
        if mapTable.tp[i].change.b == true then
          mapTable = require(mapTable.tp[i].change.src)
          initAnims()
        end
      end
    end
  end
  for i=1, #mapAnimations do
    mapAnimations[i].animation:update(dt)
  end
  if (menu==false and conv.b==false) then
    
    animationActuelle.G:update(dt)
    animationActuelle.D:update(dt)
    animationActuelle.AV:update(dt)
    animationActuelle.AR:update(dt)
    
    if timer.t > 0 then
      if (love.timer.getTime() - timer.t) > 0.01 then
        timer.b = true
        timer.t = 0
      end
    end
    for numX=1, #mapTable.zone do 
      if (mapTable.zone[numX].x1 < perso.rx and mapTable.zone[numX].x2 > perso.rx and mapTable.zone[numX].y1 < perso.ry and mapTable.zone[numX].y2 > perso.ry) then
        if mapTable.zone[numX].conv[1] ~= "none" then 
          if mapTable.zone[numX].bloquant == true then
            conv.conv = mapTable.zone[numX]
            conv.b = true
            conv.n = 1
          else
            conv2.conv = mapTable.zone[numX]
            conv2.b = true
            conv2.n = 1
          end
        end
        if (mapTable.zone[numX].monture.b == true) then
          if mapTable.zone[numX].monture.src ~= "root" then
            montureBoolean = true
            if mapTable.zone[numX].monture.taille == 1 then
              montureBoolean = false
              animationActuelle = animation
              imagePersoActuelle = {sprite = love.graphics.newImage(mapTable.zone[numX].monture.src), frame = QS96.AV[1]}
            elseif mapTable.zone[numX].monture.taille == 2 then
              animationActuelle = animationMonture
              imagePersoActuelle = {sprite = love.graphics.newImage(mapTable.zone[numX].monture.src), frame = montureQ.AV[1]}
            end
            perso.speed = mapTable.zone[numX].monture.speed
          else 
            montureBoolean = false
            imagePersoActuelle = imagePerso
            animationActuelle = animation
            perso.speed = defaultSpeed
          end
        end
      else
        conv2.b = false
      end
    end
    if mapTable.mapType == "rpg" then
      if love.keyboard.isDown('left', 'q') and collision("gauche")==true then
        if bool.ani.G == false then
          bool.ani.G = true
        end
        bool.move = true
        KEY = "G"
        debloc.g = true
        debloc.d = false
        debloc.h = false
        debloc.b = false
        perso.rx = perso.rx - math.floor(perso.speed*dt*40)
        if  perso.rx < 10 then 
          changeMap.gauche()
        end
      elseif love.keyboard.isDown('right', 'd') and collision("droite")==true then
        if bool.ani.D == false then 
          bool.ani.D = true
        end
        KEY = "D"
        debloc.g = false
        debloc.d = true
        debloc.h = false
        debloc.b = false
        bool.move = true
        perso.rx = perso.rx + math.floor(perso.speed*dt*40)
        if  perso.rx > (1344-10) then 
          changeMap.droite()
        end
      elseif love.keyboard.isDown('up', 'z') and collision("haut")==true then
        if bool.ani.AR == false then 
          bool.ani.AR = true
        end
        bool.move = true
        KEY = "AR"
        debloc.g = false
        debloc.d = false
        debloc.h = true
        debloc.b = false
        perso.ry = perso.ry - math.floor(perso.speed*dt*40)
        if perso.ry < 10 then 
          changeMap.haut()
        end
      elseif love.keyboard.isDown('down', 's') and collision("bas")==true then
        if bool.ani.AV == false then 
          bool.ani.AV = true
        end
        bool.move = true
        KEY = "AV"
        debloc.g = false
        debloc.d = false
        debloc.h = false
        debloc.b = true
        perso.ry = perso.ry + math.floor(perso.speed*dt*40)
        if perso.ry > (768-10) then 
          changeMap.bas()
        end
      end


    elseif mapTable.mapType == "platformer" then
      -- platformer controls are here
      if love.keyboard.isDown('up', 'z', 'space') and collision("haut")==true and love.keyboard.isDown('right', 'd') then
        if jump.can and jump.pushed == false then
          jump.pushed = true
          jump.bol = true
          jump.goal = 20
          jump.jump = 10
          jump.can = false
          perso.ry = perso.ry - 10
        end
        plat.pushed = plat.pushed + 1
        plat.value = 42
      elseif love.keyboard.isDown('up', 'z', 'space') and collision("haut")==true and love.keyboard.isDown('left', 'q') then
        if jump.can and jump.pushed == false then
          jump.pushed = true
          jump.bol = true
          jump.goal = 20
          jump.jump = 10
          jump.can = false
          perso.ry = perso.ry - 10
        end
        plat.pushed = plat.pushed + 1
        plat.value = -42
      elseif love.keyboard.isDown('up', 'z', 'space') and collision("haut")==true then
        if jump.can and jump.pushed == false then
          jump.pushed = true
          jump.bol = true
          jump.goal = 20
          jump.jump = 10
          jump.can = false
          perso.ry = perso.ry - 10
        end
      elseif love.keyboard.isDown('right', 'd') then
        plat.pushed = plat.pushed + 1
        plat.value = 42
      elseif love.keyboard.isDown('left', 'q') then
        plat.pushed = plat.pushed + 1
        plat.value = -42
      elseif love.keyboard.isDown('down', 's') and collision("bas")==true then
        
      end

      if collision("haut", 0) == true then
        jump.frame = jump.frame + 1

        if jump.can == false then
          if jump.frame % 1 == 0  then --every 3 frames
            if jump.bol then
              jump.can = false -- make sure that user cant do an easy double jump
              if jump.jump < jump.goal then
                jump.jump = jump.jump + 2
              else 
                jump.bol = false
              end
            else
              if jump.jump > 0 then
                jump.jump = jump.jump - 2
              else
                jump.bol = true
                jump.jump = 0
                jump.goal = 0   --reset jump settings
              end
            end
          end
        end
        perso.ry = perso.ry - jump.jump
      else 
        jump.bol = true
        jump.jump = 0
        jump.goal = 0
        jump.can = false
      end

      if plat.value < 0 then                      -- go left or right if user pushed the keys
        if collision("gauche", -5)==true then
          if bool.ani.G == false then
            bool.ani.G = true
          end
          bool.move = true
          KEY = "G"
          debloc.g = true
          debloc.d = false
          debloc.h = false
          debloc.b = false
          perso.rx = perso.rx - math.floor(perso.speed*dt*40)
          if  perso.rx < 10 then 
            changeMap.gauche()
          end
        end
      elseif plat.value > 0 then
        if collision("droite", -5)==true then
          if bool.ani.D == false then 
            bool.ani.D = true
          end
          KEY = "D"
          debloc.g = false
          debloc.d = true
          debloc.h = false
          debloc.b = false
          bool.move = true
          perso.rx = perso.rx + math.floor(perso.speed*dt*40)
          if  perso.rx > (1344-10) then 
            changeMap.droite()
          end
        end
      end

      local i = 0
      while i < 7 do
        if collision("bas", -3)==true then
          perso.ry = perso.ry + 1        
          jump.can = false -- if the user falls he can't jump
          if perso.ry > (768-10) then 
            changeMap.bas()
          end
          if perso.ry < 10 then 
            changeMap.haut()
          end
        else 
          if jump.jump == 0 then
            jump.can = true -- if the user is down then he can jump again
          end
        end
        i = i+1
      end
    end
  end
end

function love.draw()
  -- Fonction pour dessiner (appelée à chaque frame)
  for rowIndex=1, #mapTable.map do
    local row = mapTable.map[rowIndex]
    for columnIndex=1, #row do
      local number = row[columnIndex]
      if number ~= 0 then
        if number < 0 then
          local newN = number * -1
          love.graphics.draw(basicTiles, Q[newN], ((columnIndex-1)*32)+bordureX, ((rowIndex-1)*32)+bordureY)
        else
          love.graphics.draw(tileset, Q[number], ((columnIndex-1)*32)+bordureX, ((rowIndex-1)*32)+bordureY)
        end
      end
    end
  end
  
  if debug == true then
    love.graphics.setColor(255,0,0)
    love.graphics.setFont(font.normal.medium)
    love.graphics.print('___________________'..posMap.x..' / '..posMap.y..'____'..perso.rx..' / '..(perso.ry)..'_____')
    love.graphics.setColor(255,255,255)
  end
  
  for i=1, #mapTable.decors do
    if ((mapTable.decors[i].y*32)-(mapTable.decors[i].height/2)) <= perso.ry then
      love.graphics.draw(mapTable.decors[i].src, (mapTable.decors[i].x*32)+bordureX, (mapTable.decors[i].y*32)+bordureY-mapTable.decors[i].height)
    end
  end
  
  for i=1, #mapAnimations do
    if ((mapAnimations[i].y*32)+(mapAnimations[i].img:getHeight())/2) <= perso.ry then
      mapAnimations[i].animation:draw(mapAnimations[i].img, mapAnimations[i].x*32+bordureX, mapAnimations[i].y*32+bordureY)
    end
  end
  
  for i=1, #mapTable.persos do
    if mapTable.persos[i].y*32 <= perso.ry-0 then
      local frame
      if mapTable.persos[i].dir == "b" then
        frame = QS96.AV[1]
      elseif mapTable.persos[i].dir == "h" then
        frame = QS96.AR[1]
      elseif mapTable.persos[i].dir == "d" then
        frame = QS96.D[1]
      elseif mapTable.persos[i].dir == "g" then
        frame = QS96.G[1]
      end
      love.graphics.draw(mapTable.persos[i].sprite, frame, (mapTable.persos[i].x*32)+bordureX, (mapTable.persos[i].y*32)+bordureY-50)
    end
  end
  
  if bool.move == false then
    love.graphics.draw(imagePersoActuelle.sprite, imagePersoActuelle.frame, perso.rx+bordureX, perso.ry-50+bordureY) --on utilise pas l'animation, on dessine une image statique
  else
    if KEY == "G" then
      animationActuelle.G:draw(imagePersoActuelle.sprite, perso.rx+bordureX, perso.ry-50+bordureY)
    elseif KEY == "D" then
      animationActuelle.D:draw(imagePersoActuelle.sprite, perso.rx+bordureX, perso.ry-50+bordureY)
    elseif KEY == "AV" then
      animationActuelle.AV:draw(imagePersoActuelle.sprite, perso.rx+bordureX, perso.ry-50+bordureY)
    elseif KEY == "AR" then
      animationActuelle.AR:draw(imagePersoActuelle.sprite, perso.rx+bordureX, perso.ry-50+bordureY)
    end
  end
  
  for i=1, #mapTable.decors do
    if ((mapTable.decors[i].y*32)-(mapTable.decors[i].height/2)) > perso.ry then
      love.graphics.draw(mapTable.decors[i].src, (mapTable.decors[i].x*32)+bordureX, (mapTable.decors[i].y*32)+bordureY-mapTable.decors[i].height)
    end
  end
  
  for i=1, #mapAnimations do
    if ((mapAnimations[i].y*32)+(mapAnimations[i].img:getHeight())/2) > perso.ry then
      mapAnimations[i].animation:draw(mapAnimations[i].img, mapAnimations[i].x*32+bordureX, mapAnimations[i].y*32+bordureY)
    end
  end
  
  for i=1, #mapTable.persos do 
    if mapTable.persos[i].y*32 > perso.ry-0 then
      local frame
      if mapTable.persos[i].dir == "b" then
        frame = QS96.AV[1]
      elseif mapTable.persos[i].dir == "h" then
        frame = QS96.AR[1]
      elseif mapTable.persos[i].dir == "d" then
        frame = QS96.D[1]
      elseif mapTable.persos[i].dir == "g" then
        frame = QS96.G[1]
      end
      love.graphics.draw(mapTable.persos[i].sprite, frame, (mapTable.persos[i].x*32)+bordureX, (mapTable.persos[i].y*32)+bordureY-50)
    end
  end  
  
  if menu == true then
    love.graphics.setFont(font.pixel.medium)
    
    love.graphics.setColor(169,208,245, 128)
    love.graphics.rectangle("fill", bordureX, bordureY, 1344, 768)
    love.graphics.setColor(0,0,0, 128)
    love.graphics.rectangle("fill", bordureX+(1344/2)-150, bordureY+(768/2)-150, 300, 300)
    
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", bordureX+(1344/2)-150+20, bordureY+(768/2)-150+20, 300-40, 30)
    love.graphics.setColor(180,180,180)
    love.graphics.print("Sauvegarder", bordureX+(1344/2)-150+20+5, bordureY+(768/2)-150+20)
    
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", bordureX+(1344/2)-150+20, bordureY+(768/2)-150+60, 300-40, 30)
    love.graphics.setColor(180,180,180)
    love.graphics.print("Commencer une run", bordureX+(1344/2)-150+20+5, bordureY+(768/2)-150+60)
    
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", bordureX+(1344/2)-150+20, bordureY+(768/2)-150+100, 300-40, 30)
    love.graphics.setColor(180,180,180)
    love.graphics.print("Quit (esc)", bordureX+(1344/2)-150+20+5, bordureY+(768/2)-150+100)
    
    love.graphics.setColor(0,0,0)
    love.graphics.print("Le menu est ouvert : ", bordureX+20, bordureY+700)
    love.graphics.setColor(255,255,255)
  end
  love.graphics.draw(MenuImage, 0+bordureX, 0+bordureY)
  
  if conv.b == true then
    love.graphics.setFont(font.pixel.medium)
    love.graphics.setColor(102,93,11, 220)
    love.graphics.rectangle("fill", bordureX, 768+bordureY-100, 1344, 100)
    love.graphics.setColor(0,0,0)
    if conv.conv.name == "" then
      love.graphics.print(conv.conv.conv[conv.n], bordureX+20, 768+bordureY-80)
    else
      love.graphics.print(conv.conv.name.." : "..conv.conv.conv[conv.n], bordureX+20, 768+bordureY-80)
    end
    love.graphics.setColor(255,255,255)
  end
  
  if conv2.b == true then
    love.graphics.setFont(font.pixel.medium)
    love.graphics.setColor(102,93,11, 220)
    love.graphics.rectangle("fill", bordureX, 768+bordureY-100, 1344, 100)
    love.graphics.setColor(0,0,0)
    if conv2.conv.name == "" then
      love.graphics.print(conv2.conv.conv[conv2.n], bordureX+20, 768+bordureY-80)
    else
      love.graphics.print(conv2.conv.name.." : "..conv2.conv.conv[conv2.n], bordureX+20, 768+bordureY-80)
    end
    love.graphics.setColor(255,255,255)
  end
end

function love.keypressed(key)
  -- Fonction pour gérer l'appui sur les touches (appelée pour chaque touche pressée)  
  if key == "escape" then
    love.event.quit() -- Pour quitter le jeu
  end
  if key == "right" or key == "d" then
    actDir = "droite"
  end
  if key == "left" or key == "q" then
    actDir = "gauche"
  end
  if key == "up" or key == "z" then
    actDir = "haut"
  end
  if key == "down" or key == "s" then
    actDir = "bas"
  end
  if key == "x" then
    if menu == false then
      menu = true
    else
      menu = false
    end
  end
  if key == "c" then
    if conv.b == false then
      local actions = function(ligne, colonne) 
        if ligne < 1 or colonne < 1 or ligne > 42 or colonne > 24 then
          return 0
        end
        for numX=1, #mapTable.interaction do 
          if mapTable.interaction[numX].x == ligne and mapTable.interaction[numX].y == colonne then
            conv.conv = mapTable.interaction[numX]
            conv.b = true
            conv.n = 1
            if (mapTable.interaction[numX].monture.b == true) then
              
              if mapTable.interaction[numX].monture.src ~= "root" then
                montureBoolean = true
                if mapTable.interaction[numX].monture.taille == 1 then
                  montureBoolean = false
                  animationActuelle = animation
                  imagePersoActuelle = {sprite = love.graphics.newImage(mapTable.interaction[numX].monture.src), frame = QS96.AV[1]}
                elseif mapTable.interaction[numX].monture.taille == 2 then
                  animationActuelle = animationMonture
                  imagePersoActuelle = {sprite = love.graphics.newImage(mapTable.interaction[numX].monture.src), frame = montureQ.AV[1]}
                end
                perso.speed = mapTable.interaction[numX].monture.speed
              else 
                montureBoolean = false
                imagePersoActuelle = imagePerso
                animationActuelle = animation
                perso.speed = defaultSpeed
              end
            end
          end
        end
        
        for numX2=1, #mapTable.persos do 
          if mapTable.persos[numX2].x == ligne-1 and mapTable.persos[numX2].y == colonne then
            if actDir == "bas" then
              mapTable.persos[numX2].dir = "h"
            elseif actDir == "haut" then
              mapTable.persos[numX2].dir = "b"
            elseif actDir == "droite" then
              mapTable.persos[numX2].dir = "g"
            elseif actDir == "gauche" then
              mapTable.persos[numX2].dir = "d"
            end
            conv.conv = mapTable.persos[numX2]
            conv.b = true
            conv.n = 1
            if conv.conv.name == "DEV" then
              EndRun()
            end 
          end
        end
        if conv.b then
          return 1
        else
          return 0
        end
      end
      local ligne
      local colonne
      if actDir == "bas" then
        ligne = (math.ceil((perso.rx+25) / 32))
        colonne = (math.ceil((perso.ry+20) / 32))
        if actions(ligne, colonne) == 0 then
          ligne = (math.ceil((perso.rx+40) / 32))
          actions(ligne, colonne)
        end
      elseif actDir == "haut" then
        ligne = (math.ceil((perso.rx+25) / 32))
        colonne = (math.floor((perso.ry-5) / 32))
        if actions(ligne, colonne) == 0 then
          ligne = (math.ceil((perso.rx+40) / 32))
          actions(ligne, colonne)
        end
      elseif actDir == "gauche" then
        ligne = (math.floor((perso.rx+25) / 32))
        colonne = (math.ceil((perso.ry+15) / 32))
        if actions(ligne, colonne) == 0 then
          colonne = (math.ceil((perso.ry-15) / 32))
          actions(ligne, colonne)
        end
      elseif actDir == "droite" then
        ligne = (math.ceil((perso.rx+50) / 32))
        colonne = (math.ceil((perso.ry+15) / 32))
        if actions(ligne, colonne) == 0 then
          colonne = (math.ceil((perso.ry-15) / 32))
          actions(ligne, colonne)
        end
      end
      
    else
      if conv.n < #conv.conv.conv then
        conv.n = conv.n + 1
      else
        conv.b = false
      end
    end
  end
end
function love.keyreleased(key)
  if conv.b == false then
     if key == 'left' or key == 'q' then
      bool.move = false
      if debloc.g == true then
        perso.rx = perso.rx+1
      end
      if montureBoolean == false then
        imagePersoActuelle.frame = QS96.G[1]
      else
        imagePersoActuelle.frame = montureQ.G[1]
      end
    elseif key == 'right' or key == 'd' then
      bool.move = false
      if debloc.d == true then
        perso.rx = perso.rx -1
      end
      if montureBoolean == false then
        imagePersoActuelle.frame = QS96.D[1]
      else
        imagePersoActuelle.frame = montureQ.D[1]
      end
    elseif key == 'up' or key == 'z' or key == 'space' then
      jump.pushed = false
      bool.move = false
      if debloc.h == true then
        perso.ry = perso.ry +1
      end
      if montureBoolean == false then
        imagePersoActuelle.frame = QS96.AR[1]
      else
        imagePersoActuelle.frame = montureQ.AR[1]
      end
    elseif key == 'down' or key == 's' then
      bool.move = false
      if debloc.b == true then
        perso.ry = perso.ry -1
      end
      if montureBoolean == false then
        imagePersoActuelle.frame = QS96.AV[1]
      else
        imagePersoActuelle.frame = montureQ.AV[1]
      end
    end
  end


  if mapTable.mapType == "platformer" then
    if key == 'down' or key == 's' then

    elseif key == 'up' or key == 'z' or key == 'space' then

    elseif key == 'right' or key == 'd' then
      plat.pushed = plat.pushed -1
      plat.value = 0
    elseif key == 'left' or key == 'q' then
      plat.pushed = plat.pushed -1
      plat.value = 0
    end
  end
end
function love.mousepressed(x, y, button)
  if x<100+bordureX and y < 100+bordureY then
    if menu==false then
      menu = true
    else 
      menu = false
    end
  elseif menu==true then
    --bordureX+(1344/2)-150+20, bordureY+(768/2)-150+20, 300-40, 30
    if x>bordureX+(1344/2)-150+20 and x<bordureX+(1344/2)-150+20+260 then
      if y>bordureY+(768/2)-150+20 and y<bordureY+(768/2)-150+20+30 then
        Save()
      elseif y>bordureY+(768/2)-150+60 and y<bordureY+(768/2)-150+60+30 then
        Reset()
      elseif y>bordureY+(768/2)-150+100 and y<bordureY+(768/2)-150+100+30 then
        love.event.quit() -- Pour quitter le jeu
      end
    else
      --if x> and x< and y> and y< then
      menu = false
    end
  end
end
function love.mousereleased(x, y, button)
  
end
