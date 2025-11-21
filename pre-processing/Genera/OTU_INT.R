# ============================================
# R 脚本：对 CSS 归一化后的丰度矩阵进行反正态变换 (INT)
# 输入: otu_taxon_Genus_CSS.csv (或前面得到的矩阵)
# 输出: INT 转换后的矩阵 (csv 格式)
# ============================================

# 读入 CSS 归一化后的结果
otu_css <- read.table("otu_taxon_Genus_20percent_CSS.txt",
                  header = TRUE,
                  row.names = 1,
                  sep = "\t",
                  check.names = FALSE,
                  comment.char = "",
                  quote = ""
)


# 定义反正态变换函数
inverse_normal_transform <- function(x) {
  # 秩次 (ties.method = "average" 保证相同值处理一致)
  r <- rank(x, ties.method = "average", na.last = "keep")
  # 转换为分位点 (避免 0 和 1，除以 n+1)
  p <- (r - 0.5) / length(r)
  # 转换为标准正态分布值
  qnorm(p)
}

# 对每一行 (菌属) 做 INT
otu_int <- t(apply(otu_css, 1, inverse_normal_transform))

# 输出结果
write.csv(otu_int, "otu_taxon_Genus_CSS_INT.csv")

cat("反正态变换完成！输出文件: otu_taxon_Genus_CSS_INT.csv\n")
# ============================================


# ============================================
# R 脚本：丰度矩阵整理为 mGWAS 输入格式
# ============================================

# 1. 读入数据
# 假设 CSV 文件行为菌属，列为样本
#otu_int <- read.csv("otu_taxon_Genus_CSS_INT.csv",
                    #row.names = 1,
                    #check.names = FALSE)

# 转置：行 = 个体，列 = 菌属
otu_int_t <- t(otu_int)

# 2. 读入完整个体 ID 列表
ids <- read.table("H:/data/性状/菌/ID.txt", header = FALSE, stringsAsFactors = FALSE)
ids <- ids$V1   # 个体 ID 向量

# 3. 建立一个数据框：500 行，列为菌属
# 先创建全为 -9 的矩阵
otu_mgwas <- matrix(-9,
                    nrow = length(ids),
                    ncol = ncol(otu_int_t),
                    dimnames = list(ids, colnames(otu_int_t)))

# 4. 把已有数据填进去
common_ids <- intersect(rownames(otu_int_t), ids)
otu_mgwas[common_ids, ] <- otu_int_t[common_ids, ]

# 5. 转为数据框
otu_mgwas <- as.data.frame(otu_mgwas)

# 6. 输出结果为制表符分隔的 txt
write.table(otu_mgwas,
            "otu_taxon_Genus_CSS_INT_mGWAS.txt",
            sep = "\t",
            quote = FALSE,
            col.names = NA)

cat("✅ 处理完成！输出文件: otu_taxon_Genus_CSS_INT_mGWAS.txt\n")
# ============================================


