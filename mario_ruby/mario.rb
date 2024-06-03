require 'ruby2d'

set title: "Mario RUBY!"
set width: 800, height: 600

# Define player properties
player = Square.new(
    x: 400, y: 490,  # Initial position
    size: 50,
    color: 'blue'
)

# Define platforms
platforms = [
    Rectangle.new(x: 400, y: 550, width: 200, height: 50, color: 'green'),   # Starting platform
    Rectangle.new(x: 700, y: 450, width: 200, height: 50, color: 'green'),
    Rectangle.new(x: 1000, y: 350, width: 200, height: 50, color: 'green'),
    Rectangle.new(x: 1300, y: 250, width: 200, height: 50, color: 'green'),
    Rectangle.new(x: 1600, y: 150, width: 200, height: 50, color: 'green')
]

# Define finish area
finish = Rectangle.new(
    x: 1900, y: 100,  # Position of the finish area
    width: 100,
    height: 50,
    color: 'yellow'
)

# Define game over and win texts
game_over_text = Text.new(
    'GAME OVER',
    x: 300, y: 250,
    size: 50,
    color: 'red',
    z: 10
)

win_text = Text.new(
    'YOU WIN',
    x: 300, y: 250,
    size: 50,
    color: 'green',
    z: 10
)

# Hide the game over and win texts initially
game_over_text.remove
win_text.remove

# Game variables
player_speed = 5
gravity = 1
jump_strength = 15
velocity_y = 0
on_ground = false
keys_pressed = { left: false, right: false }
game_over = false
game_won = false
camera_x_diff = 0

# Check for collision between player and platform
def check_collision(player, platforms)
    platforms.each do |platform|
        if player.x < platform.x + platform.width &&
            player.x + player.size > platform.x &&
            player.y + player.size > platform.y  &&
            player.y + player.size <= platform.y + platform.height 
            return true, platform
        end
    end
    return false, nil
end

# Method to handle game over
def handle_game_over(player, platforms, game_over_text, win_text, finish)
    player.remove
    platforms.each(&:remove)
    finish.remove
    win_text.remove
    game_over_text.add
end

# Method to handle game win
def handle_game_win(player, platforms, game_over_text, win_text, finish)
    player.remove
    platforms.each(&:remove)
    finish.remove
    game_over_text.remove
    win_text.add
end

# Update game state
update do
    next if game_over || game_won  # Do not update game state if game is over or won

    # Apply gravity
    velocity_y += gravity
    player.y += velocity_y


    # Check for ground collision
    if player.y + player.size >= Window.height
        game_over = true
        handle_game_over(player, platforms, game_over_text, win_text, finish)
    else
        on_ground, platform = check_collision(player, platforms)
        if on_ground
            player.y = platform.y - platform.height
            velocity_y = 0
        end
    end

  # Check for finish collision
    if  player.x < finish.x + finish.width &&
        player.x + player.size > finish.x &&
        player.y + player.size > finish.y  &&
        player.y + player.size <= finish.y + finish.height 
        game_won = true
        handle_game_win(player, platforms, game_over_text, win_text, finish)
    end

    # Handle player movement
    if keys_pressed[:left]
        camera_x_diff = player_speed
    elsif keys_pressed[:right]
        camera_x_diff = -player_speed
    else
        camera_x_diff = 0
    end


    platforms.each do |platform|
        platform.x += camera_x_diff
    end
    finish.x += camera_x_diff
  

end

# Handle key press events
on :key_down do |event|
    next if game_over || game_won  # Do not handle key events if game is over or won
    case event.key
        when 'up'
            if on_ground
                velocity_y = -jump_strength
                on_ground = false
            end
        when 'left'
            keys_pressed[:left] = true
        when 'right'
            keys_pressed[:right] = true
    end
end

on :key_up do |event|
    case event.key
        when 'left'
            keys_pressed[:left] = false
        when 'right'
            keys_pressed[:right] = false
        end
end

show
