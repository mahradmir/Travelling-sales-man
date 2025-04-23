# Hierarchical Epsilon-ROI TSP Solver  
> Scalable (1+ε)-approximation for the Euclidean Traveling Salesman Problem with optional exact phases

**Keywords:** TSP, Traveling Salesman Problem, approximation algorithm, hierarchical clustering, ROI-gated k-opt, Delaunay triangulation, pure-logic specification

---

## 🚀 Overview  
Hierarchical Epsilon-ROI is a pure-logic, **O(N)**-time algorithm that computes a tour of length ≤(1+ε)·OPT on any N-point 2D Euclidean graph, with provable error and runtime guarantees. Optional “exact” phases at cluster or global level deliver true optimality when enabled.

---

## ✨ Key Features  
- **Linear Scalability:** Runtime ≈ N·(t₀/s₀ + t₁/s₁ + ε²·t₂) = O(N)  
- **(1+ε)-Approximation:** Tour length guaranteed ≤ (1+ε)·OPT for any ε∈(0,1]  
- **ROI-Gated Moves:** Only profitable k-opt exchanges pass dual-ROI validity checks (ΔL vs. compute cost)  
- **Hierarchical Clustering:** Three levels (s₀=8, s₁=50, s₂=⌈1/ε²⌉) for local refinement and stitching  
- **Optional Exact Phases:** Accelerated exact solve via Delaunay-based branch-and-bound at cluster/global level  
- **Pure-Logic Spec:** Formal axioms, definitions, and theorem ensure reproducibility and auditability  




⸻

📑 Algorithm Overview
	1.	Compute Lower Bound: MST-1tree or equivalent → LB(G)
	2.	Hierarchical Levels (ℓ=0,1,2):
	•	Partition V into clusters of size ≤ sₗ
	•	Local Nearest-Neighbor or ExtractSubtour
	•	ROI-Gated k-opt refinement (τ_d,τ_t, k, C from ε)
	3.	Stitching: ROI-Gated k-opt on cluster centroids + inter-cluster moves
	4.	Optional Exact Phases: AcceleratedExactPhase on each cluster or full graph using Delaunay triangulation + branch-and-bound
	5.	Return final tour T_current with len(T) ≤(1+ε)·OPT

See PURE_LOGIC_PROOF.md for the full formal specification.

⸻

🤝 Contributing
	1.	Fork this repository
	2.	Create a feature branch (git checkout -b feature-xyz)
	3.	Commit your changes (git commit -m "Add xyz")
	4.	Push to your branch (git push origin feature-xyz)
	5.	Open a Pull Request

⸻

📄 License

This project is licensed under the MIT License. See LICENSE for details.

⸻



⸻

حل‌کننده TSP با روش Hierarchical Epsilon-ROI

الگوریتم خطی با تضمین خطای (1+ε) و فازهای دقیق اختیاری

کلیدواژه‌ها: مسئله مسافر دوره‌گرد، الگوریتم تقریب‌پذیر، خوشه‌بندی سلسله‌مراتبی، حرکت‌های ROI، مثلث‌بندی دِلاونی، مستند منطق محض

⸻

🚀 مرور کلی

Hierarchical Epsilon-ROI یک الگوریتم O(N) برای حل مسئله TSP در گراف‌های دکارتی دو‌بعدی است که طول مسیر ≤(1+ε)·OPT را تضمین می‌کند. فازهای «دقیق» خوشه‌ای یا سراسری در صورت فعال‌سازی، به راه‌حل بهینه مطلق می‌رسند.

⸻

✨ ویژگی‌های کلیدی
	•	مقیاس‌پذیری خطی: زمان اجرا ≈ N·(t₀/s₀ + t₁/s₁ + ε²·t₂) = O(N)
	•	تضمین خطای (1+ε): طول مسیر ≤ (1+ε)·OPT
	•	حرکت‌های ROI: تنها مبادلات k-opt با ارزش خالص مثبت اجرا می‌شوند
	•	خوشه‌بندی سلسله‌مراتبی: سه سطح با اندازه‌های s₀=8، s₁=50، s₂=⌈1/ε²⌉
	•	فازهای دقیق اختیاری: حل دقیق بر پایهٔ مثلث‌بندی دِلاونی و branch-and-bound
	•	مستندسازی منطق محض: آکس‌یو‌م‌ها، تعاریف و قضیه برای تکرار‌پذیری کامل

⸻





📑 خلاصه الگوریتم
	1.	محاسبه حد پایین: MST-1tree → LB(G)
	2.	سه سطح سلسله‌مراتبی:
	•	خوشه‌بندی V به اندازه ≤ sₗ
	•	تور اولیه NN یا استخراج زیرتور
	•	بهبود ROI-Gated k-opt (پارامترها بر اساس ε)
	3.	دوختن خوشه‌ها: k-opt روی مراکز خوشه + مبادلات بین‌خوشه‌ای
	4.	فازهای دقیق اختیاری: AcceleratedExactPhase با مثلث‌بندی دِلاونی
	5.	خروجی: مسیر نهایی T_current با طول ≤(1+ε)·OPT

مستند منطق محض را در PURE_LOGIC_PROOF.md مشاهده کنید.

⸻

🤝 مشارکت
	1.	پروژه را فورک کنید
	2.	برنچ بسازید (git checkout -b feature-xyz)
	3.	تغییرات را کامیت کنید (git commit -m "Add xyz")
	4.	به مخزن خود پوش کنید (git push origin feature-xyz)
	5.	Pull Request باز کنید

⸻

📄 مجوز

این پروژه تحت MIT License منتشر شده است. جزئیات در LICENSE.









v4
## Description 
This algorithm solves large-scale instances of the Euclidean Traveling Salesman Problem (TSP) using a multi-stage adaptive architecture. It ensures that every computation step is logically justified, absolutely profitable, and verifiably non-redundant. It is built entirely within the framework of deductive logic and arithmetic reasoning. 

## Features 

- Hybrid architecture (exact, adaptive, streaming, windowed) 
- Pure logic-based move acceptance using: 
  - Proven lower bounds (1-Tree, MST + closure, statistical) 
  - Cost-benefit filters: Benefit(m) ≥ τ × Cost(m) 
- SIMD + GPU acceleration (optional) 
- Cluster-aware move filtering and ROI thresholding 
- Modular sub-algorithms based on problem size (n₁, n₂, n₃) 
- Deterministic, non-probabilistic, no ML or statistical estimations 

## Submodules 

### 1. ExactSearch (n ≤ n₃) 
- Branch-and-Bound guided by UB and LB 
- Guarantees optimal tour for small graphs 

### 2. CombinedAdaptiveAlg_AP (n ≤ n₁) 
- Tour initialization via Nearest Neighbor 
- Local search via ImprovedTSP_LogicalROI 
- Adaptive τ adjustment, restart, perturbation 

### 3. StreamingAlg (n ≤ n₂) 
- Space-efficient approximation 
- Works on geometric cells 
- Guarantees local-optimal stitching via MST 

### 4. WindowedDiscreteAlgWithConcorde_AP (n > n₂) 
- DFS order → windowed subinstances (W, W₀ overlap) 
- Solves subproblems with Concorde TSP solver 
- Stitches borders via minimum-cost matching 

## Cost Function Cost(m) = c₁ * num_edges_changed(m) 
        + c₂ * sum_distance_change(m) 
        + c₃ * (1 if crosses_clusters(m) else 0) 
 

## Parameters 

| Name      | Role                            | Default  | 
|-----------|----------------------------------|----------| 
| n₁, n₂, n₃| Size thresholds                  | 5k, 20k, 50k | 
| α         | Geometric spanner stretch       | 2.0      | 
| τ         | ROI threshold (adaptive)        | 0.2–1.0  | 
| ε_min/max | Sensitivity safe margins        | 0.01–0.1 | 
| c₁–c₃     | Cost function weights            | 1.0, 1.0, 5.0 | 
| C         | Confidence parameter (stat LB)  | 2.0      | 

## Execution Structure 

Each move m is accepted only if: 
1. Its resulting tour length ≥ LB (logical validity) 
2. Benefit(m) ≥ τ × Cost(m) (logical profitability) 

## Cluster Assignment 

- Uses multi-scale DBSCAN 
- Cluster labels are assigned during geometric preprocessing 












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
