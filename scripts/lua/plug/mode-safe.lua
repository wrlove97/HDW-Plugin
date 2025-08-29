----�޸ĵ���.by:����Ryan -20250824
local allTime = 1000
local MIN_INTERVAL_TIME = 1  -- ��С���ʱ�䣨�룩

--��ȡ����
function OnSafeScriptLoad(configFile)
	-- ��ȡHP��Ʒ���� (HP1��HP2)
	local needSaveDefaults = false
	for i = 1, 2 do
		Config.safeHpItem[i].itemName = Util.ReadConfigString("safeHpItemName"..i, "safe", configFile)
		Config.safeHpItem[i].safeValue = Util.ReadConfigInteger("safeHpItemMax"..i, "safe", configFile)
		Config.safeHpItem[i].enable = Util.ReadConfigInteger("safeHpItemEnable"..i, "safe", configFile)
		
		-- ����Ĭ��ֵ
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
		
		-- ����UIֵ
		Form.SetEditValue("safeSpItemName"..i, Config.safeSpItem[i].itemName)
		Form.SetEditValueInt("safeSpItemMax"..i, Config.safeSpItem[i].safeValue)
		Form.SetCheckBoxValue("safeSpItemEnable"..i, Config.safeSpItem[i].enable)
	end

	-- ��ȡʹ����Ʒ
	for i = 1, Config.safeUseItemMax do
		Config.safeUseItem[i].itemName = Util.ReadConfigString("useItemName"..i, "safe", configFile)
		Config.safeUseItem[i].intervalTime = Util.ReadConfigInteger("useItemInterval"..i, "safe", configFile)
		Config.safeUseItem[i].enable = Util.ReadConfigInteger("useItemEnable"..i, "safe", configFile)
		
		-- ����Ĭ��ֵ
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
	
	-- ��ȡ��ʱ����
	Config.safeSay.sayContent = Util.ReadConfigString("safeSayContent", "safe", configFile)
	Config.safeSay.sayInterval = Util.ReadConfigInteger("safeSayInterval", "safe", configFile)
	Config.safeSay.sayEnable = Util.ReadConfigInteger("safeSayEnable", "safe", configFile)
	
	-- ����Ĭ��ֵ
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
	
	-- ���ö�ʱ����UIֵ
	Form.SetEditValue("safeSayContent", Config.safeSay.sayContent)
	Form.SetEditValueInt("safeSayInterval", Config.safeSay.sayInterval)
	Form.SetCheckBoxValue("safeSayEnable", Config.safeSay.sayEnable)
	
	-- ��ȡ��������
	Config.safePetHpItem.itemPetName = Util.ReadConfigString("PetHpItem", "safe", configFile)
	Config.safePetHpItem.safeValue = Util.ReadConfigInteger("PetHpValue", "safe", configFile)
	Config.safePetHpItem.enable = Util.ReadConfigInteger("PetEnable", "safe", configFile)
	Config.safePetHpItem.growPetItem = Util.ReadConfigString("PetGrowItem", "safe", configFile)
	Config.safePetHpItem.growEnable = Util.ReadConfigInteger("PetGrowEnable", "safe", configFile)
	
	-- ���þ���Ĭ��ֵ
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
	
	-- ���ö�ȡ���ֵ
	Form.SetEditValue("PetHpItem", Config.safePetHpItem.itemPetName)
	Form.SetEditValueInt("PetHpValue", Config.safePetHpItem.safeValue)
	Form.SetCheckBoxValue("PetEnable", Config.safePetHpItem.enable)
	Form.SetEditValue("PetGrowItem", Config.safePetHpItem.growPetItem)
	Form.SetCheckBoxValue("PetGrowEnable", Config.safePetHpItem.growEnable)
	
    -- ��ȡ��Ա��Ϣ
    for t = 1, Config.teamMaxinfo do
	   -- �Ƿ�ȷ�Ͻ�ɫ �Զ���� �Զ�����
        Config.teamInfo[t].play = Util.ReadConfigInteger("chkPlayer0"..t, "safe", configFile)
		Config.teamInfo[t].team = Util.ReadConfigInteger("chkTeam0"..t, "safe", configFile)
		Config.teamInfo[t].Invite = Util.ReadConfigInteger("chkInvite0"..t, "safe", configFile)
		Config.teamInfo[t].name = Util.ReadConfigString("play"..t, "safe", configFile)
		
		-- ���ö�ԱĬ��ֵ
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
    
    -- �����Ҫ����Ĭ��ֵ��������д�������ļ�
    if needSaveDefaults then
    	WriteDefaultSafeConfig(configFile)
    end
end

-- д��Ĭ�ϰ�ȫ����
function WriteDefaultSafeConfig(configFile)
	-- д��HP��ƷĬ������
	for i = 1, 2 do
		Util.WriteConfigString(Config.safeHpItem[i].itemName, "safeHpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].safeValue, "safeHpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].enable, "safeHpItemEnable"..i, "safe", configFile)
	end
	
	-- д��SP��ƷĬ������
	for i = 1, 2 do
		Util.WriteConfigString(Config.safeSpItem[i].itemName, "safeSpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeSpItem[i].safeValue, "safeSpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeSpItem[i].enable, "safeSpItemEnable"..i, "safe", configFile)
	end
	
	-- д��ʹ����ƷĬ������
	for i = 1, Config.safeUseItemMax do
		Util.WriteConfigString(Config.safeUseItem[i].itemName, "useItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeUseItem[i].intervalTime, "useItemInterval"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeUseItem[i].enable, "useItemEnable"..i, "safe", configFile)
	end
	
	-- д�뺰��Ĭ������
	Util.WriteConfigString(Config.safeSay.sayContent, "safeSayContent", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayInterval, "safeSayInterval", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayEnable, "safeSayEnable", "safe", configFile)
	
	-- д�뾫��Ĭ������
	Util.WriteConfigString(Config.safePetHpItem.itemPetName, "PetHpItem", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.safeValue, "PetHpValue", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.enable, "PetEnable", "safe", configFile)
	Util.WriteConfigString(Config.safePetHpItem.growPetItem, "PetGrowItem", "safe", configFile)
	Util.WriteConfigInteger(Config.safePetHpItem.growEnable, "PetGrowEnable", "safe", configFile)
	
	-- д���ԱĬ������
	for t = 1, Config.teamMaxinfo do
		Util.WriteConfigString(Config.teamInfo[t].name, "play"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].play, "chkPlayer0"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].team, "chkTeam0"..t, "safe", configFile)
		Util.WriteConfigInteger(Config.teamInfo[t].Invite, "chkInvite0"..t, "safe", configFile)
	end
end

--�洢����
function OnSafeScriptSave(configFile)
	local now = os.clock() * allTime

	-- �浵HP��Ʒ���� (HP1��HP2)
	for i = 1, 2 do
		Config.safeHpItem[i].itemName = Form.GetEditValue("safeHpItemName"..i)
		Config.safeHpItem[i].safeValue = Form.GetEditValueInt("safeHpItemMax"..i)
		Config.safeHpItem[i].enable = Form.GetCheckBoxValue("safeHpItemEnable"..i)
		
		Util.WriteConfigString(Config.safeHpItem[i].itemName, "safeHpItemName"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].safeValue, "safeHpItemMax"..i, "safe", configFile)
		Util.WriteConfigInteger(Config.safeHpItem[i].enable, "safeHpItemEnable"..i, "safe", configFile)
	end

	-- �浵SP��Ʒ���� (SP1��SP2)
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
	    local intervalTime = Form.GetEditValueInt("useItemInterval"..i)
	    -- ǿ��������С���ʱ��
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
	
	-- �浵��ʱ����
	Config.safeSay.sayContent = Form.GetEditValue("safeSayContent")
	Config.safeSay.sayInterval = Form.GetEditValueInt("safeSayInterval")
	Config.safeSay.sayEnable = Form.GetCheckBoxValue("safeSayEnable")
	Config.safeSay.nextSayTime = now + Config.safeSay.sayInterval*allTime
	Util.WriteConfigString(Config.safeSay.sayContent, "safeSayContent", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayInterval, "safeSayInterval", "safe", configFile)
	Util.WriteConfigInteger(Config.safeSay.sayEnable, "safeSayEnable", "safe", configFile)
	
	--�浵��������
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
	
    -- ���������Աѡ��
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

-- ȫ����Ʒʹ��ʱ���¼��ȷ��������Ʒʹ�ü��1�룩
local lastItemUseTime = 0

-- ʹ�ð�ȫ����
function UseSafeItem(now)
	-- ��������ϴ�ʹ����Ʒ����1�룬ֱ�ӷ���
	if now < lastItemUseTime + MIN_INTERVAL_TIME * allTime then
		return
	end
	
	local hp = Game.GetCharAttr(Game.GetCurChar(), ATTR_HP)
	local hpmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_HPMAX)
	local sp = Game.GetCharAttr(Game.GetCurChar(), ATTR_SP)
	local spmax = Game.GetCharAttr(Game.GetCurChar(), ATTR_SPMAX)
	
	-- �����ȼ����HP��Ʒʹ�ã�HP1���ȼ�����HP2��
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
	
	-- �����ȼ����SP��Ʒʹ�ã�SP1���ȼ�����SP2��
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

--ʹ�þ�����Ʒ����
function UsePetItem(now)
   -- ��������ϴ�ʹ����Ʒ����1�룬ֱ�ӷ���
   if now < lastItemUseTime + MIN_INTERVAL_TIME * allTime then
      return
   end
   
   local petMaxHp = Game.GetPetAttrMaxHp()
   local petCurHp = Game.GetPetAttrCurHp()
   --Game.SysInfo(""..petMaxHp.." "..petCurHp.." "..Game.GetPetAttrGrow().."")
   
   --����ָ�HP
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
   
   --��������
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

--ʹ����Ʒ��ʱ
function UseNextItem(now)
   -- ��������ϴ�ʹ����Ʒ����1�룬ֱ�ӷ���
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
			     Config.safeUseItem[i].nextUseTime = now + intervalTime*allTime --ʹ�óɹ�����ʱ��
			     lastItemUseTime = now  -- ����ȫ��ʹ��ʱ��
			     return true
			  else
			     Config.safeUseItem[i].nextUseTime = now + intervalTime*allTime --ʧ��Ҳ����ʱ��
			     return false
			  end
           else
               -- ��Ʒ�����ڣ��ӳ�����
               Config.safeUseItem[i].nextUseTime = now + 5*allTime
               return false
           end		 
	    end
      end
   end
   return false
end

-- ��ʱ����
function SayShiye(now)
	local sayContent = Config.safeSay.sayContent
	local sayInterval = Config.safeSay.sayInterval
	local sayEnable = Config.safeSay.sayEnable
	
	-- ��������Ч��
	if sayContent == nil then sayContent = "" end
	if sayInterval == nil or sayInterval < 5 then sayInterval = 60 end
	if sayEnable == nil then sayEnable = 0 end
	
	-- ������ú��������ݲ�Ϊ��
	if sayContent ~= "" and sayEnable == 1 then
		if Config.safeSay.nextSayTime < now then
			Game.Say(sayContent)
			Config.safeSay.nextSayTime = now + sayInterval*allTime
		end
	end
	return false
end

--�Զ��������
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

--�ж�������Ƿ����
local teamFlag = 0     --�Զ�������� �����
local teamConfim = 0   --�Զ�ȷ�ϱ��
local TeamNextTime = 0

-- �Զ���� �Զ��������
function AutoTeamNow(now)
    -- ���ʱ�������
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
        Game.SysInfo("����Ѿ������޷�������ӣ�")
        TeamNextTime = now + 36*allTime  -- ���Ӻ��ӳ������
        return
    end
    
    local CheckInvite = Form.GetCheckBoxValue("chkInvite01")
    local ComfigTeam02 = Form.GetCheckBoxValue("chkTeam02")
    local ComfigTeam03 = Form.GetCheckBoxValue("chkTeam03")
    local ComfigTeam04 = Form.GetCheckBoxValue("chkTeam04")
    local ComfigTeam05 = Form.GetCheckBoxValue("chkTeam05")
    
    -- �Զ��������
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
    
    -- �Զ�ȷ���������
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

-- ִ�а�ȫ�ű�
function DoSafe(nDeep)
	local now = os.clock() * allTime
	
	UseSafeItem(now)    --ʹ��HP/SP��ʱ��
	
	UseNextItem(now)    --ʹ����Ʒ��ʱ��

	UsePetItem(now)     --ʹ�þ�������
	
	SayShiye(now)       --˵����ʱ��
	
	AutoTeamNow(now)   --�Զ���ӣ��Զ�����
	
	return 0
end
