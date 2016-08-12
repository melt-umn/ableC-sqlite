grammar artifact;
-- Ideally, in the future, we won't have to write files like these.
-- This file exists only because we need to do the composition at compile time.

import edu:umn:cs:melt:ableC:concretesyntax as cst;
import edu:umn:cs:melt:ableC:drivers:parseAndPrint;

parser extendedParser :: cst:Root {
  edu:umn:cs:melt:ableC:concretesyntax;
  edu:umn:cs:melt:exts:ableC:sqlite;
}

function main
IOVal<Integer> ::= args::[String] ioin::IO
{
  return driver(args, ioin, extendedParser);
}

