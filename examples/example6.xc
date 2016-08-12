#include <sqlite.xh>
#include <stdio.h>

/* foreach error */
int main(void)
{
  use "test.db" with {
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR ),
    table details ( person_id  INTEGER,
                    age        INTEGER,
                    gender     VARCHAR )
  } as db;

  on db query {
    SELECT first_name, last_name FROM person
  } as people;

  foreach (person : people) {
    // person_id was not selected, even though it exists in the table
    printf("%d\n", person.person_id);
  }

  db_exit(db);

  return 0;
}

