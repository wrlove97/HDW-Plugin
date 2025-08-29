----�޸ĵ���.by:����Ryan -20250824
-- ��С�����ʰȡ�ӳ�
local MIN_PICK_TIME = 100
local MAX_PICK_TIME = 5000

-- �����������
function OnPickScriptLoad(configFile)
	local needSavePickDefaults = false
	
	Config.PickType = Util.ReadConfigInteger("onlyPickType", "pick", configFile)
	if Config.PickType == nil or Config.PickType < 0 or Config.PickType > 1 then 
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
	
	-- ǿ��ˢ��UI����
	Form.SetCheckGroupActiveIndex("chkOnlyPickType", Config.PickType)
	Form.SetEditValueInt("InPickTime", Config.PickTime)
	
	-- �����Ҫ����Ĭ��ֵ��������д�������ļ�
	if needSavePickDefaults then
		Util.WriteConfigInteger(Config.PickType, "onlyPickType", "pick", configFile)
		Util.WriteConfigInteger(Config.PickTime, "InPickTime", "pick", configFile)
	end
end

-- �洢��������
function OnPickScriptSave(configFile)
	-- ����ʰȡ����
	Config.PickType = Form.GetCheckGroupActiveIndex("chkOnlyPickType")
	Util.WriteConfigInteger(Config.PickType, "onlyPickType", "pick", configFile)
	
	-- ����ʰȡ�ӳ�
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

-- ִ��ʰȡ�ű�
function DoPick(nDeep)
	-- ��ȼ��
	if nDeep > 5 then 
		return 0 
	end
	
	-- ��ȡ��ǰʰȡ����
	local pickType = Form.GetCheckGroupActiveIndex("chkOnlyPickType")
	
	-- ��������ִ��ʰȡ
	if pickType == 0 then
		-- ʰȡȫ����Ʒ
		Game.PickAllItem(0, Config.PickTime)
	elseif pickType == 1 then
		-- ֻʰȡ�����ڵ���
		Game.PickAllItem(1, Config.PickTime)
	end
	
	return 0
end
