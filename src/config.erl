-module (config).
-export ([file/1]).


-record (conf_action, {pre,cmd,post}).
-record (conf_object, {
  action_bundle,
  action_mount,
  action_unmount,
  action_cleanup,
  action_run
}).

-define (SEPARATOR, $:).

file(Filename) ->
  {ok, Fd} = file:open(Filename, [read]),
  io:setopts(Fd, [binary]),
  for_each_line(Fd, fun parse/3, 1, []).

for_each_line(Device, Proc, Count, Accum) ->
  case io:get_line(Device, "") of
    eof  -> file:close(Device), Accum;
    Line -> 
      NewAccum = Proc(Line, Count, Accum), 
      for_each_line(Device, Proc, Count + 1, NewAccum)
  end.

parse(Line, Count, Acc) ->
  [peg_parse(Line, Count)|Acc].

% START PEG PARSING
peg_parse(Line, Count) ->
  {Field, X} = parse_line(Line, [], []),
  case Field of
    comment -> ok;
    X -> io:format("[~p] ~p:~p~n", [Count, Field, X])
  end.

% Top
% Strip comments
parse_line(<<$#, _Rest/binary>>, [], _Acc) -> {comment, []};
% Is this the field?
parse_line(<<?SEPARATOR, Rest/binary>>, _Field, Acc) -> parse_line(Rest, lists:reverse(Acc), []);
parse_line(<<Char, Rest/binary>>, Field, Acc) -> parse_line(Rest, Field, [Char|Acc]);
parse_line(<<>>, Field, Acc) -> {Field, lists:reverse(Acc)};
parse_line(<<$\n>>, Field, Acc) -> {Field, lists:reverse(Acc)}.

% peg_parse_line([], Acc) -> lists:reverse(Acc);
% peg_parse_line(['#'|_T], _Acc) -> [];
% peg_parse_line([H|T], Acc) -> 
%   io:format("Head: ~p~n", [H]),
%   peg_parse_line(T, [H|Acc]).