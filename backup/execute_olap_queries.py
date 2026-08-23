#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
OLAP查询执行脚本 - 使用Pandas执行所有16条OLAP查询
"""

import pandas as pd
import numpy as np
from pathlib import Path
import sys
import io

# 设置输出编码
if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

class OLAPAnalyzer:
    """OLAP分析器"""
    
    def __init__(self, data_dir='hive_data'):
        """初始化并加载所有数据表"""
        self.data_dir = Path(data_dir)
        self.load_tables()
    
    def load_tables(self):
        """加载所有TSV数据文件"""
        print("正在加载数据表...")

        # 加载维度表
        self.time_dim = pd.read_csv(self.data_dir / 'time_dimension.tsv', sep='\t')
        self.location_dim = pd.read_csv(self.data_dir / 'location_dimension.tsv', sep='\t')
        self.university_dim = pd.read_csv(self.data_dir / 'university_dimension.tsv', sep='\t')
        self.batch_dim = pd.read_csv(self.data_dir / 'batch_dimension.tsv', sep='\t')
        self.type_dim = pd.read_csv(self.data_dir / 'admission_type_dimension.tsv', sep='\t')
        self.candidate_dim = pd.read_csv(self.data_dir / 'candidate_type_dimension.tsv', sep='\t')

        # 加载事实表
        self.fact = pd.read_csv(self.data_dir / 'gaokao_admission_fact.tsv', sep='\t')

        print("所有数据表加载完成\n")
    
    def print_header(self, title):
        """打印查询标题"""
        print("=" * 80)
        print(f"  {title}")
        print("=" * 80)
    
    def drill_down_1(self):
        """Drill Down 1: 按年份和省份统计平均分"""
        self.print_header("Drill Down 1: 按年份和省份统计平均分")
        
        result = self.fact.merge(self.time_dim, on='time_key') \
                          .merge(self.location_dim, on='location_key') \
                          .groupby(['year', 'province_name'])['avg_score'].agg(['mean', 'count']) \
                          .round(2)
        print(result)
        print()
    
    def drill_down_2(self):
        """Drill Down 2: 按批次和省份统计招生数"""
        self.print_header("Drill Down 2: 按批次和省份统计招生数")
        
        result = self.fact.merge(self.batch_dim, on='batch_key') \
                          .merge(self.location_dim, on='location_key') \
                          .groupby(['batch_name', 'province_name']).size() \
                          .reset_index(name='count')
        print(result.head(20))
        print(f"... (共{len(result)}行)")
        print()
    
    def roll_up_1(self):
        """Roll Up 1: 按年份统计总体趋势"""
        self.print_header("Roll Up 1: 按年份统计总体趋势")
        
        result = self.fact.merge(self.time_dim, on='time_key') \
                          .groupby('year')['avg_score'].agg(['mean', 'min', 'max', 'count']) \
                          .round(2)
        print(result)
        print()
    
    def roll_up_2(self):
        """Roll Up 2: 按省份统计总体情况"""
        self.print_header("Roll Up 2: 按省份统计总体情况")
        
        result = self.fact.merge(self.location_dim, on='location_key') \
                          .groupby('province_name')['avg_score'].agg(['mean', 'min', 'max', 'count']) \
                          .round(2)
        print(result)
        print()
    
    def slice_1(self):
        """Slice 1: 只查看2019年的数据"""
        self.print_header("Slice 1: 2019年招生统计")
        
        result = self.fact.merge(self.time_dim, on='time_key') \
                          .query('year == 2019') \
                          .merge(self.location_dim, on='location_key') \
                          .groupby('province_name')['avg_score'].agg(['mean', 'count']) \
                          .round(2)
        print(result)
        print()
    
    def slice_2(self):
        """Slice 2: 只查看天津的数据"""
        self.print_header("Slice 2: 天津招生统计")
        
        result = self.fact.merge(self.location_dim, on='location_key') \
                          .query('province_name == "天津"') \
                          .merge(self.time_dim, on='time_key') \
                          .groupby('year')['avg_score'].agg(['mean', 'count']) \
                          .round(2)
        print(result)
        print()
    
    def dice_1(self):
        """Dice 1: 2017-2019年天津/青海理科本科批次"""
        self.print_header("Dice 1: 2017-2019年天津/青海理科本科批次")

        result = self.fact.merge(self.time_dim, on='time_key') \
                          .merge(self.location_dim, on='location_key') \
                          .merge(self.batch_dim, on='batch_key') \
                          .merge(self.candidate_dim, on='candidate_key') \
                          .query('year >= 2017 and year <= 2019 and province_name in ["天津", "青海"] and batch_name == "本科一批" and candidate_type == "理科"') \
                          .groupby(['year', 'province_name'])['avg_score'].agg(['mean', 'count']) \
                          .round(2)
        print(result)
        print()
    
    def dice_2(self):
        """Dice 2: 2018-2019年广西本科批次文理科"""
        self.print_header("Dice 2: 2018-2019年广西本科批次文理科")

        result = self.fact.merge(self.time_dim, on='time_key') \
                          .merge(self.location_dim, on='location_key') \
                          .merge(self.batch_dim, on='batch_key') \
                          .merge(self.candidate_dim, on='candidate_key') \
                          .query('year >= 2018 and year <= 2019 and province_name == "广西" and batch_name == "本科一批"') \
                          .groupby(['year', 'candidate_type'])['avg_score'].agg(['mean', 'count']) \
                          .round(2)
        print(result)
        print()
    
    def top_n_1(self):
        """Top N 1: 2019年平均分最高的10所高校"""
        self.print_header("Top N 1: 2019年平均分最高的10所高校")
        
        result = self.fact.merge(self.time_dim, on='time_key') \
                          .merge(self.university_dim, on='university_key') \
                          .query('year == 2019') \
                          .groupby('university_name')['avg_score'].mean() \
                          .nlargest(10) \
                          .round(2)
        print(result)
        print()
    
    def top_n_2(self):
        """Top N 2: 天津理科本科一批2017-2019年平均分最高的15所高校"""
        self.print_header("Top N 2: 天津理科本科一批2017-2019年平均分最高的15所高校")

        result = self.fact.merge(self.time_dim, on='time_key') \
                          .merge(self.location_dim, on='location_key') \
                          .merge(self.batch_dim, on='batch_key') \
                          .merge(self.candidate_dim, on='candidate_key') \
                          .merge(self.university_dim, on='university_key') \
                          .query('year >= 2017 and year <= 2019 and province_name == "天津" and batch_name == "本科一批" and candidate_type == "理科"') \
                          .groupby('university_name')['avg_score'].mean() \
                          .nlargest(15) \
                          .round(2)
        print(result)
        print()
    
    def bottom_n_1(self):
        """Bottom N 1: 2018-2019年平均分最低的10所高校"""
        self.print_header("Bottom N 1: 2018-2019年平均分最低的10所高校")
        
        result = self.fact.merge(self.time_dim, on='time_key') \
                          .merge(self.university_dim, on='university_key') \
                          .query('year >= 2018 and year <= 2019') \
                          .groupby('university_name')['avg_score'].mean() \
                          .nsmallest(10) \
                          .round(2)
        print(result)
        print()
    
    def bottom_n_2(self):
        """Bottom N 2: 青海本科二批2016-2019年平均分最低的12所高校"""
        self.print_header("Bottom N 2: 青海本科二批2016-2019年平均分最低的12所高校")
        
        result = self.fact.merge(self.time_dim, on='time_key') \
                          .merge(self.location_dim, on='location_key') \
                          .merge(self.batch_dim, on='batch_key') \
                          .merge(self.university_dim, on='university_key') \
                          .query('year >= 2016 and year <= 2019 and province_name == "青海" and batch_name == "本科二批"') \
                          .groupby('university_name')['avg_score'].mean() \
                          .nsmallest(12) \
                          .round(2)
        print(result)
        print()
    
    def tertile_1(self):
        """Tertile 1: 2018年理科分数三分位数按省份分布"""
        self.print_header("Tertile 1: 2018年理科分数三分位数按省份分布")

        data = self.fact.merge(self.time_dim, on='time_key') \
                        .merge(self.location_dim, on='location_key') \
                        .merge(self.candidate_dim, on='candidate_key') \
                        .query('year == 2018 and candidate_type == "理科"')

        result = data.groupby('province_name')['avg_score'].apply(
            lambda x: pd.Series({
                '33.3%分位': np.percentile(x.dropna(), 33.3) if len(x.dropna()) > 0 else np.nan,
                '66.7%分位': np.percentile(x.dropna(), 66.7) if len(x.dropna()) > 0 else np.nan,
                '平均分': x.mean()
            })
        ).round(2)
        print(result)
        print()
    
    def tertile_2(self):
        """Tertile 2: 本科一批分数三分位数按年份分布"""
        self.print_header("Tertile 2: 本科一批分数三分位数按年份分布")

        data = self.fact.merge(self.time_dim, on='time_key') \
                        .merge(self.batch_dim, on='batch_key') \
                        .query('batch_name == "本科一批"')

        result = data.groupby('year')['avg_score'].apply(
            lambda x: pd.Series({
                '33.3%分位': np.percentile(x.dropna(), 33.3) if len(x.dropna()) > 0 else np.nan,
                '66.7%分位': np.percentile(x.dropna(), 66.7) if len(x.dropna()) > 0 else np.nan,
                '平均分': x.mean()
            })
        ).round(2)
        print(result)
        print()
    
    def quartile_1(self):
        """Quartile 1: 2017-2018年分数四分位数按省份分布"""
        self.print_header("Quartile 1: 2017-2018年分数四分位数按省份分布")

        data = self.fact.merge(self.time_dim, on='time_key') \
                        .merge(self.location_dim, on='location_key') \
                        .query('year >= 2017 and year <= 2018')

        result = data.groupby('province_name')['avg_score'].apply(
            lambda x: pd.Series({
                'Q1(25%)': np.percentile(x.dropna(), 25) if len(x.dropna()) > 0 else np.nan,
                'Q2(50%)': np.percentile(x.dropna(), 50) if len(x.dropna()) > 0 else np.nan,
                'Q3(75%)': np.percentile(x.dropna(), 75) if len(x.dropna()) > 0 else np.nan,
                'IQR': (np.percentile(x.dropna(), 75) - np.percentile(x.dropna(), 25)) if len(x.dropna()) > 0 else np.nan
            })
        ).round(2)
        print(result)
        print()
    
    def quartile_2(self):
        """Quartile 2: 文科vs理科四分位数对比2017-2018"""
        self.print_header("Quartile 2: 文科vs理科四分位数对比2017-2018")

        data = self.fact.merge(self.time_dim, on='time_key') \
                        .merge(self.candidate_dim, on='candidate_key') \
                        .query('year >= 2017 and year <= 2018')

        result = data.groupby('candidate_type')['avg_score'].apply(
            lambda x: pd.Series({
                'Q1(25%)': np.percentile(x.dropna(), 25) if len(x.dropna()) > 0 else np.nan,
                'Q2(50%)': np.percentile(x.dropna(), 50) if len(x.dropna()) > 0 else np.nan,
                'Q3(75%)': np.percentile(x.dropna(), 75) if len(x.dropna()) > 0 else np.nan,
                'IQR': (np.percentile(x.dropna(), 75) - np.percentile(x.dropna(), 25)) if len(x.dropna()) > 0 else np.nan
            })
        ).round(2)
        print(result)
        print()
    
    def run_all_queries(self):
        """执行所有16条OLAP查询"""
        print("\n")
        print("=" * 80)
        print("高考招生数据OLAP分析 - 16条查询")
        print("=" * 80)
        print("\n")
        
        # Drill Down
        print("\n【Drill Down - 下钻】\n")
        self.drill_down_1()
        self.drill_down_2()
        
        # Roll Up
        print("\n【Roll Up - 上卷】\n")
        self.roll_up_1()
        self.roll_up_2()
        
        # Slice
        print("\n【Slice - 切片】\n")
        self.slice_1()
        self.slice_2()
        
        # Dice
        print("\n【Dice - 切块】\n")
        self.dice_1()
        self.dice_2()
        
        # Top N
        print("\n【Top N - 前N名】\n")
        self.top_n_1()
        self.top_n_2()
        
        # Bottom N
        print("\n【Bottom N - 后N名】\n")
        self.bottom_n_1()
        self.bottom_n_2()
        
        # Tertile
        print("\n【Tertile - 三分位数】\n")
        self.tertile_1()
        self.tertile_2()
        
        # Quartile
        print("\n【Quartile - 四分位数】\n")
        self.quartile_1()
        self.quartile_2()
        
        print("\n" + "=" * 80)
        print("✓ 所有16条OLAP查询执行完成！")
        print("=" * 80 + "\n")

if __name__ == '__main__':
    analyzer = OLAPAnalyzer()
    analyzer.run_all_queries()

