local valid = 1
local modifier_count = 0
local faliure_reason = ""

S.events:getListeners(C.TowerBuild):add(C.Listener(function(event)
    local tower = event:getTower()
    local type = tower.type
    if type == C.TowerType.CANNON or type == C.TowerType.FREEZING or type == C.TowerType.BLAST or type == C.TowerType.MULTISHOT or type == C.TowerType.GAUSS or type == C.TowerType.LASER or type == C.TowerType.CRUSHER then
        valid = 0
        C.Notifications:i():addFailure("不合法防御塔建造")
        faliure_reason = "不合法防御塔建造"
        S.gameState:setGameSpeed(0)
    end
end))

S.events:getListeners(C.AbilityApply):add(C.Listener(function(event)
    local ability = event:getAbility()
    local type = ability:getType()
    if type ~= C.AbilityType.LOIC and type ~= C.AbilityType.BULLET_WALL then
        valid = 0
        C.Notifications:i():addFailure("不合法技能使用")
        faliure_reason = "不合法技能使用"
        S.gameState:setGameSpeed(0)
    end
end))

local modifier_balance = 0
local modifier_search = 0
local modifier_power = 0
local modifier_damage = 0
local modifier_attack_speed = 0
local modifier_mining_speed = 0
local modifier_bounty = 0
local modifier_experience = 0
S.events:getListeners(C.ModifierBuild):add(C.Listener(function(event)
    local modifier = event:getModifier()
    local type = modifier.type
    if type == C.ModifierType.BALANCE then
        modifier_balance = 1
    end
    if type == C.ModifierType.SEARCH then
        modifier_search = 1
    end
    if type == C.ModifierType.POWER then
        modifier_power = 1
    end
    if type == C.ModifierType.DAMAGE then
        modifier_damage = 1
    end
    if type == C.ModifierType.ATTACK_SPEED then
        modifier_attack_speed = 1
    end
    if type == C.ModifierType.MINING_SPEED then
        modifier_mining_speed = 1
    end
    if type == C.ModifierType.BOUNTY then
        modifier_bounty = 1
    end
    if type == C.ModifierType.EXPERIENCE then
        modifier_experience = 1
    end
    modifier_count = modifier_balance + modifier_search + modifier_power + modifier_damage + modifier_attack_speed + modifier_mining_speed + modifier_bounty + modifier_experience
    if modifier_count > 4 then
        valid = 0
        C.Notifications:i():addFailure("芯片建造类别超出上限")
        C.Notifications:i():addFailure("当前芯片建造类别数量: " .. tostring(modifier_count))
        faliure_reason = "芯片建造类别超出上限"
        S.gameState:setGameSpeed(0)
    end
end))

S.events:getListeners(C.GameOver):add(C.Listener(function(event)
    if valid == 0 then
        C.Notifications:i():addFailure("本局游戏不合法")
        C.Notifications:i():addFailure("最近不合法行为详细情况:" .. faliure_reason)
    else
        C.Notifications:i():addSuccess("本局游戏验证成功")
    end
end))