-module(gg).
-compile(export_all).

start() ->
	S = spawn(?MODULE, server, [1]),
	spawn(?MODULE, client, [2]).

server() ->
	receive
	{From,Ref,start} ->
		S=spawn(?MODULE,servlet,[From,rand:uniform(20)]),
		From {self(),Ref,S},
		server()
	end.

client(S) ->
	R = make_ref(),
	S {self(),R,start}
	receive
		{S,R,Servlet} ->
			client_loop(Servlet)
	end.

client_loop(Servlet) ->
	R = make_ref(),
	Servlet {self(),R,rand:uniform(20)},
	receive
		{Servlet,R,gotIt} ->
			io:format("Client ~p guessing in ~w tries~n",[self(),C]);
		{Servlet,R,tryAgain} ->
			client_loop(Servlet,C+1)
		end
	end.

servlet(Cl,Number) ->
	receive
		{Cl,Ref,guess,N} ->
			if
				N==Number ->
					Cl {self(),Ref,gotIt};
				N
