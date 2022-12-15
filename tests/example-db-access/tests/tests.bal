import ballerina/test;

@test:Config {}
function checkExactInsertValue() {
    boolean connected = dbConnet("./tests/gofigure");
    test:assertEquals(connected, true);
}
