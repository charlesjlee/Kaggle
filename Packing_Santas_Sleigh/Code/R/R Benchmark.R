# Written by user Thakur Raj Anand
# https://www.kaggle.com/c/packing-santas-sleigh/forums/t/6581/here-comes-the-r-code-for-benchmark

presents = read.csv("Data/presents.csv")

numPresents = nrow(presents)

presentIDs = presents[,1]
presentWidth = presents[,2]
presentLength = presents[,3]
presentHeight = presents[,4]

presentVol = presentWidth*presentLength*presentHeight
minVol = min(presentVol)
maxVol = max(presentVol)

sleighWidth = 1000
sleighLength = 1000

xs = 1
ys = 1
zs = 1


lastRowIdxs = rep(0,1000)
lastLayerIdxs = rep(0,1000)

numInRow = 0
numInLayer = 0

presentCoords = data.frame(PresentId = rep(0,numPresents), x1 = rep(0,numPresents), y1 = rep(0,numPresents), z1 = rep(0,numPresents), x2 = rep(0,numPresents), y2 = rep(0,numPresents), z2 = rep(0,numPresents), x3 = rep(0,numPresents), y3 = rep(0,numPresents), z3 = rep(0,numPresents), x4 = rep(0,numPresents), y4 = rep(0,numPresents), z4 = rep(0,numPresents), x5 = rep(0,numPresents), y5 = rep(0,numPresents), z5 = rep(0,numPresents), x6 = rep(0,numPresents), y6 = rep(0,numPresents), z6 = rep(0,numPresents), x7 = rep(0,numPresents), y7 = rep(0,numPresents), z7 = rep(0,numPresents), x8 = rep(0,numPresents), y8 = rep(0,numPresents), z8 = rep(0,numPresents))

for (i in 1:numPresents) {
  if (xs + presentWidth[i] > sleighWidth + 1){
    # exceeded allowable width
    ys = ys + max(presentLength[lastRowIdxs[1:numInRow]]) # increment y to ensure no overlap
    xs = 1
    numInRow = 1
  }
  else if(ys + presentLength[i] > sleighLength + 1){
    # exceeded allowable length
    zs = zs - max(presentHeight[lastLayerIdxs[1:numInLayer]]) # increment z to ensure no overlap
    xs = 1
    ys = 1
    numInLayer = 0
  }
  # Fill present coordinate matrix
  presentCoords[i,1] = presentIDs[i]
  presentCoords[i,c(2,8,14,20)] = xs
  presentCoords[i,c(5,11,17,23)] = xs + presentWidth[i] - 1
  presentCoords[i,c(3,6,15,18)] = ys
  presentCoords[i,c(9,12,21,24)] = ys + presentLength[i] - 1
  presentCoords[i,c(4,7,10,13)] = zs
  presentCoords[i,c(16,19,22,25)] = zs - presentHeight[i] + 1
  
  # Update location info
  xs = xs + presentWidth[i]
  numInRow = numInRow + 1
  numInLayer = numInLayer + 1
  lastRowIdxs[numInRow] = presentIDs[i]
  lastLayerIdxs[numInLayer] = presentIDs[i]
}
  
# We started at z = -1 and went downward, need to shift so all z-values >= 1
zCoords = presentCoords[,c(4,7,10,13,16,19,22,25)]
minZ = min(presentCoords$z1,presentCoords$z2,presentCoords$z3,presentCoords$z4,presentCoords$z5,presentCoords$z6,presentCoords$z7,presentCoords$z8)
presentCoords[,c(4,7,10,13,16,19,22,25)] = zCoords - minZ + 1
  
  
# Evaluation metric
  abc <- function(presentCoords1){
  presentsCoords1 = presentCoords1[,c(1,4,7,10,13,16,19,22,25)]
  presentCoords1$maxZ = max(presentCoords1$z1,presentCoords1$z2,presentCoords1$z3,presentCoords1$z4,presentCoords1$z5,presentCoords1$z6,presentCoords1$z7,presentCoords1$z8)
  presentCoords1[with(presentCoords1, order(maxZ,PresentId)),]
  presentCoords1$presentOrder = 1:nrow(presentCoords1)
  return(presentCoords1)
}

abc1 <- abc(presentCoords)
score <- 2*max(abc1$maxZ + sum(abs(abc1$PresentId - abc1$presentOrder)))
paste("Evaluation metric score is: ",score)

solution <- abc1[,1:25]

write.csv(solution,file="Submissions/output.csv",row.names=FALSE)