#!/bin/bash

# ---
# --- name:    aws_key_pair_import.sh
# --- author:  ckell <sunckell@gmail.com>
# --- date:    Oct 1, 2016
# --- desc:    generate a valid key pair and upload to AWS
# ---
# --- TODO:
# ---

# --- global variables
SCRIPT=`basename $0`
VERSION="0.0.1"
HOSTNAME=`hostname`

# --- a simple logger to stdout
logger()
{
  mesg=$1
  echo "[`date`] - ${HOSTNAME} - ${SCRIPT} - ${mesg}"
}

# --- what did we get passed.
parse_cmd_line()
{
  SHOW_HELP="false"
  KEY_NAME="UNDEFINED"
  EMAIL_ADDR="UNDEFINED"
  KEY_PASSPHRASE=""

  while [ "$#" -ne 0 ];
  do
    case $1 in
      --help|-h)
        SHOW_HELP="true"; shift; shift
      ;;
      --name|-n)
        KEY_NAME="$2"; shift; shift;
      ;;
      --email|-e)
        EMAIL_ADDR="$2"; shift; shift;
      ;;
      --passphrase|-p)
        KEY_PASSPHRASE="$2"; shift; shift;
      ;;
      *)
        UNKNOWN_ACTION="true"; shift; shift
        echo " Unknow option."
        show_help
      ;;
     esac
  done

  if [ ${SHOW_HELP} = "true" ]; then
    show_help
    exit 0
  fi

  if [ ${EMAIL_ADDR} = "UNDEFINED" ]; then
    logger "ERROR: --email|-e flag not provided."
    exit 4
  fi

  if [ ${KEY_NAME} = "UNDEFINED" ]; then
    logger "ERROR: -name|-n flag not provided"
    exit 3
  fi

}
# --- show the information (help) about $0
show_help()
{
  echo ""
  echo "${SCRIPT}(1)"
  echo "NAME"
  echo "  ${SCRIPT} - generate a valid key pair and upload to AWS"
  echo ""
  echo "SYNOPSYS"
  echo "  ${SCRIPT} [OPTION]"
  echo ""
  echo "DESCRIPTION"
  echo "  Create and import a valid key pair to AWS using Hashicorp's terraform."
  echo ""
  echo "  Mandatory arguments for long options are mandatory for short options."
  echo "  --help, -h"
  echo "      show the help screen"
  echo "  --name key_name, -n key_name"
  echo "      required, name of the ssh key to create and import to AWS"
  echo "  --email email_address, -e email_address"
  echo "      required, email address to use when creating the ssh keys"
  echo "  --passphrase key_passphrase, -p key_passphrase"
  echo "      passphrase to use for the rsa key.  empty if blank."
  echo ""
  echo "  Exit status:"
  echo "     0        if OK,"
  echo "     1        generic system error,"
  echo "     3        name of ssh key not provided on command line,"
  echo "     4        email address not provided on command line,"
  echo "     5        aws credentials file not found,"
  echo "     6        hashicorp terraform not found,"
  echo "     7        ssh-keygen not found,"
  echo "     8        could not create key pair,"
  echo ""
  echo "AUTHOR"
  echo "    ckell <sunckell at that google mail site>"
  echo ""
  echo "REPORTING BUGS"
  echo "    https://github.com/sunckell/cloud_tooling/issues"
  echo ""
  echo "COPYRIGHT"
  echo "    Copyright © 2012 Free Software Foundation, Inc.  License GPLv3+: GNU GPL"
  echo "    version 3 or later <http://gnu.org/licenses/gpl.html>."
  echo "    This is free software: you are free to change and redistribute it."
  echo "    There is  NO WARRANTY, to the extent permitted by law."
  echo ""
  echo "CLOUD TOOLING ${VERSION}     Oct 2016                        ${SCRIPT}(1)"
  echo ""
}

# --- check around to make sure we can do what we want to do.
environment_checks()
{
  # --- check that aws is set up
  aws_credentials="${HOME}/.aws/credentials"
  if [ ! -f ${aws_credentials} ]; then
    logger "ERROR: aws credentials file not found."
    logger "INFO:  install awscli and run aws configure"
    exit 5
  fi

  # --- terraform?
  $(which terraform > /dev/null 2>&1)

  if [ $? -ne "0" ]; then
    logger "ERROR: terraform not found."
    logger "INFO:  install terraform to continue."
    exit 6
  fi

  # --- ssh?
  $(which ssh-keygen > /dev/null 2>&1)
  if [ $? -ne 0 ]; then
    logger "ERROR: ssh-keygen is not installed"
    logger "INFO:  install ssh to continue"
    exit 7
  fi

}

# -- use ssh-keygen to create a rsa key (AWS does not support DSA)
create_key_pair()
{
  logger "creating key pair"

  if [ ! -d ${HOME}/.ssh ]; then
    mkdir -p ${HOME}/.ssh
    if [ $? -ne 0 ]; then
      logger "ERROR: could not make directory ${HOME}/.ssh"
      exit 1
    fi

    chmod 700 ${HOME}/.ssh
    if [ $? -ne 0 ]; then
      logger "ERROR: could not change permissions on directory ${HOME}/.ssh"
      exit 1
    fi
  fi


  ssh-keygen -q -b 4096 -t rsa -N "${KEY_PASSPHRASE}" -C "${EMAIL_ADDR}" -f "${HOME}/.ssh/${KEY_NAME}"
  if [ $? -ne 0 ]; then
    logger "ERROR: could not create key pair"
    exit 8
  fi
}

# --- use the pub key to generate a terraform file to use during import
generate_tf_file()
{
  logger "generating terraform file"
  mkdir -p "/var/tmp/${SCRIPT}.$$"
  if [ $? -ne 0 ]; then
    logger "ERROR: could not make directory /var/tmp/${SCRIPT}.$$"
    exit 1
  fi

  pub_key=`cat ${HOME}/.ssh/${KEY_NAME}.pub`

  cat <<EOF > /var/tmp/${SCRIPT}.$$/aws_key_pair.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "${KEY_NAME}" {
  key_name = "${KEY_NAME}-key"
  public_key = "$pub_key"
}
EOF
}

# --- import the keyfile using terraform
import_key_pair()
{
  logger "importing the key pair using terraform"
  cd  /var/tmp/${SCRIPT}.$$
  #terraform import  aws_key_pair.${KEY_NAME} ${KEY_NAME}-key
  terraform apply
}

# --- a sane place to kick off the actions
main()
{
  parse_cmd_line "$@"
  environment_checks
  create_key_pair
  generate_tf_file
  import_key_pair
}

# --- do it!
main "$@"
