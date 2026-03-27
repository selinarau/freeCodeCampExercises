#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Salon ~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi
  # display a numbered list of services
  SERVICES=$($PSQL "SELECT * FROM services")
  # if no services
  if [[ -z $SERVICES ]]
  then
    echo -e "\nNo services available at the moment, try again later."
  else
    echo -e "\nList of services:"
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do 
      echo "$SERVICE_ID) $NAME"
    done
    # pick a service
    echo -e "\nWhich service would you like to have?"
    read SERVICE_ID_SELECTED
    # if not valid
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then 
      MAIN_MENU "That is not a valid service."
    else
      # check service exists
      SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_NAME_SELECTED ]]
      then 
        MAIN_MENU "That is not a valid service."
      else 
        # ask phone number
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        # get customer name and id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        # if not customer yet, add customer
        if [[ -z $CUSTOMER_ID ]]
        then
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        fi
        # ask time
        echo -e "\nWhat time would you like to have the appointment?"
        read SERVICE_TIME
        # insert appointment
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        # check appointment inserted
        if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
        then
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID" | sed -E 's/^ *| *$//g')
          SERVICE_NAME=$(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g')
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        else
          MAIN_MENU "\nSomething went wrong, please try again."
        fi
      fi
    fi
  fi
}

MAIN_MENU