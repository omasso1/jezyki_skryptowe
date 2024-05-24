-- main.lua
local pieces = require "pieces"

local moveCooldown = 0.1
local rotateCooldown = 0.2
local fallCooldown = 0.5

function love.load()
    love.window.setMode(400, 600)
    love.window.setTitle("Tetris")
    resetGame()
end

function resetGame()
    board = {}
    for y = 1, 20 do
        board[y] = {}
        for x = 1, 10 do
            board[y][x] = 0
        end
    end

    score = 0
    gameOver = false
    moveTimer = 0
    rotateTimer = 0
    fallTimer = 0
    spawnPiece()
end

function spawnPiece()
    currentPiece = pieces.newPiece()
    if not canPlacePiece(currentPiece.shape, currentPiece.x, currentPiece.y) then
        gameOver = true
    end
end

function canPlacePiece(shape, offsetX, offsetY)
    for y, row in ipairs(shape) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                local newX = x + offsetX - 1
                local newY = y + offsetY - 1
                if newX < 1 or newX > 10 or newY > 20 or (newY > 0 and board[newY][newX] ~= 0) then
                    return false
                end
            end
        end
    end
    return true
end

function placePiece()
    for y, row in ipairs(currentPiece.shape) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                board[currentPiece.y + y - 1][currentPiece.x + x - 1] = cell
            end
        end
    end
    clearLines()
    spawnPiece()
end

function clearLines()
    local newBoard = {}
    local linesCleared = 0

    for y = 1, 20 do
        local fullLine = true
        for x = 1, 10 do
            if board[y][x] == 0 then
                fullLine = false
                break
            end
        end

        if not fullLine then
            table.insert(newBoard, board[y])
        else
            linesCleared = linesCleared + 1
        end
    end

    while #newBoard < 20 do
        table.insert(newBoard, 1, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
    end

    board = newBoard
    score = score + (linesCleared * 100)
end

function love.update(dt)
    if gameOver then
        return
    end

    moveTimer = moveTimer - dt
    rotateTimer = rotateTimer - dt
    fallTimer = fallTimer - dt

    if love.keyboard.isDown("left") and moveTimer <= 0 and canPlacePiece(currentPiece.shape, currentPiece.x - 1, currentPiece.y) then
        currentPiece.x = currentPiece.x - 1
        moveTimer = moveCooldown
    elseif love.keyboard.isDown("right") and moveTimer <= 0 and canPlacePiece(currentPiece.shape, currentPiece.x + 1, currentPiece.y) then
        currentPiece.x = currentPiece.x + 1
        moveTimer = moveCooldown
    elseif love.keyboard.isDown("down") and moveTimer <= 0 and canPlacePiece(currentPiece.shape, currentPiece.x, currentPiece.y + 1) then
        currentPiece.y = currentPiece.y + 1
        moveTimer = moveCooldown
    end

    if fallTimer <= 0 then
        if canPlacePiece(currentPiece.shape, currentPiece.x, currentPiece.y + 1) then
            currentPiece.y = currentPiece.y + 1
        else
            placePiece()
        end
        fallTimer = fallCooldown
    end

    if love.keyboard.isDown("space") and rotateTimer <= 0 then
        local newShape = pieces.rotatePiece(currentPiece.shape)
        if canPlacePiece(newShape, currentPiece.x, currentPiece.y) then
            currentPiece.shape = newShape
        end
        rotateTimer = rotateCooldown
    end
end

function love.draw()
    local tileSize = 30
    for y = 1, 20 do
        for x = 1, 10 do
            if board[y][x] ~= 0 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
            end
        end
    end

    for y, row in ipairs(currentPiece.shape) do
        for x, cell in ipairs(row) do
            if cell ~= 0 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (currentPiece.x + x - 2) * tileSize, (currentPiece.y + y - 2) * tileSize, tileSize, tileSize)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 620)
    if gameOver then
        love.graphics.print("Game Over", 150, 300)
    end
end
