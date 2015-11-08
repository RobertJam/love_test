-- program entry point

shipImg = nil
asteroidImg = nil
bulletImg = nil
player = {x = 100,y = 100,
          rot = 0,size = 0.3,
          accx = 100.0,accy=100.0,
          vx = 0,vy = 0,
          score = 0,
          shootTimer = 0}
rockList = {}
bulletSpeed = 500
shootDelay = 0.2
minRockSize = 0.3
bulletList = {}
pewSound = nil
boomSound = nil

function rand_range(min,max)
   return love.math.random()*(max-min)+min
end
function normalize(x,y)
   local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end
end
function dist(a,b)
   return ((b.x-a.x)^2+(b.y-a.y)^2)^0.5
end

function create_rock()
   rock = {x = love.math.random() * love.window.getWidth(),
           y = love.math.random() * love.window.getHeight(),
           rot = 0,
           size = rand_range(0.5,0.8),
           vx = rand_range(-20,20),
           vy = rand_range(-20,20),
           vrot = rand_range(-0.5,0.5)}
   table.insert(rockList,rock)
   return rock
end

function touch_rock(rockIndex,nrocks)
   rock = rockList[rockIndex]
   rockX = rock.x
   rockY = rock.y
   rockVx = rock.vx
   rockVy = rock.vy
   if rock.size > 0.4 then
      for i=1,nrocks do
         newRock = create_rock()
         newRock.size = rock.size/2
         newRock.x = rockX
         newRock.y = rockY
         newRock.vx = rockVx + love.math.random()*rockVy
         newRock.vy = rockVy + love.math.random()*rockVx
      end
   end
   player.score = player.score + math.floor(rock.size * 1000)
   table.remove(rockList,rockIndex)
   boomSound:rewind()
   boomSound:play()
end

function create_bullet(posX,posY,dirX,dirY)
   bullet = {x = posX, y = posY,
             vx = dirX*bulletSpeed,vy = dirY*bulletSpeed,
             lifetime = 3.0}
   table.insert(bulletList,bullet)
   pewSound:rewind()
   pewSound:play()
end

function wrap_borders(obj,w,h)
   if (obj.x+w) < 0 then obj.x = love.window.getWidth() end
   if (obj.y+h) < 0 then obj.y = love.window.getHeight() end
   if obj.x > love.window.getWidth() then obj.x = 0 end
   if obj.y > love.window.getHeight() then obj.y = 0 end
end

-- called when the game starts
function love.load(arg)
   shipImg = love.graphics.newImage("spaceship.png")
   asteroidImg = love.graphics.newImage("asteroid.png")
   bulletImg = love.graphics.newImage("bullet.tga")
   pewSound = love.audio.newSource("pew.wav")
   boomSound = love.audio.newSource("explosion.wav")
   for i=1,5 do
      create_rock()
   end
end

-- update a frame
function love.update(dt)
   -- direction of ship
   mouseX,mouseY = love.mouse.getPosition()
   player.rot = math.atan2(mouseY-player.y,mouseX-player.x) + math.pi/2
   dirX,dirY = normalize(mouseX-player.x,mouseY-player.y)
   -- accelerate ship
   if love.mouse.isDown('l') then
      player.vx = player.vx + dirX*player.accx*dt
      player.vy = player.vy + dirY*player.accy*dt
   end
   -- shoot things
   player.shootTimer = player.shootTimer - dt
   if player.shootTimer < 0 then player.shootTimer = 0 end
   if love.mouse.isDown('r') and player.shootTimer == 0 then
      create_bullet(player.x,player.y,dirX,dirY)
      player.shootTimer = shootDelay
   end
   -- move stuff
   player.x = player.x + player.vx*dt
   player.y = player.y + player.vy*dt
   for i=1,#rockList do
      rock = rockList[i]
      rock.x = rock.x + rock.vx*dt
      rock.y = rock.y + rock.vy*dt
      rock.rot = rock.rot + rock.vrot*dt
   end
   for i=1,#bulletList do
      bullet = bulletList[i]
      bullet.x = bullet.x + bullet.vx*dt
      bullet.y = bullet.y + bullet.vy*dt
      bullet.lifetime = bullet.lifetime - dt
   end
   for i=#bulletList,1,-1 do
      if bulletList[i].lifetime <= 0 then
         table.remove(bulletList,i)
      end
   end
   -- wrap around on screen borders
   wrap_borders(player,shipImg:getWidth(),shipImg:getHeight())
   for i=1,#rockList do
      wrap_borders(rockList[i],asteroidImg:getWidth(),asteroidImg:getHeight())
   end
   for i=1,#bulletList do
      wrap_borders(bulletList[i],bulletImg:getWidth(),bulletImg:getHeight())
   end
   -- check for collisions
   for i=#rockList,1,-1 do
      rock = rockList[i]
      for j=#bulletList,1,-1 do
         bullet = bulletList[j]
         if dist(rock,bullet) < asteroidImg:getWidth()*rock.size*0.5 then
            print("BOOM")
            touch_rock(i,3)
            table.remove(bulletList,j)
            break
         end
      end
   end
end

-- draw a frame
function love.draw()
   for i=1,#rockList do
      rock = rockList[i]
      love.graphics.draw(asteroidImg,rock.x,rock.y,rock.rot,rock.size,rock.size,
                         asteroidImg:getWidth()/2,asteroidImg:getHeight()/2)
   end
   for i=1,#bulletList do
      bullet = bulletList[i]
      love.graphics.draw(bulletImg,bullet.x,bullet.y,0,0.5,0.5,
                         bulletImg:getWidth()/2,bulletImg:getHeight()/2)
   end
   love.graphics.draw(shipImg,player.x,player.y,player.rot,player.size,player.size,
                      shipImg:getWidth()/2,shipImg:getHeight()/2)
   love.graphics.print("Score " .. player.score,10,10)
end
