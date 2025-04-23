# Pure-Logic Proof of ROI Superiority

**Proof (pure-logic style):**

1. **From A₁–A₆: Bounding \(L^*\)**  
   1.1. \(A_1:\ \mathrm{Independent}(D)\wedge\mathrm{VarFinite}(D)\wedge|D|=n\;\to\;\mathrm{CLTApplicable}(D)\).  
   1.2. \(A_2:\ \mathrm{CLTApplicable}(D)\;\to\;\mathrm{NormalApprox}(D)\).  
   1.3. \(A_3:\ \mathrm{NormalApprox}(D)\;\to\;n\mu - C\sigma\sqrt{n}\le L^*\).  
   1.4. \(A_4:\ \mathrm{AssignmentLowerBound}(G)\;\to\;\mathrm{LB}_{\mathrm{assign}}\le L^*\).  
   1.5. Define  
   \[
     \mathrm{LB}_{\mathrm{stat}} = n\mu - C\sigma\sqrt{n}, 
     \quad
     \mathrm{LB} = \max\bigl(\mathrm{LB}_{\mathrm{stat}},\,\mathrm{LB}_{\mathrm{assign}}\bigr).
   \]  
   1.6. \(A_5:\ \mathrm{Christofides}(G)\;\to\;\mathrm{UB}=L_{\Chr}\ge L^*\).  
   1.7. \(A_6:\ \mathrm{LB}\le L^*\le \mathrm{UB}.\)

2. **From A₇/A₈ and B₁–D: Comparing ROIs**  
   2.1. \(A_7:\ \mathrm{Cost}_{\mathrm{approx}}=\poly(n),\ \mathrm{Benefit}_{\mathrm{approx}}=1-\varepsilon\;\to\;\ROI_{\mathrm{approx}}=\tfrac{1-\varepsilon}{\poly(n)}.\)  
   2.2. \(A_8:\ \mathrm{Cost}_{\mathrm{exact}}=\exp(n),\ \mathrm{Benefit}_{\mathrm{exact}}=1\;\to\;\ROI_{\mathrm{exact}}=\tfrac1{\exp(n)}.\)  
   2.3. \(C_1:\forall\text{ large }n:\ \poly(n)\ll\exp(n)\;\to\;\tfrac{1-\varepsilon}{\poly(n)}\gg\tfrac1{\exp(n)}.\)  
   2.4. Therefore \(D:\ \ROI_{\mathrm{approx}}\gg\ROI_{\mathrm{exact}}.\)  
   2.5. From \(D\) — “\(\ROI_{\mathrm{approx}}\gg\ROI_{\mathrm{exact}}\)” — we infer  
   \[
     \text{MostROIProfitable}(\text{ApproxAlg}).
   \]

3. **On the independence of exact‐poly existence (G₁/G₂, I₁):**  
   3.1. \(G_1/G_2:\ \P\neq\NP\iff\neg\exists\text{poly‐time exact},\;\P=\NP\iff\exists\text{poly‐time exact}.\)  
   3.2. \(I_1:\ \P\neq\NP\) is independent of ZFC.  
   3.3. ⇒ Whether \(\P=\NP\) or not, the strict superiority \(\ROI_{\mathrm{approx}}\gg\ROI_{\mathrm{exact}}\) remains unchanged.

---

**Conclusion:**  
- **Guaranteed bound:** \(\mathrm{LB}\le L^*\le \mathrm{UB}.\)  
- **ROI advantage:** For sufficiently large \(n\),  
  \(\displaystyle \ROI_{\mathrm{approx}}\gg\ROI_{\mathrm{exact}},\)  
  so the approximate algorithm yields the **best ROI**.  
- **Robustness:** Holds regardless of whether a poly-time exact solver exists (\(\P=\NP\) independent of ZFC).  
