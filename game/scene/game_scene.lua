-- Import from Hatchling
local Class = require("hatchling.engine.lib.class")
local Scene = require("hatchling.engine.class.scene")

-- Load entities
local Board = require("game.entity.board")
local Cat = require("game.entity.cat")
local Fridge = require("game.entity.fridge")
local Oven = require("game.entity.oven")
local Player = require("game.entity.player")
local Toaster = require("game.entity.toaster")

-- Create scene
local GameScene = Class{__includes = Scene}

-- Set constants
local CAMERA = {x = 120, y = 67.5, zoom = 1}

local DOOR_COOLDOWN = 0.5
local DOOR_TOLERANCE = 14
local DOOR_X = 146.5

local FRIDGE_COOLDOWN = 0.5
local FRIDGE_TOLERANCE = 9
local FRIDGE_X = 198

local OVEN_TOLERANCE = 9
local OVEN_X = 179

local BOARD_TOLERANCE = 9
local BOARD_X = 162

local TOASTER_TOLERANCE = 10
local TOASTER_X = 143

local X_MIN, X_MAX = 71, 230
local X_MIN_INDOOR, X_MAX_INDOOR = 141, 200


function GameScene:init(game, engine)
    Scene.init(self, game, engine)
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
        {"toast_box",   98.5,   101.5,  1,  0,  10},
        {"phone_box",   118,    97,     1,  0,  10},
        {"ground",      120,    135.5,  1,  0,  16},
        {"house",       177.5,  80.5,   1,  0,  18},
        {"house_front", 170.5,  94.5,   1,  0,  40},
        {"kitchen",     170,    99,     1,  0,  19},
        {"tree_right",  229,    82.5,   1,  0,  21},
        {"shrub_right", 227.5,  101,    1,  0,  22},
    self.engine:add_sprite("house_front", "house_front", "house_front", 170.5, 94.5, 1, 0, 40)
    }
    for _, p in ipairs(scene_sprites) do
        self.engine:add_sprite(p[1], p[1], p[1], p[2], p[3], p[4], p[5], p[6])
    end
    self.engine:add_sprite_background("sky", "sky", "sky", 120, 71, 1, 0, 0)

    self.engine:add_sprite_hud("menu_base", "menu", "menu", 150.5, 68, 1, 0, 200)
    self.engine:add_sprite_hud("in_tray", "in_tray", "in_tray", 31, 79, 1, 0, 202)
    self.engine:add_sprite_hud("header_in_tray", "header_orders", "header_orders", 31, 12.5, 1, 0, 202)
    
    self.engine:add_sprite_hud("menu_right", "menu_right", "menu_right", 266, 68, 1, 0, 201)
    self.engine:add_sprite_hud("hud_fridge", "hud_fridge", "hud_fridge", 290, 79, 1, 0, 202)
    self.engine:add_sprite_hud("header_fridge", "header_fridge", "header_fridge", 290, 12.5, 1, 0, 202)

    self.engine:add_sprite("debug_point", "debug_point", "debug_point", 0, 0, 1, 0, 255)

    -- Initialize cat
    self.cat = Cat(self, 99, 93)

    -- Initialize player
    self.player = Player(self, 80, 103)
    self.player_indoors = false
    
    self.toaster = Toaster(self, 147.5, 99.5)
    self.board = Board(self, 164.5, 101.5)
    self.oven = Oven(self, 181.5, 104.5)
    self.fridge = Fridge(self, 197.5, 99.5)

    self.door_hover = false
end


function GameScene:trigger(trigger_id)
end


function GameScene:toggle_fridge()
    if self.fridge.hovered then
        if not self.fridge.open then
            self:open_fridge()
        else
            self:close_fridge()
        end
    end
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


function GameScene:enter_house()
    self.engine.render_manager.draw_objects_foreground["house_front"] = nil
    self.player_indoors = true
    self.engine.flux.to(CAMERA, 0.5, {x=150, y=72.5, zoom=1.3}):ease("expoout")
end


function GameScene:leave_house()
    self.engine:add_sprite("house_front", "house_front", "house_front", 170.5, 94.5, 1, 0, 40)
    self.player_indoors = false
    self.engine.flux.to(CAMERA, 0.5, {x=120, y=67.5, zoom=1}):ease("expoout")
end


function GameScene:open_fridge()
    self.engine.flux.to(CAMERA, 0.5, {x=184}):ease("expoout")
    self.engine.flux.to(self.engine.render_manager.draw_objects_hud['menu_right'], 0.5, {x=205}):ease("expoout")
    self.engine.flux.to(self.engine.render_manager.draw_objects_hud['header_fridge'], 0.5, {x=209}):ease("expoout")
    self.engine.flux.to(self.engine.render_manager.draw_objects_hud['hud_fridge'], 0.5, {x=209}):ease("expoout")
    self.fridge.open = true
    self.fridge.sprite_tag = "open_top"
    self.fridge:create_sprite()
end


function GameScene:close_fridge()
    self.engine.flux.to(CAMERA, 0.5, {x=150}):ease("expoout")
    self.engine.flux.to(self.engine.render_manager.draw_objects_hud['menu_right'], 0.5, {x=266}):ease("expoout")
    self.engine.flux.to(self.engine.render_manager.draw_objects_hud['header_fridge'], 0.5, {x=290}):ease("expoout")
    self.engine.flux.to(self.engine.render_manager.draw_objects_hud['hud_fridge'], 0.5, {x=290}):ease("expoout")
    self.fridge.open = false
    self.fridge.sprite_tag = "shut"
    self.fridge:create_sprite()
end


function GameScene:setup_events()
    self.engine.event_manager:on(self.engine.event_manager.events["MOVE_LEFT"], self, function()
        if not self.fridge.open then
            self.player:move_left()
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["MOVE_RIGHT"], self, function()
        if not self.fridge.open then
            self.player:move_right()
        end
    end)
    
    self.engine.event_manager:on(self.engine.event_manager.events["MOVE_UP"], self, function()
        if not self.door_cooldown then
            self:toggle_house()
            self.door_cooldown = DOOR_COOLDOWN
        end
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["INTERACT"], self, function()
        if not self.fridge_cooldown and self.player_indoors then
            self:toggle_fridge()
            self.fridge_cooldown = FRIDGE_COOLDOWN
        end
    end)
end


function GameScene:setup_keybinds()
    self.engine:create_keybind(self, "a", "MOVE_LEFT")
    self.engine:create_keybind(self, "d", "MOVE_RIGHT")
    self.engine:create_keybind(self, "e", "INTERACT")
    self.engine:create_keybind(self, "w", "MOVE_UP")
    self.engine:create_keybind(self, "left", "MOVE_LEFT")
    self.engine:create_keybind(self, "right", "MOVE_RIGHT")
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

    -- Update fridge parameters
    self.fridge.hovered = self:hover_entity(self.player.interact_x, FRIDGE_X, FRIDGE_TOLERANCE)
    self.fridge_cooldown = self:update_cooldown(self.fridge_cooldown, dt)
    if self.fridge.hovered and self.player_indoors and not self.engine.render_manager.draw_objects_foreground["fridge_outline"] then
        self.engine:add_sprite("fridge_outline", "fridge", "outline", 197.5, 99.5, 1, 0, 21)
    elseif not self.fridge.hovered then
        self.engine.render_manager.draw_objects_foreground["fridge_outline"] = nil
    end

    -- Update door parameters
    self.door_hovered = self:hover_entity(self.player.interact_x, DOOR_X, DOOR_TOLERANCE)
    self.door_cooldown = self:update_cooldown(self.door_cooldown, dt)
    if self.door_hovered and not self.player_indoors and not self.engine.render_manager.draw_objects_foreground["door_outline"] then
        self.engine:add_sprite("door_outline", "door_outline", "door_outline", 146.5, 99, 1, 0, 41)
    elseif not self.door_hovered or self.player_indoors then
        self.engine.render_manager.draw_objects_foreground["door_outline"] = nil
    end

    -- Update oven parameters
    self.oven.hovered = self:hover_entity(self.player.interact_x, OVEN_X, OVEN_TOLERANCE)
    if self.oven.hovered and self.player_indoors and not self.engine.render_manager.draw_objects_foreground["oven_outline"] then
        self.engine:add_sprite("oven_outline", "oven", "outline", 181.5, 104.5, 1, 0, 21)
    elseif not self.oven.hovered then
        self.engine.render_manager.draw_objects_foreground["oven_outline"] = nil
    end

    -- Update board parameters
    self.board.hovered = self:hover_entity(self.player.interact_x, BOARD_X, BOARD_TOLERANCE)
    if self.board.hovered and self.player_indoors and not self.engine.render_manager.draw_objects_foreground["board_outline"] then
        self.engine:add_sprite("board_outline", "board", "outline", 164.5, 101.5, 1, 0, 21)
    elseif not self.board.hovered then
        self.engine.render_manager.draw_objects_foreground["board_outline"] = nil
    end

    -- Update toaster parameters
    self.toaster.hovered = self:hover_entity(self.player.interact_x, TOASTER_X, TOASTER_TOLERANCE)
    if self.toaster.hovered and self.player_indoors and not self.engine.render_manager.draw_objects_foreground["toaster_outline"] then
        self.engine:add_sprite("toaster_outline", "toaster", "outline", 147.5, 99.5, 1, 0, 21)
    elseif not self.toaster.hovered then
        self.engine.render_manager.draw_objects_foreground["toaster_outline"] = nil
    end

    -- self.engine.render_manager.draw_objects_foreground["debug_point"].x = self.player.interact_x
    -- self.engine.render_manager.draw_objects_foreground["debug_point"].y = self.player.y+0.5
end


function GameScene:hover_entity(interact_x, x, tolerance)
    return interact_x >= (x - tolerance) and interact_x < (x + tolerance)
end


function GameScene:update_cooldown(cooldown, dt)
    if not cooldown then return nil end
    cooldown = cooldown - dt
    return cooldown > 0 and cooldown or nil
end


return GameScene