#! /bin/zsh

#this script will walk you through everything you need to do to append data to a Google Sheet using the Sheets API.
#this assumes you have already set up authorization, check setting-up-authorization.sh in this repo for more information on this

####################################functions & global variables############################################################################################################
refreshToken="YOUR REFRESH TOKEN HERE"
clientId="YOUR CLIENT ID HERE"
clientSecret="YOUR CLIENT SECRET HERE"
googleSheetId="1k6hwdSj3hQ7bxs8iCRlASfwCu2zkm2p4vrWQEriqFXQ"
googleSheetName="Sheet1"
googleSheetRange="A:J"


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



#function to append values to row via Google Sheet API
#pass the values you wish to append to the sheet; adjust the number of values based on how many items you need to post to the sheet
appendRow() {

  #1 : API Token - The access token returned from the json response requesting a new token
  #2 : Sheet ID - The ID of the Google Sheet you want to append to - this can be found in the URL
  #3 : Sheet Name - The name of the Google Sheet you want to append to - at the bottom of the page (by default it's Sheet1)
  #4 : Sheet Range - The range of columns you'd like to update within the row - ex. A:C updates columns A, B, and C.

  local apiToken="$1"
  local sheetId="$2"
  local sheetName="$3"
  local sheetRange="$4"

  result=$(curl "https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/$sheetName!$sheetRange:append?insertDataOption=INSERT_ROWS&valueInputOption=USER_ENTERED" \
  --request POST \
  -H "Authorization: Bearer $apiToken" \
  -H "Content-Type: application/json" \
  -d "{\"values\": [[\"$5\", \"$6\", \"$7\", \"$8\", \"$9\", \"${10}\", \"${11}\", \"${12}\", \"${13}\", \"${14}\"]]}")

  echo $result

}


####################################MAIN############################################################################################################

#obtain our access token
sheetsAccessToken=$( getSheetsAPIAuthToken "$refreshToken" "$clientId" "$clientSecret" )

#for a very basic example, let's say we're trying to populate the row with details about the Macbook Pro M4
apiResponse=$( appendRow "$sheetsAccessToken" "$googleSheetId" "$googleSheetName" "$googleSheetRange" "Apple" "Macbook Pro" "M4" "14-inch" "16GB" "256GB" "Space Black" "10 Cores" "A3112" "2024" )

#see what the response from the API is
echo $apiResponse