-- ============================================================
-- 高考招生数据仓库 - Hive数据加载脚本
-- 说明：将处理好的TSV文件加载到Hive表中
-- 注意：请根据实际文件路径修改LOCAL INPATH
-- ============================================================

-- 使用数据库
USE gaokao_dw;

-- ============================================================
-- 1. 加载维度表数据
-- ============================================================

-- 1.1 加载时间维度数据
LOAD DATA LOCAL INPATH '/mnt/c/Users/32517/Desktop/400/hive_data/time_dimension.tsv'
OVERWRITE INTO TABLE time_dimension;

-- 1.2 加载地点维度数据
LOAD DATA LOCAL INPATH '/mnt/c/Users/32517/Desktop/400/hive_data/location_dimension.tsv'
OVERWRITE INTO TABLE location_dimension;

-- 1.3 加载高校维度数据
LOAD DATA LOCAL INPATH '/mnt/c/Users/32517/Desktop/400/hive_data/university_dimension.tsv'
OVERWRITE INTO TABLE university_dimension;

-- 1.4 加载录取批次维度数据
LOAD DATA LOCAL INPATH '/mnt/c/Users/32517/Desktop/400/hive_data/batch_dimension.tsv'
OVERWRITE INTO TABLE batch_dimension;

-- 1.5 加载招生类型维度数据
LOAD DATA LOCAL INPATH '/mnt/c/Users/32517/Desktop/400/hive_data/admission_type_dimension.tsv'
OVERWRITE INTO TABLE admission_type_dimension;

-- 1.6 加载考生类别维度数据
LOAD DATA LOCAL INPATH '/mnt/c/Users/32517/Desktop/400/hive_data/candidate_type_dimension.tsv'
OVERWRITE INTO TABLE candidate_type_dimension;

-- ============================================================
-- 2. 加载事实表数据
-- ============================================================

-- 2.1 加载高考招生事实数据
LOAD DATA LOCAL INPATH '/mnt/c/Users/32517/Desktop/400/hive_data/gaokao_admission_fact.tsv'
OVERWRITE INTO TABLE gaokao_admission_fact;

-- ============================================================
-- 3. 验证数据加载
-- ============================================================

-- 3.1 查看各表记录数
SELECT '时间维度表' as table_name, COUNT(*) as record_count FROM time_dimension
UNION ALL
SELECT '地点维度表' as table_name, COUNT(*) as record_count FROM location_dimension
UNION ALL
SELECT '高校维度表' as table_name, COUNT(*) as record_count FROM university_dimension
UNION ALL
SELECT '批次维度表' as table_name, COUNT(*) as record_count FROM batch_dimension
UNION ALL
SELECT '招生类型维度表' as table_name, COUNT(*) as record_count FROM admission_type_dimension
UNION ALL
SELECT '考生类别维度表' as table_name, COUNT(*) as record_count FROM candidate_type_dimension
UNION ALL
SELECT '事实表' as table_name, COUNT(*) as record_count FROM gaokao_admission_fact;

-- 3.2 查看时间维度数据
SELECT * FROM time_dimension ORDER BY time_key;

-- 3.3 查看地点维度数据
SELECT * FROM location_dimension ORDER BY location_key;

-- 3.4 查看批次维度数据（前10条）
SELECT * FROM batch_dimension LIMIT 10;

-- 3.5 查看事实表数据（前10条）
SELECT * FROM gaokao_admission_fact LIMIT 10;

-- 3.6 验证数据完整性 - 检查外键关联
SELECT 
    '事实表总记录数' as check_item,
    COUNT(*) as count
FROM gaokao_admission_fact
UNION ALL
SELECT 
    '有效时间键记录数' as check_item,
    COUNT(*) as count
FROM gaokao_admission_fact f
INNER JOIN time_dimension t ON f.time_key = t.time_key
UNION ALL
SELECT 
    '有效地点键记录数' as check_item,
    COUNT(*) as count
FROM gaokao_admission_fact f
INNER JOIN location_dimension l ON f.location_key = l.location_key;

-- ============================================================
-- 4. 数据统计分析
-- ============================================================

-- 4.1 按年份统计招生记录数
SELECT 
    t.year as 年份,
    COUNT(*) as 招生记录数
FROM gaokao_admission_fact f
JOIN time_dimension t ON f.time_key = t.time_key
GROUP BY t.year
ORDER BY t.year;

-- 4.2 按省份统计招生记录数
SELECT 
    l.province_name as 省份,
    COUNT(*) as 招生记录数
FROM gaokao_admission_fact f
JOIN location_dimension l ON f.location_key = l.location_key
GROUP BY l.province_name
ORDER BY COUNT(*) DESC;

-- 4.3 按录取批次统计招生记录数
SELECT 
    b.batch_name as 录取批次,
    COUNT(*) as 招生记录数
FROM gaokao_admission_fact f
JOIN batch_dimension b ON f.batch_key = b.batch_key
GROUP BY b.batch_name
ORDER BY COUNT(*) DESC;

-- 4.4 按考生类别统计平均分
SELECT 
    c.candidate_type as 考生类别,
    COUNT(*) as 记录数,
    ROUND(AVG(f.avg_score), 2) as 平均分,
    ROUND(MIN(f.avg_score), 2) as 最低分,
    ROUND(MAX(f.avg_score), 2) as 最高分
FROM gaokao_admission_fact f
JOIN candidate_type_dimension c ON f.candidate_key = c.candidate_key
WHERE f.avg_score IS NOT NULL
GROUP BY c.candidate_type
ORDER BY AVG(f.avg_score) DESC;

-- 数据加载完成！

