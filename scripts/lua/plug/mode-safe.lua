local allTime = 1000
local MIN_INTERVAL_TIME = 1  -- ��С���ʱ�䣨�룩

--��ȡ����
function OnSafeScriptLoad(configFile)
	-- ��ȡHP��Ʒ���� (HP1��HP2)
	for i = 1, 2 do
		Config.safeHpItem[i].itemName = Util.ReadConfigString("safeHpItemName"..i, "safe", configFile)
		Config.safeHpItem[i].safeValue = Util.ReadConfigInteger("safeHpItemMax"..i, "safe", configFile)
		Config.safeHpItem[i].enable = Util.ReadConfigInteger("safeHpItemEnable"..i, "safe", configFile)
		
		-- ����Ĭ��ֵ
		if Config.safeHpItem[i].itemName == nil then 
			Config.safeHpItem[i].itemName = ""
		end
		if Config.safeHpItem[i].safeValue == nil or Config.safeHpItem[i].safeValue <= 0 then 
			Config.safeHpItem[i].safeValue = (i == 1) and 50 or 80
		end
		if Config.safeHpItem[i].enable == nil then 
			Config.safeHpItem[i].enable = 0
		end
		
		-- ����UIֵ
		Form.SetEditValue("safeHpItemName"..i, Config.safeHpItem[i].itemName)
		Form.SetEditValueInt("safeHpItemMax"..i, Config.safeHpItem[i].safeValue)
		Form.SetCheckBoxValue("safeHpItemEnable"..i, Config.safeHpItem[i].enable)
	end
	
	-- ��ȡSP��Ʒ���� (SP1��SP2)
	for i = 1, 2 do
		Config.safeSpItem[i].itemName = Util.ReadConfigString("safeSpItemName"..i, "safe", configFile)
		Config.safeSpItem[i].safeValue = Util.ReadConfigInteger("safeSpItemMax"..i, "safe", configFile)
		Config.safeSpItem[i].enable = Util.ReadConfigInteger("safeSpItemEnable"..i, "safe", configFile)
		
		-- ����Ĭ��ֵ
		if Config.safeSpItem[i].itemName == nil then 
			Config.safeSpItem[i].itemName = ""
		end
		if Config.safeSpItem[i].safeValue == nil or Config.safeSpItem[i].safeValue <= 0 then 
			Config.safeSpItem[i].safeValue = (i == 1) and 50 or 80
		end
		if Config.safeSpItem[i].enable == nil then 
			Config.safeSpItem[i].enable = 0
		end
		
		-- ����UIֵ
		Form.SetEditValue("safeSpItemName"..i, Config.safeSpItem[i].itemName)
		Form.SetEditValueInt("safeSpItemMax"..i, Config.safeSpItem[i].safeValue)
		Form.SetCheckBoxValue("safeSpItemEnable"..i, Config.safeSpItem[i].enable)
	end

	-- ��ȡʹ����Ʒ
	for i = 1, Config.safeUseItemMax do
		Config.safeUseItem[i].itemName = Util.ReadConfigString("useItemName"..i, "safe", configFile)
		Config.safeUseItem[i].intervalTime = Util.ReadConfigInteger("useItemInterval"..i, "safe", configFile)
		Config.safeUseItem[i].nextUseTime = 0
		Config.safeUseItem[i].enable = Util.ReadConfigInteger("useItemEnable"..i, "safe", configFile)
		
		-- ����Ĭ��ֵ
		if Config.safeUseItem[i].itemName == nil then 
			Config.safeUseItem[i].itemName = ""
		end
		if Config.safeUseItem[i].intervalTime == nil or Config.safeUseItem[i].intervalTime < MIN_INTERVAL_TIME then
			Config.safeUseItem[i].intervalTime = 60 + i - 1
		end
		if Config.safeUseItem[i].enable == nil then 
			Config.safeUseItem[i].enable = 0
		end
		
		Form.SetEditValue("useItemName"..i, Config.safeUseItem[i].itemName)
		Form.SetEditValueInt("useItemInterval"..i, Config.safeUseItem[i].intervalTime)
		Form.SetCheckBoxValue("useItemEnable"..i, Config.safeUseItem[i].enable)
	end
	
	-- ��ȡ��ʱ����
	Config.safeSay.sayContent = Util.ReadConfigString("safeSayContent", "safe", configFile)
	Config.safeSay.sayInterval = Util.ReadConfigInteger("safeSayInterval", "safe", configFile)
	Config.safeSay.sayEnable = Util.ReadConfigInteger("safeSayEnable", "safe", configFile)
	
	-- ����Ĭ��ֵ
	if Config.safeSay.sayContent == nil then 
		Config.safeSay.sayContent = ""
	end
	if Config.safeSay.sayInterval == nil or Config.safeSay.sayInterval < 5 then 
		Config.safeSay.sayInterval = 30
	end
	if Config.safeSay.sayEnable == nil then 
		Config.safeSay.sayEnable = 0
	end
	
	-- ���ö�ʱ����UIֵ
	Form.SetEditValue("safeSayContent", Config.safeSay.sayContent)
	Form.SetEditValueInt("safeSayInterval", Config.safeSay.sayInterval)
	Form.SetCheckBoxValue("safeSayEnable", Config.safeSay.sayEnable)
end

-- �浵��ȫ����
function OnSafeScriptSave(configFile)
	-- �浵HP��Ʒ����
	for i = 1, 2 do
		Config.safeHpItem[i].itemName = Form.GetEditValue("safeHpItemName"..i)
		Config.safeHpItem[i].safeValue = Form.GetEditValueInt("safeHpItemMax"..i)
		Config.safeHpItem[i].enable = Form.GetCheckBoxValue("safeHpItemEnable"..i)
		
		Util.WriteConfigString(Config.safeHpItem[i].itemName, "safeHpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].safeValue, "safeHpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].enable, "safeHpItemEnable"..i, "safe", configFile)
	end
	
	-- �浵SP��Ʒ����
	for i = 1, 2 do
		Config.safeSpItem[i].itemName = Form.GetEditValue("safeSpItemName"..i)
		Config.safeSpItem[i].safeValue = Form.GetEditValueInt("safeSpItemMax"..i)
		Config.safeSpItem[i].enable = Form.GetCheckBoxValue("safeSpItemEnable"..i)
		
		Util.WriteConfigString(Config.safeSpItem[i].itemName, "safeSpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeSpItem[i].safeValue, "safeSpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeSpItem[i].enable, "safeSpItemEnable"..i, "safe", configFile)
	end

	-- �浵ʹ����Ʒ
	for i = 1, Config.safeUseItemMax do
		Config.safeUseItem[i].itemName = Form.GetEditValue("useItemName"..i)
		Config.safeUseItem[i].intervalTime = Form.GetEditValueInt("useItemInterval"..i)
		Config.safeUseItem[i].enable = Form.GetCheckBoxValue("useItemEnable"..i)
		
		Util.WriteConfigString(Config.safeUseItem[i].itemName, "useItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeUseItem[i].intervalTime, "useItemInterval"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeUseItem[i].enable, "useItemEnable"..i, "safe", configFile)
	end
	
	-- �浵��ʱ����
	Config.safeSay.sayContent = Form.GetEditValue("safeSayContent")
	Config.safeSay.sayInterval = Form.GetEditValueInt("safeSayInterval")
	Config.safeSay.sayEnable = Form.GetCheckBoxValue("safeSayEnable")
	
	Util.WriteConfigString(Config.safeSay.sayContent, "safeSayContent", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayInterval, "safeSayInterval", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayEnable, "safeSayEnable", "safe", configFile)
end

-- ����HP����
function HandleHpProtection()
	local hp = Game.GetCharAttr(Game.GetCurChar(), ATTR_HP)
	local hpmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_HPMAX)
	local hpPercent = (hp / hpmax) * 100
	
	for i = 1, 2 do
		if Config.safeHpItem[i].enable == 1 and Config.safeHpItem[i].itemName ~= "" then
			if hpPercent <= Config.safeHpItem[i].safeValue then
				if Game.HasItem(Config.safeHpItem[i].itemName) then
					Game.UseItem(Config.safeHpItem[i].itemName)
					return
				end
			end
		end
	end
end

-- ����SP����
function HandleSpProtection()
	local sp = Game.GetCharAttr(Game.GetCurChar(), ATTR_SP)
	local spmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_SPMAX)
	local spPercent = (sp / spmax) * 100
	
	for i = 1, 2 do
		if Config.safeSpItem[i].enable == 1 and Config.safeSpItem[i].itemName ~= "" then
			if spPercent <= Config.safeSpItem[i].safeValue then
				if Game.HasItem(Config.safeSpItem[i].itemName) then
					Game.UseItem(Config.safeSpItem[i].itemName)
					return
				end
			end
		end
	end
end

-- ����ʱʹ����Ʒ
function HandleTimedItems()
	local now = os.clock() * allTime
	
	for i = 1, Config.safeUseItemMax do
		if Config.safeUseItem[i].enable == 1 and Config.safeUseItem[i].itemName ~= "" and Config.safeUseItem[i].intervalTime > 0 then
			if now >= Config.safeUseItem[i].nextUseTime then
				if Game.HasItem(Config.safeUseItem[i].itemName) then
					Game.UseItem(Config.safeUseItem[i].itemName)
					Config.safeUseItem[i].nextUseTime = now + Config.safeUseItem[i].intervalTime * allTime
				end
			end
		end
	end
end

-- ����ʱ����
function HandleTimedSay()
	if Config.safeSay.sayEnable == 1 and Config.safeSay.sayContent ~= "" then
		local now = os.clock() * allTime
		if now >= Config.safeSay.nextSayTime then
			Game.Say(Config.safeSay.sayContent)
			Config.safeSay.nextSayTime = now + Config.safeSay.sayInterval * allTime
		end
	end
end

-- ִ�а�ȫ�ű�
function DoSafe(nDeep)
	-- ��ȼ��
	if nDeep > 5 then 
		return 0 
	end
	
	-- ����HP����
	HandleHpProtection()
	
	-- ����SP����
	HandleSpProtection()
	
	-- ����ʱʹ����Ʒ
	HandleTimedItems()
	
	-- ����ʱ����
	HandleTimedSay()
	
	return 0
end

