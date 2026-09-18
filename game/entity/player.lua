-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Player = Class{__includes = Entity}

local INTERACT_OFFSET = 5.5


function Player:init(scene, x, y)
    Entity.init(self, scene, "player", {x=x, y=y, w=16, h=16, s=1, r=0, sprite_sheet="player", sprite_tag="player", animation_speed=0.1, depth=128, moveable=true})
    scene.engine:register_entity("player", self)
    self.base_y = y

    self:set_sine_wave('rotation', {amplitude = 10, frequency = 2.5})
    self:set_sine_wave('y', {amplitude = 1, frequency = 5})

    self.bread = 0
    self.money = 0

    self.facing = 1
    self.interact_x = self.x

    self.walking = false
    self.walking_momentum = 0

    self.hand_front = Entity(self, "hand_front", {x=x, y=x, w=8, h=12, s=1, r=0, sprite_sheet="hand", sprite_tag="empty", depth=132})
    scene.engine:register_entity("hand_front", self.hand_front)
    self.hand_back = Entity(self, "hand_back", {x=x, y=x, w=8, h=12, s=1, r=0, sprite_sheet="hand", sprite_tag="empty", depth=126})
    scene.engine:register_entity("hand_back", self.hand_back)

    self.carrying = "empty"
    self.hand_back:rescale_x(-1)
    self.hand_back:create_sprite()
    self.hand_front.sprite_tag = self.carrying
    self.hand_front:create_sprite()
end


function Player:update_carrying(item)
    self.carrying = item
    if self.facing == 1 then
        self.hand_front.sprite_tag = self.carrying
        self.hand_front:create_sprite()
        self.hand_back.sprite_tag = "empty"
        self.hand_back:create_sprite()
    elseif self.facing == -1 then
        self.hand_front.sprite_tag = "empty"
        self.hand_front:create_sprite()
        self.hand_back.sprite_tag = self.carrying
        self.hand_back:create_sprite()
    end
end


function Player:move_left()
    self.held_left = true
    self.facing = -1
    self.walking = true

    self:start_sine_wave('rotation')
    self:start_sine_wave('y')

    self:update_carrying(self.carrying)

    if self.scale_x ~= -1 then
        self:rescale_x(-1)
    end

    if self.walking_momentum > -1 then
        self.walking_momentum = self.walking_momentum - 0.2
    end
end


function Player:move_right()
    self.held_right = true
    self.facing = 1
    self.walking = true

    self:start_sine_wave('rotation')
    self:start_sine_wave('y')

    self:update_carrying(self.carrying)

    if self.scale_x ~= 1 then
        self:rescale_x(1)
    end

    if self.walking_momentum < 1 then
        self.walking_momentum = self.walking_momentum + 0.2
    end
end


function Player:chop(board_x)
    self.chopping = true

    if self.facing == 1 then
        self.hand_front.x = board_x - 1
        self.hand_front.y = self.y - 8
        self.hand_front.rotation = -90
        self.engine.flux.to(self.hand_front, 0.5, {
            x=(self.x+2), y=(self.y+0.5), rotation=(-self.rotation*5)
        }):ease("expoout"):oncomplete(function() self.chopping = false end)

    elseif self.facing == -1 then
        self.hand_back.x = board_x + 1
        self.hand_back.y = self.y - 8
        self.hand_back.rotation = 90
        self.engine.flux.to(self.hand_back, 0.5, {
            x=(self.x-2), y=(self.y+0.5), rotation=(self.rotation*5)
        }):ease("expoout"):oncomplete(function() self.chopping = false end)
    end
end


function Player:add_bread_to_toaster()
    if self.bread > 0 then
        self.bread = self.bread - 1
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
            self.walking_momentum = self.walking_momentum - 0.1
        elseif self.walking_momentum < -0.05 then
            self.walking_momentum = self.walking_momentum + 0.1
        end
    end

    -- reset for next frame; move_left/move_right will re-set these if still held
    self.held_left = false
    self.held_right = false
    self.scene.engine.flux.to(self, 0.25, {y=self.base_y, rotation=0})

    if self.facing == 1 then
        self.interact_x = self.x + INTERACT_OFFSET
    else
        self.interact_x = self.x - INTERACT_OFFSET
    end

    if not self.chopping then
        if self.facing == 1 then
            self.hand_front.x = self.x - 2
            self.hand_back.x = self.x + 2
        elseif self.facing == -1 then
            self.hand_front.x = self.x + 2
            self.hand_back.x = self.x - 2
        end
        self.hand_front.y = self.y + 0.5
        self.hand_back.y = self.y + 0.5
        self.hand_front.rotation = -self.rotation * 5
        self.hand_back.rotation = self.rotation * 5
    end

    
end


function Player:draw()
    Entity.draw(self)
end


return Player
