#!/bin/bash

set -e

SDIR=$(dirname "$0")

source $SDIR/../env.sh
source $SDIR/../utils.sh
source $SDIR/../channel.sh

createChannel