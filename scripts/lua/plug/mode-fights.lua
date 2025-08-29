-- 脚本状态机
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
        pSkill = Game.FindSkillByName(pSkillName)   -- 通过技能名称获取技能指针
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
    local offx = math.abs(x1 - x2) -- 取绝对值
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
function HanldeFindMonster()
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

-- 挂机点巡逻
function HanldeNextPos()
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

-- 清空攻击目标
function ClearAttackTarget()
    fightTargetPtr = nil
    fightTargetId = -1
end

-- 处理攻击状态 0：正常攻击，1：目标不存在 2：目标已死亡 4：目标超过20秒未死亡
function HanldeAttackMonster()
    
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

    local pSkill = GetAttackSkillPtr()
    if (pSkill == nil and Config.fightOnlySkill) then
        HandleFreeSit() -- 处理空闲打坐
        return 0
    end

    local isSelf = Game.SkillIsTypeSelf(pSkill) -- 判断目标是否是自己
    if (isSelf == 1) then
        Game.Attack(pSkill, Game.GetCurChar()) -- 开始正常对自己攻击
        return 0
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
        HanldeAttackMonster() -- 执行攻击逻辑
        return true
    end
    return false
end

-- 读取攻击类型配置
function OnFightScriptLoad(configFile)
    -- 读取目标类型
    Config.fightTargetType = Util.ReadConfigInteger("fightTargetType", "fight", configFile)
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
    end

    -- 读取攻击目标
    Config.fightTargetsStr = Util.ReadConfigString("fightTargetsStr", "fight", configFile)
    if Config.fightTargetsStr == "全部" or Config.fightTargetsStr == "" then
        Config.fightTargets = {} -- 清空目标列表
    else
        Config.fightTargets = Util.Split(Config.fightTargetsStr, ",") -- 使用"，"分隔目标
    end
    
    -- 读取使用技能
    for i = 1, Config.fightSkillMax do
        -- 读取技能名字
        Config.fightSkill[i].skillName = Util.ReadConfigString("fightSkill"..i, "fight", configFile)
        Form.SetCommandSkill("fightSkill"..i, Config.fightSkill[i].skillName)

        -- 读取技能设置CD
        Config.fightSkill[i].intervalTime = Util.ReadConfigInteger("SkillCd"..i, "fight", configFile)
        if Config.fightSkill[i].intervalTime == nil then
            Config.fightSkill[i].intervalTime = 1
        end
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
    else
        Config.fightTargetType = 5
    end
    Util.WriteConfigInteger(Config.fightTargetType, "fightTargetType", "fight", configFile)

    -- 存档攻击目标
    Config.fightTargetsStr = Form.GetEditValue("fightTarget")
    if Config.fightTargetsStr == "" or Config.fightTargetsStr == "全部" then
        Config.fightTargetsStr = "全部" -- 确保保存为"全部"
        Config.fightTargets = {} -- 清空目标列表
    else
        Config.fightTargets = Util.Split(Config.fightTargetsStr, ",") -- 使用"，"分隔目标
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
end

-- 修改函数：检测并使用增益技能
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
                        -- 对自己使用增益技能
                        Game.Attack(skillPtr, Game.GetCurChar())
                        Config.fightSkill[i].nextSkTime = now + intervalTime * skillAllTime
                    end
                    break
                end
            end
        end
    end
end

--打怪执行总脚本
function FightMonsters(nDeep)
    -- 深度检测
    if nDeep > 5 then return 0 end

    -- 检测并使用增益技能
    if (Form.GetCheckGroupActiveIndex("fightTargetType") == 0) then		--目标为怪
        UseBuffSkills()
    end

   -- 寻找怪物
        if (fightState == 0) then -- 没有攻击状态，开始执行
            -- 如果寻怪成功进入攻击状态
            if (HanldeFindMonster() == true) then
                return NextState(nDeep, 1, true)
            else
                if Config.fightStayHere then -- 是否选择原地打怪
                    if IsOutAttackArea() then -- 检测目标范围
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit() -- 空闲打坐
                    end
                else
                    if (HanldeNextPos() == true) then
                        ClearAttackTarget()  ---清空攻击目标
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit()
                    end
                end
            end

            -- 攻击怪物
        elseif (fightState == 1) then
            -- 如果攻击异常重新寻怪
            local attackState = HanldeAttackMonster()
            if attackState == 1 or attackState == 2 or attackState == 4 then -- 目标HP小于0或者=0 为空重新寻找，或者超过20秒未死亡
                return NextState(nDeep, 0, true)
            end

            -- 向挂机区移动
        elseif (fightState == 2) then
            ClearAttackTarget()
            local dis = GetCurDistance(Config.fightPosCur.x, Config.fightPosCur.y)
            if (dis > 1) then
                -- 沿途打怪检测
                if (CheckMonsterAlongTheWay() == false) then
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

-- 开始执行打怪总脚本
function DoFights(nDeep)
    -- 深度检测
    if (nDeep > 5) then 
        return 0 
    end
    
    FightMonsters(nDeep)  --执行打怪脚本

    return 0
end