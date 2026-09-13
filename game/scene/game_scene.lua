-- Import from Hatchling
local Class = require("hatchling.engine.lib.class")
local Scene = require("hatchling.engine.class.scene")

-- Load entities
local Board = require("game.entity.board")
local Cat = require("game.entity.cat")
local Colours = require("game.constants.colours")
local Fridge = require("game.entity.fridge")
local Oven = require("game.entity.oven")
local Player = require("game.entity.player")
local Toaster = require("game.entity.toaster")

-- Create scene
local GameScene = Class{__includes = Scene}

-- Set constants
local CAMERA = {x = 120, y = 67.5, zoom = 1}

local DOOR_TOLERANCE = 8
local DOOR_X = 151.5

local FRIDGE_TOLERANCE = 8
local FRIDGE_X = 198.5
local OVEN_TOLERANCE = 8
local OVEN_X = 182.5
local BOARD_TOLERANCE = 14
local BOARD_X = 133
local TOASTER_TOLERANCE = 8
local TOASTER_X = 166.5

local X_MIN, X_MAX = 71, 230
local X_MIN_INDOOR, X_MAX_INDOOR = 125, 200

local NUM_SLICES_IN_LOAF = 4


function GameScene:init(game, engine, font)
    Scene.init(self, game, engine)
    self.font = font
end


function GameScene:enter()
    Scene.enter(self)
    self:setup_keybinds()
    self:setup_events()

    -- Create scene sprites (now absolute world coords)
    local scene_sprites = {
        {"hedge",       94.5,   103,    1,  0,  4},
        {"tree_left",   76.5,   71.5,   1,  0,  5},
        {"fence",       74.5,   106,    1,  0,  6},
        {"toast_box",   99.5,   101.5,  1,  0,  10},
        {"ground",      120,    135.5,  1,  0,  16},
        {"house",       170,  80,   1,  0,  18},
        {"house_front", 162.5,  94.5,   1,  0,  40},
        {"kitchen",     163,    99,     1,  0,  19},
        {"tree_right",  229,    82.5,   1,  0,  21},
        {"shrub_right", 227.5,  101,    1,  0,  22},
    }
    for _, p in ipairs(scene_sprites) do
        self.engine:add_sprite(p[1], p[1], p[1], p[2], p[3], p[4], p[5], p[6])
    end
    self.engine:add_sprite_background("sky", "sky", "sky", 120, 71, 1, 0, 0)

    self.engine:add_sprite_hud("menu_base", "menu", "menu", 150.5, 68, 1, 0, 200)
    self.engine:add_sprite_hud("in_tray", "in_tray", "in_tray", 31, 79, 1, 0, 202)
    self.engine:add_sprite_hud("header_in_tray", "header_orders", "header_orders", 31, 12.5, 1, 0, 202)
    
    self.fridge_x = 270
    self.engine:add_sprite_hud("menu_right", "menu_right", "menu_right", self.fridge_x - 4, 68, 1, 0, 201)
    self.engine:add_sprite_hud("hud_fridge", "hud_fridge", "hud_fridge", self.fridge_x, 79, 1, 0, 202)
    self.engine:add_sprite_hud("header_fridge", "header_orders", "header_orders", self.fridge_x, 12.5, 1, 0, 202)

    self.engine:add_sprite("debug_point", "debug_point", "debug_point", 0, 0, 1, 0, 255)

    -- Initialize cat
    self.cat = Cat(self, 100, 93)

    -- Initialize player
    self.player = Player(self, 80, 103)
    self.player_indoors = false
    
    self.engine:add_text_hud("text_bread_shadow", tostring(self.player.bread), "SuperCartoon", 8, Colours.BROWN4, 85.5, 18.75, 1, 0, 300, "left")
    self.engine:add_text_hud("text_bread", tostring(self.player.bread), "SuperCartoon", 8, Colours.WHITE, 84.5, 17.75, 1, 0, 301, "left")

    self.engine:add_text_hud("text_orders_shadow", "ORDERS", "SuperCartoon", 10, Colours.BROWN4, 31.5, 16, 1, 0, 300, "centre")
    self.engine:add_text_hud("text_orders", "ORDERS", "SuperCartoon", 10, Colours.WHITE, 30.5, 15, 1, 0, 301, "centre")

    self.engine:add_text_hud("text_fridge_shadow", "FRIDGE", "SuperCartoon", 10, Colours.BROWN4, 270.5, 16, 1, 0, 300, "centre")
    self.engine:add_text_hud("text_fridge", "FRIDGE", "SuperCartoon", 10, Colours.WHITE, 269.5, 15, 1, 0, 301, "centre")

    self.toaster = Toaster(self, TOASTER_X, 99.5)
    self.board = Board(self, BOARD_X, 101.5)
    self.oven = Oven(self, OVEN_X, 104.5)
    self.fridge = Fridge(self, FRIDGE_X, 99.5)
    for item, values in pairs(self.fridge.inventory) do
        if values.unlocked then
            self.engine:add_sprite_hud(values.name, values.name, "1", self.fridge_x - values.x_offset, values.y, 1, 0, 210)
            end
    end

    self.door_hover = false
end


function GameScene:trigger(trigger_id)
end


function GameScene:toggle_house()
    if self.door_hovered then
        if not self.player_indoors then
            self:enter_house()
        else
            self:leave_house()
        end
    end
end


function GameScene:enter_garden()
    self.engine.flux.to(CAMERA, 0.5, {x=220, y=67.5, zoom=1}):ease("expoout")
end


function GameScene:leave_garden()
    self.engine.flux.to(CAMERA, 0.5, {x=120, y=67.5, zoom=1}):ease("expoout")
end


function GameScene:enter_house()
    self.engine.render_manager.draw_objects_foreground["house_front"] = nil
    self.player_indoors = true
    self.engine.flux.to(CAMERA, 0.5, {x=142, y=74.5, zoom=1.3}):ease("expoout")
end


function GameScene:leave_house()
    self.engine:add_sprite("house_front", "house_front", "house_front", 162.5, 94.5, 1, 0, 40)
    self.player_indoors = false
    self.engine.flux.to(CAMERA, 0.5, {x=120, y=67.5, zoom=1}):ease("expoout")
end


function GameScene:open_fridge()
    self.engine.flux.to(self, 0.5, {fridge_x=209}):ease("expoout")
    self.engine.flux.to(CAMERA, 0.5, {x=184}):ease("expoout")

    for item in pairs(self.fridge.inventory) do
        local hud_key = "hud_fridge_" .. item
        local draw_obj = self.engine.render_manager.draw_objects_hud[hud_key]
        if draw_obj then
            self.engine.flux.to(draw_obj, 0.5, {x = 209}):ease("expoout")
        end
    end

    self.fridge.open = true
    self.fridge.sprite_tag = "open_top"
    self.fridge:create_sprite()
end


function GameScene:close_fridge()
    self.engine.flux.to(CAMERA, 0.5, {x=142}):ease("expoout")
    self.engine.flux.to(self, 0.5, {fridge_x=270}):ease("expoout")

    self.fridge.open = false
    self.fridge.sprite_tag = "shut"
    self.fridge:create_sprite()
end


function GameScene:use_board()
    -- If nothing on the board, add a loaf with hp 4
    if not self.board.loaf and self.board.slices == 0 then
        self.board:add_loaf(NUM_SLICES_IN_LOAF)

    -- If a loaf already on the board, chop it, and add a slice
    elseif self.board.loaf then
        self.player:chop(BOARD_X)
        self.board:chop_slice()
    
    elseif not self.board.loaf then
        self.player.bread = self.board.slices
        self.board:remove_slices()

        self.engine:set_text_hud("text_bread_shadow", tostring(self.player.bread))
        self.engine.render_manager.text_objects_hud["text_bread_shadow"].x = 86.5
        self.engine.flux.to(self.engine.render_manager.text_objects_hud["text_bread_shadow"], 0.25, {x=85.5})

        self.engine:set_text_hud("text_bread", tostring(self.player.bread))
        self.engine.render_manager.text_objects_hud["text_bread"].x = 86.5
        self.engine.flux.to(self.engine.render_manager.text_objects_hud["text_bread"], 0.25, {x=84.5})
    end
end


function GameScene:setup_events()
    self.engine.event_manager:on(self.engine.event_manager.events["PRESS_LEFT"], self, function()
        if self.fridge.open then
            self.fridge:select_nearest(-1, 0)
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["PRESS_RIGHT"], self, function()
        if self.fridge.open then
            self.fridge:select_nearest(1, 0)
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["HOLD_LEFT"], self, function()
        if not self.fridge.open and not self.player.chopping then
            self.player:move_left()
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["HOLD_RIGHT"], self, function()
        if not self.fridge.open and not self.player.chopping then
            self.player:move_right()
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["PRESS_UP"], self, function()
        if self.fridge.open then
            self.fridge:select_nearest(0, -1)
        else
            self:toggle_house()
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["PRESS_DOWN"], self, function()
        if self.fridge.open then
            self.fridge:select_nearest(0, 1)
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["INTERACT"], self, function()
        if self.player_indoors and self.fridge.hovered and not self.fridge.open then
            self:open_fridge()
        end
        if self.board.hovered then
            self:use_board()
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["GOBACK"], self, function()
        if self.player_indoors and self.fridge.open then
            self:close_fridge()
        end
    end)
end


function GameScene:setup_keybinds()
    self.engine:create_keybind(self, "a", "HOLD_LEFT")
    self.engine:create_keybind(self, "d", "HOLD_RIGHT")
    self.engine:create_keybind(self, "w", "PRESS_UP", "press")
    self.engine:create_keybind(self, "s", "PRESS_DOWN", "press")
    self.engine:create_keybind(self, "a", "PRESS_LEFT", "press")
    self.engine:create_keybind(self, "d", "PRESS_RIGHT", "press")
    self.engine:create_keybind(self, "e", "INTERACT", "press")
    self.engine:create_keybind(self, "q", "GOBACK", "press")
end


function GameScene:update(dt, mx, my, md, mp)
    self.engine:move_camera(CAMERA.x, CAMERA.y)
    self.engine:zoom_camera(CAMERA.zoom)

    -- Limit player movement
    local x_min = X_MIN
    local x_max = X_MAX
    if self.player_indoors then
        x_min = X_MIN_INDOOR
        x_max = X_MAX_INDOOR
    end
    if self.player.x < x_min then
        self.player.x = x_min
    elseif self.player.x > x_max then
        self.player.x = x_max
    end

    -- Position fridge HUD elements
    local fridge_hud_elements = {
        menu_right = {name = "menu_right", x_offset = -4},
        header_fridge = {name = "header_fridge", x_offset = 0},
        hud_fridge = {name = "hud_fridge", x_offset = 0},
    }
    for item, values in pairs(self.fridge.inventory) do
        fridge_hud_elements[item] = values
    end
    for item, values in pairs(fridge_hud_elements) do
        local hud_element = self.engine.render_manager.draw_objects_hud[values.name]
        if hud_element then
            hud_element.x = self.fridge_x + values.x_offset
        end
    end

    self.engine.render_manager.text_objects_hud["text_fridge"].x = self.fridge_x
    self.engine.render_manager.text_objects_hud["text_fridge_shadow"].x = self.fridge_x+1
    
    if self.fridge.selected_item then
        local values = self.fridge.inventory[self.fridge.selected_item]
        if values then
            local item_name = values.name
            self.engine:add_sprite_hud("fridge_selection_outline", item_name, "1_outline", self.fridge_x + values.x_offset, values.y, 1, 0, 255)
            self.engine:add_sprite_hud("bubble", "bubble", "bubble", self.fridge_x + values.x_offset - 0.5, values.y - 11.5, 1, 0, 265)
            self.engine:add_text_hud("bubble_text", item_name, "SuperCartoon", 5, Colours.BLACK,  self.fridge_x + values.x_offset - 0.5, values.y - 8.5, 1, 0, 300, "centre")

            -- self.engine.flux.to(self.engine.render_manager.draw_objects_hud["bubble"], 0.25, {y=values.y -11.5}):ease("expoout")
        end
    end

    -- Update fridge parameters
    self.fridge.hovered = self:hover_entity(self.player.interact_x, FRIDGE_X, FRIDGE_TOLERANCE)
    if self.fridge.hovered and not self.fridge.open and self.player_indoors and not self.engine.render_manager.draw_objects_foreground["fridge_outline"] then
        self.engine:add_sprite("fridge_outline", "fridge", "outline", FRIDGE_X, 99.5, 1, 0, 21)
    elseif not self.fridge.hovered or self.fridge.open then
        self.engine.render_manager.draw_objects_foreground["fridge_outline"] = nil
    end

    -- Update door parameters
    self.door_hovered = self:hover_entity(self.player.interact_x, DOOR_X, DOOR_TOLERANCE)
    if self.door_hovered and not self.player_indoors and not self.engine.render_manager.draw_objects_foreground["door_outline"] then
        self.engine:add_sprite("door_outline", "door_outline", "door_outline", DOOR_X, 99, 1, 0, 41)
    elseif not self.door_hovered or self.player_indoors then
        self.engine.render_manager.draw_objects_foreground["door_outline"] = nil
    end

    -- Update oven parameters
    self.oven.hovered = self:hover_entity(self.player.interact_x, OVEN_X, OVEN_TOLERANCE)
    if self.oven.hovered and self.player_indoors and not self.engine.render_manager.draw_objects_foreground["oven_outline"] then
        self.engine:add_sprite("oven_outline", "oven", "outline", OVEN_X, 104.5, 1, 0, 21)
    elseif not self.oven.hovered then
        self.engine.render_manager.draw_objects_foreground["oven_outline"] = nil
    end

    -- Update board parameters
    self.board.hovered = self:hover_entity(self.player.interact_x, BOARD_X, BOARD_TOLERANCE)
    if self.board.hovered and self.player_indoors and not self.engine.render_manager.draw_objects_foreground["board_outline"] then
        self.engine:add_sprite("board_outline", "board", "outline", BOARD_X, 101.5, 1, 0, 21)
    elseif not self.board.hovered then
        self.engine.render_manager.draw_objects_foreground["board_outline"] = nil
    end

    -- Update toaster parameters
    self.toaster.hovered = self:hover_entity(self.player.interact_x, TOASTER_X, TOASTER_TOLERANCE)
    if self.toaster.hovered and self.player_indoors and not self.engine.render_manager.draw_objects_foreground["toaster_outline"] then
        self.engine:add_sprite("toaster_outline", "toaster", "outline", TOASTER_X, 99.5, 1, 0, 21)
    elseif not self.toaster.hovered then
        self.engine.render_manager.draw_objects_foreground["toaster_outline"] = nil
    end

    -- Set what player is carrying
    if self.board.hovered and self.player_indoors then
        if self.player.carrying ~= "knife" then
            self.player:update_carrying("knife")
        end
    else
        if self.player.carrying ~= "empty" then
            self.player:update_carrying("empty")
        end
    end
end


function GameScene:hover_entity(interact_x, x, tolerance)
    return interact_x >= (x - tolerance) and interact_x < (x + tolerance)
end


return GameScene