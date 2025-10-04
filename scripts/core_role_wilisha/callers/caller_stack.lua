---@diagnostic disable: lowercase-global, undefined-global, trailing-space

local modid = 'role_wilisha'

local data = _require('core_'..modid..'/data/stacks')

API.STACK:main(data)