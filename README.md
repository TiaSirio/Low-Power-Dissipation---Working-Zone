# Low Power Dissipation - Working Zone 🚀

## Overview 📜

The specification of the 2019 "Logical Networks Project" Final Test is inspired by the low power dissipation coding method called "Working Zone." This method is applied to the Address Bus and is used to encode addresses differently based on certain ranges of values, known as Working Zone (WZ).

## Encoding Method 🔢

There are two possible encodings:
- If the address doesn't belong to any Working Zone, it is transmitted unchanged, with an additional bit set to 0 inserted before the address by a chaining operation.
- If the address belongs to a Working Zone, the additional bit is set to 1. The address bits are represented as follows:
  1. The first three bits represent the number of the Working Zone to which the address belongs.
  2. The last four bits indicate the offset from the base address of the Working Zone (encoded in one-hot).

## Technology Stack 💻

This project is implemented in VHDL, a hardware description language used to model and simulate digital circuits.

## Getting Started 🚀

To get started with the project, follow these steps:
1. Clone or download this repository.
2. Explore the VHDL code for detailed insights.
3. Implement or simulate the project in your VHDL environment.

# University Course 📖

This is the final project of the exam "Reti Logiche" for the Computer Science and Engineering degree at Polytechnic of Milano.

## Author 👨‍🏫

- Mattia Siriani