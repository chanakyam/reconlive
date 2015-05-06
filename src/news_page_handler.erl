-module(news_page_handler).
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
	{[{Name,Value}], Req2} = cowboy_req:bindings(Req),
 	Url = string:concat("http://api.contentapi.ws/t?id=",binary_to_list(Value) ),
	{ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	Res = string:sub_string(Response, 1, string:len(Response) -1 ),
	Params = jsx:decode(list_to_binary(Res)),

	Video_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=4&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Video_Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[VideoParams] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Technology_Url = "http://api.contentapi.ws/news?channel=us_technology&limit=10&skip=0&format=short",
	% io:format("all news : ~p~n",[Technology_Url]),
	{ok, "200", _, Response_Technology} = ibrowse:send_req(Technology_Url,[],get,[],[]),
	Res_Technology = jsx:decode(list_to_binary(Response_Technology)),
	TechnologyParams = proplists:get_value(<<"articles">>, Res_Technology),

	More_Technology_Url = "http://api.contentapi.ws/news?channel=us_technology&limit=25&skip=0&format=short",
	% io:format("all news : ~p~n",[Technology_Url]),
	{ok, "200", _, Response_More_Technology} = ibrowse:send_req(More_Technology_Url,[],get,[],[]),
	Res_More_Technology = jsx:decode(list_to_binary(Response_More_Technology)),
	MoreTechnologyParams = proplists:get_value(<<"articles">>, Res_More_Technology),

	% {ok, Body} = news_page_dtl:render(Params),
	{ok, Body} = news_page_dtl:render([{<<"allnews">>,Params},{<<"videoParam">>,VideoParams},{<<"technology">>,TechnologyParams},{<<"moretechnology">>,MoreTechnologyParams}]),
    {Body, Req2, State}.


