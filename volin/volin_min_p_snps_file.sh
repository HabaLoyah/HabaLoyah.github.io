#!/bin/bash

# 功能：根据表型文件，提取每个表型每个染色体中最小p值的SNP位点
# 统计：不同基因型对应的个体数目、表型平均数±标准差
# 备注：得出的最小位点，需另外检查一遍，防止找出的最小值位点实际上是”假阳性“位点。/
    # 如果是”假阳性“，则最好手动添加对应位的。该脚本只为了辅助，更快速的筛出所需位点，无法一步到位。
# 作者：韩涛泽

# 参数检查
task_name=$1
input_file="/data/Htz/sample500_genotype/p/${task_name}/p_volin.txt"

# 定义路径
base_dir="/data/Htz/sample500_genotype/output/lm/${task_name}"
# 定义Excel文件路径
excel_file="${base_dir}/lm_pca1_5_${task_name}_specific_positions_annotated_results.xlsx"
# 读取输入文件并处理每一行
while read -r p_value; do
    echo "开始处理${p_value}"
    output_base="${base_dir}/${p_value}/volin"
    mkdir -p ${output_base}
    p_file="/data/Htz/sample500_genotype/p/${task_name}/${p_value}.txt"
    # 假设这是包含所有SNP及其p值的文件
    # 所有的显著SNP位点集
    snp_pvalue_file="/data/Htz/sample500_genotype/output/lm/${task_name}/${p_value}/${p_value}_auto_specific_file.txt"
    # 提取每个染色体中最小p值的SNP位点
    ## 我们需要按染色体分组，找出每组中p值最小的记录
    min_p_snps_file="${output_base}/min_p_snps_per_chrom.txt"
    ## 清空原本的min_p_snps_file
    > ${min_p_snps_file}
    ## 提取最小p值的SNP位点
    awk '{
        if (!min_p[$2] || $5 < min_p[$2]) {
            min_p[$2] = $5
            min_snp[$2] = $1
            min_pos[$2] = $3
        }
    }
    END {
        for (chr in min_p) {
            print chr "\t" min_pos[chr] "\t" min_snp[chr] "\t" min_p[chr]
        }
    }' "$snp_pvalue_file" > "$min_p_snps_file"
    echo "提取完成，结果保存在 $min_p_snps_file"

    # 直接从Excel文件中查找min_p_snps_file里的SNP对应的Gene并添加到文件中
python3 -c "
import pandas as pd, os

excel_file = r'''$excel_file'''
min_p_snps_file = r'''$min_p_snps_file'''
pheno= r'''$p_value'''
temp_file = min_p_snps_file + '.tmp'
temp_file2 = min_p_snps_file + '.tmp2'

# 读Excel
df = pd.read_excel(excel_file, engine='openpyxl')
# 列索引：0-第一列(phenotype), 1-第二列(SNP), 6-第七列(Gene)
pheno_col, snp_col, gene_col = 0, 1, 6

# 创建复合键字典 (pheno, snp) -> gene
pheno_snp_to_gene = {}

# 遍历Excel数据，构建复合键字典
for _, r in df.iterrows():
    if pd.notna(r.iloc[snp_col]) and pd.notna(r.iloc[gene_col]) and pd.notna(r.iloc[pheno_col]):
        excel_pheno = str(r.iloc[pheno_col]).strip()
        snp = str(r.iloc[snp_col]).strip()
        gene = str(r.iloc[gene_col]).strip()
        pheno_snp_to_gene[(excel_pheno, snp)] = gene

with open(min_p_snps_file) as fin, open(temp_file, 'w') as fout:
    for line in fin:
        parts = line.strip().split('\t')
        if len(parts) >= 3:
            snp = parts[2]
            # 只使用pheno和snp的复合键查找
            gene = pheno_snp_to_gene.get((pheno, snp), '')
            # 如果找不到，报错并终止循环
            if not gene:
                print(f'❌ 错误：在Excel文件中未找到pheno "{pheno}" 和 SNP "{snp}" 同时匹配的记录')
                # 删除临时文件并退出
                if os.path.exists(temp_file):
                    os.remove(temp_file)
                exit(1)
            parts.append(gene)
        fout.write('\t'.join(parts) + '\n')

os.replace(temp_file, min_p_snps_file)
print(f'✅ 已为 {min_p_snps_file} 添加Gene列')
"

done < "$input_file"