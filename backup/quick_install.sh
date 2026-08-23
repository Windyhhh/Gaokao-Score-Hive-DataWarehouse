#!/bin/bash

# 快速安装脚本 - 使用本地模式Hive（不需要Hadoop）

set -e

echo "============================================================"
echo "Hive本地模式快速安装"
echo "============================================================"

INSTALL_DIR="$HOME/hive_local"
HIVE_VERSION="3.1.3"
HIVE_HOME="$INSTALL_DIR/apache-hive-$HIVE_VERSION-bin"

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# 1. 安装Java
echo "步骤1: 检查Java环境"
if ! command -v java &> /dev/null; then
    echo "安装Java 8..."
    sudo apt-get update -qq
    sudo apt-get install -y openjdk-8-jdk wget
fi
java -version

# 2. 下载Hive
echo ""
echo "步骤2: 下载Hive $HIVE_VERSION"
if [ ! -d "$HIVE_HOME" ]; then
    if [ ! -f "apache-hive-$HIVE_VERSION-bin.tar.gz" ]; then
        echo "下载Hive..."
        wget -q --show-progress https://dlcdn.apache.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
    fi
    echo "解压Hive..."
    tar -xzf apache-hive-$HIVE_VERSION-bin.tar.gz
fi

# 3. 配置环境变量
echo ""
echo "步骤3: 配置环境变量"
grep -q "HIVE_HOME" ~/.bashrc || cat >> ~/.bashrc << EOF

# Hive Environment
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HIVE_HOME=$HIVE_HOME
export PATH=\$PATH:\$HIVE_HOME/bin
EOF

source ~/.bashrc

# 4. 配置Hive（本地模式）
echo ""
echo "步骤4: 配置Hive本地模式"
mkdir -p $HIVE_HOME/conf

cat > $HIVE_HOME/conf/hive-site.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/tmp/hive_warehouse</value>
    </property>
    <property>
        <name>hive.exec.local.scratchdir</name>
        <value>/tmp/hive_scratch</value>
    </property>
    <property>
        <name>hive.downloaded.resources.dir</name>
        <value>/tmp/hive_resources</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:derby:;databaseName=/tmp/metastore_db;create=true</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.apache.derby.jdbc.EmbeddedDriver</value>
    </property>
    <property>
        <name>hive.execution.engine</name>
        <value>mr</value>
    </property>
</configuration>
EOF

# 创建必要的目录
mkdir -p /tmp/hive_warehouse /tmp/hive_scratch /tmp/hive_resources
chmod 777 /tmp/hive_warehouse /tmp/hive_scratch /tmp/hive_resources

# 5. 初始化元数据
echo ""
echo "步骤5: 初始化Hive元数据"
cd /tmp
$HIVE_HOME/bin/schematool -dbType derby -initSchema

echo ""
echo "============================================================"
echo "安装完成！"
echo "============================================================"
echo "Hive安装路径: $HIVE_HOME"
echo ""
echo "使用方法:"
echo "  source ~/.bashrc"
echo "  hive"
echo "============================================================"

