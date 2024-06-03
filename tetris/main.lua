-- main.lua
local pieces = require "pieces"


local moveCooldown = 0.1
local rotateCooldown = 0.2
local fallCooldown = 0.5
local TileSize = 30
local ROWS = 20
local COLS = 10


local rotateSound = love.audio.newSource("sounds/rotate.mp3", "static")
local moveSound = love.audio.newSource("sounds/move.mp3", "static")
local scoreSound = love.audio.newSource("sounds/score.mp3", "static")


function love.load()
    love.window.setMode(TileSize * COLS + 100, 600)
    love.window.setTitle("Tetris")
    ResetGame()
end

function love.conf(t)
	t.console = true
end


function PlayRotateSound()
    rotateSound:stop()
    rotateSound:setVolume(0.5)
    rotateSound:play()
end

function PlayMoveSound()
    moveSound:stop()
    -- rotateSound:setVolume(1)
    moveSound:play()
end

function PlayScoreSound()
    scoreSound:stop()
    -- rotateSound:setVolume(volume)
    scoreSound:play()
end

function SaveGame()
    print("save")
    local filename = "gamestate.txt"
    local file = io.open(filename, "w")
    if file == nil then
        print("Couldn't find file")
        return 0
    end

    for i = 1, ROWS do
        for j = 1, COLS do
            file:write(Board[i][j] .. " ")
        end
        file:write("\n")
    end

    file:write("score=" .. Score .. "\n")
    file:write("currentCol=" .. CurrentPiece.x .. "\n")
    file:write("currentRow=" .. CurrentPiece.y .. "\n")
    file:write("curSizeX=" .. #CurrentPiece.shape[1] .. "\n")
    file:write("curSizeY=" .. #CurrentPiece.shape .. "\n")

    for y=1, #CurrentPiece.shape do
        for x=1, #CurrentPiece.shape[1] do
            file:write(CurrentPiece.shape[y][x] .. " ")
        end
        file:write("\n")
    end

    file:close()
end

function LoadGame()
    local filename = "gamestate.txt"
    local file = io.open(filename, "r")

    if file then
        for i = 1, ROWS do
            local line = file:read() 
            local row = {}
            for value in line:gmatch("%S+") do 
                table.insert(row, tonumber(value)) 
            end
            Board[i] = row 
        end

        for i=1,5 do
            local line = file:read() 
            local key, value = line:match("([^=]+)=(.+)")

            if key == "score" then
                Score = tonumber(value)
            end

            if key == "currentCol" then
                CurrentPiece.x = tonumber(value)
            end

            if key == "currentRow" then
                CurrentPiece.y = tonumber(value)
            end

            if key == "curSizeX" then
                SizeX = tonumber(value)
            end

            if key == "curSizeY" then
                SizeY = tonumber(value)
            end
        end

        CurrentPiece.shape = {}
        for i = 1, SizeY do
            CurrentPiece.shape[i] = {}
            local line = file:read()
            for value in line:gmatch("%S+") do
                print(value) 
                table.insert(CurrentPiece.shape[i], tonumber(value)) 
            end
        end

        file:close()
    else
        print("Cannot find file.")
    end
end


function ResetGame()
    Board = {}
    for y = 1, 20 do
        Board[y] = {}
        for x = 1, 10 do
            Board[y][x] = 0
        end
    end

    Score = 0
    GameOver = false
    MoveTimer = 0
    RotateTimer = 0
    FallTimer = 0
    SpawnPiece()
end

function SpawnPiece()
    CurrentPiece = pieces.newPiece()
    if not CanPlacePiece(CurrentPiece.shape, CurrentPiece.x, CurrentPiece.y) then
        GameOver = true
    end
end

function CanPlacePiece(shape, offsetX, offsetY)
    for y, row in ipairs(shape) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                local newX = x + offsetX - 1
                local newY = y + offsetY - 1
                if newX < 1 or newX > 10 or newY > 20 or (newY > 0 and Board[newY][newX] ~= 0) then
                    return false
                end
            end
        end
    end
    return true
end

function PlacePiece()
    for y, row in ipairs(CurrentPiece.shape) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                Board[CurrentPiece.y + y - 1][CurrentPiece.x + x - 1] = cell
            end
        end
    end
    ClearLines()
    SpawnPiece()
end

function ClearLines()
    local newBoard = {}
    local linesCleared = 0

    for y = 1, 20 do
        local fullLine = true
        for x = 1, 10 do
            if Board[y][x] == 0 then
                fullLine = false
                break
            end
        end

        if not fullLine then
            table.insert(newBoard, Board[y])
        else
            linesCleared = linesCleared + 1
        end
    end

    while #newBoard < 20 do
        table.insert(newBoard, 1, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
    end

    if linesCleared > 0 then
        PlayScoreSound()
    end
    Board = newBoard
    Score = Score + (linesCleared * 100)
end

function love.update(dt)
    if GameOver then
        return
    end

    MoveTimer = MoveTimer - dt
    RotateTimer = RotateTimer - dt
    FallTimer = FallTimer - dt

    if love.keyboard.isDown("left") and MoveTimer <= 0 and CanPlacePiece(CurrentPiece.shape, CurrentPiece.x - 1, CurrentPiece.y) then
        CurrentPiece.x = CurrentPiece.x - 1
        PlayMoveSound()
        MoveTimer = moveCooldown
    elseif love.keyboard.isDown("right") and MoveTimer <= 0 and CanPlacePiece(CurrentPiece.shape, CurrentPiece.x + 1, CurrentPiece.y) then
        CurrentPiece.x = CurrentPiece.x + 1
        MoveTimer = moveCooldown
        PlayMoveSound()
    elseif love.keyboard.isDown("down") and MoveTimer <= 0 and CanPlacePiece(CurrentPiece.shape, CurrentPiece.x, CurrentPiece.y + 1) then
        CurrentPiece.y = CurrentPiece.y + 1
        MoveTimer = moveCooldown
    end

    if FallTimer <= 0 then
        if CanPlacePiece(CurrentPiece.shape, CurrentPiece.x, CurrentPiece.y + 1) then
            CurrentPiece.y = CurrentPiece.y + 1
        else
            PlacePiece()
        end
        FallTimer = fallCooldown
    end

    if love.keyboard.isDown("space") and RotateTimer <= 0 then
        local newShape = pieces.rotatePiece(CurrentPiece.shape)
        if CanPlacePiece(newShape, CurrentPiece.x, CurrentPiece.y) then
            CurrentPiece.shape = newShape
            PlayRotateSound()
        end
        RotateTimer = rotateCooldown
    end
end

function love.keypressed(key)
    if key == "s" then
        SaveGame()
    elseif key == "r" then
        LoadGame()
    end
end



function love.draw()
    for y = 1, 20 do
        for x = 1, 10 do
            if Board[y][x] ~= 0 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (x-1)*TileSize, (y-1)*TileSize, TileSize, TileSize)
            end
        end
    end

    for y, row in ipairs(CurrentPiece.shape) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (CurrentPiece.x + x - 2) * TileSize, (CurrentPiece.y + y - 2) * TileSize, TileSize, TileSize)
            end
        end
    end

    love.graphics.line(TileSize * COLS, 0, TileSize * COLS, TileSize * ROWS)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. Score, TileSize * COLS + 10, 30)
    if GameOver then
        love.graphics.print("Game Over", 150, 300)
    end
end
