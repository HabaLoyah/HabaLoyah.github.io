# ============================================
# R 脚本：属水平丰度表 CSS 归一化 + 20%检出率过滤
# 输出：txt 格式
# ============================================

# 如果没安装过
# if (!requireNamespace("BiocManager", quietly = TRUE))
#     install.packages("BiocManager")
# BiocManager::install("metagenomeSeq")

library(metagenomeSeq)

setwd("H:/data/性状/菌/Genus/20%_CSS_cor")

# 1. 读取属水平丰度表（绝对丰度）
otu <- read.table("H:/data/性状/菌/Genus/otu_taxon_Genus_origin.txt",
                  header = TRUE,
                  row.names = 1,
                  sep = "\t",
                  check.names = FALSE,
                  comment.char = "",
                  quote = ""
                  )
OTU <- as.matrix(otu)

# 2. 先做 20% 检出率过滤
prevalence_rate <- rowSums(OTU > 0) / ncol(OTU)
OTU_filtered <- OTU[prevalence_rate >= 0.20, ]

# 打开日志文件
logfile <- "otu_taxon_Genus.log"
sink(logfile)

cat("========== 筛选与归一化日志 ==========\n")
cat("原始属数量:", nrow(OTU), "\n")
cat("过滤后属数量:", nrow(OTU_filtered), "\n")
cat("过滤掉的属数量:", nrow(OTU) - nrow(OTU_filtered), "\n\n")

# 3. 构建 MRexperiment 对象并 CSS 归一化
MGS <- newMRexperiment(OTU_filtered)

# 推荐先计算分位点，再归一化
p <- cumNormStatFast(MGS)
MGS <- cumNorm(MGS, p = p)

# 4. 提取 CSS 归一化后的矩阵
otu_css <- MRcounts(MGS, norm = TRUE)

cat("归一化完成。输出文件：\n")
cat(" - otu_taxon_Genus_20percent.csv\n")
cat(" - otu_taxon_Genus_CSS.csv\n")
cat(" - otu_taxon_Genus.log (本日志)\n")
# 关闭日志文件
sink()

# 5. 输出结果为 txt
write.table(otu_css, 
            "otu_taxon_Genus_20percent_CSS.txt", 
            sep = "\t", quote = FALSE)
write.table(OTU_filtered, 
            "otu_taxon_Genus_20percent.txt", 
            sep = "\t", quote = FALSE)

# ============================================
# 脚本结束
# 输出文件：
# 1) otu_taxon_Genus_20percent.txt   # 20%检出率过滤后的原始丰度
# 2) otu_taxon_Genus_CSS.txt# CSS 归一化结果
# ============================================