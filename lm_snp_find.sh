### 提取显著SNP脚本 ###
## 批量提取显著的SNP，及其chr,pos,碱基对，p值##

#!/bin/bash
task_name=$1

# 生成日志
log_file1="/data/Htz/sample500_genotype/output/lm/${task_name}/1logs/gwas.log"
echo "$(date): 开始显著SNPs提取" >> ${log_file1}
log_file2="/data/Htz/sample500_genotype/output/lm/${task_name}/1logs/top_snp.log"
> $log_file2

# 设置路径
base_dir="/data/Htz/sample500_genotype"
output_dir="/data/Htz/sample500_genotype/output/lm/${task_name}"
output_file="${output_dir}/lm_pca1_5_${task_name}_specific_positions.txt"
cov_file="/data/Htz/sample500_genotype/p/pheno/cov_list.txt"
# 添加snp_count文件路径定义
snp_count_file="${output_dir}/snp_count.txt"
> $snp_count_file
# 清空之前的output_file
> $output_file
while read -r cov; do
    echo "Processing cov: ${cov}" >> $log_file2
    input_file="/data/Htz/sample500_genotype/p/${task_name}/p_list_${cov}.txt"   
    while read -r p_value; do
        echo "$(date): ${p_value}开始SNP位点提取" >> $log_file2  

        p_dir="${output_dir}/${p_value}"
        specific_file="${output_dir}/${p_value}/${p_value}_auto_specific_file.txt"
        assoc_plot_file="${p_dir}/${p_value}_GE_GWAS_lm_${cov}_pca1_5.assoc.plot.txt"
        
        # 获取文件行数作为SNP总数
        total_lines=$(wc -l < "$assoc_plot_file")
        # 将p_value和total_lines写入snp_count.txt文件
        echo -e "${p_value}\t${total_lines}" >> $snp_count_file
        #��ȡpֵ��������
        # 先筛选出满足最严格条件的行并标记**
        awk -v total_lines="$total_lines" '$11 < 0.05/total_lines' $assoc_plot_file | 
        awk ' {print "chr"$2,"chr"$1,$3, $6"/"$7,$11,"**", $12 }' > $specific_file
        # 再筛选出仅满足较宽松条件但不满足最严格条件的行并标记*
        awk -v total_lines="$total_lines" '$11 >= 0.05/total_lines && $11 < 0.1/total_lines' $assoc_plot_file | 
        awk ' {print "chr"$2,"chr"$1,$3, $6"/"$7,$11, "*", $12 }' >> $specific_file
        if [ ! -s "$specific_file" ]; then
            echo "$(date): ${p_value}完成SNP位点提取, 无显著SNP位点" >> $log_file2
            rm "$specific_file"
            else
            awk -v af="${p_value}" '{print af,$0}' $specific_file >> $output_file
            echo "$(date): ${p_value}完成SNP位点提取, 共有$(wc -l < "$specific_file")个显著SNPs位点, 结果储存于$specific_file" >> $log_file2
        fi
    done < "$input_file"
done < "$cov_file"

echo "$(date): 完成显著SNPs提取, 结果保存于$output_file" >> ${log_file1}