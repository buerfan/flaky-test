csv_file="test_results_COLLECTIONS-661_FlakyVersionCode.csv"
echo "File Name,Total Tests,Successes,Failures,Errors,Skipped,Total Time (seconds)" > "$csv_file"
for ((i=1;i<=100;i++)); do
   echo "Iteration Running $i / 100 : $(date)"
   mvn test -Dtest=org.apache.commons.collections4.multimap.HashSetValuedHashMapTest | tee mvn-test-$i.log
   for g in $(egrep "^Running|^\[INFO\] Running " mvn-test-$i.log | rev | cut -d' ' -f1 | rev); do
     f=$(find . -name "TEST-${g}.xml" -not -path "target/surefire-reports/junitreports/");
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
   mkdir -p /Users/mderfan/FlakyTest/COLLECTIONS-661/FlakyVersionCode/isolation/$i
   mv mvn-test-$i.log /Users/mderfan/FlakyTest/COLLECTIONS-661/FlakyVersionCode/isolation/$i
 done
 echo "CSV file created "$csv_file" with test results."
