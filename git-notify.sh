#!/bin/bash
# send email with the latest changes from all repositories.
# Ivan Dimitrov https://github.com/dobber
# for Ancient Media Ltd.

mailer="/usr/bin/mail"
repodir="/home/git/repositories/"
prettyf="%an <%ae> - %s"
from="From: root@${HOSTNAME}" # $HOSTNAME must be FQDN
email="your@email.addr"
template="Here is a list of changes in all repositories in out git"
subject="Weekly list of git changes"
period="1.week"

###### DO NOT EDIT BELOW THIS LINE ########
index=0
debug=0

function generate_email {
        if [ $index -eq 0 ] ; then
                mail="$template
"
                index=1

        fi
        mail="$mail

$1
$2
=============================================="
}

function just_print {
	echo "  ::      $1 ::"
	echo "$2"
	echo "=============================================="
}

case "$1" in
	dry-run)
		debug=1
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
                        generate_email "${repo}" "${out}"
                else
			just_print "${repo}" "${out}"
                fi
        fi

        unset out
done

if [ $debug -eq 0 ] ; then
        echo "${mail}" | ${mailer} -s "${subject}" "${email}"
fi
