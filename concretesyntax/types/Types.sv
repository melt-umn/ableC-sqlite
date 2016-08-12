grammar edu:umn:cs:melt:exts:ableC:sqlite:concretesyntax:types;

--imports edu:umn:cs:melt:exts:ableC:sqlite:abstractsyntax as abs;
--import edu:umn:cs:melt:ableC:concretesyntax;
--
--marking terminal SqliteDb_t 'SqliteDb' lexer classes {Ckeyword};
--
--concrete productions top::TypeSpecifier_c
--| SqliteDb_t
--  {
--    top.realTypeSpecifiers = [abs:sqliteDbTypeExpr([])];
--    top.preTypeSpecifiers = [];
--  }
--
