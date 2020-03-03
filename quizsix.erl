-module(quizsix).
-compile(export_all).

%%Kamil Zambrowski
%%Paul Chua
%%I Pledge My Honor That I Have Abided By The Stevens Honor System

dryCleaner(Clean,Dirt) ->
	receive
	{dropOffOverall} -> dryCleaner(Clean, Dirt+1),
	{From, Ref, dryCleanItem} ->
		dryCleaner(Clean+1, Dirt-1) when Dirt > 0,
	{From, Ref, pickUpOverall} -> dryCleaner(Clean-1, Dirt) when Clean > 0
	end.

employee(DC) ->
	R = make_ref(),
	DC {self(),R,start}.
	receive
		{DC, R, pickupOverall},
		{self(),R, ok},
	end.

dryCleanMachine(DC) ->
	R = make_ref(),
	DC {self(),R,start}.
	receive
		{DC, R, ok},
		{self(),R,ok},
	end.

start(E,M) ->
	DC=spawn(?MODULE,dryCleaner,[0,0]),
	[ spawn(?MODULE,employee,[DC]) || _ <- lists:seq(1,E) ],
	[ spawn(?MODULE,dryCleanMachine,[DC]) || _ <- lists:seq(1,M) ].
