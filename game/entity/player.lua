-- player.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Items = require("game.constants.items")
local Player = Class{__includes = Entity}
local Toast = require("game.entity.toast")

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

    -- Set up hands
    self.hand_front = Entity(self, "hand_front", {x=x, y=x, w=8, h=12, s=1, r=0, sprite_sheet="hand", sprite_tag="empty", depth=132})
    scene.engine:register_entity("hand_front", self.hand_front)
    self.hand_back = Entity(self, "hand_back", {x=x, y=x, w=8, h=12, s=1, r=0, sprite_sheet="hand", sprite_tag="empty", depth=126})
    scene.engine:register_entity("hand_back", self.hand_back)
    self.hand_back:rescale(-1, 1)
    self.hand_back:create_sprite()
    self.dominant_hand = self.hand_front
    
    -- Set up walking
    self.walking = false
    self.walking_momentum = 0
end


function Player:move(facing)
    self.facing = facing
    if self.scale_x ~= self.facing then
        self:rescale_x(self.facing)
    end

    self:start_sine_wave('rotation')
    self:start_sine_wave('y')

    if self.facing == 1 then
        self.walking = self.facing
        if self.walking_momentum < 1 then
            self.walking_momentum = self.walking_momentum + 0.2
        end
    else
        self.walking = self.facing
        if self.walking_momentum > -1 then
            self.walking_momentum = self.walking_momentum - 0.2
        end
    end
end


function Player:pick_up_item(item)
    self.carrying = item
end


function Player:drop_item()
    self.carrying = nil
end


function Player:chop(board_x)
    self.chopping = true

    self.dominant_hand.x = board_x - self.facing
    self.dominant_hand.y = self.y - 8
    self.dominant_hand.rotation = -90 * self.facing
    self.engine.flux.to(self.dominant_hand, 0.5, {
        x=(self.x + (2 * self.facing)), y=(self.y+0.5), rotation=((-self.rotation*5) * self.facing)
    }):ease("expoout"):oncomplete(function() self.chopping = false end)
end


function Player:add_bread_to_toaster()
    if self.bread > 0 then
        self.bread = self.bread - 1
    end
end


function Player:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
    if self.carrying then
        print(self.carrying.id)
    end

    -- Set dominant hand
    self.dominant_hand = self.hand_front
    if self.facing == 1 then
        self.dominant_hand = self.hand_back
    end

    -- Move player
    self.x = self.x + self.walking_momentum

    if self.walking ~= 0 then
        self:stop_sine_wave('rotation')
        self:stop_sine_wave('y')
        self.walking = 0
    else
        self.walking_momentum = math.max(math.abs(self.walking_momentum) - 0.1, 0) * (self.walking_momentum < 0 and -1 or 1)
    end

    -- reset for next frame; move_left/move_right will re-set these if still held
    self.scene.engine.flux.to(self, 0.25, {y=self.base_y, rotation=0})

    self.interact_x = self.x - INTERACT_OFFSET
    if self.facing == 1 then
        self.interact_x = self.x + INTERACT_OFFSET
    end

    if not self.chopping then
        self.hand_front.x = self.x - (2 * self.facing)
        self.hand_back.x = self.x + (2 * self.facing)
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
