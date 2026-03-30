#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# ask username
echo -e "Enter your username:"
read USERNAME
# get the user from the database
USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME';")

# if new user
if [[ -z $USER ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # insert to the database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
else
  echo $USER | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# generate a random number 1-1000
SECRET_NUMBER=500 # TESTING
# NUMBER=$(( 1 + RANDOM % 1000 ))

# ask to guess a number
echo -e "Guess the secret number between 1 and 1000:"
read GUESS
# if the input not a number
while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo -e "That is not an integer, guess again:"
  read GUESS
done
NUMBER_OF_GUESSES=1

# give hints
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))

  # if guess greater than secret number
  if [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo -e "It's lower than that, guess again:"
    read GUESS
  # if guess greater than secret number
  else
    echo -e "It's higher than that, guess again:"
    read GUESS
  fi
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo -e "That is not an integer, guess again:"
    read GUESS
  done
done
echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME';")
if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';")
fi
