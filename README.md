# Elvish Test

A testing utility for the elvish programming language.

Install by:

```Elvish
use epm
epm:install github.com/silly-internet-tricks/elvish-test
```

Example usage:

```Elvish
use github.com/silly-internet-tricks/elvish-test/elvish-test
elvish-test:run [[$eq~ "two equals two" [2 2] $true] [$eq~ "two does not equal 4" [2 4] $false]]
```

