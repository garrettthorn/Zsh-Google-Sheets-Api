#! /bin/zsh

#this script will allow you to download a Google Sheet locally to a computer as a csv file, which is helpful when you need to parse a Google Sheet to find data
#you can do this without needing an API token, if the Google Sheet is set to public.  Otherwise, the token is required to download

####################################functions & global variables############################################################################################################
refreshToken="YOUR REFRESH TOKEN HERE"
clientId="YOUR CLIENT ID HERE"
clientSecret="YOUR CLIENT SECRET HERE"
googleSheetId="1k6hwdSj3hQ7bxs8iCRlASfwCu2zkm2p4vrWQEriqFXQ"
#this will need to be URL encoded, for example the sheet "Financial Reports" would need to be formatted "Financial%20Reports"
googleSheetName="Sheet1"
csvFileLocation="/private/tmp/myFile.csv"


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


####################################MAIN############################################################################################################

#obtain our access token
sheetsAccessToken=$( getSheetsAPIAuthToken "$refreshToken" "$clientId" "$clientSecret" )

#pull down the sheetId and sheetName, and save them at the location provided at $csvFileLocation
curl "https://docs.google.com/spreadsheets/d/$googleSheetId/gviz/tq?tqx=out:csv&sheet=$googleSheetName" \
  --request GET \
  -o $csvFileLocation \
  -H "Authorization: Bearer $sheetsAccessToken"