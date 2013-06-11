#!/bin/bash
# send email with the latest changes from all repositories.
# Ivan Dimitrov https://github.com/dobber
# for Ancient Media Ltd.

repodir=/home/git/repositories/
prettyf="%an - %s"
email=your@email.addr
template="Here is a list of changes in all repositories in out git"
subject="Weekly list of git changes"
period="1.week"

###### DO NOT EDIT BELOW THIS LINE ########
index=0

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

for repo in `ls ${repodir}/` ; do
	out=`git --git-dir=${repodir}${repo} log --since=${period} --pretty="${prettyf}"`
	if [ -n "$out" ] ; then
		generate_email "${repo}" "${out}"
	fi

	unset out
done

echo "${mail}" | mail -s "${subject}" "${email}"
