###菌表型文件输出脚本###
###用于从表格中提取指定列的数值，并生成对应的菌表型文件###
## 作者：韩涛泽


## 开始生成表型文件
input_file="/data/Htz/sample500_genotype/p/CSS/p_list_Genus.txt"
Genus_file="/data/Htz/sample500_genotype/p/CSS/otu_taxon_Genus_CSS_INT_mGWAS.txt"
# 初始化列号
d=1
 # 查找对应菌所在列，并生成菌表型文件（包含单列表型值）
while read -r p_value; do
    d=$((d+1))
    # 按列切取丰度数据, 去除第一行
    awk -v col="$d" 'NR>1 {print $col}' "$Genus_file" > "/data/Htz/sample500_genotype/p/CSS/${p_value}.txt"
done < "$input_file"
