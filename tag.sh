#!/bin/bash
#
# Tagging script
#

VERSION=
BUILD_TAG=
GIT="git"
TITO="tito"
TITO_TAG_FLAGS=

GIT_ROOTS="pulp pulp_rpm pulp_puppet"
PACKAGES="
  pulp/platform/
  pulp/builtins/
  pulp/products/pulp-rpm-product/
  pulp_rpm/
  pulp_puppet/"

NEXT_VR_SCRIPT=\
$(cat << END
import sys
sys.path.insert(0, 'rel-eng/lib')
import tools
print tools.next()
END
)

set_version()
{
  pushd pulp
  VERSION=`python -c "$NEXT_VR_SCRIPT"`
  popd
}

tito_tag()
{
  pushd $1
  $TITO tag $TITO_TAG_FLAGS && $GIT push && $GIT push --tags
  if [ $? != 0 ]; then
    exit
  fi
  popd
}

git_tag()
{
  pushd $1
  $GIT tag -m "Build Tag" $BUILD_TAG && $GIT push --tags
  if [ $? != 0 ]; then
    exit
  fi
  popd
}

usage()
{
cat << EOF
usage: $0 options

This script tags all pulp projects

OPTIONS:
   -h      Show this message
   -v      The pulp version (eg: 0.0.332)
   -a      Auto accept the changelog
EOF
}

while getopts "hav:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    v)
      VERSION=$OPTARG
      ;;
    a)
      TITO_TAG_FLAGS="$TITO_TAG_FLAGS --accept-auto-changelog"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

# version based on main pulp project
# unless specified using -v
if [[ -z $VERSION ]]
then
  set_version
  if [ $? != 0 ]; then
    exit
  fi
fi

# confirmation
echo "Using:"
echo "  version [$VERSION]"
echo "  tito options: $TITO_TAG_FLAGS"
echo ""
read -p "Continue [y|n]: " ANS
if [ $ANS != "y" ]
then
  exit 0
fi

# used by tagger
PULP_VERSION_AND_RELEASE=$VERSION
export PULP_VERSION_AND_RELEASE

BUILD_TAG="build-$VERSION"

# tito tagging
for PACKAGE in $PACKAGES
do
  tito_tag $PACKAGE
done

# git (correlated build) tagging
for GIT_ROOT in $GIT_ROOTS
do
  git_tag $GIT_ROOT
done

