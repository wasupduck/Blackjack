# Blackjack in LC3Tools

## Description

This is a simple implementation of the classic card game Blackjack, written in LC-3 Assembly language. The program allows a single player to compete against a basic dealer. Players can choose to 'hit' to receive another card or 'stay' to keep their current hand. The game includes basic logic for calculating hand totals, handling busts (going over 21), determining wins, losses, and pushes (ties), and provides options to start a new round or quit.

## How to Run

To run this program, you will need LC3Tools. You can typically assemble the `.asm` file using the simulator's built-in assembler and then load and execute the `.obj` or `.hex` file.

Here is the link: **[LC3Tools](http://highered.mheducation.com/sites/0072467509/student_view0/lc-3_tools.html)**.
## Special Requirements

After you assemble the program, you will need to hit randomize machine, and then reload object files before running it.

I'm not exactly sure why, but this program can break without warning. Pausing and playing it usually fixes the issue. If that doesn't work, try restarting the program or LC3Tools. I assume it has something to do with the size of the program I've written, but it might be a flaw in the code. It's hard to trace when exactly it's breaking.

<img width="536" alt="Screenshot 2025-05-14 at 11 15 01 AM" src="https://github.com/user-attachments/assets/a8da6e6e-fab3-4527-8c91-749ac1d9a82c" />
