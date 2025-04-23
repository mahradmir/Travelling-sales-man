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


capabilities:

Exceptional scalability: Solves instances from a few thousand up to several million nodes with the same codebase while staying near-optimal.
	•	Modular, intelligent design: Integrates five search engines and automatically invokes Concorde on small sub-windows—no manual intervention required.
	•	ROI filtering: Executes only moves that deliver real gain, eliminating wasted CPU cycles.
	•	Adjustable τ parameter: Lets you trade off accuracy versus speed, from real-time decisions to overnight optimizations.
	•	Open-source and easily pluggable in Julia: Seamlessly connects to Python or CI pipelines.




Use Cases:

Last-mile delivery routing – Sequencing hundreds or thousands of daily drop-offs for couriers, parcel services, grocery and meal delivery to minimise drive time and fuel while respecting real-world constraints (traffic, parking, driver habits).  ￼
	2.	Manufacturing tool-path optimisation (PCB/CNC/3-D printing) – Ordering drill holes, mill cuts or extrusion moves so the tool travels the shortest distance, cutting cycle time and wear on spindles or print heads.  ￼
	3.	De-novo genome assembly – Ordering millions of DNA reads in an overlap-layout-consensus pipeline; a near-optimal TSP tour gives the scaffold on which contigs are built.  ￼
	4.	Multi-waypoint UAV / drone missions – Planning inspection, mapping or delivery flights where each waypoint must be visited once and battery time is tight; trajectory-aware TSP variants cut mission duration by double-digit percentages.  ￼
	5.	Telescope & satellite observation scheduling – Sequencing sky targets for ground- or space-based sensors (e.g., SSA, astronomy) to minimise slew time and maximise time on target within tight visibility windows.  


 and ...


License

© 2025 Mitra Jafaei & Mehrad Mir – all rights reserved. Written permission required for redistribution.
