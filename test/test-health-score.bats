#!/usr/bin/env bats
# Tests for bin/okr-health-score

BIN="./bin/okr-health-score"

setup() {
  export TEST_DIR=$(mktemp -d)
  mkdir -p "$TEST_DIR/quarters/Q1-2026/weekly"
}

teardown() {
  rm -rf "$TEST_DIR"
}

create_monday() {
  local week=$1
  local kr1_conf=${2:-5}
  local kr2_conf=${3:-5}
  local kr3_conf=${4:-5}
  local health_status=${5:-green}
  local date="2026-01-$(printf "%02d" $((week * 7)))"

  cat > "$TEST_DIR/quarters/Q1-2026/weekly/${date}-monday.md" << EOF
---
week: $week
date: $date
priorities:
  - text: "Task A"
    priority: P1
    status: done
  - text: "Task B"
    priority: P1
    status: done
  - text: "Task C"
    priority: P1
    status: not_done
confidence:
  kr1: $kr1_conf
  kr2: $kr2_conf
  kr3: $kr3_conf
health_metrics:
  - name: "Customer satisfaction"
    status: $health_status
  - name: "Code health"
    status: $health_status
code_red: false
forecast:
  - "Nothing special"
---

## Notes
Normal week.
EOF
}

@test "no --quarter flag prints usage" {
  run $BIN --okr-dir "$TEST_DIR"
  [ "$status" -eq 1 ]
}

@test "missing quarter dir exits 2" {
  run $BIN --quarter Q9-2099 --okr-dir "$TEST_DIR"
  [ "$status" -eq 2 ]
}

@test "insufficient data (0 weeks) exits 1" {
  run $BIN --quarter Q1-2026 --okr-dir "$TEST_DIR"
  [ "$status" -eq 1 ]
}

@test "insufficient data (1 week) exits 1" {
  create_monday 1
  run $BIN --quarter Q1-2026 --okr-dir "$TEST_DIR"
  [ "$status" -eq 1 ]
}

@test "2 weeks produces valid JSON" {
  create_monday 1 5 5 5
  create_monday 2 6 5 5
  run $BIN --quarter Q1-2026 --okr-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"score":'* ]]
  [[ "$output" == *'"cadence_adherence":'* ]]
  [[ "$output" == *'"confidence_trajectory":'* ]]
  [[ "$output" == *'"priority_completion":'* ]]
  [[ "$output" == *'"health_metric_stability":'* ]]
}

@test "score is between 0 and 100" {
  create_monday 1 5 5 5
  create_monday 2 6 6 6
  create_monday 3 7 7 7
  run $BIN --quarter Q1-2026 --okr-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  score=$(echo "$output" | grep -o '"score":[0-9]*' | cut -d: -f2)
  [ "$score" -ge 0 ]
  [ "$score" -le 100 ]
}

@test "all green health metrics = high stability" {
  create_monday 1 5 5 5 green
  create_monday 2 5 5 5 green
  create_monday 3 5 5 5 green
  run $BIN --quarter Q1-2026 --okr-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  stability=$(echo "$output" | grep -o '"health_metric_stability":[0-9]*' | cut -d: -f2)
  [ "$stability" -eq 100 ]
}

@test "yellow health metrics reduce stability" {
  create_monday 1 5 5 5 green
  create_monday 2 5 5 5 yellow
  create_monday 3 5 5 5 green
  run $BIN --quarter Q1-2026 --okr-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  stability=$(echo "$output" | grep -o '"health_metric_stability":[0-9]*' | cut -d: -f2)
  [ "$stability" -lt 100 ]
}

@test "rising confidence = higher trajectory" {
  create_monday 1 3 3 3
  create_monday 2 5 5 5
  create_monday 3 7 7 7
  run $BIN --quarter Q1-2026 --okr-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  trajectory=$(echo "$output" | grep -o '"confidence_trajectory":[0-9]*' | cut -d: -f2)
  [ "$trajectory" -ge 70 ]
}
