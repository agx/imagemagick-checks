#!/bin/bash

RET=0
FAILURES=0
TEMPDIR=$(mktemp -d)
function cleanup() {
    rm -rf $TEMPDIR
}
trap cleanup EXIT


function check_inputs() {
  for f in inputs/openlogo-100.*; do
    basename=$(basename $f)
    convert $f $TEMPDIR/$(echo $basename | sed -e 's,\.[a-z]\+,.png,')
    if [ $? -ne 0 ]; then
      echo "E: Conversion of $f to png failed." >&2
      RET=1
    fi
  done
  return $RET
}


# MPC is special since it's not stable between imagemagick versions
# http://www.imagemagick.org/Usage/files/#mpc
function check_mpc() {
  convert inputs/openlogo-100.png $TEMPDIR/openlogo-100.mpc
  convert $TEMPDIR/openlogo-100.mpc $TEMPDIR/openlogo-100.png
  if [ $? -ne 0 ]; then
      echo "E: MPC round trip failed." >&2
      return 1
  fi
}


for check in check_inputs check_mpc; do
   CHECKS=$((CHECKS+1))
   if ! $check; then
     FAILURES=$((FAILURES+1))
   fi
done

echo "Run $CHECKS checks with $FAILURES failures."
exit $FAILURES
