#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GET_USER_NAME() {
  echo "Enter your username:"
  read USER_NAME

  CHECK_USER_NAME $USER_NAME
}

CHECK_USER_NAME() {
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$1';")

  if [[ -z $USER_ID ]]
    then
        echo "Welcome, $1! It looks like this is your first time here."
        INSERT_USER $1
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$1';")
    else
        GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id='$USER_ID';")
        BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id='$USER_ID';")
        echo "Welcome back, $1! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  PLAY_GAME $USER_ID
}

INSERT_USER() {
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$1');")
}

PLAY_GAME() {
  USER_ID=$1
  RANDOM_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  NUMBER_OF_TRIES=0

  while true; do

    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
      continue
    fi

    NUMBER_OF_TRIES=$((NUMBER_OF_TRIES+1))

    if [ "$RANDOM_NUMBER" -eq "$GUESS" ]; then
      echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      break
    elif [ "$RANDOM_NUMBER" -lt "$GUESS" ]; then
      echo "It's lower than that, guess again:"
      read GUESS
    else
      echo "It's higher than that, guess again:"
      read GUESS
    fi

  done

  SAVE_PROGRESS $USER_ID $NUMBER_OF_TRIES
}

SAVE_PROGRESS() {
  UPDATE=$($PSQL "UPDATE users
              SET games_played = games_played + 1,
              best_game = CASE 
                WHEN best_game IS NULL OR $2 < best_game 
                  THEN $2 
                  ELSE best_game
                END
              WHERE user_id = $1;")
}

GET_USER_NAME