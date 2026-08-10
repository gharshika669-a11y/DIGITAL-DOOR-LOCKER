# Digital Door Lock Using Verilog HDL

## Overview

This project implements a **digital door lock system using Verilog HDL**.

The system uses an 8-digit password entered through a 4-bit keypad interface. Each password digit is entered on a valid clock cycle.

The controller compares the entered 8-digit password with a predefined password. If the password is correct, the door is unlocked.

For security, the system counts incorrect password attempts. After **five consecutive wrong attempts**, an alarm is activated and further keypad input is ignored until the system is reset.

## Features

* 8-digit password
* 4-bit keypad input
* Clock-based digit entry
* Correct password detection
* Wrong password detection
* Door unlock output
* Wrong-attempt counter
* Alarm after 5 wrong attempts
* Reset functionality
* Synthesizable Verilog
* Automated testbench
* Simulation output
* VCD waveform generation

## Default Password

The default password used in this project is:

```text
1 2 3 4 5 6 7 8
```

It is stored in the Verilog module as:

```verilog
parameter [31:0] PASSWORD = 32'h12345678;
```

The password can easily be changed by modifying this parameter.

## Block Diagram

```text
                  +----------------------+
                  |                      |
   4-bit Key ---->|                      |
                  |                      |
   Key Valid ---->|   Digital Door      |
                  |      Lock            |
   Clock -------->|                      |----> Door Unlock
                  |                      |
   Reset -------->|                      |----> Alarm
                  |                      |
                  +----------------------+
                           |
                           |
                    Attempt Counter
```

## Input Signals

| Signal      |  Width | Description                 |
| ----------- | -----: | --------------------------- |
| `clk`       |  1 bit | System clock                |
| `reset`     |  1 bit | Active-high reset           |
| `key_code`  | 4 bits | Current keypad digit        |
| `key_valid` |  1 bit | Indicates a valid key entry |

## Output Signals

| Signal          |  Width | Description                              |
| --------------- | -----: | ---------------------------------------- |
| `door_unlock`   |  1 bit | Becomes 1 when password is correct       |
| `alarm`         |  1 bit | Becomes 1 after five wrong attempts      |
| `wrong_attempt` |  1 bit | One-clock indication of a wrong password |
| `attempt_count` | 3 bits | Number of wrong attempts                 |
| `digit_count`   | 4 bits | Number of digits currently entered       |

## Keypad Encoding

Each digit is represented using four bits.

| Digit | Binary Code |
| ----: | ----------- |
|     0 | `0000`      |
|     1 | `0001`      |
|     2 | `0010`      |
|     3 | `0011`      |
|     4 | `0100`      |
|     5 | `0101`      |
|     6 | `0110`      |
|     7 | `0111`      |
|     8 | `1000`      |
|     9 | `1001`      |

Only the digits 0–9 are required for the password.

## Password Entry

The password is entered one digit at a time.

For the default password:

```text
Clock 1 → 1
Clock 2 → 2
Clock 3 → 3
Clock 4 → 4
Clock 5 → 5
Clock 6 → 6
Clock 7 → 7
Clock 8 → 8
```

After the eighth valid digit is entered, the controller performs the password comparison.

## Correct Password

If the entered password is:

```text
12345678
```

the system produces:

```text
door_unlock = 1
alarm       = 0
```

The door remains unlocked until reset.

## Wrong Password

For example, if the user enters:

```text
11111111
```

the password comparison fails.

The `wrong_attempt` signal becomes active for one clock cycle and the attempt counter increases.

Example:

```text
Wrong attempt 1 → attempt_count = 1
Wrong attempt 2 → attempt_count = 2
Wrong attempt 3 → attempt_count = 3
Wrong attempt 4 → attempt_count = 4
Wrong attempt 5 → attempt_count = 5
```

On the fifth wrong attempt:

```text
alarm = 1
```

## Alarm Operation

After five wrong attempts:

```text
alarm = 1
```

The controller then ignores further keypad input.

Therefore, entering the correct password after the alarm has been activated will not unlock the door.

A reset is required to return the system to its initial state.

## System State Flow

```text
             +---------+
             |  RESET  |
             +----+----+
                  |
                  v
          +---------------+
          | Door Locked   |
          | Alarm OFF     |
          +-------+-------+
                  |
                  v
          Enter 8 digits
                  |
                  v
          +---------------+
          | Compare Code  |
          +-------+-------+
                  |
          +-------+-------+
          |               |
       Correct          Wrong
          |               |
          v               v
   +-------------+   Increment
   | Door Unlock |   Attempt Count
   +-------------+       |
                       |
                 Attempts = 5?
                    /       \
                  No         Yes
                  |           |
                  v           v
             Enter again   +-------+
                            | Alarm |
                            |  ON   |
                            +-------+
```

## RTL Architecture

The design contains:

### 1. Password Register

The entered digits are shifted into a 32-bit register.

Since each digit requires 4 bits:

```text
8 digits × 4 bits = 32 bits
```

### 2. Digit Counter

The digit counter tracks how many digits have been entered.

```text
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7
```

After the eighth digit, the password is checked.

### 3. Password Comparator

The complete 32-bit entered value is compared with the stored password.

```text
Entered Code == Password
```

If true:

```text
door_unlock = 1
```

Otherwise:

```text
wrong_attempt = 1
attempt_count = attempt_count + 1
```

### 4. Attempt Counter

The attempt counter records incorrect password attempts.

When the fifth incorrect password is detected:

```text
alarm = 1
```

## Truth Table

| Password | Attempt Count | Alarm | Door   |
| -------- | ------------: | ----: | ------ |
| Correct  |           Any |     0 | Unlock |
| Wrong    |             1 |     0 | Locked |
| Wrong    |             2 |     0 | Locked |
| Wrong    |             3 |     0 | Locked |
| Wrong    |             4 |     0 | Locked |
| Wrong    |             5 |     1 | Locked |

## Project Files

```text
digital-door-lock/
│
├── README.md
│
├── src/
│   └── digital_door_lock.v
│
├── tb/
│   └── digital_door_lock_tb.v
│
└── simulation/
    └── simulation_output.txt
```

## Simulation

The testbench verifies:

1. System reset
2. Correct password entry
3. Door unlocking
4. First wrong password
5. Second wrong password
6. Third wrong password
7. Fourth wrong password
8. Fifth wrong password
9. Alarm activation
10. Correct password attempted after alarm

## Icarus Verilog

Compile the project:

```bash
iverilog -o door_lock_sim src/digital_door_lock.v tb/digital_door_lock_tb.v
```

Run the simulation:

```bash
vvp door_lock_sim
```

A waveform file will be generated:

```text
digital_door_lock.vcd
```

Open the waveform:

```bash
gtkwave digital_door_lock.vcd
```

## ModelSim / QuestaSim

Compile:

```text
vlog src/digital_door_lock.v
vlog tb/digital_door_lock_tb.v
```

Start simulation:

```text
vsim digital_door_lock_tb
```

Run:

```text
run -all
```

## Important Waveform Signals

For the waveform screenshot, add:

```text
clk
reset
key_code
key_valid
digit_count
attempt_count
door_unlock
wrong_attempt
alarm
```

### Correct Password Waveform

During the correct password:

```text
key_code:

1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

door_unlock:

0 0 0 0 0 0 0 1
```

After the eighth digit, `door_unlock` becomes `1`.

### Wrong Password Waveform

For repeated wrong passwords:

```text
attempt_count:

0 → 1 → 2 → 3 → 4 → 5
```

At the fifth wrong attempt:

```text
alarm = 1
```

## Expected Simulation Result

```text
Correct Password:
12345678
       ↓
Password Match
       ↓
Door Unlock = 1
Alarm = 0
```

For five incorrect attempts:

```text
Wrong Password
      ↓
Attempt 1
      ↓
Attempt 2
      ↓
Attempt 3
      ↓
Attempt 4
      ↓
Attempt 5
      ↓
Alarm = 1
      ↓
Further input blocked
```

## Advantages

* Simple and easy-to-understand architecture
* Password can be changed through a parameter
* Hardware-friendly Verilog design
* Provides basic security functionality
* Easy to simulate
* Easy to implement on an FPGA

## Limitations

This is an educational digital design and does not implement the security features required for a real-world access-control product.

The password is stored directly in the RTL parameter, so it should not be considered secure against hardware inspection.

## Future Enhancements

The project can be extended with:

* 4×4 physical keypad interface
* Seven-segment display
* LCD/OLED display
* Password change functionality
* Password masking
* User authentication
* EEPROM/Flash password storage
* Door-open sensor
* Automatic relocking
* Buzzer control
* LED status indicators
* Tamper detection
* FPGA board implementation

## Conclusion

The Digital Door Lock project demonstrates how Verilog HDL can be used to design a basic password-based security system.

The system accepts an eight-digit password through a 4-bit keypad interface. A correct password unlocks the door, while repeated incorrect passwords increment an attempt counter. After five incorrect attempts, an alarm is activated and further input is blocked.

The project contains the complete RTL design, testbench, simulation output, and waveform generation required for a Verilog-based academic project.
