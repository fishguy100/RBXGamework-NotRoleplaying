local StatsLinks = {};
local StatsClass = {};
local StatsMt = {};

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
    Interface = Interface;
  }
end;
