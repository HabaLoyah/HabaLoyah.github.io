#!/bin/bash

### Manhattan图并行绘制脚本 ###
## 作者：韩涛泽（基于原始脚本修改支持并行和日志）
## 功能：对每个 p_value 和 cov 进行 Manhattan图并行处理，记录耗时

# 任务名称(命令行跟在脚本后)
task_name=$1

# 写入日志文件
log_file1="/data/Htz/sample500_genotype/output/lm/${task_name}/1logs/gwas.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')]: 开始Manhattan图绘制" >> ${log_file1}
log_file2="/data/Htz/sample500_genotype/output/lm/${task_name}/1logs/manhatton_paint.log"
> $log_file2

# 设置路径
paint_R="/data/Htz/sample500_genotype/cov/pca1_5/lm/p/GWAS_resultplot_lm_pca1_5.R"
cov_file="/data/Htz/sample500_genotype/p/pheno/cov_list.txt"

# 主函数：每个任务处理一个 p_value x cov
run_manhattan_plot() {
    local paint_R="$1"
    local p_value="$2"
    local cov="$3"
    local task_name="$4"
    local log_file2="$5"
    
    start_time=$(date +%s)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始绘制: p_value: $p_value, cov: $cov" | tee -a "$log_file2"

    # 运行R脚本进行绘图
    Rscript "$paint_R" "$p_value" "$cov" "$task_name"
    
    # 检查R脚本是否成功执行
    if [ $? -eq 0 ]; then
        end_time=$(date +%s)
        duration=$((end_time-start_time))
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 完成绘图——${p_value}, cov: ${cov}，耗时: ${duration}秒" | tee -a "$log_file2"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 错误: 绘图失败——${p_value}, cov: ${cov}" | tee -a "$log_file2"
    fi
}
export -f run_manhattan_plot

# 生成任务列表文件
task_list=$(mktemp)
echo "生成任务列表..."

while read -r cov; do 
    input_file="/data/Htz/sample500_genotype/p/$task_name/p_list_$cov.txt"
    while read -r p_value; do
        echo "$paint_R $p_value $cov $task_name $log_file2" >> "$task_list"
    done < "$input_file"
done < "$cov_file"

echo "总任务数: $(wc -l < "$task_list")"

# 并行执行
echo "开始并行执行，使用10个核心..."
cat "$task_list" | parallel -j 10 --colsep ' ' run_manhattan_plot {1} {2} {3} {4} {5}

# 删除临时任务文件
rm "$task_list"

echo "[$(date '+%Y-%m-%d %H:%M:%S')]: 完成Manhattan图绘制" >> ${log_file1}
echo "所有绘图任务已完成。"