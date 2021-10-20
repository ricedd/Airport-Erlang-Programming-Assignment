% ACO 240 Spring 2021 Erlang Programming Assignment Template
%USES DATE AS ONE COLUMN FROM CSV
-module(main).
-export([start/0]).
-define(FILENAME, "flights_info.csv").

-define(DATE, 1).
-define(AIRLINE_CODE, 2).
-define(AIRLINE_NAME, 3). 
-define(FLIGHT_NUM, 4). 
-define(ORIGIN_AIRPORT, 5). 
-define(ORIGIN_NAME, 6).
-define(ORIGIN_CITY, 7).
-define(ORIGIN_STATE, 8).
-define(DEST_AIRPORT, 9). 
-define(DEST_NAME, 10).
-define(DEST_CITY, 11).
-define(DEST_STATE, 12).
-define(DEPARTURE_SCHEDULED, 13). 
-define(DEPARTURE_TIME, 14). 
-define(DEPARTURE_DELAY, 15). 
-define(ARRIVAL_SCHEDULED, 16). 
-define(ARRIVAL_TIME, 17). 
-define(ARRIVAL_DELAY, 18). 

start() -> flights_file(?FILENAME).

flights_file(Filename) ->
	case file:open(Filename, read) of
		{ok, IoDevice} ->
		  % PROCESS CSV	
      {ok, Airline_Map, Airport_Map, Date_Map} = process_data(IoDevice, #{}, #{}, #{}),
      % TEST CASE I/O CHECKING
      {ok, Test_Case} = io:read(""),
      io:format("test case ~B~n", [Test_Case]),
      test(Test_Case, Airline_Map, Airport_Map, Date_Map);
	  {error, Reason} ->
		  io:format("~s~n", [Reason])
	end.

% Process CSV
process_data(IoDevice, Airline_Map, Airport_Map, Date_Map) ->
	case io:get_line(IoDevice,"") of
		% End of file
    eof -> 
			file:close(IoDevice),
			{ok, Airline_Map, Airport_Map, Date_Map};
		{error, Reason} ->
			file:close(IoDevice),
			throw(Reason);
		% Each row
    Line ->
			Data = case re:run(Line, "\"[^\"]*\"|[^,]+", [{capture,first, list},global]) of   % doesn't handle empty fields
				{match, Captures} -> [ hd(C) || C <- Captures];
				nomatch -> []
		  end,
      %io:format("~p~n", [Data]),
      % YOUR CODE GOES HERE! Pseudocode given below


        {Date, Airline_Code, Airline_Name, Flight_Number, Origin_Airport, Origin_Name, Origin_City, Origin_State, Dest_Airport, Dest_Name, Dest_City, Dest_State, Departure_Sched, Departure_Time, Departure_Delay, Arrival_Sched, Arrival_Time, Arrival_Delay} = list_to_tuple(Data),


        {FlightNumber,[]} = string:to_integer(Flight_Number),
        {DepartureSched,[]} = string:to_integer(Departure_Sched),
        {DepartureDelay,[]} = string:to_integer(Departure_Delay),
        {DepartureTime,[]} = string:to_integer(Departure_Time),
        {ArrivalSched,[]} = string:to_integer(Arrival_Sched),
        {ArrivalTime,[]} = string:to_integer(Arrival_Time),
        {ArrivalDelay,[]} = string:to_integer(string:trim(Arrival_Delay)),

        
    
      FlightTuple = {flight, Date, Airline_Code, FlightNumber, Origin_Airport, Dest_Airport, DepartureSched, DepartureTime, DepartureDelay, ArrivalSched, ArrivalTime, ArrivalDelay},
       %io:format("~p~n", [FlightTuple]),
      case maps:is_key(Date, Date_Map) of
      true -> Value = maps:get(Date, Date_Map);
      false -> Value = []
      end,

      UpdatedDateMap = maps:put(Date, lists:append(Value, [FlightTuple]), Date_Map),

      case maps:is_key(Airline_Code, Airline_Map) of
      true -> Flight_list = lists:append(element(4, maps:get(Airline_Code, Airline_Map)), [FlightTuple]);
      false -> Flight_list = [FlightTuple]
      end,
      Airline = {airline, Airline_Code, Airline_Name, Flight_list},

      UpdatedAirlineMap = maps:put(Airline_Code, Airline, Airline_Map),

      case maps:is_key(Origin_Airport, Airport_Map) of
      true -> OriginFlights = lists:append(element(6, maps:get(Origin_Airport, Airport_Map)), [FlightTuple]),
      OrigAir = {airport, Origin_Airport, Origin_Name, Origin_City, Origin_State, OriginFlights, element(7, maps:get(Origin_Airport, Airport_Map))};
      false -> OriginFlights = [FlightTuple],
      OrigAir = {airport, Origin_Airport, Origin_Name, Origin_City, Origin_State, OriginFlights, []}
      end,

      UpdatedOAirportMap = maps:put(Origin_Airport, OrigAir, Airport_Map),

      case maps:is_key(Dest_Airport, UpdatedOAirportMap) of
      true -> DestFlights = lists:append(element(7, maps:get(Dest_Airport, UpdatedOAirportMap)), [FlightTuple]),
              DestAir = {airport, Dest_Airport, Dest_Name, Dest_City, Dest_State, element(6, maps:get(Dest_Airport, Airport_Map)), DestFlights};
      false -> DestFlights = [FlightTuple],
      DestAir = {airport, Dest_Airport, Dest_Name, Dest_City, Dest_State, [], DestFlights}
      end,
      
      UpdatedDAirportMap = maps:put(Dest_Airport, DestAir, UpdatedOAirportMap),

      process_data(IoDevice, UpdatedAirlineMap, UpdatedDAirportMap, UpdatedDateMap) 
  end.


% Query 1
query1(Date_Map) -> 
KeysList = maps:keys(Date_Map),
find_delays(KeysList, Date_Map).

find_delays([],_) -> ok;
find_delays([DateHead| Tail], Date_Map) ->
  Flight_List = maps:get(DateHead, Date_Map),
  io:fwrite("~s~n", [DateHead ++ ":"]),
  print_delays(lists:sort(fun(D1,D2) -> element(12, D1) >= element(12,D2) end, Flight_List)),
  find_delays(Tail, Date_Map).

print_delays([]) -> ok;
print_delays([Fli | _]) ->
  io:fwrite("~p~n", [Fli]).

% Query 2
query2(_Airport_Map) -> ok.


% TEST CASES - DO NOT CHANGE CODE BELOW FOR INPUT-OUTPUT TESTING
test(1, Airline_Map, Airport_Map, Date_Map) -> 
  testMaps(lists:sort(maps:values(Airline_Map))),
  testMaps(lists:sort(maps:values(Airport_Map))),
  testMaps(lists:sort(maps:keys(Date_Map)), Date_Map);
test(2, _, _, Date_Map) ->
  query1(Date_Map);
test(3, _, Airport_Map, _) ->
  query2(Airport_Map).

% Test case 1
testMaps([]) -> ok;
testMaps([{airline, Code, Name, Flights}|Tail]) ->
  io:format("{~s, ~s, ~B}~n", [Code, Name, length(Flights)]),
  testMaps(Tail);
testMaps([{airport, Code, Name, City, State, OriginFlights, DestFlights}|Tail]) ->
  io:format("{~s, ~s, ~s, ~s, ~B, ~B}~n", [Code, Name, City, State, length(OriginFlights), length(DestFlights)]),
  testMaps(Tail).

testMaps([], _) -> ok;
testMaps([Date|Tail], Date_Map) ->
  Flights = maps:get(Date, Date_Map),
  io:format("~s: ~B~n", [Date, length(Flights)]),
  io:format("~p~n", [lists:nth(1, Flights)]),
  io:format("~p~n", [lists:nth(length(Flights), Flights)]),
  testMaps(Tail, Date_Map).