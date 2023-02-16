# Progetto_finale_reti_logiche
This is the final project of the exam "Reti Logiche" of the year 2019-2020.

## Introduction

The specification of the 2019 "Logical Networks Project" Final Test is inspired by the method of low power dissipation coding called "Working Zone."
This method is for the Address Bus: it is used to encode differently different way the value of a transmitted address (7 bits) when it is between certain ranges of values, called working-zone1 (WZ).
There are two possible encodings:
- If the address to be transmitted does not belong to any Working Zone, it is transmitted unchanged, with an additional bit set to 0 inserted previously to the address itself by a chaining operation.
- If the address to be transmitted belongs to a Working Zone, the additional bit is set to 1 while the address bits are represented as
following:
1. The first three represent the number of the Working Zone to which the address belongs.
2. The last four bits indicate the offset from the base address of the
Working Zone (encoded in one-hot2).
