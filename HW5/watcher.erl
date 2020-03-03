-module(watcher).
-compile(export_all).
-author("Kamil Zambrowski and Matthew Jaros").
%% I Pledge My Honor That I Have Abided By The Stevens Honor System

startWatch(List, Tuple) ->
	case length(List) == 0 of
		true ->
			io:fwrite("Watcher: ~p , list: ~p~n", [self(), Tuple]),
			watcher(Tuple);
		false ->
			[H|T] = List,
			{SensorPID, _} = spawn_monitor(sensor, sensorfun, [self(), H]),
			NewTuple = lists:append(Tuple, [{H, SensorPID}]),
			startWatch(T, NewTuple)
		end.

restart(List, SensorID) ->
	{PID, _} = spawn_monitor(sensor, sensorfun, [self(), SensorID]),
	UpdatedList = lists:append(List, [{SensorID, PID}]),
	io:fwrite("Sensor Restarted. New List of Sensors: ~p~n", [UpdatedList]),
	watcher(UpdatedList).

watcher(List) ->
	receive
		{SensorPID, Measurement} ->
			io:fwrite("Sensor: ~p , measurement: ~p~n", [SensorPID, Measurement]),
			watcher(List);
		{'DOWN', _, process, Sensor, Reason} ->
			{SensorNumber, _} = lists:keyfind(Sensor, 2, List),
			io:fwrite("Sensor: ~p died , reason: ~p~n", [SensorNumber, Reason]),
			NewList = lists:delete({SensorNumber, Sensor}, List),
			restart(NewList, SensorNumber)
		end.

	
