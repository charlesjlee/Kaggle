# Written by user demytt
# https://www.kaggle.com/c/packing-santas-sleigh/forums/t/6544/evaluation-metric-using-r

getScore = function(submission){
  submission_Z = submission[,c(1,4,7,10,13,16,19,22,25)]
  submission_Z$maxZ = apply(submission_Z[, 2:ncol(submission_Z)], 1, max)
  submission_Z = submission_Z[order(-submission_Z$maxZ,submission_Z$PresentId),]
  submission_Z$presentOrder = 1:nrow(submission_Z)
  return (2*max(submission_Z$maxZ) + sum(abs(submission_Z$PresentId - submission_Z$presentOrder)))
}

benchmark = read.table("Benchmarks/MATLAB_Packing_Submission_File.csv", h = T, sep = ",")
getScore(benchmark) #5270836
