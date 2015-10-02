local InventoryLinks = {};
local InventoryClass = {};
local InventoryMt = {};

return function(Interface)
  assert(Interface, "Something is wrong: No Interface supplied for Inventory", 2);
  local ret = newproxy(true);
  local mt = getmetatable(ret);
  InventoryLinks[ret] = {
    Inventory = {};
    Equip = {};
    InventoryQuantity = {};
    Interface = Interface
  };
  for k,v in next, InventoryMt do
    mt[k] = v;
  end;
  return ret;
end;