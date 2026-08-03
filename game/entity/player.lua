-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Player = Class{__includes = Entity}


function Player:init(scene, x, y)
    Entity.init(self, scene, "player", {x=x, y=y, w=16, h=16, s=1, r=0, sprite_sheet="player", sprite_tag="player", animation_speed=0.1, depth=128, moveable=true})
    scene.engine:register_entity("player", self)
    self.base_y = y

    self:set_sine_wave('rotation', {amplitude = 10, frequency = 1.25})
    self:set_sine_wave('y', {amplitude = 1, frequency = 2.5})

    self.walking = false
    self.walking_momentum = 0
end


function Player:move_left()
    self.held_left = true
    self.walking = true
    self:start_sine_wave('rotation')
    self:start_sine_wave('y')

    if self.scale_x ~= -1 then
        self:rescale_x(-1)
    end

    if self.walking_momentum > -0.5 then
        self.walking_momentum = self.walking_momentum - 0.1
    end
end


function Player:move_right()
    self.held_right = true
    self.walking = true
    self:start_sine_wave('rotation')
    self:start_sine_wave('y')

    if self.scale_x ~= 1 then
        self:rescale_x(1)
    end

    if self.walking_momentum < 0.5 then
        self.walking_momentum = self.walking_momentum + 0.1
    end
end


function Player:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)

    self.x = self.x + self.walking_momentum

    -- if we were walking but neither move function fired this frame, stop
    if self.walking and not (self.held_left or self.held_right) then
        self:stop_sine_wave('rotation')
        self:stop_sine_wave('y')
        self.walking = false
    else
        if self.walking_momentum >= -0.05 and self.walking_momentum <= 0.05 then
            self.walking_momentum = 0
        elseif self.walking_momentum > 0.05 then
            self.walking_momentum = self.walking_momentum - 0.05
        elseif self.walking_momentum < -0.05 then
            self.walking_momentum = self.walking_momentum + 0.05
        end
    end

    -- reset for next frame; move_left/move_right will re-set these if still held
    self.held_left = false
    self.held_right = false
    self.scene.engine.flux.to(self, 0.25, {y=self.base_y, rotation=0})
end


function Player:draw()
    Entity.draw(self)
end


return Player
