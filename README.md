git-notify
=========

Simple script that checks all your local repositories and sends email to your team with the recent changes.

Install
==
Edit your copy of the script, then

	cp -a git-notify.sh /usr/local/bin/
	echo "59 23 * * 7 root /usr/local/bin/git-notify.sh" >> /etc/crontab
