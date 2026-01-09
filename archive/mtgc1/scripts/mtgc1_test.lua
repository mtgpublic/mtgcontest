local valid = 1
local cost = 0

S.events:getListeners(C.TowerBuild):add(C.Listener(function(event)
    local tower = event:getTower()
    local type = tower.type
    if type == C.TowerType.BASIC or type == C.TowerType.SNIPER or type == C.TowerType.CANNON or type == C.TowerType.FREEZING or type == C.TowerType.GAUSS or type == C.TowerType.LASER or type == C.TowerType.MINIGUN or type == C.TowerType.FLAMETHROWER or type == C.TowerType.VENOM then
        valid = 0
        C.Notifications:i():addFailure("不合法防御塔建造")
        S.gameState:setGameSpeed(0)
    end
end))

S.events:getListeners(C.AbilityApply):add(C.Listener(function(event)
    local ability = event:getAbility()
    local type = ability:getType()
    if type == C.AbilityType.FIREBALL then
        cost = cost + 2
    end
    if type == C.AbilityType.BLIZZARD then
        cost = cost + 2
    end
    if type == C.AbilityType.WINDSTORM then
        cost = cost + 2
    end
    if type == C.AbilityType.THUNDER then
        cost = cost + 1
    end
    if type == C.AbilityType.SMOKE_BOMB then
        cost = cost + 3
    end
    if type == C.AbilityType.FIRESTORM then
        cost = cost + 3
    end
    if type == C.AbilityType.MAGNET then
        cost = cost + 2
    end
    if type == C.AbilityType.BULLET_WALL then
        cost = cost + 2
    end
    if type == C.AbilityType.BALL_LIGHTNING then
        cost = cost + 1
    end
    if type == C.AbilityType.LOIC then
        cost = cost + 1
    end
    if type == C.AbilityType.NUKE then
        cost = cost + 4
    end
    if type == C.AbilityType.OVERLOAD then
        cost = cost + 1
    end
    if type == C.AbilityType.LOOP then
        cost = cost + 3
    end
    if cost > 30 then
        valid = 0
        C.Notifications:i():addFailure("技能点超出限制\n当前技能点使用数量：" .. tostring(cost))
        S.gameState:setGameSpeed(0)
    end
end))

S.events:getListeners(C.ModifierBuild):add(C.Listener(function(event)
    local modifier = event:getModifier()
    local type = modifier.type
    if type == C.ModifierType.BOUNTY then
        valid = 0
        C.Notifications:i():addFailure("不合法芯片建造")
        S.gameState:setGameSpeed(0)
    end
end))

S.events:getListeners(C.GameOver):add(C.Listener(function(event)
    if valid == 0 then
        C.Notifications:i():addFailure("本局游戏不合法")
    else
        C.Notifications:i():addSuccess("本局游戏验证成功")
        C.Notifications:i():addSuccess("本局技能点使用数量："..tostring(cost))
    end
end))