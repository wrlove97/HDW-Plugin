----修改调整.by:初雨Ryan -20250824
-- 最小和最大拾取延迟
local MIN_PICK_TIME = 100
local MAX_PICK_TIME = 5000

-- 载入捡东西配置
function OnPickScriptLoad(configFile)
	local needSavePickDefaults = false
	
	Config.PickType = Util.ReadConfigInteger("onlyPickType", "pick", configFile)
	if Config.PickType == nil or Config.PickType < 0 or Config.PickType > 1 then 
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
	
	-- 强制刷新UI设置
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	Form.SetEditValueInt("InPickTime", Config.PickTime)
	
	-- 如果需要保存默认值，则立即写入配置文件
	if needSavePickDefaults then
		Util.WriteConfigInteger(Config.PickType, "onlyPickType", "pick", configFile)
		Util.WriteConfigInteger(Config.PickTime, "InPickTime", "pick", configFile)
	end
end

-- 存储捡东西配置
function OnPickScriptSave(configFile)
	-- 保存拾取类型
	Config.PickType = Form.GetCheckGroupActiveIndex("chkOnlyPickType")
	Util.WriteConfigInteger(Config.PickType, "onlyPickType", "pick", configFile)
	
	-- 保存拾取延迟
	Config.PickTime = Form.GetEditValueInt("InPickTime")
	if Config.PickTime < MIN_PICK_TIME then
		Config.PickTime = MIN_PICK_TIME
		Form.SetEditValueInt("InPickTime", Config.PickTime)
	elseif Config.PickTime > MAX_PICK_TIME then
		Config.PickTime = MAX_PICK_TIME
		Form.SetEditValueInt("InPickTime", Config.PickTime)
	end
	Util.WriteConfigInteger(Config.PickTime, "InPickTime", "pick", configFile)
end

-- 执行拾取脚本
function DoPick(nDeep)
	-- 深度检测
	if nDeep > 5 then 
		return 0 
	end
	
	-- 获取当前拾取类型
	local pickType = Form.GetCheckGroupActiveIndex("chkOnlyPickType")
	
	-- 根据类型执行拾取
	if pickType == 0 then
		-- 拾取全部物品
		Game.PickAllItem(0, Config.PickTime)
	elseif pickType == 1 then
		-- 只拾取背包内道具
		Game.PickAllItem(1, Config.PickTime)
	end
	
	return 0
end
