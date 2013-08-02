#!/bin/bash
# send email with the latest changes from all repositories.
# Ivan Dimitrov https://github.com/dobber
# for Ancient Media Ltd.

mailer="/usr/bin/bsd-mailx"
repodir="/home/git/repositories/"
from="From: root@${HOSTNAME}" # $HOSTNAME must be FQDN
email="your@email.addr"
template="Here is a list of changes in all repositories in out git"
subject="Weekly list of git changes"
period="1.week"
web="http://git.bastun.net/gitweb/"

###### DO NOT EDIT BELOW THIS LINE ########
prettyf="<tr><td><a href=\"${web}/?p=REPO;s=%an;st=author\">%an</a></td><td><a href=\"${web}/?p=REPO;h=%H\">%s</a></td></tr>"
index=0
debug=0

function generate_email {
	repo=$1
	message=$2
	if [ $index -eq 0 ] ; then
		message=`echo ${message} | sed -e s/REPO/${repo}/g`
		mail="<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
<html><head><title></title></head><body><p>
$template<br>
"
	index=1

	fi
	mail="$mail<hr>
<table border=1>
<th colspan=2 align=\"center\"><a href=\"${web}/?p=${repo};a=summary\">${repo}</a></th>
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

for repo in `ls ${repodir}/` ; do
	out=`git --git-dir=${repodir}${repo} log --since=${period} --pretty="${prettyf}"`
	if [ -n "$out" ] ; then
		if [ $debug -eq 0 ] ; then
#			out=`echo "${out}" | sed -e 's/$/<br>/g'`
			generate_email "${repo}" "${out}"
		else
			just_print "${repo}" "${out}"
		fi
	fi

	unset out
done

if [ $debug -eq 0 ] ; then
	mail="$mail</p></body></html>"
	echo "${mail}" | ${mailer} -a "${from}" -a "MIME-Version: 1.0" -a "Content-Type: text/html" -s "${subject}" "${email}"
fi
