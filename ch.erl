-module(ch).
-compile(export_all).

chain(S,0) ->
	S!self(),
	receive
		ok ->
			exit(oops)
	end;
chain(S,N) when N > 0 ->
	spawn_link(?MODULE,chain,[S,N-1]),
	receive
		ok ->
			exit(oopsie)
	end.

start() ->
	spawn_link(?MODULE,chain,[self(),5]).

%% Monitoring and Restarting

critic() ->
	receive
		{From, {"Rage Against the TUring Maching", "Unit Testify"}} ->
			From ! {self(), "They are great!"};
		{
