#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

# checking arguments
if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
else
  # check if the element is number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # finding the element
    ELEMENT=$($PSQL"SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                    FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id)
                    WHERE atomic_number=$1;")
  else
    # finding the element
    ELEMENT=$($PSQL"SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                    FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id)
                    WHERE symbol='$1' OR name='$1';")
  fi
  # if element not found
  if [[ -z $ELEMENT ]]
  then
    echo -e "I could not find that element in the database."
  else
    # print the element information
    echo $ELEMENT | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
    do
      echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi
