# CISD3 在结直肠癌原发灶与转移灶中的表达差异分析（GSE41258）

## 项目目的
本项目用于构建一个**可复现的 R 生信分析流程**，研究主题为：

> CISD3 在结直肠癌原发灶与转移灶中的表达差异：基于 GEO GSE41258。

项目聚焦于：
- 规范化整理分析目录；
- 明确原始数据与处理数据分层；
- 为后续 R 脚本执行提供固定输入/输出路径；
- 便于团队协作、审计和复现实验流程。

## 数据来源
- 数据库：NCBI GEO（Gene Expression Omnibus）
- 数据集编号：**GSE41258**
- 建议将下载得到的原始数据文件放入：`data_raw/geo/GSE41258/`

## 目录结构

```text
.
├── AGENTS.md
├── README.md
├── .gitignore
├── scripts/                     # R 脚本目录
├── data_raw/
│   └── geo/
│       └── GSE41258/            # GEO 原始数据（只读）
├── data_processed/
│   └── gse41258/                # 处理后中间数据
├── results/
│   ├── tables/                  # 结果表格输出
│   └── figures/                 # 结果图形输出
└── logs/                        # 日志与运行记录
```

## 运行顺序（建议）
后续可在 `scripts/` 中按以下阶段组织 R 脚本并顺序执行：

1. **数据下载/整理**：读取 `data_raw/geo/GSE41258/` 中原始文件；
2. **预处理与标准化**：输出到 `data_processed/gse41258/`；
3. **分组比较与统计检验**：围绕原发灶 vs 转移灶比较 CISD3 表达；
4. **结果导出**：
   - 表格写入 `results/tables/`
   - 图形写入 `results/figures/`
5. **日志记录**：运行日志写入 `logs/`

## 输出文件位置
- 统计表、注释表、汇总表：`results/tables/`
- 可视化图（箱线图、火山图、注释图等）：`results/figures/`
- 可复用中间对象（RDS/CSV/TSV）：`data_processed/gse41258/`
- 运行日志：`logs/`

---
如需扩展脚本，请保证每个脚本头部写明“输入、输出、用途”，并使用相对路径以确保可复现性。
