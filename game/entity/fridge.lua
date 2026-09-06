-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Fridge = Class{__includes = Entity}


function Fridge:init(scene, x, y)
    Entity.init(self, scene, "fridge", {
        x=x,
        y=y,
        w=15,
        h=19,
        s=1,
        r=0,
        sprite_sheet="fridge",
        sprite_tag="shut",
        animation_speed=1,
        depth=20
    })
    scene.engine:register_entity("fridge", self)
    self.hovered = false
    self.open = false
end


function Fridge:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


return Fridge
