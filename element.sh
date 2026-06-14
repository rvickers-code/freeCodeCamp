#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z "$1" ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # get name, symbol, type, mass, melting poitn, boiling point (i.e. everything)
    QUERY_RES=$($PSQL "select * from elements e 
                  join properties p using(atomic_number) 
                  join types t using(type_id) 
                  where atomic_number='$1';")
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
  then
    QUERY_RES=$($PSQL "select * from elements e 
                  join properties p using(atomic_number) 
                  join types t using(type_id) 
                  where symbol='$1';")
  elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
  then
    QUERY_RES=$($PSQL "select * from elements e 
                  join properties p using(atomic_number) 
                  join types t using(type_id) 
                  where name='$1';")
  fi
  if [[ -z $QUERY_RES ]]
  then
    echo I could not find that element in the database.
  else
    IFS='|' read -r -a arr <<< "$QUERY_RES"
    echo "The element with atomic number ${arr[1]} is ${arr[3]} (${arr[2]}). \
It's a ${arr[7]}, with a mass of ${arr[4]} amu. \
${arr[3]} has a melting point of ${arr[5]} celsius and a boiling point of ${arr[6]} celsius."
  fi
fi