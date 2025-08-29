----修改调整.by:初雨Ryan -20250824
-- 最小和最大拾取延迟
local MIN_PICK_TIME = 100
local MAX_PICK_TIME = 5000

-- 过滤提示时间控制
local lastFilterTipTime = 0
local FILTER_TIP_INTERVAL = 10000  -- 10秒间隔

-- 检查物品名称是否为有效过滤项
function IsValidFilterItem(itemName)
	return itemName ~= nil and itemName ~= "" and itemName ~= "功能暂不支持"
end

-- 检查过滤列表中是否有有效物品
function HasValidFilterItems()
	for i = 1, table.getn(Config.PickFilterList) do
		if IsValidFilterItem(Config.PickFilterList[i]) then
			return true
		end
	end
	return false
end

-- 保存过滤物品列表到配置文件
function SaveFilterItemsToConfig(configFile)
	for i = 1, Config.PickFilterMaxItems do
		local itemName = ""
		if i <= table.getn(Config.PickFilterList) then
			itemName = Config.PickFilterList[i]
		end
		Util.WriteConfigString(itemName, "pickFilterItem" .. i, "pick", configFile)
	end
end

-- 载入捡东西配置
function OnPickScriptLoad(configFile)
	local needSavePickDefaults = false
	
	Config.PickType = Util.ReadConfigInteger("onlyPickType", "pick", configFile)
	if Config.PickType == nil or Config.PickType < 0 or Config.PickType > 3 then 
		Config.PickType = 0  -- 默认：拾取全部物品
		needSavePickDefaults = true
	end
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	
	Config.PickTime = Util.ReadConfigInteger("InPickTime", "pick", configFile)
	if Config.PickTime == nil or Config.PickTime < MIN_PICK_TIME or Config.PickTime > MAX_PICK_TIME then 
		Config.PickTime = 500
		needSavePickDefaults = true
	end
	Form.SetEditValueInt("InPickTime", Config.PickTime)
	
	-- 加载过滤配置
	Config.PickFilterMode = Util.ReadConfigInteger("pickFilterMode", "pick", configFile)
	if Config.PickFilterMode == nil or Config.PickFilterMode < 0 or Config.PickFilterMode > 2 then
		Config.PickFilterMode = 0  -- 默认不过滤模式
		needSavePickDefaults = true
	end
	Form.SetCheckGroupActiveIndex("chkPickFilterMode", Config.PickFilterMode)
	
	-- 加载过滤物品列表
	Config.PickFilterList = {}
	local hasAnyItems = false
	for i = 1, Config.PickFilterMaxItems do
		local itemName = Util.ReadConfigString("pickFilterItem" .. i, "pick", configFile)
		if IsValidFilterItem(itemName) then
			table.insert(Config.PickFilterList, itemName)
			hasAnyItems = true
		end
	end
	
	-- 如果没有任何有效物品，填充默认提示
	if not hasAnyItems then
		for i = 1, Config.PickFilterMaxItems do
			table.insert(Config.PickFilterList, "功能暂不支持")
		end
		needSavePickDefaults = true
	end
	RefreshPickFilterDisplay()
	
	-- 强制刷新UI设置
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	Form.SetCheckGroupActiveIndex("chkPickFilterMode", Config.PickFilterMode)
	Form.SetEditValueInt("InPickTime", Config.PickTime)
	
	-- 如果需要保存默认值，则立即写入配置文件
	if needSavePickDefaults then
		Util.WriteConfigInteger(Config.PickType, "onlyPickType", "pick", configFile)
		Util.WriteConfigInteger(Config.PickTime, "InPickTime", "pick", configFile)
		Util.WriteConfigInteger(Config.PickFilterMode, "pickFilterMode", "pick", configFile)
		
		-- 保存默认物品列表
		SaveFilterItemsToConfig(configFile)

	end

end

-- 存储捡东西配置
function OnPickScriptSave(configFile)
    local PickTypeIndex = Form.GetCheckGroupActiveIndex("chkOnlyPickType")  -- 获取复选框组索引
    Util.WriteConfigInteger(PickTypeIndex, "onlyPickType", "pick", configFile)  -- 写入拾取类型
    
    local PickTimeNum = Form.GetEditValueInt("InPickTime")  -- 读取编辑框捡取延迟时间
    Util.WriteConfigInteger(PickTimeNum, "InPickTime", "pick", configFile)  -- 写入延迟时间
    
    -- 保存过滤配置
    local PickFilterModeIndex = Form.GetCheckGroupActiveIndex("chkPickFilterMode")
    Util.WriteConfigInteger(PickFilterModeIndex, "pickFilterMode", "pick", configFile)
    
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
    if PickTypeIndex < 0 or PickTypeIndex > 3 then
        Game.SysInfo("拾取类型错误: " .. PickTypeIndex)
        return 0
    end   
    
    local filterMode = Form.GetCheckGroupActiveIndex("chkPickFilterMode")
    
    -- 检查过滤模式
    if filterMode == 0 then
        -- 不过滤模式：正常拾取
        DoStandardPick(PickTypeIndex)
    else
        -- 只有当存在有效物品时才显示提示
        if HasValidFilterItems() then
            local currentTime = os.clock() * 1000  -- 转换为毫秒
            
            -- 检查是否已过间隔时间
            if currentTime >= lastFilterTipTime + FILTER_TIP_INTERVAL then
                if filterMode == 1 then
                    Game.SysInfo("白名单模式：过滤功能暂不支持，请使用不过滤模式")
                    lastFilterTipTime = currentTime
                elseif filterMode == 2 then
                    Game.SysInfo("黑名单模式：过滤功能暂不支持，请使用不过滤模式")
                    lastFilterTipTime = currentTime
                end
            end
        end
        
        -- 仍然执行标准拾取
        DoStandardPick(PickTypeIndex)
    end
    
    return 0
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
    end
end
