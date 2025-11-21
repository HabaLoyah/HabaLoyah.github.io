# GWAS分析自动化流程

## 项目概述

本项目提供了一套完整的全基因组关联分析(GWAS)自动化流程，支持从基因型和表型数据输入，到GWAS分析、结果筛选、基因注释、结果汇总和可视化的全流程自动化处理。主要用于分析遗传变异与表型性状之间的关联，识别显著相关的SNP位点及其相关基因。

## 目录结构

```
.
├── GWAS_auto_p.sh          # 主自动化脚本，整合整个分析流程
├── GWAS_resultplot_lm_pca1_5.R  # GWAS结果可视化脚本（曼哈顿图和QQ图）
├── common_space_abstract.py      # 连锁区间分析脚本
├── gemma_for_list.sh       # 使用GEMMA进行GWAS分析的并行处理脚本
├── lm_annoar_p.sh          # 基因注释脚本
├── lm_result_xslx_p.sh     # 结果汇总为Excel表格的脚本
├── lm_snp_find.sh          # 显著SNP位点提取脚本
├── mahatton_paint.sh       # 曼哈顿图并行绘制脚本
├── pre-processing/         # 数据预处理相关脚本目录
│   ├── GWAS_pre-processing.sh  # GWAS数据预处理主脚本
│   ├── Genera/             # 属水平分析相关脚本
│   │   ├── OTU_CSS.R       # OTU CSS标准化处理
│   │   ├── OTU_INT.R       # OTU 整数化处理
│   │   ├── anova_anaysis_genera.R  # 属水平方差分析
│   │   └── p_file_output.sh        # 表型文件输出脚本
│   ├── PCA_plot.R          # PCA结果可视化脚本
│   ├── Pheno/              # 表型分析相关脚本
│   │   └── anova_anaysis_pheno.R   # 表型方差分析脚本
│   └── topsnp_sum.sh       # 显著SNP汇总脚本
└── volin/                  # 小提琴图相关脚本目录
    ├── ln.sh               # 链接创建脚本
    ├── volin_min_p_snps_file.sh  # 最小p值SNP位点提取脚本
    ├── volin_paint.R       # 小提琴图绘制脚本
    └── volin_paint.sh      # 小提琴图批量处理脚本
```

## 主要功能

### 1. 自动化GWAS分析流程
- **`GWAS_auto_p.sh`**：主控制脚本，按顺序调用各个功能模块，实现从数据准备到结果输出的自动化流程。

### 2. 高效的GWAS分析
- **`gemma_for_list.sh`**：使用GEMMA软件进行GWAS分析，支持多表型并行处理，显著提高分析效率。

### 3. 显著SNP筛选与注释
- **`lm_snp_find.sh`**：根据显著性阈值提取显著关联的SNP位点。
- **`lm_annoar_p.sh`**：对筛选出的SNP位点进行基因注释，获取相关基因信息。

### 4. 结果汇总与表格化
- **`lm_result_xslx_p.sh`**：将GWAS结果汇总为结构化的Excel表格，包含SNP信息、关联p值和注释信息。
- **`common_space_abstract.py`**：对显著SNP进行连锁区间分析，识别潜在的功能区域。

### 5. 结果可视化
- **`GWAS_resultplot_lm_pca1_5.R`**：绘制曼哈顿图(Manhattan plot)和QQ图，直观展示GWAS分析结果。
- **`mahatton_paint.sh`**：并行处理曼哈顿图绘制，支持批量绘图，显著提高处理效率。
- **`volin_paint.sh`**：绘制基因型-表型关联的小提琴图，展示不同基因型在表型上的分布差异。

## 环境依赖

### 软件依赖
- **GEMMA**（版本 0.98.5）：用于执行GWAS分析
- **R**（建议版本 4.4.3）：用于数据可视化和统计分析
- **Python**（建议版本 3.6+）：用于数据处理和分析
- **parallel**：用于并行处理GWAS分析任务
- **Annovar**：用于SNP位点注释

### R包依赖
- **CMplot**：用于绘制曼哈顿图和QQ图
- **magick**：用于图像拼接和处理

### Python包依赖
- **pandas**：用于数据处理和分析
- **openpyxl**：用于Excel文件读写

## 使用方法

### 1. 准备数据

项目提供了完整的数据预处理模块，支持：
- **`pre-processing/GWAS_pre-processing.sh`**：统一的数据预处理入口脚本
- **OTU数据处理**：包括CSS标准化和整数化处理
- **方差分析**：支持属水平和表型水平的统计分析
- **表型文件生成**：自动生成符合GEMMA要求的表型输入文件

预处理完成后，将生成以下数据：
- 基因型数据（plink格式）
- 表型数据（文本格式，每行一个样本）
- 协变量数据（如PCA结果，用于校正群体结构）

### 2. 修改路径配置

在使用前，需要根据实际情况修改脚本中的路径配置，主要修改以下脚本中的路径：
- **`GWAS_auto_p.sh`** 中的 `base_dir`
- **`gemma_for_list.sh`** 中的 `base_dir` 和 `gemma_exec`
- **`lm_result_xslx_p.sh`** 中的路径配置

### 3. 运行自动化流程

执行主脚本，指定任务名称作为参数：

```bash
./GWAS_auto_p.sh task_name
```

其中 `task_name` 是自定义的任务名称，用于创建和标识输出目录。

### 4. 分析流程说明

执行自动化流程后，系统将按以下步骤进行分析：
1. 提取显著SNP位点
2. 进行基因注释
3. 结果汇总为Excel表格
4. 生成曼哈顿图（可选，当前已注释）
5. 提取最小p值SNP位点并绘制小提琴图

## 输出结果

### 主要输出文件

1. **GWAS分析结果**：
   - `.assoc.plot.txt` 文件：包含SNP信息和关联分析结果

2. **显著SNP列表**：
   - `lm_pca1_5_{task_name}_specific_positions.txt`：筛选出的显著SNP

3. **注释结果**：
   - `lm_pca1_5_{task_name}_specific_positions_annotated_results.xlsx`：包含注释信息的Excel表格

4. **可视化结果**：
   - 曼哈顿图和QQ图：`{p_value}_combined_manhattan.jpg`
   - 小提琴图：在 `volin/{snp_id}` 目录下生成

5. **连锁区间分析**：
   - `merged_SNP_intervals_all.tsv`：识别的连锁区间信息

## 示例

### 运行示例

```bash
# 运行完整的GWAS分析流程
./GWAS_auto_p.sh my_trait_analysis

# 仅运行GWAS分析
./gemma_for_list.sh my_trait_analysis

# 并行绘制曼哈顿图
./mahatton_paint.sh my_trait_analysis

# 仅绘制特定表型的曼哈顿图
Rscript GWAS_resultplot_lm_pca1_5.R phenotype_name covariate_name my_trait_analysis

# 运行数据预处理
cd pre-processing && ./GWAS_pre-processing.sh my_data
```

## 注意事项

1. 请确保所有路径配置正确，特别是基因型数据、表型数据和协变量数据的路径
2. 对于大型数据集，建议调整并行处理的核心数（在`gemma_for_list.sh`和`mahatton_paint.sh`中的`-j 10`参数）
3. 显著性阈值可以根据研究需要进行调整
4. 确保Python和R环境中已安装必要的依赖包
5. 在运行预处理脚本时，请确保输入数据格式符合要求

## 维护与更新

本项目由韩涛泽开发和维护。如有任何问题或建议，请联系相关开发者，微信：Han17526835148。

本项目为作者硕士期间所编写，请详细甄别其内容。仍在持续更新中。
## 版本历史

- 初始版本：支持基本的GWAS分析流程、注释和可视化功能
- 更新版本：添加并行处理支持，优化运行效率，增加连锁区间分析功能

---

*注：本流程主要针对特定研究设计，使用前请根据实际研究需求进行适当调整。*