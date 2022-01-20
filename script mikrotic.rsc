:global data "name,disabled,state";
:global tmp;

foreach id in=[/routing bgp peer find] do={
    :global name [/routing bgp peer get value-name=name $id];
    :global state [/routing bgp peer get value-name=state $id];
    :global disabled [/routing bgp peer get value-name=disabled $id];

    :if ($disabled) do={:global state "idle"};

    :set $tmp ($name . "," . $disabled . "," . $state);
    
    set $data ($data . "|" . $tmp);
};

/snmp send-trap oid=1.3.6.444.444 type=string value="$data"