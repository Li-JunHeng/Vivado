#!/bin/bash

# Vivado 项目压缩脚本 (Mac)
# 使用方法: ./compress.sh <源文件/文件夹> [输出文件名]

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查参数
if [ $# -lt 1 ]; then
    echo -e "${RED}错误: 缺少参数${NC}"
    echo "使用方法: $0 <源文件/文件夹路径> [输出文件名]"
    echo "示例: $0 Vivado_Learning"
    echo "示例: $0 Vivado_Learning my_project.zip"
    exit 1
fi

SOURCE="$1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 检查源文件/文件夹是否存在
if [ ! -e "$SOURCE" ]; then
    echo -e "${RED}错误: 源路径不存在: $SOURCE${NC}"
    exit 1
fi

# 确定输出文件名
if [ $# -eq 2 ]; then
    OUTPUT="$2"
else
    # 获取源文件/文件夹的基本名称
    BASENAME=$(basename "$SOURCE")
    OUTPUT="${BASENAME}_${TIMESTAMP}.zip"
fi

# 如果输出文件名没有 .zip 扩展名，则添加
if [[ ! "$OUTPUT" =~ \.zip$ ]]; then
    OUTPUT="${OUTPUT}.zip"
fi

echo -e "${YELLOW}开始压缩...${NC}"
echo "源路径: $SOURCE"
echo "目标文件: $OUTPUT"
echo ""

# 使用 zip 命令压缩
# -r: 递归压缩文件夹
# -q: 静默模式
# -9: 最大压缩率
# -x: 排除某些文件
if [ -d "$SOURCE" ]; then
    # 如果是文件夹，排除一些不必要的文件
    zip -r -9 "$OUTPUT" "$SOURCE" \
        -x "*.DS_Store" \
        -x "*/__pycache__/*" \
        -x "*/node_modules/*" \
        -x "*/.git/*" \
        -x "*.backup.*" \
        2>&1 | while read line; do
        echo -ne "${GREEN}.${NC}"
    done
else
    # 如果是单个文件
    zip -9 "$OUTPUT" "$SOURCE"
fi

echo ""

# 检查压缩是否成功
if [ $? -eq 0 ]; then
    FILE_SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
    echo -e "${GREEN}✓ 压缩完成!${NC}"
    echo "输出文件: $OUTPUT"
    echo "文件大小: $FILE_SIZE"
else
    echo -e "${RED}✗ 压缩失败!${NC}"
    exit 1
fi

