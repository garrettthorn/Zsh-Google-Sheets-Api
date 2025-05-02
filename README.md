# Using Google Sheets API with Zsh/Bash

In many of the zsh/bash scripts I've written, I've found the ability to append to Google Sheets via the Sheets API extremely valuable.  This repo contains some of the methods I've used for using this API with zsh/bash.  Start with authorization/authentication, then check out some of the scripts I have for reading/writing data.

## Authorization/Authentication
To start, you'll need to set up proper authorization with the Google Cloud Console.  I have steps in the [setting-up-authorization.sh](https://github.com/garrettthorn/Zsh-Google-Sheets-Api/blob/main/setting-up-authorization.sh) file in this repo.  

Once you obtain a refresh token, you'll be able to hardcode these credentials into your script so the script will be able to obtain a new access token each time the script executes.

Of course, storing credentials in plain-text is always a bad idea, even on a hardened machine.  So do this at your own risk.

## Appending Data to Rows
One of the most basic function is when you'd like to append some data to the bottom of a row.  This is by far the simplest function, where you're essentially just defining the sheet name, sheet id, and range; then passing over all the data.  You can find this in the [append-row.sh](https://github.com/garrettthorn/Zsh-Google-Sheets-Api/blob/main/append-row.sh) file in this repo.

## More to come!

## Notes

 - All my testing was done on macOS 15+
	 - jq is referenced in a few of the scripts; which is natively installed in macOS 15, but not in earlier versions
 - I got a lot of my information from [this article](https://sysopstechnix.com/insert-data-into-google-sheets-via-oauth-2-0-using-shell-script/) on setting up all the authorization stuff.
 - When passing data to the Sheets API, it's pretty important you URL encode it.  I don't have any references to this in any of these scripts, but I've used jq and also sed/awk in the past for this.