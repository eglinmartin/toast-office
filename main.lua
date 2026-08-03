love.filesystem.setRequirePath(
    love.filesystem.getRequirePath() .. ";hatchling/?.lua;hatchling/?/init.lua"
)

local flux = require("hatchling.engine.lib.flux")
local rs = require("hatchling.engine.lib.resolution_solution")
local Engine = require("hatchling.engine.hatchling")
local Game = require("game.game")


if arg and arg[2] == "debug" then
    local ok, dbg = pcall(require, "lldebugger")
    if ok then dbg.start() end
end


function love.load()
    GAME_SIZE = {240, 135}
    WINDOW_SIZE = {960, 540}
    BIN_PATH = '/game/bin'

    rs.conf({game_width = GAME_SIZE[1], game_height = GAME_SIZE[2], pixel_perfect = true})
    rs.setMode(WINDOW_SIZE[1], WINDOW_SIZE[2], {fullscreen = false})
    love.graphics.setDefaultFilter("nearest", "nearest")

    ENGINE = Engine(BIN_PATH, rs, flux)
    GAME = Game(ENGINE)
end


function love.update(dt)
    ENGINE:update(dt, rs)
    GAME:update(dt)
    flux.update(dt)
end


function love.draw()
    ENGINE.render_manager:draw()
    love.graphics.setColor(1, 1, 1)
end


function love.resize(w, h)
    rs.resize(w, h)
end


function love.keypressed(key)
    ENGINE.input_manager:keypressed(key)
end


function love.mousepressed(x, y, button)
    ENGINE.input_manager:mousepressed(x, y, button)
end


function love.mousereleased(x, y, button)
    ENGINE.input_manager:mousereleased(x, y, button)
end


if lldebugger then
    local love_errorhandler = love.errorhandler
    function love.errorhandler(msg)
        error(msg, 2)
    end
end

