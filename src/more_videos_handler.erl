-module(more_videos_handler).
-author("chanakyam@koderoom.com").
-modified("sushmap@ybrantinc.com").

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

	{PageBinary, _} = cowboy_req:qs_val(<<"p">>, Req),
	PageNum = list_to_integer(binary_to_list(PageBinary)),
	SkipItems = (PageNum-1) * ?NEWS_PER_PAGE,	

	Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=6&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Url_all_news = "http://api.contentapi.ws/videos?channel=world_news&limit=16&skip=0&format=short",
	% io:format("all news : ~p~n",[Url_all_news]),
	{ok, "200", _, ResponseAllNews} = ibrowse:send_req(Url_all_news,[],get,[],[]),
	ResponseParams = jsx:decode(list_to_binary(ResponseAllNews)),
	ResAllNews = proplists:get_value(<<"articles">>, ResponseParams),

	Technology_Url = "http://api.contentapi.ws/news?channel=us_technology&limit=5&skip=0&format=short",
	% io:format("all news : ~p~n",[Technology_Url]),
	{ok, "200", _, Response_Technology} = ibrowse:send_req(Technology_Url,[],get,[],[]),
	Res_Technology = jsx:decode(list_to_binary(Response_Technology)),
	TechnologyParams = proplists:get_value(<<"articles">>, Res_Technology),

	{ok, Body} = more_videos_dtl:render([{<<"videoParam">>,Params},{<<"allnews">>,ResAllNews},{<<"technology">>,TechnologyParams}]),
    {Body, Req, State}.




