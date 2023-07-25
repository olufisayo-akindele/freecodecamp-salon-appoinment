#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
 if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  if [[ ! $AVAILABLE_SERVICES ]]
  then 
  echo "service not available"
  else 
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    read SERVICE_ID_SELECTED
    if [[ $SERVICE_ID_SELECTED =~ [^0-9] ]]
    then
     MAIN_MENU "You need to input a number e.g 1,2,3"
     else
      SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED ")
      if [[ ! $SERVICE_AVAILABLE ]]
        then
         MAIN_MENU "I could not find that service. What would you like today?"
         else
         echo -e "\nWhat's your phone number?"
         read CUSTOMER_PHONE
         CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
         if [[ ! $CUSTOMER_NAME ]]
         then
            echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi  
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        if [[ $SERVICE_TIME ]]
        then
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
          echo -e "\n\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        
        fi 
      fi
    fi 
  fi
}
MAIN_MENU
