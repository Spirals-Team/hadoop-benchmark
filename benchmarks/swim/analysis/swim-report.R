#!/usr/bin/env Rscript

library(tidyverse, warn.conflicts=FALSE, quietly=TRUE)
library(Hmisc, warn.conflicts=FALSE, quietly=TRUE)

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("Missing directory name with the sets")
}

parse_ts <- function(pattern, x) {
  lines <- grep(pattern, x, value=TRUE)
  lines <- sub(pattern, "\\1", lines)

  as.numeric(strptime(lines, "%a %b %e %X UTC %Y", tz="GMT"))
}

parse_log <- function(f) {
  lines <- readLines(f)
  job <- as.numeric(sub("job-(\\d+)\\.txt", "\\1", basename(f)))
  started <- parse_ts("Job started:\\s+(.+)\\s*$", lines)
  ended <- parse_ts("Job ended:\\s+(.+)\\s*$", lines)

  if (length(job) != 1) {
    message("Invalid log file name", f)
    return(NA)
  }
  if (length(started) != 1) {
    message("Invalid job start timestamp", f)
    return(NA)
  }
  if (length(ended) != 1) {
    message("Invalid job end timestamp", f)
    return(NA)
  }

  data.frame(
    job=job,
    started=started,
    ended=ended
  )
}

ds <- lapply(list.dirs(args[1], recursive=FALSE), function(dir) {
  files <- list.files(dir, full.names=TRUE)
  data <- lapply(files, parse_log)
  data <- data[!is.na(data)]
  df <- do.call(rbind, data)
  start <- df[1, "started"]
  df %>%
    # normalize
    mutate(started=started-start, ended=ended-start, duration=ended-started) %>%
    # added set name
    mutate(set=basename(dir))
})

ds <- do.call(rbind, ds)

pdf("timeline.pdf")

# the coordinations are flipped so we can support the dodged possition
ggplot(ds, aes(x=job, xmin=job, xmax=job+.9, ymin=started, ymax=ended, fill=set)) +
  geom_rect(position="dodge") +
  ylab("Time (s)")+
  xlab("Job id") +
  ggtitle("Execution Time Line") +
  theme_bw() +
  coord_flip()

pdf("execution-time.pdf")

ggplot(ds, aes(x=job, y=duration, fill=set)) +
  geom_bar(stat="identity", position="dodge") +
  ylab("Time (s)")+
  xlab("Job id") +
  ggtitle("Job Execution Time") +
  theme_bw()

dev.off()
