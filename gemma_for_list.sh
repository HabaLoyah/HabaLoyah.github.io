

### mGWAS分析循环脚本 ###
## gemma 版
## 作者：韩涛泽（修改版支持并行和日志）
## 功能：对每个 p_value 和 cov 进行 GWAS 并行处理，记录耗时

# 任务名称(命令行跟在脚本后)
task_name=$1
# 基本目录
base_dir="/data/Htz/sample500_genotype"
output_dir="/data/Htz/sample500_genotype/output/lm/$task_name"
cov_list="${base_dir}/p/Genus/cov_list.txt"


cd "$base_dir" || exit 1

# GEMMA 可执行文件路径
gemma_exec=~/gemma-0.98.5

# 输出日志目录
log_dir="${output_dir}/1logs"
mkdir -p "$log_dir"
log_file="${log_dir}/run_gwas.log"

# 主函数：每个任务处理一个 p_value x cov
run_gwas() {
    local base_dir="$1"
    local output_dir="$2"
    local gemma_exec="$3"
    local p_value="$4"
    local cov="$5"
    local task_name="$6"
    local log_file="$7"
    
    start_time=$(date +%s)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Start p_value: $p_value, cov: $cov"

    cov_file="${base_dir}/cov/pca1_5/${cov}_pca1_5.txt"
    p_dir="${output_dir}/${p_value}"
    mkdir -p "$p_dir"

    assoc_file="${p_dir}/${p_value}_GE_GWAS_lm_${cov}_pca1_5.assoc.txt"
    output_file="lm/$task_name/${p_value}/${p_value}_GE_GWAS_lm_${cov}_pca1_5"
    assoc_plot_file="${p_dir}/${p_value}_GE_GWAS_lm_${cov}_pca1_5.assoc.plot.txt"
    

    # 运行 GEMMA 并记录日志
    echo "Running GEMMA for $p_value with cov $cov..." > "$log_file"
    $gemma_exec -bfile "${base_dir}/All500_3/All500_3.merge.snp" -lm -c "$cov_file" -p ${base_dir}/p/${task_name}/$p_value.txt -o "$output_file" >> "$log_file" 2>&1

    # 检查GEMMA是否成功执行
    if [ $? -eq 0 ]; then
        # 后处理 assoc 文件
        if [ -f "$assoc_file" ]; then
            awk '{ $2 = $1 ":" $3; print }' "$assoc_file" | sed '1s/chr:ps/snp/' > "$assoc_plot_file"
            rm "$assoc_file"
            echo "Successfully processed assoc file for $p_value, $cov" >> "$log_file"
        else
            echo "Warning: Assoc file not found: $assoc_file" >> "$log_file"
        fi
    else
        echo "Error: GEMMA failed for $p_value, $cov" >> "$log_file"
    fi

    end_time=$(date +%s)
    duration=$((end_time-start_time))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Finished p_value: $p_value, cov: $cov in $duration seconds" | tee -a "$log_file"
}
export -f run_gwas

# 生成任务列表文件
task_list=$(mktemp)
echo "Generating task list..."
echo "$input_file"

while read -r cov; do
    input_file="${base_dir}/p/${task_name}/p_list_${cov}.txt"
    while read -r p_value; do
        echo "$base_dir $output_dir $gemma_exec $p_value $cov $task_name $log_file" >> "$task_list"
    done < "$input_file"
done < "$cov_list"

echo "Total tasks: $(wc -l < "$task_list")"

# 并行执行
echo "Starting parallel execution with 10 cores..."
cat "$task_list" | parallel -j 10 --colsep ' ' run_gwas {1} {2} {3} {4} {5} {6} {7}

# 删除临时任务文件
rm "$task_list"

echo "All tasks finished."