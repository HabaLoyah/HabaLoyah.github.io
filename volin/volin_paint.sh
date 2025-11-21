# 循环绘制小提琴图
# 作者：韩涛泽

# 参数输入
task_name=$1
# 输入文件（事先写好，流程列表文件，每行为一个表型）
input_file="/data/Htz/sample500_genotype/p/${task_name}/p_volin.txt"
# 定义路径
base_dir="/data/Htz/sample500_genotype/output/lm/${task_name}"

echo "开始绘制小提琴图..."
# 读取输入文件并处理每一行
while read -r p_value; do
    # 定义路径
    output_base="${base_dir}/${p_value}/volin"
    p_file="/data/Htz/sample500_genotype/p/${task_name}/${p_value}.txt"
    # 之前注释生成过的上述SNP位点的VCF文件
    vcf_file="/data/Htz/ref/annovar/result/lm_pca1_5_${task_name}_specific_positions/lm_pca1_5_${task_name}_specific_positions.recode.vcf"
    # 最小位点所在文件，由上一个脚本生成 
    min_p_snps_file="${output_base}/min_p_snps_per_chrom.txt"
    # 主处理逻辑
    ## 处理提取的最小p值SNP位点
    ## 生成“基因型与表型对应关系”的统计信息，用于绘制小提琴图的数据
    awk -v p_value="$p_value" -v output_base="$output_base" -v min_p_snps_file=$min_p_snps_file -v p_file="$p_file" -v vcf_file="$vcf_file" '
    BEGIN {
        OFS = "\t"
        FS = "\t"
        
        # 从min_p_snps_file提取第一列值到snp_list关联数组（用于快速查找）
        while ((getline < min_p_snps_file) > 0) {
            snp_list[$3] = 1  # 使用SNP编号作为键
        }
        close(min_p_snps_file)
    }   

    {
        # 跳过VCF header
        if (NR <= 82) next
        # 提取SNP编号
        snp_id = $1 ":" $2
        # 仅处理snp_list中存在的SNP
        if (!snp_list[snp_id]) next
        
        subdir = output_base "/" snp_id
        system("mkdir -p \"" subdir "\"")
        
        output_txt = subdir "/" snp_id ".txt"
        
        ref = $4
        alt = $5
        for (i = 10; i <= NF; i++) {
            split($i, parts, ":") 
            split(parts[1], alleles, /[\/|]/)
            a1 = (alleles[1] == 0) ? ref : (alleles[1] == 1) ? alt : "N"
            a2 = (alleles[2] == 0) ? ref : (alleles[2] == 1) ? alt : "N"
            printf("%s%s\n", a1, a2) >> output_txt
        }

        csv_file = subdir "/" snp_id ".csv"
        print "genotype\t" p_value > csv_file
        close(output_txt)
        system("paste \"" output_txt "\" \"" p_file "\" >> \"" csv_file "\"")
        system("rm \"" output_txt "\"")
    }
    ' "$vcf_file"

    echo "${p_value}数据处理完成！"
    echo "结果文件保存在: $output_base"    
    # 假设volin_paint_pheno_auto.R脚本能够处理新的文件结构
    /home/hantz1/miniconda3/envs/r_443/bin/Rscript /data/Htz/sample500_genotype/cov/pca1_5/lm/CSS/p/volin/volin_paint.R ${task_name} $p_value
    echo "${p_value}绘制完成！"
done < "$input_file"