### 汇总所有topsnp脚本 ###
## 作者：韩涛泽

#!/bin/bash

# 设置路径变量
input_file="/data/Htz/sample500_genotype/p/topsnp_FDR_list.txt"
base_dir="/data/Htz/sample500_genotype/output"
output_dir="/data/Htz/sample500_genotype/output"
# 设置日志变量
log_file="${output_dir}/no_topsnp_1.log"

# 遍历 topsnp_list.txt 中的每个 SNP
while read -r p_value; do
    # 设置文件路径变量
    p_dir="${base_dir}/${p_value}"
    specific_file="${p_dir}/${p_value}.specific_position.txt"
    assoc_plot_file="${p_dir}/${p_value}_GE_GWAS.assoc.plot.txt"
    output_file="${output_dir}/specific_positions.txt"

    # 检查 specific_position.txt 是否存在
    if stat "$specific_file" >/dev/null 2>&1; then
        # 将 p_value 输出到 temp1.txt
        awk -v af="$p_value" '{print af}' "$specific_file" > temp1.txt
        
        # 筛选出满足条件的列，使用制表符分隔
        awk '$12 < (1/21283462) {print $5"/"$6}' "$assoc_plot_file" | paste -d ' ' temp1.txt - > temp2.txt
        
        # 合并 snp 位置信息并以制表符分隔
        awk '{print $0}' "$specific_file" | paste -d ' ' temp2.txt - >> "$output_file"
        
        # 清理临时文件
        rm -f temp1.txt temp2.txt
    else 
        # 如果 specific_position.txt 文件不存在，记录 p_value 到日志文件
        echo "$p_value" >> "$log_file"
    fi
done < "$input_file"