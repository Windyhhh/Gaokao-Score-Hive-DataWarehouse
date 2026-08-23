-- ============================================================
-- 高考招生数据仓库 - OLAP分析脚本（修复版）
-- 包含8类OLAP操作，每类2条HQL语句，共16条
-- 数据范围：天津、青海、广西三省，2014-2019年
-- ============================================================

USE gaokao_dw;

-- ============================================================
-- 1. Drill Down（下钻）- 从粗粒度到细粒度
-- ============================================================

-- 1.1 下钻分析：从年度总体平均分下钻到各省份各年度的平均分
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
SELECT 
    t.year year,
    COUNT(DISTINCT f.university_key) university_count,
    COUNT(*) total_records,
    ROUND(AVG(f.avg_score), 2) overall_avg_score,
    ROUND(AVG(f.min_score), 2) overall_min_score
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
WHERE f.avg_score IS NOT NULL
GROUP BY t.year
ORDER BY t.year;

-- 2.2 上卷分析：从各高校在各省的详细数据上卷到省份层面
SELECT 
    l.province_name province,
    COUNT(DISTINCT f.university_key) university_count,
    COUNT(DISTINCT f.batch_key) batch_count,
    COUNT(*) total_records,
    ROUND(AVG(f.avg_score), 2) avg_admission_score,
    ROUND(AVG(f.control_score), 2) avg_control_score
FROM gaokao_admission_fact f
JOIN location_dimension l ON f.location_key = l.location_key
WHERE f.avg_score IS NOT NULL
GROUP BY l.province_name
ORDER BY COUNT(*) DESC;

-- ============================================================
-- 3. Slice（切片）- 在某一维度上选择特定值
-- ============================================================

-- 3.1 切片分析：只看2019年的招生数据
SELECT 
    l.province_name province,
    b.batch_name batch,
    c.candidate_type candidate_type,
    COUNT(*) record_count,
    ROUND(AVG(f.avg_score), 2) avg_score
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
SELECT 
    t.year year,
    b.batch_name batch,
    c.candidate_type candidate_type,
    COUNT(*) record_count,
    ROUND(AVG(f.avg_score), 2) avg_score,
    ROUND(MIN(f.avg_score), 2) min_score,
    ROUND(MAX(f.avg_score), 2) max_score
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
SELECT
    t.year year,
    l.province_name province,
    b.batch_name batch,
    COUNT(*) record_count,
    ROUND(AVG(f.avg_score), 2) avg_score,
    ROUND(AVG(f.control_score), 2) avg_control_score,
    ROUND(AVG(f.avg_score) - AVG(f.control_score), 2) score_above_control
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
SELECT
    t.year year,
    b.batch_name batch,
    c.candidate_type candidate_type,
    COUNT(*) record_count,
    ROUND(AVG(f.avg_score), 2) avg_score,
    ROUND(MIN(f.avg_score), 2) min_score,
    ROUND(MAX(f.avg_score), 2) max_score
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
SELECT
    u.university_name university,
    u.university_province province,
    COUNT(*) record_count,
    ROUND(AVG(f.avg_score), 2) avg_admission_score,
    ROUND(MIN(f.avg_score), 2) min_admission_score,
    ROUND(MAX(f.avg_score), 2) max_admission_score
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN university_dimension u ON f.university_key = u.university_key
WHERE t.year = 2019 AND f.avg_score IS NOT NULL
GROUP BY u.university_name, u.university_province
ORDER BY AVG(f.avg_score) DESC
LIMIT 10;

-- 5.2 Top N分析：天津市理科本科一批录取分最高的前15所高校（2017-2019年平均）
SELECT
    u.university_name university,
    u.university_province province,
    COUNT(*) year_count,
    ROUND(AVG(f.avg_score), 2) three_year_avg_score,
    ROUND(MIN(f.avg_score), 2) min_score,
    ROUND(MAX(f.avg_score), 2) max_score
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
SELECT
    u.university_name university,
    u.university_province province,
    COUNT(*) record_count,
    ROUND(AVG(f.avg_score), 2) avg_admission_score,
    ROUND(MIN(f.avg_score), 2) min_admission_score
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
SELECT
    u.university_name university,
    u.university_province province,
    c.candidate_type candidate_type,
    COUNT(*) year_count,
    ROUND(AVG(f.avg_score), 2) avg_score,
    ROUND(MIN(f.avg_score), 2) min_score
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
SELECT
    'Tertile Analysis' analysis_type,
    l.province_name province,
    COUNT(*) total_records,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.333), 2) tertile_1,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.667), 2) tertile_2,
    ROUND(AVG(f.avg_score), 2) avg_score,
    ROUND(MIN(f.avg_score), 2) min_value,
    ROUND(MAX(f.avg_score), 2) max_value
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
SELECT
    t.year year,
    COUNT(*) total_records,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.333), 2) tertile_33,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.667), 2) tertile_67,
    ROUND(AVG(f.avg_score), 2) avg_score,
    ROUND(STDDEV(f.avg_score), 2) stddev
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
SELECT
    l.province_name province,
    COUNT(*) total_records,
    ROUND(MIN(f.avg_score), 2) min_value,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.25), 2) q1,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.50), 2) q2_median,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.75), 2) q3,
    ROUND(MAX(f.avg_score), 2) max_value,
    ROUND(AVG(f.avg_score), 2) avg_score,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.75) -
          PERCENTILE(CAST(f.avg_score AS BIGINT), 0.25), 2) iqr
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
JOIN location_dimension l ON f.location_key = l.location_key
WHERE t.year BETWEEN 2018 AND 2019
  AND f.avg_score IS NOT NULL
GROUP BY l.province_name
ORDER BY l.province_name;

-- 8.2 四分位数分析：文科vs理科录取分数的四分位对比（2017-2019年）
SELECT
    c.candidate_type candidate_type,
    COUNT(*) total_records,
    ROUND(MIN(f.avg_score), 2) min_value,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.25), 2) q1,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.50), 2) q2_median,
    ROUND(PERCENTILE(CAST(f.avg_score AS BIGINT), 0.75), 2) q3,
    ROUND(MAX(f.avg_score), 2) max_value,
    ROUND(AVG(f.avg_score), 2) avg_score
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

