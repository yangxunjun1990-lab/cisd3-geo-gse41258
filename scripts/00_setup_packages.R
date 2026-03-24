#!/usr/bin/env Rscript

# 用途:
#   安装并加载本项目分析所需 R 包（CRAN + Bioconductor）。
# 输入:
#   无（依赖本机/环境中的 R 包安装状态）。
# 输出:
#   1) 缺失包将被安装
#   2) 加载所有目标包
#   3) sessionInfo() 写入 logs/sessionInfo_setup.txt

options(repos = c(CRAN = "https://cloud.r-project.org"))

# -----------------------------
# 1) 定义目标包
# -----------------------------
bioc_packages <- c(
  "GEOquery",
  "limma",
  "AnnotationDbi",
  "hgu133a.db"
)

cran_packages <- c(
  "tidyverse",
  "janitor",
  "readr",
  "stringr",
  "tibble",
  "ggplot2"
)

all_packages <- unique(c(bioc_packages, cran_packages))

# -----------------------------
# 2) 安装 BiocManager（若缺失）
# -----------------------------
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# -----------------------------
# 3) 按类型安装缺失包
# -----------------------------
installed <- rownames(installed.packages())

missing_bioc <- setdiff(bioc_packages, installed)
if (length(missing_bioc) > 0) {
  BiocManager::install(missing_bioc, ask = FALSE, update = FALSE)
}

installed <- rownames(installed.packages())
missing_cran <- setdiff(cran_packages, installed)
if (length(missing_cran) > 0) {
  install.packages(missing_cran)
}

# -----------------------------
# 4) 加载所有包
# -----------------------------
for (pkg in all_packages) {
  ok <- suppressPackageStartupMessages(
    require(pkg, character.only = TRUE, quietly = TRUE)
  )
  if (!isTRUE(ok)) {
    stop(sprintf("包加载失败: %s", pkg))
  }
}

# -----------------------------
# 5) 输出 sessionInfo
# -----------------------------
dir.create("logs", showWarnings = FALSE, recursive = TRUE)

session_info_path <- file.path("logs", "sessionInfo_setup.txt")
writeLines(capture.output(sessionInfo()), con = session_info_path)

message("依赖包安装与加载完成。")
message("sessionInfo 已写入: ", session_info_path)
