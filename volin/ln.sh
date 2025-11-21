task_name="CSS"
input_file="/data/Htz/sample500_genotype/p/${task_name}/p_volin.txt"

# 定义路径
base_dir="/data/Htz/sample500_genotype/output/lm/${task_name}"
while read -r p_value; do
    echo "开始处理${p_value}"
    origin_dir="${base_dir}/${p_value}"
    target_dir="/data/Htz/sample500_genotype/cov/pca1_5/lm/CSS/p/volin"
    ln -s $origin_dir $target_dir
done < "$input_file"