#!/bin/bash

# Define the PSQL variable to simplify the command usage
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display services list
display_services() {
  echo "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Main program loop
while true; do
  # Display the list of services
  display_services

  # Prompt for the service_id
  echo "Please enter the service ID for the service you want:"
  read SERVICE_ID_SELECTED

  # Check if the selected service exists
  SERVICE_EXISTS=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_EXISTS ]]; then
    echo "Invalid service ID. Please select a valid service."
    continue
  fi

  # Prompt for customer's phone number
  echo "Please enter your phone number:"
  read CUSTOMER_PHONE

  # Check if the customer already exists in the database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # If the customer doesn't exist, prompt for their name and insert them into the customers table
  if [[ -z $CUSTOMER_ID ]]; then
    echo "It seems you're a new customer. Please enter your name:"
    read CUSTOMER_NAME

    # Insert the new customer into the customers table
    $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"

    # Fetch the newly inserted customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    # If the customer exists, get their name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi

  # Prompt for the appointment time
  echo "Please enter the time for your appointment (e.g., 10:30):"
  read SERVICE_TIME

  # Insert the appointment into the appointments table
  $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

  # Get the service name for the confirmation message
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # Output confirmation message
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  # Exit the loop
  break
done
