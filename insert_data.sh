#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Empty the rows in the tables
echo $($PSQL "TRUNCATE games, teams")

#read through the games file
cat games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; 

do
  #Get Winner name
  #If Winner does not = winner

  if [[ $WINNER != "winner" ]]; 
    then
      # Get winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      # If not found
      if [[ -z $WINNER_ID ]]; 
        then
        # Insert the winner into the teams table
        INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') RETURNING team_id")
      
      # Extract the inserted team_id
      WINNER_ID=$(echo $INSERT_WINNER_RESULT | cut -d ' ' -f 3)
      echo "Inserted into teams: $WINNER"
      fi
  fi

#Get Opponent name

  if [[ $OPPONENT != "opponent" ]]; 
    then
      # Get opponent_id
      OPPONENT_ID=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")

        # If not found
        if [[ -z $OPPONENT_ID ]]; 
          then
          # Insert the opponent into the teams table
          INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') RETURNING team_id")
            # Extract the inserted team_id
              OPPONENT_ID=$(echo $INSERT_OPPONENT_RESULT | cut -d ' ' -f 3)
              echo "Inserted into teams: $OPPONENT"
        fi
  fi

#Insert the Games
if [[ YEAR != "year" ]]
      then
        #Get WINNER_ID
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        #Get OPPONENT_ID
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        
        INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
          if [[ $INSERT_GAME == "INSERT 0 1" ]]
            then
              echo New game added: $YEAR, $ROUND, $WINNER_ID VS $OPPONENT_ID, score $WINNER_GOALS : $OPPONENT_GOALS
          fi
    fi
    
done