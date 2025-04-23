# Pure-Logic ROI Framework for Combinatorial Optimization  
# چارچوب ROI خالص-منطق برای بهینه‌سازی ترکیبی

**Keywords:**  
_combinatorial optimization · TSP · approximation algorithm · high ROI · cost-effective · efficient · large-scale_  
**کلیدواژه‌ها:**  
بهینه‌سازی ترکیبی · مسئله فروشنده دوره‌گرد · الگوریتم تقریب‌پذیر · ROI بالا · مقرون‌به‌صرفه · کارا · مقیاس بزرگ

A theory-driven, SEO-optimized toolkit to:  
1. **Bound** the optimal solution \(L^*\) via statistical (CLT) and assignment lower bounds plus a Christofides upper bound  
2. **Compare** approximate vs. exact algorithms by their accuracy-to-time ratio (ROI)  
3. **Decide** which method delivers the **highest ROI**—the most cost-effective algorithm—for large instances  

یک ابزار نظری و بهینه برای سئوی گیت‌هاب که:  
1. **بازه‌بندی** مقدار بهینه \(L^*\) با حد پایین آماری (CLT)، حد پایین بر پایه تخصیص و حد بالای کریستوفیدس  
2. **مقایسه** الگوریتم تقریب‌پذیر و دقیق بر اساس نسبت «دقت به زمان» (ROI)  
3. **انتخاب** روش با **بالاترین ROI**—مقرون‌به‌صرفه‌ترین الگوریتم—برای مسائل بزرگ  

---

## 📑 Table of Contents / فهرست مطالب

1. [Overview / معرفی](#overview--معرفی)  
2. [Key Features / ویژگی‌های کلیدی](#key-features--ویژگی‌های-کلیدی)  
3. [Core Steps / مراحل اصلی](#core-steps--مراحل-اصلی)  
4. [ROI Analysis / تحلیل ROI](#roi-analysis--تحلیل-roi)  
5. [Use Cases / موارد کاربرد](#use-cases--موارد-کاربرد)  
6. [Installation / نصب](#installation--نصب)  
7. [Quick Start / شروع سریع](#quick-start--شروع-سریع)  
8. [Contributing / مشارکت](#contributing--مشارکت)  
9. [License / مجوز](#license--مجوز)  

---

## 🌐 Overview / معرفی

For NP-hard combinatorial problems like the metric TSP, you typically choose between:  
- **Approximate algorithms**: run in \(\poly(n)\) time, error ≤ε  
- **Exact algorithms**: run in \(\exp(n)\) time, zero error  

**Key insight:**  
\[
\ROI_{\rm approx} = \frac{1 - \varepsilon}{\poly(n)}
\quad\gg\quad
\ROI_{\rm exact} = \frac{1}{\exp(n)}
\]  
for large \(n\).  
Thus, **this approximate method is provably the most cost-effective (highest ROI) approach possible** under our assumptions.

برای مسائل NP-سخت مانند TSP متریک، دو گزینه دارید:  
- **الگوریتم تقریب‌پذیر**: زمان اجرا چندجمله‌ای، خطای ≤ε  
- **الگوریتم دقیق**: زمان اجرا نمایی، دقت صددرصد  

**نکته کلیدی:**  
\[
\ROI_{\rm approx} = \frac{1 - \varepsilon}{\poly(n)}
\quad\gg\quad
\ROI_{\rm exact} = \frac{1}{\exp(n)}
\]  
برای \(n\) بزرگ.  
بنابراین، **این روش تقریب‌پذیر از نظر ROI سودده-ترین و مقرون‌به‌صرفه‌ترین است**.

---

## ✨ Key Features / ویژگی‌های کلیدی

- **Guaranteed Bounds**  
  - Statistical Lower Bound via CLT:  
    \(\mathrm{LB}_{\rm stat} = n\mu - C\,\sigma\sqrt{n}\)  
  - Assignment Lower Bound (LP relaxation)  
  - Christofides Upper Bound (1.5-approx)  

- **ROI-Driven Comparison**  
  - Approximate ROI = \((1-\varepsilon)/\poly(n)\)  
  - Exact ROI = \(1/\exp(n)\)  
  - For large \(n\): ROIₐₚₚ ≫ ROIₑₓ ⇒ **Most Cost-Effective**

- **Modular & Lightweight**  
  - Core logic separated in `pure-logic-proof.md`  
  - Easily plug in your own graph formats & solvers  

- **SEO Optimized**  
  - Targeted keywords for visibility on GitHub and search engines  

- **Bilingual Documentation**  
  - English first, then فارسی  

---

## 🛠 Core Steps / مراحل اصلی

1. **Compute Statistical LB**  
   ```python
   LB_stat = n*mu - C * sigma * math.sqrt(n)
   ```
2. **Compute Assignment LB**  
   ```python
   LB_assign = solve_assignment_relaxation(graph)
   ```
3. **Combined LB**  
   ```python
   LB = max(LB_stat, LB_assign)
   ```
4. **Christofides UB**  
   ```python
   UB = christofides_tsp(graph)
   ```
5. **Compare ROIs**  
   ```python
   ROI_approx = (1 - epsilon) / poly_time(n)
   ROI_exact  = 1 / exp_time(n)
   # For large n: poly(n) << exp(n) ⇒ ROI_approx >> ROI_exact
   ```

---

## 📊 ROI Analysis / تحلیل ROI

- **Approximate Algorithm**  
  - Time: \(\poly(n)\)  
  - Accuracy: ≥\(1-\varepsilon\)  
  - ROI: \(\frac{1-\varepsilon}{\poly(n)}\)

- **Exact Algorithm**  
  - Time: \(\exp(n)\)  
  - Accuracy: 1  
  - ROI: \(\frac{1}{\exp(n)}\)

Because \(\poly(n)\ll\exp(n)\) for large \(n\),  
\(\displaystyle\ROI_{\rm approx}\gg\ROI_{\rm exact}\).  
→ **Approximate algorithm is the most cost-effective (highest ROI).**

---

## 🎯 Use Cases / موارد کاربرد

- Logistics & Delivery Routing / لجستیک و مسیریابی  
- Job-Shop Scheduling / زمان‌بندی کارگاه  
- Sensor-Network & Telecom Design / طراحی شبکه‌های حسگر  
- Robotic Path Planning / مسیریابی رباتیک  
- Any large-scale optimization requiring quality guarantees and fast execution  
  / هر بهینه‌سازی مقیاس بزرگ با تضمین کیفیت و زمان اجرا

---

## 💻 Installation / نصب

```bash
git clone https://github.com/yourusername/pure-logic-roi.git
cd pure-logic-roi
pip install -r requirements.txt
```

---

## 🚀 Quick Start / شروع سریع

```python
from roi_framework import compute_bounds, compare_roi

# Load or generate your TSP graph
graph = load_graph('data/graph.json')

# 1. Compute bounds
LB, UB = compute_bounds(graph, mu=..., sigma=..., C=...)

# 2. Determine most cost-effective method
best = compare_roi(graph, epsilon=0.05)
print(f"Most cost-effective algorithm: {best}")
```

---

## 🤝 Contributing / مشارکت

1. Fork this repository  
2. Create a feature branch (`git checkout -b feature/your-change`)  
3. Commit your changes (`git commit -m 'Add new feature'`)  
4. Push to the branch (`git push origin feature/your-change`)  
5. Open a Pull Request  

---

## 📄 License / مجوز

Distributed under the **MIT License**.  
تحت مجوز **MIT** منتشر می‌شود.  
See [LICENSE](LICENSE) for details.
