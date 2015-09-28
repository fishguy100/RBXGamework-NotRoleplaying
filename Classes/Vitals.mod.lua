local VitalsLinks = setmetatable({},{__mode = 'k'});
local VitalsClass = {};
local VitalsMt = {
  __index = function(t,k)
    return VitalsClass[k] or VitalsLinks[t][k];
  end;
  __tostring = function(t)
    local l = VitalsLinks[t];
    return string.format([[
      * Vitals (%s)
      | Health : %d/%d
      | Mana   : %d/%d
      | Energy : %d/%d
      | Armour : %d
    ]],tostring(l.Interface),l.Health,l.MaxHealth,l.Mana,l.MaxMana,l.Energy,l.MaxEnergy,l.Armour)
  end;
  __metatable = "Vitals Class";
};

function VitalsClass:Dump()
  return VitalsLinks[self];
end;

function VitalsClass:Recalculate()
  local this = VitalsLinks[self];
  local Interface = this.Interface;
  -- Quickly calculate limits based on the Interface Level
  this.MaxHealth = 100 + Interface.Level^1.4*10;
  this.MaxMana = 80 + (Interface.Level/2)^2*4;
  this.MaxEnergy = 100 + Interface.Level*8
  do if this.Interface.Stats then
    local stats = this.Interface.Stats; -- Let Stats mod
    local h,m,e = this.MaxHealth, this.MaxMana, this.MaxEnergy;
    -- Check the basic mods
    h = h*stats.Mods.HealthCap;
    m = m*stats.Mods.ManaCap;
    e = e*stats.Mods.EnergyCap;
    -- Check special mods and apply
    this.MaxHealth,this.MaxMana,this.MaxEnergy = stats:SpecialModVitals(h, m, e)
  end end;
  do if this.Interface.Inventory then
    local equip = this.Interface.Inventory.Equip -- Quickly grab equip Armour rating
    local armour = this.Armour;
    for k,v in next, equip do
      armour = armour + (v.ArmourRating or 0);
    end;
    this.Armour = armour;
  end end;
  -- Catch if the limits are passed
  this.Health = math.min(this.Health, this.MaxHealth);
  this.Mana = math.min(this.Mana, this.MaxMana);
  this.Energy = math.min(this.Energy, this.MaxEnergy);
end;

function VitalsClass:TakeDamage(source) --> Calculated Damage
  local this = VitalsLinks[self];
  local dmg = source.BaseDamage;
  do -- Let stats nerf
    local stats = this.Interface.Stats;
    if stats then
      stats = stats.Mods;
      -- Check the right modifiers
      if source.Melee then
        dmg = dmg*stats.MeleeDefence;
      elseif source.Ranged then
        dmg = dmg*stats.RangedDefence;
      end;
      if source.Physical then
        dmg = dmg*stats.PhysicalDefence;
      elseif source.Magical then
        dmg = dmg*stats.MagicalDefence;
      end;
      if source.Element then
        dmg = dmg*stats[Element.."Defence"];
      end;
      -- Check special mods
      dmg = stats:SpecialModDamage(dmg,source)
    end
  end;
  -- Mod for armour rating
  -- Each bit of armour takes 5 damage max, and reduces the damage a bit.
  dmg = dmg - math.min(this.Armour * 5, dmg*0.02*this.Armour^1.2)
  if dmg < 1 then dmg = 1 end;
  local hp = this.Health - dmg;
  if hp > this.MaxHealth then
    hp = this.MaxHealth;
  elseif hp <= 0 then
    hp = 0;
    this.Health = hp;
    this.Interface.Died:Fire();
  end;
  this.Health = hp;
  return dmg;
end;

function VitalsClass:Heal(amt)
  local this = VitalsLinks[self];
  local hp = this.Health + amt;
  if hp > this.MaxHealth then
    hp = this.MaxHealth;
  elseif hp <= 0 then
    hp = 0;
    this.Health = hp;
    this.Events.Died:Fire();
  end;
  this.Health = hp;
end;

function VitalsClass:UseMana(amt)
  local this = VitalsLinks[self];
  local mana = this.Mana - amt;
  if mana < 0 then
    mana = 0;
  end;
  this.Mana = mana;
end;

function VitalsClass:RestoreMana(amt)
  local this = VitalsLinks[self];
  local mana = this.Mana + amt;
  if mana > this.MaxMana then
    mana = this.MaxMana;
  end;
  this.Mana = mana;
end;

function VitalsClass:UseEnergy(amt)
  local this = VitalsLinks[self];
  local energy = this.Energy - amt;
  if energy < 0 then
    energy = 0;
  end;
  this.Energy = energy;
end;

function VitalsClass:RestoreEnergy(amt)
  local this = VitalsLinks[self];
  local energy = this.Energy + amt;
  if energy > this.MaxEnergy then
    energy = this.MaxEnergy;
  end;
  this.Energy = energy;
end;

do -- Needs to know where to get the Status constructor from
  local newStatus = require(script.Parent.Status);
  function VitalsClass:GiveStatus(type, duration, level)
    local Status = newStatus(self, type or "Fire", duration or 1, level or 1);
    VitalsLinks[self].Status[Status.Key] = Status;
  end;
end

function VitalsClass:Update(delta)
  local status = VitalsLinks[self].Status;
  for k,v in next, status do
    if v:Update(delta) then
      status[k] = nil;
    end;
  end;
end;

return function(Interface)
  assert(Interface, "Something is wrong; No Interface for Vitals", 2);
  local container = {
    Interface = Interface;
    Health = 100;
    MaxHealth = 100;
    Mana = 100;
    MaxMana = 100;
    Energy = 100;
    MaxEnergy = 100;
    Armour = 1;
    Status = setmetatable({},{__mode = 'k'});
    Died = Instance.new("BindableEvent");
    HealthChanged = Instance.new("BindableEvent");
    ManaChanged = Instance.new("BindableEvent");
    EnergyChanged = Instance.new("BindableEvent");
    StatusAdded = Instance.new("BindableEvent");
  };
  local Vitals = newproxy(true);
  local mt = getmetatable(Vitals);
  for k,v in next, VitalsMt do
    mt[k] = v;
  end;
  VitalsLinks[Vitals] = container;
  return Vitals;
end;
