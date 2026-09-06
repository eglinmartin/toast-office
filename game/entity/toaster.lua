-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Toaster = Class{__includes = Entity}


function Toaster:init(scene, x, y)
    Entity.init(self, scene, "toaster", {
        x=x,
        y=y,
        w=15,
        h=19,
        s=1,
        r=0,
        sprite_sheet="toaster",
        sprite_tag="done",
        animation_speed=1,
        depth=20
    })
    scene.engine:register_entity("toaster", self)
    self.hovered = false
    self.open = false
end


function Toaster:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


return Toaster
