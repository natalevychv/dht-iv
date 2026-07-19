# Testbench naming convention

Each simulation target must have a corresponding top-level VHDL testbench entity.

The testbench entity name must follow the convention:

<target>_tb


where `<target>` is the name used when running the simulation.

Examples:

Target:      n3
Testbench:   entity n3_tb

Target:      n4
Testbench:   entity n4_tb


The `run.sh` script automatically derives the top-level entity name from the selected target.

When adding a new target, make sure that:
- the source list is stored in `sources/<target>.txt`
- the testbench entity is named `<target>_tb`
- the testbench file contains the matching entity declaration

Following this convention allows new targets to be added without modifying the simulation script.