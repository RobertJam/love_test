-- this file is parsed by love2D before initialization of the engine
-- is complete.
-- this is the place for global configuration parameters
function love.conf(t)
   t.title = "love2D test game"
   t.window.width = 800
   t.window.height = 600
   -- force debug console display
   t.console = true
end
