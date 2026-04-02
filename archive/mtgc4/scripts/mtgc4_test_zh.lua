local valid = 1
local faliure_reason = ""
local replaymode = false

if (S.state.replayMode ~= true or replaymode == false) and S.gameState.basicLevelName ~= "5.8" then
    return
else
    C.Notifications:i():addInfo("正在进行 MTGC4 验证")
end


S.events:getListeners(C.AbilityApply):add(C.Listener(function(event)
    C.Notifications:i():addFailure("不合法技能使用")
    faliure_reason = "不合法技能使用"
    S.gameState:setGameSpeed(0)
end))

S.events:getListeners(C.TowerUpgrade):add(C.Listener(function(event)
    C.Notifications:i():addFailure("不合法升级防御塔行为")
    faliure_reason = "不合法升级防御塔行为"
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