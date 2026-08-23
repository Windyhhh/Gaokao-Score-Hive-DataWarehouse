#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Hive模拟器 - 使用Pandas执行OLAP查询
用于在没有Hive环境的情况下测试HQL查询
"""

import pandas as pd
import numpy as np
from pathlib import Path

class HiveSimulator:
    """模拟Hive数据仓库的Python类"""
    
    def __init__(self, data_dir='hive_data'):
        """初始化Hive模拟器，加载所有维度表和事实表"""
        self.data_dir = Path(data_dir)
        self.tables = {}
        self.load_tables()
    
    def load_tables(self):
        """加载所有TSV数据文件"""
        print("正在加载Hive数据表...")
        
        # 加载维度表
        self.tables['time_dimension'] = pd.read_csv(
            self.data_dir / 'time_dimension.tsv', sep='\t'
        )
        self.tables['location_dimension'] = pd.read_csv(
            self.data_dir / 'location_dimension.tsv', sep='\t'
        )
        self.tables['university_dimension'] = pd.read_csv(
            self.data_dir / 'university_dimension.tsv', sep='\t'
        )
        self.tables['batch_dimension'] = pd.read_csv(
            self.data_dir / 'batch_dimension.tsv', sep='\t'
        )
        self.tables['admission_type_dimension'] = pd.read_csv(
            self.data_dir / 'admission_type_dimension.tsv', sep='\t'
        )
        self.tables['candidate_type_dimension'] = pd.read_csv(
            self.data_dir / 'candidate_type_dimension.tsv', sep='\t'
        )
        
        # 加载事实表
        self.tables['gaokao_admission_fact'] = pd.read_csv(
            self.data_dir / 'gaokao_admission_fact.tsv', sep='\t'
        )
        
        print("✓ 所有数据表加载完成")
        self.print_table_stats()
    
    def print_table_stats(self):
        """打印表统计信息"""
        print("\n数据表统计:")
        print("=" * 60)
        for table_name, df in self.tables.items():
            print(f"{table_name:30s}: {len(df):6d} 行")
        print("=" * 60)
    
    def query(self, sql):
        """执行SQL查询（简化版）"""
        # 这是一个简化的实现，实际使用时可以使用pandasql库
        print(f"\n执行查询: {sql[:80]}...")
        # 返回示例结果
        return None
    
    def get_table(self, table_name):
        """获取表数据"""
        return self.tables.get(table_name)
    
    def show_tables(self):
        """显示所有表"""
        print("\n可用的表:")
        for table_name in self.tables.keys():
            print(f"  - {table_name}")

if __name__ == '__main__':
    # 初始化Hive模拟器
    hive = HiveSimulator()
    
    # 显示可用的表
    hive.show_tables()
    
    # 示例查询
    print("\n" + "=" * 60)
    print("示例查询1: 查看事实表前5行")
    print("=" * 60)
    fact_table = hive.get_table('gaokao_admission_fact')
    print(fact_table.head())
    
    print("\n" + "=" * 60)
    print("示例查询2: 按年份统计招生记录数")
    print("=" * 60)
    time_dim = hive.get_table('time_dimension')
    fact = hive.get_table('gaokao_admission_fact')
    result = fact.merge(time_dim, on='time_key').groupby('year').size()
    print(result)
    
    print("\n" + "=" * 60)
    print("示例查询3: 按省份统计招生记录数")
    print("=" * 60)
    loc_dim = hive.get_table('location_dimension')
    result = fact.merge(loc_dim, on='location_key').groupby('province_name').size()
    print(result)

