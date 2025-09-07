# Kaggle — Learning in Public

Clean, reproducible notebooks organized **by competition**, with metrics, validation, and takeaways.  
This repo documents *process* as much as *score*.

---

## Repository layout
~~~text
.
├─ competitions/
│  ├─ titanic/
│  │  ├─ 01_eda.ipynb
│  │  ├─ 02_baseline.ipynb
│  │  ├─ 03_feature_engineering.ipynb
│  │  ├─ 04_modeling.ipynb
│  │  └─ README.md        # objective → metric → best LB → lessons
│  ├─ house-prices/
│  │  ├─ ...
│  └─ ...
├─ tools/
│  └─ kaggle_helpers.py   # CV, scoring, plots
├─ assets/
│  └─ preview.png
├─ requirements.txt
├─ .gitignore
└─ LICENSE
~~~

---

## Suggested README per competition
~~~markdown
# [Competition Name]

**Objective**: (what to predict)  
**Metric**: (e.g., RMSLE / AUC)  
**Best public LB**: X.XXXX (date)  
**Approach**:
- Baseline: [model + features]
- Improvements: [what moved the metric]
- Validation: [CV scheme, leakage checks]

**Key takeaways**
1) …
2) …
3) …

**Reproduce**
- Install deps: `pip install -r ../../requirements.txt`
- Run notebook(s) in order
- Submit with: [...]
~~~

---

## Reproduce (global)
~~~bash
python -m venv .venv
# activate venv...
pip install -r requirements.txt
jupyter notebook
~~~

---

## Principles
- **Organized by challenge**, not by date  
- **Document validation:** CV must mirror LB metric  
- **Keep only winning changes:** clean final notebooks

---

## License
**MIT**

---

### Appendix — Minimal `requirements.txt`
~~~text
jupyter
numpy
pandas
scikit-learn
matplotlib
xgboost
lightgbm
~~~

### Appendix — Minimal `.gitignore`
~~~gitignore
.venv/
__pycache__/
.ipynb_checkpoints/
.kaggle/
competitions/*/input/
competitions/*/working/
~~~
