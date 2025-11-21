##PCA图 绘制##
#参考：https://www.jianshu.com/p/fa6790e68818

library(ggplot2)
setwd("D:/个人/科研/生信/分析/GWAS")
pca <- read.table("All500.merge.snp.pca.eigenvec",sep = "\t",header = T)
ggplot(pca, aes(x=pca1,y=pca2)) +
  geom_point(aes(color=pop, shape=pop),size=1.5)+
  labs(x="PC1",y="PC2")+theme_bw()+theme(legend.title = element_blank())