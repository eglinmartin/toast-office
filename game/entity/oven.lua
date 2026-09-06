-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Oven = Class{__includes = Entity}


function Oven:init(scene, x, y)
    Entity.init(self, scene, "oven", {
        x=x,
        y=y,
        w=15,
        h=19,
        s=1,
        r=0,
        sprite_sheet="oven",
        sprite_tag="oven",
        animation_speed=1,
        depth=20
    })
    scene.engine:register_entity("oven", self)
    self.hovered = false
    self.open = false
end


function Oven:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


return Oven
