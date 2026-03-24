#!/usr/bin/env Rscript

# 用途:
#   下载 GEO GSE41258 的 series matrix，并导出表达矩阵、样本注释、特征注释。
# 输入:
#   GEO 在线数据集 GSE41258（通过 GEOquery::getGEO 获取）。
# 输出:
#   1) data_processed/gse41258/gse41258_expr_raw.rds
#   2) data_processed/gse41258/gse41258_pheno_raw.csv
#   3) data_processed/gse41258/gse41258_feature_raw.csv
#   4) logs/01_download_gse41258.log

suppressPackageStartupMessages({
  library(GEOquery)
  library(Biobase)
})

# -----------------------------
# 1) 路径与日志初始化（全部相对路径）
# -----------------------------
geo_id <- "GSE41258"
raw_dir <- file.path("data_raw", "geo", geo_id)
out_dir <- file.path("data_processed", "gse41258")
log_dir <- "logs"
log_file <- file.path(log_dir, "01_download_gse41258.log")

dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)

log_msg <- function(...) {
  msg <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", paste(..., collapse = " "))
  cat(msg, "\n")
  write(msg, file = log_file, append = TRUE)
}

# 每次运行覆盖旧日志，保证可追踪本次过程
if (file.exists(log_file)) file.remove(log_file)

log_msg("启动脚本:", "scripts/01_download_gse41258.R")
log_msg("目标 GEO:", geo_id)
log_msg("下载目录:", raw_dir)
log_msg("处理后输出目录:", out_dir)

# -----------------------------
# 2) 下载 GEO series matrix
# -----------------------------
log_msg("开始调用 getGEO() 下载 series matrix...")
gse_obj <- getGEO(
  GSEMatrix = TRUE,
  GEO = geo_id,
  destdir = raw_dir,
  AnnotGPL = FALSE,
  getGPL = FALSE
)
log_msg("getGEO() 下载完成。")

# -----------------------------
# 3) 处理 getGEO 返回对象并选取正确 ExpressionSet
# -----------------------------
# 若返回列表：优先选择样本数最多的 ExpressionSet（通常对应主分析矩阵）
if (is.list(gse_obj)) {
  log_msg("getGEO() 返回列表，候选 ExpressionSet 数量:", length(gse_obj))
  n_samples <- vapply(gse_obj, function(x) ncol(exprs(x)), numeric(1))
  pick_idx <- which.max(n_samples)
  eset <- gse_obj[[pick_idx]]
  log_msg("已自动选择 ExpressionSet 索引:", pick_idx, "; 样本数:", n_samples[pick_idx])
} else {
  eset <- gse_obj
  log_msg("getGEO() 返回单个 ExpressionSet。")
}

if (!methods::is(eset, "ExpressionSet")) {
  stop("未获得有效的 ExpressionSet 对象。")
}

# -----------------------------
# 4) 提取表达矩阵与注释表
# -----------------------------
expr_mat <- exprs(eset)
pheno_df <- pData(eset)
feature_df <- fData(eset)

expr_dim <- dim(expr_mat)
sample_n <- nrow(pheno_df)
feature_n <- nrow(feature_df)

log_msg("表达矩阵维度:", paste(expr_dim, collapse = " x "))
log_msg("样本数量:", sample_n)
log_msg("特征数量:", feature_n)

# -----------------------------
# 5) 保存结果文件
# -----------------------------
expr_path <- file.path(out_dir, "gse41258_expr_raw.rds")
pheno_path <- file.path(out_dir, "gse41258_pheno_raw.csv")
feature_path <- file.path(out_dir, "gse41258_feature_raw.csv")

saveRDS(expr_mat, file = expr_path)
write.csv(pheno_df, file = pheno_path, row.names = TRUE)
write.csv(feature_df, file = feature_path, row.names = TRUE)

log_msg("已保存表达矩阵:", expr_path)
log_msg("已保存样本注释:", pheno_path)
log_msg("已保存特征注释:", feature_path)
log_msg("脚本执行完成。")

# 终端输出关键信息，便于调用者快速查看
cat("\n=== GSE41258 下载与整理完成 ===\n")
cat("表达矩阵维度:", paste(expr_dim, collapse = " x "), "\n")
cat("样本数量:", sample_n, "\n")
cat("特征数量:", feature_n, "\n")
cat("输出文件:\n")
cat("-", expr_path, "\n")
cat("-", pheno_path, "\n")
cat("-", feature_path, "\n")
cat("日志文件:\n")
cat("-", log_file, "\n")
