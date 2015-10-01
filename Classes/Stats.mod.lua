local StatsLinks = {};
local StatsClass = {};
local StatsMt = {};

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
  -- Get from external sources

  -- Calculate new Mods
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
    }
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
  }
end;
