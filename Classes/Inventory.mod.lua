local InventoryLinks = setmetatable({},{__mode = 'kv'});
local InventoryClass = {};
local InventoryMt = {
  __index = function(t,k)
    return InventoryClass[k] or InventoryLinks[t][k];
  end;
  __metatable = "Inventory class";
  __tostring = function(t)
    local this = InventoryLinks[t];
    return string.format([[
    * Inventory
    | Weight = %.1f/%d
    | OverEncumbered = %s
    ]], this.Weight, this.MaxWeight, tostring(this.Weight > this.MaxWeight));
  end;
};

local ValidEquipPoints = {
  Weapon = true;
  WeaponL = true;
  WeaponR = true;
  WeaponD = true;
  Ring = true;
  Ring1 = true;
  Ring2 = true;
  Ring3 = true;
  Body = true;
  Feet = true;
  Legs = true;
  Head = true;
  Necklace = true;
};

local EquipAliasPoints = {
  Helmet = "Head";
  Greaves =  "Legs";
  Trousers = "Legs";
  Chestplate = "Body";
  Shoes = "Feet";
  Boots = "Feet";
  Bracelet = "Ring";
}

function InventoryClass:Update()
  local this = InventoryLinks[self];
  local Interface = this.Interface;
  local Stats = Interface.Stats;
  -- Disconnect all of the SpecialMods to start
  for k,v in next, this.Disconnections do
    v();
  end;

  -- Recalculate all the weights
  local inv,qty = this.Inventory, this.InventoryQuantity;
  local w = 0;
  for i=1,#inv do
    w = w + inv[i].Weight*qty[i];
  end;
  this.Weight = w;

  -- Bind all the special mods
  if Stats then
    for k,v in pairs(this.Equip) do
      local m = v.SpecialMods;
      if m then
        if m.Vitals then
          Stats:RegisterVitalsHook(m.Vitals);
        end;
        if m.Carry then
          Stats:RegisterCarryHook(m.Carry);
        end;
        if m.Damage then
          Stats:RegisterDamageHook(m.Damage);
        end;
      end;
    end;
  end;

  -- Recalculate the MaxWeight
  local mw = 100 + 10 * Interface.Level;
  if Stats then
    mw = mw*Stats.Mods.MaxCarryWeight;
    mw = Stats:SpecialModCarry(mw);
  end;
  if mw > this.Weight then
    this.OverEncumbered:Fire(true);
  else
    this.OverEncumbered:Fire(false);
  end;
  this.MaxWeight = mw;
end;

function InventoryClass:GiveItem(item, amount)
  amount = amount or 1
  local this = InventoryLinks[self];
  -- Quickly check if they have the item already
  local found;
  local inv = this.Inventory;
  for i=1,#inv do
    if inv[i] == item then
      found = i;
      break;
    end;
  end;
  if found then
    this.InventoryQuantity[found] = this.InventoryQuantity[found] + amount;
  else
    local n = #inv+1;
    inv[n] = item;
    this.InventoryQuantity[n] = amount;
  end;
  this.Weight = this.Weight + item.Weight*amount;
  if this.Weight > this.MaxWeight then
    this.OverEncumbered:Fire(true);
  end;
end;

function InventoryClass:RemoveItem(item, amount)
  amount = amount or 1;
  local this = InventoryLinks[self];
  local inv = this.Inventory;
  local q = this.InventoryQuantity;
  local rem = amount;
  if type(item) == 'number' then
    -- Choosing a specific entry
    local a = q[item];
    if not a then return 0 end;
    a = a - amount;
    if a =< 0 then
      rem = rem + a;
      local _i = item;
      item = inv[_i];
      inv[_i] = nil;
      q[_i] = nil;
      for i=item,#inv do
        inv[i-1] = inv[i];
        q[i-1] = q[i];
      end;
    else
      q[item] = a;
      item = inv[item];
    end;
  else
    -- Choosing an item
    local found;
    for i=1,#inv do
      if inv[i]==item then
        found = true;
        local a = q[i];
        a = a - amount;
        if a=< 0 then
          rem = rem+a;
          inv[i] = nil;
          q[i] = nil;
        else
          break
        end;
      elseif found then
        inv[i-1] = inv[i];
        q[i-1] = q[i];
      end;
    end;
    if not found then return 0;
  end;
  this.Weight = this.Weight - item.Weight*rem;
  return item, rem;
end;

function InventoryClass:Equip(item, special)
  local this = InventoryLinks[self];
  local success = false;
  item = self:RemoveItem(item);
  if not item then return error("Invalid item to equip!", 2) end;
  if item.Equippable then
    local eType = item.EquipClass;
    local equipPoint = this.Equip;
    eType = EquipAliasPoints[eType] or eType;
    -- Check special equippable types
    assert(ValidEquipPoints[eType], eType.." has no equip target!", 2);
    if eType == 'Ring' then
      -- Special case: Rings
      -- Check if we can overflow to another Ring
      local able;
      if not special then
        for i=1,3 do
          if equipPoint["Ring"..i] then
            able = i;
            break;
          end;
        end;
      end;
      if able or special then
        equipPoint["Ring"..(able or special)] = item;
      else
        -- Cycle the rings
        local r1 = equipPoint.Ring1;
        local r2 = equipPoint.Ring2;
        local r3 = equipPoint.Ring3
        equipPoint.Ring2 = r1;
        equipPoint.Ring3 = r2;
        equipPoint.Ring1 = item;
        self:AddItem(r3);
      end;
    elseif eType == 'Weapon' then
      -- Special case: Single-handed weapon
      -- Check if there is a two-handed equipped
      if equipPoint.WeaponD then
        -- Dualies on.
        self:AddItem(self:Dequip("WeaponD")); -- Dualies off.
      end;
      if special == "L" then
        -- Manual equip to L
        local i = equipPoint.WeaponL;
        equipPoint.WeaponL = item;
        if i then
          self:AddItem(i);
        end;
      elseif special == "R" then
        -- Manual equip to R
        local i = equipPoint.WeaponR;
        equipPoint.WeaponR = item;
        if i then
          self:AddItem(i);
        end;
      else
        -- Check which hands are taken
        if not equipPoint.WeaponL then
          -- Left hand is clear
          equipPoint.WeaponL = item;
        elseif not equipPoint.WeaponR then
          -- Right hand is clear
          equipPoint.WeaponR = item;
        else
          -- Both hands are taken; cycle them.
          local l,r = equipPoint.WeaponL, equipPoint.WeaponR;
          equipPoint.WeaponL = item;
          equipPoint.WeaponR = l;
          self:AddItem(r);
        end;
      end;
    elseif eType == 'WeaponD' then
      -- Special case: Two-handed weapon
      -- Quickly try and dequip L,R if applicable
      local l,r = equipPoint.WeaponL, equipPoint.WeaponR;
      equipPoint.WeaponL = nil;
      equipPoint.WeaponR = nil;
      if l then self:AddItem(l) end;
      if r then self:AddItem(r) end;
      -- Quickly try to dequip an active two-hand if applicable
      local d = equipPoint.WeaponD;
      equipPoint.WeaponD = item;
      if d then self:AddItem(d) end;
    else
      -- Any other standard equip
      local i = equipPoint[eType];
      equipPoint[eType] = item;
      if i then self:AddItem(i) end;
    end;
    self:Update();
    success = true;
  else
    self:AddItem(item);
  end;
  -- It's okay we're fine guys.
  return success;
end;

function InventoryClass:Dequip(slot)
  assert(slot, "You need to supply a slot to dequip", 2);
  local this = InventoryLinks[self];
  local item;
  if ValidEquipPoints[slot] then
    -- We're actually given a slot oh isn't that so fun?
    item = Equip[slot];
    Equip[slot] = nil;
  else
    return error(slot.." is not a valid equip point", 2);
  end;
  self:Update();
  return item;
end;

return function(Interface)
  assert(Interface, "Something is wrong: No Interface supplied for Inventory", 2);
  local ret = newproxy(true);
  local mt = getmetatable(ret);
  InventoryLinks[ret] = {
    Inventory = {};
    Equip = {};
    InventoryQuantity = {};
    Weight = 0;
    MaxWeight = 100;
    Interface = Interface
    Disconnections = {};
    OverEncumbered = Instance.new "BindableEvent";
  };
  for k,v in next, InventoryMt do
    mt[k] = v;
  end;
  return ret;
end;
