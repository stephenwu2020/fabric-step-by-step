### 文件更改

* crypto-config.yaml 添加了R1和R2的CA
* configtx.yaml 添加了通道配置CC1
* docker-compose.yml 添加了R1的peer和cli
* ./network.sh channeltx 生成创建通道的交易数据
* ./network.sh channel 创建通道，生成通道的创世块

### 执行流程

1. ./network.sh crypto 生成CA
1. ./network.sh genesis 生成系统通道的创世块
1. ./network.sh channeltx 生成通道C1的交易数据
1. ./network.sh up 启动网络
1. ./network.sh channel 创建通道C1，生成通道C1的创世块
1. ./network.sh down 关闭网络
1. ./network.sh clear 清空生成文件