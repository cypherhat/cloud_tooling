#!/bin/bash

# ---
# --- name:    aws_key_pair_import.sh
# --- author:  ckell <sunckell@gmail.com>
# --- date:    Oct 1, 2016
# --- desc:    generate a valid key pair and upload to AWS
# ---
# --- TODO:
# ---

SCRIPT=`basename $0`
VERSION="0.0.1"

# --- what did we get passed.
parse_cmd_line()
{
  SHOW_HELP="false"
  while [ "$#" -ne 0 ];
  do
    case $1 in
      --help|-h)
        SHOW_HELP="true"; shift; shift
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
  echo "  Create and import a valid key pair to AWS."
  echo ""
  echo "  Mandatory arguments for long options are mandatory for short options."
  echo "  --help, -h"
  echo "      show the help screen"
  echo ""
  echo "  Exit status:"
  echo "     0        if OK,"
  echo "     1"
  echo ""
  echo "AUTHO"
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

# --- a sane place to kick off the actions
main()
{
  parse_cmd_line "$@"
}

# --- do it!
main "$@"
