#!/bin/bash

# Mail files and log files are the number one and number two reasons servers fill up.
# This script deals with mail files specifically. There are two options
# This one removes the mail files:
# sudo ./mailfixer.sh remove
# This one stores the mail files in a tarball.
# sudo ./mailfixer.sh archive

SESH=$(date +"%m-%d-%y-%s")

function mailremove () {
  for x in $(ls /var/spool/mail); do
      cp /dev/null /var/spool/mail/"$x"
  done
  for x in $(ls /var/spool/postfix/); do
      cd /var/spool/postfix/"$x"
      for a in $(ls); do
           cp /dev/null "$a"
      done
  done
}

function mailarchive () {
  for x in $(ls /var/spool/mail); do
      cp /var/spool/mail/"$x" /var/spool/mail/"$x".$SESH.backup &&
      gzip /var/spool/mail/"$x".$SESH.backup &&
      cp /dev/null /var/spool/mail/"$x"
  done
  for x in $(ls /var/spool/postfix/); do
      cd /var/spool/postfix/"$x"
      for a in $(ls); do
           cp "$a" /var/spool/postfix/"$a".$SESH.backup &&
           gzip /var/spool/postfix/"$a".$SESH.backup &&
           cp /dev/null "$a"
      done
      ls /var/spool/postfix/
  done
  cd /var/spool/
  tar -czvf mail.$SESH.backup.tar.gz /var/spool/mail/*$SESH* /var/spool/postfix/*$SESH* &&
  echo "Mail has been backed up to /var/spool/mail.$SESH.backup.tar.gz"
  rm -f /var/spool/mail/*$SESH*
  rm -f /var/spool/postfix/*$SESH*

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
