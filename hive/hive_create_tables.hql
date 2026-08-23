-- ============================================================
-- 高考招生数据仓库 - Hive建表脚本
-- 架构：星型架构（Star Schema）
-- 数据范围：天津、青海、广西三省，2014-2019年
-- ============================================================

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS gaokao_dw
COMMENT '高考招生数据仓库'
LOCATION '/user/hive/warehouse/gaokao_dw.db';

-- 使用数据库
USE gaokao_dw;

-- ============================================================
-- 2. 创建维度表
-- ============================================================

-- 2.1 时间维度表
DROP TABLE IF EXISTS time_dimension;
CREATE TABLE time_dimension (
    time_key INT COMMENT '时间键（年份）',
    year INT COMMENT '年份'
)
COMMENT '时间维度表'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- 2.2 地点维度表
DROP TABLE IF EXISTS location_dimension;
CREATE TABLE location_dimension (
    location_key STRING COMMENT '地点键',
    province_name STRING COMMENT '省份名称'
)
COMMENT '地点维度表（招生地址）'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- 2.3 高校维度表
DROP TABLE IF EXISTS university_dimension;
CREATE TABLE university_dimension (
    university_key STRING COMMENT '高校键',
    university_name STRING COMMENT '学校名称',
    university_province STRING COMMENT '学校所在省份'
)
COMMENT '高校维度表'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- 2.4 录取批次维度表
DROP TABLE IF EXISTS batch_dimension;
CREATE TABLE batch_dimension (
    batch_key STRING COMMENT '批次键',
    batch_name STRING COMMENT '录取批次名称'
)
COMMENT '录取批次维度表'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- 2.5 招生类型维度表
DROP TABLE IF EXISTS admission_type_dimension;
CREATE TABLE admission_type_dimension (
    type_key STRING COMMENT '类型键',
    type_name STRING COMMENT '招生类型名称'
)
COMMENT '招生类型维度表'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- 2.6 考生类别维度表
DROP TABLE IF EXISTS candidate_type_dimension;
CREATE TABLE candidate_type_dimension (
    candidate_key STRING COMMENT '考生类别键',
    candidate_type STRING COMMENT '考生类别'
)
COMMENT '考生类别维度表'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ============================================================
-- 3. 创建事实表
-- ============================================================

-- 3.1 高考招生事实表
DROP TABLE IF EXISTS gaokao_admission_fact;
CREATE TABLE gaokao_admission_fact (
    admission_id BIGINT COMMENT '招生记录ID',
    time_key INT COMMENT '时间维度外键',
    location_key STRING COMMENT '地点维度外键',
    university_key STRING COMMENT '高校维度外键',
    batch_key STRING COMMENT '批次维度外键',
    type_key STRING COMMENT '招生类型维度外键',
    candidate_key STRING COMMENT '考生类别维度外键',
    avg_score FLOAT COMMENT '平均分',
    min_score FLOAT COMMENT '最低分',
    control_score FLOAT COMMENT '省控线'
)
COMMENT '高考招生事实表'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ============================================================
-- 4. 显示所有表
-- ============================================================
SHOW TABLES;

-- ============================================================
-- 5. 查看表结构
-- ============================================================
DESCRIBE FORMATTED time_dimension;
DESCRIBE FORMATTED location_dimension;
DESCRIBE FORMATTED university_dimension;
DESCRIBE FORMATTED batch_dimension;
DESCRIBE FORMATTED admission_type_dimension;
DESCRIBE FORMATTED candidate_type_dimension;
DESCRIBE FORMATTED gaokao_admission_fact;

