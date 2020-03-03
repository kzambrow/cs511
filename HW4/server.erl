-module(server).

-export([start_server/0]).

-include_lib("./defs.hrl").

%% Kamil Zambrowski
%% Matthew Jaros
%% I Pledge My Honor That I Have Abided By The Stevens Honor System

-spec start_server() -> _.
-spec loop(_State) -> _.
-spec do_join(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_leave(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_new_nick(_State, _Ref, _ClientPID, _NewNick) -> _.
-spec do_client_quit(_State, _Ref, _ClientPID) -> _NewState.

start_server() ->
    catch(unregister(server)),
    register(server, self()),
    case whereis(testsuite) of
	undefined -> ok;
	TestSuitePID -> TestSuitePID!{server_up, self()}
    end,
    loop(
      #serv_st{
	 nicks = maps:new(), %% nickname map. client_pid => "nickname"
	 registrations = maps:new(), %% registration map. "chat_name" => [client_pids]
	 chatrooms = maps:new() %% chatroom map. "chat_name" => chat_pid
	}
     ).

loop(State) ->
    receive 
	%% initial connection
	{ClientPID, connect, ClientNick} ->
	    NewState =
		#serv_st{
		   nicks = maps:put(ClientPID, ClientNick, State#serv_st.nicks),
		   registrations = State#serv_st.registrations,
		   chatrooms = State#serv_st.chatrooms
		  },
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, join, ChatName} ->
	    NewState = do_join(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, leave, ChatName} ->
	    NewState = do_leave(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to register a new nickname
	{ClientPID, Ref, nick, NewNick} ->
	    NewState = do_new_nick(State, Ref, ClientPID, NewNick),
	    loop(NewState);
	%% client requests to quit
	{ClientPID, Ref, quit} ->
	    NewState = do_client_quit(State, Ref, ClientPID),
	    loop(NewState);
	{TEST_PID, get_state} ->
	    TEST_PID!{get_state, State},
	    loop(State)
    end.

%% executes join protocol from server perspective
do_join(ChatName, ClientPID, Ref, State) ->
	ClientNick = maps:get(ClientPID, State#serv_st.nicks),
    case maps:is_key(ChatName, State#serv_st.chatrooms) of
	false ->
		PID = spawn(chatroom, start_chatroom, [ChatName]),
		UpdatedState = State#serv_st{chatrooms = maps:put(ChatName,PID,State#serv_st.chatrooms), registrations=maps:put(ChatName, [], State#serv_st.registrations)},
		do_join(ChatName, ClientPID, Ref, UpdatedState);
	true -> 
		ClientNick = maps:get(ClientPID, State#serv_st.nicks),
		Chatroom = maps:get(ChatName, State#serv_st.chatrooms),
		Chatroom!{self(), Ref, register, ClientPID, ClientNick},
		State#serv_st{registrations = maps:put(ChatName, maps:get(ChatName, State#serv_st.registrations) ++ [ClientNick], State#serv_st.registrations)}
	end.

%% executes leave protocol from server perspective
do_leave(ChatName, ClientPID, Ref, State) ->
	PID = maps:get(ChatName, State#serv_st.registrations),
	NewPID = lists:delete(ClientPID, PID),
	UpdatedState = State#serv_st{registrations = maps:update(ChatName, NewPID, State#serv_st.registrations)},
	Chatroom = maps:get(ChatName, State#serv_st.chatrooms),	
	Chatroom!{self(), Ref, unregister, ClientPID},
	ClientPID!{self(), Ref, ack_leave},
	UpdatedState.

%% executes new nickname protocol from server perspective
do_new_nick(State, Ref, ClientPID, NewNick) ->
    	case lists:member(NewNick, maps:values(State#serv_st.nicks)) of
		true ->
			ClientPID!{self(), Ref, err_nick_used},
			State;
		false ->
			UpdatedState = State#serv_st{nicks = maps:update(ClientPID, NewNick, State#serv_st.nicks)},
			Pred = fun(X,Y) -> lists:member(ClientPID, Y) end,
			RelChats = maps:filter(Pred, State#serv_st.registrations),
			RelChatList = maps:keys(RelChats),
			update_chatrooms(State, Ref, ClientPID, NewNick, RelChatList),
			ClientPID!{self(), Ref, ok_nick},
			UpdatedState
	end.

%% update all the chatrooms of new nickname
update_chatrooms(_State, _Ref, _ClientPID, _NewNick, []) ->
	ok;
update_chatrooms(_State, Ref, ClientPID, NewNick, [H|T]) ->
	whereis(list_to_atom(H))!{self(), Ref, update_nick, ClientPID, NewNick},
	update_chatrooms(_State, Ref, ClientPID, NewNick, T).

%% executes client quit protocol from server perspective
do_client_quit(State, Ref, ClientPID) ->
    	UpdatedState = State#serv_st{nicks = maps:remove(ClientPID, State#serv_st.nicks)},
	Pred = fun(X,Y) -> lists:keymember(ClientPID, 1, Y) end,
	RelChats = maps:filter(Pred, State#serv_st.registrations),
	RelChatList = maps:keys(RelChats),
	FinalState = quit_helper(UpdatedState, Ref, ClientPID, RelChatList),
	ClientPID!{self, Ref, ack_quit},
	FinalState.

quit_helper(State, _Ref, _ClientPID, []) ->
	State;
quit_helper(State, Ref, ClientPID, [H|T]) ->
	PID = maps:get(H, State#serv_st.registrations),
	NewPID = lists:delete(ClientPID, PID),
	UpdatedState = State#serv_st{registrations = maps:update(H, NewPID, State#serv_st.registrations)},
	whereis(list_to_atom(H))!{self(), Ref, unregister, ClientPID},
	quit_helper(UpdatedState, Ref, ClientPID, T).


