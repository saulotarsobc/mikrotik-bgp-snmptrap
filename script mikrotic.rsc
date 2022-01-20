:global data "name,disabled,state";

foreach id in=[/routing bgp peer find] do={
    :global name [/routing bgp peer get value-name=name $id];
    :global state [/routing bgp peer get value-name=state $id];
    :global disabled [/routing bgp peer get value-name=disabled $id];
        :if (state = "idle") do={:set state 1;};
        :if (state = "connect") do={:set state 2;}
        :if (state = "active") do={:set state 3;}; 
        :if (state = "opensent") do={:set state 4;}
        :if (state = "openconfirm") do={:set state 5;}; 
        :if (state = "established") do={:set state 6;}
        :if (disabled) do={:set state 1;}
        
    :set $data ($data . "|" . $name . "," . $disabled . "," . $state);
};

/snmp send-trap oid=1.3.6.444.444 type=string value="$data"