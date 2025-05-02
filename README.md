# Using Google Sheets API with Zsh/Bash

In many of the zsh/bash scripts I've written, I've found the ability to append to Google Sheets via the Sheets API extremely valuable.  This repo contains some of the methods I've used for using this API with zsh/bash.  Start with authorization/authentication, then check out some of the scripts I have for reading/writing data.

## Authorization/Authentication
To start, you'll need to set up proper authorization with the Google Cloud Console.  I have steps in the [setting-up-authorization.sh](https://github.com/garrettthorn/Zsh-Google-Sheets-Api/blob/main/setting-up-authorization.sh) file in this repo.  

Once you obtain a refresh token, you'll be able to hardcode these credentials into your script so the script will be able to obtain a new access token each time the script executes.

Of course, storing credentials in plain-text is always a bad idea, even on a hardened machine.  So do this at your own risk.

## Appending Data to Rows
One of the most basic function is when you'd like to append some data to the bottom of a row.  This is by far the simplest function, where you're essentially just defining the sheet name, sheet id, and range; then passing over all the data.  You can find this in the [append-row.sh](https://github.com/garrettthorn/Zsh-Google-Sheets-Api/blob/main/append-row.sh) file in this repo.

## Downloading CSVs
Often, I need to download Google Sheets as CSVs so I can parse the data inside them using awk.  The [download-sheet.sh](https://github.com/garrettthorn/Zsh-Google-Sheets-Api/blob/main/download-sheet.sh) file in this repo explains how to do this and save the CSV locally on your machine.  Note that you can download public sheets without needing a refreshed access token, but you'll need one to download sheets that are private to your account or those that have been shared with you.

## Update Specific Rows
After you have downloaded a CSV, you can parse it using awk.  This will allow you to find a row number and update all the values for the row number.  In the [update-specific-rows.sh](https://github.com/garrettthorn/Zsh-Google-Sheets-Api/blob/main/update-specific-rows.sh) file in this repo, I go through an example of updating information using the Google Sheets API when passed a specific row number/column range to send the updates to.

## Notes

 - All my testing was done on macOS 15+
	 - jq is referenced in a few of the scripts; which is natively installed in macOS 15, but not in earlier versions
 - I got a lot of my information from [this article](https://sysopstechnix.com/insert-data-into-google-sheets-via-oauth-2-0-using-shell-script/) on setting up all the authorization stuff.
 - When passing data to the Sheets API, it's pretty important you URL encode it.  I don't have any references to this in any of these scripts, but I've used jq and also sed/awk in the past for this.
