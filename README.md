<div align="center">

# 🎓 Gaokao-Score-Hive-DataWarehouse

### Hive data warehouse for college-entrance (Gaokao) scores.

OLAP queries and multi-dimensional analysis on a star-schema Hive warehouse of Gaokao admission scores.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![HiveQL](https://img.shields.io/badge/Hive-3-FF7A00?logo=apachehive&logoColor=white)](https://hive.apache.org/)
[![OLAP](https://img.shields.io/badge/OLAP-star_schema-blue)](https://en.wikipedia.org/wiki/Star_schema)

</div>

---

**Gaokao-Score-Hive-DataWarehouse** builds an **Apache Hive** data warehouse for college-entrance (Gaokao) admission scores — a **star schema** with OLAP queries and multi-dimensional analysis.

> [!NOTE]
> 中文项目：高考分数线数仓——Apache Hive OLAP 查询、多维分析、星型模型。

---

## Quickstart

```bash
git clone https://github.com/Windyhhh/Gaokao-Score-Hive-DataWarehouse.git
cd Gaokao-Score-Hive-DataWarehouse

# Load dimension/fact data into Hive
hive -f backup/hive_olap_analysis.hql

# Or run the simulator without a cluster
python backup/hive_simulator.py
```

Star-schema data (university, location, time, admission_type, batch, candidate_type dimensions + fact) ships in `data/hive_data/`.

---

## Features

- **Star-schema warehouse** — dimension + fact tables for Gaokao scores.
- **OLAP analysis** — multi-dimensional slice / dice / roll-up queries.
- **Cluster-free option** — `hive_simulator.py` runs without a Hadoop cluster.

---

## Project Structure

```
Gaokao-Score-Hive-DataWarehouse/
├── data/hive_data/         # dimension + fact TSV files
├── backup/
│   ├── hive_olap_analysis.hql
│   ├── execute_olap_queries.py
│   ├── hive_simulator.py
│   └── quick_install.sh
└── docs/                   # warehouse design, OLAP notes
```

---

## License

MIT — free to use, modify and distribute.
