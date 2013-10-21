#!/bin/bash
# send email with the latest changes from all repositories.
# Ivan Dimitrov https://github.com/dobber
# for Ancient Media Ltd.

mailer="/usr/bin/bsd-mailx"
repodir="/home/git/repositories/"
from="From: root@${HOSTNAME}" # $HOSTNAME must be FQDN
email="your@email.addr"
template="Here is a list of changes in all repositories in our git"
subject="Weekly list of git changes"
period="1.week"
web="http://gitlab.bastun.net/"

###### DO NOT EDIT BELOW THIS LINE ########
prettyf="<tr><td><a href=\"${web}/u/USER/\">%an</a></td><td><a href=\"${web}/USER/REPO/commit/%H\">%s</a></td></tr>"
index=0
debug=0

function generate_email {
	user=$1
	repo=$2
	message=$3

	message=`echo ${message} | sed -e s/USER/${user}/g`
	message=`echo ${message} | sed -e s/REPO/${repo}/g`
	if [ $index -eq 0 ] ; then
		mail="<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
		<html><head><title></title></head><body><p>
$template<br>"
		index=1
	fi

	mail="$mail<hr>
<table border=1>
<th colspan=2 align=\"center\"><a href=\"${web}/${user}/${repo}/commits/master\">${repo}</a></th>
${message}
</table>
"
}

function just_print {
	echo "  ::      $1 ::"
	echo "$2"
	echo "=============================================="
}

case "$1" in
	dry-run)
		debug=1
		prettyf="%an <%ae> - %s"
		;;
	help)
		echo $"Usage: $0 {help|dry-run|no-options}"
		exit 0
		;;
	no-options)
		echo "Actualy you can just run \`$0\` with no options and it will work too!"
		debug=0;
		;;
	*)
		debug=0
esac

if [ ! -d ${repodir} ] ; then
	echo "Repo dir does not exist"
	exit 0
fi

for user in `ls ${repodir}/` ; do
	for repo in `ls ${repodir}/${user}/` ; do
		out=`git --git-dir=${repodir}/${user}/${repo} log --since=${period} --pretty="${prettyf}"`
		reponame=`echo ${repo} | cut -f 1 -d.`
		if [ -n "$out" ] ; then
			if [ $debug -eq 0 ] ; then
#				out=`echo "${out}" | sed -e 's/$/<br>/g'`
				generate_email "${user}" "${reponame}" "${out}"
			else
				just_print "${reponame}" "${out}"
			fi
		fi
		unset out
	done
done

if [ $debug -eq 0 ] ; then
	mail="$mail</p></body></html>"
	echo "${mail}" | ${mailer} -a "${from}" -a "MIME-Version: 1.0" -a "Content-Type: text/html;charset=utf-8" -s "${subject}" "${email}"
fi
