#!/usr/bin/env Rscript

library(ggplot2)

a=read.table("all-jobs-duration-static.txt")
b=read.table("all-jobs-duration-dynamic.txt")

pdf("compare.pdf")

plot(0)

ggplot()+geom_point(aes(x=a[,1],y=a[,2]),col="red",pch=3)+geom_point(aes(x=b[,1],y=b[,2]),col="blue",pch=3)+theme_bw()+ylab("Job Completion Time (s)")+xlab("Job id")

legend("topleft",legend=c("Static Cluster","Self-Adaptation Cluster"), col=c("red","blue"),pch=15)

dev.off()
