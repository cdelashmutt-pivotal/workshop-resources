#!/bin/bash

systemdomain=`cf api | sed 's/^.*https:\/\/api\.\([^ ]*\).*/\1/'`
appsdomain=`cf domains | head -n 3 | tail -n 1 | sed 's/\([^ ]*\).*/\1/'`

asciidoctor -a systemdomain=$systemdomain -a appsdomain=$appsdomain *.adoc
