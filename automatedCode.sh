#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# Define the issue ID to search for
#ISSUE_ID="ZOOKEEPER-1045"
ISSUE_ID=$1
TEST_METHOD=$2

  
# Fetch all branches and updates
git fetch --all

# Search for commits related to the issue ID
COMMITS=$(git log --grep="$ISSUE_ID" --format="%H %s" | awk '{print $1}')
  
# Check if any commits were found
if [ -z "$COMMITS" ]; then
  echo "No commits found for issue ID $ISSUE_ID"
  exit 1
fi  

# Create or clear the report file
# Create or clear the report file
REPORT_FILE="commit_report.txt"
csv_file="test_results.csv"

echo "File Name,Total Tests,Successes,Failures,Errors,Skipped,Total Time (seconds)" > "$csv_file"

> $REPORT_FILE
  
# Print the commit hashes and messages to the report file
echo "Commits related to $ISSUE_ID:" > $REPORT_FILE
for COMMIT in $COMMITS; do
  git checkout $COMMIT
  COMMIT_DETAILS=$(git show $COMMIT --oneline --name-only)
  JAVA_CLASS=$(echo "$COMMIT_DETAILS" | grep ".java") 
  MODULE_NAME=$(echo "$JAVA_CLASS" | awk -F'/src/' '{print $1}')
  TEST_CLASS_PATH=$(echo "$JAVA_CLASS" | awk -F'src/test/java/' '{print $NF}' | sed 's/\//./g' | sed 's/.java$//')
  echo "Test Class Path $TEST_CLASS_PATH"
  #mvn clean install -DskipTests -pl $MODULE_NAME -am
  for ((i=1;i<=10;i++)); do
      echo "Iteration Running $i / 10 : $(date)"
      mvn -pl $MODULE_NAME test -Dtest=$TEST_CLASS_PATH#$TEST_METHOD | tee mvn-test-$i.log
      
      for g in $(egrep "^Running|^\[INFO\] Running " mvn-test-$i.log | rev | cut -d' ' -f1 | rev); do   
          f=$(find . -name "TEST-${g}.xml" -not -path "*target/surefire-reports/junitreports/*");
          fcount=$(echo "$f" | wc -l); 
          echo "Value of - f: $f"
          
          for xml_file in $f; do
              echo "Processing $xml_file"
    	      testcase_count=$(xmllint --xpath 'count(//testcase)' "$xml_file")
              echo "Number of test cases: $testcase_count"

	      #testsuite=$(xmllint --xpath '//testsuite' "$xml_file")
      	      #total_tests=$(xmllint --xpath '//@tests' <<< "$testsuite")
              #total_failures=$(xmllint --xpath '//@failures' <<< "$testsuite")
              #total_errors=$(xmllint --xpath '//@errors' <<< "$testsuite")
              #total_skipped=$(xmllint --xpath '//@skipped' <<< "$testsuite")
              #total_time=$(xmllint --xpath '//@time' <<< "$testsuite")

              total_tests=$(xmllint --xpath 'string(//testsuite/@tests)' "$xml_file")
              total_failures=$(xmllint --xpath 'string(//testsuite/@failures)' "$xml_file")
              total_errors=$(xmllint --xpath 'string(//testsuite/@errors)' "$xml_file")
              total_skipped=$(xmllint --xpath 'string(//testsuite/@skipped)' "$xml_file")
              total_success=$(xmllint --xpath 'string(//testsuite/@tests - //testsuite/@failures - //testsuite/@errors - //testsuite/@skipped)' "$xml_file")
              total_time=$(xmllint --xpath 'string(//testsuite/@time)' "$xml_file") 


	      echo "$xml_file,$total_tests,$total_success,$total_failures,$total_errors,$total_skipped,$total_time" >> "$csv_file"
              #echo "Total Tests: $total_tests"
              #echo "Total Success: $total_success"
              #echo "Total Failures: $total_failures"
              #echo "Total Errors: $total_errors"
              #echo "Total Skipped: $total_skipped"
              #echo "Total Time (seconds): $total_time"
          done
      done

      mkdir -p /Users/mderfan/camel/AutoScriptResult/isolation/$i
      mv mvn-test-$i.log /Users/mderfan/camel/AutoScriptResult/isolation/$i
  done 
  echo "CSV file created "$csv_file" with test results."
  echo "JAVA CLASS  $JAVA_CLASS"
  echo "MODULE NAME $MODULE_NAME"
  echo "$COMMIT" >> $REPORT_FILE
  echo "$COMMIT_DETAILS" >> $REPORT_FILE
done


