/* ============================================================================
   MCA - Artificial Intelligence | Lab Test 2
   Set 8: Smart Parking Space Allocation System (Roll No: IC-2K23-87)
   Turbo Prolog 2.0 Compatible Version
   ============================================================================ */

domains
    space_id, vehicle_id, s_type, v_type, req_type, status_type = symbol
    dist_val = integer

database
    parking_space(space_id, s_type, status_type, dist_val)

predicates
    init_parking
    suitable_space(v_type, req_type, s_type)
    has_closer_space(v_type, req_type, space_id, dist_val)
    nearest_suitable_space(v_type, req_type, space_id, s_type, dist_val)
    allocate_parking(vehicle_id, v_type, req_type)
    allocate_decision(v_type, req_type)
    explain_failure(v_type, req_type)
    show_parking_status
    run_test_cases

clauses
    /* 1. Initialize 10 Parking Spaces */
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

    /* 2. Compatibility & Priority Rules */
    suitable_space(_, accessible, accessible).
    suitable_space(_, reserved, reserved).
    suitable_space(ev, ev_charging, ev_charging).
    suitable_space(car, ev_charging, ev_charging).
    suitable_space(car, regular, regular).
    suitable_space(compact_car, compact, compact).
    suitable_space(compact_car, regular, compact).
    suitable_space(compact_car, regular, regular).
    suitable_space(suv, large, large).
    suitable_space(suv, regular, large).
    suitable_space(van, large, large).
    suitable_space(van, regular, large).

    /* 3. Nearest Available Space Selection */
    has_closer_space(VehicleType, Requirement, BestSpace, BestDist) :-
        parking_space(OtherSpace, OtherType, available, OtherDist),
        OtherSpace <> BestSpace,
        suitable_space(VehicleType, Requirement, OtherType),
        OtherDist < BestDist.

    nearest_suitable_space(VehicleType, Requirement, BestSpace, BestType, BestDist) :-
        parking_space(BestSpace, BestType, available, BestDist),
        suitable_space(VehicleType, Requirement, BestType),
        not(has_closer_space(VehicleType, Requirement, BestSpace, BestDist)),
        !.

    /* 4. Allocation & Dynamic State Update */
    allocate_parking(VehicleID, VehicleType, Requirement) :-
        nl,
        write("===================================================="), nl,
        write("SMART PARKING SYSTEM"), nl,
        write("===================================================="), nl,
        write("Vehicle ID   : ", VehicleID), nl,
        write("Vehicle Type : ", VehicleType), nl,
        write("Requirement  : ", Requirement), nl,
        allocate_decision(VehicleType, Requirement),
        write("===================================================="), nl.

    allocate_decision(VehicleType, Requirement) :-
        nearest_suitable_space(VehicleType, Requirement, SpaceID, SpaceType, Dist),
        !,
        retract(parking_space(SpaceID, SpaceType, available, Dist)),
        assertz(parking_space(SpaceID, SpaceType, occupied, Dist)),
        write("Allocated Space : ", SpaceID), nl,
        write("Space Type      : ", SpaceType), nl,
        write("Distance        : ", Dist, " meters"), nl,
        write("Status          : Successfully Allocated"), nl,
        write("Reason          : ", SpaceID, " is the nearest available space matching ", Requirement, "."), nl.

    allocate_decision(VehicleType, Requirement) :-
        write("Allocated Space : None"), nl,
        write("Status          : Allocation Failed"), nl,
        explain_failure(VehicleType, Requirement).

    explain_failure(VehicleType, Requirement) :-
        suitable_space(VehicleType, Requirement, SpaceType),
        parking_space(_, SpaceType, occupied, _),
        !,
        write("Reason          : All suitable spaces (", SpaceType, ") are currently occupied."), nl.

    explain_failure(_, Requirement) :-
        write("Reason          : No parking space supports ", Requirement, "."), nl.

    /* 5. Display All Parking Spaces */
    show_parking_status :-
        nl, write("--- CURRENT PARKING LOT STATUS ---"), nl,
        parking_space(ID, Type, Status, Dist),
        write("Space: ", ID, " | Type: ", Type, " | Status: ", Status, " | Distance: ", Dist, "m"), nl,
        fail.
    show_parking_status :-
        write("----------------------------------"), nl.

    /* 6. Run All 3 Test Cases */
    run_test_cases :-
        init_parking,
        nl, write("*** TEST CASE 1: Standard Car & Nearest Regular Space ***"), nl,
        allocate_parking(v101, car, regular),
        nl, write("*** TEST CASE 2: Sequential Arrivals & Accessibility Priority ***"), nl,
        allocate_parking(v102, car, accessible),
        allocate_parking(v103, car, regular),
        nl, write("*** TEST CASE 3: No Suitable Space Available ***"), nl,
        allocate_parking(v104, car, regular),
        allocate_parking(v105, car, accessible),
        show_parking_status.

goal
    run_test_cases.
