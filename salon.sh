#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

MAIN_MENU () {
  SERVICE_DATA=$($PSQL "SELECT * FROM services")
  echo "$SERVICE_DATA" | while IFS="|" read -r SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
  then 
    MAIN_MENU
  else
    SERVICE_AVAILABLE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_AVAILABLE ]]
    then
      MAIN_MENU 
    else
      ASK_INFO $SERVICE_ID_SELECTED
    fi
  fi
}

ASK_INFO () {
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo "I don't have a record of that number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_INFO_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
  echo "what time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT_INFO_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")

  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU 