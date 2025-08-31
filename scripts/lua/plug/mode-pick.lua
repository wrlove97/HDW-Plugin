----修改调整.by:初雨Ryan -20250831
-- 最小和最大拾取延迟
local MIN_PICK_TIME = 100
local MAX_PICK_TIME = 5000

-- 检查物品名称是否为有效过滤项
function IsValidFilterItem(filterItemName)
	return filterItemName ~= nil and filterItemName ~= ""
end

-- 清空过滤物品列表
function ClearPickFilterList()
	-- 清空所有输入框
	for i = 1, Config.PickFilterMaxItems do
		Form.SetEditValue("pickFilterList" .. i, "")
	end
	Config.PickFilterList = {}
	Game.SysInfo("已清空过滤列表物品！")
end

-- 删除指定索引的过滤物品
function RemovePickFilterItem(index)
	if index < 1 or index > Config.PickFilterMaxItems then
		return
	end
	
	local filterItemName = Form.GetEditValue("pickFilterList" .. index)
	if filterItemName ~= "" then
		Form.SetEditValue("pickFilterList" .. index, "")  -- 清空输入框
		RefreshPickFilterDisplay()  -- 更新Config
		Game.SysInfo("已删除过滤列表物品: " .. filterItemName)
	end
end

-- 刷新过滤物品显示
function RefreshPickFilterDisplay()
	-- 从UI读取物品列表并更新Config
	Config.PickFilterList = {}
	for i = 1, Config.PickFilterMaxItems do
		local filterItemName = Form.GetEditValue("pickFilterList" .. i)
		if IsValidFilterItem(filterItemName) then
			table.insert(Config.PickFilterList, filterItemName)
		end
	end
end

-- 保存过滤物品列表到配置文件
function SaveFilterItemsToConfig(configFile)
	for i = 1, Config.PickFilterMaxItems do
		local filterItemName = Form.GetEditValue("pickFilterList" .. i)
		if not IsValidFilterItem(filterItemName) then
			filterItemName = ""
		end
		Util.WriteConfigString(filterItemName, "pickFilterItem" .. i, "pick", configFile)
	end
end

-- 载入捡东西配置
function OnPickScriptLoad(configFile)
	-- 读取拾取类型配置
	Config.PickType = Util.ReadConfigInteger("onlyPickType", "pick", configFile)
	if Config.PickType == nil or Config.PickType < 0 or Config.PickType > 4 then 
		Config.PickType = 0  -- 默认：拾取全部物品
	end
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	
	-- 读取拾取延迟配置
	Config.PickTime = Util.ReadConfigInteger("InPickTime", "pick", configFile)
	if Config.PickTime == nil or Config.PickTime < MIN_PICK_TIME or Config.PickTime > MAX_PICK_TIME then 
		Config.PickTime = 500
	end
	Form.SetEditValueInt("InPickTime", Config.PickTime)
	
	-- 加载过滤物品列表到UI
	for i = 1, Config.PickFilterMaxItems do
		local filterItemName = Util.ReadConfigString("pickFilterItem" .. i, "pick", configFile)
		if IsValidFilterItem(filterItemName) then
			Form.SetEditValue("pickFilterList" .. i, filterItemName)
		else
			Form.SetEditValue("pickFilterList" .. i, "")
		end
	end
	RefreshPickFilterDisplay()
	
	-- 强制刷新UI设置
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	Form.SetEditValueInt("InPickTime", Config.PickTime)
end

-- 存储捡东西配置
function OnPickScriptSave(configFile)
    local PickTypeIndex = Form.GetCheckGroupActiveIndex("chkOnlyPickType")  -- 获取复选框组索引
    Util.WriteConfigInteger(PickTypeIndex, "onlyPickType", "pick", configFile)  -- 写入拾取类型
    
    local PickTimeNum = Form.GetEditValueInt("InPickTime")  -- 读取编辑框捡取延迟时间
    Util.WriteConfigInteger(PickTimeNum, "InPickTime", "pick", configFile)  -- 写入延迟时间
    
    -- 保存过滤物品列表
    SaveFilterItemsToConfig(configFile)
end

-- 执行拾取脚本
function DoPick(nDeep)
    -- 深度检查，防止无限递归
    if nDeep > 3 then
        return 0
    end
    
    local PickTypeIndex = Form.GetCheckGroupActiveIndex("chkOnlyPickType")   -- 获取复选框组索引
    
    -- 验证拾取类型
    if PickTypeIndex < 0 or PickTypeIndex > 4 then
        Game.SysInfo("拾取类型错误: " .. PickTypeIndex)
        return 0
    end   
    
    -- 执行标准拾取
    DoStandardPick(PickTypeIndex)
    
    return 0
end

-- 执行只拾取指定物品
function PickSpecificItems()
	for i = 1, Config.PickFilterMaxItems do
		local filterItemName = Form.GetEditValue("pickFilterList" .. i)
		if IsValidFilterItem(filterItemName) then
			Game.PickItemName(filterItemName)
		end
	end
end

function DoStandardPick(PickTypeIndex)
    if PickTypeIndex == 0 then
        Game.PickAllItem(0, Config.PickTime)  -- 拾取全部物品
    elseif PickTypeIndex == 1 then
        Game.PickAllItem(1, Config.PickTime)  -- 拾取背包内道具
    elseif PickTypeIndex == 2 then
        Game.PickAllItem(2, Config.PickTime)  -- 拾取装备类型
    elseif PickTypeIndex == 3 then
        Game.PickAllItem(3, Config.PickTime)  -- 拾取杂物类型
    elseif PickTypeIndex == 4 then
        PickSpecificItems()  -- 执行只拾取指定物品
    end
end
