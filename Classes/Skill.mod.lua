local SkillLinks = setmetatable({},{__mode='k'});
local SkillClass = {};
local SkillMt = {
  __index = function(t,k)
    return SkillClass[k] or SkillsLinks[t][k];
  end;
  __tostring = function(t)
    local this = SkillLinks[t];
    return string.format([[
* Skill: %s
|
    ]], this.Name);
  end;
  __metatable = "Skill Class"
};

return function(Name,Tree)
  local Skill = newproxy(true);
  local mt = getmetatable(Skill);
  SkillLinks[Skill] = {

  };
  for k,v in next, SkillMt do
    mt[k] = v;
  end;
  return Skill;
end;