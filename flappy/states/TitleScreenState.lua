--[[
    TitleScreenState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The TitleScreenState is the starting screen of the game, shown on startup. It should
    "ask" the user to choose the game difficulty and also our highest score.
]]

TitleScreenState = Class{__includes = BaseState}
gameDifficulty = 'A'

function TitleScreenState:update(dt)
    -- stablish game difficulty depending on the player's choice
    if love.keyboard.wasPressed('1') then
        gameDifficulty = 'normal'
        gStateMachine:change('countdown')
    end
    if love.keyboard.wasPressed('2') then
        gameDifficulty = 'hard'
        gStateMachine:change('countdown')
    end
end

function TitleScreenState:render()
    -- simple UI code
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Fifty Bird', 0, 64, VIRTUAL_WIDTH, 'center')

    -- ask the user to choose the game difficulty
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Normal', -35, 220, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Hard', 35, 220, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press 1', -35, 240, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press 2', 35, 240, VIRTUAL_WIDTH, 'center')
end