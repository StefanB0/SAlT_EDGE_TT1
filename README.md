This is the exam task for SaltEdge Ruby courses.
Task coded by Boicu Stefan

To make the script run completely automatically, fill the desired login and password in the config file as string
``"login": "user",
"password": "user_password",``
if you leave it as 'null' you will need to introduce the login and password manually while the script runs.
You can also set so the browser closes by itself after running the script, by writting "true" after '"browser_close":' Default is "false".

For the rspec unit tests to work you need to fill in there the id of the playlist created after executing main.rb, a valid access token and your user id

I couldn't think how to make the unit tests for get_playlist and update methods easily reproductible on another PC so I scratched them, but as seen in the main script they work.
