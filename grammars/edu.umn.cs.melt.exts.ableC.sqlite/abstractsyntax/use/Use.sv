grammar edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:use;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
imports edu:umn:cs:melt:ableC:concretesyntax as cnc;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax:tables;

abstract production sqliteUse
top::Stmt ::= dbFilename::Expr dbName::Name tableList::SqliteTableList
{
  -- _new_sqlite_db(${dbFilename});
  local callNew :: Expr =
    directCallExpr(
      name("_new_sqlite_db", location=abs:builtin),
      foldExpr([
        dbFilename
      ]),
      location=abs:builtin
    );

  -- _sqlite_db ${dbName} = _new_sqlite_db(${dbFilename});
  local dbDecl :: Stmt =
    declStmt(
      variableDecls(
        nilStorageClass(),
        nilAttribute(),
        abs:sqliteDbTypeExpr(tableList.tables),
        foldDeclarator([
          declarator(
            dbName,
            baseTypeExpr(),
            nilAttribute(),
            justInitializer(exprInitializer(callNew, location=abs:builtin)))
        ])
      )
    );

  forwards to dbDecl;
}
