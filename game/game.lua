local Class = require("hatchling.engine.lib.class")
local Game = Class{}
local GameScene = require("game.scene.game_scene")


function Game:init(hatchling)
    self.hatchling = hatchling

    self:load_fonts()
    self.hatchling.render_manager.shadow_offset = {1, 1}
    self.hatchling.render_manager.shadow_colour = {9/255, 10/255, 20/255}

    self.hatchling:add_scene("GAME", GameScene(self, self.hatchling))
    self.hatchling:switch_scene("GAME")
end


function Game:load_fonts()
end


function Game:update(dt)
end


return Game
