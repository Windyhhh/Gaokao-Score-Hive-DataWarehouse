# 高考招生数据仓库与OLAP分析项目

## 项目概述

本项目构建了一个基于Hive的高考招生数据仓库，用于管理和分析天津、青海、广西三省2014-2019年的高考招生数据。采用星型架构设计，实现了8类OLAP分析操作。

## 项目结构

```
400/
├── data_preprocessing.py              # 数据预处理脚本
├── generate_dimension_tables.py       # 生成维度表和事实表脚本
├── hive_create_tables.hql            # Hive建表脚本
├── hive_load_data.hql                # Hive数据加载脚本
├── hive_olap_analysis.hql            # OLAP分析脚本（16条HQL）
├── 数据仓库架构设计.md                # 架构设计文档
├── 6 高考分数线 -可用--202511处理.csv  # 原始数据文件
├── processed_data/                    # 预处理后的数据
│   ├── gaokao_filtered.csv           # 筛选后的CSV数据
│   └── gaokao_filtered.tsv           # 筛选后的TSV数据
└── hive_data/                        # Hive加载数据
    ├── time_dimension.tsv            # 时间维度表数据
    ├── location_dimension.tsv        # 地点维度表数据
    ├── university_dimension.tsv      # 高校维度表数据
    ├── batch_dimension.tsv           # 批次维度表数据
    ├── admission_type_dimension.tsv  # 招生类型维度表数据
    ├── candidate_type_dimension.tsv  # 考生类别维度表数据
    └── gaokao_admission_fact.tsv     # 事实表数据
```

## 使用步骤

### 第一步：数据预处理

运行数据预处理脚本，从原始数据中提取天津、青海、广西三省数据：

```bash
python data_preprocessing.py
```

**输出：**
- `processed_data/gaokao_filtered.csv` - 筛选后的数据（30,508条记录）
- `processed_data/gaokao_filtered.tsv` - TSV格式数据

### 第二步：生成维度表和事实表

运行维度表生成脚本，将数据转换为星型架构：

```bash
python generate_dimension_tables.py
```

**输出：**
- `hive_data/` 目录下的7个TSV文件（6个维度表 + 1个事实表）

### 第三步：在Hive中创建数据库和表

启动Hive并执行建表脚本：

```bash
# 启动Hive
hive

# 执行建表脚本
source hive_create_tables.hql;
```

或者直接执行：

```bash
hive -f hive_create_tables.hql
```

**创建的表：**
- `gaokao_dw` 数据库
- 6个维度表
- 1个事实表

### 第四步：加载数据到Hive

**重要：** 修改 `hive_load_data.hql` 中的文件路径为实际路径。

例如，将：
```sql
LOAD DATA LOCAL INPATH '/path/to/hive_data/time_dimension.tsv'
```

修改为：
```sql
LOAD DATA LOCAL INPATH '/home/your_username/400/hive_data/time_dimension.tsv'
```

然后执行加载脚本：

```bash
hive -f hive_load_data.hql
```

### 第五步：执行OLAP分析

执行OLAP分析脚本，运行16条分析查询：

```bash
hive -f hive_olap_analysis.hql
```

或者在Hive交互式环境中逐条执行：

```bash
hive
hive> USE gaokao_dw;
hive> -- 复制粘贴hive_olap_analysis.hql中的查询语句
```

## 数据仓库架构

### 星型架构设计

**事实表：**
- `gaokao_admission_fact` - 高考招生事实表（30,508条记录）

**维度表：**
1. `time_dimension` - 时间维度（6条记录：2014-2019）
2. `location_dimension` - 地点维度（3条记录：天津、青海、广西）
3. `university_dimension` - 高校维度（2,071条记录）
4. `batch_dimension` - 批次维度（14条记录）
5. `admission_type_dimension` - 招生类型维度（30条记录）
6. `candidate_type_dimension` - 考生类别维度（9条记录）

详细架构设计请参考：`数据仓库架构设计.md`

## OLAP分析操作

本项目实现了8类OLAP操作，每类2条HQL语句，共16条：

### 1. Drill Down（下钻）
- 从年度总体平均分下钻到各省份各年度
- 从录取批次总体下钻到各批次在不同省份的情况

### 2. Roll Up（上卷）
- 从各高校各年度数据上卷到整体年度趋势
- 从各高校在各省的详细数据上卷到省份层面

### 3. Slice（切片）
- 只看2019年的招生数据
- 只看天津市的招生数据

### 4. Dice（切块）
- 2017-2019年，天津和青海，本科批次，理科
- 2018-2019年，广西，本科批次，文理科对比

### 5. Top N（前N名）
- 2019年平均录取分最高的前10所高校
- 天津市理科本科一批录取分最高的前15所高校

### 6. Bottom N（后N名）
- 2018-2019年平均录取分最低的10所高校
- 青海省本科二批录取分最低的12所高校

### 7. Tertile（三分位数）
- 2019年三省理科录取分数的三分位分布
- 本科一批各年度录取分数的三分位分布趋势

### 8. Quartering（四分位数）
- 2018-2019年三省录取分数的四分位分布
- 文科vs理科录取分数的四分位对比

## 数据统计

- **原始数据**：433,436条记录
- **筛选后数据**：30,508条记录（天津、青海、广西）
- **时间跨度**：2014-2019年（6年）
- **涉及高校**：2,071所
- **招生地点**：3个省份
- **录取批次**：14种
- **招生类型**：30种
- **考生类别**：9种

## 技术栈

- **数据处理**：Python 3.x, Pandas
- **数据仓库**：Apache Hive
- **大数据平台**：Hadoop
- **数据格式**：CSV, TSV

## 注意事项

1. **数据范围限制**：本项目只使用天津、青海、广西三省数据，不能使用其他省份数据
2. **文件路径**：在执行Hive加载脚本前，务必修改文件路径为实际路径
3. **编码问题**：原始CSV文件使用GBK编码，处理后统一使用UTF-8编码
4. **缺失值处理**：平均分、最低分、省控线等字段存在缺失值，分析时需要过滤
5. **Hive版本**：建议使用Hive 1.2.1或更高版本

## 常见问题

### Q1: 如何检查数据是否加载成功？

```sql
USE gaokao_dw;
SELECT COUNT(*) FROM gaokao_admission_fact;  -- 应该返回30508
SELECT COUNT(*) FROM university_dimension;    -- 应该返回2071
```

### Q2: PERCENTILE函数报错怎么办？

确保Hive版本支持PERCENTILE函数，或者使用PERCENTILE_APPROX替代。

### Q3: 如何查看某个表的数据？

```sql
SELECT * FROM location_dimension;
SELECT * FROM gaokao_admission_fact LIMIT 10;
```

## 项目作者

西南交通大学 - Hive数据仓库开发与OLAP实践课程项目

## 参考文档

- `数据仓库架构设计.md` - 详细的架构设计文档
- `任务要求.txt` - 项目任务要求
- `搭建.txt` - 环境搭建说明

