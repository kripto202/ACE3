/*
 * Author: Dslyecxi, Jonpas
 * Throw grenade.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit] call ace_grenadethrowing_fnc_throw
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

// Make it real at the end
_unit playAction "ThrowGrenade";

// If CTRL is held, we don't delay, otherwise we wait for the playAction to complete, which is roughly 0.3 seconds
private _waitTime = [0.3, 0] select GVAR(CtrlHeld);

[{
    params ["_unit"];

    // If the grenade's not already cooked, create the "real" one
    if (!GVAR(CookingGrenade)) then {
        [_unit, GVAR(ActiveGrenadeItem), GVAR(ActiveGrenadeType)] call FUNC(cook);
    };

    _unit removeItem ((currentThrowable _unit) select 0);

    // Stuff we need to know
    private _direction = GVAR(ThrowStyle_Normal_Direction);
    private _velocity = GVAR(CurrentThrowSpeed);
    private _vup = [0, 1, 1];

    if (GVAR(ThrowType) == "under") then {
        _direction = GVAR(ThrowStyle_Under_Direction);
        _velocity = GVAR(ThrowStyle_Under_Velocity);
        _vup = [1, 0, 0];
    };

    // Calculate the throw vector
    private _newVelocity = [0, 0, 0];

    if (GVAR(CtrlHeld)) then {
        _direction = [0, 200, 500];
        _velocity = 3;
    };

    private _p2 = (eyePos _unit) vectorAdd (positionCameraToWorld _direction) vectorDiff (positionCameraToWorld [0, 0, 0]);
    private _p1 = AGLtoASL (GVAR(ActiveGrenadeItem) modelToWorldVisual [0, 0, 0]);

    private _unitV = (_p1 vectorFromTo _p2) vectorMultiply _velocity;

    if (vehicle _unit == _unit) then {
        // This method assumes the ability for a human to instinctively provide upper-body throw stabilization to prevent a grenade from being too influenced by how they're moving
        _newVelocity = [0, 0, 0] vectorAdd _unitV;
    } else {
        // This method would be for things like the Littlebird throw-from-vehicles, where we have a vehicle-based velocity that can't be compensated for by a human
        _newVelocity = (velocity (vehicle _unit)) vectorAdd _unitV;
    };

    // Drop if unit dies during throw process
    if (alive _unit) then {
        GVAR(ActiveGrenadeItem) setVectorUp _vup; // This was null at start sometimes
        GVAR(ActiveGrenadeItem) setVelocity _newVelocity;
    };

    [_unit, "Completed a throw fully"] call FUNC(exitThrowMode);
}, [_unit], _waitTime] call EFUNC(common,waitAndExecute);
