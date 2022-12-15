import ballerinax/java.jdbc;

function dbConnet(string dbFilePath) returns boolean {
    jdbc:Client|error dbClient = new ("jdbc:h2:file:" + dbFilePath, "root", "root");
    if dbClient is jdbc:Client {
        return true;
    }
    return false;
}
