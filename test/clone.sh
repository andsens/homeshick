#!/bin/bash

function testCloning() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	assertSame "\`clone' did not exit with status 0" 0 $?
}

function tearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
}

source $SHUNIT2
