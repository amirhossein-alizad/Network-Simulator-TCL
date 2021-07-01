if { $argc != 1 } {
   puts "The main.tcl script requires one TCP algorithm to be inputed. \n For example, 'ns main.tcl newReno' \n Please try again."
    return 0;
} else {
    
   if { [lindex $argv 0] == "cubic" } {
     set TCP "TCP/Linux"
    set alg "cubic"
    } else {
      if { [lindex $argv 0] == "yeah" } {
        set TCP "TCP/Linux"
        set alg "yeah"
        } else {
            if { [lindex $argv 0] == "Reno" } {
              set TCP "TCP/Reno"
            set alg "Reno"
        } else {
            puts "The main.tcl script requires one TCP algorithm to be inputed.\nFor example, 'ns main.tcl newReno'\nPlease try again."
            return 0;
        }
    }
  }
}
#Create a simulator object
set ns [new Simulator]

set path1 "outFiles/"
file mkdir $path1 ;

set path "csvFiles/"
file mkdir $path ;

#Open the nam file congestion.nam and the variable-trace file congestion.tr
set tf [open outFiles/out.tr w]
$ns trace-all $tf
set nf [open outFiles/out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
    global ns nf tf
    $ns flush-trace
    close $nf
    close $tf
    exec nam outFiles/out.nam &
    exit 0
}

#Create the network nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

#Create a duplex link between the nodes
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
if {$alg != "Reno"} {
  $ns at 0 "$tcp1 select_ca $alg"
}
$tcp1 set ttl_ 64
$tcp1 set fid_ 1
$tcp1 set windowInit_ 8
if {$alg != "Reno"} {
  $tcp1 set window_ 1000
} else {
  $tcp1 set window_ 8000
}
$ns attach-agent $n1 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1
$ns connect $tcp1 $sink1

set tcp2 [new Agent/$TCP]
if {$alg != "Reno"} {
  $ns at 0 "$tcp1 select_ca $alg"
}
$tcp2 set ttl_ 64
$tcp2 set fid_ 2
$tcp2 set windowInit_ 8
if {$alg != "Reno"} {
  $tcp2 set window_ 1000
} else {
  $tcp2 set window_ 8000
}
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

# Schedule events for the CBR and FTP agents
$ns at 0.0 "$ftp1 start"
$ns at 0.0 "$ftp2 start"
$ns at 1000.0 "$ftp1 stop"
$ns at 1000.0 "$ftp2 stop"
$ns at 1000.0 "finish"

#Plot cwnd data
proc plotCwnd {tcpSource outfile} {
   global ns
   set now [$ns now]
   set cwnd_ [$tcpSource set cwnd_]

   puts  $outfile  "$now,$cwnd_"
   $ns at [expr $now + 1] "plotCwnd $tcpSource $outfile"
}

set cwndTcp1File [open "csvFiles/cwnd1.csv" w]
set cwndTcp2File [open "csvFiles/cwnd2.csv" w]
puts  $cwndTcp1File  "time,cwnd"
puts  $cwndTcp2File  "time,cwnd"
$ns at 0.0  "plotCwnd $tcp1 $cwndTcp1File"
$ns at 0.0  "plotCwnd $tcp2 $cwndTcp2File"

#Plot goodput data
proc plotGoodput {tcpSource prevAck outfile} {
   global ns
   set now [$ns now]
   set ack [$tcpSource set ack_]

   puts  $outfile  "$now,[expr ($ack - $prevAck) * 8]"
   $ns at [expr $now + 1] "plotGoodput $tcpSource $ack $outfile"
}

set goodputTcp1File [open "csvFiles/goodput1.csv" w]
set goodputTcp2File [open "csvFiles/goodput2.csv" w]
puts  $goodputTcp1File  "time,goodput"
puts  $goodputTcp2File  "time,goodput"
$ns at 0.0  "plotGoodput $tcp1 0 $goodputTcp1File"
$ns at 0.0  "plotGoodput $tcp2 0 $goodputTcp2File"

#Plot RTT data
proc plotRTT {tcpSource outfile} {
   global ns
   set now [$ns now]
   set rtt_ [$tcpSource set rtt_]

   puts  $outfile  "$now,$rtt_"
   $ns at [expr $now + 1] "plotRTT $tcpSource $outfile"
}

set rttTcp1File [open "csvFiles/rtt1.csv" w]
set rttTcp2File [open "csvFiles/rtt2.csv" w]
puts  $rttTcp1File  "time,rtt"
puts  $rttTcp2File  "time,rtt"
$ns at 0.0  "plotRTT $tcp1 $rttTcp1File"
$ns at 0.0  "plotRTT $tcp2 $rttTcp2File"

$ns run