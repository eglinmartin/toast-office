-- toast.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Toast = Class{__includes = Entity}


function Toast:init(scene)
    Entity.init(self, scene, "toast", {x=0, y=0, w=15, h=19, s=1, r=0, sprite_sheet="bread_stack", sprite_tag="1", animation_speed=1, depth=19})
    scene.engine:register_entity("oven", self)
    self.hovered = false
    self.open = false

    self.cooked = 1
    self.buttered = false

    self.toppings = {}
end


function Toast:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


return Toast
