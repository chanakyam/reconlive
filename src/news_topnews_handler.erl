-module(news_topnews_handler).
-author("tapanp@koderoom.com").

-export([init/3]).

-export([content_types_provided/2]).
-export([welcome/2]).
-export([terminate/3]).

%% Init
init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.

%% Callbacks
content_types_provided(Req, State) ->
	{[		
		{<<"application/json">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->
	{Count, _ } = cowboy_req:qs_val(<<"n">>, Req),
	{Skip, _ } = cowboy_req:qs_val(<<"s">>, Req),
	{Category, _ } = cowboy_req:qs_val(<<"c">>, Req),
	Url = case binary_to_list(Category) of 
		"us_technology" ->
			%Category = "US",
			"http://api.contentapi.ws/news?channel=us_technology&limit=5&skip=0&format=short";
		"us_technology_limit" ->
			%Category = "US",
			"http://api.contentapi.ws/news?channel=us_technology&limit=10&skip=0&format=short";
		"us_science" ->
			%Category = "US",
			"http://api.contentapi.ws/news?channel=us_science&limit=5&skip=0&format=short";
			
		"us_science_limit" ->
			%Category = "US",
			"http://api.contentapi.ws/news?channel=us_science&limit=10&skip=0&format=short";
		"us_internet" ->
			%Category = "Politics",
			"http://api.contentapi.ws/news?channel=us_internet&limit=5&skip=0&format=short";
		"us_internet_limit" ->
			%Category = "Politics",
			"http://api.contentapi.ws/news?channel=us_internet&limit=10&skip=0&format=short";
			
		
		_ ->
			%Category = "None",
			lager:info("#########################None")

	end,
	% io:format("url --> ~p ~n",[Url]),

	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	Body = list_to_binary(Response_mlb),
	{Body, Req, State}.
