#!/bin/bash

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

  mvn -pl $MODULE_NAME test -Dtest=$TEST_CLASS_PATH#$TEST_METHOD >> $REPORT_FILE 

  echo "JAVA CLASS  $JAVA_CLASS"
  echo "MODULE NAME $MODULE_NAME"
  echo "$COMMIT" >> $REPORT_FILE
  echo "$COMMIT_DETAILS" >> $REPORT_FILE
done


