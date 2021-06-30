set ns [new Simulator]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]


$ns duplex-link $n0 $n2 4000Mb 500ms DropTail
$ns duplex-link $n1 $n2 4000Mb 800ms DropTail
$ns duplex-link $n2 $n3 1000Mb 50ms DropTail
$ns duplex-link $n3 $n4 4000Mb 500ms DropTail
$ns duplex-link $n3 $n5 4000Mb 800ms DropTail

#Set Queue Size of link (n2-n3) to 10
#Set all output links of routers queue limit to 10
$ns queue-limit $n2 $n3 10
$ns queue-limit $n2 $n0 10
$ns queue-limit $n2 $n1 10
$ns queue-limit $n3 $n2 10
$ns queue-limit $n3 $n4 10
$ns queue-limit $n3 $n5 10

#set edges
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5