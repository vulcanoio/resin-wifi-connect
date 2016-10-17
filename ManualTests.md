# Manual tests

## Test 1
 1. Retry flag = false
 2. No credentials stored
 3. Make sure the hotspot starts
 4. Set correct credentials
 5. Make sure it connects and then exits

## Test 2
 1. Retry flag = false
 2. Correct credentials stored
 3. Make sure it connects and then exits

## Test 3
 1. Retry flag = false
 2. No credentials stored
 3. Make sure the hotspot starts
 4. Set incorrect credentials
 5. Make sure it does not connect and then exits

## Test 4
 1. Retry flag = false
 2. Incorrect credentials stored
 3. Make sure it does not connect and then exits

## Test 5
 1. Retry flag = true
 2. No credentials stored
 3. Make sure the hotspot starts
 4. Set correct credentials
 5. Make sure it connects and then exits

## Test 6
 1. Retry flag = true
 2. Correct credentials stored
 3. Make sure it connects and then exits
 
## Test 7
 1. Retry flag = true
 2. No credentials stored
 3. Make sure the hotspot starts
 4. Set incorrect credentials
 5. Make sure it does not connect and go to Test 5, Step 3
 
## Test 8
 1. Retry flag = true
 2. Incorrect credentials stored
 3. Make sure it does not connect and go to Test 5, Step 3
