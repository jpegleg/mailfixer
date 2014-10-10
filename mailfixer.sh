#!/bin/bash

# Mail files and log files are the number one and number two reasons servers fill up.
# This script deals with mail files specifically. There are two options
# This one removes the mail files:
# sudo ./mailfixer.sh remove
# This one stores the mail files in a tarball.
# sudo ./mailfixer.sh archive

SESH=$(date +"%m-%d-%y-%s")
mkdir /var/mailfixer/ 2> /dev/null

function mailremove () {
  for x in $(ls /var/mail); do
      cp /dev/null /var/spool/mail/"$x"
  done
  for x in $(ls /var/mail/postfix/); do
      cd /var/spool/postfix/"$x"
      for a in $(ls); do
           cp /dev/null "$a"
      done
  done
}

function mailarchive () {
  for x in $(ls /var/spool/mail); do
      cp /var/mail/"$x" /var/mail/"$x".$SESH.backup &&
      gzip /var/mail/"$x".$SESH.backup &&
      cp /dev/null /var/mail/"$x"
  done
  for x in $(ls /var/spool/postfix/); do
      cd /var/spool/postfix/"$x"
      for a in $(ls); do
           cp -r "$a" /var/spool/postfix/"$a".$SESH.backup &&
           gzip /var/spool/postfix/"$a".$SESH.backup &&
           cp /dev/null "$a"
      done
      ls /var/spool/postfix/
  done

  cd /var/mailfixer/
  mkdir backup-mail 2> /dev/null
  mkdir backup-postfix-mail 2> /dev/null
  mv /var/mail/*backup.gz backup-mail/
  mv /var/spool/postfix/*backup.gz backup-postfix-mail/
  tar -czvf mail.$SESH.backup.tar.gz backup-mail/  &&
  tar -czvf postfix.$SESH.baskup.tar.gz backup-postfix-mail/
  echo "Mail has been backed up to /var/mailfixer/mail.$SESH.backup.tar.gz"
  echo "Postfix mail has been backed up to /var/mailfixer/postfix.$SESH.baskup.tar.gz"
  rm -f /var/spool/mail/*"$SESH" /var/spool/postfix/*"$SESH"*
  rm -rf /var/mailfixer/backup-mail/ /var/mailfixer/backup-postfix-mail/ 

}

case "$1" in
remove)
mailremove
;;
archive)
mailarchive
;;
*)
echo "Usage: sudo ./mailfixer.sh option";
echo "Options are remove or archive."
exit 1;
esac
