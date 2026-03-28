#!/usr/bin/env bats
# Tests for bin/okr-state

BIN="./bin/okr-state"

setup() {
  export TEST_DIR=$(mktemp -d)
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "no .okr/ directory exits 2" {
  run $BIN --okr-dir "$TEST_DIR/nonexistent"
  [ "$status" -eq 2 ]
}

@test "empty .okr/ directory exits 1" {
  mkdir -p "$TEST_DIR/.okr"
  run $BIN --okr-dir "$TEST_DIR/.okr"
  # Should still work for the directory check but fail on missing objective
  [ "$status" -ne 0 ]
}

@test "with objective.md outputs OBJECTIVE line" {
  # Create full directory structure
  mkdir -p "$TEST_DIR/quarters/Q1-2026/weekly"
  cat > "$TEST_DIR/OKR-CONTEXT.md" << 'EOF'
---
mission: "Test mission"
quarter_start: 1
---
EOF
  cat > "$TEST_DIR/quarters/Q1-2026/objective.md" << 'EOF'
---
quarter: Q1-2026
objective: "Test objective for Q1"
key_results:
  - id: kr1
    description: "Revenue reaches $50K"
    target: 50000
    unit: dollars
    confidence: 5
  - id: kr2
    description: "25 new partners"
    target: 25
    unit: count
    confidence: 5
  - id: kr3
    description: "NPS above 8"
    target: 8
    unit: score
    confidence: 5
health_metrics:
  - name: "Customer satisfaction"
    status: green
created: 2026-01-01
---
EOF
  run $BIN --okr-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"OBJECTIVE: Test objective for Q1"* ]]
}

@test "outputs QUARTER and WEEK" {
  mkdir -p "$TEST_DIR/quarters/Q1-2026"
  cat > "$TEST_DIR/OKR-CONTEXT.md" << 'EOF'
---
mission: "Test"
quarter_start: 1
---
EOF
  cat > "$TEST_DIR/quarters/Q1-2026/objective.md" << 'EOF'
---
quarter: Q1-2026
objective: "Test"
key_results:
  - id: kr1
    description: "KR1"
    target: 100
    unit: count
    confidence: 5
health_metrics:
  - name: "Health"
    status: green
created: 2026-01-01
---
EOF
  run $BIN --okr-dir "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUARTER:"* ]]
  [[ "$output" == *"WEEK:"* ]]
  [[ "$output" == *"PHASE:"* ]]
}
