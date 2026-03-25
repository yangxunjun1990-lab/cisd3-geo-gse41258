#!/usr/bin/env Rscript

# 用途:
#   为 GSE41258 分析准备依赖：按需安装并加载 CRAN/Bioconductor 包。
# 输入:
#   无（仅检查当前 R 环境已安装包）。
# 输出:
#   1) 缺失依赖将被安装
#   2) 目标依赖将被加载
#   3) sessionInfo() 写入 logs/sessionInfo_setup.txt
# 运行方式:
#   Rscript scripts/00_setup_packages.R

options(repos = c(CRAN = "https://cloud.r-project.org"))

# 目标 Bioconductor 包
bioc_packages <- c(
  "GEOquery",
  "limma",
  "AnnotationDbi",
  "hgu133a.db"
)

# 目标 CRAN 包
cran_packages <- c(
  "tidyverse",
  "janitor",
  "readr",
  "stringr",
  "tibble",
  "ggplot2"
)

all_packages <- unique(c(bioc_packages, cran_packages))

# 自动检查 BiocManager，缺失则安装
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# 仅安装缺失的 Bioconductor 包
installed <- rownames(installed.packages())
missing_bioc <- setdiff(bioc_packages, installed)
if (length(missing_bioc) > 0) {
  BiocManager::install(missing_bioc, ask = FALSE, update = FALSE)
}

# 仅安装缺失的 CRAN 包
installed <- rownames(installed.packages())
missing_cran <- setdiff(cran_packages, installed)
if (length(missing_cran) > 0) {
  install.packages(missing_cran)
}

# 加载所有目标包
for (pkg in all_packages) {
  loaded <- suppressPackageStartupMessages(
    require(pkg, character.only = TRUE, quietly = TRUE)
  )
  if (!isTRUE(loaded)) {
    stop(sprintf("包加载失败: %s", pkg))
  }
}

# 输出 sessionInfo 到相对路径
logs_dir <- "logs"
dir.create(logs_dir, recursive = TRUE, showWarnings = FALSE)
session_info_file <- file.path(logs_dir, "sessionInfo_setup.txt")
writeLines(capture.output(sessionInfo()), con = session_info_file)

message("依赖包安装与加载完成。")
message("sessionInfo 已写入: ", session_info_file)
