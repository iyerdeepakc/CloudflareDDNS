# CloudflareDDNS
A script that allows you to update your ip address for sites hosted in Cloudflare.

You'll need credentials from cloudflare and place them in an environment file! I've given a sample .env to help.
Call it whatever you want, keep it wherever you want. Just make sure you point to it in the script where it says "source."

You'll also need to create a log file, which is just a text file. Make sure it's pointed at the right spot in the script.

Finally add the script to crontab in order to run it at regular intervals.
Run it as often as you'd like. I don't have anything that needs to be highly available so I run it once every 10 minutes.

That's about it. Thanks!
