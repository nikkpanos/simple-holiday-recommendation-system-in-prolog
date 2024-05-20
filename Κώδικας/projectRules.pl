:-initialization(['projectFacts.pl']).

directlyConnected(Start, Finish, TransportType):-
	route(TransportType, Start, Finish, _, _, _).

connected(Start, Finish, TransportList):-
	directlyConnected(Start, Finish, TransportType),
	member(TransportType, TransportList).
	
connected(Start, Finish, TransportList):-
	directlyConnected(Start, Middle, TransportType),
	member(TransportType, TransportList),
	connected(Middle, Finish, TransportList).

connectedAndMatchChoices(Start, Finish, _, _, _, _, TransportChoiceList, _, _, _):- 
	Start \== athens,
	directlyConnected(Start, Finish, TransportType),
	member(TransportType, TransportChoiceList).

connectedAndMatchChoices(Start, Finish, _, _, _, _, TransportChoiceList, RouteCostChoice, RouteTimeChoice, RouteDistanceChoice):- 
	Start = athens,
	directlyConnected(Start, Finish, TransportType),
	member(TransportType, TransportChoiceList),
	route(TransportType, athens, Finish, Cost, Time, Distance),
	Cost =< RouteCostChoice,
	Time =< RouteTimeChoice,
	Distance =< RouteDistanceChoice,
	showSinglePathInfo(athens, Finish, TransportType).
	
connectedAndMatchChoices(Start, Finish, CurrentCost, CurrentTime, CurrentDistance, CurrentTransportType, 
							TransportChoiceList, RouteCostChoice, RouteTimeChoice, RouteDistanceChoice):-
	directlyConnected(Start, Middle, CurrentTransportType),
	route(CurrentTransportType, Start, Middle, RouteCost, RouteTime, RouteDistance),
	member(CurrentTransportType, TransportChoiceList),
	NewCost is CurrentCost + RouteCost,
	NewTime is CurrentTime + RouteTime,
	NewDistance is CurrentDistance + RouteDistance,
	connectedAndMatchChoices(Middle, Finish, NewCost, NewTime, NewDistance, NewTransportType, TransportChoiceList, RouteCostChoice, RouteTimeChoice, RouteDistanceChoice),
	route(NewTransportType, Middle, Finish, FinalRouteCost, FinalRouteTime, FinalRouteDistance),
	member(NewTransportType, TransportChoiceList),
	TotalCost is NewCost + FinalRouteCost,
	TotalTime is NewTime + FinalRouteTime,
	TotalDistance is NewDistance + FinalRouteDistance,
	TotalCost =< RouteCostChoice,
	TotalTime =< RouteTimeChoice,
	TotalDistance =< RouteDistanceChoice,
	format('From ~w to ~w using ~w:', [Start, Middle, CurrentTransportType]), 
	nl,
	nl,
	format('cost is ~w euros, time is ~w, hours, distance is ~w km', [NewCost, NewTime, NewDistance]),
	nl,
	nl,
	format('From ~w to ~w using ~w:', [Middle, Finish, NewTransportType]), 
	nl,
	nl,
	format('cost is ~w euro, time is ~w hours, distance is ~w km', [FinalRouteCost, FinalRouteTime, FinalRouteDistance]),
	nl,
	nl,
	format('The total cost, travel time and distance to travel to ~w are:', [Finish]),
	nl,
	nl,
	format('~w euro, ~w hours and ~w km',[TotalCost, TotalTime, TotalDistance]),
	nl,
	nl.

matchAllChoices(LocationChoice, SightChoice, AccommodationChoice, RoomChoice, RoomCostChoice, TransportChoiceList, RouteCostChoice, RouteTimeChoice, RouteDistanceChoice):- 
	matchLocation(LocationChoice, DestinationName), 
	matchSight(SightChoice, DestinationName),
	matchAccommodation(AccommodationChoice, RoomChoice, RoomCostChoice, DestinationName),
	matchRoute(TransportChoiceList, RouteCostChoice, RouteTimeChoice, RouteDistanceChoice, DestinationName).

matchLocation(LocationChoice, DestinationName):- 
	destinationData(DestinationName, LocationType, _, _, _), 
	member(LocationChoice, LocationType).

matchSight(SightChoice, DestinationName):- 
	destinationData(DestinationName, _, sights(List), _, _),
	member([SightChoice, _], List). 

matchAccommodation(AccommodationChoice, RoomChoice, CostChoice, DestinationName):- 
	destinationData(DestinationName, _, _, accommodations(List), _), 
	member([AccommodationChoice, List1], List), 
	member([RoomChoice, Cost],List1),  
	Cost=< CostChoice.

matchRoute(TransportChoiceList, RouteCostChoice, RouteTimeChoice, RouteDistanceChoice, DestinationName):-
	connectedAndMatchChoices(athens, DestinationName, 0, 0, 0, _, TransportChoiceList, RouteCostChoice, RouteTimeChoice, RouteDistanceChoice).

showFullInfo(DestinationName):-
	showSightInfo(DestinationName);
	showAccommodationInfo(DestinationName);
	showPublicUtilityServices(DestinationName).
	
showSightInfo(DestinationName):-
	format('In ~w you can find the following interesing tourist sights (categorized by the type):', [DestinationName]),
	nl,
	nl,
	destinationData(DestinationName, _, sights(SightList), _, _),
	member([SightType|Sights], SightList),
	format('~w:', [SightType]),
	nl,
	member(SpecificSight, Sights),
	format('~w', [SpecificSight]),
	nl,
	nl,
	fail.
	
showAccommodationInfo(DestinationName):-
	format('The room choices for ~w (presented in room type-cost pairs) are:', [DestinationName]),
	nl,
	nl,
	destinationData(DestinationName, _, _, accommodations(AccommodationList), _),
	member([AccommodationType|Rooms], AccommodationList),
	format('~w:', [AccommodationType]),
	nl,
	member(Rooms_and_Cost, Rooms),
	format('~w', [Rooms_and_Cost]),
	nl,
	nl,
	fail.
	
showPublicUtilityServices(DestinationName):-
	format('The public utility services that can be found in ~w are the following:', [DestinationName]),
	nl,
	nl,
	destinationData(DestinationName, _, _, _, publicUtilityServices(ServicesList)),
	member(Service, ServicesList),
	format('~w', [Service]),
	nl,
	nl,
	fail.
	
showSinglePathInfo(Start, Finish, TransportType):-
	route(TransportType, Start, Finish, RouteCost, RouteTime, RouteDistance),
	format('From ~w to ~w using ~w:', [Start, Finish, TransportType]), 
	nl,
	nl,
	format('cost is ~w euro, time is ~w hours, distance is ~w km', [RouteCost, RouteTime, RouteDistance]),
	nl,
	nl.