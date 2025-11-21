import pandas as pd
from pathlib import Path

task_name="CSS"
# 设置工作目录
path = Path(f"/data/Htz/sample500_genotype/output/lm/{task_name}")

# ===== 参数设置 =====
input_file = path / f"lm_pca1_5_{task_name}_specific_positions_annotated_results.xlsx"
output_file = path/"merged_SNP_intervals_all.tsv"
distance_kb = 250000  # 连锁判断窗口，单位 bp，可自行修改

# ===== 读取数据 =====
df = pd.read_excel(input_file)
df['Position'] = df['Position'].astype(int)

# ===== 按染色体排序处理 =====
merged = []
for chrom, g in df.groupby('Chromosome'):
    g = g.sort_values('Position')
    
    start = None
    end = None
    phenos = set()
    genes = set()
    snps = []
    pvals = []

    for _, row in g.iterrows():
        pos = row['Position']
        if start is None:
            # 初始化新区间
            start = pos
            end = pos
            phenos = {str(row['Phenotype'])}
            genes = {str(row['Near gene'])}
            snps = [str(row['SNP'])]
            pvals = [float(row['P value'])]
        else:
            if pos - end <= distance_kb:
                # 属于同一连锁区间
                end = pos
                phenos.add(str(row['Phenotype']))
                genes.add(str(row['Near gene']))
                snps.append(str(row['SNP']))
                pvals.append(float(row['P value']))
            else:
                # 输出上一区间
                merged.append({
                    "Chromosome": chrom,
                    "Start": start,
                    "End": end,
                    "n_SNPs": len(snps),
                    "Phenotypes": ";".join(sorted(phenos)),
                    "Genes": ";".join(sorted(genes)),
                    "P_min": min(pvals),
                    "P_max": max(pvals),
                    "SNPs": ";".join(snps)
                })
                # 开始新一段
                start = pos
                end = pos
                phenos = {str(row['Phenotype'])}
                genes = {str(row['Near gene'])}
                snps = [str(row['SNP'])]
                pvals = [float(row['P value'])]
    # 最后一段写入
    if start is not None:
        merged.append({
            "Chromosome": chrom,
            "Start": start,
            "End": end,
            "n_SNPs": len(snps),
            "Phenotypes": ";".join(sorted(phenos)),
            "Genes": ";".join(sorted(genes)),
            "P_min": min(pvals),
            "P_max": max(pvals),
            "SNPs": ";".join(snps)
        })

# ===== 输出结果 =====
out = pd.DataFrame(merged)
out = out.sort_values(['Chromosome','Start'])
out.to_csv(output_file, sep="\t", index=False)
print(f"✅ 输出完成，共 {len(out)} 个区间，结果已保存至 {output_file}")
