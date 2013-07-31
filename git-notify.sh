#!/bin/bash
# send email with the latest changes from all repositories.
# Ivan Dimitrov https://github.com/dobber
# for Ancient Media Ltd.

mailer="/usr/bin/bsd-mailx"
repodir="/home/git/repositories/"
from="From: root@${HOSTNAME}" # $HOSTNAME must be FQDN
email="admins@amln.net"
template="Here is a list of changes in all repositories in out git"
subject="Weekly list of git changes"
period="1.week"

###### DO NOT EDIT BELOW THIS LINE ########
index=0
debug=0

function generate_email {
	if [ $index -eq 0 ] ; then
		mail="<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
<html><head><title></title></head><body><p>
$template<br>
"
	index=1

	fi
	mail="$mail<br>
<br>
$1<br>
$2<br>
==============================================<br>"
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
		prettyf="<a href=\"%ae\">%an</a> %s"
		;;
	*)
		debug=0
		prettyf="<a href=\"%ae\">%an</a> %s"
esac

if [ ! -d ${repodir} ] ; then
	echo "Repo dir does not exist"
	exit 0
fi

for repo in `ls ${repodir}/` ; do
	out=`git --git-dir=${repodir}${repo} log --since=${period} --pretty="${prettyf}"`
	if [ -n "$out" ] ; then
		if [ $debug -eq 0 ] ; then
			out=`echo "${out}" | sed -e 's/$/<br>/g'`
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
