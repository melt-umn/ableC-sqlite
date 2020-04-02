#include <sqlite.xh>
#include <stdio.h>

int main(void)
{
  use "test.db" with {
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR ),
    -- This is a SQLite comment, that should not raise a syntax error.
    table details ( person_id  INTEGER,
                    age        INTEGER,
                    gender     VARCHAR )
  } as db;

  on db commit { DELETE FROM person };

  db_exit(db);

  return 0;
}
