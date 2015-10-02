local InventoryLinks = {};
local InventoryClass = {};
local InventoryMt = {};

return function(Interface)
    local ret = newproxy(true);
    local mt = getmetatable(ret);
    InventoryLinks[ret] = {

    };
    for k,v in next, InventoryMt do
        mt[k] = v;
    end;
    return ret;
end;