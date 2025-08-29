----�޸ĵ���.by:����Ryan -20250824
-- ��С�����ʰȡ�ӳ�
local MIN_PICK_TIME = 100
local MAX_PICK_TIME = 5000

-- ������ʾʱ�����
local lastFilterTipTime = 0
local FILTER_TIP_INTERVAL = 10000  -- 10����

-- �����Ʒ�����Ƿ�Ϊ��Ч������
function IsValidFilterItem(itemName)
	return itemName ~= nil and itemName ~= "" and itemName ~= "�����ݲ�֧��"
end

-- �������б����Ƿ�����Ч��Ʒ
function HasValidFilterItems()
	for i = 1, table.getn(Config.PickFilterList) do
		if IsValidFilterItem(Config.PickFilterList[i]) then
			return true
		end
	end
	return false
end

-- ���������Ʒ�б������ļ�
function SaveFilterItemsToConfig(configFile)
	for i = 1, Config.PickFilterMaxItems do
		local itemName = ""
		if i <= table.getn(Config.PickFilterList) then
			itemName = Config.PickFilterList[i]
		end
		Util.WriteConfigString(itemName, "pickFilterItem" .. i, "pick", configFile)
	end
end

-- �����������
function OnPickScriptLoad(configFile)
	local needSavePickDefaults = false
	
	Config.PickType = Util.ReadConfigInteger("onlyPickType", "pick", configFile)
	if Config.PickType == nil or Config.PickType < 0 or Config.PickType > 3 then 
		Config.PickType = 0  -- Ĭ�ϣ�ʰȡȫ����Ʒ
		needSavePickDefaults = true
	end
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	
	Config.PickTime = Util.ReadConfigInteger("InPickTime", "pick", configFile)
	if Config.PickTime == nil or Config.PickTime < MIN_PICK_TIME or Config.PickTime > MAX_PICK_TIME then 
		Config.PickTime = 500
		needSavePickDefaults = true
	end
	Form.SetEditValueInt("InPickTime", Config.PickTime)
	
	-- ���ع�������
	Config.PickFilterMode = Util.ReadConfigInteger("pickFilterMode", "pick", configFile)
	if Config.PickFilterMode == nil or Config.PickFilterMode < 0 or Config.PickFilterMode > 2 then
		Config.PickFilterMode = 0  -- Ĭ�ϲ�����ģʽ
		needSavePickDefaults = true
	end
	Form.SetCheckGroupActiveIndex("chkPickFilterMode", Config.PickFilterMode)
	
	-- ���ع�����Ʒ�б�
	Config.PickFilterList = {}
	local hasAnyItems = false
	for i = 1, Config.PickFilterMaxItems do
		local itemName = Util.ReadConfigString("pickFilterItem" .. i, "pick", configFile)
		if IsValidFilterItem(itemName) then
			table.insert(Config.PickFilterList, itemName)
			hasAnyItems = true
		end
	end
	
	-- ���û���κ���Ч��Ʒ�����Ĭ����ʾ
	if not hasAnyItems then
		for i = 1, Config.PickFilterMaxItems do
			table.insert(Config.PickFilterList, "�����ݲ�֧��")
		end
		needSavePickDefaults = true
	end
	RefreshPickFilterDisplay()
	
	-- ǿ��ˢ��UI����
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	Form.SetCheckGroupActiveIndex("chkPickFilterMode", Config.PickFilterMode)
	Form.SetEditValueInt("InPickTime", Config.PickTime)
	
	-- �����Ҫ����Ĭ��ֵ��������д�������ļ�
	if needSavePickDefaults then
		Util.WriteConfigInteger(Config.PickType, "onlyPickType", "pick", configFile)
		Util.WriteConfigInteger(Config.PickTime, "InPickTime", "pick", configFile)
		Util.WriteConfigInteger(Config.PickFilterMode, "pickFilterMode", "pick", configFile)
		
		-- ����Ĭ����Ʒ�б�
		SaveFilterItemsToConfig(configFile)

	end

end

-- �洢��������
function OnPickScriptSave(configFile)
    local PickTypeIndex = Form.GetCheckGroupActiveIndex("chkOnlyPickType")  -- ��ȡ��ѡ��������
    Util.WriteConfigInteger(PickTypeIndex, "onlyPickType", "pick", configFile)  -- д��ʰȡ����
    
    local PickTimeNum = Form.GetEditValueInt("InPickTime")  -- ��ȡ�༭���ȡ�ӳ�ʱ��
    Util.WriteConfigInteger(PickTimeNum, "InPickTime", "pick", configFile)  -- д���ӳ�ʱ��
    
    -- �����������
    local PickFilterModeIndex = Form.GetCheckGroupActiveIndex("chkPickFilterMode")
    Util.WriteConfigInteger(PickFilterModeIndex, "pickFilterMode", "pick", configFile)
    
    -- ���������Ʒ�б�
    SaveFilterItemsToConfig(configFile)
end

-- ִ��ʰȡ�ű�
function DoPick(nDeep)
    -- ��ȼ�飬��ֹ���޵ݹ�
    if nDeep > 3 then
        return 0
    end
    
    local PickTypeIndex = Form.GetCheckGroupActiveIndex("chkOnlyPickType")   -- ��ȡ��ѡ��������
    
    -- ��֤ʰȡ����
    if PickTypeIndex < 0 or PickTypeIndex > 3 then
        Game.SysInfo("ʰȡ���ʹ���: " .. PickTypeIndex)
        return 0
    end   
    
    local filterMode = Form.GetCheckGroupActiveIndex("chkPickFilterMode")
    
    -- ������ģʽ
    if filterMode == 0 then
        -- ������ģʽ������ʰȡ
        DoStandardPick(PickTypeIndex)
    else
        -- ֻ�е�������Ч��Ʒʱ����ʾ��ʾ
        if HasValidFilterItems() then
            local currentTime = os.clock() * 1000  -- ת��Ϊ����
            
            -- ����Ƿ��ѹ����ʱ��
            if currentTime >= lastFilterTipTime + FILTER_TIP_INTERVAL then
                if filterMode == 1 then
                    Game.SysInfo("������ģʽ�����˹����ݲ�֧�֣���ʹ�ò�����ģʽ")
                    lastFilterTipTime = currentTime
                elseif filterMode == 2 then
                    Game.SysInfo("������ģʽ�����˹����ݲ�֧�֣���ʹ�ò�����ģʽ")
                    lastFilterTipTime = currentTime
                end
            end
        end
        
        -- ��Ȼִ�б�׼ʰȡ
        DoStandardPick(PickTypeIndex)
    end
    
    return 0
end

function DoStandardPick(PickTypeIndex)
    if PickTypeIndex == 0 then
        Game.PickAllItem(0, Config.PickTime)  -- ʰȡȫ����Ʒ
    elseif PickTypeIndex == 1 then
        Game.PickAllItem(1, Config.PickTime)  -- ʰȡ�����ڵ���
    elseif PickTypeIndex == 2 then
        Game.PickAllItem(2, Config.PickTime)  -- ʰȡװ������
    elseif PickTypeIndex == 3 then
        Game.PickAllItem(3, Config.PickTime)  -- ʰȡ��������
    end
end
