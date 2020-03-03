-module(main).
-compile(export_all).
-author("Kamil Zambrowski and Matthew Jaros").
%%I Pledge My Honor That I Have Abided By The Stevens Honor System

start() ->
	{ok, [ N ]} = io:fread("enter number of sensors> ", "~d") ,
	if N =< 1 ->
		io:fwrite("setup: range must be at least 2~n", []) ;
	true ->
		Num_watchers = 1 + (N div 10) ,
		setup_loop(N, Num_watchers)
	end.

setup_loop(N, _) ->
	setup_loop_helper(N, [], 0).

setup_loop_helper(N, List, PID) ->
	case length(List) == 10 of
		true ->
			spawn(watcher, startWatch, [List,[]]),
			setup_loop_helper(N, [], PID);
		false ->
			case N == 0 of
				true ->
					spawn(watcher, startWatch, [List,[]]);
				false ->
					NewList = lists:append(List, [PID]),
					setup_loop_helper(N-1, NewList, PID+1)
				end
			end.
