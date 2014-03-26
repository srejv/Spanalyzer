Class = require "hump.class"
PrettyPrint = require 'PrettyPrint'

Queue = Class {
  init = function(self, size)
    self.size = size
    self.buffer = {}
  end,
  size = 0,
  front = 1,
  back = 1,
  currentSize = 0
}
function Queue:pop()
    if self.currentSize == 0 then
      return nil
    end
    local v = self.buffer[self.front]
    self.front = self.front + 1
    self.currentSize = self.currentSize - 1
    if self.front > self.size then
      self.front = 1
    end
    return v
end

function Queue:push(obj)
    if self.currentSize >= self.size-1 then
      return
    end
    obj.obj = Player (obj.obj.img, obj.obj.x, obj.obj.y)
    table.insert(self.buffer, self.back, obj)
    self.back = self.back + 1
    self.currentSize = self.currentSize + 1

    if(self.back > self.size) then
      self.back = 1
    end
end

function Queue:head()
  if self.currentSize == 0 then
    return nil
  end
  return self.buffer[self.front]
end

function Queue:update()

end

function Queue:draw()
  local g = love.graphics
  g.setColor(255,255,255,127)
  local base = self.buffer[1]
  local prev = base.obj

  for i,v in ipairs(self.buffer) do
    if i > 1 then
      v.obj.x = prev.x
      v.obj.y = prev.y
      v.obj:update(v.dt)
      prev = v.obj
    end
    v.obj:draw()

  end
  g.setColor(255,255,255,255)
end


Images = Class{
  init = function(self)
  end,
  map = {}
}
function Images:add(key, image)
  self.map[key] = image
end
function Images:get(key)
  return self.map[key]
end
function Images:remove(key)
  self.map[key] = nil
end
function Images:clear()
  self.map = {}
end

Player = Class {
  init = function(self, img,x,y )
    self.img = img
    self.x = x
    self.y = y
  end,
  img = 'name',
  x = 0,y = 0,
  speed = 140
}
function Player:update(dt)
    self.x = self.x + self.speed * 1 * dt
end
function Player:draw()
    love.graphics.draw(imglib:get(self.img), self.x, self.y)
end


Frame = Class{
  init = function(self, n, events, obj, dt)
    self.n = n
    self.events = events
    self.obj = obj
    self.dt = dt
  end,
  n = 0,
  events = nil,
  obj = nil,
  dt = 0,
}


function love.load()
  str = "Hello World"
  love.window.setTitle('test')

  imglib = Images()
  imglib:add('planet', love.graphics.newImage('hjm-big_gas_planet.png'))

  prayer = Player('planet', 20, 20)
  px = 0

  q = Queue(240)
  f = Frame(1, {}, prayer, 0)

  isPaused = false
end

function love.update(dt)
	require("lurker").update()
  if not  isPaused then
    prayer:update(dt)
  end
end

function love.draw()
	love.graphics.print(str, 400, 300)

  if isPaused then
    q:draw()
  else
    prayer:draw()
  end

end

function love.keypressed(key, u)
  if key == 'up' or key == 'down' then
    str = key
  end
  if key == ' ' then
    isPaused = true
  end
end


function love.run()

    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.event then
        love.event.pump()
    end

    if love.load then love.load(arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0
    local sumdt = 0
    local numStep = 0
    local stepsPerSecond = 12
    local timePerStep = 1/stepsPerSecond
    local lastTime = 0
    local stepEvents = {}
    local frameToAdd = {}
    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            stepEvents = {}
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
                table.insert(stepEvents, {e,a,b,c,d})
            end
        end

        -- Update dt, as we'll be passing it to update
        dt = 0
        if love.timer then
            love.timer.step()
            dt = love.timer.getAverageDelta()
            sumdt = sumdt + dt
        end

        if sumdt >= timePerStep then
          -- Call update and draw
          if love.update then love.update(sumdt) end -- will pass 0 if love.timer is disabled
          if not isPaused then
            frameToAdd = Frame(numStep, stepEvents, prayer, sumdt)
            q:push(frameToAdd)
            --prettyOutput = PrettyPrint( f )
            --print(prettyOutput)
            numStep = numStep + 1;
          end
          sumdt = sumdt - timePerStep;
        end

        if love.window and love.graphics and love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.print(numStep, 5, 5)

            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end

end
