#!/usr/bin/env bats
# Tests for bin/okr-config

BIN="./bin/okr-config"

setup() {
  export OKR_CONFIG_DIR=$(mktemp -d)
}

teardown() {
  rm -rf "$OKR_CONFIG_DIR"
}

@test "set creates config file and key" {
  run $BIN set test_key test_value
  [ "$status" -eq 0 ]
  [ -f "$OKR_CONFIG_DIR/config" ]
  grep -q "test_key=test_value" "$OKR_CONFIG_DIR/config"
}

@test "get retrieves existing key" {
  $BIN set mykey myvalue
  run $BIN get mykey
  [ "$status" -eq 0 ]
  [ "$output" = "myvalue" ]
}

@test "get missing key exits 1" {
  run $BIN get nonexistent
  [ "$status" -eq 1 ]
}

@test "set overwrites existing key" {
  $BIN set color red
  $BIN set color blue
  run $BIN get color
  [ "$status" -eq 0 ]
  [ "$output" = "blue" ]
}

@test "set preserves other keys" {
  $BIN set key1 val1
  $BIN set key2 val2
  $BIN set key1 updated
  run $BIN get key2
  [ "$status" -eq 0 ]
  [ "$output" = "val2" ]
}

@test "get from nonexistent config file exits 1" {
  rm -f "$OKR_CONFIG_DIR/config"
  run $BIN get anything
  [ "$status" -eq 1 ]
}

@test "no args prints usage" {
  run $BIN
  [ "$status" -ne 0 ]
}

@test "set with spaces in value" {
  $BIN set message "hello world"
  run $BIN get message
  [ "$status" -eq 0 ]
  [ "$output" = "hello world" ]
}
