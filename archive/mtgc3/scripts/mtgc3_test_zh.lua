local valid = 1
local tower_count = {}
local faliure_reason = ""

if S.gameState.basicLevelName ~= "5.6" then
    return
else
    C.Notifications:i():addInfo("正在进行 MTGC3 验证")
end


S.events:getListeners(C.TowerBuild):add(C.Listener(function(event)
    local tower = event:getTower() 
    local type = tower.type
    local price = event:getPrice()
    if type == C.TowerType.GAUSS then
        valid = 0
        C.Notifications:i():addFailure("不合法防御塔建造")
        faliure_reason = "不合法防御塔建造"
        S.gameState:setGameSpeed(0)
    else
        log(tower_count[type])
        if tower_count[type] == nil then
            tower_count[type] = 1
        else
            if price ~=0 then -- Basic Ultimate
                tower_count[type] = tower_count[type] + 1
            end
        end
        if tower_count[type] > 1 then
            C.Notifications:i():addFailure("防御塔建造数量超出限制")
            C.Notifications:i():addFailure("防御塔类型和数量:" .. tostring(type:name()) .. " " .. tostring(tower_count[type]))
            faliure_reason = "防御塔建造数量超出限制"
            S.gameState:setGameSpeed(0) 
        end
    end
end))

S.events:getListeners(C.AbilityApply):add(C.Listener(function(event)
    local ability = event:getAbility()
    local type = ability:getType()
    if type == C.AbilityType.OVERLOAD then
        valid = 0
        C.Notifications:i():addFailure("不合法技能使用")
        faliure_reason = "不合法技能使用"
        S.gameState:setGameSpeed(0)
    end
end))

S.events:getListeners(C.ModifierBuild):add(C.Listener(function(event)
    local modifier = event:getModifier()
    local type = modifier.type
    if type == C.ModifierType.BOUNTY then
        valid = 0
        C.Notifications:i():addFailure("不合法芯片建造")
        faliure_reason = "不合法芯片建造"
        S.gameState:setGameSpeed(0)
    end
end))

S.events:getListeners(C.TowerAbilityChange):add(C.Listener(function(event)
    local tower = event:getTower()
    local type = tower.type
    local index = event:getAbilityIndex()
    if type == C.TowerType.VENOM and index == 4 then -- Venom Ultimate
        valid = 0
        C.Notifications:i():addFailure("不合法防御塔技能选择")
        faliure_reason = "不合法防御塔技能选择"
        S.gameState:setGameSpeed(0)
    end
end))

S.events:getListeners(C.TowerSell):add(C.Listener(function(event)
    local tower = event:getTower()
    local type = tower.type
    valid = 0
    C.Notifications:i():addFailure("不合法出售防御塔行为")
    C.Notifications:i():addFailure("防御塔类型:" .. tostring(type:name()))
    faliure_reason = "不合法出售防御塔行为"
    S.gameState:setGameSpeed(0)
end))

S.events:getListeners(C.GameOver):add(C.Listener(function(event)
    if valid == 0 then
        C.Notifications:i():addFailure("本局游戏不合法")
        C.Notifications:i():addFailure("最近不合法行为详细情况:" .. faliure_reason)
    else
        C.Notifications:i():addSuccess("本局游戏验证成功")
    end
end))