-- Load it up
eRPG = require(script.Parent.Main);
-- Add it
_G.eRPG = eRPG;

-- Idly wait for Valkyrie.
local n = 0;
repeat
    n = n + wait();
until n > 30 or _G.Valkyrie;
if _G.Valkyrie then
    -- Add integration for Valkyrie.
    
    -- Inform listeners that Valkyrie is ready.
    eRPG.ValkyrieReady:Fire(true);
else
    -- Tell listeners that Valkyrie support is not coming.
    eRPG.ValkyrieReady:Fire(false);
end;