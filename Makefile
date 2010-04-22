
all: tests
	erlc plist_helper.erl
	erlc config.erl
	
tests:
	erlc packrat_parser_test.erl
	erlc test_suite.erl
	erlc test_plist_helper.erl

peg: all neotoma packrat_parser.peg tests
	erl -pa ./priv/neotoma/ebin -noshell -run neotoma file packrat_parser.peg -s init stop
	erlc packrat_parser.erl

neotoma:
	@(cd priv/neotoma; $(MAKE))	
