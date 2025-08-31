----�޸ĵ���.by:����Ryan -20250831
-- ��С�����ʰȡ�ӳ�
local MIN_PICK_TIME = 100
local MAX_PICK_TIME = 5000

-- �����Ʒ�����Ƿ�Ϊ��Ч������
function IsValidFilterItem(filterItemName)
	return filterItemName ~= nil and filterItemName ~= ""
end

-- ��չ�����Ʒ�б�
function ClearPickFilterList()
	-- ������������
	for i = 1, Config.PickFilterMaxItems do
		Form.SetEditValue("pickFilterList" .. i, "")
	end
	Config.PickFilterList = {}
	Game.SysInfo("����չ����б���Ʒ��")
end

-- ɾ��ָ�������Ĺ�����Ʒ
function RemovePickFilterItem(index)
	if index < 1 or index > Config.PickFilterMaxItems then
		return
	end
	
	local filterItemName = Form.GetEditValue("pickFilterList" .. index)
	if filterItemName ~= "" then
		Form.SetEditValue("pickFilterList" .. index, "")  -- ��������
		RefreshPickFilterDisplay()  -- ����Config
		Game.SysInfo("��ɾ�������б���Ʒ: " .. filterItemName)
	end
end

-- ˢ�¹�����Ʒ��ʾ
function RefreshPickFilterDisplay()
	-- ��UI��ȡ��Ʒ�б�����Config
	Config.PickFilterList = {}
	for i = 1, Config.PickFilterMaxItems do
		local filterItemName = Form.GetEditValue("pickFilterList" .. i)
		if IsValidFilterItem(filterItemName) then
			table.insert(Config.PickFilterList, filterItemName)
		end
	end
end

-- ���������Ʒ�б������ļ�
function SaveFilterItemsToConfig(configFile)
	for i = 1, Config.PickFilterMaxItems do
		local filterItemName = Form.GetEditValue("pickFilterList" .. i)
		if not IsValidFilterItem(filterItemName) then
			filterItemName = ""
		end
		Util.WriteConfigString(filterItemName, "pickFilterItem" .. i, "pick", configFile)
	end
end

-- �����������
function OnPickScriptLoad(configFile)
	-- ��ȡʰȡ��������
	Config.PickType = Util.ReadConfigInteger("onlyPickType", "pick", configFile)
	if Config.PickType == nil or Config.PickType < 0 or Config.PickType > 4 then 
		Config.PickType = 0  -- Ĭ�ϣ�ʰȡȫ����Ʒ
	end
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	
	-- ��ȡʰȡ�ӳ�����
	Config.PickTime = Util.ReadConfigInteger("InPickTime", "pick", configFile)
	if Config.PickTime == nil or Config.PickTime < MIN_PICK_TIME or Config.PickTime > MAX_PICK_TIME then 
		Config.PickTime = 500
	end
	Form.SetEditValueInt("InPickTime", Config.PickTime)
	
	-- ���ع�����Ʒ�б�UI
	for i = 1, Config.PickFilterMaxItems do
		local filterItemName = Util.ReadConfigString("pickFilterItem" .. i, "pick", configFile)
		if IsValidFilterItem(filterItemName) then
			Form.SetEditValue("pickFilterList" .. i, filterItemName)
		else
			Form.SetEditValue("pickFilterList" .. i, "")
		end
	end
	RefreshPickFilterDisplay()
	
	-- ǿ��ˢ��UI����
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	Form.SetEditValueInt("InPickTime", Config.PickTime)
end

-- �洢��������
function OnPickScriptSave(configFile)
    local PickTypeIndex = Form.GetCheckGroupActiveIndex("chkOnlyPickType")  -- ��ȡ��ѡ��������
    Util.WriteConfigInteger(PickTypeIndex, "onlyPickType", "pick", configFile)  -- д��ʰȡ����
    
    local PickTimeNum = Form.GetEditValueInt("InPickTime")  -- ��ȡ�༭���ȡ�ӳ�ʱ��
    Util.WriteConfigInteger(PickTimeNum, "InPickTime", "pick", configFile)  -- д���ӳ�ʱ��
    
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
    if PickTypeIndex < 0 or PickTypeIndex > 4 then
        Game.SysInfo("ʰȡ���ʹ���: " .. PickTypeIndex)
        return 0
    end   
    
    -- ִ�б�׼ʰȡ
    DoStandardPick(PickTypeIndex)
    
    return 0
end

-- ִ��ֻʰȡָ����Ʒ
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
        Game.PickAllItem(0, Config.PickTime)  -- ʰȡȫ����Ʒ
    elseif PickTypeIndex == 1 then
        Game.PickAllItem(1, Config.PickTime)  -- ʰȡ�����ڵ���
    elseif PickTypeIndex == 2 then
        Game.PickAllItem(2, Config.PickTime)  -- ʰȡװ������
    elseif PickTypeIndex == 3 then
        Game.PickAllItem(3, Config.PickTime)  -- ʰȡ��������
    elseif PickTypeIndex == 4 then
        PickSpecificItems()  -- ִ��ֻʰȡָ����Ʒ
    end
end
