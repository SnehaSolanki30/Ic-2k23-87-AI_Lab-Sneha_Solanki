# MCA AI Lab Test 2 — Set 8: Smart Parking Space Allocation System

* **Student Roll No:** IC-2K23-87

* **Assigned Set:** Set 8 (Roll No. 85–90)

* **GitHub Profile:** [SnehaSolanki30](https://github.com/SnehaSolanki30)

* **Files Included:**

  * `smart_parking.pl` — Standard Prolog version (GNU Prolog 1.4.5 / SWI-Prolog, matching `prolog notes.docx`)

  * `smart_parking_turbo.pl` — Turbo Prolog 2.0 version (`domains`, `database`, `predicates`, `clauses`, `goal`)

  * `smart_parking_demo.mp4` — 2+ minute captioned walkthrough video explaining the logic, implementation, and test cases

## 1. Explanation of Facts, Rules, and Approach

### Knowledge Base Representation (`parking_space/4`)

Each of the 10 parking spaces (`p1`–`p10`) is stored as a dynamic fact:

```
parking_space(SpaceID, SpaceType, Availability, DistanceInMeters).

```

Initial state includes a mix of `regular`, `compact`, `reserved`, `accessible`, `ev_charging`, and `large` spaces, some `available` and some `occupied`.

### Matching & Priority Rules (`suitable_space/3`)

* **Accessibility Priority:** Vehicles with `accessible` requirements are matched directly to `accessible` spaces (`p5` at 5m, `p10` already occupied).

* **Type & Requirement Matching:** Standard cars (`car`) with `regular` requirement match `regular` spaces; `compact_car` can use `compact` or `regular`; `suv`/`van` match `large`; `ev` matches `ev_charging`; `reserved` matches `reserved`.

### Nearest-Distance Optimization (`nearest_suitable_space/5`)

Instead of picking the first matching space in clause order, the program uses negation-as-failure (`\+` in GNU Prolog / `not(...)` in Turbo Prolog) to verify that no other available, suitable space has a strictly smaller distance from the entrance, then uses a cut (`!`) to commit to that optimal space.

### Dynamic State Update (Preventing Double Allocation)

Once a space is allocated, `retract/1` removes its `available` fact and `assertz/1` inserts an `occupied` fact for that `SpaceID`. This guarantees that subsequent vehicles arriving one after another cannot be assigned an already-allocated space.

## 2. Three Test Cases & Expected Outputs

Run `init_parking.` followed by `run_test_cases.` in Prolog:

### Test Case 1: Standard Car (`v101`, `car`, `regular`)

* `p1` (regular, 10m) is `occupied`. `p3` (regular, 20m) and `p6` (regular, 30m) are `available`.

* **Output:**

```
SMART PARKING SYSTEM
Vehicle ID   : v101
Vehicle Type : car
Requirement  : regular
Allocated Space : p3
Space Type      : regular
Distance        : 20 meters
Status          : Successfully Allocated
Reason          : p3 is the nearest available space matching regular requirement.

```

### Test Case 2: Sequential Arrivals & Accessibility Priority (`v102` accessible, `v103` regular)

* `v102` (`car`, `accessible`) gets `p5` (accessible, 5m) because `p10` is occupied.

* `v103` (`car`, `regular`) cannot get `p3` (now `occupied` from Test Case 1), so it is allocated `p6` (regular, 30m).

* **Output:**

```
Vehicle ID   : v102 | Allocated Space: p5 (accessible, 5m) | Status: Successfully Allocated
Vehicle ID   : v103 | Allocated Space: p6 (regular, 30m)   | Status: Successfully Allocated

```

### Test Case 3: No Suitable Space Available (`v104` regular, `v105` accessible)

* All `regular` spaces (`p1`, `p3`, `p6`) and all `accessible` spaces (`p5`, `p10`) are now `occupied`.

* **Output:**

```
Vehicle ID   : v104
Vehicle Type : car
Requirement  : regular
Allocated Space : None
Status          : Allocation Failed
Reason          : All suitable spaces for regular (regular) are currently occupied.

```

## 3. How to Push to Your GitHub Repository

1. Create a new repository on [GitHub](https://github.com/SnehaSolanki30) (for example, `MCA-AI-Lab-Test-2`).

2. Place `smart_parking.pl`, `smart_parking_turbo.pl`, `README.md`, and `smart_parking_demo.mp4` in a local folder and run:

```
git init
git add smart_parking.pl smart_parking_turbo.pl README.md smart_parking_demo.mp4
git commit -m "Add Set 8 Smart Parking Space Allocation System (IC-2K23-87)"
git branch -M main
git remote add origin https://github.com/SnehaSolanki30/MCA-AI-Lab-Test-2.git
git push -u origin main

```

## 4. 2-Minute Demo Video Narration Script (If Recording Voiceover)

* **\[0:00 – 0:25\] Introduction:** "Hello, my name is Sneha Solanki, Roll Number IC-2K23-87. For MCA AI Lab Test 2, I have been assigned Set 8: Smart Parking Space Allocation System, implemented in Prolog."

* **\[0:25 – 0:55\] Knowledge Base & Facts:** "In my knowledge base, I defined ten parking spaces, p1 through p10, using a dynamic predicate `parking_space(SpaceID, Type, Status, Distance)`. Each space has a type such as regular, compact, accessible, reserved, ev_charging, or large, a status of available or occupied, and a distance in meters from the entrance."

* **\[0:55 – 1:25\] Rules & Optimization:** "The `suitable_space` rules match incoming vehicles to compatible spaces while giving priority to accessibility requirements. To pick the nearest available space, `nearest_suitable_space` uses negation-as-failure to ensure no other available matching space has a smaller distance. Once allocated, `retract` and `assertz` update the space status to occupied so it can never be assigned twice."

* **\[1:25 – 2:10\] Test Cases & Conclusion:** "In Test Case 1, vehicle v101 requests regular parking and receives p3 at 20 meters because p1 is occupied. In Test Case 2, v102 requests accessible parking and receives p5 at 5 meters, while v103 arrives next and receives p6 at 30 meters since p3 is now occupied. In Test Case 3, when v104 and v105 arrive with no remaining regular or accessible spaces, the system reports Allocation Failed and explains why. Thank you."