fn make-test { |function-under-test test-name test-input expected|
  # the function under test must be passed in as variable
  # so, if the function was defined with fn
  # it has to be passed in as $fn-name~
  var test-function = {
    var test = [
      &test-name=$test-name
      &expected=$expected
    ]

    try {
      put (assoc $test actual ($function-under-test $@test-input))
    } catch e { fail (assoc $test message $e) }
  }

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

fn run-tests { |tests|
  var test-runs = (map-over { |test|
    var status = "error"
    var test-result = [&]
    # TODO: capture output
    try {
      set test-result = ($test)
    } catch e {
      # for future reference, here is a sample of an error I got back 😁
      # [^exception &reason=[^fail-error &content=[&expected=Whatever. &message=[^exception &reason=<unknown variable $solution:hey~ not found> &stack-trace=<...>] &test-name='stating something'] &type=fail] &stack-trace=<...>]
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
      &test-name=$test-result[test-name]
      &status=$status
    ]

    var message = ok

    if (eq $status "fail") {
      set message = "Expected \""(echo $test-result[expected])"\", but got \""(echo $test-result[actual])"\"!"
    }

    if (eq $status "error") {
      set message = (echo $test-result[message][reason])
    }

    if (not-eq $status "pass") {
      set final-test-result = (assoc $final-test-result message $message)
    }

    put $final-test-result
  } $tests)

  put $test-runs
}

fn get-run-status { |test-runs|
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

  put $status
}

fn print-status { |status|
  var style = [blue]
  if (eq $status pass) {
    set style = [green]
  } elif (eq $status fail) {
    set style = [red]
  } elif (eq $status error) {
    set style = [red bold]
  }

  echo (styled $status $@style)
}

fn pretty-print { |status tests|
  print "run status: "
  print-status $status

  for test-run $tests {
    print "  "$test-run[test-name]": "
    print-status $test-run[status]
    if (not-eq $test-run[status] pass) {
      echo "    "$test-run[message]
    }
  }
}

fn run { |test-data|
  var tests = []
  for td $test-data {
    set tests = (append $tests (make-test $@td))
  }

  var test-runs = (run-tests $tests)
  pretty-print (get-run-status $test-runs) $test-runs
}


