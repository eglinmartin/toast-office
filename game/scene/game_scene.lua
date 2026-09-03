-- Import from Hatchling
local Class = require("hatchling.engine.lib.class")
local Scene = require("hatchling.engine.class.scene")

-- Load entities
local Cat = require("game.entity.cat")
local Player = require("game.entity.player")

-- Create scene
local GameScene = Class{__includes = Scene}

-- Set constants
local CX, CY = 120, 71
local DOOR_X = CX + 27


function GameScene:init(game, engine)
    Scene.init(self, game, engine)
end


function GameScene:enter()
    Scene.enter(self)
    self:setup_keybinds()
    self:setup_events()

    -- Set up camera

    -- Create scene sprites
    local scene_sprites = {
        {"hedge",       -25.5,  32,     1,  0,  4},
        {"tree_left",   -43.5,  0.5,    1,  0,  5},
        {"fence",       -45.5,  35,     1,  0,  6},
        {"toast_box",   -21.5,  30.5,   1,  0,  10},
        {"phone_box",   -2,     26,     1,  0,  10},
        {"ground",      0,      64.5,   1,  0,  16},
        {"house",       57.5,   9.5,    1,  0,  18},
        {"kitchen",     58.5,   29,     1,  0,  19},
        {"tree_right",  109,    11.5,   1,  0,  21},
        {"shrub_right", 107.5,  30,     1,  0,  22},
    }
    for _, p in ipairs(scene_sprites) do
        self.engine:add_sprite(p[1], p[1], p[1], CX + p[2], CY + p[3], p[4], p[5], p[6])
    end
    self.engine:add_background("sky", "sky", "sky", CX, CY, 1, 0, 0)
    self.engine:add_sprite("menu_base", "menu", "menu", CX+30.5, CY-3, 1, 0, 200)

    -- Initialize cat
    self.cat = Cat(self, CX-21, CY+22)
    self.engine:register_entity(self.cat)
    
    -- Initialize player
    self.player = Player(self, CX+16, CY+32)
end


function GameScene:trigger(trigger_id)
end


function GameScene:setup_events()
    self.engine.event_manager:on(self.engine.event_manager.events["MOVE_LEFT"], self, function()
        self.player:move_left()
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["MOVE_RIGHT"], self, function()
        self.player:move_right()
    end)
end


function GameScene:setup_keybinds()
    self.engine:create_keybind(self, "a", "MOVE_LEFT")
    self.engine:create_keybind(self, "d", "MOVE_RIGHT")
end


function GameScene:update(dt, mx, my, md, mp)
    if self.player.x < DOOR_X and not self.engine.render_manager.draw_objects_foreground["house_front"] then
        self.engine:add_sprite("house_front", "house_front", "house_front", CX + 51, CY + 23.5, 1, 0, 40)
    elseif self.player.x >= DOOR_X and self.engine.render_manager.draw_objects_foreground["house_front"] then
        self.engine.render_manager.draw_objects_foreground["house_front"] = nil
    end
end


return GameScene
