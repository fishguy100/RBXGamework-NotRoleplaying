local this = {};
local extract;
local pack = function(...) return {n=select('#',...),...} end;

do
    -- CreateNew
    local crn = newproxy(true);
    local cache = {};
    local mt = getmetatable(crn);
    mt.__index = function(t,k)
        return cache[k];
    end;
    mt.__call = function(t,ty)
        return cache[ty]
    end;
    mt.__metatable = "Locked metatable: eRPG"
    mt.__tostring = function() return "eRPG.CreateNew" end;
    mt.__newindex = function() error "Please don't" end;
    for i,v in ipairs(script.Parent.Classes:GetChildren()) do
        cache[v.Name] = require(v);
    end;
    this.CreateNew = crn;
end;

do
    local pev = newproxy(true);
    local mt = getmetatable(pev);
    local ev = Instance.new "BindableEvent";
    this.ValkyrieReady = pev;
    mt.__tostring = function() return "eRPG.ValkyrieReady" end;
    mt.__metatable = function() return "Locked metatable" end;
    mt.__index = function(t,k)
        if k == 'connect' then
            return function(_,f)
                return ev.Event:connect(f);
            end;
        elseif k == 'wait' then
            return function()
                return ev.Event:wait();
            end;
        elseif k == 'Fire' then
            return function(_,...)
                return ev.Fire(ev,...);
            end;
        end;
    end;
end;

local r = newproxy(true);
local mt = getmetatable(r);
mt.__index = this;
mt.__tostring = function() return "RPG Enginework." end;
mt.__newindex = function() error "Please don't" end;
mt.__metatable = "Locked metatable: eRPG";

extract = function(...)
    if (...) == r then
        return select(2,...);
    else
        return ...;
    end;
end;

return r;