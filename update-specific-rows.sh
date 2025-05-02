#! /bin/zsh

#in this script, i'll explain how I would find a key value and then update the rest of the values on that row using zsh/bash.
#let's say we have a Google Sheet that looks like this:
#
#   ID Number | Serial Number | Owner | 
#   -----------------------------------
#   12        | RX19P10FD     | Steve |
#   25        | RZ22X15KV     | Susan |
#   33        | BB12XPP7E     | Andy  |
#
#In this example, we want to find the ID number of 25 and update the serial number and owner from RZ22X15KV / Susan to P1X223Z32 / Jef
#See the main section of this script to see how we will accomplish this

####################################functions & global variables############################################################################################################
refreshToken="INSERT REFRESH TOKEN HERE"
clientId="INSERT CLIENT ID HERE"
clientSecret="INSERT CLIENT SECRET HERE"
googleSheetId="1AnIPWq3X_iwEq8dHul8_6a9MFgqTtMlf80Jg9F6Unwk"
#this will need to be URL encoded, for example the sheet "Financial Reports" would need to be formatted "Financial%20Reports"
googleSheetName="Sheet1"
csvFileLocation="/private/tmp/myFile.csv"
googleSheetStartColumn="B"
googleSheetEndColumn="C"


#function to get refreshed access_token from Google API
getSheetsAPIAuthToken() {

  #1 : Refresh Token - The refresh token from the Google Console Cloud that allows us to obtain a new access token
  #2 : Client ID - The client ID provided by Google Console Cloud
  #3 : Client Secret - The client secret provided by Google Console Cloud

  local refreshToken="$1"
  local clientId="$2"
  local clientSecret="$3"

  key=$(curl https://oauth2.googleapis.com/token \
  --request POST \
  --data "access_type=offline&refresh_token=$refreshToken&client_id=$clientId&client_secret=$clientSecret&grant_type=refresh_token")

  #remove carriage returns, newlines, and tabs from the json string
  key=$(echo "$key" | tr -d '\r' | tr -d '\n' | tr -d '\t')

  #use jq to determine asset_id from JSON response
  access_token=$( echo $key | jq -r ".access_token" )

  #return auth_token
  echo $access_token
}

#function that updates a specific row number on a specific sheet
updateSpecificRow() {

  #1 : Google Sheet ID - The ID of the Google Sheet, contained within the URL of your Google Sheet
  #2 : Edited Row Number - The row numbers (with column values and sheet name) you wish to make changes at
  #3 : API Key - The access token retrieved in order to use the Google Sheets API
  #4 : New Value 1 - The first new value you want to append
  #5 : New Value 2 - The second new value you want to append
  #NOTE : You can add virtually as many values as you'd like to this function to send more data; 
  #       just know you need to adjust your start and end column variables at the beginning of this script

  local sheetId="$1"
  local rowNumberEdited="$2"
  local apiKey="$3"
  local newValue1="$4"
  local newValue2="$5"

  result=$(curl "https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/$rowNumberEdited?valueInputOption=USER_ENTERED" \
  --request PUT \
  -H "Authorization: Bearer $apiKey" \
  -H "Content-Type: application/json" \
  -d "{\"values\": [[\"$newValue1\", \"$newValue2\"]]}")

  echo $result


}



####################################MAIN############################################################################################################

#obtain our access token
sheetsAccessToken=$( getSheetsAPIAuthToken "$refreshToken" "$clientId" "$clientSecret" )

#pull down the sheetId and sheetName, and save them at the location provided at $csvFileLocation; so we can parse with awk
curl "https://docs.google.com/spreadsheets/d/$googleSheetId/gviz/tq?tqx=out:csv&sheet=$googleSheetName" \
  --request GET \
  -o $csvFileLocation \
  -H "Authorization: Bearer $sheetsAccessToken"


#since we're looking for a value of 25 for our key value, we'll use 25 here
searchValue="25"

#use awk to determine the row number where you can find the provided value; if awk cannot find the value it will return an empty string
rowNumber=$(awk -v val="$searchValue" -F ',' '{gsub(/"/, ""); if ($1 == val) {print NR; exit}}' $csvFileLocation)

#error checking to ensure the number was found
if [ -z "$rowNumber" ]; then
  echo "Value could not be found."
  exit 1
fi

#Now we have the row number, we can create our editedRowNumber variable to define the specific place the data will be sent
editedRowNumber=$( echo "$googleSheetName!$googleSheetStartColumn$rowNumber:$googleSheetEndColumn$rowNumber" )

#now we can use the updateSpecificRow function to send our two new values to the sheet, replacing the old values
apiResult=$( updateSpecificRow "$googleSheetId" "$editedRowNumber" "$sheetsAccessToken" "P1X223Z32" "Jef" )

echo $apiResult