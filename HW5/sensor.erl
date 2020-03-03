-module(sensor).
-compile(export_all).
-author("Kamil Zambrowski and Matthew Jaros").
%% I Pledge My Honor That I Have Abided By The Stevens Honor System

sensorfun(WatcherPID, SensorPID) ->
	Measurement = rand:uniform(11),
	case Measurement == 11 of
		true -> exit("anomalous_reading");
		false -> WatcherPID!{SensorPID, Measurement}
	end,
	Sleep_time = rand:uniform(10000),
	timer:sleep(Sleep_time),
	sensorfun(WatcherPID, SensorPID).
