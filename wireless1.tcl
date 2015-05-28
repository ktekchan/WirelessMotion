set val(chan1)	Channel/WirelessChannel
set val(prop1)	Propagation/TwoRayGround
set val(netif)	Phy/WirelessPhy
set val(mac)	Mac/802_11
set val(ifq)	CMUPriQueue
set val(ll)	LL
set val(ant)	Antenna/OmniAntenna
set val(ifqlen)	50
set val(nn)	4
set val(rp)	DSR

set ns [new Simulator]
set nt [open throughput.tr w]
$ns trace-all $nt
set nm [open throughput.nam w]
$ns namtrace-all-wireless $nm 300 300

set topo [new Topography]
$topo load_flatgrid 300 300

create-god $val(nn)

$ns node-config	-adhocRouting $val(rp)\
		-llType $val(ll)\
		-macType $val(mac)\
		-ifqType $val(ifq)\
		-ifqLen $val(ifqlen)\
		-antType $val(ant)\
		-propType $val(prop1)\
		-phyType $val(netif)\
		-channelType $val(chan1)\
		-topoInstance $topo\
		-agentTrace ON\
		-routerTrace ON\
		-macTrace ON\
		-movementTrace ON

	proc finish {} {
	global nt nm ns
	$ns flush-trace
	close $nt
	close $nm
	exec nam throughput.nam
	exit 0
	}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$n0 random-motion 1
$n1 random-motion 1
$n2 random-motion 1
$n3 random-motion 1

$n0 start
$n1 start
$n2 start
$n3 start

$ns initial_node_pos $n0 30
$ns initial_node_pos $n1 10
$ns initial_node_pos $n2 10
$ns initial_node_pos $n3 10

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
set sink2 [new Agent/Null]
$ns attach-agent $n3 $sink2
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 250
$cbr1 set interval_ 0.01

$ns connect $tcp0 $sink1
$ns connect $udp1 $sink2

$ns at 1.0 "$ftp0 start"
$ns at 1.0 "$cbr1 start"
$ns at 170.0 "$n0 reset"
$ns at 170.0 "$n1 reset"
$ns at 170.0 "$n2 reset"
$ns at 170.0 "$n3 reset"
$ns at 175.0 "$ftp0 stop"
$ns at 175.0 "$cbr1 stop"
$ns at 180.1 "finish"
$ns run

