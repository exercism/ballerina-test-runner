#!/usr/bin/env sh

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: path to solution folder
# $3: path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug path/to/solution/folder/ path/to/output/directory/"
    exit 1
fi
slug="$1"
work_dir=$(pwd)
solution_dir=$(realpath "${2%/}")
output_dir=$(realpath "${3%/}")
results_file="${output_dir}/results.json"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"


# Run the tests for the provided implementation file
cd "$solution_dir" || exit
# Output is saved at this location
echo "==== ${slug}: testing..."
test_output=""
if ! [ -s *.bal ]; then
    test_output="WARNING: student did not add code to the balllerina file."
fi
if [ ! -e Ballerina.toml ]; then
    test_output="$test_output \n WARNING: student did not upload Ballerina.toml."
fi
if [ ! -e Dependencies.toml ]; then
    test_output="$test_output \n WARNING: student did not upload Dependencies.toml."
fi
# The `--code-coverage` flag generates a test_results.json file
# Capture err_msg from stderr output
{ err_msg="$(bal test --code-coverage 2>&1 1>&3 3>&-)"; } 3>&1;
if [ $? -ne 0 ]; then
    test_output="$test_output \n Compile Failed: \n $err_msg"
fi

echo "==== ${slug} test output:  $test_output"

test_output_file="$solution_dir/target/report/test_results.json"
if test -f "$test_output_file"; then

    # Write the results.json file based on the exit code of the command that was 
    # just executed that tested the implementation file
    failed=$(jq '.failed' $test_output_file)
    if [ $failed -eq 0 ]; then
        echo "${slug}: test passed"
        jq -n '{version: 1, status: "pass"}' > ${results_file}
    else
        echo "${slug}: test failed; formatting results"
        cd "$work_dir/bin/test-report-to-exercism-result" || exit
        bal run -- -CreportFile="$test_output_file" -CtransformedFile="$results_file"
    fi
else
    echo "${slug}: test failed; exporting output"
    jq -n --arg output "${test_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
fi


echo "${slug}: done"
