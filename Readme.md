CombinedROIAlgUnified v3 – ROI-Filtered TSP Meta-Solver

A single Julia 1.10 script that never wastes a CPU cycle: every local move is executed only when
benefit ≥ τ · cost (default τ = 0.001 m per ms).
It auto-switches among five engines and can handle graphs from tens to millions of vertices.

What’s new vs v2
	•	Global ROI gate – user-set τ instead of hand-tuned cut-offs.
	•	Still uses Concorde for windows ≤ W0 (default 9 k).
	•	Stops automatically when no ROI-positive move remains.

Requirements

julia 1.10
] add SimpleWeightedGraphs Graphs Clustering FilePathsBase
# optional – exact windows
install Concorde solver and place `concorde` in PATH

Quick start

include("CombinedROIAlgUnified_v3.jl")
tour = CombinedROIAlgUnified(G; τ = 0.0007, W0 = 6000, W = 4000)

println("length = ", tour_length(G, tour))

Default parameters

symbol	value	role
n3	40	exact branch
n1	800	adaptive branch
n2	30 000	streaming branch
W0	9 000	Concorde-window max
W	5 000	streaming window size
τ	0.001 m / ms	ROI threshold

(Set τ=0 to recover v2 behaviour; set W0=0 to disable Concorde.)

Performance snapshot*

n	gap	wall-time	RAM
50 k	0 .5 %	4 min	1 GB
250 k	1 %	40 min	3 GB
5 M	2 %	2 h	6 GB

* Intel i7-13700, single NVMe SSD, Concorde off-thread.

License

© 2025 Mitra Jafaei & Mehrad Mir – all rights reserved. Written permission required for redistribution.
