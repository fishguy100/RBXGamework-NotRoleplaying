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
  -- Disconnect all of the SpecialMods to start
  for k,v in next, this.Disconnections do
    v();
  end;
  -- Recalculate the MaxWeight

  -- Recalculate all the weights

  -- Bind all the special mods

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
  self.Weight = self.Weight - item.Weight*rem;
  return item, rem;
end;

function InventoryClass:Equip(item)
  local this = InventoryLinks[self];
  local success = false;
  if type(item) == 'number' then
    -- Fetch it from the Inventory
  end;
  -- It's okay we're fine guys.
  return success;
end;

function InventoryClass:Dequip(slot)
  assert(slot, "You need to supply a slot to dequip", 2);
  local this = InventoryLinks[self];
  if ValidEquipPoints[slot] then
    -- We're actually given a slot oh isn't that so fun?
    
  else
    return error(slot.." is not a valid equip point", 2);
  end;
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
