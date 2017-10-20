// Note: exception handling is left aside for clarity.
import std.stdio;
import d2sqlite3;
import std.typecons : Nullable;

unittest
{
	assert(1 + 2 == 3);
	auto arr = [1, 2, 3];
	assert(arr.length == 4); // 間違ってるけど Emacs が教えてくれる！
}

unittest
{
	// このコードはunittestでコンパイルされた時のみ実行される
	writeln("this is unittest code");
	//assert(add(1,2) == 3); // error
	writeln("test clear");
}

version (unittest)
{
}
else
	int main()
{
	writeln("start!");
	// Open a database in memory.
	auto db = Database(":memory:");

	// Create a table
	db.run("DROP TABLE IF EXISTS person;
        CREATE TABLE person (
          id    INTEGER PRIMARY KEY,
          name  TEXT NOT NULL,
          score FLOAT
        )");

	// Prepare an INSERT statement
	Statement statement = db.prepare("INSERT INTO person (name, score)
     VALUES (:name, :score)");

	// Bind values one by one (by parameter name or index)
	statement.bind(":name", "John");
	statement.bind(2, 77.5);
	statement.execute();
	statement.reset(); // Need to reset the statement after execution.

	// Bind muliple values at the same time
	statement.bindAll("John", null);
	statement.execute();
	statement.reset();

	// Bind, execute and reset in one call
	statement.inject("Clara", 88.1);

	// Count the changes
	assert(db.totalChanges == 3);

	// Count the Johns in the table.
	auto count = db.execute("SELECT count(*) FROM person WHERE name == 'John'").oneValue!long;
	assert(count == 2);

	// Read the data from the table lazily
	ResultRange results = db.execute("SELECT * FROM person");
	foreach (Row row; results)
	{
		// Retrieve "id", which is the column at index 0, and contains an int,
		// e.g. using the peek function (best performance).
		auto id = row.peek!long(0);

		// Retrieve "name", e.g. using opIndex(string), which returns a ColumnData.
		auto name = row["name"].as!string;
		writeln(name);

		// Retrieve "score", which is at index 2, e.g. using the peek function,
		// using a Nullable type
		//auto score = row.peek!(Nullable!double)(2);
		auto score = row["score"].as!(Nullable!double);
		//score2.nullify();
		if (!score.isNull)
		{
			writeln(score);
		}
		else
		{
			writeln("<NULL>");
		}
	}
	return 0;
}
