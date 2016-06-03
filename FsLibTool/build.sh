#!/bin/bash -e

if hash xbuild &> /dev/null ; then
  BUILD=xbuild
  RUN=mono
elif hash msbuild.exe &> /dev/null ; then
  BUILD=msbuild.exe
  RUN=
else
  echo "Couldn't find build command."
  exit 1
fi

PAKET=.paket/paket.exe

if [ ! -f $PAKET ] ; then
  $RUN .paket/paket.bootstrapper.exe
  chmod +x $PAKET
fi

$RUN $PAKET install

for SOLUTION in *.sln ; do
  for CONFIG in Debug Release ; do
    $BUILD /nologo /verbosity:quiet /p:Configuration=$CONFIG $SOLUTION
  done
done

for TEMPLATE in *.paket.template ; do
  if [ -f $TEMPLATE ] ; then
    $RUN $PAKET pack output . templatefile $TEMPLATE
  fi
done
