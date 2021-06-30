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

