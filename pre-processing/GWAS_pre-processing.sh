### GWAS前期准备
## 作者：韩涛泽

#!/bin/bash

### vcf格式转换为tped/tfam格式 ###
/home/hantz1/plink2 --vcf All500.merge.vcf.gz --chr-set 33 --allow-extra-chr --export tped  --out All500.merge
### 生成bed/bim/fam文件
/home/hantz1/plink2 --vcf All500.merge.vcf.gz --chr-set 33 --allow-extra-chr --make-bed --out  All500.merge.snp
###数据过滤###得到过滤后的All500.merge.snp.tped， All500.merge.snp.tfam
/home/hantz1/plink2 --tfile All500.merge --output-missing-genotype 0 --geno 0.1 --maf 0.05 --make-bed --out All500.merge.clean
###进行pca分析，得到All500-pca.eigen，All500-a-pca.pos
/home/hantz1/plink2 --bfile All500.merge.snp --chr-set 31 --pca 5 --out All500.merge.snp.pca1_5
## 计算kinship矩阵（其中的fam文件，随便给放点表型再）
/home/hantz1/gemma-0.98.5-linux-static-AMD64 -bfile All500.merge.snp -gk 2 -o All500.merge.snp.kin