# Chronic

[![Build Status](https://travis-ci.org/alexherbo2/chronic.svg)](https://travis-ci.org/alexherbo2/chronic)
[![IRC](https://img.shields.io/badge/IRC-%23chronic-blue)](https://webchat.freenode.net/#chronic)

Chronic is a natural language date-time parser for the command-line.

[![Chronic](https://img.youtube.com/vi_webp/P0m9RHs_0Wo/maxresdefault.webp)](https://youtube.com/playlist?list=PLdr-HcjEDx_nVgUW8io9HG39BDyp96u3s "YouTube – Chronic")
[![YouTube Play Button](https://www.iconfinder.com/icons/317714/download/png/16)](https://youtube.com/playlist?list=PLdr-HcjEDx_nVgUW8io9HG39BDyp96u3s) · [Chronic](https://youtube.com/playlist?list=PLdr-HcjEDx_nVgUW8io9HG39BDyp96u3s)

## Dependencies

- [Crystal]
- [date] (for [date input formats])
- [ripgrep] (Optional, for [`cg`](scripts/cg))

## Installation

``` sh
make build # Build bin/chronic
make install # Install bin/chronic and scripts into ~/.local/bin
```

### Editor integration

- [Kakoune][chronic.kak]

### Scripts

- [`at`](scripts/at)
- [`cg`](scripts/cg)

## Usage

```
[time = now] | chronic [format = %F %T]
  [--input | -i INPUT]
  [--days | -d DAYS] [--hours | -h HOURS] [--minutes | -m MINUTES] [--seconds | -s SECONDS]
  [--format | -f FORMAT] [--separator | -j SEPARATOR]
  [--sleep | -z]
  [--command | -x COMMAND]
  [--help]
```

### Syntax

```
<time> [+|plus] [relative-time] | chronic [format]
<start-time> [..|-|→|to] <end-time> | chronic [format]
<time> [::] <relative-time> | chronic [format]
```

### Examples

Simple:

``` sh
echo today | chronic
# 2020-02-02 19:00:00
```

Increment a day:

``` sh
echo 2020-02-02 + tomorrow | chronic '%F'
# 2020-02-03
```

Same with `--input` option:

``` sh
echo 2020-02-02 | chronic '%F' --input '%s + tomorrow'
# 2020-02-03
```

Create a new diary:

``` sh
echo 01 January to 31 December | chronic '# %F' > ~/documents/diary/2020.md
```

`~/documents/diary/2020.md`

``` markdown
# 2020-01-01
[…]
# 2020-12-31
```

Grep things to do over the next 7 days:

``` sh
grep $(chronic --input 'today → 7 days' 'TODO.+%F' --separator '|')
```

Regex:

```
TODO.+2020-02-02|TODO.+2020-02-03|TODO.+2020-02-04|TODO.+2020-02-05|TODO.+2020-02-06|TODO.+2020-02-07|TODO.+2020-02-08
```

Set up an alarm:

``` sh
echo Tomorrow 09:00 AM | chronic --sleep
mpv -shuffle ~/music
```

## Configuration

``` sh
alias p=echo
alias cr=chronic
```

## Options

```
--input / -i INPUT
  Set text input (Default: %s).  You can map stdin content with %s.

--days / -d DAYS
  Configure step in days (Default: 1).

--hours / -h HOURS
  Configure step in hours.

--minutes / -m MINUTES
  Configure step in minutes.

--seconds / -s SECONDS
  Configure step in seconds.

--format / -f FORMAT
  Set text format (Default: %s).

--separator / -j SEPARATOR
  Configure separator (Default: ␤).

--sleep / -z
  Sleep for the specified time span.

--command / -x COMMAND
  Execute command when the specified time passed.  Requires --sleep.

--help
  Display a help message and quit.
```

## References

- [Time::Format]
- [Date input formats]

[Crystal]: https://crystal-lang.org
[Time::Format]: https://crystal-lang.org/api/Time/Format.html
[date]: https://gnu.org/software/coreutils/manual/coreutils.html#date-invocation
[Date input formats]: https://gnu.org/software/coreutils/manual/coreutils.html#Date-input-formats
[ripgrep]: https://github.com/BurntSushi/ripgrep
[chronic.kak]: https://github.com/alexherbo2/chronic.kak
