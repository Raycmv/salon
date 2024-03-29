#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nHow may I help you?" 
  echo -e "\n~~~ Services Menu ~~~"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED -ge 1 && $SERVICE_ID_SELECTED -le 4 ]]
  then 
    BOOK_SERVICES 
  else
    SERVICES_MENU "We don't have that service"
  fi
}

BOOK_SERVICES(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  echo -e "\nWhat time do you want the reservation?"
  read SERVICE_TIME
  if [[ SERVICE_TIME =~ ^[0-9]+* ]]
  then
    ($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED','$SERVICE_TIME')")
    SERVICES_VALUE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $SERVICES_VALUE at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    EXIT
  fi
}

EXIT() {
  echo -e "\nThank you for stopping by.\n"
}
SERVICES_MENU
