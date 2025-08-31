----修改调整.by:初雨Ryan -20250828
----- 脚本状态机
----1、给队友加状态可以采取 定时器加法，当一个角色加了状态后，延迟一定时间，再进行下一个角色	
----2、目前采用的医生加状态机制是 遍历完每个人物并判断是否全部加完状态，再进行下一个人物的状态

local fightState = 0
local fightTmpState = 0
local stayputNUM = 0
-- 攻击目标
local fightTargetPtr = nil
local fightTargetId = -1

-- 新增一个击杀怪物计时器变量
local killTimer = 0

-- 技能定时毫秒全局
local skillAllTime = 1000

-- 判断设置下一次使用技能CD时间
function UseNextSkillCD(arrI, now, skName)
    local intervalTime = Config.fightSkill[arrI].intervalTime   -- 获取设置间隔时间
    local nextSkTime = Config.fightSkill[arrI].nextSkTime   -- 记录下次释放技能的CD
    if skName ~= "" and intervalTime ~= 0 then
        if nextSkTime < now then
            Config.fightSkill[arrI].nextSkTime = now + intervalTime * skillAllTime   -- 当下一次间隔时间小于目前时间增加设置CD
            return true
        end
    end
    return false
end

-- 获取攻击技能
function GetAttackSkillPtr()
    local pSkill = nil
    local pSkillName = nil
    for i = 1, Config.fightSkillMax do
        pSkillName = Form.GetCommandText("fightSkill" .. i)
        pSkill = Game.FindSkillByName(pSkillName)       -- 通过技能名称获取技能指针
        if pSkill ~= nil and pSkillName ~= "治愈术" then
            local now = os.clock() * skillAllTime
            if Game.SkillIsCanUse(pSkill) and UseNextSkillCD(i, now, pSkillName) then   -- 判断是否可以使用技能 和 设置下一次技能使用的CD
                return pSkill
            end
        end
    end
    return nil
end

-- 计算距离
function GetDistance(x1, y1, x2, y2)
    local offx = math.abs(x1 - x2)      -- 取绝对值
    local offy = math.abs(y1 - y2)
    return math.sqrt(offx * offx + offy * offy) -- 返回开平方值
end

-- 计算当前角色到某个点的距离
function GetCurDistance(x2, y2)
    return GetDistance(Game.GetCurX(), Game.GetCurY(), x2, y2)
end

-- 范围检测
function IsOutAttackArea(bIsFree)
    local distance = GetCurDistance(Config.fightPosCur.x, Config.fightPosCur.y)
    if bIsFree then
        return distance > 1
    end
    return distance > Config.fightRange
end
-- 判断角色是否待在原地
function IsStayPut()
    stayputNUM = stayputNUM + 1
    if stayputNUM >= 20 then
        stayputNUM = 0
        return true
    end
    return false
end

-- 处理寻怪状态
function HandleFindMonster()
    if (fightTargetPtr == nil) then
        -- 目标为空，开始通过 名字 目标 是否存活 范围 来寻找目标
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr) -- 获取寻找到目标的ID
        return fightTargetId > 0
    end

    local attachId = Game.GetCharAttachID(fightTargetPtr)
    if (fightTargetId ~= attachId) then -- 寻找到的目标跟目前攻击目标不同时 重启寻找攻击目标
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end

    local hp = Game.GetCharAttr(fightTargetPtr, ATTR_HP) -- 获取寻找到目标的HP
    if (hp <= 0) then -- 当HP小于0，在开始重新寻找怪物
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end

    return true
end

-- 获取队伍的人员名字字符串
function GetTeamName()
    for i = 1, Config.teamMaxinfo, 1 do
        local teamName = Form.GetEditValue("play"..i)
		--local teamName = Game.GetTeamCharName(i)
		--Game.SysInfo(""..i.." "..teamName.."")
        if (teamName ~= "") and Config.teamInfo[i].state ~= 1 then
            Config.fightAddTargets = {} --插入前先设置空表
            table.insert(Config.fightAddTargets, teamName) --插入目标名字
            Config.teamInfo[i].state = 1 --设置了加状态标志
            break
        end

        if (teamName ~= "") and Config.teamInfo[i].state == 1 then
            Config.teamInfo[i].state = 0 --循环完后全部初始化状态为0
        end
    end

end

-- 处理医生寻队友状态
function HandleAddTeamState()
    if fightTargetPtr == nil then
        GetTeamName() -- 获取目标
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightAddTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end

    local attachId = Game.GetCharAttachID(fightTargetPtr)
    if (fightTargetId ~= attachId) then -- 寻找到的目标跟目前攻击目标不同时 重启寻找攻击目标
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightAddTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end

    local hp = Game.GetCharAttr(fightTargetPtr, ATTR_HP) -- 获取寻找到目标的HP
    if (hp == nil or hp <= 0) then -- 当HP小于0，在开始重新寻找怪物
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightAddTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end
	
    return true

end

-- 挂机点巡逻
function HandleNextPos()
    local startIndex = Config.fightPosIndex
    for i = 1, Config.fightPosMax do
        -- 直接增加索引并确保在范围内
        Config.fightPosIndex = Config.fightPosIndex + 1
        if Config.fightPosIndex > Config.fightPosMax then
            Config.fightPosIndex = 1
        end
        
        if (Config.fightPos[Config.fightPosIndex].x > 0 and
            Config.fightPos[Config.fightPosIndex].y > 0) then
            Config.fightPosCur.x = Config.fightPos[Config.fightPosIndex].x
            Config.fightPosCur.y = Config.fightPos[Config.fightPosIndex].y
                Game.SysInfo("开始前往挂机点"..Config.fightPosIndex.." ")
            return true
        end
        
        -- 如果已经检查了一圈还没找到有效点，退出
        if Config.fightPosIndex == startIndex then
            break
        end
    end
    Config.fightPosIndex = 0
    return false
end

-- 处理空闲打坐
function HandleFreeSit()
    -- Game.SysInfo("开始打坐")
    -- 空闲打坐未开启结束
    if (Config.fightFreeSit ~= true) then return end

    -- HP不足打坐
    local hp = Game.GetCharAttr(Game.GetCurChar(), ATTR_HP)
    local hpmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_HPMAX)
    if (hp <= (hpmax * 0.98)) then
        Game.SitDown()
        return
    end

    -- SP不足打坐
    local sp = Game.GetCharAttr(Game.GetCurChar(), ATTR_SP)
    local spmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_SPMAX)
    if (sp <= (spmax * 0.98)) then
        Game.SitDown()
        return
    end

    -- HP SP 充沛，玩家站起
    Game.StandUp()
end

--空闲自动跟随自定玩家
function  AutoFollow()
    --判断跟随
    if (Form.GetCheckBoxValue("chkAutouFollow") ~= 1 ) then
        return      
    end
	
    local Play_name = Form.GetEditValue("playFollw")
    if Play_name == nil or Play_name == "" then 
        Game.SysInfo("请选择或输入要跟随的目标")
	    return 
	end
	
    local pPlay = Game.FindCharByName(Play_name ,1 , math.min(Config.fightRange * 2, 25))
    if pPlay == nil then 
	   return 
	end
    Game.AutoFollow(pPlay)
end

-- 清空攻击目标
function ClearAttackTarget()
    fightTargetPtr = nil
    fightTargetId = -1
end

--判断目标是否有设置的全部状态，有返回true 无返回false
function IsAddStates(player)
    local hp = Game.GetCharAttr(player, ATTR_HP) 
	local hpmax = Game.GetCharAttr(player, ATTR_HPMAX)
	--local str = {"石化皮肤", "风之领主", "心灵之火"}
    for i = 1, Config.fightSkillMax do
       local sName = Form.GetCommandText("fightSkill" ..i) --获取技能框名字
       local sKillCd = Form.GetEditValueInt("SkillCd" ..i) --获取设置技能cd数值
        if (sName ~= "") and sKillCd ~= "" and sName ~= "治愈术" and sName ~= "回复术" and sName ~= "心灵屏障" and sName ~= "心灵冲撞" then
           if (Game.GetSkillStateNow(player, sName) == 0) then --判断技能是否有状态
			   return false
           end
        end 
    end
    return true --返回真表示都有状态
 end

-- 处理攻击状态 0：正常攻击，1：目标不存在 2：目标已死亡 3：目前是否有状态（医生用） 4：目标超过20秒未死亡
function HandleAttackMonster()
    
    -- 判断目标是否为空
    if (fightTargetPtr == nil or fightTargetId < 0) then 
        ClearAttackTarget()
        return 1
    end

    -- 判断目标的HP是否小于等于0
    local hp = Game.GetCharAttr(fightTargetPtr, ATTR_HP) 
	local hpmax = Game.GetCharAttr(fightTargetPtr, ATTR_HPMAX)
    if (hp == nil or hpmax == nil or hp <= 0) then
        ClearAttackTarget()
        return 2
    end
	
    -- 判断目标是否超过20秒未死亡
    local now = os.clock()
    if (killTimer == 0) then
        killTimer = now -- 开始计时
    elseif (now - killTimer >= 20) then
        ClearAttackTarget()
        killTimer = 0 -- 重置计时器
        return 4 -- 返回状态4，表示目标超过20秒未死亡
    end
	
    -- 检测血量低于阈值时使用治愈术
    if (Form.GetCheckGroupActiveIndex("fightTargetType") == 5) and (Form.GetCheckBoxValue("chkUseHealSkill") == 1) then
        -- 获取治愈术技能
        local healSkill = Game.FindSkillByName("治愈术")
        if healSkill ~= nil then
            -- 判断目标血量是否低于设置的百分比
            local healThreshold = Form.GetEditValueInt("healSkillHpThreshold")
            if healThreshold == nil or healThreshold >= 100 then
                healThreshold = 85 -- 默认值
            end
            if hp < hpmax * (healThreshold / 100) then
                if Game.SkillIsAttackTime(healSkill) ~= 0 then
                    Game.SysInfo("治愈术不在冷却中，有目标血量低于阀值，使用治愈术加血")
                    -- 使用治愈术加血
                    Game.Attack(healSkill, fightTargetPtr)
                end
                return 0
            end
        end
    end

    local pSkill = GetAttackSkillPtr()
    if (pSkill == nil and Config.fightOnlySkill) then
        HandleFreeSit() -- 处理空闲打坐
        AutoFollow() --跟随
        return 0
    end

    local isSelf = Game.SkillIsTypeSelf(pSkill) -- 判断目标是否是自己
    if (isSelf == 1) then
        Game.Attack(pSkill, Game.GetCurChar()) -- 开始正常对自己攻击
        return 0
    end
    
    --判断目标是否有所有的状态
    if (Form.GetCheckBoxValue("chkOnlyDoctor") == 1) and (IsAddStates(fightTargetPtr)) then 
        ClearAttackTarget()
        return 3
    end
	
    Game.Attack(pSkill, fightTargetPtr)
    return 0
end

-- 进入下一个状态 nDeep：调用深入，nNextState：下一个状态，bNow：是否立即执行
function NextState(nDeep, nNextState, bNow)
    fightState = nNextState
    if (bNow) then 
        return DoFights(nDeep + 1) 
    end
    return 0
end

-- 沿途打怪检测
function CheckMonsterAlongTheWay()
    local target = Game.FindCharByEveryName(Config.fightTargetType, Config.fightTargets, 1, Config.fightRange)
    if target  then
        fightTargetPtr = target
        fightTargetId = Game.GetCharAttachID(target)
        HandleAttackMonster() -- 执行攻击逻辑	--20250320.调整.by:初雨Ryan
        return true
    end
    return false
end

-- 读取攻击类型配置
function OnFightScriptLoad(configFile)
    -- 读取目标类型
    Config.fightTargetType = Util.ReadConfigInteger("fightTargetType", "fight", configFile)
    -- Config.fightTargetType = Form.GetCheckGroupActiveIndex("fightTargetType");
    if Config.fightTargetType == 5 then --怪物
        Form.SetCheckGroupActiveIndex("fightTargetType", 0);
    elseif Config.fightTargetType == 6 then --树
        Form.SetCheckGroupActiveIndex("fightTargetType", 1);
    elseif Config.fightTargetType == 7 then --矿石
        Form.SetCheckGroupActiveIndex("fightTargetType", 2);
    elseif Config.fightTargetType == 8 then --海上怪鱼
        Form.SetCheckGroupActiveIndex("fightTargetType", 3);
    elseif Config.fightTargetType == 9 then --船
        Form.SetCheckGroupActiveIndex("fightTargetType", 4);
    elseif Config.fightTargetType == 1 then --玩家
        Form.SetCheckGroupActiveIndex("fightTargetType", 5);
    end

    -- 读取攻击目标
    Config.fightTargetsStr = Util.ReadConfigString("fightTargetsStr", "fight", configFile)
    -- Form.SetEditValue("fightTarget", Config.fightTargetsStr); --读取后设置攻击目标编辑框值
	if Config.fightTargetsStr == "全部" or Config.fightTargetsStr == "" then		--20250321.调整.by:初雨Ryan
        Config.fightTargets = {} -- 清空目标列表
    else
        Config.fightTargets = Util.Split(Config.fightTargetsStr, ",") -- 使用“，”分隔目标
    end
    -- 读取使用技能
    for i = 1, Config.fightSkillMax do
        -- 读取技能名字
        Config.fightSkill[i].skillName = Util.ReadConfigString("fightSkill"..i, "fight", configFile)
        Form.SetCommandSkill("fightSkill"..i, Config.fightSkill[i].skillName)

        -- 读取技能设置CD
        Config.fightSkill[i].intervalTime = Util.ReadConfigInteger("SkillCd"..i, "fight", configFile)
        Form.SetEditValueInt("SkillCd"..i, Config.fightSkill[i].intervalTime)
    end

    -- 读取挂机点
    for i = 1, Config.fightPosMax do
        Config.fightPos[i].x = Util.ReadConfigFloat("fightPosX"..i, "fight", configFile)
        Config.fightPos[i].y = Util.ReadConfigFloat("fightPosY"..i, "fight", configFile)
        Form.SetEditValueFloat("fightPosX"..i, Config.fightPos[i].x)
        Form.SetEditValueFloat("fightPosY"..i, Config.fightPos[i].y)
    end

    -- 读取挂机范围
    Config.fightRange = Util.ReadConfigInteger("fightRange", "fight", configFile)
    Form.SetEditValueInt("fightRange", Config.fightRange)

    -- 读取原地挂机
    Config.fightStayHere = (Util.ReadConfigInteger("fightStayHere", "fight", configFile) == 1)
    if (Config.fightStayHere) then
        Form.SetCheckBoxValue("chkStayHere", 1)
    else
        Form.SetCheckBoxValue("chkStayHere", 0)
    end

    -- 读取空闲打坐
    Config.fightFreeSit = (Util.ReadConfigInteger("fightFreeSit", "fight", configFile) == 1)
    if (Config.fightFreeSit) then
        Form.SetCheckBoxValue("chkFreeSit", 1)
    else
        Form.SetCheckBoxValue("chkFreeSit", 0)
    end

    -- 读取仅用技能
    Config.fightOnlySkill = (Util.ReadConfigInteger("fightOnlySkill", "fight", configFile) == 1)
    if (Config.fightOnlySkill) then
        Form.SetCheckBoxValue("chkOnlySkill", 1)
    else
        Form.SetCheckBoxValue("chkOnlySkill", 0)
    end

    -- 读取选择医生挂机
    Config.fightOnlyDoctor = (Util.ReadConfigInteger("fightOnlyDoctor", "fight", configFile) == 1)
    if (Config.fightOnlyDoctor) then
        Form.SetCheckBoxValue("chkOnlyDoctor", 1)
    else
        Form.SetCheckBoxValue("chkOnlyDoctor", 0)
    end

 	-- 加载治愈术配置
     Config.useHealSkill = (Util.ReadConfigInteger("useHealSkill", "fight", configFile) == 1)
     if (Config.useHealSkill) then
         Form.SetCheckBoxValue("chkUseHealSkill", 1)
     else
         Form.SetCheckBoxValue("chkUseHealSkill", 0)
     end
     
    -- 读取治愈术血量阈值
     Config.healSkillHpThreshold = Util.ReadConfigInteger("healSkillHpThreshold", "fight", configFile)
     Form.SetEditValueInt("healSkillHpThreshold", Config.healSkillHpThreshold)

end

-- 存档攻击配置单
function OnFightScriptSave(configFile)
    -- 存档攻击类型
    local fightTargetTypeIndex = Form.GetCheckGroupActiveIndex("fightTargetType");
    if (fightTargetTypeIndex == 0) then
        Config.fightTargetType = 5 -- 普通怪物

    elseif (fightTargetTypeIndex == 1) then
        Config.fightTargetType = 6 -- 树

    elseif (fightTargetTypeIndex == 2) then
        Config.fightTargetType = 7 -- 矿石

    elseif (fightTargetTypeIndex == 3) then
        Config.fightTargetType = 8 -- 海上怪鱼

    elseif (fightTargetTypeIndex == 4) then
        Config.fightTargetType = 9 -- 船

    elseif (fightTargetTypeIndex == 5) then
        Config.fightTargetType = 1 -- 玩家

    else
        Config.fightTargetType = 5
    end
    Util.WriteConfigInteger(Config.fightTargetType, "fightTargetType", "fight", configFile)

    -- 存档攻击目标
--    Config.fightTargetsStr = Form.GetEditValue("fightTarget");
--    if (Config.fightTargetsStr ~= "" and Config.fightTargetsStr ~= "全部") then
--        Config.fightTargets = Util.Split(Config.fightTargetsStr, ",") -- 需要攻击的目标，并使用“，”来划分
	Config.fightTargetsStr = Form.GetEditValue("fightTarget")			--20250321.调整.by:初雨Ryan
    if Config.fightTargetsStr == "" or Config.fightTargetsStr == "全部" then
        Config.fightTargetsStr = "全部" -- 确保保存为“全部”
        Config.fightTargets = {} -- 清空目标列表
    else
		Config.fightTargets = Util.Split(Config.fightTargetsStr, ",") -- 使用“，”分隔目标
    end
    Util.WriteConfigString(Config.fightTargetsStr, "fightTargetsStr", "fight", configFile)

    -- 存档使用技能
    for i = 1, Config.fightSkillMax do
        -- 保存技能名字
        Config.fightSkill[i].skillName = Form.GetCommandText("fightSkill" .. i)
        Util.WriteConfigString(Config.fightSkill[i].skillName, "fightSkill" .. i, "fight", configFile)

        -- 保存技能设置CD
        Config.fightSkill[i].intervalTime = Form.GetEditValueInt("SkillCd" .. i)
        Util.WriteConfigInteger(Config.fightSkill[i].intervalTime, "SkillCd" .. i, "fight", configFile)
    end

    -- 存档挂机点
    for i = 1, Config.fightPosMax do
        Config.fightPos[i].x = Form.GetEditValueFloat("fightPosX" .. i)
        Config.fightPos[i].y = Form.GetEditValueFloat("fightPosY" .. i)
        Util.WriteConfigFloat(Config.fightPos[i].x, "fightPosX" .. i, "fight", configFile)
        Util.WriteConfigFloat(Config.fightPos[i].y, "fightPosY" .. i, "fight", configFile)
    end

    if (Config.fightPos[1].x <= 0 or Config.fightPos[1].y <= 0) then
        Config.fightPosCur.x = Game.GetCurX()
        Config.fightPosCur.y = Game.GetCurY()
        Config.fightPosIndex = 0
    else
        Config.fightPosCur.x = Config.fightPos[1].x
        Config.fightPosCur.y = Config.fightPos[1].y
        Config.fightPosIndex = 1
    end

    -- 存档挂机范围
    Config.fightRange = Form.GetEditValueInt("fightRange")
    if (Config.fightRange == 0) then Config.fightRange = 8 end
    Util.WriteConfigInteger(Config.fightRange, "fightRange", "fight", configFile)

    -- 存档原地挂机
    Config.fightStayHere = (Form.GetCheckBoxValue("chkStayHere") == 1)
    if (Config.fightStayHere) then
        Util.WriteConfigInteger(1, "fightStayHere", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "fightStayHere", "fight", configFile)
    end

    -- 存档空闲打坐
    Config.fightFreeSit = (Form.GetCheckBoxValue("chkFreeSit") == 1)
    if (Config.fightFreeSit) then
        Util.WriteConfigInteger(1, "fightFreeSit", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "fightFreeSit", "fight", configFile)
    end

    -- 存档仅用技能
    Config.fightOnlySkill = (Form.GetCheckBoxValue("chkOnlySkill") == 1)
    if (Config.fightOnlySkill) then
        Util.WriteConfigInteger(1, "fightOnlySkill", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "fightOnlySkill", "fight", configFile)
    end

    -- 存档医生挂机
    Config.fightOnlyDoctor = (Form.GetCheckBoxValue("chkOnlyDoctor") == 1)
    if (Config.fightOnlyDoctor) then
        Util.WriteConfigInteger(1, "fightOnlyDoctor", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "fightOnlyDoctor", "fight", configFile)
    end

    -- 保存治愈术配置
	Config.useHealSkill = (Form.GetCheckBoxValue("chkUseHealSkill") == 1)
    if (Config.useHealSkill) then
        Util.WriteConfigInteger(1, "useHealSkill", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "useHealSkill", "fight", configFile)
    end

    -- 存档治愈术血量阈值
	Config.healSkillHpThreshold = Form.GetEditValueInt("healSkillHpThreshold")
    if (Config.healSkillHpThreshold <= 0 or Config.healSkillHpThreshold == nil or Config.healSkillHpThreshold >= 100) then Config.healSkillHpThreshold = 85 end
	Util.WriteConfigInteger(Config.healSkillHpThreshold, "healSkillHpThreshold", "fight", configFile)

end

-- 修改函数：检测并使用增益技能	--20250320.调整增加.by:初雨Ryan
function UseBuffSkills()
    local buffSkills = {"心灵之火", "石化皮肤", "风之领主", "极速风暴", "天使护盾","回复术","回复温泉","魔力催化"}
    local now = os.clock() * skillAllTime

    for i = 1, Config.fightSkillMax do
        local skillName = Form.GetCommandText("fightSkill" .. i)
        local intervalTime = Config.fightSkill[i].intervalTime
        local nextSkTime = Config.fightSkill[i].nextSkTime or 0

        if skillName ~= "" and intervalTime ~= 0 and nextSkTime < now then
            for j = 1, table.getn(buffSkills) do
                local buffSkill = buffSkills[j]
                if skillName == buffSkill then
                    local skillPtr = Game.FindSkillByName(skillName)
                    if skillPtr ~= nil then
                        -- 对自己使用增益技能：仅在没有该状态时施放
                        local selfChar = Game.GetCurChar()
                        if Game.GetSkillStateNow(selfChar, skillName) == 0 then
                            Game.Attack(skillPtr, selfChar)
                            Config.fightSkill[i].nextSkTime = now + intervalTime * skillAllTime
                        end
                    end
                    break
                end
            end
        end
    end

    -- 检测血量低于阈值时使用治愈术
    if (Form.GetCheckBoxValue("chkUseHealSkill") == 1) then
        local healSkill = Game.FindSkillByName("治愈术")
        if healSkill ~= nil then
            local hp = Game.GetCharAttr(Game.GetCurChar(), ATTR_HP)
            local hpmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_HPMAX)
            local healThreshold = Form.GetEditValueInt("healSkillHpThreshold") -- 获取治愈术阈值
            if healThreshold == nil or healThreshold >= 100 then
                healThreshold = 85 -- 默认值
            end
            if hp < hpmax * (healThreshold / 100) then
                if Game.SkillIsAttackTime(healSkill) ~= 0 then
                    Game.SysInfo("治愈术不在冷却中，血量低于阀值，使用治愈术加血")
                    Game.Attack(healSkill, Game.GetCurChar()) -- 使用治愈术
                end    
            end
        end
    end
end
--打怪执行总脚本
function FightMonsters(nDeep)
    -- 深度检测
    if nDeep > 5 then return 0 end

    -- 检测并使用增益技能	--20250320.调整增加.by:初雨Ryan
    --if not Config.fightOnlyDoctor then
	if (Form.GetCheckBoxValue("chkOnlyDoctor") ~= 1) and (Form.GetCheckGroupActiveIndex("fightTargetType") == 0) then		--不开医生挂机并且目标为怪
        UseBuffSkills()
    end

   -- 寻找怪物
        if (fightState == 0) then -- 没有攻击状态，开始执行
            -- 如果正在跟随中，强制跟随，跳过所有其他逻辑
            if IsFollowing() then
                AutoFollow()
                return 0
            end
            
            -- 如果寻怪成功进入攻击状态
            if (HandleFindMonster() == true) then
                --Game.SysInfo("寻怪成功马上攻击")
                return NextState(nDeep, 1, true)
            else
                if Config.fightStayHere then -- 是否选择原地打怪
                    if IsOutAttackArea() then -- 检测目标范围
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit() -- 空闲打坐
                        AutoFollow()
                    end
                else
                    if (HandleNextPos() == true) then
                        --Game.SysInfo("开启移动下一个目标")
                        ClearAttackTarget()  ---清空攻击目标
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit()
                        AutoFollow()
                    end
                end
            end

            -- 攻击怪物
        elseif (fightState == 1) then
            -- 如果正在跟随中，强制跟随，跳过攻击
            if IsFollowing() then
                AutoFollow()
                return 0
            end
            
            -- 检测是否偏离挂机区 偏离了去寻找目标
            -- if IsOutAttackArea() then
			    -- Game.SysInfo("移动到范围目标")
                -- return NextState(nDeep, 2, true) -- 进入向目标移动
            -- end

            -- 如果攻击异常重新寻怪
            local attackState = HandleAttackMonster()
			--Game.SysInfo("马上攻击")
            if attackState == 1 or attackState == 2 or attackState == 4 then -- 目标HP小于0或者=0 为空重新寻找，或者超过20秒未死亡
			    --Game.SysInfo("目标有异常")
                return NextState(nDeep, 0, true)
            end

            -- 向挂机区移动
        elseif (fightState == 2) then
            -- 如果正在跟随中，强制跟随，跳过移动
            if IsFollowing() then
                AutoFollow()
                return 0
            end
            
            --Game.SysInfo("移动到目标")
            ClearAttackTarget()
            local dis = GetCurDistance(Config.fightPosCur.x, Config.fightPosCur.y)
            if (dis > 1) then
                -- 沿途打怪检测
                if (CheckMonsterAlongTheWay() == false) then	--20250320.调整.by:初雨Ryan
                    Game.MoveTo(Config.fightPosCur.x, Config.fightPosCur.y)
                end
                if IsStayPut() then
                    return NextState(nDeep, 2, true) -- 直接清空状态返回起始点
                end
            else
                stayputNUM = 0
                return NextState(nDeep, 0, true)
            end
        else
            Util.Debug("未知状态...")
        end
end 


---医生加状态总脚本
function DoDoctors(nDeep)
    -- 深度检测
	if (nDeep > 5) then 
		return 0 
	end
	
       -- 寻找队员
        if (fightState == 0) then -- 没有状态，开始执行
		
            --Game.SysInfo("寻找队友中ing")
            -- 如果找到队友成功进入补助状态
            if (HandleAddTeamState() == true) then
                AutoFollow()
                return NextState(nDeep, 1, true)
            else
                if (Config.fightStayHere) then
                    if (IsOutAttackArea()) then -- 检测目标范围
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit() -- 空闲打坐
                        AutoFollow() --跟随
                    end
                else
                    if (HandleNextPos() == true) then
                         --Game.SysInfo("开启移动下一个目标")
                        AutoFollow()
                        ClearAttackTarget()
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit()
                        AutoFollow()
                    end
                end
            end

            -- 帮助队员加状态ing
        elseif (fightState == 1) then
            -- 检测是否偏离挂机区 偏离了去寻找目标
            -- if (IsOutAttackArea()) then
                -- --Game.SysInfo("目标偏离")
				-- AutoFollow()
                -- --return NextState(nDeep, 2, true) -- 进入向目标移动
                -- --暂时不需要移动到角色
            -- end
            AutoFollow()
            -- 如果队员异常重新寻找
            local attackState = HandleAttackMonster()
            if (attackState == 1) or (attackState == 2) or (attackState == 3) then -- 目标为空重新寻找 && 目标HP小于0或者=0 重新寻找 && 目前已经有状态，重新寻找
                return NextState(nDeep, 0, true)
            end

            -- 向坐标区移动
        elseif (fightState == 2) then
            --Game.SysInfo("移动到目标")
            ClearAttackTarget()
            local dis = GetCurDistance(Config.fightPosCur.x, Config.fightPosCur.y)
            if (dis > 1) then
                Game.MoveTo(Config.fightPosCur.x, Config.fightPosCur.y)
            else
                return NextState(nDeep, 0, true)
            end
        else
            Util.Debug("未知状态...")
        end
end

-- 开始执行打怪总脚本
function DoFights(nDeep)
    -- 深度检测
	if (nDeep > 5) then 
		return 0 
	end
	
    if (Form.GetCheckBoxValue("chkOnlyDoctor") == 1) then
		 DoDoctors(nDeep)  --执行医生脚本
    else
	     FightMonsters(nDeep)  --执行打怪脚本
    end

    return 0
end



-- 检查是否正在跟随中
function IsFollowing()
    -- 如果勾选了空闲跟随，检查是否有跟随目标
    if (Form.GetCheckBoxValue("chkAutouFollow") == 1) then
        local Play_name = Form.GetEditValue("playFollw")
        if Play_name ~= nil and Play_name ~= "" then
            -- 使用更大的搜索范围来检查目标是否在远处（最大25格）
            local pPlay = Game.FindCharByName(Play_name, 1, math.min(Config.fightRange * 2, 25))
            if pPlay ~= nil then
                -- 如果能在正常范围内找到目标，说明距离较近，不需要强制跟随
                local pPlayNear = Game.FindCharByName(Play_name, 1, 5)
                if pPlayNear == nil then
                    -- 在远距离能找到，但在近距离找不到，说明距离较远，需要跟随
                    return true
                end
            else
                -- 如果在扩大范围内也找不到，说明目标很远或不存在，不进行跟随
                return false
            end
        end
    end
    return false
end
