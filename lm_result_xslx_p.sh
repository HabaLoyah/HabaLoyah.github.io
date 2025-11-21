#!/bin/bash

task_name=$1
# 从输入参数中提取snp_name
snp_name="lm_pca1_5_${task_name}_specific_positions"
base_dir="/data/Htz/sample500_genotype/output/lm/${task_name}"
input_file="$base_dir/${snp_name}.txt"

# 生成日志
log_file="/data/Htz/sample500_genotype/output/lm/${task_name}/1logs/gwas.log"
echo "$(date): 开始处理: ${input_file}" >> $log_file

# 1. 处理文件并添加显著性标记
output_file="$base_dir/${snp_name}_annotated.txt"

# 第一步：转换分隔符为逗号
tr -s ' ' ',' < $input_file > $output_file

# 2. 添加Alleles和Near gene列
# 读取annovar结果
anno_dir="/data/Htz/ref/annovar/result/${snp_name}"
anno_file="${anno_dir}/${snp_name}.GCF_015476345.1_ZJU1.0_genomic_multianno.csv"

temp_file="${base_dir}/temp_annotated.txt"
# 创建临时映射文件
awk -F',' 'BEGIN { OFS="\t" } NR==FNR {
  # 去除引号
  gsub(/^"/, "", $6); gsub(/"$/, "", $6);
  gsub(/^"/, "", $7); gsub(/"$/, "", $7);
  # 从_multianno.csv文件读取Alleles(第6列)和Near gene(第7列)
  alleles[$1"_"$2] = $6
  near_gene[$1"_"$2] = $7
  next
} {
  # 匹配主文件数据
  key = $3"_"$4
  if (key in alleles) {
    print $1,$2,$3,$4,$5,alleles[key],near_gene[key],$6,$7;
  } else {
    # 尝试匹配位置偏移±1
    key = $3"_"($4+1)
    if (key in alleles) {
      print $1,$2,$3,$4,$5,alleles[key],near_gene[key],$6,$7;
    } else {
      key = $3"_"($4-1)
      if (key in alleles) {
        print $1,$2,$3,$4,$5,alleles[key],near_gene[key],$6,$7;
      } else {
        print $1,$2,$3,$4,$5,"NA","NA",$6,$7;
      }
    }
  }
}' "$anno_file" "$output_file" > "$temp_file"
rm $output_file

# 安装必要的Python包
#pip install pandas openpyxl

# 添加表头并生成xlsx文件
python3 -c "
import pandas as pd

# 读取临时文件
data = pd.read_csv('$temp_file', sep='\t', header=None)

# 设置表头
headers = ['Phenotype', 'SNP', 'Chromosome', 'Position', 'Alleles', 'Location', 'Near gene', 'P value', 'sig']
df = pd.DataFrame(data)

# 保存为xlsx文件
df.to_excel('$base_dir/${snp_name}_annotated_results.xlsx', index=False, header=headers)
"

# 清理临时文件
rm $temp_file

echo "$(date): 处理完成，结果保存在 ${snp_name}_annotated_results.xlsx" >> $log_file