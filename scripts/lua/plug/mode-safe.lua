----修改调整.by:初雨Ryan -20250824
local allTime = 1000
local MIN_INTERVAL_TIME = 1  -- 最小间隔时间（秒）

--读取配置
function OnSafeScriptLoad(configFile)
	-- 读取HP物品配置 (HP1和HP2)
	local needSaveDefaults = false
	for i = 1, 2 do
		Config.safeHpItem[i].itemName = Util.ReadConfigString("safeHpItemName"..i, "safe", configFile)
		Config.safeHpItem[i].safeValue = Util.ReadConfigInteger("safeHpItemMax"..i, "safe", configFile)
		Config.safeHpItem[i].enable = Util.ReadConfigInteger("safeHpItemEnable"..i, "safe", configFile)
		
		-- 设置默认值
		if Config.safeHpItem[i].itemName == nil then 
			Config.safeHpItem[i].itemName = ""
			needSaveDefaults = true
		end
		if Config.safeHpItem[i].safeValue == nil or Config.safeHpItem[i].safeValue <= 0 then 
			Config.safeHpItem[i].safeValue = (i == 1) and 50 or 80
			needSaveDefaults = true
		end
		if Config.safeHpItem[i].enable == nil then 
			Config.safeHpItem[i].enable = 0
			needSaveDefaults = true
		end
		
		-- 设置UI值
		Form.SetEditValue("safeHpItemName"..i, Config.safeHpItem[i].itemName)
		Form.SetEditValueInt("safeHpItemMax"..i, Config.safeHpItem[i].safeValue)
		Form.SetCheckBoxValue("safeHpItemEnable"..i, Config.safeHpItem[i].enable)
	end
	
	-- 读取SP物品配置 (SP1和SP2)
	for i = 1, 2 do
		Config.safeSpItem[i].itemName = Util.ReadConfigString("safeSpItemName"..i, "safe", configFile)
		Config.safeSpItem[i].safeValue = Util.ReadConfigInteger("safeSpItemMax"..i, "safe", configFile)
		Config.safeSpItem[i].enable = Util.ReadConfigInteger("safeSpItemEnable"..i, "safe", configFile)
		
		-- 设置默认值
		if Config.safeSpItem[i].itemName == nil then 
			Config.safeSpItem[i].itemName = ""
			needSaveDefaults = true
		end
		if Config.safeSpItem[i].safeValue == nil or Config.safeSpItem[i].safeValue <= 0 then 
			Config.safeSpItem[i].safeValue = (i == 1) and 50 or 80
			needSaveDefaults = true
		end
		if Config.safeSpItem[i].enable == nil then 
			Config.safeSpItem[i].enable = 0
			needSaveDefaults = true
		end
		
		-- 设置UI值
		Form.SetEditValue("safeSpItemName"..i, Config.safeSpItem[i].itemName)
		Form.SetEditValueInt("safeSpItemMax"..i, Config.safeSpItem[i].safeValue)
		Form.SetCheckBoxValue("safeSpItemEnable"..i, Config.safeSpItem[i].enable)
	end

	-- 读取使用物品
	for i = 1, Config.safeUseItemMax do
		Config.safeUseItem[i].itemName = Util.ReadConfigString("useItemName"..i, "safe", configFile)
		Config.safeUseItem[i].intervalTime = Util.ReadConfigInteger("useItemInterval"..i, "safe", configFile)
		Config.safeUseItem[i].enable = Util.ReadConfigInteger("useItemEnable"..i, "safe", configFile)
		
		-- 设置默认值
		if Config.safeUseItem[i].itemName == nil then 
			Config.safeUseItem[i].itemName = ""
			needSaveDefaults = true
		end
		if Config.safeUseItem[i].intervalTime == nil or Config.safeUseItem[i].intervalTime < MIN_INTERVAL_TIME then
			Config.safeUseItem[i].intervalTime = 59 + i  -- 60, 61, 62, 63, 64, 65
			needSaveDefaults = true
		end
		if Config.safeUseItem[i].enable == nil then 
			Config.safeUseItem[i].enable = 0
			needSaveDefaults = true
		end
		
		Form.SetEditValue("useItemName"..i, Config.safeUseItem[i].itemName)
		Form.SetEditValueInt("useItemInterval"..i, Config.safeUseItem[i].intervalTime)
		Form.SetCheckBoxValue("useItemEnable"..i, Config.safeUseItem[i].enable)
	end
	
	-- 读取定时喊话
	Config.safeSay.sayContent = Util.ReadConfigString("safeSayContent", "safe", configFile)
	Config.safeSay.sayInterval = Util.ReadConfigInteger("safeSayInterval", "safe", configFile)
	Config.safeSay.sayEnable = Util.ReadConfigInteger("safeSayEnable", "safe", configFile)
	
	-- 设置默认值
	if Config.safeSay.sayContent == nil then 
		Config.safeSay.sayContent = ""
		needSaveDefaults = true
	end
	if Config.safeSay.sayInterval == nil or Config.safeSay.sayInterval < 5 then 
		Config.safeSay.sayInterval = 30
		needSaveDefaults = true
	end
	if Config.safeSay.sayEnable == nil then 
		Config.safeSay.sayEnable = 0
		needSaveDefaults = true
	end
	
	-- 设置定时喊话UI值
	Form.SetEditValue("safeSayContent", Config.safeSay.sayContent)
	Form.SetEditValueInt("safeSayInterval", Config.safeSay.sayInterval)
	Form.SetCheckBoxValue("safeSayEnable", Config.safeSay.sayEnable)
	
	-- 读取精灵配置
	Config.safePetHpItem.itemPetName = Util.ReadConfigString("PetHpItem", "safe", configFile)
	Config.safePetHpItem.safeValue = Util.ReadConfigInteger("PetHpValue", "safe", configFile)
	Config.safePetHpItem.enable = Util.ReadConfigInteger("PetEnable", "safe", configFile)
	Config.safePetHpItem.growPetItem = Util.ReadConfigString("PetGrowItem", "safe", configFile)
	Config.safePetHpItem.growEnable = Util.ReadConfigInteger("PetGrowEnable", "safe", configFile)
	
	-- 设置精灵默认值
	if Config.safePetHpItem.itemPetName == nil then 
		Config.safePetHpItem.itemPetName = ""
		needSaveDefaults = true
	end
	if Config.safePetHpItem.safeValue == nil or Config.safePetHpItem.safeValue <= 0 then 
		Config.safePetHpItem.safeValue = 50
		needSaveDefaults = true
	end
	if Config.safePetHpItem.enable == nil then 
		Config.safePetHpItem.enable = 0
		needSaveDefaults = true
	end
	if Config.safePetHpItem.growPetItem == nil then 
		Config.safePetHpItem.growPetItem = ""
		needSaveDefaults = true
	end
	if Config.safePetHpItem.growEnable == nil then 
		Config.safePetHpItem.growEnable = 0
		needSaveDefaults = true
	end
	
	-- 设置读取后的值
	Form.SetEditValue("PetHpItem", Config.safePetHpItem.itemPetName)
	Form.SetEditValueInt("PetHpValue", Config.safePetHpItem.safeValue)
	Form.SetCheckBoxValue("PetEnable", Config.safePetHpItem.enable)
	Form.SetEditValue("PetGrowItem", Config.safePetHpItem.growPetItem)
	Form.SetCheckBoxValue("PetGrowEnable", Config.safePetHpItem.growEnable)
	
    -- 读取队员信息
    for t = 1, Config.teamMaxinfo do
	   -- 是否确认角色 自动组队 自动邀请
        Config.teamInfo[t].play = Util.ReadConfigInteger("chkPlayer0"..t, "safe", configFile)
		Config.teamInfo[t].team = Util.ReadConfigInteger("chkTeam0"..t, "safe", configFile)
		Config.teamInfo[t].Invite = Util.ReadConfigInteger("chkInvite0"..t, "safe", configFile)
		Config.teamInfo[t].name = Util.ReadConfigString("play"..t, "safe", configFile)
		
		-- 设置队员默认值
		if Config.teamInfo[t].play == nil then 
			Config.teamInfo[t].play = 0
			needSaveDefaults = true
		end
		if Config.teamInfo[t].team == nil then 
			Config.teamInfo[t].team = 0
			needSaveDefaults = true
		end
		if Config.teamInfo[t].Invite == nil then 
			Config.teamInfo[t].Invite = 0
			needSaveDefaults = true
		end
		if Config.teamInfo[t].name == nil then 
			Config.teamInfo[t].name = ""
			needSaveDefaults = true
		end
		
		Form.SetEditValue("play"..t, Config.teamInfo[t].name)
        Form.SetCheckBoxValue("chkPlayer0"..t, Config.teamInfo[t].play)
		Form.SetCheckBoxValue("chkTeam0"..t, Config.teamInfo[t].team)
		Form.SetCheckBoxValue("chkInvite0"..t, Config.teamInfo[t].Invite)
    end
    
    -- 如果需要保存默认值，则立即写入配置文件
    if needSaveDefaults then
    	WriteDefaultSafeConfig(configFile)
    end
end

-- 写入默认安全配置
function WriteDefaultSafeConfig(configFile)
	-- 写入HP物品默认配置
	for i = 1, 2 do
		Util.WriteConfigString(Config.safeHpItem[i].itemName, "safeHpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].safeValue, "safeHpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].enable, "safeHpItemEnable"..i, "safe", configFile)
	end
	
	-- 写入SP物品默认配置
	for i = 1, 2 do
		Util.WriteConfigString(Config.safeSpItem[i].itemName, "safeSpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeSpItem[i].safeValue, "safeSpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeSpItem[i].enable, "safeSpItemEnable"..i, "safe", configFile)
	end
	
	-- 写入使用物品默认配置
	for i = 1, Config.safeUseItemMax do
		Util.WriteConfigString(Config.safeUseItem[i].itemName, "useItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeUseItem[i].intervalTime, "useItemInterval"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeUseItem[i].enable, "useItemEnable"..i, "safe", configFile)
	end
	
	-- 写入喊话默认配置
	Util.WriteConfigString(Config.safeSay.sayContent, "safeSayContent", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayInterval, "safeSayInterval", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayEnable, "safeSayEnable", "safe", configFile)
	
	-- 写入精灵默认配置
	Util.WriteConfigString(Config.safePetHpItem.itemPetName, "PetHpItem", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.safeValue, "PetHpValue", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.enable, "PetEnable", "safe", configFile)
	Util.WriteConfigString(Config.safePetHpItem.growPetItem, "PetGrowItem", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.growEnable, "PetGrowEnable", "safe", configFile)
	
	-- 写入队员默认配置
	for t = 1, Config.teamMaxinfo do
		Util.WriteConfigString(Config.teamInfo[t].name, "play"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].play, "chkPlayer0"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].team, "chkTeam0"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].Invite, "chkInvite0"..t, "safe", configFile)
	end
end

--存储配置
function OnSafeScriptSave(configFile)
	local now = os.clock() * allTime

	-- 存档HP物品配置 (HP1和HP2)
	for i = 1, 2 do
		Config.safeHpItem[i].itemName = Form.GetEditValue("safeHpItemName"..i)
		Config.safeHpItem[i].safeValue = Form.GetEditValueInt("safeHpItemMax"..i)
		Config.safeHpItem[i].enable = Form.GetCheckBoxValue("safeHpItemEnable"..i)
		
		Util.WriteConfigString(Config.safeHpItem[i].itemName, "safeHpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].safeValue, "safeHpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].enable, "safeHpItemEnable"..i, "safe", configFile)
	end

	-- 存档SP物品配置 (SP1和SP2)
	for i = 1, 2 do
		Config.safeSpItem[i].itemName = Form.GetEditValue("safeSpItemName"..i)
		Config.safeSpItem[i].safeValue = Form.GetEditValueInt("safeSpItemMax"..i)
		Config.safeSpItem[i].enable = Form.GetCheckBoxValue("safeSpItemEnable"..i)
		
		Util.WriteConfigString(Config.safeSpItem[i].itemName, "safeSpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeSpItem[i].safeValue, "safeSpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeSpItem[i].enable, "safeSpItemEnable"..i, "safe", configFile)
	end

	-- 存档使用物品
	for i = 1, Config.safeUseItemMax do
	    Config.safeUseItem[i].itemName = Form.GetEditValue("useItemName"..i)
	    local intervalTime = Form.GetEditValueInt("useItemInterval"..i)
	    -- 强制设置最小间隔时间
	    if intervalTime < MIN_INTERVAL_TIME then
	        intervalTime = MIN_INTERVAL_TIME
	        Form.SetEditValueInt("useItemInterval"..i, intervalTime)
	    end
	    Config.safeUseItem[i].intervalTime = intervalTime
	    Config.safeUseItem[i].enable = Form.GetCheckBoxValue("useItemEnable"..i)
	    Config.safeUseItem[i].nextUseTime = now + Config.safeUseItem[i].intervalTime*allTime
	    Util.WriteConfigString(Config.safeUseItem[i].itemName, "useItemName"..i, "safe", configFile)
	    Util.WriteConfigInteger(Config.safeUseItem[i].intervalTime, "useItemInterval"..i, "safe", configFile)
	    Util.WriteConfigInteger(Config.safeUseItem[i].enable, "useItemEnable"..i, "safe", configFile)
	end
	
	-- 存档定时喊话
	Config.safeSay.sayContent = Form.GetEditValue("safeSayContent")
	Config.safeSay.sayInterval = Form.GetEditValueInt("safeSayInterval")
	Config.safeSay.sayEnable = Form.GetCheckBoxValue("safeSayEnable")
	Config.safeSay.nextSayTime = now + Config.safeSay.sayInterval*allTime
	Util.WriteConfigString(Config.safeSay.sayContent, "safeSayContent", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayInterval, "safeSayInterval", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayEnable, "safeSayEnable", "safe", configFile)
	
	--存档精灵配置
	Config.safePetHpItem.itemPetName = Form.GetEditValue("PetHpItem")
	Config.safePetHpItem.safeValue = Form.GetEditValueInt("PetHpValue")
	Config.safePetHpItem.enable = Form.GetCheckBoxValue("PetEnable")
	Config.safePetHpItem.growPetItem = Form.GetEditValue("PetGrowItem")
	Config.safePetHpItem.growEnable = Form.GetCheckBoxValue("PetGrowEnable")
	
	Util.WriteConfigString(Config.safePetHpItem.itemPetName, "PetHpItem", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.safeValue, "PetHpValue", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.enable, "PetEnable", "safe", configFile)
	Util.WriteConfigString(Config.safePetHpItem.growPetItem, "PetGrowItem", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.growEnable, "PetGrowEnable", "safe", configFile)
	
    -- 保存队伍人员选择
    for t = 1, Config.teamMaxinfo do
        Config.teamInfo[t].play = Form.GetCheckBoxValue("chkPlayer0"..t)
		Config.teamInfo[t].team = Form.GetCheckBoxValue("chkTeam0"..t)
		Config.teamInfo[t].Invite = Form.GetCheckBoxValue("chkInvite0"..t)
		Config.teamInfo[t].name = Form.GetEditValue("play"..t)
		
		Util.WriteConfigString(Config.teamInfo[t].name, "play"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].play, "chkPlayer0"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].team, "chkTeam0"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].Invite, "chkInvite0"..t, "safe", configFile)
    end
end

-- 全局物品使用时间记录（确保所有物品使用间隔1秒）
local lastItemUseTime = 0

-- 使用安全道具
function UseSafeItem(now)
	-- 如果距离上次使用物品不足1秒，直接返回
	if now < lastItemUseTime + MIN_INTERVAL_TIME * allTime then
		return
	end
	
	local hp = Game.GetCharAttr(Game.GetCurChar(), ATTR_HP)
	local hpmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_HPMAX)
	local sp = Game.GetCharAttr(Game.GetCurChar(), ATTR_SP)
	local spmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_SPMAX)
	
	-- 按优先级检查HP物品使用（HP1优先级高于HP2）
	for i = 1, 2 do
		if Config.safeHpItem[i].enable == 1 and Config.safeHpItem[i].itemName ~= "" then
			if hp <= (hpmax * (Config.safeHpItem[i].safeValue/100)) then
				if Game.HasItem(Config.safeHpItem[i].itemName) then
					if Game.UseItem(Config.safeHpItem[i].itemName) == 1 then
						lastItemUseTime = now
						return
					end
				end
			end
		end
	end
	
	-- 按优先级检查SP物品使用（SP1优先级高于SP2）
	for i = 1, 2 do
		if Config.safeSpItem[i].enable == 1 and Config.safeSpItem[i].itemName ~= "" then
			if sp <= (spmax * (Config.safeSpItem[i].safeValue/100)) then
				if Game.HasItem(Config.safeSpItem[i].itemName) then
					if Game.UseItem(Config.safeSpItem[i].itemName) == 1 then
						lastItemUseTime = now
						return
					end
				end
			end
		end
	end
end

--使用精灵物品配置
function UsePetItem(now)
   -- 如果距离上次使用物品不足1秒，直接返回
   if now < lastItemUseTime + MIN_INTERVAL_TIME * allTime then
      return
   end
   
   local petMaxHp = Game.GetPetAttrMaxHp()
   local petCurHp = Game.GetPetAttrCurHp()
   --Game.SysInfo(""..petMaxHp.." "..petCurHp.." "..Game.GetPetAttrGrow().."")
   
   --精灵恢复HP
   if Config.safePetHpItem.enable == 1 and Config.safePetHpItem.itemPetName ~= "" then
      if petCurHp <= (petMaxHp*(Config.safePetHpItem.safeValue/100)) then
	        if Game.HasItem(Config.safePetHpItem.itemPetName) then
		       if Game.UseItem(Config.safePetHpItem.itemPetName) == 1 then
		          lastItemUseTime = now
		          return
		       end
		    end
	  end
   end
   
   --精灵升级
   local petGrowExp = Game.GetPetAttrGrow()
   if Config.safePetHpItem.growEnable == 1 and Config.safePetHpItem.growPetItem ~= "" then
      if petGrowExp == 1 then
	        if Game.HasItem(Config.safePetHpItem.growPetItem) then
		       if Game.UseItem(Config.safePetHpItem.growPetItem) == 1 then
		          lastItemUseTime = now
		          return
		       end
		    end
	  end
   end
end

--使用物品定时
function UseNextItem(now)
   -- 如果距离上次使用物品不足1秒，直接返回
   if now < lastItemUseTime + MIN_INTERVAL_TIME * allTime then
      return false
   end
   
   for i = 1, Config.safeUseItemMax do 
      local itemName = Config.safeUseItem[i].itemName	
      local intervalTime = Config.safeUseItem[i].intervalTime
      local enable = Config.safeUseItem[i].enable
   --Game.SysInfo(""..intervalTime.." "..Config.safeUseItem[i].nextUseTime.."")
      if itemName ~= "" and enable == 1 then
        if Config.safeUseItem[i].nextUseTime < now then
	       if Game.HasItem(itemName) then
		      if Game.UseItem(itemName) == 1 then
			     Config.safeUseItem[i].nextUseTime = now + intervalTime*allTime --使用成功增加时间
			     lastItemUseTime = now  -- 更新全局使用时间
			     return true
			  else
			     Config.safeUseItem[i].nextUseTime = now + intervalTime*allTime --失败也增加时间
			     return false
			  end
           else
               -- 物品不存在，延迟重试
               Config.safeUseItem[i].nextUseTime = now + 5*allTime
               return false
           end		 
	    end
      end
   end
   return false
end

-- 定时喊话
function SayShiye(now)
	local sayContent = Config.safeSay.sayContent
	local sayInterval = Config.safeSay.sayInterval
	local sayEnable = Config.safeSay.sayEnable
	
	-- 检查参数有效性
	if sayContent == nil then sayContent = "" end
	if sayInterval == nil or sayInterval < 5 then sayInterval = 60 end
	if sayEnable == nil then sayEnable = 0 end
	
	-- 如果启用喊话且内容不为空
	if sayContent ~= "" and sayEnable == 1 then
		if Config.safeSay.nextSayTime < now then
			Game.Say(sayContent)
			Config.safeSay.nextSayTime = now + sayInterval*allTime
		end
	end
	return false
end

--自动邀请组队
function AutoInviteTeam(Play_name)
    if Play_name == "" then
        return
    end
    
    local pPlay = Game.FindCharByName(Play_name, 1, Config.fightRange)
    if pPlay == nil then 
	   return 
	end

	Game.AutoTeamChaName(pPlay, Play_name)
end

--判断邀请的是否组队
local teamFlag = 0     --自动邀请组队 做标记
local teamConfim = 0   --自动确认标记
local TeamNextTime = 0

-- 自动检测 自动邀请组队
function AutoTeamNow(now)
    -- 组队时间间隔检查
    if TeamNextTime > now then
        return
    end
    
    local PlayName01 = Form.GetEditValue("play1")
    if PlayName01 == "" then
        TeamNextTime = now + 6*allTime
        return
    end
    
    local pMySelf = Game.FindCharByName(PlayName01, 1, Config.fightRange)
    if pMySelf == nil then
        TeamNextTime = now + 6*allTime
        return
    end
    
    local teamSize = Game.IsInTeam(pMySelf)
    if teamSize == 4 then
        Game.SysInfo("组队已经满，无法正常组队！")
        TeamNextTime = now + 36*allTime  -- 满队后延长检查间隔
        return
    end
    
    local CheckInvite = Form.GetCheckBoxValue("chkInvite01")
    local ComfigTeam02 = Form.GetCheckBoxValue("chkTeam02")
    local ComfigTeam03 = Form.GetCheckBoxValue("chkTeam03")
    local ComfigTeam04 = Form.GetCheckBoxValue("chkTeam04")
    local ComfigTeam05 = Form.GetCheckBoxValue("chkTeam05")
    
    -- 自动邀请组队
    if CheckInvite == 1 then
        for i = 2, Config.teamMaxinfo do 
            local playName = Form.GetEditValue("play"..i)
            if playName ~= "" then
                local pCha = Game.FindCharByName(playName, 1, Config.fightRange)
                if pCha ~= nil and Game.IsInTeam(pCha) == 0 then  
                    AutoInviteTeam(playName)
                end
            end
        end
    end
    
    -- 自动确认组队邀请
    if ComfigTeam02 == 1 or ComfigTeam03 == 1 or ComfigTeam04 == 1 or ComfigTeam05 == 1 then
        for i = 2, Config.teamMaxinfo do 
            local comfigPlay = Form.GetEditValue("play"..i)
            if comfigPlay ~= "" then
                local pPlay = Game.FindCharByName(comfigPlay, 1, Config.fightRange)
                if pPlay ~= nil then
                    Game.AutoTeamComfig(pPlay)
                end
            end
        end
    end

    TeamNextTime = now + 6*allTime
end

-- 执行安全脚本
function DoSafe(nDeep)
	local now = os.clock() * allTime
	
	UseSafeItem(now)    --使用HP/SP定时器
	
	UseNextItem(now)    --使用物品定时器

	UsePetItem(now)     --使用精灵配置
	
	SayShiye(now)       --说话定时器
	
	AutoTeamNow(now)   --自动组队，自动邀请
	
	return 0
end
