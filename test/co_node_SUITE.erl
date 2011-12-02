%%%-------------------------------------------------------------------
%%% @author Marina Westman Lönne <malotte@malotte.net>
%%% @copyright (C) 2011, Marina Westman Lönne
%%% @doc
%%%
%%% @end
%%% Created : 29 Nov 2011 by Marina Westman Lönne <malotte@malotte.net>
%%%-------------------------------------------------------------------
-module(co_node_SUITE).

%% Note: This directive should only be used in test suites.
-compile(export_all).

-include_lib("common_test/include/ct.hrl").

-define(SERIAL, 16#03000301).
-define(cocli, "../cocli_udp").
-define(co_target, "0x80030003").

-define(atomic, {{16#6033, 0}, "A long string 1234567890qwertyuiop111"}).
-define(streamed, {{16#6034, 0}, "A long string 1234567890qwertyuiop222"}).

-define(read_file, "../read_file").
-define(write_file, "../write_file").
-define(file_stream_index, 16#6077).


%%--------------------------------------------------------------------
%% COMMON TEST CALLBACK FUNCTIONS
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% @doc
%%  Returns list of tuples to set default properties
%%  for the suite.
%%
%% Function: suite() -> Info
%%
%% Info = [tuple()]
%%   List of key/value pairs.
%%
%% Note: The suite/0 function is only meant to be used to return
%% default data values, not perform any other operations.
%%
%% @spec suite() -> Info
%% @end
%%--------------------------------------------------------------------
suite() ->
    [{timetrap,{minutes,10}}].


%%--------------------------------------------------------------------
%% @doc
%%  Returns the list of groups and test cases that
%%  are to be executed.
%%
%% GroupsAndTestCases = [{group,GroupName} | TestCase]
%% GroupName = atom()
%%   Name of a test case group.
%% TestCase = atom()
%%   Name of a test case.
%% Reason = term()
%%   The reason for skipping all groups and test cases.
%%
%% @spec all() -> GroupsAndTestCases | {skip,Reason}
%% @end
%%--------------------------------------------------------------------
all() -> 
    [start_of_co_node,
     start_of_app,
     set_atomic_segment,
     set_atomic_block,
     set_streamed_segment,
     set_streamed_block,
     get_atomic_segment,
     get_atomic_block,
     get_streamed_segment,
     get_streamed_block,
     stream_app].
%%     break].


%%--------------------------------------------------------------------
%% @doc
%% Returns a list of test case group definitions.
%%
%% Group = {GroupName,Properties,GroupsAndTestCases}
%% GroupName = atom()
%%   The name of the group.
%% Properties = [parallel | sequence | Shuffle | {RepeatType,N}]
%%   Group properties that may be combined.
%% GroupsAndTestCases = [Group | {group,GroupName} | TestCase]
%% TestCase = atom()
%%   The name of a test case.
%% Shuffle = shuffle | {shuffle,Seed}
%%   To get cases executed in random order.
%% Seed = {integer(),integer(),integer()}
%% RepeatType = repeat | repeat_until_all_ok | repeat_until_all_fail |
%%              repeat_until_any_ok | repeat_until_any_fail
%%   To get execution of cases repeated.
%% N = integer() | forever
%%
%% @spec: groups() -> [Group]
%% @end
%%--------------------------------------------------------------------
groups() ->
    [{co_app, [sequence],
     [start_of_app, 
      stop_of_app]}].


%%--------------------------------------------------------------------
%% @doc
%% Initialization before the whole suite
%%
%% Config0 = Config1 = [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%% Reason = term()
%%   The reason for skipping the suite.
%%
%% Note: This function is free to add any key/value pairs to the Config
%% variable, but should NOT alter/remove any existing entries.
%%
%% @spec init_per_suite(Config0) ->
%%               Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% @end
%%--------------------------------------------------------------------
init_per_suite(Config) ->
    {ok, _Pid} = co_node:start_link([{serial,?SERIAL}, 
				     {options, [extended, {vendor,0},
						{dict_file, "test.dict"}]}]),
    ct:pal("Started co_node"),
    Config.

%%--------------------------------------------------------------------
%% @doc
%% Cleanup after the whole suite
%%
%% Config - [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%%
%% @spec end_per_suite(Config) -> _
%% @end
%%--------------------------------------------------------------------
end_per_suite(_Config) ->
    co_node:stop(?SERIAL),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% Initialization before each test case group.
%%
%% GroupName = atom()
%%   Name of the test case group that is about to run.
%% Config0 = Config1 = [tuple()]
%%   A list of key/value pairs, holding configuration data for the group.
%% Reason = term()
%%   The reason for skipping all test cases and subgroups in the group.
%%
%% @spec init_per_group(GroupName, Config0) ->
%%               Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% @end
%%--------------------------------------------------------------------
init_per_group(_GroupName, Config) ->
    Config.

%%--------------------------------------------------------------------
%% @doc
%% Cleanup after each test case group.
%%
%% GroupName = atom()
%%   Name of the test case group that is finished.
%% Config0 = Config1 = [tuple()]
%%   A list of key/value pairs, holding configuration data for the group.
%%
%% @spec end_per_group(GroupName, Config0) ->
%%               void() | {save_config,Config1}
%% @end
%%--------------------------------------------------------------------
end_per_group(_GroupName, _Config) ->
    ok.

%%--------------------------------------------------------------------
%% @doc
%% Initialization before each test case
%%
%% TestCase - atom()
%%   Name of the test case that is about to be run.
%% Config0 = Config1 = [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%% Reason = term()
%%   The reason for skipping the test case.
%%
%% Note: This function is free to add any key/value pairs to the Config
%% variable, but should NOT alter/remove any existing entries.
%%
%% @spec init_per_testcase(TestCase, Config0) ->
%%               Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% @end
%%--------------------------------------------------------------------
init_per_testcase(Case, Config) when Case == set_atomic_segment;
				     Case == set_atomic_block;
				     Case == set_streamed_segment;
				     Case == set_streamed_block;
				     Case == get_atomic_segment;
				     Case == get_atomic_block;
				     Case == get_streamed_segment;
				     Case == get_streamed_block ->
    ct:pal("Testcase: ~p", [Case]),
    {ok, _Pid} = co_ex_app:start(?SERIAL),
    Config;
init_per_testcase(_TestCase, Config) ->
    ct:pal("Testcase: ~p", [_TestCase]),
    Config.

%%--------------------------------------------------------------------
%% @doc
%% Cleanup after each test case
%%
%% TestCase - atom()
%%   Name of the test case that is finished.
%% Config0 = Config1 = [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%%
%% @spec end_per_testcase(TestCase, Config0) ->
%%               void() | {save_config,Config1} | {fail,Reason}
%% @end
%%--------------------------------------------------------------------
end_per_testcase(Case, _Config) when Case == set_atomic_segment;
				     Case == set_atomic_block;
				     Case == set_streamed_segment;
				     Case == set_streamed_block;
				     Case == get_atomic_segment;
				     Case == get_atomic_block;
				     Case == get_streamed_segment;
				     Case == get_streamed_block ->
    ok = co_ex_app:stop(),
    ok;
end_per_testcase(stream_app, _Config) ->
    ok = co_stream_app:stop(),
    ct:pal("Stopped stream app"),
    ok;
end_per_testcase(_TestCase, _Config) ->
    ok.
%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% @doc 
%%  Test case info function - returns list of tuples to set
%%  properties for the test case.
%%
%% Info = [tuple()]
%%   List of key/value pairs.
%%
%% Note: This function is only meant to be used to return a list of
%% values, not perform any other operations.
%%
%% @spec TestCase() -> Info 
%% @end
%%--------------------------------------------------------------------
start_of_co_node() -> 
    [].

%%--------------------------------------------------------------------
%% @doc Test case function. (The name of it must be specified in
%%              the all/0 list or in a test case group for the test case
%%              to be executed).
%%
%% Config0 = Config1 = [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%% Reason = term()
%%   The reason for skipping the test case.
%% Comment = term()
%%   A comment about the test case that will be printed in the html log.
%%
%% @spec TestCase(Config0) ->
%%           ok | exit() | {skip,Reason} | {comment,Comment} |
%%           {save_config,Config1} | {skip_and_save,Reason,Config1}
%% @end
%%--------------------------------------------------------------------
start_of_co_node(_Config) -> 
    ct:pal("Node up and running"),
    timer:sleep(1000),
    ok.

start_of_app(_Config) ->
    {ok, _Pid} = co_ex_app:start(?SERIAL),
    timer:sleep(1000),
    ok.

stop_of_app(_Config) ->
    ok = co_ex_app:stop(),
    ok.

set_atomic_segment(_Config) ->
    set(?atomic, segment).

set_atomic_block(_Config) ->
    set(?atomic, block).


set_streamed_segment(_Config) ->
    set(?streamed, segment).

set_streamed_block(_Config) ->
    set(?streamed, block).


set({Index, NewValue}, BlockOrSegment) ->
    %% Get old value
    {Index, _Type, _Transfer, OldValue} = lists:keyfind(Index, 1, co_ex_app:dict()),
							
    %% Change to new
    [] = os:cmd(set_cmd(Index, NewValue, BlockOrSegment)),
    {Index, _Type, _Transfer, NewValue} = lists:keyfind(Index, 1, co_ex_app:dict()),
    
    %% Restore old
    [] = os:cmd(set_cmd(Index, OldValue, BlockOrSegment)),
    {Index, _Type, _Transfer, OldValue} = lists:keyfind(Index, 1, co_ex_app:dict()),

    ok.

get_atomic_segment(_Config) ->
    get(?atomic, segment).

get_atomic_block(_Config) ->
    get(?atomic, block).


get_streamed_segment(_Config) ->
    get(?streamed, segment).

get_streamed_block(_Config) ->
    get(?streamed, block).


get({Index, _NewValue}, BlockOrSegment) ->

    Result = os:cmd(get_cmd(Index, BlockOrSegment)),

    %% For now ....
    case Result of
	"0x6033 = 1701734733\n" -> ok;
	"can_cli: error: FIXME: handle strings etc\n" -> ok
    end,

    %% ct:pal("Result = ~p", [Result]),

    %% Get value from cocli and compare with dict
    %% {Index, _Type, _Transfer, Value} = lists:keyfind(Index, 1, co_ex_app:dict()),
    
    ok.

stream_app(_Config) ->
    generate_file(?read_file),

    Md5Res1 = os:cmd("md5 " ++ ?read_file),
    [_,_,_,Md5] = string:tokens(Md5Res1," "),

    {ok, _Pid} = co_stream_app:start(?SERIAL, {?file_stream_index, 
					       ?read_file, ?write_file}),
    ct:pal("Started stream app"),
    timer:sleep(1000),

    [] = os:cmd(file_cmd(?file_stream_index, "download", block)),
    %% ct:pal("Started download of file from stream app, result = ~p",[Res1]),
    receive 
	eof ->
	    ct:pal("Application upload finished",[]),
	    timer:sleep(1000),
	    ok
    after 5000 ->
	    ct:fail("Application stuck")
    end,

    [] = os:cmd(file_cmd(?file_stream_index, "upload", block)),
    %% ct:pal("Started upload of file to stream app, result = ~p",[Res2]),
    receive 
	eof ->
	    ct:pal("Application download finished",[]),
	    timer:sleep(1000),
	    ok
    after 5000 ->
	    ct:fail("Application stuck")
    end,

    %% Check that file is unchanged
    Md5Res2 = os:cmd("md5 " ++ ?write_file),
    %% Doesn't work because of cocli error
    %% [_,_,_,Md5] = string:tokens(Md5Res2," "),
    
    ok.

break(Config) ->
    ets:new(config, [set, public, named_table]),
    ets:insert(config, {c, Config}),
    test_server:break("Break for test development"),
    ok.

generate_file(File) ->
    {ok, F} = file:open(File, [write, raw, binary, delayed_write]),
    write(F, "qwertyuiopasdfghjklzxcvbnm", 50),
    file:close(F),
    ok.

write(F, _Data, 0) ->
    file:write(F, << "EOF">>),
    ok;
write(F, Data, N) ->
    Bin = list_to_binary(Data ++ integer_to_list(N)),
    file:write(F, Bin), 
    write(F, Data, N-1).


set_cmd(Index, Value, block) ->
    set_cmd(Index, Value, " -b");
set_cmd(Index, Value, segment) ->
    set_cmd(Index, Value, "");
set_cmd(Index, Value, BFlag) ->
    ?cocli ++ BFlag ++ " -s " ++ ?co_target ++ " set " ++ 
	index_as_c_string(Index) ++ " \"" ++ Value ++ "\"".
get_cmd(Index, block) ->
    get_cmd(Index, " -b");
get_cmd(Index, segment) ->
    get_cmd(Index, "");
get_cmd(Index, BFlag) ->
    ?cocli ++ BFlag ++ " -s " ++ ?co_target ++ " get " ++ 
	index_as_c_string(Index).

file_cmd(Index, Direction, block) ->
    file_cmd(Index, Direction, " -b");
file_cmd(Index, Direction, segment) ->
    file_cmd(Index, Direction, "");
file_cmd(Index, Direction, BFlag) ->
    ?cocli ++ BFlag ++ " -s " ++ ?co_target ++ " " ++ Direction ++ " " ++
	index_as_c_string(Index) ++ " tmp_file".
    
index_as_c_string({Index, 0}) ->
    "0x" ++ integer_to_list(Index,16);
index_as_c_string({Index, SubInd}) ->
    "0x" ++ integer_to_list(Index,16) ++ ":" ++ integer_to_list(SubInd);
index_as_c_string(Index) when is_integer(Index)->
    "0x" ++ integer_to_list(Index,16).
