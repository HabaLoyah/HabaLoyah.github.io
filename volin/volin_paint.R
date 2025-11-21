### 小提琴图 绘制
# 韩涛泽

library(tidyverse) #包含了ggplot2包和数据处理用到的dplyr包
library(ggpubr)

# 命令行参数处理
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("请提供参数，例如：Rscript volin_paint.R FI", call. = FALSE)
}
task_name <- args[1]
p_name <- args[2]
path <- paste("/data/Htz/sample500_genotype/output/lm",task_name,p_name,"volin",sep = "/")
base_path <- file.path(path)
if (!dir.exists(base_path)) {
  stop(paste("目录不存在:", base_path), call. = FALSE)
}
# 获取所有第一级子目录（位点目录）
sub_dirs <- list.dirs(base_path, full.names = TRUE, recursive = FALSE)

for (dir in sub_dirs) {
  file_name <- basename(dir)
  csv_file <- file.path(dir, paste0(file_name, ".csv"))
  setwd(dir)
  #读取CSV文件
  data <- read.csv(csv_file, header = TRUE, sep = "\t")
  original_colname <- colnames(data)[2]  # 获取第二列原始名称
  # 检查基因型数量
  unique_genotypes <- sort(unique(data$genotype))

  if (length(unique_genotypes) < 2) {
    message(paste("跳过：", file_name, "（基因型少于两个）"))
    next
  }

  # 转换基因型为数值索引以便拟合
  data <- data %>%
    mutate(
      genotype_num = as.numeric(factor(genotype, levels = unique_genotypes))
    )
  # 转换表型为数值型
  data <- data %>% 
    mutate(
      phenotype = as.numeric(.[[2]])     # 转换数值类型
    )%>%
    filter(!is.na(phenotype) & phenotype != 0)
  # 比较
  comparisons <- combn(unique_genotypes, 2, simplify = FALSE)

  p <- ggplot(data, aes(x = genotype, y = phenotype)) +
    geom_violin(aes(fill=genotype),cex=1.2)+               #根据genotype的不同因子使用不同颜色
    scale_fill_manual(values = c('#FB5554','#42F203','#579ABB'))+
    geom_boxplot(width=0.1,cex=1.2)+      #设置箱线图宽度
    ggtitle(file_name)+             #设置标题置于    
    theme_classic(base_size = 20)+        #可设置不同的主题
    theme(axis.text = element_text(color = 'black'),
          legend.position = 'none')+       #去掉图例
    labs(x = "", y = original_colname)+                           #不显示x轴名称
    geom_jitter(shape = 16, size = 1, position = position_jitter(0.2))+      #添加抖动点
    geom_signif(comparisons = comparisons,
            map_signif_level = T, 
            textsize = 5,          # 增大文字尺寸
            tip_length = 0.01,     # 添加标记线长度参数
            size = 1,             # 调整线宽
            color = "black",        # 设置标记颜色
            test = wilcox.test, 
            step_increase = 0.2) +
    guides(fill = "none") + xlab(NULL) + theme_classic()

  # 添加拟合曲线（以基因型序号为横轴）
  p <- p +
    geom_smooth(
      aes(x = genotype_num, y = phenotype, group = 1),
      method = "lm", size = 1, se = TRUE,
      color = "black", linetype = "dashed", inherit.aes = FALSE
    )

  # 保存文件
  ggsave(paste0(file_name, ".png"), plot = p, dpi = 300)
  ggsave(paste0(file_name, ".pdf"), plot = p, dpi = 300)
  
  # 计算不同基因型的表型平均数±标准差
  genotype_stats <- data %>% 
  group_by(genotype) %>% 
  summarise(
    mean = mean(phenotype, na.rm = TRUE),
    sd = sd(phenotype, na.rm = TRUE),
    count = n()
  ) %>% 
  mutate(
    mean_sd = sprintf("%.4f ± %.4f", mean, sd)
  )
  # ==== 新增部分：计算相对参考基因型（通常为第一个或特定基因型）的变化百分比 ====
  # 自动选择第一个基因型为参考（或你也可以指定，如 ref_genotype <- "CC"）
  ref_genotype <- genotype_stats$genotype[1]
  ref_mean <- genotype_stats$mean[1]

  genotype_stats <- genotype_stats %>%
    mutate(
      change_vs_ref = (mean - ref_mean) / ref_mean * 100
    )
  # 可选：四舍五入至两位小数
  genotype_stats$change_vs_ref <- round(genotype_stats$change_vs_ref, 2)
  
  # 保存统计结果到snp目录
  stats_file <- file.path(dir, paste0(file_name, ".stats.txt"))
  write.table(genotype_stats, file = stats_file, sep = "\t", row.names = FALSE, quote = FALSE)
  print(paste("平均值±标准差结果保存至", stats_file))
}
