# erldnsclient
Simplest possible Erlang DNS client. It sends one question and just parses first response.
Nothing really useful, but what more can you expect from jus a few lines of code.

You can choose requested hostname and nameserver.

    $ erl
    1> dns:query("github.com", "8.8.8.8").
    [{dnsh,3838,1,0,0,0,1,1,0,1,1,0,0},
     {question,["github","com"],1,1},
      {response,{record,type_A,1,222,<<192,30,252,130>>}}]
    2> dns:query("blabla.github.com", "8.8.8.8").
    [{dnsh,1872,1,0,0,0,1,1,0,1,2,0,0},
     {question,["blabla","github","com"],1,1},
      {response,{record,type_CNAME,1,29,
                         ["github","map","fastly","net"]}}]
