-module(tnc_page_handler).
-author("shree@ybrantdigital.com").

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
	Technology_Url = "http://api.contentapi.ws/news?channel=us_technology&limit=5&skip=0&format=short",
	% io:format("all news : ~p~n",[Technology_Url]),
	{ok, "200", _, Response_Technology} = ibrowse:send_req(Technology_Url,[],get,[],[]),
	Res_Technology = jsx:decode(list_to_binary(Response_Technology)),
	TechnologyParams = proplists:get_value(<<"articles">>, Res_Technology),

	Video_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=5&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Video_Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[VideoParams] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	% {ok, Body} = tnc_dtl:render(),
	{ok, Body} = tnc_dtl:render([{<<"technology">>,TechnologyParams},{<<"videoParam">>,VideoParams}]),
    {Body, Req, State}
.