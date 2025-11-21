# snp注释脚本

#!/bin/bash

task_name=$1

# 生成日志
log_file="/data/Htz/sample500_genotype/output/lm/${task_name}/1logs/gwas.log"
echo "$(date): 开始基因注释" >> $log_file

# 设置路径
cd /data/Htz/ref/annovar
base_dir="/data/Htz/ref/annovar/result"
# 从输入参数中提取snp_name
snp_name="lm_pca1_5_${task_name}_specific_positions"
snp_file="$base_dir/${snp_name}/$snp_name"

# 提取/data/Htz/sample500_genotype/output/lm/pca1_5/lm_pca1_5_specific_positions_FDR.txt的3,4列
mkdir -p $base_dir/${snp_name}
awk '{print $3,$4}' /data/Htz/sample500_genotype/output/lm/${task_name}/${snp_name}.txt > "${snp_file}.txt"

vcftools --gzvcf /data/Htz/sample500_genotype/All500.merge.vcf.gz --positions ${snp_file}.txt --recode --out ${snp_file}
perl convert2annovar.pl -format vcf4old ${snp_file}.recode.vcf > ${snp_file}.avinput
perl annotate_variation.pl -geneanno -dbtype refGene -out ${snp_file} -build GCF_015476345.1_ZJU1.0_genomic ${snp_file}.avinput ./duckdb/
perl table_annovar.pl  ${snp_file}.avinput duckdb/ -buildver GCF_015476345.1_ZJU1.0_genomic -out ${snp_file} -remove -protocol refGene -operation g -nastring . -csvout
cd /data/Htz/sample500_genotype


echo "$(date): 完成基因注释, 结果保存在$base_dir/${snp_name}/$snp_name.GCF_015476345.1_ZJU1.0_genomic_multianno.csv" >> $log_file