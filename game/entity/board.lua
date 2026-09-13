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

    self.loaf = nil
    self.num_slices_in_loaf = 0
    self.slices = 0
end


function Board:add_loaf(loaf_hp)
    self.loaf = loaf_hp
    self.num_slices_in_loaf = loaf_hp
    self.engine:add_sprite('bread_loaf', 'bread_loaf', tostring(4 - self.loaf), 134, 96, 1, 0, 24)
    self.engine.flux.to(self.engine.render_manager.draw_objects_foreground['bread_loaf'], 0.5, {y=97}):ease("expoout")
end


function Board:chop_slice()
    self.slices = self.slices + 1

    if self.loaf then
        self.loaf = self.loaf - 1
        if self.loaf == 0 then
            self:remove_loaf()
        end

        if self.slices > 0 and self.slices <= self.num_slices_in_loaf then
            if self.loaf and self.loaf > 0 then
                self.engine:add_sprite('bread_loaf', 'bread_loaf', tostring(4 - self.loaf), 135, 97, 1, 0, 24)
                self.engine.flux.to(self.engine.render_manager.draw_objects_foreground['bread_loaf'], 0.5, {x=134}):ease("expoout")
            else
                self.engine.render_manager.draw_objects_foreground['bread_loaf'] = nil
            end
            self.engine:add_sprite('bread_stack', 'bread_stack', tostring(self.slices), 133, 95, 1, 0, 25)
            self.engine.flux.to(self.engine.render_manager.draw_objects_foreground['bread_stack'], 0.5, {y=96}):ease("expoout")
        end
    end
end


function Board:remove_loaf()
    self.loaf = nil
end


function Board:remove_slices()
    self.slices = 0
    self.engine.render_manager.draw_objects_foreground['bread_stack'] = nil
end


function Board:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


return Board
