local pieces = {}

local shapes = {
    {
        {1, 1, 1, 1},
    },
    {
        {1, 1},
        {1, 1},
    },
    {
        {0, 1, 0},
        {1, 1, 1},
    },
    {
        {1, 1, 0},
        {0, 1, 1},
    },
    {
        {0, 1, 1},
        {1, 1, 0},
    },
    {
        {1, 1, 1},
        {1, 0, 0},
    },
    {
        {1, 1, 1},
        {0, 0, 1},
    }
}

function pieces.newPiece()
    local shape = shapes[math.random(#shapes)]
    return {
        shape = shape,
        x = 4,
        y = 0,
    }
end

function pieces.rotatePiece(shape)
    local newShape = {}
    for x = 1, #shape[1] do
        newShape[x] = {}
        for y = 1, #shape do
            newShape[x][y] = shape[#shape - y + 1][x]
        end
    end
    return newShape
end

return pieces