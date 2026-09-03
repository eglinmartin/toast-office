-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Cat = Class{__includes = Entity}


function Cat:init(scene, x, y)
    Entity.init(self, scene, "cat", {x=x, y=y, w=16, h=14, s=1, r=0, sprite_sheet="cat", sprite_tag="sleep", animation_speed=0.1, depth=64, hoverable=true, draggable=true})
    scene.engine:register_entity("cat", self)
end


function Cat:move_left()
    self.held_left = true
end


function Cat:move_right()
    self.held_right = true
end


function Cat:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Cat:on_hover_start()
    Entity.on_hover_start(self)
end


function Cat:on_hover_end()
    Entity.on_hover_end(self)
end


function Cat:on_drag_start()
    Entity.on_drag_start(self)
    self.engine.flux.to(self, 0.25, {scale_x=1.2, scale_y=1.2}):ease("expoout")
    self.sprite_tag = "idle"
    self:create_sprite()
end


function Cat:on_drag_end()
    Entity.on_drag_end(self)
    self.sprite_tag = "sleep"
    self.engine.flux.to(self, 0.25, {scale_x=1, scale_y=1, y=self.y+1, depth=self.original_depth}):ease("expoout")
    self:create_sprite()
end


function Cat:drag()
    Entity.drag(self)
    self:create_sprite()
end


function Cat:draw()
    Entity.draw(self)
end


return Cat
