-module(dns).
-compile(export_all).

enc_string(Str) ->
    STR = list_to_binary(Str),
    LEN = byte_size(STR),
    <<LEN:8, STR/binary>>.

dec_strings(Str, <<0:8, Rest/binary>>)                   ->  {Str, Rest};
dec_strings(Str, <<>>)                                   ->  {Str, <<>>};
dec_strings(Str, <<L:8, StrData:L/binary, Rest/binary>>) ->
    Strings = Str ++ [binary_to_list(StrData)],
    dec_strings(Strings, Rest).

make_query(ID, Name) ->
    HDR = <<ID:16/integer, 0:1, 0:4, 0:1, 0:1, 1:1, 0:1, 0:3, 0:4, 1:16, 0:16, 0:16, 0:16>>,
    QUERYSTR = [enc_string(STR) || STR <- string:tokens(Name, ".")],
    [HDR, QUERYSTR, <<0:8, 1:16, 1:16>>].

dec_record(<<Type:16, Class:16, TTL:32, 
             RDLength:16, RData:RDLength/binary, _Rest/binary>>) ->
    {record, Type, Class, TTL, RData}.

decode_response(<<ID:16, 1:1, OPCODE:4, AA:1, TC:1, RD:1, RA:1, 0:3, 
                 RCode:4, QDCount:16, ANCount:16, AUTHRS:16, ADDRS:16, Rest/binary>>) ->
    {Strings, Rest2} = dec_strings([], Rest),
    <<Type:16, Class:16, Rest3/binary>> = Rest2, 
    [{dnsh, ID, 1, OPCODE, AA, TC, RD, RA, RCode, QDCount, ANCount, AUTHRS, ADDRS},
     {question, Strings, Type, Class},
     {responses, (Rest3)}].

query(Name, Server) ->
    ID = rand:uniform(1 bsl 16),
    Q = make_query(ID, Name),
    {ok, Socket} = gen_udp:open(1234, [binary]),
    gen_udp:send(Socket, Server, 53, Q),
    receive
        {udp, _, _, _, Datagram = <<ID:16, _/binary>>} ->
            gen_udp:close(Socket),
            decode_response(Datagram)
    after 10000 ->
            gen_udp:close(Socket),
            {error, timeout}
    end.
