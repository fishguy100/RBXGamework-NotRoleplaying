local StatsLinks = setmetatable({},{__mode = 'k'});
local StatsClass = {};
local StatsMt = {
  __index = function(t,k)
    return StatsClass[k] or StatsLinks[t][k];
  end;
  __metatable = "Locked Metatable: eRPG";
  __tostring = function(t)
    local this = StatsLinks[t];
    local att = this.Attributes;
    local s = string.format([[
* Stats
| * Attributes
| | Strength = %d
| | Agility = %d
| | Luck = %d
| | Intelligence = %d
| | Charisma = %d
| | Dexterity = %d
| * Mods
]], att.str, att.agi, att.luk, att.int, att.cha, att.dex);
    for k,v in next, this.Mods do
      s = s.."\n| | "..k.." = "..v;
    end;
    return s;
  end;
  };

function StatsClass:SpecialModVitals(h,m,e)
  local registeredVitalMods = StatsLinks[self].SpecialModRegisters.Vitals;
  for i=1,#registeredVitalMods do
    h,m,e = registeredVitalMods[i](h,m,e);
  end;
  return h,m,e
end;

function StatsClass:SpecialModDamage(dmg,source)
  local registeredDamageMods = StatsLinks[self].SpecialModRegisters.Damage;
  for i=1,#registeredDamageMods do
    dmg = registeredDamageMods[i](dmg, source);
  end;
  return dmg
end;

function StatsClass:RegisterDamageHook(f)
  local reg = StatsLinks[self].SpecialModRegisters.Damage;
  reg[#reg+1] = f;
  local found;
  local disconnectionHandle = function()
    if found then return end;
    for i=1,#reg do
      if reg[i] == f then
        reg[i] = nil;
        found = true;
      elseif found then
        reg[i-1] = reg[i];
      end;
    end;
  end;
  return disconnectionHandle;
end;

function StatsClass:RegisterVitalsHook(f)
  local reg = StatsLinks[self].SpecialModRegisters.Vitals;
  reg[#reg+1] = f;
  local found;
  local disconnectionHandle = function()
    if found then return end;
    for i=1,#reg do
      if reg[i] == f then
        reg[i] = nil;
        found = true;
      elseif found then
        reg[i-1] = reg[i];
      end;
    end;
  end;
  return disconnectionHandle;
end;

function StatsClass:Update()
  local this = StatusLinks[self];
  local att = this.Attributes;
  do local _att = this.BaseAttributes;
    -- Set the Attributes back to their 'base' values.
    att.str = _att.str;
    att.agi = _att.agi;
    att.luk = _att.luk;
    att.int = _att.int;
    att.cha = _att.cha;
    att.dex = _att.dex;
  end;
  local mods = this.Mods;
  local _mods = this.BaseMods;
  for k,v in next, mods do
    mods[k] = 1;
  end;
  -- Get from external sources
  local Interface = this.Interface;
  do local Skills = Interface.Skills;
    if Skills then
      local modd = Skills:GetSpecialMods();
      for k,v in pairs(modd) do
        mods[k] = mods[k] + v;
      end;
    end;
  end;
  do local Inventory = Interface.Inventory;
    if Inventory then
      local attcapp = Inventory:GetAttributeMods();
      for k,v in pairs(attcapp) do
        att[k] = att[k] + v;
      end;
      local modd = Inventory:GetSpecialMods();
      for k,v in pairs(modd) do
        mods[k] = mods[k] + v;
      end;
    end
  end;
  -- Calculate new Mods
  local str, agi, luk, int, cha, dex = att.str, att.agi, att.luk, att.int, att.cha, att.dex
  mods.HealthCap = mods.HealthCap
  *(1+str*0.04+dex*0.03)
  *_mods.HealthCap;

  mods.ManaCap = mods.ManaCap
  *(1+--[[Attributes]])
  *_mods.ManaCap;

  mods.EnergyCap = mods.EnergyCap
  *(1+--[[Attributes]])
  *_mods.EnergyCap;

  mods.MeleeDefence = mods.MeleeDefence
  *(1+--[[Attributes]])
  *_mods.MeleeDefence;

  mods.RangedDefence = mods.RangedDefence
  *(1+--[[Attributes]])
  *_mods.RangedDefence;

  mods.PhysicalDefence = mods.PhysicalDefence
  *(1+--[[Attributes]])
  *_mods.PhysicalDefence;

  mods.MagicalDefence = mods.MagicalDefence
  *(1+--[[Attributes]])
  *_mods.MagicalDefence;

  mods.FireDefence = mods.FireDefence
  *(1+--[[Attributes]])
  *_mods.FireDefence;

  mods.IceDefence = mods.IceDefence
  *(1+--[[Attributes]])
  *_mods.IceDefence;

  mods.PoisonDefence = mods.PoisonDefence
  *(1+--[[Attributes]])
  *_mods.PoisonDefence;

  mods.MeleeAttack = mods.MeleeAttack
  *(1+--[[Attributes]])
  *_mods.MeleeAttack;

  mods.RangedAttack = mods.RangedAttack
  *(1+--[[Attributes]])
  *_mods.RangedAttack;

  mods.PhysicalAttack = mods.PhysicalAttack
  *(1+--[[Attributes]])
  *_mods.PhysicalAttack;

  mods.MagicalAttack = mods.MagicalAttack
  *(1+--[[Attributes]])
  *_mods.MagicalAttack;

  mods.FireAttack = mods.FireAttack
  *(1+--[[Attributes]])
  *_mods.FireAttack;

  mods.IceAttack = mods.IceAttack
  *(1+--[[Attributes]])
  *_mods.IceAttack;

  mods.PoisonAttack = mods.PoisonAttack
  *(1+--[[Attributes]])
  *_mods.PoisonAttack;
end;

function StatsClass:GiveAttribute(att,amt)
  -- X gon' give it to ya'
  -- X gon' deliv' it to ya'
  local BaseAttributes = StatusLinks[self].BaseAttributes;
  BaseAttributes[att] = BaseAttributes[att] + amt;
  self:Update();
end;

function StatsClass:SetAttribute(att,set)
  local BaseAttributes = StatusLinks[self].BaseAttributes;
  BaseAttributes[att] = set;
  self:Update();
end;

function StatsClass:ModifyBase(base,set)
  local this = StatsLinks[self];
  local m,b = this.Mods, this.BaseMods;
  assert(base and m[base], "There is no Mod for "..base, 2);
  local mv = m[base];
  mv = mv/b[base];
  b[base] = set;
  mv = mv*set;
  m[base] = mv;
  return m[base];
end;

return function(Interface)
  assert(Interface, "Something is wrong: No Interface for Stats", 2);
  local container = {
    Attributes = {
      str = 0;
      agi = 0;
      luk = 0;
      int = 0;
      cha = 0;
      dex = 0;
    };
    BaseAttributes = {
      str = 0;
      agi = 0;
      luk = 0;
      int = 0;
      cha = 0;
      dex = 0;
    };
    Mods = {
      HealthCap = 1;
      ManaCap = 1;
      EnergyCap = 1;
      MeleeDefence = 1;
      RangedDefence = 1;
      PhysicalDefence = 1;
      MagicalDefence = 1;
      FireDefence = 1;
      IceDefence = 1;
      PoisonDefence = 1;
      MeleeAttack = 1;
      RangedAttack = 1;
      PhysicalAttack = 1;
      MagicalAttack = 1;
      FireAttack = 1;
      IceAttack = 1;
      PoisonAttack = 1;
    };
    BaseMods = {
      HealthCap = 1;
      ManaCap = 1;
      EnergyCap = 1;
      MeleeDefence = 1;
      RangedDefence = 1;
      PhysicalDefence = 1;
      MagicalDefence = 1;
      FireDefence = 1;
      IceDefence = 1;
      PoisonDefence = 1;
      MeleeAttack = 1;
      RangedAttack = 1;
      PhysicalAttack = 1;
      MagicalAttack = 1;
      FireAttack = 1;
      IceAttack = 1;
      PoisonAttack = 1;
    };
    SpecialModRegisters = {
      Vitals = {

      };
      Damage = {

      };
    };
    Interface = Interface;
  };
  local newStats = newproxy(true);
  local mt = getmetatable(newStats);
  for k,v in next, StatsMt do
    mt[k] = v;
  end;
  StatsLinks[newStats] = container
  return newStats;
end;
