#!/bin/bash
task_name=$1
set -e

# 设置路径
base_dir="/data/Htz/sample500_genotype/cov/pca1_5/lm/p"
# 进行GWAS
#$base_dir/gemma_for_list.sh ${task_name}
echo "GWAS分析完成"
# 进行显著SNP提取
$base_dir/lm_snp_find.sh ${task_name}
# 基因注释
source ~/miniconda3/bin/activate gwas && $base_dir/lm_annoar_p.sh ${task_name}
echo "基因注释完成"
# 总结成表
source ~/miniconda3/bin/activate r_443 && $base_dir/lm_result_xslx_p.sh ${task_name}
echo "结果总结完成"
# 曼哈顿图绘制
#$base_dir/mahatton_paint.sh ${task_name}
echo "曼哈顿图绘制完成"
# 进行小提琴图绘制 以及基因型-表型对对应关系汇总、平均数±标准差统计。
## top SNPs位点提取
$base_dir/volin/volin_min_p_snps_file.sh ${task_name}
echo "小提琴图绘制完成"