pb_plot_disparity_decomp <- function(out) {
  if (!inherits(out, "pb")) {
    stop("`out` must be a pb object.")
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package `ggplot2` is required for plotting.")
  }

  df <- data.frame(
    group = rownames(out$unexplained.disp),
    overall = as.numeric(out$overall.disp[, 1]),
    unexplained = as.numeric(out$unexplained.disp[, 1]),
    se = sqrt(as.numeric(out$unexp.disp.variance[, 1]))
  )

  plot_df <- rbind(
    data.frame(group = df$group, metric = "Overall disparity", value = df$overall),
    data.frame(group = df$group, metric = "Unexplained disparity", value = df$unexplained)
  )

  ggplot2::ggplot(plot_df, ggplot2::aes(x = group, y = value, fill = metric)) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.7), width = 0.6) +
    ggplot2::geom_errorbar(
      data = df,
      ggplot2::aes(
        x = group,
        ymin = unexplained - 1.96 * se,
        ymax = unexplained + 1.96 * se
      ),
      width = 0.15,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed") +
    ggplot2::labs(
      x = NULL,
      y = "Disparity",
      fill = NULL,
      title = paste("PB Decomposition -", out$family)
    ) +
    ggplot2::theme_minimal()
}

pb_save_disparity_plot <- function(out, filename, out_dir = "images", width = 9, height = 5, dpi = 300) {
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE)
  }
  path <- file.path(out_dir, filename)
  p <- pb_plot_disparity_decomp(out)
  ggplot2::ggsave(filename = path, plot = p, width = width, height = height, dpi = dpi)
  invisible(path)
}

pb_describe_result <- function(out, label = out$family) {
  group_name <- colnames(out$overall.disp)[1]
  rows <- rownames(out$overall.disp)
  overall <- as.numeric(out$overall.disp[, 1])
  unexplained <- as.numeric(out$unexplained.disp[, 1])
  se <- sqrt(as.numeric(out$unexp.disp.variance[, 1]))
  pct <- as.numeric(out$percent.unexplained[, 1])

  cat("\n")
  cat("=== ", label, " (", out$family, ") ===\n", sep = "")
  cat("What this plot shows:\n")
  cat("- Blue bar: observed disparity (White minus ", group_name, ").\n", sep = "")
  cat("- Orange bar: unexplained disparity after adjusting for model covariates.\n")
  cat("- Black error bar: 95% CI for unexplained disparity.\n")
  cat("- Dashed zero line: no disparity.\n")
  cat("\n")
  cat("How to read sign:\n")
  cat("- Positive value: White is higher for that outcome level.\n")
  cat("- Negative value: ", group_name, " is higher for that outcome level.\n", sep = "")
  cat("\n")
  cat("Model results by row:\n")
  for (i in seq_along(rows)) {
    ci_low <- unexplained[i] - 1.96 * se[i]
    ci_high <- unexplained[i] + 1.96 * se[i]
    cat(
      sprintf(
        "- %s: overall=%.4f, unexplained=%.4f, 95%% CI [%.4f, %.4f], unexplained%%=%.1f\n",
        rows[i], overall[i], unexplained[i], ci_low, ci_high, pct[i]
      )
    )
  }
  cat("\n")
}
