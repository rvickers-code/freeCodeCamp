#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESSING_GAME () {
  N=$(($RANDOM % 1000 + 1))
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again: 
    read GUESS
  done
  N_GUESS=1
  while (( GUESS != N ))
  do
    if (( GUESS > N ))
    then
      echo "It's lower than that, guess again:"
    elif (( GUESS < N ))
    then
      echo "It's higher than that, guess again:"
    fi
    read GUESS
    while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
      echo That is not an integer, guess again: 
      read GUESS
    done
    (( N_GUESS += 1 ))
  done
  echo You guessed it in $N_GUESS tries. The secret number was $N. Nice job!
  UPDATE_DB $N_GUESS
}

UPDATE_DB () {
  UPDATE_n_games=$($PSQL "UPDATE users set n_games=n_games+1 where username='$USERNAME';")
  PREV_BEST=$($PSQL "select best_game from users where username='$USERNAME';")
  if [[ -z $PREV_BEST || $1 -lt $PREV_BEST ]]
  then
    UPDATE_BEST=$($PSQL "update users set best_game=$1 where username='$USERNAME';")
  fi
}


echo "Enter your username:"
read USERNAME
QUERY_USER=$($PSQL "select * from users where username='$USERNAME';")
if [[ -z $QUERY_USER ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users VALUES('$USERNAME',0,NULL);")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  IFS='|' read -r u n b <<< $QUERY_USER
  echo Welcome back, $u! You have played $n games, and your best game took $b guesses.
fi

GUESSING_GAME