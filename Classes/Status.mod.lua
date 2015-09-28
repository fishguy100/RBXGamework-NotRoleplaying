local StatusTypes = {
  Fire = function(status, amp, fin)
    status.Vitals:TakeDamage {
      BaseDamage = status.Level^2*amp;
      Element = 'Fire';
    };
  end;
  Ice = function(status, amp, fin)
    status.Vitals:TakeDamage {
      BaseDamage = status.Level*amp*4;
      Element = 'Ice';
    };
    if status.Cache.SpDiff then
      if fin then
        local hum = status.Vitals.Interface.Humanoid;
        if hum then hum.WalkSpeed = hum.WalkSpeed*status.Cache.SpDiff end;
      end;
    else
      status.Cache.SpDiff = status.Level;
      local hum = status.Vitals.Interface.Humanoid;
      if hum then hum.WalkSpeed = hum.WalkSpeed/status.Level end;
    end;
  end;
  Frostbite = function(status, amp, fin)
    status.Vitals:TakeDamage {
      BaseDamage = status.Level^3*amp*0.4;
      Element = 'Ice';
    }
  end;
}

local StatusLinks = setmetatable({}, {__mode = 'k'});
local StatusClass = {};
local StatusMt = {
  __index = function(t,k)
    return StatusClass[k] or StatusLinks[t][k];
  end;
  __tostring = function(t)
    local l = StatusLinks[t];
    return strting.format([[
      * Status Effect
      | Type     : %s
      | Duration : %f
      | Level    : %d
    ]], l.Type, l.Duration, l.Level);
  end;
  __metatable = "Status Class"
};

function StatusClass:Destroy()
  StatusLinks[self].Key = nil;
end;

function StatusClass:Update(delta)
  local this = StatusLinks[self];
  local duration = this.Duration;
  local deadstatus = false;
  duration = duration - delta;
  if duration < 0 then
    delta = delta + duration;
    duration = 0;
    deadstatus = true;
    this.Key = nil;
  end;
  this.updateFunc(this, delta, deadstatus);
  return deadstatus;
end;

function StatusClass:Dump()
  return StatusLinks[self];
end;

return function(Vitals, Type, Duration, Level)
  local status = newproxy(true);
  local mt = getmetatable(status);
  for k,v in next, StatusMt do
    mt[k] = v;
  end;
  StatusLinks[status] = {
    Type = Type;
    Duration = Duration;
    Level = Level;
    Vitals = Vitals;
    Cache = setmetatable({},{__mode = 'k'});
    Key = newproxy(false);
    updateFunc = StatusTypes[Type];
  };
  return status;
end;
