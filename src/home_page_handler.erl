-module(home_page_handler).
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
		{<<"text/html">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->

	Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=0&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Technology_Url = "http://api.contentapi.ws/news?channel=us_technology&limit=5&skip=0&format=short",
	% io:format("all news : ~p~n",[Technology_Url]),
	{ok, "200", _, Response_Technology} = ibrowse:send_req(Technology_Url,[],get,[],[]),
	Res_Technology = jsx:decode(list_to_binary(Response_Technology)),
	TechnologyParams = proplists:get_value(<<"articles">>, Res_Technology),

	Internet_Url = "http://api.contentapi.ws/news?channel=us_internet&limit=5&skip=0&format=short",
	{ok, "200", _, Response_Internet} = ibrowse:send_req(Internet_Url,[],get,[],[]),
	Res_Internet = jsx:decode(list_to_binary(Response_Internet)),
	InternetParams = proplists:get_value(<<"articles">>, Res_Internet),

	Science_Url = "http://api.contentapi.ws/news?channel=us_science&limit=5&skip=0&format=short",
	{ok, "200", _, Response_Science} = ibrowse:send_req(Science_Url,[],get,[],[]),
	Res_Science = jsx:decode(list_to_binary(Response_Science)),
	ScienceParams = proplists:get_value(<<"articles">>, Res_Science),

	% {ok, Body} = index_dtl:render(),
	{ok, Body} = index_dtl:render([{<<"videoParam">>,Params},{<<"technology">>,TechnologyParams},{<<"internet">>,InternetParams},{<<"science">>,ScienceParams}]),
    {Body, Req, State}
.
