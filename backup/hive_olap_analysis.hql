-- ============================================================
-- 高考招生数据仓库 - OLAP分析脚本
-- 包含8类OLAP操作，每类2条HQL语句，共16条
-- 数据范围：天津、青海、广西三省，2014-2019年
-- ============================================================

USE gaokao_dw;

-- ============================================================
-- 1. Drill Down（下钻）- 从粗粒度到细粒度
-- ============================================================

-- 1.1 下钻分析：从年度总体平均分下钻到各省份各年度的平均分
-- 物理意义：分析天津、青海、广西三省在2014-2019年间录取平均分的年度变化趋势
SELECT
    t.year year,
    l.province_name province,
    COUNT(*) record_count,
    ROUND(AVG(f.avg_score), 2) avg_admission_score,
    ROUND(MIN(f.avg_score), 2) min_admission_score,
    ROUND(MAX(f.avg_score), 2) max_admission_score
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
WHERE f.avg_score IS NOT NULL
GROUP BY t.year, l.province_name
ORDER BY t.year, l.province_name;

-- 1.2 下钻分析：从录取批次总体下钻到各批次在不同省份的录取情况
-- 物理意义：分析本科一批、本科二批在三省的录取分数差异，了解各省录取标准
SELECT
    b.batch_name batch,
    l.province_name province,
    c.candidate_type candidate_type,
    COUNT(*) record_count,
    ROUND(AVG(f.avg_score), 2) avg_score,
    ROUND(AVG(f.control_score), 2) avg_control_score
FROM gaokao_admission_fact f
JOIN batch_dimension b ON f.batch_key = b.batch_key
JOIN location_dimension l ON f.location_key = l.location_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE f.avg_score IS NOT NULL
  AND b.batch_name IN ('本科一批', '本科二批')
GROUP BY b.batch_name, l.province_name, c.candidate_type
ORDER BY b.batch_name, l.province_name, c.candidate_type;

-- ============================================================
-- 2. Roll Up（上卷）- 从细粒度到粗粒度
-- ============================================================

-- 2.1 上卷分析：从各高校各年度数据上卷到整体年度趋势
-- 物理意义：汇总分析2014-2019年整体招生趋势，观察录取分数线的总体变化
SELECT 
    t.year AS 年份,
    COUNT(DISTINCT f.university_key) AS 招生高校数,
    COUNT(*) AS 总招生记录数,
    ROUND(AVG(f.avg_score), 2) AS 整体平均分,
    ROUND(AVG(f.min_score), 2) AS 整体最低分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
WHERE f.avg_score IS NOT NULL
GROUP BY t.year
ORDER BY t.year;

-- 2.2 上卷分析：从各高校在各省的详细数据上卷到省份层面
-- 物理意义：汇总三省的整体招生情况，比较各省的招生规模和录取标准
SELECT 
    l.province_name AS 省份,
    COUNT(DISTINCT f.university_key) AS 招生高校数,
    COUNT(DISTINCT f.batch_key) AS 涉及批次数,
    COUNT(*) AS 总招生记录数,
    ROUND(AVG(f.avg_score), 2) AS 平均录取分,
    ROUND(AVG(f.control_score), 2) AS 平均省控线
FROM gaokao_admission_fact f
JOIN location_dimension l ON f.location_key = l.location_key
WHERE f.avg_score IS NOT NULL
GROUP BY l.province_name
ORDER BY COUNT(*) DESC;

-- ============================================================
-- 3. Slice（切片）- 在某一维度上选择特定值
-- ============================================================

-- 3.1 切片分析：只看2019年的招生数据
-- 物理意义：分析2019年三省各批次的录取情况，了解最新年度的招生特点
SELECT 
    l.province_name AS 省份,
    b.batch_name AS 录取批次,
    c.candidate_type AS 考生类别,
    COUNT(*) AS 招生记录数,
    ROUND(AVG(f.avg_score), 2) AS 平均分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
JOIN batch_dimension b ON f.batch_key = b.batch_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE t.year = 2019 AND f.avg_score IS NOT NULL
GROUP BY l.province_name, b.batch_name, c.candidate_type
ORDER BY l.province_name, COUNT(*) DESC
LIMIT 20;

-- 3.2 切片分析：只看天津市的招生数据
-- 物理意义：专注分析天津市2014-2019年的招生变化，了解天津考生的录取趋势
SELECT 
    t.year AS 年份,
    b.batch_name AS 录取批次,
    c.candidate_type AS 考生类别,
    COUNT(*) AS 招生记录数,
    ROUND(AVG(f.avg_score), 2) AS 平均分,
    ROUND(MIN(f.avg_score), 2) AS 最低分,
    ROUND(MAX(f.avg_score), 2) AS 最高分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
JOIN batch_dimension b ON f.batch_key = b.batch_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE l.province_name = '天津' AND f.avg_score IS NOT NULL
GROUP BY t.year, b.batch_name, c.candidate_type
ORDER BY t.year, b.batch_name, c.candidate_type;

-- ============================================================
-- 4. Dice（切块）- 在多个维度上同时选择
-- ============================================================

-- 4.1 切块分析：2017-2019年，天津和青海，本科一批和本科二批，理科
-- 物理意义：对比分析天津和青海两地近三年本科批次理科录取情况
SELECT 
    t.year AS 年份,
    l.province_name AS 省份,
    b.batch_name AS 录取批次,
    COUNT(*) AS 招生记录数,
    ROUND(AVG(f.avg_score), 2) AS 平均分,
    ROUND(AVG(f.control_score), 2) AS 平均省控线,
    ROUND(AVG(f.avg_score) - AVG(f.control_score), 2) AS 超省控线分数
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
JOIN batch_dimension b ON f.batch_key = b.batch_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE t.year BETWEEN 2017 AND 2019
  AND l.province_name IN ('天津', '青海')
  AND b.batch_name IN ('本科一批', '本科二批')
  AND c.candidate_type = '理科'
  AND f.avg_score IS NOT NULL
GROUP BY t.year, l.province_name, b.batch_name
ORDER BY t.year, l.province_name, b.batch_name;

-- 4.2 切块分析：2018-2019年，广西，本科批次，文科和理科对比
-- 物理意义：分析广西近两年本科批次文理科录取分数差异
SELECT
    t.year AS 年份,
    b.batch_name AS 录取批次,
    c.candidate_type AS 考生类别,
    COUNT(*) AS 招生记录数,
    ROUND(AVG(f.avg_score), 2) AS 平均分,
    ROUND(MIN(f.avg_score), 2) AS 最低分,
    ROUND(MAX(f.avg_score), 2) AS 最高分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
JOIN batch_dimension b ON f.batch_key = b.batch_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE t.year BETWEEN 2018 AND 2019
  AND l.province_name = '广西'
  AND b.batch_name LIKE '本科%'
  AND c.candidate_type IN ('文科', '理科')
  AND f.avg_score IS NOT NULL
GROUP BY t.year, b.batch_name, c.candidate_type
ORDER BY t.year, b.batch_name, c.candidate_type;

-- ============================================================
-- 5. Top N（前N名）- 排名前N的记录
-- ============================================================

-- 5.1 Top N分析：2019年平均录取分最高的前10所高校在三省的表现
-- 物理意义：找出2019年在三省录取分数最高的顶尖高校
SELECT
    u.university_name AS 学校名称,
    u.university_province AS 学校所在省,
    COUNT(*) AS 招生记录数,
    ROUND(AVG(f.avg_score), 2) AS 平均录取分,
    ROUND(MIN(f.avg_score), 2) AS 最低录取分,
    ROUND(MAX(f.avg_score), 2) AS 最高录取分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN university_dimension u ON f.university_key = u.university_key
WHERE t.year = 2019 AND f.avg_score IS NOT NULL
GROUP BY u.university_name, u.university_province
ORDER BY AVG(f.avg_score) DESC
LIMIT 10;

-- 5.2 Top N分析：天津市理科本科一批录取分最高的前15所高校（2017-2019年平均）
-- 物理意义：分析近三年在天津理科本科一批录取分数最高的名校
SELECT
    u.university_name AS 学校名称,
    u.university_province AS 学校所在省,
    COUNT(*) AS 招生年次,
    ROUND(AVG(f.avg_score), 2) AS 三年平均分,
    ROUND(MIN(f.avg_score), 2) AS 最低分,
    ROUND(MAX(f.avg_score), 2) AS 最高分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
JOIN university_dimension u ON f.university_key = u.university_key
JOIN batch_dimension b ON f.batch_key = b.batch_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE t.year BETWEEN 2017 AND 2019
  AND l.province_name = '天津'
  AND b.batch_name = '本科一批'
  AND c.candidate_type = '理科'
  AND f.avg_score IS NOT NULL
GROUP BY u.university_name, u.university_province
HAVING COUNT(*) >= 2
ORDER BY AVG(f.avg_score) DESC
LIMIT 15;

-- ============================================================
-- 6. Bottom N（后N名）- 排名后N的记录
-- ============================================================

-- 6.1 Bottom N分析：2018-2019年平均录取分最低的10所高校
-- 物理意义：找出近两年录取门槛最低的高校，为低分考生提供参考
SELECT
    u.university_name AS 学校名称,
    u.university_province AS 学校所在省,
    COUNT(*) AS 招生记录数,
    ROUND(AVG(f.avg_score), 2) AS 平均录取分,
    ROUND(MIN(f.avg_score), 2) AS 最低录取分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN university_dimension u ON f.university_key = u.university_key
WHERE t.year BETWEEN 2018 AND 2019
  AND f.avg_score IS NOT NULL
  AND f.avg_score > 0
GROUP BY u.university_name, u.university_province
HAVING COUNT(*) >= 2
ORDER BY AVG(f.avg_score) ASC
LIMIT 10;

-- 6.2 Bottom N分析：青海省本科二批录取分最低的12所高校（2016-2019年）
-- 物理意义：分析青海本科二批录取门槛较低的高校，帮助考生了解保底选择
SELECT
    u.university_name AS 学校名称,
    u.university_province AS 学校所在省,
    c.candidate_type AS 考生类别,
    COUNT(*) AS 招生年次,
    ROUND(AVG(f.avg_score), 2) AS 平均分,
    ROUND(MIN(f.avg_score), 2) AS 最低分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
JOIN university_dimension u ON f.university_key = u.university_key
JOIN batch_dimension b ON f.batch_key = b.batch_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE t.year BETWEEN 2016 AND 2019
  AND l.province_name = '青海'
  AND b.batch_name = '本科二批'
  AND f.avg_score IS NOT NULL
  AND f.avg_score > 0
GROUP BY u.university_name, u.university_province, c.candidate_type
ORDER BY AVG(f.avg_score) ASC
LIMIT 12;

-- ============================================================
-- 7. Tertile（三分位数）- 将数据分为三等份
-- ============================================================

-- 7.1 三分位数分析：2019年三省理科录取分数的三分位分布
-- 物理意义：将2019年理科录取分数分为高、中、低三档，了解分数分布特征
SELECT
    '三分位数分析' AS 分析类型,
    l.province_name AS 省份,
    COUNT(*) AS 总记录数,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.333), 2) AS 第一三分位数,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.667), 2) AS 第二三分位数,
    ROUND(AVG(f.avg_score), 2) AS 平均分,
    ROUND(MIN(f.avg_score), 2) AS 最小值,
    ROUND(MAX(f.avg_score), 2) AS 最大值
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE t.year = 2019
  AND c.candidate_type = '理科'
  AND f.avg_score IS NOT NULL
GROUP BY l.province_name
ORDER BY l.province_name;

-- 7.2 三分位数分析：本科一批各年度录取分数的三分位分布趋势
-- 物理意义：分析2014-2019年本科一批录取分数的三分位变化，观察录取标准演变
SELECT
    t.year AS 年份,
    COUNT(*) AS 总记录数,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.333), 2) AS 低分段_33分位,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.667), 2) AS 高分段_67分位,
    ROUND(AVG(f.avg_score), 2) AS 平均分,
    ROUND(STDDEV(f.avg_score), 2) AS 标准差
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN batch_dimension b ON f.batch_key = b.batch_key
WHERE b.batch_name = '本科一批'
  AND f.avg_score IS NOT NULL
GROUP BY t.year
ORDER BY t.year;

-- ============================================================
-- 8. Quartering（四分位数）- 将数据分为四等份
-- ============================================================

-- 8.1 四分位数分析：2018-2019年三省录取分数的四分位分布
-- 物理意义：通过四分位数分析三省录取分数的离散程度和分布特征
SELECT
    l.province_name AS 省份,
    COUNT(*) AS 总记录数,
    ROUND(MIN(f.avg_score), 2) AS 最小值,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.25), 2) AS Q1_第一四分位数,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.50), 2) AS Q2_中位数,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.75), 2) AS Q3_第三四分位数,
    ROUND(MAX(f.avg_score), 2) AS 最大值,
    ROUND(AVG(f.avg_score), 2) AS 平均分,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.75) -
          PERCENTILE(CAST(f.avg_score AS BIGINT), 0.25), 2) AS 四分位距IQR
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
WHERE t.year BETWEEN 2018 AND 2019
  AND f.avg_score IS NOT NULL
GROUP BY l.province_name
ORDER BY l.province_name;

-- 8.2 四分位数分析：文科vs理科录取分数的四分位对比（2017-2019年）
-- 物理意义：对比文理科录取分数的四分位分布，分析文理科录取难度差异
SELECT
    c.candidate_type AS 考生类别,
    COUNT(*) AS 总记录数,
    ROUND(MIN(f.avg_score), 2) AS 最小值,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.25), 2) AS Q1_25分位,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.50), 2) AS Q2_中位数,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.75), 2) AS Q3_75分位,
    ROUND(MAX(f.avg_score), 2) AS 最大值,
    ROUND(AVG(f.avg_score), 2) AS 平均分
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE t.year BETWEEN 2017 AND 2019
  AND c.candidate_type IN ('文科', '理科')
  AND f.avg_score IS NOT NULL
GROUP BY c.candidate_type
ORDER BY c.candidate_type;

-- ============================================================
-- 分析完成
-- ============================================================
-- 以上共16条HQL语句，涵盖8类OLAP操作：
-- 1. Drill Down（下钻）：2条
-- 2. Roll Up（上卷）：2条
-- 3. Slice（切片）：2条
-- 4. Dice（切块）：2条
-- 5. Top N（前N名）：2条
-- 6. Bottom N（后N名）：2条
-- 7. Tertile（三分位数）：2条
-- 8. Quartering（四分位数）：2条
-- ============================================================

