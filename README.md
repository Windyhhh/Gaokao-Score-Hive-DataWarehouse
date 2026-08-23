# 🎓 Gaokao Score Hive Data Warehouse | 高考分数线数据分析：基于 Hive 的数据仓库实践

> **Comprehensive data warehouse practice for Chinese college entrance exam (Gaokao) score analysis. Apache Hive-based OLAP queries, multi-dimensional analysis, and complete data warehouse modeling.**
>
> 基于 Apache Hive 的中国高考分数线数据分析完整数据仓库实践。Hive OLAP 查询、多维度分析、完整数据仓库建模。

---

## 🌟 Features | 核心特性

- **Apache Hive** — Data warehouse built on Hadoop HDFS
- **OLAP Queries** — Multi-dimensional online analytical processing
- **Data Warehouse Modeling** — Star/snowflake schema design
- **Multi-dimensional Analysis** — By year, province, school, major, score segment
- **Hive Simulator** — Python-based Hive simulation for local testing
- **Complete Dataset** — Gaokao admission scores across years and provinces
- **Installation Scripts** — Automated Hive/Hadoop setup

---

## 📁 Project Structure | 项目结构

```
Gaokao-Score-Hive-DataWarehouse/
├── README.md
├── 快速导航.md
├── 高考分数线数据分析项目精品博客-优化版.md
└── backup/
    ├── 6 高考分数线 -可用--202511处理.csv   # Raw dataset
    ├── hive_olap_analysis.hql               # Hive OLAP queries
    ├── hive_simulator.py                     # Python Hive simulator
    ├── execute_olap_queries.py               # OLAP query executor
    ├── olap_results.txt                      # Query results
    ├── OLAP分析说明.md                        # OLAP analysis guide
    ├── README.md
    ├── 任务要求.txt
    ├── 实验报告要求.txt
    └── 开始使用.txt
```

---

## 🚀 Quick Start | 快速开始

```bash
# Option 1: Use Hive simulator (no Hadoop needed)
python backup/hive_simulator.py

# Option 2: Run on real Hive
hive -f backup/hive_olap_analysis.hql

# Option 3: Execute OLAP queries via Python
python backup/execute_olap_queries.py
```

---

## 🔬 Data Warehouse Design | 数据仓库设计

### Fact Table | 事实表

- `fact_admission` — Admission records (school_id, major_id, year, province_id, score, rank)

### Dimension Tables | 维度表

- `dim_school` — School information (name, level, location, type)
- `dim_major` — Major information (name, category, degree_type)
- `dim_province` — Province information (name, region, gaokao_type)
- `dim_year` — Year dimension
- `dim_score_segment` — Score segment classification

### OLAP Dimensions | OLAP 分析维度

| Dimension | Description |
|-----------|-------------|
| **Year** | Trend analysis across years |
| **Province** | Regional comparison |
| **School** | School-level analysis (985/211/dual first-class) |
| **Major** | Major category analysis |
| **Score Segment** | Distribution by score range |
| **Science/Arts** | Subject type comparison |

---

## 📊 Sample Queries | 示例查询

```sql
-- Average score by province and year
SELECT province_name, year, AVG(score) as avg_score
FROM fact_admission f
JOIN dim_province p ON f.province_id = p.id
GROUP BY province_name, year
ORDER BY year, avg_score DESC;

-- Top 10 schools by average score
SELECT school_name, AVG(score) as avg_score
FROM fact_admission f
JOIN dim_school s ON f.school_id = s.id
WHERE year = 2024
GROUP BY school_name
ORDER BY avg_score DESC
LIMIT 10;

-- Score distribution by segment
SELECT score_segment, COUNT(*) as count
FROM fact_admission f
JOIN dim_score_segment s ON f.score BETWEEN s.min_score AND s.max_score
GROUP BY score_segment;
```

---

## 📚 References | 参考文献

1. **Thusoo, A., et al.** (2009). *Hive: a warehousing solution over a map-reduce framework.* VLDB.
2. **Kimball, R., & Ross, M.** (2013). *The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling.* Wiley.
3. **Apache Hive.** (2024). *Apache Hive Language Manual.*

---

## 📄 License | 许可证

MIT License.

---

<div align="center">

**Built with 🎓 for big data education**

[GitHub](https://github.com/Windyhhh/Gaokao-Score-Hive-DataWarehouse)

</div>
