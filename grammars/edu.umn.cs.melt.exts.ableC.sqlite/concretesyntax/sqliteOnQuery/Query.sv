grammar edu:umn:cs:melt:exts:ableC:sqlite:src:concretesyntax:sqliteOnQuery;

imports silver:langutil;

imports edu:umn:cs:melt:ableC:concretesyntax as host_cnc;
imports edu:umn:cs:melt:ableC:abstractsyntax as host_abs;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction as host_abs;

imports edu:umn:cs:melt:exts:ableC:sqlite:src:abstractsyntax as abs;

exports edu:umn:cs:melt:exts:ableC:sqlite:src:concretesyntax:query;
exports edu:umn:cs:melt:exts:ableC:sqlite:src:concretesyntax:onKeyword;


terminal SqliteCommit_t 'commit';
terminal SqliteQuery_t 'query';
terminal SqliteAs_t 'as';


concrete production sqliteQueryDb_c
top::host_cnc:Stmt_c ::= 'on' q::QueryBit_c
{
  top.ast = q.ast;
}

nonterminal QueryBit_c with ast<host_abs:Stmt>, location ;

concrete production sqliteQueryBitStmt_c
top::QueryBit_c ::= '(' db::host_cnc:Expr_c ')' 'query' '{' query::SqliteQuery_c '}'
                    'as' queryName::host_cnc:Identifier_t
{
  top.ast = abs:sqliteQueryDb(db.ast, query.ast, host_abs:fromId(queryName));
}

concrete production sqliteQueryIdDb_c
top::QueryBit_c ::= id::host_cnc:Identifier_t 'query' '{' query::SqliteQuery_c '}'
                    'as' queryName::host_cnc:Identifier_t
{
  top.ast = abs:sqliteQueryDb(
              host_abs:declRefExpr(host_abs:fromId(id), location=top.location),
	      query.ast, host_abs:fromId(queryName));
}


