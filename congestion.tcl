if { $argc != 1 } {
   puts "The main.tcl script requires one TCP algorithm to be inputed. \n For example, 'ns main.tcl newReno' \n Please try again."
    return 0;
} else {
    set TCP "TCP/Linux"
   if { [lindex $argv 0] == "cubic" } {
    set alg "cubic"
    } else {
      if { [lindex $argv 0] == "yeah" } {
        set alg "yeah"
        } else {
            if { [lindex $argv 0] == "Reno" } {
            set alg "Reno"
        } else {
            puts "The main.tcl script requires one TCP algorithm to be inputed.\nFor example, 'ns main.tcl newReno'\nPlease try again."
            return 0;
        }
    }
  }
}
set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

set tf [open out.tr w]
$ns trace-all $tf
set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam out.nam &
    exit 0
}

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]


$ns duplex-link $n1 $n3 4000Mb 500ms DropTail
$ns duplex-link $n2 $n3 4000Mb 800ms DropTail
$ns duplex-link $n3 $n4 1000Mb 50ms DropTail
$ns duplex-link $n4 $n5 4000Mb 500ms DropTail
$ns duplex-link $n4 $n6 4000Mb 800ms DropTail

#Set Queue Size of link (n2-n3) to 10
#Set all output links of routers queue limit to 10
$ns queue-limit $n3 $n1 10
$ns queue-limit $n3 $n2 10
$ns queue-limit $n3 $n4 10
$ns queue-limit $n4 $n3 10
$ns queue-limit $n4 $n5 10
$ns queue-limit $n4 $n6 10

#set edges
$ns duplex-link-op $n1 $n3 orient right-down
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right-down

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n3 $n4 queuePos 0.5

set tcp1 [new Agent/$TCP]
if {$alg != "ًReno"} {
  $ns at 0 "$tcp1 select_ca $alg"
}
$tcp1 set class_ 2
$tcp1 set ttl_ 64
$tcp1 set fid_ 1
$ns attach-agent $n1 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1
$ns connect $tcp1 $sink1

set tcp2 [new Agent/$TCP]
if {$alg != "Reno"} {
  $ns at 0 "$tcp1 select_ca $alg"
}
$tcp2 set class_ 2
$tcp2 set ttl_ 64
$tcp2 set fid_ 2
$ns attach-agent $n2 $tcp2

set sink2 [new Agent/TCPSink]
$ns attach-agent $n6 $sink2
$ns connect $tcp2 $sink2

# Setup a FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP

proc finish{tcpSource outfile} {

global ns nf
$ns flush-trace
close $nf
exec nam out.nam &
exit 0
 
}

# Schedule events for the CBR and FTP agents
$ns at 0.0 "$ftp1 start"
$ns at 0.0 "$ftp2 start"
$ns at 1000.0 "$ftp1 stop"
$ns at 1000.0 "$ftp2 stop"
$ns at 1000.0 "finish"


$ns run
