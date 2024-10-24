grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax;

import silver:langutil;

import edu:umn:cs:melt:ableC:concretesyntax as host_cnc;
import edu:umn:cs:melt:ableC:abstractsyntax:host as host_abs;
import edu:umn:cs:melt:ableC:abstractsyntax:construction as host_abs;

import edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;

marking terminal SqliteUse_t 'use' lexer classes {host_cnc:Keyword, host_cnc:Global};

terminal SqliteLcAs_t 'as' lexer classes {host_cnc:Keyword};
terminal SqliteLcWith_t 'with' lexer classes {host_cnc:Keyword};
terminal SqliteTable_t 'table' lexer classes {host_cnc:Keyword};
terminal SqliteVarchar_t 'VARCHAR' lexer classes {SqliteKeyword};
terminal SqliteInteger_t 'INTEGER' lexer classes {SqliteKeyword};

concrete production sqliteUse_c
top::host_cnc:Stmt_c ::= 'use' u::UseBit_c
{
  top.ast = u.ast;
}

tracked nonterminal UseBit_c with ast<host_abs:Stmt>;

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
              host_abs:declRefExpr(host_abs:fromId(id)),
              host_abs:fromId(dbName), tables.ast);
}

concrete production useBitStringLit_c
top::UseBit_c ::= sl::host_cnc:StringConstant_t tables::SqliteOptWithTables_c
                    'as' dbName::host_cnc:Identifier_t
{
  top.ast = abs:sqliteUse(
              host_abs:stringLiteral(sl.lexeme),
              host_abs:fromId(dbName), tables.ast);
}

tracked nonterminal SqliteOptWithTables_c with ast<abs:SqliteTableList>;
concrete productions top::SqliteOptWithTables_c
| 'with' '{' t::SqliteTableList_c '}'
  layout {SqliteLineComment_t, host_cnc:BlockComment_t, host_cnc:Spaces_t, host_cnc:NewLine_t}
  {
    top.ast = t.ast;
  }
|
  {
    top.ast = abs:sqliteNilTable();
  }

tracked nonterminal SqliteTableList_c with ast<abs:SqliteTableList>;
concrete productions top::SqliteTableList_c
| ts::SqliteTableList_c ',' t::SqliteTable_c
  {
    top.ast = abs:sqliteConsTable(t.ast, ts.ast);
  }
| t::SqliteTable_c
  {
    top.ast = abs:sqliteConsTable(t.ast, abs:sqliteNilTable());
  }

tracked nonterminal SqliteTable_c with ast<abs:SqliteTable>;
concrete productions top::SqliteTable_c
| 'table' n::host_cnc:Identifier_t '(' cs::SqliteColumnList_c ')'
  {
    top.ast = abs:sqliteTable(host_abs:fromId(n), cs.ast);
  }

tracked nonterminal SqliteColumnList_c with ast<abs:SqliteColumnList>;
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

tracked nonterminal SqliteColumn_c with ast<abs:SqliteColumn>;
concrete productions top::SqliteColumn_c
| n::host_cnc:Identifier_t t::SqliteColumnType_c
  {
    top.ast = abs:sqliteColumn(host_abs:fromId(n), t.ast);
  }

tracked nonterminal SqliteColumnType_c with ast<abs:SqliteColumnType>;
concrete productions top::SqliteColumnType_c
| 'VARCHAR'
  {
    top.ast = abs:sqliteVarchar();
  }
| 'INTEGER'
  {
    top.ast = abs:sqliteInteger();
  }

