input <- readLines("day1.R/input.txt")

input <- as.numeric(input)

elve <- 0
elves <- c()

for(i in input){
    if(is.na(i)){
        elves <- append(elves, c(elve))
        elve <- 0
    } else {
        elve <- elve + i
    }
}

elves <- sort(elves, decreasing=TRUE)

sum(elves[1:3])
