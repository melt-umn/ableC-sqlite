#include <sqlite.xh>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* clear the database and repopulate it */

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

  on db commit { DELETE FROM person };
  on db commit { DELETE FROM details };

  on db commit { INSERT INTO person VALUES (0, 'Aaron',    'Allen') };
  on db commit { INSERT INTO person VALUES (1, 'Abigail',  'Adams') };
  on db commit { INSERT INTO person VALUES (2, 'Benjamin', 'Brown') };
  on db commit { INSERT INTO person VALUES (3, 'Belle',    'Bailey') };

  on db commit { INSERT INTO details VALUES (0,  5, 'M') };
  on db commit { INSERT INTO details VALUES (1, 15, 'F') };
  on db commit { INSERT INTO details VALUES (2, 25, 'M') };
  on db commit { INSERT INTO details VALUES (3, 35, 'F') };

  db_exit(db);

  return 0;
}

