Vitals base class
===
*The Vitals class handles all of the regenerative fundamental values. This means
health, mana and stamina. Also handles the status effects*

Properties
---
- *number* **Health**
- *number* **MaxHealth**
- *number* **Mana**
- *number* **MaxMana**
- *number* **Energy**
- *number* **MaxEnergy**
- *number* **Armour**

Methods
---
**TakeDamage**
```
Vitals:TakeDamage(
  table source {
    number BaseDamage = 1;
    bool ?Melee || Ranged;
    bool ?Physical || Magical;
    string ?Element;
  }
) -> number ModifiedDamage
```
Causes the target `Vitals` class to take damage, modified by the types defined
in `source` according to the `Vitals` class' `Interface`. Fires the `Died` event
if it happens to kill the `Vitals`

**Recalculate**
```
Vitals:Recalculate() -> nil
```
Checks against the target `Vitals` class' `Interface` to quickly recalculate all
mods such as upper limits for the properties, and clamp them.

**Dump**
```
Vitals:Dump() -> table this
```
Returns the internal container for the target `Vitals`

**Heal**
```
Vitals:Heal(
  number Amount
) -> nil
```
Adds `Amount` to the `Vitals` class' `Health`, clamping it against the
`MaxHealth` and 0, firing the `Died` event if it kills the `Vitals`

**UseMana**
```
Vitals:UseMana(
  number Amount
) -> nil
```
Removes `Amount` from the `Vitals` class' `Mana`, clamping it against 0

**RestoreMana**
```
Vitals:RestoreMana(
  number Amount
) -> nil
```
Similar to `UseMana`, except this one adds and clamps against `MaxMana`

**UseEnergy**
```
Vitals:UseEnergy(
  number Amount
) -> nil
```
Similar to `UseMana`, but removing from `Energy` instead.

**RestoreEnergy**
```
Vitals:RestoreEnergy(
  number Amount
) -> nil
```
Similar to `RestoreMana`, but to `Energy` and clamping against `MaxEnergy`

**GiveStatus**
```
Vitals:GiveStatus(
  string Type = "Fire",
  number Level = 1,
  number Duration = 1
) -> Status NewStatus
```
Adds a `Status` to the `Vitals` class with the specified Attributes

**Update**
```
Vitals:Update(
  number Delta
) -> nil
```
Updates all of the `Vitals` class' status effects, reducing the remaining time
on each `Status` by `Delta`, amplifying the effects accordingly.

Events
---
**Died**
```
Vitals.Died -> nil
```
Fires when the `Vitals` class hits 0 health

**HealthChanged**
```
Vitals.HealthChanged -> number NewHealth
```
Fires when the `Health` is changed, through a method

**ManaChanged**
```
Vitals.ManaChanged -> number NewMana
```
Fires when the `Mana` is changed, through a method

**EnergyChanged**
```
Vitals.EnergyChanged -> number NewEnergy
```
Fires when the `Energy` is changed, through a method

**StatusAdded**
```
Vitals.StatusAdded -> Status NewStatus
```
Fires when a new `Status` is added through the `GiveStatus` method
