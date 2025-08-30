----修改调整.by:初雨Ryan -20250824
-- 加载状态
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
	fightPosMax = 20,  -- 实际挂机点数量
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

	fightTargetType = 5,   --攻击类型
	fightTargetsStr = "全部",  --全部攻击目标
	fightTargets = {},     --攻击目标集
	fightAddTargets ={},   --加状态集
	
	fightSkillMax = 8,   --技能最大数量
	fightSkill = {
	--设置技能再次CD
         {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}, 
		 {skillName = "", intervalTime = 30, nextSkTime = 0}
	},  

	--队伍人员信息
	teamMaxinfo = 5,
	teamInfo = {
		-- 是否选中，状态是否加完 自动组队 自动邀请
		{play = 0, state = 0, team = false, Invite = false, name = ""},
		{play = 0, state = 0, team = false, Invite = false, name = ""},
		{play = 0, state = 0, team = false, Invite = false, name = ""},
		{play = 0, state = 0, team = false, Invite = false, name = ""},
		{play = 0, state = 0, team = false, Invite = false, name = ""}
	},

	fightFreeSit = false,    --空闲打坐
	fightStayHere = false,   --原地打怪
	fightOnlySkill = false,  --单单使用技能
	fightOnlyDoctor = false, --选择医生挂机模式
	useHealSkill = false, --使用治疗技能
	
	PickType = 0,  --捡取类型（默认：拾取全部物品）
	PickTime = 500, --捡取延迟 毫秒
	
	-- 物品名称过滤配置
	PickFilterMode = 0,  -- 0=不过滤, 1=白名单模式, 2=黑名单模式
	PickFilterList = {},  -- 过滤物品列表
	PickFilterMaxItems = 18,  -- 最大显示物品数量
		
	safeUseItemMax = 6,
	safeUseItem = {
		{itemName = "", intervalTime = 60, nextUseTime = 0, enable = 1},  
		{itemName = "", intervalTime = 61, nextUseTime = 0, enable = 1}, 
		{itemName = "", intervalTime = 62, nextUseTime = 0, enable = 1},
		{itemName = "", intervalTime = 63, nextUseTime = 0, enable = 1},
		{itemName = "", intervalTime = 64, nextUseTime = 0, enable = 1},
		{itemName = "", intervalTime = 65, nextUseTime = 0, enable = 1}
	},
	
	-- HP物品配置
	safeHpItem = {
		{itemName = "", safeValue = 50, enable = 1},  -- HP1 (低血量)
		{itemName = "", safeValue = 80, enable = 1}   -- HP2 (常规)
	},
	-- SP物品配置  
	safeSpItem = {
		{itemName = "", safeValue = 50, enable = 1},  -- SP1 (低SP)
		{itemName = "", safeValue = 80, enable = 1}   -- SP2 (常规)
	},
	safePetHpItem = {itemPetName = "", safeValue = 100, enable = 1, growPetItem = "", growEnable = 1},
	
	safeSay = { sayContent = "", sayInterval = 30, nextSayTime = 0, sayEnable = 1}
}

-- 加载脚本
function Util.LoadScript(file)
	CLU_Call("UI_LoadScript", file)
end	

-- 取余
function Util.Mod(num1, num2)
    return num1 - math.floor(num1/num2)*num2
end

-- 字符串分隔方法
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

-- 读取配置文件参数为字符串
function Util.ReadConfigString(szKey, szApp, szFileName)
	return CLU_Call("Ini_ReadString", szKey, szApp, szFileName)
end

-- 读取配置文件参数为整数
function Util.ReadConfigInteger(szKey, szApp, szFileName)
	return CLU_Call("Ini_ReadInteger", szKey, szApp, szFileName)
end

-- 读取配置文件参数为浮点数
function Util.ReadConfigFloat(szKey, szApp, szFileName)
	return CLU_Call("Ini_ReadFloat", szKey, szApp, szFileName)
end

-- 写入配置文件参数为字符串
function Util.WriteConfigString(aValue, szKey, szApp, szFileName)
	return CLU_Call("Ini_WriteString", aValue, szKey, szApp, szFileName)
end

-- 写入配置文件参数为整数
function Util.WriteConfigInteger(aValue, szKey, szApp, szFileName)
	return CLU_Call("Ini_WriteInteger", aValue, szKey, szApp, szFileName)
end

-- 写入配置文件参数为浮点数
function Util.WriteConfigFloat(aValue, szKey, szApp, szFileName)
	return CLU_Call("Ini_WriteFloat", aValue, szKey, szApp, szFileName)
end

-- 打印日志
function Util.Debug(pszInfo)
	if (Config.enableDebug)
	then
		return CLU_Call("Gua_SysInfo", pszInfo)
	end
	return 0
end

-- 获取输入框的值（字符串）
function Form.GetEditValue(szName)
	return CLU_Call("Gua_GetEditValue", szName)
end

-- 获取输入框的值（整数）
function Form.GetEditValueInt(szName)
	return CLU_Call("Gua_GetEditValueInt", szName)
end

-- 获取输入框的值（浮点数）
function Form.GetEditValueFloat(szName)
	return CLU_Call("Gua_GetEditValueFloat", szName)
end

-- 设置输入框的值（字符串）
function Form.SetEditValue(szName, szValue)
	return CLU_Call("Gua_SetEditValue", szName, szValue)
end

-- 设置输入框的值（整数）
function Form.SetEditValueInt(szName, nValue)
	return CLU_Call("Gua_SetEditValueInt", szName, nValue)
end

-- 设置输入框的值（浮点数）
function Form.SetEditValueFloat(szName, fValue)
	return CLU_Call("Gua_SetEditValueFloat", szName, fValue)
end

-- 获取复选框的值
function Form.GetCheckBoxValue(szName)
	return CLU_Call("Gua_GetCheckBoxValue", szName)
end

-- 设置复选框的值
function Form.SetCheckBoxValue(szName, nValue)
	return CLU_Call("Gua_SetCheckBoxValue", szName, nValue)
end

-- 获取复选框组的值
function Form.GetCheckGroupActiveIndex(szName)
	return CLU_Call("Gua_GetCheckGroupActiveIndex", szName)
end

-- 设置复选框组的值
function Form.SetCheckGroupActiveIndex(szName, nValue)
	return CLU_Call("Gua_SetCheckGroupActiveIndex", szName, nValue)
end

-- 获取指令组件的名称
function Form.GetCommandText(szName)
	return CLU_Call("Gua_GetCommandText", szName)
end

-- 设置指令组件的值（物品名称）
function Form.SetCommandItem(szName, nValue)
	return CLU_Call("Gua_SetCommandItem", szName, nValue)
end

-- 设置指令组件的值（技能名称）
function Form.SetCommandSkill(szName, nValue)
	return CLU_Call("Gua_SetCommandSkill", szName, nValue)
end

-- 搜索最近的游戏角色
-- nType = 5 怪物
-- nType = 6 树木
-- nType = 7 矿物
-- nType = 8 鱼群
-- nType = 9 沉船
-- nType = 1 玩家
function Game.FindCharByType(nType, iAlive, iMaxDis)
	return CLU_Call("Gua_FindCharByType", nType, iAlive, iMaxDis)
end
--跟随函数
function Game.AutoFollow(pTarget)
	return CLU_Call("Gua_AutoFollow",pTarget)
end
-- 搜索最近的游戏角色（包含怪物、NPC）
function Game.FindCharByName(szName, iAlive, iMaxDis)
	return CLU_Call("Gua_FindCharByName", szName, iAlive, iMaxDis)
end

-- 搜索最近的游戏角色（包含怪物、NPC）｛类型 名字 是否存活 距离｝
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

-- 获取技能信息
function Game.FindSkillByName(szName)
	return CLU_Call("Gua_FindSkillByName", szName) 	
end

-- 获取技能消耗SP值
function Game.GetSkillUseSp(pSkill)
	return CLU_Call("Gua_GetSkillUseSp", pSkill) 	
end

-- 获取技能速度
function Game.GetSkillFireSpeed(pSkill)
	return CLU_Call("Gua_GetSkillFireSpeed", pSkill) 	
end

-- 判断技能是否给自己使用
function Game.SkillIsTypeSelf(pSkill)
	return CLU_Call("Gua_SkillIsTypeSelf", pSkill) 	
end

-- 判断CD是否已过
function Game.SkillIsAttackTime(pSkill)
	return CLU_Call("Gua_SkillIsAttackTime", pSkill) 	
end

-- 判断人物目前是否有相应的状态
function Game.GetSkillStateNow(pCha, szName)
   return CLU_Call("Gua_GetSkillStateNow", pCha, szName)
end

-- 判断技能是否可以使用
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

--获取精灵最大体力
function Game.GetPetAttrMaxHp()
   return CLU_Call("Gua_GetPetMaxHP") 
end

--获取精灵当前体力
function Game.GetPetAttrCurHp()
   return CLU_Call("Gua_GetPetCurrentHP") 
end

--获取精灵当前成长值
function Game.GetPetAttrGrow()
   return CLU_Call("Gua_GetPetGrow") 
end

-- 获取当前角色属性
function Game.GetCharAttr(pCha, sType)
	return CLU_Call("Gua_GetCharAttr", pCha, sType) 	
end

-- 获取角色ID
function Game.GetCharAttachID(pCha)
	return CLU_Call("Gua_GetCharAttachID", pCha)
end

-- 获取角色名称
function Game.GetCharName()
    return CLU_Call("Gua_GetCharName")
end

--通过组队获取队员名字
function Game.GetTeamCharName(id)
    return CLU_Call("Gua_GetTeamCharName", id)
end

--通过获取人名字 自动组队 自动邀请
function Game.AutoTeamChaName(pTarget, Name)
    return CLU_Call("Gua_AutoTeamByName", pTarget, Name)
end

--通过人物指针确认被邀请组队
function Game.AutoTeamComfig(pCha)
    return CLU_Call("Gua_AutoTeamConfirm", pCha)
end 
--判断是否组队了
function Game.IsInTeam(pCha)
    return CLU_Call("IsCheckInTeam", pCha)
end

-- 获取当前角色
function Game.GetCurChar()
	return CLU_Call("Gua_GetMainChar")
end

-- 获取当前角色坐标X
function Game.GetCurX()
	return CLU_Call("Gua_GetCurX")
end

-- 获取当前角色坐标Y
function Game.GetCurY()
	return CLU_Call("Gua_GetCurY")
end

-- 获取当前角色动作ID
function Game.GetCurPoseID()
	return CLU_Call("Gua_GetCurPoseID")
end

-- 获取当前角色动作类型
function Game.GetCurPoseType()
	return CLU_Call("Gua_GetCurPoseType")
end

-- 发送系统消息
function Game.SysInfo(pszInfo)
	return CLU_Call("Gua_SysInfo", pszInfo)
end

-- 发送视野消息
function Game.Say(pszInfo)
	return CLU_Call("Gua_Say", pszInfo) 	
end

-- 移动当前角色
function Game.MoveTo(x, y)
	return CLU_Call("Gua_MoveTo", x, y) 	
end

-- 自动寻路到目标
function Game.AutoMoveTo(x, y)
    return CLU_Call("Gua_AutoMoveTo", x, y) 
end

-- 攻击指定目标（使用技能）
function Game.Attack(pSkill, pTarget)
	return CLU_Call("Gua_Attack", pSkill, pTarget) 	
end

-- 存在道具
function Game.HasItem(szItemName)
	return CLU_Call("Gua_HasItem", szItemName) 	
end

-- 使用道具
function Game.UseItem(szItemName)
	return CLU_Call("Gua_UseItem", szItemName) 	
end

-- 拾取道具 参数 模式，延迟（毫秒）
function Game.PickAllItem(bOnlyPickInBag, ms)
	return CLU_Call("Gua_PickAllItem", bOnlyPickInBag, ms) 	
end


-- 按下键盘
function Game.KeyDown(dwKey)
	return CLU_Call("Gua_KeyDown", dwKey) 	
end

-- 打坐
function Game.SitDown()
	local chaPoseType = Game.GetCurPoseType()
	if (chaPoseType ~= 16)
	then
		Game.KeyDown(45)
	end
end

-- 站起
function Game.StandUp()
	local chaPoseType = Game.GetCurPoseType()
	if (chaPoseType == 16)
	then
		Game.KeyDown(45)
	end
end

-- 加载外置脚本
function LoadPlugScript(bReload)
	if (bIsLoaded == false or bReload == true) then
		Util.LoadScript("scripts/lua/plug/mode-fights.lua")
		Util.LoadScript("scripts/lua/plug/mode-pick.lua")
		Util.LoadScript("scripts/lua/plug/mode-safe.lua")
		bIsLoaded = true
	end
end

-- 脚本启动事件触发
function OnPlugStarted()
	Game.SysInfo("脚本已开始运行")
	
	LoadPlugScript(true)

	OnPlugSave()
	return 0
end

-- 脚本停止事件触发
function OnPlugStopped()
	Game.SysInfo("脚本已停止运行")
	return 0
end

-- 脚本加载事件触发
function OnPlugLoad()
	-- 生成配置文件路径
	local configFile = "./user/plug-"..Game.GetCharAttachID(Game.GetCurChar())..".ini"
	
	-- 加载挂机脚本
	LoadPlugScript(false)
	
	-- 加载挂机脚本配置
	OnFightScriptLoad(configFile)
	
	-- 加载拾取脚本配置
	OnPickScriptLoad(configFile)
	
	-- 刷新物品过滤显示
	RefreshPickFilterDisplay()
	
	-- 加载安全脚本配置
	OnSafeScriptLoad(configFile)

	-- 加载挂机模式配置
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
	
	-- 如果需要保存默认值，则立即写入配置文件
	if needSaveMainDefaults then
		Util.WriteConfigInteger(Config.chkPlugMode01, "mode1", "plug", configFile)
		Util.WriteConfigInteger(Config.chkPlugMode02, "mode2", "plug", configFile)
		Util.WriteConfigInteger(Config.chkPlugMode03, "mode3", "plug", configFile)
	end
	
	return 0
end

-- 脚本保存事件触发
function OnPlugSave()
	-- 生成配置文件路径
	local configFile = "./user/plug-"..Game.GetCharAttachID(Game.GetCurChar())..".ini"
	
	-- 存档玩家昵称
	Util.WriteConfigString(""..Game.GetCharName().."", "playerName", "player", configFile)
	
	-- 保存挂机配置
	OnFightScriptSave(configFile)
	
	-- 保存拾取配置
	OnPickScriptSave(configFile)
	
	-- 保存安全配置
	OnSafeScriptSave(configFile)
		
		-- 保存模式配置
	Config.chkPlugMode01 = Form.GetCheckBoxValue("chkPlugMode01")
	Util.WriteConfigInteger(Config.chkPlugMode01, "mode1", "plug", configFile)

	Config.chkPlugMode02 = Form.GetCheckBoxValue("chkPlugMode02")
	Util.WriteConfigInteger(Config.chkPlugMode02, "mode2", "plug", configFile)

	Config.chkPlugMode03 = Form.GetCheckBoxValue("chkPlugMode03")
	Util.WriteConfigInteger(Config.chkPlugMode03, "mode3", "plug", configFile)

	Game.SysInfo("配置文件已保存 user/plug-"..Game.GetCharAttachID(Game.GetCurChar())..".ini" )

	return 0
end

-- 脚本执行事件触发
function OnPlugExecTimer()
	local ret = 0
	local now = os.time()
		
	-- 打怪模块
	if Form.GetCheckBoxValue("chkPlugMode01") == 1 then
		DoFights(0)
	end
	
	-- 捡取模块
	if Form.GetCheckBoxValue("chkPlugMode02") == 1 then
		DoPick(0)
	end
	
	-- 保护模块
	if Form.GetCheckBoxValue("chkPlugMode03") == 1 then
		DoSafe(0)
	end

	-- 定时通告功能
	if Util.Mod(now, 900) == 0 and now - announcementLastTime >= 900 then
		Game.SysInfo("欢迎使用Ryanの辅助面板，感谢支持！如果觉得好用请“支持一下”。另外强烈谴责恶意剽窃成果的人！！！")
		announcementLastTime = now
	end

	return 0
end

-- 保存挂机点到指定文件
function SavePositionsToFile()
	local fileName = Form.GetEditValue("posConfigFileName")
	if fileName == "" or fileName == nil then
		Game.SysInfo("错误: 请输入文件名")
		return
	end
	
	local posFile = "./user/positions-" .. fileName .. ".ini"
	local posCount = 0
	
	-- 保存所有挂机点坐标
	for i = 1, Config.fightPosMax do
		local x = Form.GetEditValueFloat("fightPosX"..i)
		local y = Form.GetEditValueFloat("fightPosY"..i)
		Util.WriteConfigFloat(x, "fightPosX"..i, "positions", posFile)
		Util.WriteConfigFloat(y, "fightPosY"..i, "positions", posFile)
		
		-- 统计非零坐标点数量
		if x ~= 0 or y ~= 0 then
			posCount = posCount + 1
		end
	end
	
	-- 保存挂机范围
	local fightRange = Form.GetEditValueInt("fightRange")
	Util.WriteConfigInteger(fightRange, "fightRange", "positions", posFile)
	
	Game.SysInfo("成功导出 " .. posCount .. " 个挂机点到: user/positions-" .. fileName .. ".ini")
end

-- 从指定文件加载挂机点
function LoadPositionsFromFile()
	local fileName = Form.GetEditValue("posConfigFileName")
	if fileName == "" or fileName == nil then
		Game.SysInfo("错误: 请输入文件名")
		return
	end
	
	local posFile = "./user/positions-" .. fileName .. ".ini"
	
	-- 检测文件是否存在：尝试读取第一个挂机点测试
	local testX = Util.ReadConfigFloat("fightPosX1", "positions", posFile)
	local testRange = Util.ReadConfigInteger("fightRange", "positions", posFile)
	
	-- 如果所有测试值都为0或nil，可能文件不存在或为空
	if (testX == nil or testX == 0) and (testRange == nil or testRange == 0) then
		-- 进一步检测：尝试读取所有位置点
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
			Game.SysInfo("错误: 文件不存在或为空: user/positions-" .. fileName .. ".ini")
			return
		end
	end
	
	local posCount = 0
	
	-- 读取所有挂机点坐标
	for i = 1, Config.fightPosMax do
		local x = Util.ReadConfigFloat("fightPosX"..i, "positions", posFile)
		local y = Util.ReadConfigFloat("fightPosY"..i, "positions", posFile)
		
		-- 处理nil值
		if x == nil then x = 0 end
		if y == nil then y = 0 end
		
		-- 更新配置和UI
		Config.fightPos[i].x = x
		Config.fightPos[i].y = y
		Form.SetEditValueFloat("fightPosX"..i, x)
		Form.SetEditValueFloat("fightPosY"..i, y)
		
		-- 统计非零坐标点数量
		if x ~= 0 or y ~= 0 then
			posCount = posCount + 1
		end
	end
	
	-- 读取挂机范围
	local fightRange = Util.ReadConfigInteger("fightRange", "positions", posFile)
	if fightRange ~= nil and fightRange > 0 then
		Config.fightRange = fightRange
		Form.SetEditValueInt("fightRange", fightRange)
	end
	
	Game.SysInfo("成功导入 " .. posCount .. " 个挂机点从: user/positions-" .. fileName .. ".ini")
end

-- 物品过滤管理功能
function AddPickFilterItem()
	local itemName = Form.GetEditValue("pickFilterItemName")
	if itemName == nil or itemName == "" then
		Game.SysInfo("请输入物品名称")
		return
	end
	
	-- 检查是否已存在
	for i = 1, table.getn(Config.PickFilterList) do
		if Config.PickFilterList[i] == itemName then
			Game.SysInfo("物品 [" .. itemName .. "] 已存在于列表中")
			return
		end
	end
	
	-- 检查列表是否已满
	if table.getn(Config.PickFilterList) >= Config.PickFilterMaxItems then
		Game.SysInfo("过滤列表已满，最多支持 " .. Config.PickFilterMaxItems .. " 个物品")
		return
	end
	
	-- 添加到列表
	table.insert(Config.PickFilterList, itemName)
	Form.SetEditValue("pickFilterItemName", "")  -- 清空输入框
	RefreshPickFilterDisplay()
	Game.SysInfo("已添加过滤列表物品: " .. itemName)
end

function ClearPickFilterList()
	Config.PickFilterList = {}
	RefreshPickFilterDisplay()
	Game.SysInfo("已清空过滤列表物品！")
end

function RemovePickFilterItem(index)
	if index < 1 or index > table.getn(Config.PickFilterList) then
		return
	end
	
	local itemName = Config.PickFilterList[index]
	table.remove(Config.PickFilterList, index)
	RefreshPickFilterDisplay()
	Game.SysInfo("已删除过滤列表物品: " .. itemName)
end

function RefreshPickFilterDisplay()
	-- 清空所有显示
	for i = 1, Config.PickFilterMaxItems do
		Form.SetEditValue("pickFilterList" .. i, "")
	end
	
	-- 显示当前列表
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
	
	-- 如果列表为空，不进行过滤
	if table.getn(Config.PickFilterList) == 0 then
		return true
	end
	
	if filterMode == 0 then
		-- 白名单模式：只拾取列表中的物品
		return isInList
	else
		-- 黑名单模式：不拾取列表中的物品
		return not isInList
	end
end

-- 打开支持链接
function OpenSupportLink()
	local url = "https://yx0hija69lf.feishu.cn/docx/P50Nd7jKpofxgcxj59KcWwKsnGf"
	-- 使用系统默认浏览器打开链接
	os.execute('start "" "' .. url .. '"')
	--Game.SysInfo("感谢您的支持！正在打开链接...")
end

-- 脚本执行事件触发
function OnMouseEvent(compentName, x, y, dwKey)
	-- 挂机点定位/清空按钮监听
	for i = 1, Config.fightPosMax do
		if (compentName == "btnRefreshPos"..i) then
			Form.SetEditValueFloat("fightPosX"..i, Game.GetCurX())
			Form.SetEditValueFloat("fightPosY"..i, Game.GetCurY())
			
		elseif (compentName == "btnClearPos"..i) then
			Form.SetEditValueFloat("fightPosX"..i, 0)
			Form.SetEditValueFloat("fightPosY"..i, 0)
		end
	end
	
	if (compentName == "btnClearPosAll") then	-- 清空全部挂机点按钮
		for i = 1, Config.fightPosMax do
			 Form.SetEditValueFloat("fightPosX"..i, 0)
			 Form.SetEditValueFloat("fightPosY"..i, 0)
		end
		Game.SysInfo("已清空所有挂机点")
		
	elseif (compentName == "btnSavePositions") then		-- 另存挂机点配置
		SavePositionsToFile()
		
	elseif (compentName == "btnLoadPositions") then		-- 加载挂机点配置
		LoadPositionsFromFile()
		
	elseif (compentName == "btnSupport") then			-- 支持一下按钮
		OpenSupportLink()
		
	-- 物品过滤按钮处理
	elseif (compentName == "btnPickFilterAdd") then		-- 插入物品按钮
		AddPickFilterItem()
		
	elseif (compentName == "btnPickFilterClear") then	-- 清空列表按钮
		ClearPickFilterList()
		
	-- 删除物品按钮处理
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
-- 刷新组队信息
function OnRefreshTeam(compentName)

   if (compentName == "btnRefreshTeam"..1) then
	  Form.SetEditValue("play1", Game.GetCharName()) --自己名字
	  return 1
	  
   elseif (compentName == "btnRefreshTeam"..2) then
	  Form.SetEditValue("play2", Game.GetTeamCharName(0))  --队员1
	  return 1
	  
   elseif (compentName == "btnRefreshTeam"..3) then
      Form.SetEditValue("play3", Game.GetTeamCharName(1))  --队员2
	  return 1
	  
   elseif (compentName == "btnRefreshTeam"..4) then
      Form.SetEditValue("play4", Game.GetTeamCharName(2))  --队员3
	  return 1
	  
	elseif (compentName == "btnRefreshTeam"..5) then
      Form.SetEditValue("play5", Game.GetTeamCharName(3))  --队员4
	  return 1
	  
	else
		BtnFollow_click(compentName)--跟随按钮
		return 1
    end

end
--获取定位
function OnRefreshMouseEvent1(compentName, x, y, dwKey)
	return 1
end
--清空定位
function OnRefreshMouseEvent2(compentName, x, y, dwKey)
	--Game.Say("我被点击了2")
	return 1
end
--跟随点击事件
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