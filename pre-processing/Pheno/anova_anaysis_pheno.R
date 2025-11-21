## 多因素方差分析脚本 ##
## 用于快速判定性别和批次固定效应对饲料效率性状的影响/
## 影响显著的表型则在后续GWAS中用对应固定效应对其进行矫正
# 读取数据
data <- read.csv("pheno.csv", header = TRUE)

# 确保分组变量为因子
data$sex <- as.factor(data$sex)
data$batch <- as.factor(data$batch)

# 读取要分析的菌属名
traits <- readLines("p_list_whole.txt")

results <- data.frame(
  Trait = character(),
  Effect = character(), 
  Df = numeric(),
  F_value = numeric(),
  P_value = numeric(),
  stringsAsFactors = FALSE
)

# 确认要分析的列
all_needed_cols <- c("sex", "batch", traits)

# 检查是否有不存在的列
missing_cols <- setdiff(all_needed_cols, names(data))


for (trait in traits) {
  # 只保留当前性状 + 分组变量
  subdata <- data[, c("sex", "batch", trait)]
  subdata <- na.omit(subdata)   # 只去掉该性状的 NA
  
  cat("Now processing:", trait, "\n")
  print(summary(subdata[[trait]]))
  
  # 双因素方差分析
  formula <- as.formula(paste(trait, "~ sex * batch"))
  model <- aov(formula, data = subdata)
  anova_tab <- summary(model)[[1]]
  
  # 提取 sex、batch、sex:batch 三个效应
  effects <- rownames(anova_tab)[1:3]
  tmp <- data.frame(
    Trait = trait,
    Effect = effects,
    Df = anova_tab$Df[1:3],
    F_value = anova_tab$`F value`[1:3],
    P_value = anova_tab$`Pr(>F)`[1:3]
  )
  
  results <- rbind(results, tmp)
}


# 查看结果
print(results)

# 保存为 CSV
write.csv(results, "pheno_auto_ANOVA_results.csv", row.names = FALSE)

## 判断分组

# 1. 把长表转换为宽表（每个Trait对应三个p值列）
library(reshape2)
results_wide <- dcast(results, Trait ~ Effect, value.var = "P_value")

# 2. 定义显著阈值
alpha <- 0.05

# 3. 按条件判断分组
library(dplyr)

# 去掉sex和batch前后的空格
names(results_wide) <- trimws(names(results_wide))

results_wide <- results_wide %>%
  mutate(cov_group = case_when(
    sex < alpha & batch >= alpha & `sex:batch` >= alpha ~ "sex",
    batch < alpha & sex >= alpha & `sex:batch` >= alpha ~ "batch",
    `sex:batch` < alpha & sex >= alpha & batch >= alpha ~ "sync",
    sex < alpha & batch < alpha & `sex:batch` >= alpha ~ "both",
    TRUE ~ "no_cov"
  ))

# 保存为 CSV
write.csv(results_wide, "pheno_auto_ANOVA_cov-group.csv", row.names = FALSE)

