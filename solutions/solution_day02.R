# read file "input_day02.txt" and store it in lines as a variable
lines <- readLines("inputs/input_day02.txt")

# dictionary that maps rock, paper, scissors to their respective numbers
points <- c("rock" = 1, "paper" = 2, "scissors" = 3, "lost" = 0, "draw" = 3, "won" = 6)

letter_to_symbol <- c("A" = "rock", "B" = "paper", "C" = "scissors", "X" = "rock", "Y" = "paper", "Z" = "scissors")

# function that returns the winner of a game
# input: two strings, each representing a move
# output: a string, either "won", "lost" or "draw"
get_winner <- function(move1, move2) {
  if (move1 == move2) {
    return("draw")
  }
  if (move1 == "rock") {
    if (move2 == "paper") {
      return("lost")
    } else {
      return("won")
    }
  }
  if (move1 == "paper") {
    if (move2 == "scissors") {
      return("lost")
    } else {
      return("won")
    }
  }
  if (move1 == "scissors") {
    if (move2 == "rock") {
      return("lost")
    } else {
      return("won")
    }
  }
}

# function that returns the score of a game
# input: two strings, each representing a move
# output: an integer, the sum of the the points of the move1 and the points of the game result
get_score <- function(move1, move2) {
  return(points[move1] + points[get_winner(move1, move2)])
}

# function that returns the result for a line
# a line has the format as "A Y" these values
# needs to be transformed into moves and then the score needs to be calculated
# input: a string, representing a line
# output: an integer, the score of the line
get_result <- function(line) {
  moves <- strsplit(line, " ")[[1]]
  return(get_score(letter_to_symbol[moves[2]], letter_to_symbol[moves[1]]))
}


# function that returns the total score of all lines
# input: a vector of strings, each representing a line
# output: an integer, the total score of all lines
get_total_score <- function(lines) {
  return(sum(sapply(lines, get_result)))
}

# print the result
print(get_total_score(lines))

# function that returns move1 
# given the move2 and the result
# input: two strings, one representing a move and one representing a result
# output: a string, representing a move
get_move1 <- function(move2, result) {
  if (result == "won") {
    if (move2 == "rock") {
      return("paper")
    }
    if (move2 == "paper") {
      return("scissors")
    }
    if (move2 == "scissors") {
      return("rock")
    }
  }
  if (result == "lost") {
    if (move2 == "rock") {
      return("scissors")
    }
    if (move2 == "paper") {
      return("rock")
    }
    if (move2 == "scissors") {
      return("paper")
    }
  }
  if (result == "draw") {
    return(move2)
  }
}

# function get_score2 that returns the score of a game
# input: two strings, each representing a move and a result
# output: an integer, the sum of the the points of the move1 and the points of the game result
get_score2 <- function(move2, result) {
  return(points[get_move1(move2, result)] + points[result])
}


# redefine letter_to_symbol mapping X,Y,Z to lost, draw, won
letter_to_symbol = c("A" = "rock", "B" = "paper", "C" = "scissors", "X" = "lost", "Y" = "draw", "Z" = "won")

# function that returns the result for a line
# a line has the format as "A Y" these values
# needs to be transformed into moves and then the score needs to be calculated
# input: a string, representing a line
# output: an integer, the score of the line
get_result2 <- function(line) {
  moves <- strsplit(line, " ")[[1]]
  return(get_score2(letter_to_symbol[moves[1]], letter_to_symbol[moves[2]]))
}

# write test get_result2
# the result for the following
# "A Y" -> 4
# "B X" -> 1
# "C Z" -> 7
test_lines <- c("A Y", "B X", "C Z")
test_res <- c(4, 1, 7)
test_res == sapply(test_lines, get_result2)

debug(get_result2)
get_result2((test_lines[1]))

# "A Y" -> 4




# "B X" -> 1
# "C Z" -> 7

lines <- c("A Y", "B X", "C Z")
res


moves = strsplit(lines[1], " ")[[1]]


letter_to_symbol[moves[2]], letter_to_symbol[moves[1]]

# function that returns the total score of all lines
# input: a vector of strings, each representing a line
# output: an integer, the total score of all lines
get_total_score2 <- function(lines) {
  return(sum(sapply(lines, get_result2)))
}

# print the result
print(get_total_score2(lines))
