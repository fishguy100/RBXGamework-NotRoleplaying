local SkillsLinks = setmetatable({},{__mode='k'});
local SkillsClass = {};
local SkillsMt = {
  __index = function(t,k)
    return SkillsClass[k] or SkillsLinks[t][k];
  end;
  __tostring = function(t)
    return string.format([[
* Inventory
|
]])
};

return function(Interface)
  local Skills = newproxy(true);
  local mt = getmetatable(Skill);
  for k,v in next, SkillsMt do
    mt[k] = v;
  end;
  SkillsLinks[Skills] = {
    Interface = Interface;
  };
  return Skills;
end;