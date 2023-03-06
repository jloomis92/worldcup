#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear both tables before running script
echo -e "Truncating all tables before execution..."
echo $($PSQL "TRUNCATE TABLE games, teams")
echo -e "\n=== BEGIN SCRIPT OUTPUT ===\n"


### BEGIN ADDING TEAMS TO TEAMS TABLE ###
# Read winner and opponent columns from csv and insert into teams table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" && $OPPONENT != "opponent" ]]
  then
    WINNER_TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    if [[ -z $WINNER_TEAM_NAME ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    OPPONENT_TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    if [[ -z $OPPONENT_TEAM_NAME ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then 
        echo Inserted into teams, $OPPONENT
      else
        echo Cannot add duplicate entries to this table. Skipping...
      fi
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi
  ### END ADDING TEAMS TO TEAMS TABLE ###

  ### BEGIN ADDING GAME DATA TO GAMES TABLE ###
  if [[ $YEAR != "year" && $ROUND != "round" && $WINNER_ID != "winner" && $OPPONENT_ID != "opponent" && $WINNER_GOALS != "winner_goals" && $OPPONENT_GOALS != "opponent_goals" ]]
  then
    INSERT_GAME_DATA=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ INSERT_GAME_DATA == "INSERT 0 1" ]]
    then
      echo "Inserted into games, $YEAR : $ROUND : $WINNER_ID : $OPPONENT_ID : $WINNER_GOALS : $OPPONENT_GOALS"
    fi
  fi
  ### END ADDING GAME DATA TO GAMES TABLE ###
done
