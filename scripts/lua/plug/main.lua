----�޸ĵ���.by:����Ryan -20250824
-- ����״̬
local bIsLoaded = false
local announcementLastTime = 0

ATTR_HP = 1
ATTR_SP = 2
ATTR_HPMAX = 31
ATTR_SPMAX = 32
	
Util = {}
Form = {}
Game = {}

Config = 
{ 
	enableDebug = true,
	
	chkPlugMode01 = 1,
	chkPlugMode02 = 0,
	chkPlugMode03 = 0,

	fightPosIndex = 0,
	fightPosMax = 20,  -- ʵ�ʹһ�������
	fightPosCur = { x = 0.0, y = 0.0 },
	fightPos = {
		{ x = 0.0, y = 0.0 },  		--1
		{ x = 0.0, y = 0.0 },  		--2
		{ x = 0.0, y = 0.0 },  		--3
		{ x = 0.0, y = 0.0 },  		--4
		{ x = 0.0, y = 0.0 },  		--5
		{ x = 0.0, y = 0.0 },  		--6
		{ x = 0.0, y = 0.0 },  		--7
		{ x = 0.0, y = 0.0 },  		--8
		{ x = 0.0, y = 0.0 },  		--9
		{ x = 0.0, y = 0.0 },  		--10
		{ x = 0.0, y = 0.0 },  		--11
		{ x = 0.0, y = 0.0 }, 		--12
		{ x = 0.0, y = 0.0 },  		--13
		{ x = 0.0, y = 0.0 },  		--14
		{ x = 0.0, y = 0.0 },  		--15
		{ x = 0.0, y = 0.0 },  		--16
		{ x = 0.0, y = 0.0 },  		--17
		{ x = 0.0, y = 0.0 },		--18
		{ x = 0.0, y = 0.0 },  		--19
		{ x = 0.0, y = 0.0 }  		--20
	},

	fightTargetType = 5,   --��������
	fightTargetsStr = "ȫ��",  --ȫ������Ŀ��
	fightTargets = {},     --����Ŀ�꼯
	fightAddTargets ={},   --��״̬��
	
	fightSkillMax = 8,   --�����������
	fightSkill = {
	--���ü����ٴ�CD
         {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}
	},  

	--������Ա��Ϣ
	teamMaxinfo = 5,
	teamInfo = {
		-- �Ƿ�ѡ�У�״̬�Ƿ���� �Զ���� �Զ�����
		{play = 0, state = 0, team = false, Invite = false, name = ""},
		{play = 0, state = 0, team = false, Invite = false, name = ""},
		{play = 0, state = 0, team = false, Invite = false, name = ""},
		{play = 0, state = 0, team = false, Invite = false, name = ""},
		{play = 0, state = 0, team = false, Invite = false, name = ""}
	},

	fightFreeSit = false,    --���д���
	fightStayHere = false,   --ԭ�ش��
	fightOnlySkill = false,  --����ʹ�ü���
	fightOnlyDoctor = false, --ѡ��ҽ���һ�ģʽ
	useHealSkill = false, --ʹ�����Ƽ���
	
	PickType = 0,  --��ȡ���ͣ�Ĭ�ϣ�ʰȡȫ����Ʒ��
	PickTime = 500, --��ȡ�ӳ� ����
	
	-- ��Ʒ���ƹ�������
	PickFilterMode = 0,  -- 0=������, 1=������ģʽ, 2=������ģʽ
	PickFilterList = {},  -- ������Ʒ�б�
	PickFilterMaxItems = 18,  -- �����ʾ��Ʒ����
		
	safeUseItemMax = 6,
	safeUseItem = {
		{itemName = "", intervalTime = 60, nextUseTime = 0, enable = 1},  
		{itemName = "", intervalTime = 61, nextUseTime = 0, enable = 1}, 
		{itemName = "", intervalTime = 62, nextUseTime = 0, enable = 1},
		{itemName = "", intervalTime = 63, nextUseTime = 0, enable = 1},
		{itemName = "", intervalTime = 64, nextUseTime = 0, enable = 1},
		{itemName = "", intervalTime = 65, nextUseTime = 0, enable = 1}
	},
	
	-- HP��Ʒ����
	safeHpItem = {
		{itemName = "", safeValue = 50, enable = 1},  -- HP1 (��Ѫ��)
		{itemName = "", safeValue = 80, enable = 1}   -- HP2 (����)
	},
	-- SP��Ʒ����  
	safeSpItem = {
		{itemName = "", safeValue = 50, enable = 1},  -- SP1 (��SP)
		{itemName = "", safeValue = 80, enable = 1}   -- SP2 (����)
	},
	safePetHpItem = {itemPetName = "", safeValue = 100, enable = 1, growPetItem = "", growEnable = 1},
	
	safeSay = { sayContent = "", sayInterval = 30, nextSayTime = 0, sayEnable = 1}
}

-- ���ؽű�
function Util.LoadScript(file)
	CLU_Call("UI_LoadScript", file)
end	

-- ȡ��
function Util.Mod(num1, num2)
    return num1 - math.floor(num1/num2)*num2
end

-- �ַ����ָ�����
function Util.Split(str, sep)
	if sep == nil then
		sep = '%s'
	end

	local rt= {}
	local func = function(w)
		table.insert(rt, w)
	end

    string.gsub(str, '[^'..sep..']+', func )
    return rt
end

-- ��ȡ�����ļ�����Ϊ�ַ���
function Util.ReadConfigString(szKey, szApp, szFileName)
	return CLU_Call("Ini_ReadString", szKey, szApp, szFileName)
end

-- ��ȡ�����ļ�����Ϊ����
function Util.ReadConfigInteger(szKey, szApp, szFileName)
	return CLU_Call("Ini_ReadInteger", szKey, szApp, szFileName)
end

-- ��ȡ�����ļ�����Ϊ������
function Util.ReadConfigFloat(szKey, szApp, szFileName)
	return CLU_Call("Ini_ReadFloat", szKey, szApp, szFileName)
end

-- д�������ļ�����Ϊ�ַ���
function Util.WriteConfigString(aValue, szKey, szApp, szFileName)
	return CLU_Call("Ini_WriteString", aValue, szKey, szApp, szFileName)
end

-- д�������ļ�����Ϊ����
function Util.WriteConfigInteger(aValue, szKey, szApp, szFileName)
	return CLU_Call("Ini_WriteInteger", aValue, szKey, szApp, szFileName)
end

-- д�������ļ�����Ϊ������
function Util.WriteConfigFloat(aValue, szKey, szApp, szFileName)
	return CLU_Call("Ini_WriteFloat", aValue, szKey, szApp, szFileName)
end

-- ��ӡ��־
function Util.Debug(pszInfo)
	if (Config.enableDebug)
	then
		return CLU_Call("Gua_SysInfo", pszInfo)
	end
	return 0
end

-- ��ȡ������ֵ���ַ�����
function Form.GetEditValue(szName)
	return CLU_Call("Gua_GetEditValue", szName)
end

-- ��ȡ������ֵ��������
function Form.GetEditValueInt(szName)
	return CLU_Call("Gua_GetEditValueInt", szName)
end

-- ��ȡ������ֵ����������
function Form.GetEditValueFloat(szName)
	return CLU_Call("Gua_GetEditValueFloat", szName)
end

-- ����������ֵ���ַ�����
function Form.SetEditValue(szName, szValue)
	return CLU_Call("Gua_SetEditValue", szName, szValue)
end

-- ����������ֵ��������
function Form.SetEditValueInt(szName, nValue)
	return CLU_Call("Gua_SetEditValueInt", szName, nValue)
end

-- ����������ֵ����������
function Form.SetEditValueFloat(szName, fValue)
	return CLU_Call("Gua_SetEditValueFloat", szName, fValue)
end

-- ��ȡ��ѡ���ֵ
function Form.GetCheckBoxValue(szName)
	return CLU_Call("Gua_GetCheckBoxValue", szName)
end

-- ���ø�ѡ���ֵ
function Form.SetCheckBoxValue(szName, nValue)
	return CLU_Call("Gua_SetCheckBoxValue", szName, nValue)
end

-- ��ȡ��ѡ�����ֵ
function Form.GetCheckGroupActiveIndex(szName)
	return CLU_Call("Gua_GetCheckGroupActiveIndex", szName)
end

-- ���ø�ѡ�����ֵ
function Form.SetCheckGroupActiveIndex(szName, nValue)
	return CLU_Call("Gua_SetCheckGroupActiveIndex", szName, nValue)
end

-- ��ȡָ�����������
function Form.GetCommandText(szName)
	return CLU_Call("Gua_GetCommandText", szName)
end

-- ����ָ�������ֵ����Ʒ���ƣ�
function Form.SetCommandItem(szName, nValue)
	return CLU_Call("Gua_SetCommandItem", szName, nValue)
end

-- ����ָ�������ֵ���������ƣ�
function Form.SetCommandSkill(szName, nValue)
	return CLU_Call("Gua_SetCommandSkill", szName, nValue)
end

-- �����������Ϸ��ɫ
-- nType = 5 ����
-- nType = 6 ��ľ
-- nType = 7 ����
-- nType = 8 ��Ⱥ
-- nType = 9 ����
-- nType = 1 ���
function Game.FindCharByType(nType, iAlive, iMaxDis)
	return CLU_Call("Gua_FindCharByType", nType, iAlive, iMaxDis)
end
--���溯��
function Game.AutoFollow(pTarget)
	return CLU_Call("Gua_AutoFollow",pTarget)
end
-- �����������Ϸ��ɫ���������NPC��
function Game.FindCharByName(szName, iAlive, iMaxDis)
	return CLU_Call("Gua_FindCharByName", szName, iAlive, iMaxDis)
end

-- �����������Ϸ��ɫ���������NPC�������� ���� �Ƿ��� �����
function Game.FindCharByEveryName(nType, vNames, iAlive, iMaxDis)
	if (next(vNames) == nil) then
		return CLU_Call("Gua_FindCharByType", nType, iAlive, iMaxDis)
	end

	for k,v in pairs(vNames) do 
		local pTarget = CLU_Call("Gua_FindCharByName", v, iAlive, iMaxDis)
		if (pTarget ~= nil) then
			return pTarget
		end
	end 
	return nil
end

-- ��ȡ������Ϣ
function Game.FindSkillByName(szName)
	return CLU_Call("Gua_FindSkillByName", szName) 	
end

-- ��ȡ��������SPֵ
function Game.GetSkillUseSp(pSkill)
	return CLU_Call("Gua_GetSkillUseSp", pSkill) 	
end

-- ��ȡ�����ٶ�
function Game.GetSkillFireSpeed(pSkill)
	return CLU_Call("Gua_GetSkillFireSpeed", pSkill) 	
end

-- �жϼ����Ƿ���Լ�ʹ��
function Game.SkillIsTypeSelf(pSkill)
	return CLU_Call("Gua_SkillIsTypeSelf", pSkill) 	
end

-- �ж�CD�Ƿ��ѹ�
function Game.SkillIsAttackTime(pSkill)
	return CLU_Call("Gua_SkillIsAttackTime", pSkill) 	
end

-- �ж�����Ŀǰ�Ƿ�����Ӧ��״̬
function Game.GetSkillStateNow(pCha, szName)
   return CLU_Call("Gua_GetSkillStateNow", pCha, szName)
end

-- �жϼ����Ƿ����ʹ��
function Game.SkillIsCanUse(pSkill)
	local sp = Game.GetCharAttr(Game.GetCurChar(), ATTR_SP)
	if (Game.GetSkillUseSp(pSkill) > sp) then
		return false
	end

	if (Game.SkillIsAttackTime(pSkill) == 0) then
		return false
	end
	
	return true
end

--��ȡ�����������
function Game.GetPetAttrMaxHp()
   return CLU_Call("Gua_GetPetMaxHP") 
end

--��ȡ���鵱ǰ����
function Game.GetPetAttrCurHp()
   return CLU_Call("Gua_GetPetCurrentHP") 
end

--��ȡ���鵱ǰ�ɳ�ֵ
function Game.GetPetAttrGrow()
   return CLU_Call("Gua_GetPetGrow") 
end

-- ��ȡ��ǰ��ɫ����
function Game.GetCharAttr(pCha, sType)
	return CLU_Call("Gua_GetCharAttr", pCha, sType) 	
end

-- ��ȡ��ɫID
function Game.GetCharAttachID(pCha)
	return CLU_Call("Gua_GetCharAttachID", pCha)
end

-- ��ȡ��ɫ����
function Game.GetCharName()
    return CLU_Call("Gua_GetCharName")
end

--ͨ����ӻ�ȡ��Ա����
function Game.GetTeamCharName(id)
    return CLU_Call("Gua_GetTeamCharName", id)
end

--ͨ����ȡ������ �Զ���� �Զ�����
function Game.AutoTeamChaName(pTarget, Name)
    return CLU_Call("Gua_AutoTeamByName", pTarget, Name)
end

--ͨ������ָ��ȷ�ϱ��������
function Game.AutoTeamComfig(pCha)
    return CLU_Call("Gua_AutoTeamConfirm", pCha)
end 
--�ж��Ƿ������
function Game.IsInTeam(pCha)
    return CLU_Call("IsCheckInTeam", pCha)
end

-- ��ȡ��ǰ��ɫ
function Game.GetCurChar()
	return CLU_Call("Gua_GetMainChar")
end

-- ��ȡ��ǰ��ɫ����X
function Game.GetCurX()
	return CLU_Call("Gua_GetCurX")
end

-- ��ȡ��ǰ��ɫ����Y
function Game.GetCurY()
	return CLU_Call("Gua_GetCurY")
end

-- ��ȡ��ǰ��ɫ����ID
function Game.GetCurPoseID()
	return CLU_Call("Gua_GetCurPoseID")
end

-- ��ȡ��ǰ��ɫ��������
function Game.GetCurPoseType()
	return CLU_Call("Gua_GetCurPoseType")
end

-- ����ϵͳ��Ϣ
function Game.SysInfo(pszInfo)
	return CLU_Call("Gua_SysInfo", pszInfo)
end

-- ������Ұ��Ϣ
function Game.Say(pszInfo)
	return CLU_Call("Gua_Say", pszInfo) 	
end

-- �ƶ���ǰ��ɫ
function Game.MoveTo(x, y)
	return CLU_Call("Gua_MoveTo", x, y) 	
end

-- �Զ�Ѱ·��Ŀ��
function Game.AutoMoveTo(x, y)
    return CLU_Call("Gua_AutoMoveTo", x, y) 
end

-- ����ָ��Ŀ�꣨ʹ�ü��ܣ�
function Game.Attack(pSkill, pTarget)
	return CLU_Call("Gua_Attack", pSkill, pTarget) 	
end

-- ���ڵ���
function Game.HasItem(szItemName)
	return CLU_Call("Gua_HasItem", szItemName) 	
end

-- ʹ�õ���
function Game.UseItem(szItemName)
	return CLU_Call("Gua_UseItem", szItemName) 	
end

-- ʰȡ���� ���� ģʽ���ӳ٣����룩
function Game.PickAllItem(bOnlyPickInBag, ms)
	return CLU_Call("Gua_PickAllItem", bOnlyPickInBag, ms) 	
end


-- ���¼���
function Game.KeyDown(dwKey)
	return CLU_Call("Gua_KeyDown", dwKey) 	
end

-- ����
function Game.SitDown()
	local chaPoseType = Game.GetCurPoseType()
	if (chaPoseType ~= 16)
	then
		Game.KeyDown(45)
	end
end

-- վ��
function Game.StandUp()
	local chaPoseType = Game.GetCurPoseType()
	if (chaPoseType == 16)
	then
		Game.KeyDown(45)
	end
end

-- �������ýű�
function LoadPlugScript(bReload)
	if (bIsLoaded == false or bReload == true) then
		Util.LoadScript("scripts/lua/plug/mode-fights.lua")
		Util.LoadScript("scripts/lua/plug/mode-pick.lua")
		Util.LoadScript("scripts/lua/plug/mode-safe.lua")
		bIsLoaded = true
	end
end

-- �ű������¼�����
function OnPlugStarted()
	Game.SysInfo("�ű��ѿ�ʼ����")
	
	LoadPlugScript(true)

	OnPlugSave()
	return 0
end

-- �ű�ֹͣ�¼�����
function OnPlugStopped()
	Game.SysInfo("�ű���ֹͣ����")
	return 0
end

-- �ű������¼�����
function OnPlugLoad()
	-- ���������ļ�·��
	local configFile = "./user/plug-"..Game.GetCharAttachID(Game.GetCurChar())..".ini"
	
	-- ���عһ��ű�
	LoadPlugScript(false)
	
	-- ���عһ��ű�����
	OnFightScriptLoad(configFile)
	
	-- ����ʰȡ�ű�����
	OnPickScriptLoad(configFile)
	
	-- ˢ����Ʒ������ʾ
	RefreshPickFilterDisplay()
	
	-- ���ذ�ȫ�ű�����
	OnSafeScriptLoad(configFile)

	-- ���عһ�ģʽ����
	local needSaveMainDefaults = false
	
	Config.chkPlugMode01 = Util.ReadConfigInteger("mode1", "plug", configFile)
	if Config.chkPlugMode01 == nil then 
		Config.chkPlugMode01 = 0
		needSaveMainDefaults = true
	end
	Form.SetCheckBoxValue("chkPlugMode01", Config.chkPlugMode01)

	Config.chkPlugMode02 = Util.ReadConfigInteger("mode2", "plug", configFile)
	if Config.chkPlugMode02 == nil then 
		Config.chkPlugMode02 = 0
		needSaveMainDefaults = true
	end
	Form.SetCheckBoxValue("chkPlugMode02", Config.chkPlugMode02)

	Config.chkPlugMode03 = Util.ReadConfigInteger("mode3", "plug", configFile)
	if Config.chkPlugMode03 == nil then 
		Config.chkPlugMode03 = 0
		needSaveMainDefaults = true
	end
	Form.SetCheckBoxValue("chkPlugMode03", Config.chkPlugMode03)
	
	-- �����Ҫ����Ĭ��ֵ��������д�������ļ�
	if needSaveMainDefaults then
		Util.WriteConfigInteger(Config.chkPlugMode01, "mode1", "plug", configFile)
		Util.WriteConfigInteger(Config.chkPlugMode02, "mode2", "plug", configFile)
		Util.WriteConfigInteger(Config.chkPlugMode03, "mode3", "plug", configFile)
	end
	
	return 0
end

-- �ű������¼�����
function OnPlugSave()
	-- ���������ļ�·��
	local configFile = "./user/plug-"..Game.GetCharAttachID(Game.GetCurChar())..".ini"
	
	-- �浵����ǳ�
	Util.WriteConfigString(""..Game.GetCharName().."", "playerName", "player", configFile)
	
	-- ����һ�����
	OnFightScriptSave(configFile)
	
	-- ����ʰȡ����
	OnPickScriptSave(configFile)
	
	-- ���氲ȫ����
	OnSafeScriptSave(configFile)
		
		-- ����ģʽ����
	Config.chkPlugMode01 = Form.GetCheckBoxValue("chkPlugMode01")
	Util.WriteConfigInteger(Config.chkPlugMode01, "mode1", "plug", configFile)

	Config.chkPlugMode02 = Form.GetCheckBoxValue("chkPlugMode02")
	Util.WriteConfigInteger(Config.chkPlugMode02, "mode2", "plug", configFile)

	Config.chkPlugMode03 = Form.GetCheckBoxValue("chkPlugMode03")
	Util.WriteConfigInteger(Config.chkPlugMode03, "mode3", "plug", configFile)

	Game.SysInfo("�����ļ��ѱ��� user/plug-"..Game.GetCharAttachID(Game.GetCurChar())..".ini" )

	return 0
end

-- �ű�ִ���¼�����
function OnPlugExecTimer()
	local ret = 0
	local now = os.time()
		
	-- ���ģ��
	if Form.GetCheckBoxValue("chkPlugMode01") == 1 then
		DoFights(0)
	end
	
	-- ��ȡģ��
	if Form.GetCheckBoxValue("chkPlugMode02") == 1 then
		DoPick(0)
	end
	
	-- ����ģ��
	if Form.GetCheckBoxValue("chkPlugMode03") == 1 then
		DoSafe(0)
	end

	-- ��ʱͨ�湦��
	if Util.Mod(now, 900) == 0 and now - announcementLastTime >= 900 then
		Game.SysInfo("��ӭʹ��Ryan�θ�����壬��л֧�֣�������ú����롰֧��һ�¡�������ǿ��Ǵ��������Գɹ����ˣ�����")
		announcementLastTime = now
	end

	return 0
end

-- ����һ��㵽ָ���ļ�
function SavePositionsToFile()
	local fileName = Form.GetEditValue("posConfigFileName")
	if fileName == "" or fileName == nil then
		Game.SysInfo("����: �������ļ���")
		return
	end
	
	local posFile = "./user/positions-" .. fileName .. ".ini"
	local posCount = 0
	
	-- �������йһ�������
	for i = 1, Config.fightPosMax do
		local x = Form.GetEditValueFloat("fightPosX"..i)
		local y = Form.GetEditValueFloat("fightPosY"..i)
		Util.WriteConfigFloat(x, "fightPosX"..i, "positions", posFile)
		Util.WriteConfigFloat(y, "fightPosY"..i, "positions", posFile)
		
		-- ͳ�Ʒ������������
		if x ~= 0 or y ~= 0 then
			posCount = posCount + 1
		end
	end
	
	-- ����һ���Χ
	local fightRange = Form.GetEditValueInt("fightRange")
	Util.WriteConfigInteger(fightRange, "fightRange", "positions", posFile)
	
	Game.SysInfo("�ɹ����� " .. posCount .. " ���һ��㵽: user/positions-" .. fileName .. ".ini")
end

-- ��ָ���ļ����عһ���
function LoadPositionsFromFile()
	local fileName = Form.GetEditValue("posConfigFileName")
	if fileName == "" or fileName == nil then
		Game.SysInfo("����: �������ļ���")
		return
	end
	
	local posFile = "./user/positions-" .. fileName .. ".ini"
	
	-- ����ļ��Ƿ���ڣ����Զ�ȡ��һ���һ������
	local testX = Util.ReadConfigFloat("fightPosX1", "positions", posFile)
	local testRange = Util.ReadConfigInteger("fightRange", "positions", posFile)
	
	-- ������в���ֵ��Ϊ0��nil�������ļ������ڻ�Ϊ��
	if (testX == nil or testX == 0) and (testRange == nil or testRange == 0) then
		-- ��һ����⣺���Զ�ȡ����λ�õ�
		local hasAnyData = false
		for i = 1, Config.fightPosMax do
			local x = Util.ReadConfigFloat("fightPosX"..i, "positions", posFile)
			local y = Util.ReadConfigFloat("fightPosY"..i, "positions", posFile)
			if (x ~= nil and x ~= 0) or (y ~= nil and y ~= 0) then
				hasAnyData = true
				break
			end
		end
		
		if not hasAnyData then
			Game.SysInfo("����: �ļ������ڻ�Ϊ��: user/positions-" .. fileName .. ".ini")
			return
		end
	end
	
	local posCount = 0
	
	-- ��ȡ���йһ�������
	for i = 1, Config.fightPosMax do
		local x = Util.ReadConfigFloat("fightPosX"..i, "positions", posFile)
		local y = Util.ReadConfigFloat("fightPosY"..i, "positions", posFile)
		
		-- ����nilֵ
		if x == nil then x = 0 end
		if y == nil then y = 0 end
		
		-- �������ú�UI
		Config.fightPos[i].x = x
		Config.fightPos[i].y = y
		Form.SetEditValueFloat("fightPosX"..i, x)
		Form.SetEditValueFloat("fightPosY"..i, y)
		
		-- ͳ�Ʒ������������
		if x ~= 0 or y ~= 0 then
			posCount = posCount + 1
		end
	end
	
	-- ��ȡ�һ���Χ
	local fightRange = Util.ReadConfigInteger("fightRange", "positions", posFile)
	if fightRange ~= nil and fightRange > 0 then
		Config.fightRange = fightRange
		Form.SetEditValueInt("fightRange", fightRange)
	end
	
	Game.SysInfo("�ɹ����� " .. posCount .. " ���һ����: user/positions-" .. fileName .. ".ini")
end

-- ��Ʒ���˹�����
function AddPickFilterItem()
	local itemName = Form.GetEditValue("pickFilterItemName")
	if itemName == nil or itemName == "" then
		Game.SysInfo("��������Ʒ����")
		return
	end
	
	-- ����Ƿ��Ѵ���
	for i = 1, table.getn(Config.PickFilterList) do
		if Config.PickFilterList[i] == itemName then
			Game.SysInfo("��Ʒ [" .. itemName .. "] �Ѵ������б���")
			return
		end
	end
	
	-- ����б��Ƿ�����
	if table.getn(Config.PickFilterList) >= Config.PickFilterMaxItems then
		Game.SysInfo("�����б����������֧�� " .. Config.PickFilterMaxItems .. " ����Ʒ")
		return
	end
	
	-- ��ӵ��б�
	table.insert(Config.PickFilterList, itemName)
	Form.SetEditValue("pickFilterItemName", "")  -- ��������
	RefreshPickFilterDisplay()
	Game.SysInfo("����ӹ����б���Ʒ: " .. itemName)
end

function ClearPickFilterList()
	Config.PickFilterList = {}
	RefreshPickFilterDisplay()
	Game.SysInfo("����չ����б���Ʒ��")
end

function RemovePickFilterItem(index)
	if index < 1 or index > table.getn(Config.PickFilterList) then
		return
	end
	
	local itemName = Config.PickFilterList[index]
	table.remove(Config.PickFilterList, index)
	RefreshPickFilterDisplay()
	Game.SysInfo("��ɾ�������б���Ʒ: " .. itemName)
end

function RefreshPickFilterDisplay()
	-- ���������ʾ
	for i = 1, Config.PickFilterMaxItems do
		Form.SetEditValue("pickFilterList" .. i, "")
	end
	
	-- ��ʾ��ǰ�б�
	for i = 1, table.getn(Config.PickFilterList) do
		if i <= Config.PickFilterMaxItems then
			Form.SetEditValue("pickFilterList" .. i, Config.PickFilterList[i])
		end
	end
end

function IsItemInFilterList(itemName)
	for i = 1, table.getn(Config.PickFilterList) do
		if Config.PickFilterList[i] == itemName then
			return true
		end
	end
	return false
end

function ShouldPickItem(itemName)
	local isInList = IsItemInFilterList(itemName)
	local filterMode = Form.GetCheckGroupActiveIndex("chkPickFilterMode")
	
	-- ����б�Ϊ�գ������й���
	if table.getn(Config.PickFilterList) == 0 then
		return true
	end
	
	if filterMode == 0 then
		-- ������ģʽ��ֻʰȡ�б��е���Ʒ
		return isInList
	else
		-- ������ģʽ����ʰȡ�б��е���Ʒ
		return not isInList
	end
end

-- ��֧������
function OpenSupportLink()
	local url = "https://yx0hija69lf.feishu.cn/docx/P50Nd7jKpofxgcxj59KcWwKsnGf"
	-- ʹ��ϵͳĬ�������������
	os.execute('start "" "' .. url .. '"')
	--Game.SysInfo("��л����֧�֣����ڴ�����...")
end

-- �ű�ִ���¼�����
function OnMouseEvent(compentName, x, y, dwKey)
	-- �һ��㶨λ/��հ�ť����
	for i = 1, Config.fightPosMax do
		if (compentName == "btnRefreshPos"..i) then
			Form.SetEditValueFloat("fightPosX"..i, Game.GetCurX())
			Form.SetEditValueFloat("fightPosY"..i, Game.GetCurY())
			
		elseif (compentName == "btnClearPos"..i) then
			Form.SetEditValueFloat("fightPosX"..i, 0)
			Form.SetEditValueFloat("fightPosY"..i, 0)
		end
	end
	
	if (compentName == "btnClearPosAll") then	-- ���ȫ���һ��㰴ť
		for i = 1, Config.fightPosMax do
			 Form.SetEditValueFloat("fightPosX"..i, 0)
			 Form.SetEditValueFloat("fightPosY"..i, 0)
		end
		Game.SysInfo("��������йһ���")
		
	elseif (compentName == "btnSavePositions") then		-- ���һ�������
		SavePositionsToFile()
		
	elseif (compentName == "btnLoadPositions") then		-- ���عһ�������
		LoadPositionsFromFile()
		
	elseif (compentName == "btnSupport") then			-- ֧��һ�°�ť
		OpenSupportLink()
		
	-- ��Ʒ���˰�ť����
	elseif (compentName == "btnPickFilterAdd") then		-- ������Ʒ��ť
		AddPickFilterItem()
		
	elseif (compentName == "btnPickFilterClear") then	-- ����б�ť
		ClearPickFilterList()
		
	-- ɾ����Ʒ��ť����
	elseif (compentName == "btnPickFilterDel1") then
		RemovePickFilterItem(1)
	elseif (compentName == "btnPickFilterDel2") then
		RemovePickFilterItem(2)
	elseif (compentName == "btnPickFilterDel3") then
		RemovePickFilterItem(3)
	elseif (compentName == "btnPickFilterDel4") then
		RemovePickFilterItem(4)
	elseif (compentName == "btnPickFilterDel5") then
		RemovePickFilterItem(5)
	elseif (compentName == "btnPickFilterDel6") then
		RemovePickFilterItem(6)
	elseif (compentName == "btnPickFilterDel7") then
		RemovePickFilterItem(7)
	elseif (compentName == "btnPickFilterDel8") then
		RemovePickFilterItem(8)
	elseif (compentName == "btnPickFilterDel9") then
		RemovePickFilterItem(9)
	elseif (compentName == "btnPickFilterDel10") then
		RemovePickFilterItem(10)
	elseif (compentName == "btnPickFilterDel11") then
		RemovePickFilterItem(11)
	elseif (compentName == "btnPickFilterDel12") then
		RemovePickFilterItem(12)
	elseif (compentName == "btnPickFilterDel13") then
		RemovePickFilterItem(13)
	elseif (compentName == "btnPickFilterDel14") then
		RemovePickFilterItem(14)
	elseif (compentName == "btnPickFilterDel15") then
		RemovePickFilterItem(15)
	elseif (compentName == "btnPickFilterDel16") then
		RemovePickFilterItem(16)
	elseif (compentName == "btnPickFilterDel17") then
		RemovePickFilterItem(17)
	elseif (compentName == "btnPickFilterDel18") then
		RemovePickFilterItem(18)
	end
	return 1
end
-- ˢ�������Ϣ
function OnRefreshTeam(compentName)

   if (compentName == "btnRefreshTeam"..1) then
	  Form.SetEditValue("play1", Game.GetCharName()) --�Լ�����
	  return 1
	  
   elseif (compentName == "btnRefreshTeam"..2) then
	  Form.SetEditValue("play2", Game.GetTeamCharName(0))  --��Ա1
	  return 1
	  
   elseif (compentName == "btnRefreshTeam"..3) then
      Form.SetEditValue("play3", Game.GetTeamCharName(1))  --��Ա2
	  return 1
	  
   elseif (compentName == "btnRefreshTeam"..4) then
      Form.SetEditValue("play4", Game.GetTeamCharName(2))  --��Ա3
	  return 1
	  
	elseif (compentName == "btnRefreshTeam"..5) then
      Form.SetEditValue("play5", Game.GetTeamCharName(3))  --��Ա4
	  return 1
	  
	else
		BtnFollow_click(compentName)--���水ť
		return 1
    end

end
--��ȡ��λ
function OnRefreshMouseEvent1(compentName, x, y, dwKey)
	return 1
end
--��ն�λ
function OnRefreshMouseEvent2(compentName, x, y, dwKey)
	--Game.Say("�ұ������2")
	return 1
end
--�������¼�
function BtnFollow_click(compentName)
	if (compentName == "btnFollow"..2) then
		SetFollowPlayer_Name(Game.GetTeamCharName(0))
		return 1
	elseif (compentName == "btnFollow"..3) then
		SetFollowPlayer_Name(Game.GetTeamCharName(1))
		return 1
	elseif (compentName == "btnFollow"..4) then
		SetFollowPlayer_Name(Game.GetTeamCharName(2))
		return 1
	elseif (compentName == "btnFollow"..5) then
		SetFollowPlayer_Name(Game.GetTeamCharName(3))
		return 1
	end
	return 0
end
function SetFollowPlayer_Name(player_name)
	if player_name ~= nil then
		Form.SetEditValue("playFollw",player_name)
	end
end