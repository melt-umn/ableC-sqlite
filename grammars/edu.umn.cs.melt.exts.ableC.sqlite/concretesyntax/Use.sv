grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax;

import silver:langutil;

import edu:umn:cs:melt:ableC:concretesyntax as host_cnc;
import edu:umn:cs:melt:ableC:abstractsyntax:host as host_abs;
import edu:umn:cs:melt:ableC:abstractsyntax:construction as host_abs;

import edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;

marking terminal SqliteUse_t 'use' lexer classes {Ckeyword};

terminal SqliteLcAs_t 'as';
terminal SqliteLcWith_t 'with';
terminal SqliteTable_t 'table';
terminal SqliteVarchar_t 'VARCHAR';
terminal SqliteInteger_t 'INTEGER';

concrete production sqliteUse_c
top::host_cnc:Stmt_c ::= 'use' u::UseBit_c
{
  top.ast = u.ast;
}

nonterminal UseBit_c with ast<host_abs:Stmt>, location;

concrete production useBitExpr_c
top::UseBit_c ::= '(' dbFilename::host_cnc:Expr_c ')' tables::SqliteOptWithTables_c
                    'as' dbName::host_cnc:Identifier_t
{
  top.ast = abs:sqliteUse(dbFilename.ast, host_abs:fromId(dbName), tables.ast);
}

concrete production useBitId_c
top::UseBit_c ::= id::host_cnc:Identifier_t tables::SqliteOptWithTables_c
                    'as' dbName::host_cnc:Identifier_t
{
  top.ast = abs:sqliteUse(
              host_abs:declRefExpr(host_abs:fromId(id), location=top.location),
              host_abs:fromId(dbName), tables.ast);
}

concrete production useBitStringLit_c
top::UseBit_c ::= sl::host_cnc:StringConstant_t tables::SqliteOptWithTables_c
                    'as' dbName::host_cnc:Identifier_t
{
  top.ast = abs:sqliteUse(
              host_abs:stringLiteral(sl.lexeme, location=top.location),
              host_abs:fromId(dbName), tables.ast);
}

nonterminal SqliteOptWithTables_c with ast<abs:SqliteTableList>, location;
concrete productions top::SqliteOptWithTables_c
| 'with' '{' t::SqliteTableList_c '}'
  {
    top.ast = t.ast;
  }
|
  {
    top.ast = abs:sqliteNilTable();
  }

nonterminal SqliteTableList_c with ast<abs:SqliteTableList>, location;
concrete productions top::SqliteTableList_c
| ts::SqliteTableList_c ',' t::SqliteTable_c
  {
    top.ast = abs:sqliteConsTable(t.ast, ts.ast);
  }
| t::SqliteTable_c
  {
    top.ast = abs:sqliteConsTable(t.ast, abs:sqliteNilTable());
  }

nonterminal SqliteTable_c with ast<abs:SqliteTable>, location;
concrete productions top::SqliteTable_c
| 'table' n::host_cnc:Identifier_t '(' cs::SqliteColumnList_c ')'
  {
    top.ast = abs:sqliteTable(host_abs:fromId(n), cs.ast);
  }

nonterminal SqliteColumnList_c with ast<abs:SqliteColumnList>, location;
concrete productions top::SqliteColumnList_c
| cs::SqliteColumnList_c ',' c::SqliteColumn_c
  {
    top.ast = abs:sqliteConsColumn(c.ast, cs.ast);
  }
| c::SqliteColumn_c
  {
    top.ast = abs:sqliteConsColumn(c.ast, abs:sqliteNilColumn());
  }
|
  {
    top.ast = abs:sqliteNilColumn();
  }

nonterminal SqliteColumn_c with ast<abs:SqliteColumn>, location;
concrete productions top::SqliteColumn_c
| n::host_cnc:Identifier_t t::SqliteColumnType_c
  {
    top.ast = abs:sqliteColumn(host_abs:fromId(n), t.ast);
  }

nonterminal SqliteColumnType_c with ast<abs:SqliteColumnType>, location;
concrete productions top::SqliteColumnType_c
| 'VARCHAR'
  {
    top.ast = abs:sqliteVarchar();
  }
| 'INTEGER'
  {
    top.ast = abs:sqliteInteger();
  }

