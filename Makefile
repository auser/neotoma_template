EBIN_DIR := ./ebin
ERL = erl
ERLC = erlc
SILENCE = @

ERL_SOURCE_DIRS = \
	./src

TEST_DIRS = \
	./test
	
#Helper Functions
get_src_from_dir  = $(wildcard $1/*.erl)
get_src_from_dir_list = $(foreach dir, $1, $(call get_src_from_dir,$(dir)))				        
src_to_beam = $(subst ./src, ./ebin, $(subst .erl,.beam,$1))
# src_to_beam = $(subst .erl,.beam,$1)

SRC = $(call get_src_from_dir_list, $(ERL_SOURCE_DIRS))
OBJ = $(call src_to_beam,$(SRC))
STUFF_TO_CLEAN += $(OBJ)

TEST_SRC = $(call get_src_from_dir_list, $(TEST_DIRS))
TEST_OBJ = $(call src_to_beam,$(TEST_SRC))
STUFF_TO_CLEAN += $(TEST_OBJ)

STUFF_TO_CLEAN += ./priv/neotoma/ebin/*.beam

all: peg $(OBJ)

peg: neotoma
	$(ERL) -pa ./priv/neotoma/ebin -noshell -run neotoma file src/packrat_parser.peg -s init stop
	
$(OBJ): $(SRC)
	$(SILENCE)echo compiling $(notdir $@)
	$(SILENCE)$(ERLC) $(ERLC_FLAGS) -o $(EBIN_DIR) $^

$(TEST_OBJ): $(TEST_SRC)
	$(SILENCE)echo compiling $(notdir $@)
	$(SILENCE)$(ERLC) $(ERLC_FLAGS) -o $(EBIN_DIR) $^	

test: all $(TEST_OBJ)
	$(SILENCE) $(ERL)	-noshell \
					-sname local_test \
					-pa $(EBIN_DIR) \
					-s test_suite test \
					-s init stop

neotoma:
	@(cd priv/neotoma; $(MAKE))	

clean:
	@(rm -rf $(STUFF_TO_CLEAN) $(EBIN_DIR)/*.beam)
