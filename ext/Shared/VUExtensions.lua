class "VUExtensions"


function VUExtensions:PrepareInstanceForEdit(p_Partition, p_Instance)
	if p_Partition == nil then
		print('[ERROR] Parameter p_Partition was nil. Instance type: ' .. p_Instance.typeInfo.name)
		return
	end

	if p_Instance == nil then
		print('[ERROR] Parameter p_Instance was nil.')
		return
	end

	if p_Instance.isReadOnly == nil then
		-- If .isReadOnly is nil it means that its not a DataContainer, it's a Structure. We return it casted
		print('[WARNING] The instance '..p_Instance.typeInfo.name.." is not a DataContainer, it's a Structure")
		return _G[p_Instance.typeInfo.name](p_Instance)
	end

	if not p_Instance.isReadOnly then
		return _G[p_Instance.typeInfo.name](p_Instance)
	end

	if p_Instance.isLazyLoading then
		print('[ERROR] The instance is being lazy loaded, thus it cant be prepared for editing. Instance type: "' .. p_Instance.typeInfo.name)-- maybe add callstack
		return _G[p_Instance.typeInfo.name](p_Instance)
	end

	if p_Instance.instanceGuid == nil then
		print('[ERROR]  .instanceGuid is nil. Instance type: ' .. p_Instance.typeInfo.name)

		return nil
	end

	local s_Clone = p_Instance:Clone(p_Instance.instanceGuid)

	p_Partition:ReplaceInstance(p_Instance, s_Clone, true)

	local s_CastedClone = _G[s_Clone.typeInfo.name](s_Clone)

	if s_CastedClone ~= nil and s_CastedClone.typeInfo.name ~= s_Clone.typeInfo.name then
		print('[ERROR] PrepareInstanceForEdit() - Failed to prepare instance of type ' .. s_Clone.typeInfo.name)
		return nil
	end

	-- NOTE: if something is crashing this print can be useful to track it. Check if the latest output is this print and what instance it is
	-- print('Cloned instance '..p_Instance.typeInfo.name..", instance guid: "..tostring(p_Instance.instanceGuid))
	
	return s_CastedClone
end

function VUExtensions:MakeWritable(p_Instance)
	if p_Instance == nil then
		print('[ERROR] Parameter p_Instance was nil.')
		return
	end

	local s_Instance = _G[p_Instance.typeInfo.name](p_Instance)

	if p_Instance.isReadOnly == nil then
		-- If .isReadOnly is nil it means that its not a DataContainer, it's a Structure. We return it casted
		print('[WARNING] The instance '..p_Instance.typeInfo.name.." is not a DataContainer, it's a Structure")
		return s_Instance
	end

	if not p_Instance.isReadOnly then
		return s_Instance
	end

	s_Instance:MakeWritable()

	return s_Instance
end

return VUExtensions()
