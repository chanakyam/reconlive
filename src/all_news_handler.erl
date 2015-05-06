-module(all_news_handler).
-author("tapanp@koderoom.com").

-include("includes.hrl").

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
	{PageBinary, PageNumber} = cowboy_req:qs_val(<<"p">>, Req),
	PageNum = list_to_integer(binary_to_list(PageBinary)),
	SkipItems = (PageNum-1) * ?NEWS_PER_PAGE,

	{CategoryBinary, _} = cowboy_req:qs_val(<<"c">>, Req),
	Category = binary_to_list(CategoryBinary),

	Url = case Category of 
		"us_technology" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_technology&limit=25&format=short&skip=", integer_to_list(SkipItems));
		"us_science" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_science&limit=25&format=short&skip=", integer_to_list(SkipItems));
			
		"us_internet" ->
			%Category = "Politics",
			string:concat("http://api.contentapi.ws/news?channel=us_internet&limit=25&format=short&skip=", integer_to_list(SkipItems));	
		
		_ ->
			%Category = "None",
			lager:info("#########################None")

	end,

	Video_Url = case Category of 
		"us_technology" ->
			%Category = "US",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=1&format=long";
		"us_science" ->
			%Category = "US",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=2&format=long";
			
		"us_internet" ->
			%Category = "Politics",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=3&format=long";	
		
		_ ->
			%Category = "None",
			lager:info("#########################None")

	end,

	% io:format("url --> ~p ~n",[Url]),
	{ok, "200", _, ResponseAllNews} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams = jsx:decode(list_to_binary(ResponseAllNews)),
	ResAllNews = proplists:get_value(<<"articles">>, ResponseParams),

	% Video_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=1&format=long";
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Video_Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Technology_Url = "http://api.contentapi.ws/news?channel=us_technology&limit=10&skip=0&format=short",
	% io:format("all news : ~p~n",[Technology_Url]),
	{ok, "200", _, Response_Technology} = ibrowse:send_req(Technology_Url,[],get,[],[]),
	Res_Technology = jsx:decode(list_to_binary(Response_Technology)),
	TechnologyParams = proplists:get_value(<<"articles">>, Res_Technology),

	{ok, Body} = all_news_paginated_dtl:render([{<<"news_category">>,Category},{<<"videoParam">>,Params},{<<"allnews">>,ResAllNews},{<<"technology">>,TechnologyParams}]),
    {Body, Req, State}
.