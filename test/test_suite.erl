-module (test_suite).

-include_lib("eunit/include/eunit.hrl").
 
all_test_() ->
  [
    {module, packrat_parser_test},
    {module, test_plist_helper}
  ].
