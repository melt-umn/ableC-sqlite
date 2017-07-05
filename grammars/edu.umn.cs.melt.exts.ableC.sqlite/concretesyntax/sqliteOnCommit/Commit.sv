grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:sqliteOnCommit;

imports silver:langutil;

imports edu:umn:cs:melt:ableC:concretesyntax as host_cnc;
imports edu:umn:cs:melt:ableC:abstractsyntax as host_abs;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction as host_abs;

imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;

exports edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:query;
exports edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:onKeyword;

terminal SqliteCommit_t 'commit';

concrete production sqliteCommitDb_c
top::host_cnc:Expr_c ::= 'on' c::CommitBit_c
{
  top.ast = c.ast;
}

nonterminal CommitBit_c with ast<host_abs:Expr>, location ;

concrete production sqliteCommitBitExpr_c
top::CommitBit_c ::= '(' db::host_cnc:Expr_c ')' 'commit' '{' query::SqliteQuery_c '}'
{
  top.ast = abs:sqliteCommitDb(db.ast, query.ast, location=top.location);
}

concrete production sqliteCommitBitVar_c
top::CommitBit_c ::= id::host_cnc:Identifier_t 'commit' '{' query::SqliteQuery_c '}'
{
  top.ast = abs:sqliteCommitDb(
              host_abs:declRefExpr(host_abs:fromId(id), location=top.location),
              query.ast, location=top.location);
}


