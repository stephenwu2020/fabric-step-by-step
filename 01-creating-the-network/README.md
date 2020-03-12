### 定义描述

* crypto-config.yaml 定义了R4的CA
* configtx.yaml 定义了企业R4，网络配置NC4
* docker-compose.yml 定义了O4节点

### 启动网络
1. ./network.sh crypto，生成认证相关的文件
1. ./network.sh genesis，生成系统channel的创世块
1. ./network.sh up，启动网络，启动docker节点o4.demo.com
1. ./network.sh down，关闭节点
1. ./network.sh clear，删除生成认证文件和创世块文件
