local Class = require("hatchling.engine.lib.class")
local Game = Class{}


function Game:init(engine)
    self.engine = engine

    self:load_fonts()
    self.engine.render_manager.shadow_offset = {8, 8}
    self.engine.render_manager.shadow_colour = {9/255, 10/255, 20/255}
end


function Game:load_fonts()
end


function Game:update(dt)
end


return Game
