Under Windows there will always be some run to run variation in the returned
cycle counts. The variation typically increases with the execution time of
the test code. The variation appears to be greatest on the P4 processors.

Much of the variation can be avoided by inserting a several second delay
after any necessary initialization (memory allocation, etc) and before the
first counter_begin macro call. The variation between the cycle counts for
the first execution of the test app and the second will frequently be higher
than the variation between the second and those that follow soon after.

The macros count cycles against the processor Time Stamp Counter (TSC).
Because the TSC has a resolution of 1 cycle (or an apparent resolution of 4
cycles on the P4 processors) it is not possible to get meaningful cycle
counts for instructions or sequences of instructions that execute in a small
number of clock cycles. Such code can be placed in a REPEAT block with a
suitable repeat count to get the cycle count up to something that can be
reasonably measured.