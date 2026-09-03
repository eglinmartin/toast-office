local Class = require("hatchling.engine.lib.class")
local Scene = require("hatchling.engine.class.scene")

local Cat = require("game.entity.cat")
local Player = require("game.entity.player")

local GameScene = Class{__includes = Scene}


function GameScene:init(game, engine)
    Scene.init(self, game, engine)
end


function GameScene:enter()
    Scene.enter(self)
    self:setup_keybinds()
    self:setup_events()

    self.camera_xy = {120, 71}

    self.engine:add_background("sky", "sky", "sky", self.camera_xy[1], self.camera_xy[2], 1, 0, 0)

    -- self.engine:add_sprite("lamp", "lamp", "lamp", self.camera_xy[1] - 32.5, self.camera_xy[2] + 10.5, 1, 0, 8)
    self.engine:add_sprite("hedge", "hedge", "hedge", self.camera_xy[1] - 25.5, self.camera_xy[2] + 32, 1, 0, 4)
    self.engine:add_sprite("tree_left", "tree_left", "tree_left", self.camera_xy[1] - 43.5, self.camera_xy[2] +0.5, 1, 0, 5)
    self.engine:add_sprite("fence", "fence", "fence", self.camera_xy[1] - 45.5, self.camera_xy[2] + 35, 1, 0, 6)

    self.engine:add_sprite("toast_box", "toast_box", "toast_box", self.camera_xy[1] -21.5, self.camera_xy[2] + 30.5, 1, 0, 10)
    self.engine:add_sprite("phone_box", "phone_box", "phone_box", self.camera_xy[1] -2, self.camera_xy[2] + 26, 1, 0, 10)

    self.engine:add_sprite("ground", "ground", "ground", self.camera_xy[1], self.camera_xy[2] + 64.5, 1, 0, 16)
    
    self.engine:add_sprite("house", "house", "house", self.camera_xy[1] + 57.5, self.camera_xy[2] + 9.5, 1, 0, 18)
    self.engine:add_sprite("kitchen", "kitchen", "kitchen", self.camera_xy[1] + 58.5, self.camera_xy[2] + 29, 1, 0, 19)
    
    self.engine:add_sprite("tree_right", "tree_right", "tree_right", self.camera_xy[1] + 109, self.camera_xy[2] + 11.5, 1, 0, 21)
    self.engine:add_sprite("shrub_right", "shrub_right", "shrub_right", self.camera_xy[1] + 107.5, self.camera_xy[2] + 30, 1, 0, 22)

    self.engine:add_sprite("menu_base", "menu", "menu", self.camera_xy[1]+30.5, self.camera_xy[2]-3, 1, 0, 200)

    self.cat = Cat(self, self.camera_xy[1]-21, self.camera_xy[2]+22)
    self.engine:register_entity(self.cat)
    
    self.player = Player(self, 136, 103)
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
    self.engine:create_keybind(self, "left", "MOVE_LEFT")
    self.engine:create_keybind(self, "a", "MOVE_LEFT")
    self.engine:create_keybind(self, "right", "MOVE_RIGHT")
    self.engine:create_keybind(self, "d", "MOVE_RIGHT")
end


function GameScene:update(dt, mx, my, md, mp)
    local door_x = 147
    if self.player.x < door_x and not self.engine.render_manager.draw_objects_foreground["house_front"] then
        self.engine:add_sprite("house_front", "house_front", "house_front", self.camera_xy[1] + 51, self.camera_xy[2] + 23.5, 1, 0, 40)
    elseif self.player.x >= door_x and self.engine.render_manager.draw_objects_foreground["house_front"] then
        self.engine.render_manager.draw_objects_foreground["house_front"] = nil
    end
end


return GameScene
