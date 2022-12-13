import ballerina/io;

type ExercismTestResult record {
    int 'version;
    string status;
    string message;
};

type TestItem record {
    string name?;
    string status?;
    string failureMessage?;
};

type ModuleStatusItem record {
    string name;
    int totalTests?;
    int passed?;
    int failed?;
    int skipped?;
    TestItem[] tests;
};

type SourceFilesItem record {
    string name?;
    int[] coveredLines?;
    int[] missedLines?;
    decimal coveragePercentage?;
    string sourceCode?;
};

type ModuleCoverageItem record {
    string name?;
    int coveredLines?;
    int missedLines?;
    decimal coveragePercentage?;
    SourceFilesItem[] sourceFiles?;
};

type BalTestReport record {
    string projectName?;
    int totalTests?;
    int passed;
    int failed;
    int skipped?;
    int coveredLines?;
    int missedLines?;
    decimal coveragePercentage?;
    ModuleStatusItem[] moduleStatus;
    ModuleCoverageItem[] moduleCoverage?;
};

string newline = "\n";

configurable string reportFile = "test-report-to-exercism-result/tests/resources/test_results.json";
configurable string transformedFile = "test-report-to-exercism-result/tests/resources/result.json";

function rdcMsg(string msg, TestItem i) returns string {
    return string `${msg}${newline}${i?.name ?: "Test"} || ${i?.failureMessage ?: "success"}`;
}

function rdcModules(TestItem[] i, ModuleStatusItem ms) returns TestItem[] {
    i.push(...ms?.tests);
    return i;
}

function transform(BalTestReport balTestReport) returns ExercismTestResult => {
    'version: 1,
    message: balTestReport?.moduleStatus.reduce(rdcModules, []).reduce(rdcMsg, string `::${balTestReport?.projectName ?: "Exercise"}::${newline}`),
    status: balTestReport.failed > 0 ? "fail" : "pass"
};

public function main() returns error? {
    io:println(`Transforming ${reportFile} ====> ${transformedFile}`);
    json reportJson = check io:fileReadJson(reportFile);
    BalTestReport testReport = check reportJson.fromJsonWithType(BalTestReport);

    ExercismTestResult et = transform(testReport);

    check io:fileWriteJson(transformedFile, et.toJson());
    io:println(`Transform complete: ${transformedFile}`);
}
