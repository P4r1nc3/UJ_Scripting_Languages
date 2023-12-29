local serpent = require("serpent")

local boardWidth = 10
local boardHeight = 20
local board = {}
local currentPiece, currentPieceType, currentRotation
local currentX, currentY
local blockSize = 30
local moveSpeed = 0.15
local timeSinceLastMove = 0
local colors = {
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 1},
    {1, 1, 0},
    {1, 0, 1},
    {0, 1, 1},
}
local pieces = {
    {
        {{1, 1, 1, 1}},
        {{1}, {1}, {1}, {1}}
    },
    {
        {{1, 1}, {1, 1}}
    },
    {
        {{0, 1, 0}, {1, 1, 1}},
        {{1, 0}, {1, 1}, {1, 0}},
        {{1, 1, 1}, {0, 1, 0}},
        {{0, 1}, {1, 1}, {0, 1}}
    },
    {
        {{0, 1, 1}, {1, 1, 0}},
        {{1, 0}, {1, 1}, {0, 1}}
    },
    {
        {{1, 1, 0}, {0, 1, 1}},
        {{0, 1}, {1, 1}, {1, 0}}
    },
    {
        {{1, 0, 0}, {1, 1, 1}},
        {{1, 1}, {1, 0}, {1, 0}},
        {{1, 1, 1}, {0, 0, 1}},
        {{0, 1}, {0, 1}, {1, 1}}
    },
    {
        {{0, 0, 1}, {1, 1, 1}},
        {{1, 0}, {1, 0}, {1, 1}},
        {{1, 1, 1}, {1, 0, 0}},
        {{1, 1}, {0, 1}, {0, 1}}
    }
}
local touchAreas = {
    left = {x1 = 0, y1 = 0, x2 = 100, y2 = love.graphics.getHeight()},
    right = {x1 = love.graphics.getWidth() - 100, y1 = 0, x2 = love.graphics.getWidth(), y2 = love.graphics.getHeight()}
}
local touchTimeStart = 0
local touchStartedInGame = false
local gameState = "menu"

function love.load()
    math.randomseed(os.time())
    resetBoard()
    gameState = "menu"
    lineClearSound = love.audio.newSource("line_clear.wav", "static")
    blockPlaceSound = love.audio.newSource("block_place.wav", "static")
end

function resetBoard()
    for y = 1, boardHeight do
        board[y] = {}
        for x = 1, boardWidth do
            board[y][x] = 0
        end
    end
    createNewPiece()
end

function createNewPiece()
    currentPieceType = math.random(#pieces)
    currentPiece = pieces[currentPieceType][1]
    currentRotation = 1
    currentX = 5
    currentY = 0
    currentColor = colors[math.random(#colors)]

    if not canMove(0, 1) then
        gameState = "gameover"
    end
end

function rotatePiece()
    local nextRotation = (currentRotation % #pieces[currentPieceType]) + 1
    local nextPiece = pieces[currentPieceType][nextRotation]
    if canMovePieceTo(currentX, currentY, nextPiece) then
        currentPiece = nextPiece
        currentRotation = nextRotation
    end
end

function canMovePieceTo(newX, newY, piece)
    for i, row in ipairs(piece) do
        for j, block in ipairs(row) do
            if block ~= 0 then
                local boardX = j + newX - 1
                local boardY = i + newY - 1
                if boardX < 1 or boardX > boardWidth or boardY > boardHeight or (board[boardY] and board[boardY][boardX] ~= 0) then
                    return false
                end
            end
        end
    end
    return true
end

function canMove(dx, dy)
    return canMovePieceTo(currentX + dx, currentY + dy, currentPiece)
end

function love.update(dt)
    if gameState == "playing" then
        timeSinceLastMove = timeSinceLastMove + dt
        if timeSinceLastMove >= moveSpeed then
            if canMove(0, 1) then
                currentY = currentY + 1
            else
                placePiece()
                createNewPiece()
            end
            timeSinceLastMove = 0
        end
    end
end

function placePiece()
    for i, row in ipairs(currentPiece) do
        for j, block in ipairs(row) do
            if block ~= 0 then
                local x = j + currentX - 1
                local y = i + currentY - 1
                if y > 0 then
                    board[y][x] = currentColor
                end
            end
        end
    end
    love.audio.play(blockPlaceSound)
    checkAndClearLines()
end

function checkAndClearLines()
    for y = 1, boardHeight do
        local isLineFull = true
        for x = 1, boardWidth do
            if board[y][x] == 0 then
                isLineFull = false
                break
            end
        end

        if isLineFull then
            for flash = 1, 5 do
                for x = 1, boardWidth do
                    board[y][x] = flash % 2 == 0 and {1, 1, 1} or {0, 0, 0}
                end
                love.graphics.clear()
                drawBoard()
                love.graphics.present()
                love.timer.sleep(0.1)
                love.audio.play(lineClearSound)
            end

            for removeY = y, 2, -1 do
                for removeX = 1, boardWidth do
                    board[removeY][removeX] = board[removeY - 1][removeX]
                end
            end

            for x = 1, boardWidth do
                board[1][x] = 0
            end
        end
    end
end

function love.draw()
    if gameState == "menu" then
        showMenu()
    elseif gameState == "playing" or gameState == "gameover" then
        drawBoard()
        drawPiece()
    end

    if gameState == "gameover" then
        gameState = "menu"
    end
end

function drawBoard()
    for y = 1, boardHeight do
        for x = 1, boardWidth do
            local color = board[y][x]
            if color ~= 0 then
                love.graphics.setColor(color)
                love.graphics.rectangle('fill', (x-1)*blockSize, (y-1)*blockSize, blockSize, blockSize)
            else
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle('line', (x-1)*blockSize, (y-1)*blockSize, blockSize, blockSize)
            end
        end
    end
end

function drawPiece()
    for i, row in ipairs(currentPiece) do
        for j, block in ipairs(row) do
            if block == 1 then
                love.graphics.setColor(currentColor)
                love.graphics.rectangle('fill', (j + currentX - 2) * blockSize, (i + currentY - 2) * blockSize, blockSize, blockSize)
            end
        end
    end
end

function showMenu()
    love.graphics.clear()
    love.graphics.printf("Tetris", 0, 200, love.graphics.getWidth(), "center")
    love.graphics.printf("Click Enter to start", 0, 250, love.graphics.getWidth(), "center")
    love.graphics.printf("Click L button to load saved game", 0, 300, love.graphics.getWidth(), "center")
    love.graphics.printf("Click Q button to quit game", 0, 350, love.graphics.getWidth(), "center")
end

function saveGame()
    local gameStateData = {
        board = board,
        currentX = currentX,
        currentY = currentY,
        currentPiece = currentPiece,
        currentPieceType = currentPieceType,
        currentRotation = currentRotation,
        gameState = gameState
    }
    local gameDataString = serpent.dump(gameStateData)
    love.filesystem.write("saved_game.lua", gameDataString)
end


function loadGame()
    if love.filesystem.getInfo("saved_game.lua") then
        local gameDataString = love.filesystem.read("saved_game.lua")
        local ok, gameStateData = serpent.load(gameDataString)
        if ok then
            board = gameStateData.board
            currentX = gameStateData.currentX
            currentY = gameStateData.currentY
            currentPiece = gameStateData.currentPiece
            currentPieceType = gameStateData.currentPieceType
            currentRotation = gameStateData.currentRotation
            gameState = gameStateData.gameState
        else
            gameState = "error"
            errorMessage = "ERROR"
        end
    else
        gameState = "error"
        errorMessage = "ERROR"
    end
end


function love.keypressed(key)
    if gameState == "menu" then
        if key == "return" then
            gameState = "playing"
            resetBoard()
        elseif key == "l" then
            loadGame()
            gameState = "playing"
        elseif key == "q" then
            love.event.quit()
        end
    elseif gameState == "playing" then
        if key == "left" and canMove(-1, 0) then
            currentX = currentX - 1
        elseif key == "right" and canMove(1, 0) then
            currentX = currentX + 1
        elseif key == "down" and canMove(0, 1) then
            currentY = currentY + 1
        elseif key == "up" then
            rotatePiece()
        elseif key == "q" then
            love.event.quit()
        elseif key == "s" then
            saveGame()
        elseif key == "l" then
            loadGame()
        elseif key == "r" then
            resetBoard()
        elseif key == "m" then
            gameState = "menu"
        end
    elseif gameState == "gameover" then
        if key == "r" then
            saveGame()
            gameState = "menu"
        end
    elseif gameState == "error" then
        love.graphics.clear()
        love.graphics.printf(errorMessage, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if gameState == "menu" then
        gameState = "playing"
        resetBoard()
    elseif gameState == "playing" then
        touchTimeStart = love.timer.getTime()
        touchStartedInGame = true
        if isWithinArea(x, y, touchAreas.left) then
            if canMove(-1, 0) then
                currentX = currentX - 1
            end
        elseif isWithinArea(x, y, touchAreas.right) then
            if canMove(1, 0) then
                currentX = currentX + 1
            end
        elseif isCenterArea(x, y) then
            rotatePiece()
        end
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if gameState == "playing" and touchStartedInGame then
        local touchDuration = love.timer.getTime() - touchTimeStart
        if touchDuration > 1.0 then
            gameState = "menu"
            touchStartedInGame = false
        end
    end
end

function isCenterArea(x, y)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    return x > screenWidth * 0.3 and x < screenWidth * 0.7 and y > screenHeight * 0.3 and y < screenHeight * 0.7
end

function isWithinArea(x, y, area)
    return x >= area.x1 and x <= area.x2 and y >= area.y1 and y <= area.y2
end