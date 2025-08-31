----�޸ĵ���.by:����Ryan -20250828
----- �ű�״̬��
----1�������Ѽ�״̬���Բ�ȡ ��ʱ���ӷ�����һ����ɫ����״̬���ӳ�һ��ʱ�䣬�ٽ�����һ����ɫ	
----2��Ŀǰ���õ�ҽ����״̬������ ������ÿ�����ﲢ�ж��Ƿ�ȫ������״̬���ٽ�����һ�������״̬

local fightState = 0
local fightTmpState = 0
local stayputNUM = 0
-- ����Ŀ��
local fightTargetPtr = nil
local fightTargetId = -1

-- ����һ����ɱ�����ʱ������
local killTimer = 0

-- ���ܶ�ʱ����ȫ��
local skillAllTime = 1000

-- �ж�������һ��ʹ�ü���CDʱ��
function UseNextSkillCD(arrI, now, skName)
    local intervalTime = Config.fightSkill[arrI].intervalTime   -- ��ȡ���ü��ʱ��
    local nextSkTime = Config.fightSkill[arrI].nextSkTime   -- ��¼�´��ͷż��ܵ�CD
    if skName ~= "" and intervalTime ~= 0 then
        if nextSkTime < now then
            Config.fightSkill[arrI].nextSkTime = now + intervalTime * skillAllTime   -- ����һ�μ��ʱ��С��Ŀǰʱ����������CD
            return true
        end
    end
    return false
end

-- ��ȡ��������
function GetAttackSkillPtr()
    local pSkill = nil
    local pSkillName = nil
    for i = 1, Config.fightSkillMax do
        pSkillName = Form.GetCommandText("fightSkill" .. i)
        pSkill = Game.FindSkillByName(pSkillName)       -- ͨ���������ƻ�ȡ����ָ��
        if pSkill ~= nil and pSkillName ~= "������" then
            local now = os.clock() * skillAllTime
            if Game.SkillIsCanUse(pSkill) and UseNextSkillCD(i, now, pSkillName) then   -- �ж��Ƿ����ʹ�ü��� �� ������һ�μ���ʹ�õ�CD
                return pSkill
            end
        end
    end
    return nil
end

-- �������
function GetDistance(x1, y1, x2, y2)
    local offx = math.abs(x1 - x2)      -- ȡ����ֵ
    local offy = math.abs(y1 - y2)
    return math.sqrt(offx * offx + offy * offy) -- ���ؿ�ƽ��ֵ
end

-- ���㵱ǰ��ɫ��ĳ����ľ���
function GetCurDistance(x2, y2)
    return GetDistance(Game.GetCurX(), Game.GetCurY(), x2, y2)
end

-- ��Χ���
function IsOutAttackArea(bIsFree)
    local distance = GetCurDistance(Config.fightPosCur.x, Config.fightPosCur.y)
    if bIsFree then
        return distance > 1
    end
    return distance > Config.fightRange
end
-- �жϽ�ɫ�Ƿ����ԭ��
function IsStayPut()
    stayputNUM = stayputNUM + 1
    if stayputNUM >= 20 then
        stayputNUM = 0
        return true
    end
    return false
end

-- ����Ѱ��״̬
function HandleFindMonster()
    if (fightTargetPtr == nil) then
        -- Ŀ��Ϊ�գ���ʼͨ�� ���� Ŀ�� �Ƿ��� ��Χ ��Ѱ��Ŀ��
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr) -- ��ȡѰ�ҵ�Ŀ���ID
        return fightTargetId > 0
    end

    local attachId = Game.GetCharAttachID(fightTargetPtr)
    if (fightTargetId ~= attachId) then -- Ѱ�ҵ���Ŀ���Ŀǰ����Ŀ�겻ͬʱ ����Ѱ�ҹ���Ŀ��
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end

    local hp = Game.GetCharAttr(fightTargetPtr, ATTR_HP) -- ��ȡѰ�ҵ�Ŀ���HP
    if (hp <= 0) then -- ��HPС��0���ڿ�ʼ����Ѱ�ҹ���
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end

    return true
end

-- ��ȡ�������Ա�����ַ���
function GetTeamName()
    for i = 1, Config.teamMaxinfo, 1 do
        local teamName = Form.GetEditValue("play"..i)
		--local teamName = Game.GetTeamCharName(i)
		--Game.SysInfo(""..i.." "..teamName.."")
        if (teamName ~= "") and Config.teamInfo[i].state ~= 1 then
            Config.fightAddTargets = {} --����ǰ�����ÿձ�
            table.insert(Config.fightAddTargets, teamName) --����Ŀ������
            Config.teamInfo[i].state = 1 --�����˼�״̬��־
            break
        end

        if (teamName ~= "") and Config.teamInfo[i].state == 1 then
            Config.teamInfo[i].state = 0 --ѭ�����ȫ����ʼ��״̬Ϊ0
        end
    end

end

-- ����ҽ��Ѱ����״̬
function HandleAddTeamState()
    if fightTargetPtr == nil then
        GetTeamName() -- ��ȡĿ��
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightAddTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end

    local attachId = Game.GetCharAttachID(fightTargetPtr)
    if (fightTargetId ~= attachId) then -- Ѱ�ҵ���Ŀ���Ŀǰ����Ŀ�겻ͬʱ ����Ѱ�ҹ���Ŀ��
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightAddTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end

    local hp = Game.GetCharAttr(fightTargetPtr, ATTR_HP) -- ��ȡѰ�ҵ�Ŀ���HP
    if (hp == nil or hp <= 0) then -- ��HPС��0���ڿ�ʼ����Ѱ�ҹ���
        fightTargetPtr = Game.FindCharByEveryName(Config.fightTargetType, Config.fightAddTargets, 1, Config.fightRange)
        fightTargetId = Game.GetCharAttachID(fightTargetPtr)
        return fightTargetId > 0
    end
	
    return true

end

-- �һ���Ѳ��
function HandleNextPos()
    local startIndex = Config.fightPosIndex
    for i = 1, Config.fightPosMax do
        -- ֱ������������ȷ���ڷ�Χ��
        Config.fightPosIndex = Config.fightPosIndex + 1
        if Config.fightPosIndex > Config.fightPosMax then
            Config.fightPosIndex = 1
        end
        
        if (Config.fightPos[Config.fightPosIndex].x > 0 and
            Config.fightPos[Config.fightPosIndex].y > 0) then
            Config.fightPosCur.x = Config.fightPos[Config.fightPosIndex].x
            Config.fightPosCur.y = Config.fightPos[Config.fightPosIndex].y
                Game.SysInfo("��ʼǰ���һ���"..Config.fightPosIndex.." ")
            return true
        end
        
        -- ����Ѿ������һȦ��û�ҵ���Ч�㣬�˳�
        if Config.fightPosIndex == startIndex then
            break
        end
    end
    Config.fightPosIndex = 0
    return false
end

-- ������д���
function HandleFreeSit()
    -- Game.SysInfo("��ʼ����")
    -- ���д���δ��������
    if (Config.fightFreeSit ~= true) then return end

    -- HP�������
    local hp = Game.GetCharAttr(Game.GetCurChar(), ATTR_HP)
    local hpmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_HPMAX)
    if (hp <= (hpmax * 0.98)) then
        Game.SitDown()
        return
    end

    -- SP�������
    local sp = Game.GetCharAttr(Game.GetCurChar(), ATTR_SP)
    local spmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_SPMAX)
    if (sp <= (spmax * 0.98)) then
        Game.SitDown()
        return
    end

    -- HP SP ���棬���վ��
    Game.StandUp()
end

--�����Զ������Զ����
function  AutoFollow()
    --�жϸ���
    if (Form.GetCheckBoxValue("chkAutouFollow") ~= 1 ) then
        return      
    end
	
    local Play_name = Form.GetEditValue("playFollw")
    if Play_name == nil or Play_name == "" then 
        Game.SysInfo("��ѡ�������Ҫ�����Ŀ��")
	    return 
	end
	
    local pPlay = Game.FindCharByName(Play_name ,1 , math.min(Config.fightRange * 2, 25))
    if pPlay == nil then 
	   return 
	end
    Game.AutoFollow(pPlay)
end

-- ��չ���Ŀ��
function ClearAttackTarget()
    fightTargetPtr = nil
    fightTargetId = -1
end

--�ж�Ŀ���Ƿ������õ�ȫ��״̬���з���true �޷���false
function IsAddStates(player)
    local hp = Game.GetCharAttr(player, ATTR_HP) 
	local hpmax = Game.GetCharAttr(player, ATTR_HPMAX)
	--local str = {"ʯ��Ƥ��", "��֮����", "����֮��"}
    for i = 1, Config.fightSkillMax do
       local sName = Form.GetCommandText("fightSkill" ..i) --��ȡ���ܿ�����
       local sKillCd = Form.GetEditValueInt("SkillCd" ..i) --��ȡ���ü���cd��ֵ
        if (sName ~= "") and sKillCd ~= "" and sName ~= "������" and sName ~= "�ظ���" and sName ~= "��������" and sName ~= "�����ײ" then
           if (Game.GetSkillStateNow(player, sName) == 0) then --�жϼ����Ƿ���״̬
			   return false
           end
        end 
    end
    return true --�������ʾ����״̬
 end

-- ������״̬ 0������������1��Ŀ�겻���� 2��Ŀ�������� 3��Ŀǰ�Ƿ���״̬��ҽ���ã� 4��Ŀ�곬��20��δ����
function HandleAttackMonster()
    
    -- �ж�Ŀ���Ƿ�Ϊ��
    if (fightTargetPtr == nil or fightTargetId < 0) then 
        ClearAttackTarget()
        return 1
    end

    -- �ж�Ŀ���HP�Ƿ�С�ڵ���0
    local hp = Game.GetCharAttr(fightTargetPtr, ATTR_HP) 
	local hpmax = Game.GetCharAttr(fightTargetPtr, ATTR_HPMAX)
    if (hp == nil or hpmax == nil or hp <= 0) then
        ClearAttackTarget()
        return 2
    end
	
    -- �ж�Ŀ���Ƿ񳬹�20��δ����
    local now = os.clock()
    if (killTimer == 0) then
        killTimer = now -- ��ʼ��ʱ
    elseif (now - killTimer >= 20) then
        ClearAttackTarget()
        killTimer = 0 -- ���ü�ʱ��
        return 4 -- ����״̬4����ʾĿ�곬��20��δ����
    end
	
    -- ���Ѫ��������ֵʱʹ��������
    if (Form.GetCheckGroupActiveIndex("fightTargetType") == 5) and (Form.GetCheckBoxValue("chkUseHealSkill") == 1) then
        -- ��ȡ����������
        local healSkill = Game.FindSkillByName("������")
        if healSkill ~= nil then
            -- �ж�Ŀ��Ѫ���Ƿ�������õİٷֱ�
            local healThreshold = Form.GetEditValueInt("healSkillHpThreshold")
            if healThreshold == nil or healThreshold >= 100 then
                healThreshold = 85 -- Ĭ��ֵ
            end
            if hp < hpmax * (healThreshold / 100) then
                if Game.SkillIsAttackTime(healSkill) ~= 0 then
                    Game.SysInfo("������������ȴ�У���Ŀ��Ѫ�����ڷ�ֵ��ʹ����������Ѫ")
                    -- ʹ����������Ѫ
                    Game.Attack(healSkill, fightTargetPtr)
                end
                return 0
            end
        end
    end

    local pSkill = GetAttackSkillPtr()
    if (pSkill == nil and Config.fightOnlySkill) then
        HandleFreeSit() -- ������д���
        AutoFollow() --����
        return 0
    end

    local isSelf = Game.SkillIsTypeSelf(pSkill) -- �ж�Ŀ���Ƿ����Լ�
    if (isSelf == 1) then
        Game.Attack(pSkill, Game.GetCurChar()) -- ��ʼ�������Լ�����
        return 0
    end
    
    --�ж�Ŀ���Ƿ������е�״̬
    if (Form.GetCheckBoxValue("chkOnlyDoctor") == 1) and (IsAddStates(fightTargetPtr)) then 
        ClearAttackTarget()
        return 3
    end
	
    Game.Attack(pSkill, fightTargetPtr)
    return 0
end

-- ������һ��״̬ nDeep���������룬nNextState����һ��״̬��bNow���Ƿ�����ִ��
function NextState(nDeep, nNextState, bNow)
    fightState = nNextState
    if (bNow) then 
        return DoFights(nDeep + 1) 
    end
    return 0
end

-- ��;��ּ��
function CheckMonsterAlongTheWay()
    local target = Game.FindCharByEveryName(Config.fightTargetType, Config.fightTargets, 1, Config.fightRange)
    if target  then
        fightTargetPtr = target
        fightTargetId = Game.GetCharAttachID(target)
        HandleAttackMonster() -- ִ�й����߼�	--20250320.����.by:����Ryan
        return true
    end
    return false
end

-- ��ȡ������������
function OnFightScriptLoad(configFile)
    -- ��ȡĿ������
    Config.fightTargetType = Util.ReadConfigInteger("fightTargetType", "fight", configFile)
    -- Config.fightTargetType = Form.GetCheckGroupActiveIndex("fightTargetType");
    if Config.fightTargetType == 5 then --����
        Form.SetCheckGroupActiveIndex("fightTargetType", 0);
    elseif Config.fightTargetType == 6 then --��
        Form.SetCheckGroupActiveIndex("fightTargetType", 1);
    elseif Config.fightTargetType == 7 then --��ʯ
        Form.SetCheckGroupActiveIndex("fightTargetType", 2);
    elseif Config.fightTargetType == 8 then --���Ϲ���
        Form.SetCheckGroupActiveIndex("fightTargetType", 3);
    elseif Config.fightTargetType == 9 then --��
        Form.SetCheckGroupActiveIndex("fightTargetType", 4);
    elseif Config.fightTargetType == 1 then --���
        Form.SetCheckGroupActiveIndex("fightTargetType", 5);
    end

    -- ��ȡ����Ŀ��
    Config.fightTargetsStr = Util.ReadConfigString("fightTargetsStr", "fight", configFile)
    -- Form.SetEditValue("fightTarget", Config.fightTargetsStr); --��ȡ�����ù���Ŀ��༭��ֵ
	if Config.fightTargetsStr == "ȫ��" or Config.fightTargetsStr == "" then		--20250321.����.by:����Ryan
        Config.fightTargets = {} -- ���Ŀ���б�
    else
        Config.fightTargets = Util.Split(Config.fightTargetsStr, ",") -- ʹ�á������ָ�Ŀ��
    end
    -- ��ȡʹ�ü���
    for i = 1, Config.fightSkillMax do
        -- ��ȡ��������
        Config.fightSkill[i].skillName = Util.ReadConfigString("fightSkill"..i, "fight", configFile)
        Form.SetCommandSkill("fightSkill"..i, Config.fightSkill[i].skillName)

        -- ��ȡ��������CD
        Config.fightSkill[i].intervalTime = Util.ReadConfigInteger("SkillCd"..i, "fight", configFile)
        Form.SetEditValueInt("SkillCd"..i, Config.fightSkill[i].intervalTime)
    end

    -- ��ȡ�һ���
    for i = 1, Config.fightPosMax do
        Config.fightPos[i].x = Util.ReadConfigFloat("fightPosX"..i, "fight", configFile)
        Config.fightPos[i].y = Util.ReadConfigFloat("fightPosY"..i, "fight", configFile)
        Form.SetEditValueFloat("fightPosX"..i, Config.fightPos[i].x)
        Form.SetEditValueFloat("fightPosY"..i, Config.fightPos[i].y)
    end

    -- ��ȡ�һ���Χ
    Config.fightRange = Util.ReadConfigInteger("fightRange", "fight", configFile)
    Form.SetEditValueInt("fightRange", Config.fightRange)

    -- ��ȡԭ�عһ�
    Config.fightStayHere = (Util.ReadConfigInteger("fightStayHere", "fight", configFile) == 1)
    if (Config.fightStayHere) then
        Form.SetCheckBoxValue("chkStayHere", 1)
    else
        Form.SetCheckBoxValue("chkStayHere", 0)
    end

    -- ��ȡ���д���
    Config.fightFreeSit = (Util.ReadConfigInteger("fightFreeSit", "fight", configFile) == 1)
    if (Config.fightFreeSit) then
        Form.SetCheckBoxValue("chkFreeSit", 1)
    else
        Form.SetCheckBoxValue("chkFreeSit", 0)
    end

    -- ��ȡ���ü���
    Config.fightOnlySkill = (Util.ReadConfigInteger("fightOnlySkill", "fight", configFile) == 1)
    if (Config.fightOnlySkill) then
        Form.SetCheckBoxValue("chkOnlySkill", 1)
    else
        Form.SetCheckBoxValue("chkOnlySkill", 0)
    end

    -- ��ȡѡ��ҽ���һ�
    Config.fightOnlyDoctor = (Util.ReadConfigInteger("fightOnlyDoctor", "fight", configFile) == 1)
    if (Config.fightOnlyDoctor) then
        Form.SetCheckBoxValue("chkOnlyDoctor", 1)
    else
        Form.SetCheckBoxValue("chkOnlyDoctor", 0)
    end

 	-- ��������������
     Config.useHealSkill = (Util.ReadConfigInteger("useHealSkill", "fight", configFile) == 1)
     if (Config.useHealSkill) then
         Form.SetCheckBoxValue("chkUseHealSkill", 1)
     else
         Form.SetCheckBoxValue("chkUseHealSkill", 0)
     end
     
    -- ��ȡ������Ѫ����ֵ
     Config.healSkillHpThreshold = Util.ReadConfigInteger("healSkillHpThreshold", "fight", configFile)
     Form.SetEditValueInt("healSkillHpThreshold", Config.healSkillHpThreshold)

end

-- �浵�������õ�
function OnFightScriptSave(configFile)
    -- �浵��������
    local fightTargetTypeIndex = Form.GetCheckGroupActiveIndex("fightTargetType");
    if (fightTargetTypeIndex == 0) then
        Config.fightTargetType = 5 -- ��ͨ����

    elseif (fightTargetTypeIndex == 1) then
        Config.fightTargetType = 6 -- ��

    elseif (fightTargetTypeIndex == 2) then
        Config.fightTargetType = 7 -- ��ʯ

    elseif (fightTargetTypeIndex == 3) then
        Config.fightTargetType = 8 -- ���Ϲ���

    elseif (fightTargetTypeIndex == 4) then
        Config.fightTargetType = 9 -- ��

    elseif (fightTargetTypeIndex == 5) then
        Config.fightTargetType = 1 -- ���

    else
        Config.fightTargetType = 5
    end
    Util.WriteConfigInteger(Config.fightTargetType, "fightTargetType", "fight", configFile)

    -- �浵����Ŀ��
--    Config.fightTargetsStr = Form.GetEditValue("fightTarget");
--    if (Config.fightTargetsStr ~= "" and Config.fightTargetsStr ~= "ȫ��") then
--        Config.fightTargets = Util.Split(Config.fightTargetsStr, ",") -- ��Ҫ������Ŀ�꣬��ʹ�á�����������
	Config.fightTargetsStr = Form.GetEditValue("fightTarget")			--20250321.����.by:����Ryan
    if Config.fightTargetsStr == "" or Config.fightTargetsStr == "ȫ��" then
        Config.fightTargetsStr = "ȫ��" -- ȷ������Ϊ��ȫ����
        Config.fightTargets = {} -- ���Ŀ���б�
    else
		Config.fightTargets = Util.Split(Config.fightTargetsStr, ",") -- ʹ�á������ָ�Ŀ��
    end
    Util.WriteConfigString(Config.fightTargetsStr, "fightTargetsStr", "fight", configFile)

    -- �浵ʹ�ü���
    for i = 1, Config.fightSkillMax do
        -- ���漼������
        Config.fightSkill[i].skillName = Form.GetCommandText("fightSkill" .. i)
        Util.WriteConfigString(Config.fightSkill[i].skillName, "fightSkill" .. i, "fight", configFile)

        -- ���漼������CD
        Config.fightSkill[i].intervalTime = Form.GetEditValueInt("SkillCd" .. i)
        Util.WriteConfigInteger(Config.fightSkill[i].intervalTime, "SkillCd" .. i, "fight", configFile)
    end

    -- �浵�һ���
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

    -- �浵�һ���Χ
    Config.fightRange = Form.GetEditValueInt("fightRange")
    if (Config.fightRange == 0) then Config.fightRange = 8 end
    Util.WriteConfigInteger(Config.fightRange, "fightRange", "fight", configFile)

    -- �浵ԭ�عһ�
    Config.fightStayHere = (Form.GetCheckBoxValue("chkStayHere") == 1)
    if (Config.fightStayHere) then
        Util.WriteConfigInteger(1, "fightStayHere", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "fightStayHere", "fight", configFile)
    end

    -- �浵���д���
    Config.fightFreeSit = (Form.GetCheckBoxValue("chkFreeSit") == 1)
    if (Config.fightFreeSit) then
        Util.WriteConfigInteger(1, "fightFreeSit", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "fightFreeSit", "fight", configFile)
    end

    -- �浵���ü���
    Config.fightOnlySkill = (Form.GetCheckBoxValue("chkOnlySkill") == 1)
    if (Config.fightOnlySkill) then
        Util.WriteConfigInteger(1, "fightOnlySkill", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "fightOnlySkill", "fight", configFile)
    end

    -- �浵ҽ���һ�
    Config.fightOnlyDoctor = (Form.GetCheckBoxValue("chkOnlyDoctor") == 1)
    if (Config.fightOnlyDoctor) then
        Util.WriteConfigInteger(1, "fightOnlyDoctor", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "fightOnlyDoctor", "fight", configFile)
    end

    -- ��������������
	Config.useHealSkill = (Form.GetCheckBoxValue("chkUseHealSkill") == 1)
    if (Config.useHealSkill) then
        Util.WriteConfigInteger(1, "useHealSkill", "fight", configFile)
    else
        Util.WriteConfigInteger(0, "useHealSkill", "fight", configFile)
    end

    -- �浵������Ѫ����ֵ
	Config.healSkillHpThreshold = Form.GetEditValueInt("healSkillHpThreshold")
    if (Config.healSkillHpThreshold <= 0 or Config.healSkillHpThreshold == nil or Config.healSkillHpThreshold >= 100) then Config.healSkillHpThreshold = 85 end
	Util.WriteConfigInteger(Config.healSkillHpThreshold, "healSkillHpThreshold", "fight", configFile)

end

-- �޸ĺ�������Ⲣʹ�����漼��	--20250320.��������.by:����Ryan
function UseBuffSkills()
    local buffSkills = {"����֮��", "ʯ��Ƥ��", "��֮����", "���ٷ籩", "��ʹ����","�ظ���","�ظ���Ȫ","ħ���߻�"}
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
                        -- ���Լ�ʹ�����漼�ܣ�����û�и�״̬ʱʩ��
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

    -- ���Ѫ��������ֵʱʹ��������
    if (Form.GetCheckBoxValue("chkUseHealSkill") == 1) then
        local healSkill = Game.FindSkillByName("������")
        if healSkill ~= nil then
            local hp = Game.GetCharAttr(Game.GetCurChar(), ATTR_HP)
            local hpmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_HPMAX)
            local healThreshold = Form.GetEditValueInt("healSkillHpThreshold") -- ��ȡ��������ֵ
            if healThreshold == nil or healThreshold >= 100 then
                healThreshold = 85 -- Ĭ��ֵ
            end
            if hp < hpmax * (healThreshold / 100) then
                if Game.SkillIsAttackTime(healSkill) ~= 0 then
                    Game.SysInfo("������������ȴ�У�Ѫ�����ڷ�ֵ��ʹ����������Ѫ")
                    Game.Attack(healSkill, Game.GetCurChar()) -- ʹ��������
                end    
            end
        end
    end
end
--���ִ���ܽű�
function FightMonsters(nDeep)
    -- ��ȼ��
    if nDeep > 5 then return 0 end

    -- ��Ⲣʹ�����漼��	--20250320.��������.by:����Ryan
    --if not Config.fightOnlyDoctor then
	if (Form.GetCheckBoxValue("chkOnlyDoctor") ~= 1) and (Form.GetCheckGroupActiveIndex("fightTargetType") == 0) then		--����ҽ���һ�����Ŀ��Ϊ��
        UseBuffSkills()
    end

   -- Ѱ�ҹ���
        if (fightState == 0) then -- û�й���״̬����ʼִ��
            -- ������ڸ����У�ǿ�Ƹ��棬�������������߼�
            if IsFollowing() then
                AutoFollow()
                return 0
            end
            
            -- ���Ѱ�ֳɹ����빥��״̬
            if (HandleFindMonster() == true) then
                --Game.SysInfo("Ѱ�ֳɹ����Ϲ���")
                return NextState(nDeep, 1, true)
            else
                if Config.fightStayHere then -- �Ƿ�ѡ��ԭ�ش��
                    if IsOutAttackArea() then -- ���Ŀ�귶Χ
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit() -- ���д���
                        AutoFollow()
                    end
                else
                    if (HandleNextPos() == true) then
                        --Game.SysInfo("�����ƶ���һ��Ŀ��")
                        ClearAttackTarget()  ---��չ���Ŀ��
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit()
                        AutoFollow()
                    end
                end
            end

            -- ��������
        elseif (fightState == 1) then
            -- ������ڸ����У�ǿ�Ƹ��棬��������
            if IsFollowing() then
                AutoFollow()
                return 0
            end
            
            -- ����Ƿ�ƫ��һ��� ƫ����ȥѰ��Ŀ��
            -- if IsOutAttackArea() then
			    -- Game.SysInfo("�ƶ�����ΧĿ��")
                -- return NextState(nDeep, 2, true) -- ������Ŀ���ƶ�
            -- end

            -- ��������쳣����Ѱ��
            local attackState = HandleAttackMonster()
			--Game.SysInfo("���Ϲ���")
            if attackState == 1 or attackState == 2 or attackState == 4 then -- Ŀ��HPС��0����=0 Ϊ������Ѱ�ң����߳���20��δ����
			    --Game.SysInfo("Ŀ�����쳣")
                return NextState(nDeep, 0, true)
            end

            -- ��һ����ƶ�
        elseif (fightState == 2) then
            -- ������ڸ����У�ǿ�Ƹ��棬�����ƶ�
            if IsFollowing() then
                AutoFollow()
                return 0
            end
            
            --Game.SysInfo("�ƶ���Ŀ��")
            ClearAttackTarget()
            local dis = GetCurDistance(Config.fightPosCur.x, Config.fightPosCur.y)
            if (dis > 1) then
                -- ��;��ּ��
                if (CheckMonsterAlongTheWay() == false) then	--20250320.����.by:����Ryan
                    Game.MoveTo(Config.fightPosCur.x, Config.fightPosCur.y)
                end
                if IsStayPut() then
                    return NextState(nDeep, 2, true) -- ֱ�����״̬������ʼ��
                end
            else
                stayputNUM = 0
                return NextState(nDeep, 0, true)
            end
        else
            Util.Debug("δ֪״̬...")
        end
end 


---ҽ����״̬�ܽű�
function DoDoctors(nDeep)
    -- ��ȼ��
	if (nDeep > 5) then 
		return 0 
	end
	
       -- Ѱ�Ҷ�Ա
        if (fightState == 0) then -- û��״̬����ʼִ��
		
            --Game.SysInfo("Ѱ�Ҷ�����ing")
            -- ����ҵ����ѳɹ����벹��״̬
            if (HandleAddTeamState() == true) then
                AutoFollow()
                return NextState(nDeep, 1, true)
            else
                if (Config.fightStayHere) then
                    if (IsOutAttackArea()) then -- ���Ŀ�귶Χ
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit() -- ���д���
                        AutoFollow() --����
                    end
                else
                    if (HandleNextPos() == true) then
                         --Game.SysInfo("�����ƶ���һ��Ŀ��")
                        AutoFollow()
                        ClearAttackTarget()
                        return NextState(nDeep, 2, true)
                    else
                        HandleFreeSit()
                        AutoFollow()
                    end
                end
            end

            -- ������Ա��״̬ing
        elseif (fightState == 1) then
            -- ����Ƿ�ƫ��һ��� ƫ����ȥѰ��Ŀ��
            -- if (IsOutAttackArea()) then
                -- --Game.SysInfo("Ŀ��ƫ��")
				-- AutoFollow()
                -- --return NextState(nDeep, 2, true) -- ������Ŀ���ƶ�
                -- --��ʱ����Ҫ�ƶ�����ɫ
            -- end
            AutoFollow()
            -- �����Ա�쳣����Ѱ��
            local attackState = HandleAttackMonster()
            if (attackState == 1) or (attackState == 2) or (attackState == 3) then -- Ŀ��Ϊ������Ѱ�� && Ŀ��HPС��0����=0 ����Ѱ�� && Ŀǰ�Ѿ���״̬������Ѱ��
                return NextState(nDeep, 0, true)
            end

            -- ���������ƶ�
        elseif (fightState == 2) then
            --Game.SysInfo("�ƶ���Ŀ��")
            ClearAttackTarget()
            local dis = GetCurDistance(Config.fightPosCur.x, Config.fightPosCur.y)
            if (dis > 1) then
                Game.MoveTo(Config.fightPosCur.x, Config.fightPosCur.y)
            else
                return NextState(nDeep, 0, true)
            end
        else
            Util.Debug("δ֪״̬...")
        end
end

-- ��ʼִ�д���ܽű�
function DoFights(nDeep)
    -- ��ȼ��
	if (nDeep > 5) then 
		return 0 
	end
	
    if (Form.GetCheckBoxValue("chkOnlyDoctor") == 1) then
		 DoDoctors(nDeep)  --ִ��ҽ���ű�
    else
	     FightMonsters(nDeep)  --ִ�д�ֽű�
    end

    return 0
end



-- ����Ƿ����ڸ�����
function IsFollowing()
    -- �����ѡ�˿��и��棬����Ƿ��и���Ŀ��
    if (Form.GetCheckBoxValue("chkAutouFollow") == 1) then
        local Play_name = Form.GetEditValue("playFollw")
        if Play_name ~= nil and Play_name ~= "" then
            -- ʹ�ø����������Χ�����Ŀ���Ƿ���Զ�������25��
            local pPlay = Game.FindCharByName(Play_name, 1, math.min(Config.fightRange * 2, 25))
            if pPlay ~= nil then
                -- �������������Χ���ҵ�Ŀ�꣬˵������Ͻ�������Ҫǿ�Ƹ���
                local pPlayNear = Game.FindCharByName(Play_name, 1, 5)
                if pPlayNear == nil then
                    -- ��Զ�������ҵ������ڽ������Ҳ�����˵�������Զ����Ҫ����
                    return true
                end
            else
                -- ���������Χ��Ҳ�Ҳ�����˵��Ŀ���Զ�򲻴��ڣ������и���
                return false
            end
        end
    end
    return false
end
