#include <sqlite.xh>
#include <stdio.h>

/* syntax error */
int main(void)
{
  use "test.db" with {
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR )
  } as db;

  on db query {
    SELECT * FROM
  } as from_what;

  db_exit(db);

  return 0;
}

