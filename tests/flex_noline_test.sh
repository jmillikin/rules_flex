#!/bin/bash

grep -E '#line [0-9]+' "$RUNFILES_DIR/$TEST_WORKSPACE/tests/top_c.c" || exit 0
exit 1
