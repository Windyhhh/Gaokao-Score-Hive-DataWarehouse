# 🎓 高考分数线 Hive 数据仓库 | Gaokao Score Hive Data Warehouse

> **基于 Hive 的高考分数线大数据仓库——20 年全国各省分数线 ETL + 多维分析 + 可视化看板，志愿填报数据驱动。**
>
> *Hive-based big data warehouse for college entrance exam scores — 20 years of nationwide score ETL + multi-dimensional analysis + visualization dashboard, data-driven college application.*

---

## ⭐ 核心卖点 | Why Star This

| 卖点 | Feature | 一句话 |
|------|---------|--------|
| 🐘 **Hive 数仓** | Hive Data Warehouse | 完整的分层数仓架构 (ODS→DWD→DWS→ADS) |
| 📊 **20 年数据** | 20 Years Data | 全国各省 2000-2023 年高考分数线 |
| 🔄 **完整 ETL** | Full ETL | 数据采集、清洗、转换、加载全流程 |
| 📈 **多维分析** | Multi-Dimension | 省份、年份、科类、批次多维度分析 |
| 🎯 **志愿辅助** | Application Helper | 分数线趋势分析，辅助志愿填报决策 |

---

## 🏆 技术栈 | Tech Stack

![Hadoop](https://img.shields.io/badge/Hadoop-3.0+-yellow?logo=apachehadoop)
![Hive](https://img.shields.io/badge/Hive-3.1+-orange?logo=apachehive)
![Spark](https://img.shields.io/badge/Spark-3.0+-red?logo=apachespark)
![Python](https://img.shields.io/badge/Python-3.8+-blue?logo=python)
![Matplotlib](https://img.shields.io/badge/Matplotlib-3.4+-green?logo=plotly)

---

## 📊 数仓架构 | Warehouse Architecture

| 层级 | 名称 | 内容 | 表数 |
|------|------|------|------|
| ODS | 操作数据层 | 原始爬取数据，保留原始格式 | 5 |
| DWD | 明细数据层 | 清洗后的明细数据，维度退化 | 8 |
| DWS | 汇总数据层 | 按主题汇总的宽表 | 6 |
| ADS | 应用数据层 | 面向应用的结果表 | 4 |
| DIM | 维度表 | 省份、年份、科类、批次等维度 | 4 |

---

## 🚀 快速开始 | Quick Start

```bash
git clone https://github.com/Windyhhh/Gaokao-Score-Hive-DataWarehouse.git
cd Gaokao-Score-Hive-DataWarehouse

# 1. 启动 Hadoop 和 Hive
start-all.sh
hive --service metastore &

# 2. 创建数仓分层表
hive -f sql/ddl/ods_tables.sql
hive -f sql/ddl/dwd_tables.sql
hive -f sql/ddl/dws_tables.sql
hive -f sql/ddl/ads_tables.sql
hive -f sql/ddl/dim_tables.sql

# 3. 数据导入 (HDFS)
hdfs dfs -put data/ /user/hive/warehouse/ods.db/

# 4. ETL 执行
hive -f sql/etl/ods_to_dwd.sql
hive -f sql/etl/dwd_to_dws.sql
hive -f sql/etl/dws_to_ads.sql

# 5. 数据分析
hive -f sql/analysis/trend_analysis.sql
hive -f sql/analysis/province_comparison.sql

# 6. 可视化
python visualization/dashboard.py --result results/
```

---

## 📂 项目结构 | Project Structure

```
Gaokao-Score-Hive-DataWarehouse/
├── sql/
│   ├── ddl/                   # 建表语句
│   │   ├── ods_tables.sql
│   │   ├── dwd_tables.sql
│   │   ├── dws_tables.sql
│   │   ├── ads_tables.sql
│   │   └── dim_tables.sql
│   ├── etl/                   # ETL 脚本
│   │   ├── ods_to_dwd.sql
│   │   ├── dwd_to_dws.sql
│   │   └── dws_to_ads.sql
│   └── analysis/              # 分析查询
│       ├── trend_analysis.sql
│       ├── province_comparison.sql
│       ├── subject_comparison.sql
│       └── batch_analysis.sql
├── data/
│   ├── raw/                   # 原始数据
│   └── processed/             # 处理后数据
├── python/
│   ├── crawler.py             # 数据爬取
│   ├── cleaner.py             # 数据清洗
│   └── transformer.py         # 数据转换
├── visualization/
│   ├── dashboard.py           # 可视化看板
│   ├── charts.py              # 图表生成
│   └── templates/             # HTML 模板
├── docs/
│   ├── architecture.md        # 数仓架构设计
│   ├── data_dictionary.md     # 数据字典
│   └── etl_design.md          # ETL 设计文档
└── README.md
```

---

## 🔬 核心设计 | Core Design

### 数据模型 | Data Model

```
事实表: gaokao_score_fact
  - 省份 ID (dim_province)
  - 年份 ID (dim_year)
  - 科类 ID (dim_subject: 文科/理科/综合)
  - 批次 ID (dim_batch: 一本/二本/专科)
  - 分数线 (score)
  - 考生人数 (candidate_count)
  - 招生计划 (admission_plan)

维度表:
  dim_province: 省份 ID, 省份名称, 地区, 高考人数
  dim_year: 年份 ID, 年份, 高考改革标记
  dim_subject: 科类 ID, 科类名称
  dim_batch: 批次 ID, 批次名称, 批次顺序
```

### ETL 流程 | ETL Pipeline

```
数据采集 (Python 爬虫)
  ↓ 各省教育考试院、阳光高考网
ODS 层 (原始数据)
  - ods_province_score: 各省原始分数线
  - ods_school_info: 院校信息
  - ods_major_info: 专业信息
  ↓ 数据清洗 (去重、补全、格式统一)
DWD 层 (明细数据)
  - dwd_score_detail: 分数线明细
  - dwd_province_stat: 省份统计
  - dwd_school_detail: 院校明细
  ↓ 数据聚合 (按维度汇总)
DWS 层 (汇总数据)
  - dws_province_year: 省份-年份汇总
  - dws_subject_batch: 科类-批次汇总
  - dws_trend: 趋势汇总
  ↓ 应用导向
ADS 层 (应用数据)
  - ads_score_trend: 分数线趋势
  - ads_province_rank: 省份难度排名
  - ads_subject_compare: 文理对比
  - ads_volunteer_helper: 志愿填报辅助
```

### 数据质量 | Data Quality

```
数据质量规则:
  1. 完整性: 省份、年份、科类、批次不能为空
  2. 准确性: 分数线在 0-750 范围内
  3. 一致性: 同一省份同一年份同一科类批次唯一
  4. 及时性: 每年高考后 1 个月内更新
  5. 唯一性: (省份, 年份, 科类, 批次) 联合主键

数据质量检查:
  - 空值检查: SELECT * FROM dwd_score_detail WHERE score IS NULL
  - 范围检查: SELECT * FROM dwd_score_detail WHERE score < 0 OR score > 750
  - 重复检查: SELECT province, year, subject, batch, COUNT(*) ... HAVING COUNT(*) > 1
  - 逻辑检查: 一本线 > 二本线 > 专科线
```

---

## 📊 分析案例 | Analysis Cases

### 案例 1: 全国分数线趋势 | National Score Trend

```sql
-- 近 10 年全国一本线平均趋势
SELECT year, subject, AVG(score) as avg_score
FROM dws_trend
WHERE batch = '一本' AND year >= 2014
GROUP BY year, subject
ORDER BY year, subject;
```

**洞察**: 全国一本线整体呈下降趋势，文理差距逐渐缩小，新高考改革影响明显。

### 案例 2: 省份难度排名 | Province Difficulty Ranking

```sql
-- 2023 年各省一本线难度排名 (按考生人数加权)
SELECT p.province_name, s.score, p.candidate_count,
       RANK() OVER (ORDER BY s.score DESC) as difficulty_rank
FROM ads_province_rank s
JOIN dim_province p ON s.province_id = p.province_id
WHERE s.year = 2023 AND s.subject = '理科' AND s.batch = '一本'
ORDER BY difficulty_rank;
```

**洞察**: 河南、河北、山东等高考大省分数线居高不下，北京、上海、天津相对较低。

### 案例 3: 文理分数线对比 | Arts vs Science

```sql
-- 近 5 年文理分数线差距变化
SELECT year, 
       AVG(CASE WHEN subject = '文科' THEN score END) as arts_score,
       AVG(CASE WHEN subject = '理科' THEN score END) as science_score,
       AVG(CASE WHEN subject = '理科' THEN score END) - 
       AVG(CASE WHEN subject = '文科' THEN score END) as gap
FROM dws_subject_batch
WHERE batch = '一本' AND year >= 2019
GROUP BY year
ORDER BY year;
```

**洞察**: 文理分数线差距逐年缩小，新高考"3+1+2"模式下文理界限模糊。

---

## 📈 可视化看板 | Visualization Dashboard

看板包含以下图表：

| 图表 | 类型 | 说明 |
|------|------|------|
| 全国分数线趋势 | 折线图 | 近 20 年各批次分数线变化 |
| 省份热力图 | 地图 | 各省分数线难度分布 |
| 文理对比 | 柱状图 | 文理科分数线对比 |
| 批次分布 | 饼图 | 各批次招生计划占比 |
| 难度排名 | 条形图 | 各省高考难度排名 |
| 改革影响 | 面积图 | 新高考改革前后对比 |

---

## 🎯 应用场景 | Use Cases

- 🎓 **志愿填报**：考生和家长参考分数线趋势，辅助志愿决策
- 🏫 **院校招生**：高校根据历年分数线制定招生计划
- 📊 **教育研究**：教育研究者分析高考公平性和改革效果
- 📰 **媒体报道**：媒体制作高考相关的数据新闻
- 🏛️ **政策制定**：教育部门制定高考改革政策的数据支撑
- 💻 **大数据教学**：Hive 数仓项目的教学案例

---

## 📚 数据来源 | Data Sources

- 各省教育考试院官网
- 教育部阳光高考信息平台
- 中国教育在线
- 各高校本科招生网
- 公开的高考统计年鉴

---

## 📄 License

MIT License — 自由使用、修改和分发。

---

> 💡 **Hive 数仓 + 高考大数据的实战项目，Star ⭐ 支持开源大数据！**
