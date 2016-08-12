grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:use;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;

abstract production sqliteUse
top::Stmt ::= dbFilename::Expr dbName::Name tableList::SqliteTableList
{
  -- _new_sqlite_db(${dbFilename});
  local callNew :: Expr =
    directCallExpr(
      name("_new_sqlite_db", location=builtIn()),
      foldExpr([
        dbFilename
      ]),
      location=builtIn()
    );

  -- _sqlite_db ${dbName} = _new_sqlite_db(${dbFilename});
  local dbDecl :: Stmt =
    declStmt(
      variableDecls(
        [],
        [],
        abs:sqliteDbTypeExpr(tableList.tables),
        foldDeclarator([
          declarator(
            dbName,
            baseTypeExpr(),
            [],
            justInitializer(exprInitializer(callNew)))
        ])
      )
    );

  forwards to dbDecl;
}

-- TODO: don't duplicate this
-- New location for expressions which don't have real locations
abstract production builtIn
top::Location ::=
{
  forwards to loc("Built In", 0, 0, 0, 0, 0, 0);
}

