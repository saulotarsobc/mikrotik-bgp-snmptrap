:global data "name,disabled,state,remoteaddress,remoteas,prefix,uptime";
foreach id in=[/routing bgp peer find] do={
    :global name [/routing bgp peer get value-name=name $id];
    :global disabled [/routing bgp peer get value-name=disabled $id];
    :global state [/routing bgp peer get value-name=state $id];
        :if (state = "idle") do={:set state 1};
        :if (state = "connect") do={:set state 2}
        :if (state = "active") do={:set state 3}; 
        :if (state = "opensent") do={:set state 4}
        :if (state = "openconfirm") do={:set state 5}; 
        :if (state = "established") do={:set state 6};
        :if (disabled) do={:set state 1};
    :global remoteaddress [/routing bgp peer get value-name=remote-address $id];
    :global remoteas [/routing bgp peer get value-name=remote-as $id];
    :global prefix [/routing bgp peer get value-name=prefix $id];
        :if (prefix < 1) do={:set prefix 0;}

    :global uptime [/routing bgp peer get value-name=uptime $id];
        :if (uptime < 1) do={:set uptime 0;}
            :global uptimeseconds 0; :global weekend 0; 
            :global dayend 0; :global weeks 0; :global days 0;
        :if ([:find $uptime "w" -1] > 0) do={
            :set weekend [:find $uptime "w" -1];
            :set weeks [:pick $uptime 0 $weekend];
            :set weekend ($weekend+1);
        };
        :if ([:find $uptime "d" -1] > 0) do={
            :set dayend [:find $uptime "d" -1];
            :set days [:pick $uptime $weekend $dayend];
        };
        :global time [:pick $uptime ([:len $uptime]-8) [:len $uptime]];
        :global hours [:pick $time 0 2];
        :global minutes [:pick $time 3 5];
        :global seconds [:pick $time 6 8];

        :set uptimeseconds [($weeks*86400*7+$days*86400+$hours*3600+$minutes*60+$seconds)];

    :set $data ($data."|".$name.",".$disabled.",".$state.",".$remoteaddress.",".$remoteas.",".$prefix.",".$uptimeseconds);
    
    :delay 1s;

};
/snmp send-trap oid=1.3.6.444.444 type=string value="$data"