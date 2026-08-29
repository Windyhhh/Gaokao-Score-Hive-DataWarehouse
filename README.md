<div align="center">

# 高考分数线数据仓库 | Gaokao-Score-Hive-DataWarehouse

### An end-to-end data warehouse for college-entrance (Gaokao) scores.

Star-schema dimensional modeling with 6 dimensions + 1 fact table, OLAP analysis and visualization on Hive.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Hive](https://img.shields.io/badge/Hive-3-FDEE21?logo=apachehive&logoColor=black)](https://hive.apache.org/)
[![Hadoop](https://img.shields.io/badge/Hadoop-3-66CCFF?logo=apachehadoop&logoColor=white)](https://hadoop.apache.org/)

</div>

---

**Gaokao-Score-Hive-DataWarehouse** is an **end-to-end data warehouse** for college-entrance-exam (Gaokao) score analysis built on **Hive**. It applies **star-schema** dimensional modeling (6 dimension tables + 1 fact table), supports full **OLAP** operations, and visualizes the results.

> [!NOTE]
> 中文项目：高考分数线数据仓库——Hive + 星型维度建模（6 维 + 1 事实表），OLAP 分析（下钻/上卷/切片）+ 可视化。

---

## Features

- **Preprocessing pipeline** — cleaning, transformation, quality analysis.
- **Star-schema modeling** — 6 dimensions + 1 fact table.
- **OLAP analysis** — drill-down, roll-up, slice, dice.
- **Visualization** — multi-chart presentation of results.
- **Modular** — independent, maintainable components.

---

## Quickstart

```bash
git clone https://github.com/Windyhhh/Gaokao-Score-Hive-DataWarehouse.git
cd Gaokao-Score-Hive-DataWarehouse

# load data and run DDL/DML against Hive
hive -f sql/schema.sql
hive -f sql/etl.sql
hive -f sql/olap_analysis.sql
```

---

## Project Structure

```
Gaokao-Score-Hive-DataWarehouse/
├── sql/                    # schema, ETL, OLAP scripts
├── data/                   # raw score data
├── scripts/                # preprocessing
├── visualization/          # result charts
└── docs/                   # design, completion, blog
```

---


## Results

<div align="center">
  <img src="data/visualizations/01_分数线趋势图.png" alt="Score line trend" width="70%"/>
  <img src="data/visualizations/06_省份批次热力图.png" alt="Province-batch heatmap" width="70%"/>
</div>

---
## License

MIT — free to use, modify and distribute.
