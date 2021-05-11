--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end


-- iniciate score and add images
score = 0
goldMedal = love.graphics.newImage('goldMedal.png')
silverMedal = love.graphics.newImage('silverMedal.png')
bronzeMedal = love.graphics.newImage('bronzeMedal.png')


function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 75, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to Play Again!', 0, 240, VIRTUAL_WIDTH, 'center')
     
    -- reward the player acording to its score

    -- bronze if score is less than 21
    if self.score < 20 then 
        love.graphics.draw(bronzeMedal, 215, 90)
        love.graphics.printf('You lost. Try harder next time!', 0, 34, VIRTUAL_WIDTH, 'center')
    end
    -- silver if score is less than 50 and more then 19
    if self.score  < 50 and self.score > 19 then 
        love.graphics.draw(silverMedal, 215, 90)
        love.graphics.printf('Good try. Almost there!', 0, 34, VIRTUAL_WIDTH, 'center')
    end
    -- gold if score is more than 49
    if self.score  > 49 then 
        love.graphics.draw(goldMedal, 215, 90)
        love.graphics.printf('Well done! Congratulations!', 0, 34, VIRTUAL_WIDTH, 'center')
    end
end