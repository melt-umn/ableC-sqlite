#include <sqlite.xh>
#include <stdio.h>

// Top level comment

/* syntax error */
int main(void)
{
  use "test.db" with {
    // This is a C comment, that should raise a syntax error.
    table person  ( person_id  INTEGER,
                    first_name VARCHAR,
                    last_name  VARCHAR ),
    
    table details ( person_id  INTEGER,
                    age        INTEGER,
                    gender     VARCHAR )
  } as db;

  on db commit { DELETE FROM person };

  db_exit(db);

  return 0;
}
