-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Order = Class{__includes = Entity}


local STATE = {
    NEW = 'new',
    OPEN = 'open'
}


function Order:init(scene, x, y, id)
    Entity.init(self, scene, 'order_' .. id, {
        x=x,
        y=y,
        w=40,
        h=16,
        s=1,
        r=0,
        sprite_sheet="mail",
        sprite_tag="new",
        animation_speed=1,
        depth=215 + id,
        hoverable=true,
        clickable=true
    })
    scene.engine:register_entity('order_' .. id, self)
    self.state = STATE.NEW
end


function Order:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Order:open()
    self.state = STATE.OPEN
    self.sprite_tag = "open"
    self:create_sprite()
end


function Order:on_hover_start()
    Entity.on_hover_start(self)
    self.engine.flux.to(self, 0.25, {scale_x=1.1, scale_y=1.1}):ease("expoout")
    self:create_sprite()
end


function Order:on_hover_end()
    Entity.on_hover_end(self)
    self.engine.flux.to(self, 0.25, {scale_x=1, scale_y=1}):ease("expoout")
    self:create_sprite()
end


function Order:on_drag_start()
    Entity.on_drag_start(self)
    self:create_sprite()
end


function Order:on_click()
    Entity.on_click(self)
    self.scale_x = 0.9
    self.scale_y = 0.9
    self.engine.flux.to(self, 0.25, {scale_x=1, scale_y=1}):ease("expoout")
    self.hoverable=false
    self.clickable=false
    self:open()
end


function Order:on_drag_end()
    Entity.on_drag_end(self)
    self.sprite_tag = "sleep"
    self.engine.flux.to(self, 0.25, {scale_x=1, scale_y=1, y=self.y+1, depth=self.original_depth}):ease("expoout")
    self:create_sprite()
end


function Order:drag()
    Entity.drag(self)
    self:create_sprite()
end


function Order:draw()
    Entity.draw(self)
end


return Order
