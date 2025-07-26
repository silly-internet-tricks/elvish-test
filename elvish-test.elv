# NOTE: the test and solution files should be copied to ./bin/test.elv and ./bin/solution.elv in bash before running this script

fn make-test { |name test-input expected|
  var test-function = {}
  eval "set test-function = {\n    var test = [\n      &name=\""$name"\"\n      &expected=\""$expected"\"\n    ]\n    try {\n      use ./solution\n      put (assoc $test actual (solution:hey \""$test-input"\"))\n    } catch error {\n      fail (assoc $test message $error)\n    }\n  }"
  put $test-function
}

fn append { |l e|
  put [$@l $e]
}

fn map-over { |f l|
  var map-over-result = []
  for e $l {
    set map-over-result = (append $map-over-result ($f $e))
  }

  put $map-over-result
}

fn fold { |f l acc|
  for e $l {
    set acc = ($f $e $acc)
  }

  put $acc
}

# TODO: handle errors when trying to import

use ./test
var tests = (test:tests)

# This file will produce a JSON output, that matches the spec here:
#     https://exercism.org/docs/building/tooling/test-runners/interface

var test-runs = (map-over { |test|
  var status = "error"
  var test-result = [&]
  # TODO: capture output
  try {
    set test-result = ($test)
  } catch e {
    # for future reference, here is a sample of an error I got back 😁
    # [^exception &reason=[^fail-error &content=[&expected=Whatever. &message=[^exception &reason=<unknown variable $solution:hey~ not found> &stack-trace=<...>] &name='stating something'] &type=fail] &stack-trace=<...>]
    set test-result = $e[reason][content]
    set status = "error"
  } else {
    if (eq $test-result[actual] $test-result[expected]) {
      set status = "pass"
    } else {
      set status = "fail"
    }
  }

  var final-test-result = [
    &name=$test-result[name]
    &status=$status
  ]

  var message = ok

  if (eq $status "fail") {
    set message = "Expected \""$test-result[expected]"\", but got \""$test-result[actual]"\"!"
  }

  if (eq $status "error") {
    set message = (echo $test-result[message][reason])
  }

  if (not-eq $status "pass") {
    set final-test-result = (assoc $final-test-result message $message)
  }

  put $final-test-result
} $tests)

# I believe that the only way the status should come back "error"
# is if the count of $test-runs is zero
var status = (fold { |e acc|
  if (or (eq $acc "fail") ^
             (or (eq $e[status] "fail") ^
                 (eq $e[status] "error"))) {
    put "fail"
  } elif (eq $e[status] "pass") {
    put "pass"
  } else {
    fail "invalid status"
  }
} $test-runs "error")

var output = [
  &status=$status
  &tests=$test-runs
]

# pretty print the output to console
# see source file at https://github.com/zzamboni/elvish-modules/blob/master/test.elv

fn print-status { |status|
  var style = blue
  if (eq $status pass) {
    set style = green
  } elif (eq $status fail) {
    set style = red
  } elif (eq $status error) {
    set style = red bold
  }

  echo (styled $status $style)
}

print "run status: "
print-status $output[status]

# now go through all of the test runs and print each of them

for test-run $output[tests] {
  print "  "$test-run[name]": "
  print-status $test-run[status]
  if (not-eq $test-run[status] pass) {
    echo "    "$test-run[message]
  }
}

