#!/usr/bin/env bash
/usr/local/bin/icalBuddy uncompletedTasks | sed -e "s/*/-/"
