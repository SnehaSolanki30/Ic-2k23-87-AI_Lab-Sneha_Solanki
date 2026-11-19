% ============================================================================
% MCA - Artificial Intelligence | Lab Test 2
% Set 8: Smart Parking Space Allocation System (Roll No: IC-2K23-87)
% Compatible with GNU Prolog 1.4.5 / SWI-Prolog
% ============================================================================

:- dynamic(parking_space/4).

% ----------------------------------------------------------------------------
% 1. KNOWLEDGE BASE: Initial 10 Parking Spaces
%    Format: parking_space(SpaceID, SpaceType, Availability, DistanceInMeters)
% ----------------------------------------------------------------------------
init_parking :-
    retractall(parking_space(_, _, _, _)),
    assertz(parking_space(p1,  regular,     occupied,  10)),
    assertz(parking_space(p2,  compact,     available, 15)),
    assertz(parking_space(p3,  regular,     available, 20)),
    assertz(parking_space(p4,  reserved,    available, 12)),
    assertz(parking_space(p5,  accessible,  available,  5)),
    assertz(parking_space(p6,  regular,     available, 30)),
    assertz(parking_space(p7,  compact,     available,  8)),
    assertz(parking_space(p8,  ev_charging, available, 18)),
    assertz(parking_space(p9,  large,       available, 25)),
    assertz(parking_space(p10, accessible,  occupied,   6)).

% ----------------------------------------------------------------------------
% 2. COMPATIBILITY & PRIORITY RULES
%    suitable_space(VehicleType, Requirement, SpaceType)
% ----------------------------------------------------------------------------

% Highest priority: Vehicles with accessibility requirements
suitable_space(_, accessible, accessible).

% Reserved permit holders
suitable_space(_, reserved, reserved).

% Electric vehicles requiring charging
suitable_space(ev, ev_charging, ev_charging).
suitable_space(car, ev_charging, ev_charging).

% Standard cars requiring regular parking
suitable_space(car, regular, regular).

% Compact cars can use compact or regular spaces
suitable_space(compact_car, compact, compact).
suitable_space(compact_car, regular, compact).
suitable_space(compact_car, regular, regular).

% Large vehicles (SUV / Van / Truck) require large spaces
suitable_space(suv, large, large).
suitable_space(suv, regular, large).
suitable_space(van, large, large).
suitable_space(van, regular, large).

% ----------------------------------------------------------------------------
% 3. NEAREST AVAILABLE SPACE SELECTION (Distance Optimization)
%    Finds an available, suitable space such that no other available,
%    suitable space has a strictly smaller distance from the entrance.
% ----------------------------------------------------------------------------
nearest_suitable_space(VehicleType, Requirement, BestSpace, BestType, BestDist) :-
    parking_space(BestSpace, BestType, available, BestDist),
    suitable_space(VehicleType, Requirement, BestType),
    \+ (
        parking_space(OtherSpace, OtherType, available, OtherDist),
        OtherSpace \== BestSpace,
        suitable_space(VehicleType, Requirement, OtherType),
        OtherDist < BestDist
    ),
    !.

% ----------------------------------------------------------------------------
% 4. PARKING ALLOCATION & DYNAMIC STATE UPDATE
%    Prevents double-allocation by retracting 'available' and asserting 'occupied'
% ----------------------------------------------------------------------------
allocate_parking(VehicleID, VehicleType, Requirement) :-
    nl,
    write('===================================================='), nl,
    write('SMART PARKING SYSTEM'), nl,
    write('===================================================='), nl,
    write('Vehicle ID   : '), write(VehicleID), nl,
    write('Vehicle Type : '), write(VehicleType), nl,
    write('Requirement  : '), write(Requirement), nl,
    allocate_decision(VehicleType, Requirement),
    write('===================================================='), nl.

% Case A: Priority / Suitable space found
allocate_decision(VehicleType, Requirement) :-
    nearest_suitable_space(VehicleType, Requirement, SpaceID, SpaceType, Dist),
    !,
    retract(parking_space(SpaceID, SpaceType, available, Dist)),
    assertz(parking_space(SpaceID, SpaceType, occupied, Dist)),
    write('Allocated Space : '), write(SpaceID), nl,
    write('Space Type      : '), write(SpaceType), nl,
    write('Distance        : '), write(Dist), write(' meters'), nl,
    write('Status          : Successfully Allocated'), nl,
    write('Reason          : '), write(SpaceID),
    write(' is the nearest available space matching '),
    write(Requirement), write(' requirement.'), nl.

% Case B: No suitable space available (explain why)
allocate_decision(VehicleType, Requirement) :-
    write('Allocated Space : None'), nl,
    write('Status          : Allocation Failed'), nl,
    explain_failure(VehicleType, Requirement).

explain_failure(VehicleType, Requirement) :-
    suitable_space(VehicleType, Requirement, SpaceType),
    parking_space(_, SpaceType, occupied, _),
    !,
    write('Reason          : All suitable spaces for '),
    write(Requirement), write(' ('), write(SpaceType),
    write(') are currently occupied.'), nl.

explain_failure(_, Requirement) :-
    write('Reason          : No parking space in the facility supports '),
    write(Requirement), write(' requirement.'), nl.

% ----------------------------------------------------------------------------
% 5. UTILITY PREDICATE: Display Current Parking Facility Status
% ----------------------------------------------------------------------------
show_parking_status :-
    nl,
    write('--- CURRENT PARKING LOT STATUS ---'), nl,
    parking_space(ID, Type, Status, Dist),
    write('Space: '), write(ID),
    write(' | Type: '), write(Type),
    write(' | Status: '), write(Status),
    write(' | Distance: '), write(Dist), write('m'), nl,
    fail.
show_parking_status :-
    write('----------------------------------'), nl.

% ----------------------------------------------------------------------------
% 6. TEST SUITE: Three Distinct Scenarios
% ----------------------------------------------------------------------------
run_test_cases :-
    init_parking,
    nl, write('*** TEST CASE 1: Standard Car & Nearest Regular Space ***'), nl,
    allocate_parking(v101, car, regular),

    nl, write('*** TEST CASE 2: Sequential Arrivals & Accessibility Priority ***'), nl,
    allocate_parking(v102, car, accessible),
    allocate_parking(v103, car, regular),

    nl, write('*** TEST CASE 3: No Suitable Space Available ***'), nl,
    allocate_parking(v104, car, regular),
    allocate_parking(v105, car, accessible),
    show_parking_status.
