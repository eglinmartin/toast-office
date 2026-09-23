-- fridge.lua
local Class = require("hatchling.engine.lib.class")
local Entity = require("hatchling.engine.class.entity")
local Fridge = Class{__includes = Entity}
local Items = require("game.constants.items")


Fridge.Stock = {
    JAM_STRAWBERRY = {name=Items.JAM_STRAWBERRY.name, alias=Items.JAM_STRAWBERRY.alias, unlocked=true, x_offset=-14, y=42.5, amount=100, text_length="huge"},
    MARMALADE = {name=Items.MARMALADE.name, alias=Items.MARMALADE.alias, unlocked=true, x_offset=-3, y=42.5, amount=100, text_length="medium"},
    BUTTER = {name=Items.BUTTER.name, alias=Items.BUTTER.alias, unlocked=true, x_offset=14, y=62.5, amount=100, text_length="small"},
}


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

    self.inventory = {}
    for key, values in pairs(Fridge.Stock) do
        self.inventory[key] = {
            name = values.name,
            alias = values.alias,
            unlocked = values.unlocked,
            x_offset = values.x_offset,
            y = values.y,
            amount = values.amount,
            text_length = values.text_length,
        }
    end

    self.selected_item = "BUTTER"
end


function Fridge:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Fridge:select_nearest(dx, dy)
    local current = self.inventory[self.selected_item]
    if not current then return end

    local best_item = nil
    local best_dist = math.huge

    for item, values in pairs(self.inventory) do
        if values.unlocked and item ~= self.selected_item then
            local ix = values.x_offset - current.x_offset
            local iy = values.y - current.y

            local in_direction = (dx ~= 0 and ix * dx > 0) or (dy ~= 0 and iy * dy > 0)

            if in_direction then
                local dist = math.abs(ix) * (dy ~= 0 and 3 or 1)
                           + math.abs(iy) * (dx ~= 0 and 3 or 1)

                if dist < best_dist then
                    best_dist = dist
                    best_item = item
                end
            end
        end
    end

    if best_item then
        self.selected_item = best_item
    end
end


return Fridge