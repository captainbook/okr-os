#!/usr/bin/env bats
# Tests for bin/okr-quarter-info

BIN="./bin/okr-quarter-info"

@test "current date returns valid output" {
  run $BIN
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER:"* ]]
  [[ "$output" == *"YEAR:"* ]]
  [[ "$output" == *"WEEK:"* ]]
  [[ "$output" == *"PHASE:"* ]]
}

@test "Jan 1 is Q1 week 1 early phase" {
  run $BIN --date 2026-01-01
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER: Q1"* ]]
  [[ "$output" == *"WEEK: 1"* ]]
  [[ "$output" == *"PHASE: early"* ]]
}

@test "March 31 is Q1 final phase" {
  run $BIN --date 2026-03-31
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER: Q1"* ]]
  [[ "$output" == *"PHASE: final"* ]]
}

@test "April 1 is Q2 week 1" {
  run $BIN --date 2026-04-01
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER: Q2"* ]]
  [[ "$output" == *"WEEK: 1"* ]]
}

@test "July 1 is Q3" {
  run $BIN --date 2026-07-01
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER: Q3"* ]]
}

@test "Oct 1 is Q4" {
  run $BIN --date 2026-10-01
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER: Q4"* ]]
}

@test "Dec 31 is Q4 final" {
  run $BIN --date 2026-12-31
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER: Q4"* ]]
  [[ "$output" == *"PHASE: final"* ]]
}

@test "fiscal year offset: April start, July = Q1" {
  run $BIN --date 2026-07-01 --quarter-start 4
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER: Q2"* ]]
}

@test "fiscal year offset: April start, January = Q4" {
  run $BIN --date 2027-01-15 --quarter-start 4
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER: Q4"* ]]
}

@test "invalid date exits 1" {
  run $BIN --date "not-a-date"
  [ "$status" -eq 1 ]
}

@test "invalid quarter-start exits 1" {
  run $BIN --quarter-start 13
  [ "$status" -eq 1 ]
}

@test "mid-quarter has correct phase" {
  run $BIN --date 2026-05-15
  [ "$status" -eq 0 ]
  [[ "$output" == *"PHASE: mid"* ]]
}

@test "late quarter phase" {
  run $BIN --date 2026-06-15
  [ "$status" -eq 0 ]
  [[ "$output" == *"PHASE: late"* ]]
}

@test "weeks_remaining is non-negative" {
  run $BIN
  [ "$status" -eq 0 ]
  weeks=$(echo "$output" | grep "WEEKS_REMAINING:" | awk '{print $2}')
  [ "$weeks" -ge 0 ]
}

@test "days_remaining is non-negative" {
  run $BIN
  [ "$status" -eq 0 ]
  days=$(echo "$output" | grep "DAYS_REMAINING:" | awk '{print $2}')
  [ "$days" -ge 0 ]
}
