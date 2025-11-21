###Manhattan图和QQ图拼接绘制###
library(CMplot)
library(magick)

args <- commandArgs(trailingOnly = TRUE)
p_name <- args[1]
cov <- args[2]
task_name <- args[3]
# 设置工作路径到指定菌GWAS结果文件
setwd(paste("/data/Htz/sample500_genotype/output/lm/",task_name,p_name, sep = "/"))

# 读取GWAS结果
gwasResults <- read.table(paste0(p_name, "_GE_GWAS_lm_", cov, "_pca1_5.assoc.plot.txt"), header = TRUE)
plot_data <- gwasResults[, c(2,1,3,11)]  # chr, SNP, ps, p_wald

# 阈值
threshold_value <- 0.05 / nrow(plot_data)
suggested_value <- 0.1 / nrow(plot_data)

# 计算Z值和lambda
z <- gwasResults$beta / gwasResults$se
lambda_gc <- round(median(z^2, na.rm = TRUE) / qchisq(0.5, df = 1), 3)

# 输出单独图

CMplot(plot_data,
       plot.type = "m",
       threshold = c(threshold_value, suggested_value),
       cex = 0.8,
       threshold.col = c('red', 'black'),
       threshold.lty = c(1, 2),
       threshold.lwd = c(1, 1),
       amplify = TRUE,
       bin.size = 1e6,
       chr.den.col = c("darkgreen", "yellow", "red"),
       signal.col = c("red", "green"),
       signal.cex = c(1, 1),
       file="jpg",
       dpi = 300,
       main=NULL,
       verbose = FALSE)

CMplot(plot_data,
       plot.type = "q",
       threshold = 0.05,
       main=paste0("λ = ", lambda_gc),
       file="jpg",
       dpi = 300,
       verbose = FALSE)

# 使用 magick 读取图片
img1 <- image_read("Rect_Manhtn.p_wald.jpg")
img2 <- image_read("QQplot.p_wald.jpg")
# 假设要下移 100 px
img2_padded <- image_extent(img2, geometry = geometry_size_pixels(width = image_info(img2)$width,
                                                                 height = 1800),
                            gravity = "south",color = "white")  # 保持图片在顶部，空白加在上方

# 横向拼接两张图片
combined <- image_append(c(img1, img2_padded))

# 保存最终合并图
image_write(combined, path = paste(p_name,"_combined_manhattan.jpg"))

# ===== 第三步：清理临时文件 =====
file.remove("Rect_Manhtn.p_wald.jpg", "QQplot.p_wald.jpg")

quit()
