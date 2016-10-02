#!/bin/bash -eux

# ---
# --- name:    aws_key_pair_import.sh
# --- author:  ckell <sunckell@gmail.com>
# --- date:    Oct 1, 2016
# --- desc:    generate a valid key pair and upload to AWS
# ---
# --- TODO:
# ---

SCRIPT=`basename $0`


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
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""
  echo ""

}

# --- what did we get passed.
parse_cmd_line()
{
  SHOW_HELP="false"

  while [ "$#" -ne 0 ]; do
    case $1 in
      --help|-h)
        SHOW_HELP="true"; shift; shift;
      ;;
    esac
  done

  if [ ${SHOW_HELP} = "true" ]; then
    show_help
    exit 0
  fi
}

# --- a sane place to kick off the actions
main()
{
  parse_cmd_line "$@"
}

# --- do it!
main "$@"
