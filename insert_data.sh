#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

team_values=""
game_values=""

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  team_values+="('$winner'), ('$opponent'),"
  game_values+="($year, '$round', '$winner', '$opponent', $winner_goals, $opponent_goals),"
done < <(tail -n +2 games.csv)

$PSQL "INSERT INTO teams(name) VALUES ${team_values%,} ON CONFLICT (name) DO NOTHING" > /dev/null
$PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT data.year, data.round, winning_team.team_id, opposing_team.team_id, data.winner_goals, data.opponent_goals FROM (VALUES ${game_values%,}) AS data(year, round, winner, opponent, winner_goals, opponent_goals) JOIN teams AS winning_team ON winning_team.name = data.winner JOIN teams AS opposing_team ON opposing_team.name = data.opponent" > /dev/null
