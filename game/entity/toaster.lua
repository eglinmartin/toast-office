local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Toaster = Class{__includes = Entity}


function Toaster:init(scene, x, y, flux)
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
        depth=23
    })
    scene.engine:register_entity("toaster", self)
    self.hovered = false
    self.flux = flux
    self.engine = scene.engine

    self.bread = 0
    self.bread_y = 0

    self.slots = 1

    self.toasting = false
    self.toast_time = 5
    self.toast_progress = 0
    self.engine:add_sprite("toaster_dial", "toaster_dial", "toaster_dial", self.x - 3, self.y + self.bread_y, 1, 0, 24)
end


function Toaster:add_bread()
    self.bread = 1
    self.bread_y = -1
    self.flux.to(self, 0.25, {bread_y=0}):ease("expoout")
    self.engine:add_sprite("toaster_bread", "bread", "untoasted", self.x, self.y + self.bread_y, 1, 0, 22)
end


function Toaster:toast_bread()
    if self.toasting or self.bread == 0 then
        return
    end
    self.toasting = true

    self.flux.to(self, self.toast_time, {toast_progress = 1})
        :ease("linear")
        :oncomplete(function()
            self:pop_up()
        end)

    self.flux.to(self, 0.1, {bread_y=2}):ease("expoout")

    self.toast_progress = 0
    self.sprite_tag = "cooking"
    self:create_sprite()
end


function Toaster:pop_up()
    self.toasting = false
    self.toast_timer = nil
    self.sprite_tag = "done"
    self:create_sprite()
    self.engine:add_sprite("toaster_bread", "bread", "toaster", self.x, self.y + self.bread_y, 1, 0, 22)

    self.bread_y = -2
    self.flux.to(self, 0.25, {bread_y=0}):ease("expoout")
end


function Toaster:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
    self.engine.render_manager.draw_objects_foreground["toaster_dial"].y = self.y + self.bread_y - 1
    if self.engine.render_manager.draw_objects_foreground["toaster_bread"] then
        self.engine.render_manager.draw_objects_foreground["toaster_bread"].y = self.y + self.bread_y - 3
    end
end


return Toaster