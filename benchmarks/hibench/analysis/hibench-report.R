#!/usr/bin/env Rscript

library(tidyverse, warn.conflicts=FALSE, quietly=TRUE)
library(Hmisc, warn.conflicts=FALSE, quietly=TRUE)

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("Missing directory name with the sets")
}

ds <- lapply(list.dirs(args[1], recursive=FALSE), function(dir) {
  files <- list.files(dir, full.names=TRUE)
  data <- lapply(files, read_table, col_names=c("Type", "Date", "Time", "Input_data_size", "Duration", "Throughput", "Throughput_node"), skip=1)
  df <- do.call(rbind, data)
  df %>% mutate(Set=basename(dir))
})

ds <- do.call(rbind, ds)
ds <- ds %>% select(Set, Type, Duration, Throughput)

pdf("hibench-duration.pdf")

ggplot(ds, aes(Type, Duration, fill=Set)) +
  stat_summary(fun.data=mean_cl_boot, position="dodge", geom="bar") +
  stat_summary(fun.data=mean_cl_boot, color="black", geom="errorbar", position=position_dodge(.9), width=.2)

pdf("hibench-throughput.pdf")

ggplot(ds, aes(Type, Throughput, fill=Set)) +
  stat_summary(fun.data=mean_cl_boot, position="dodge", geom="bar") +
  stat_summary(fun.data=mean_cl_boot, color="black", geom="errorbar", position=position_dodge(.9), width=.2)

dev.off()
