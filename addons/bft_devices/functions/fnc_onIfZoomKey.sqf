/*
 * Author: Gundy
 *
 * Description:
 *   Called whenever a interface zoom key is pressed. Will zoom in/out map on display interface type.
 *
 * Arguments:
 *   0: 0 = ZoomIn, 1 = ZoomOut <INTEGER>
 *
 * Return Value:
 *   Handled <BOOL>
 *
 * Example:
 *   0 call ace_bft_devices_fnc_onIfZoomKey;
 *
 * Public: No
 */

#include "script_component.hpp"

private ["_displayName","_mapScale","_mapScaleMin","_mapScaleMax"];

// bail if there is no interface open, or it is still being started
if (GVAR(ifOpenStart) || (I_CLOSED)) exitWith {false};

_displayName = I_GET_NAME;
// bail if this is a dialog
if (I_GET_ISDIALOG) exitWith {false};


switch (_this) do {
    case 0: { // Zoom In
        _mapScale = ([_displayName,"mapScaleDsp"] call FUNC(getSettings)) / 2;
        _mapScaleMin = [_displayName,"mapScaleMin"] call FUNC(getSettings);
        if (_mapScale < _mapScaleMin) then {
            _mapScale = _mapScaleMin;
        };
        _mapScale = [_displayName,[["mapScaleDsp",_mapScale]]] call FUNC(setSettings);
        true
    };
    case 1: { // Zoom Out
        _mapScale = ([_displayName,"mapScaleDsp"] call FUNC(getSettings)) * 2;
        _mapScaleMax = [_displayName,"mapScaleMax"] call FUNC(getSettings);
        if (_mapScale > _mapScaleMax) then {
            _mapScale = _mapScaleMax;
        };
        _mapScale = [_displayName,[["mapScaleDsp",_mapScale]]] call FUNC(setSettings);
        true
    };
    
    default {
        false
    };
};