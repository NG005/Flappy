--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

-- you can add 10 point by pressing 's'

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_HEIGHT = 288
PIPE_WIDTH = 70

BIRD_WIDTH = 38
BIRD_HEIGHT = 24
gameScore = 0

-- set images for the pause mode
blackBackground = love.graphics.newImage('blackBackground.png')
blackGround = love.graphics.newImage('blackGround.png')
blackPipe = love.graphics.newImage('blackPipe.png')
pauseIcon = love.graphics.newImage('pauseIcon.png')

function PlayState:init()
    playing = true
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0

    -- Used to determine the gap between pipe pairs
    c = math.random(0, 10)


    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end



function PlayState:update(dt)
    -- add 10 points
    if love.keyboard.wasPressed('s') then
        self.score =  self.score + 10
    end
    if love.keyboard.wasPressed('p') then
        -- stop music and scrolling
        if scrolling == true then 
            scrolling = false
            sounds['pause']:play()
            z = sounds['music']:tell('seconds')
            sounds['music']:stop()
        -- resume music and scrolling
        elseif scrolling == false then 
            scrolling = true
            sounds['pause']:play()
            sounds['music']:play()
            z = sounds['music']:seek(z,'seconds')
        end
    end
    -- pause game
    if scrolling == true then 
         -- update timer for pipe spawning
        self.timer = self.timer + dt
        if gameDifficulty == 'normal' then 
            --[[randomize the pipe pair's gap, the distance between two pipe pair's 
            and the distance between two pipe pairs gap's]]
            -- distance between two pipe pair's 
            if self.timer > 2.5 + (c / 9) then
                -- pipe pair's gap
                GAP_HEIGHT =  math.random(90, 130)
                -- distance between two pipe pairs gap's
                if self.lastY == -278 then
                    b = math.random(10, 30)
                end
                if self.lastY == -140 then
                    b = math.random(-10, -30)
                end
                if self.lastY < -210 or self.lastY == -210 then
                    b = math.random(10, 30)
                end
                if self.lastY > -210 then
                    b = math.random(-10, -30)
                end
                local y = math.max(-PIPE_HEIGHT + 10, -- -278
                math.min(self.lastY + b, - 140)) -- -140
                self.lastY = y
                c = math.random(0, 10)
                -- add a new pipe pair at the end of the screen at our new Y
                table.insert(self.pipePairs, PipePair(y))
                -- reset timer
                self.timer = 0
            end
        end
        if gameDifficulty == 'hard' then
            --[[randomize the pipe pair's gap, the distance between two pipe pair's 
            and the distance between two pipe pairs gap's]]
            -- distance between two pipe pair's 
            if self.timer > 2.3 + (c / 10) then
                -- pipe pair's gap
                GAP_HEIGHT =  math.random(60, 105) 
                -- distance between two pipe pairs gap's              
                if self.lastY == -278 then
                    b = math.random(30, 90)
                end
                if self.lastY == -140 then
                    b = math.random(-30, -90)
                end
                if self.lastY < -210 or self.lastY == -210 then
                    b = math.random(30, 69)
                end
                if self.lastY > -210 then
                    b = math.random(-30, -69)
                end
                local y = math.max(-PIPE_HEIGHT + 10, -- -278
                 math.min(self.lastY + b, - 140))
                 self.lastY = y
                 c = math.random(0, 10)
                 -- add a new pipe pair at the end of the screen at our new Y
                table.insert(self.pipePairs, PipePair(y))
                -- reset timer
                self.timer = 0
            end
        end

        -- for every pair of pipes..
        for k, pair in pairs(self.pipePairs) do
            -- score a point if the pipe has gone past the bird to the left all the way
            -- be sure to ignore it if it's already been scored
            if not pair.scored then
                if pair.x + PIPE_WIDTH < self.bird.x then
                    self.score = self.score + 1
                    pair.scored = true
                    sounds['score']:play()
                end
            end

            -- update position of pair
            pair:update(dt)
        end
    
        -- we need this second loop, rather than deleting in the previous loop, because
        -- modifying the table in-place without explicit keys will result in skipping the
        -- next pipe, since all implicit keys (numerical indices) are automatically shifted
        -- down after a table removal
        for k, pair in pairs(self.pipePairs) do
            if pair.remove then
                table.remove(self.pipePairs, k)
            end
        end

        -- simple collision between bird and all pipes in pairs
        for k, pair in pairs(self.pipePairs) do
            for l, pipe in pairs(pair.pipes) do
                if self.bird:collides(pipe) then
                    sounds['explosion']:play()
                    sounds['hurt']:play()  
                    playing = false  
                    gStateMachine:change('score', {
                        score = self.score
                    })
                end
            end
        end
        
        -- update bird based on gravity and input
        self.bird:update(dt)

        -- reset if we get to the ground
        if self.bird.y > VIRTUAL_HEIGHT - 15 then
            sounds['explosion']:play()
            sounds['hurt']:play()
            playing = false  
            gStateMachine:change('score', {
                score = self.score
            })
        end
    end
end


function PlayState:render()
    -- draw darker versions of the images for the pause mode
    if scrolling == false then
        love.graphics.draw(blackBackground,-backgroundScroll, 0)    end

    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end
    love.graphics.setFont(smallFont)
    if scrolling == true then
        love.graphics.printf('Press "p" to pause the game', 180, 10, VIRTUAL_WIDTH, 'center')
    end
    
    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)
    self.bird:render()

    if scrolling == false then
        -- show "paused" message
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press "p" to resume the game', 180, 10, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(flappyFont)
        love.graphics.printf('Paused', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(pauseIcon,180, 60)
    end
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end

-- sorry for any gramatical or writing mistake, english isn't my main languaje :(