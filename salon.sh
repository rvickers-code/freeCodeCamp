#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon ~~~~~\n"
SERVICES=$($PSQL "select * from services;")

MAIN_MENU () {
  echo "Here are the services we offer:"
  echo "$SERVICES" | while read ID BAR SERVICE
  do
    echo -e "$ID) $SERVICE"
  done
  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED_RESULT=$($PSQL "select * from services where service_id='$SERVICE_ID_SELECTED';")
  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
  then
    echo -e  "Please select a valid service.\n"
    MAIN_MENU
  else
    echo "What is you phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo What is your name?
      read CUSTOMER_NAME
      CUSTOMER_INSERT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
    echo When would you like to have your appointment?
    read SERVICE_TIME
    APPOINTMENTS_INSERT=$($PSQL "insert into appointments(customer_id,service_id,time) values('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME');")
    SERVICE=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED';")
    echo I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.
  fi
}


MAIN_MENU

