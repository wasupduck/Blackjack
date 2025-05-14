# Blackjack in LC3Tools

## Description

This is a simple implementation of the classic card game Blackjack, written in LC-3 Assembly language. The program allows a single player to compete against a basic dealer. Players can choose to 'hit' to receive another card or 'stay' to keep their current hand. The game includes basic logic for calculating hand totals, handling busts (going over 21), determining wins, losses, and pushes (ties), and provides options to start a new round or quit.

## How to Run

To run this program, you will need LC3Tools. You can typically assemble the `.asm` file using the simulator's built-in assembler and then load and execute the `.obj` or `.hex` file.

This code was developed and tested using **[LC3Tools](http://highered.mheducation.com/sites/0072467509/student_view0/lc-3_tools.html)**.
## Special Requirements

Since this program is written for the LC-3 architecture, it must be run on an LC-3 simulator or hardware capable of executing LC-3 machine code. There are no specific graphical display requirements, as the interaction is purely text-based via standard input/output traps (`TRAP x20`, `x21`, `x22`). Ensure your simulator supports these basic trap routines.
