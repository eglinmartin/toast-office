-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Board = Class{__includes = Entity}


function Board:init(scene, x, y)
    Entity.init(self, scene, "board", {
        x=x,
        y=y,
        w=15,
        h=19,
        s=1,
        r=0,
        sprite_sheet="board",
        sprite_tag="board",
        animation_speed=1,
        depth=20
    })
    scene.engine:register_entity("board", self)
    self.hovered = false
    self.open = false
end


function Board:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


return Board
