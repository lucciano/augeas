module Test_iptables =

let add_rule = Iptables.add_rule
let ipt_match = Iptables.ipt_match

test add_rule get
"-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n" =
  { "append" = "INPUT"
      { "match" = "state" }
      { "state" = "ESTABLISHED,RELATED" }
      { "jump" = "ACCEPT" } }

test add_rule get
"-A INPUT -p icmp -j \tACCEPT \n" =
  { "append" = "INPUT"
      { "protocol" = "icmp" }
      { "jump" = "ACCEPT" } }

test add_rule get
"-A INPUT -i lo -j ACCEPT\n" =
  { "append" = "INPUT"
    { "in-interface" = "lo" }
    { "jump" = "ACCEPT" } }

test ipt_match get " -m tcp -p tcp --dport 53" =
  { "match" = "tcp" } { "protocol" = "tcp" } { "dport" = "53" }

let arule = " -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT"

test add_rule get ("--append INPUT" . arule . "\n") =
  { "append" = "INPUT"
      { "match" = "state" }
      { "state" = "NEW" }
      { "match" = "tcp" }
      { "protocol" = "tcp" }
      { "dport" = "53" }
      { "jump" = "ACCEPT" } }

test ipt_match get arule =
  { "match" = "state" } { "state" = "NEW" } { "match" = "tcp" }
  { "protocol" = "tcp" } { "dport" = "53" } { "jump" = "ACCEPT" }

test ipt_match get ("-A INPUT" . arule) = *

test ipt_match get " -p esp -j ACCEPT" =
  { "protocol" = "esp" } { "jump" = "ACCEPT" }

test ipt_match get
  " -m state --state NEW -m udp -p udp --dport 5353 -d 224.0.0.251 -j ACCEPT"
 =
  { "match" = "state" } { "state" = "NEW" } { "match" = "udp" }
  { "protocol" = "udp" } { "dport" = "5353" }
  { "destination" = "224.0.0.251" } { "jump" = "ACCEPT" }

test add_rule get
  "-I FORWARD -m physdev --physdev-is-bridged -j ACCEPT\n" =
  { "insert" = "FORWARD"
      { "match" = "physdev" } { "physdev-is-bridged" } { "jump" = "ACCEPT" } }

test add_rule get
    "-A INPUT -j REJECT --reject-with icmp-host-prohibited\n" =
  { "append" = "INPUT"
      { "jump" = "REJECT" } { "reject-with" = "icmp-host-prohibited" } }

test add_rule get
  "-A RH-Firewall-1-INPUT -p icmp --icmp-type any -j ACCEPT\n" =
  { "append" = "RH-Firewall-1-INPUT"
      { "protocol" = "icmp" }
      { "icmp-type" = "any" }
      { "jump" = "ACCEPT" } }

test Iptables.table get "*filter
:RH-Firewall-1-INPUT - [0:0]
-A FORWARD -j RH-Firewall-1-INPUT
-A RH-Firewall-1-INPUT -i lo -j ACCEPT
COMMIT\n" =
  { "table" = "filter"
      { "chain" = "RH-Firewall-1-INPUT"
          { "policy" = "-" } }
      { "append" = "FORWARD"
          { "jump" = "RH-Firewall-1-INPUT" } }
      { "append" = "RH-Firewall-1-INPUT"
          { "in-interface" = "lo" }
          { "jump" = "ACCEPT" } } }

let conf = "# Generated by iptables-save v1.2.6a on Wed Apr 24 10:19:55 2002
*filter
:INPUT DROP [1:229]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-I FORWARD -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth1 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
--append OUTPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
COMMIT
# Completed on Wed Apr 24 10:19:55 2002
# Generated by iptables-save v1.2.6a on Wed Apr 24 10:19:55 2002
*mangle
:PREROUTING ACCEPT [658:32445]
:INPUT ACCEPT [658:32445]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [891:68234]
:POSTROUTING ACCEPT [891:68234]
COMMIT
# Completed on Wed Apr 24 10:19:55 2002
# Generated by iptables-save v1.2.6a on Wed Apr 24 10:19:55 2002
*nat
:PREROUTING ACCEPT [1:229]
:POSTROUTING ACCEPT [3:450]
# The output chain
:OUTPUT ACCEPT [3:450]
# insert something
--insert POSTROUTING -o eth0 -j SNAT --to-source 195.233.192.1 \t
# and now commit
COMMIT
# Completed on Wed Apr 24 10:19:55 2002\n"

test Iptables.lns get conf =
  { "#comment" =
      "Generated by iptables-save v1.2.6a on Wed Apr 24 10:19:55 2002" }
  { "table" = "filter"
    { "chain" = "INPUT" { "policy" = "DROP" } }
    { "chain" = "FORWARD" { "policy" = "DROP" } }
    { "chain" = "OUTPUT" { "policy" = "DROP" } }
    { "append" = "INPUT"
      { "match" = "state" }
      { "state" = "RELATED,ESTABLISHED" }
      { "jump" = "ACCEPT" } }
    { "insert" = "FORWARD"
      { "in-interface" = "eth0" }
      { "match" = "state" }
      { "state" = "RELATED,ESTABLISHED" }
      { "jump" = "ACCEPT" } }
    { "append" = "FORWARD"
      { "in-interface" = "eth1" }
      { "match" = "state" }
      { "state" = "NEW,RELATED,ESTABLISHED" }
      { "jump" = "ACCEPT" } }
    { "append" = "OUTPUT"
      { "match" = "state" }
      { "state" = "NEW,RELATED,ESTABLISHED" }
      { "jump" = "ACCEPT" } } }
  { "#comment" = "Completed on Wed Apr 24 10:19:55 2002" }
  { "#comment" =
      "Generated by iptables-save v1.2.6a on Wed Apr 24 10:19:55 2002" }
  { "table" = "mangle"
    { "chain" = "PREROUTING" { "policy" = "ACCEPT" } }
    { "chain" = "INPUT" { "policy" = "ACCEPT" } }
    { "chain" = "FORWARD" { "policy" = "ACCEPT" } }
    { "chain" = "OUTPUT" { "policy" = "ACCEPT" } }
    { "chain" = "POSTROUTING" { "policy" = "ACCEPT" } } }
  { "#comment" = "Completed on Wed Apr 24 10:19:55 2002" }
  { "#comment" =
      "Generated by iptables-save v1.2.6a on Wed Apr 24 10:19:55 2002" }
  { "table" = "nat"
    { "chain" = "PREROUTING" { "policy" = "ACCEPT" } }
    { "chain" = "POSTROUTING" { "policy" = "ACCEPT" } }
    { "#comment" = "The output chain" }
    { "chain" = "OUTPUT" { "policy" = "ACCEPT" } }
    { "#comment" = "insert something" }
    { "insert" = "POSTROUTING"
      { "out-interface" = "eth0" }
      { "jump" = "SNAT" }
      { "to-source" = "195.233.192.1" } }
    { "#comment" = "and now commit" } }
  { "#comment" = "Completed on Wed Apr 24 10:19:55 2002" }

test ipt_match get " -m comment --comment \"A comment\"" =
  { "match" = "comment" }
  { "comment" = "\"A comment\"" }

(*
 * Test the various schemes for negation that iptables supports
 *
 * Note that the two ways in which a parameter can be negated lead to
 * two different trees that mean the same.
 *)
test add_rule get "-I POSTROUTING ! -d 192.168.122.0/24 -j MASQUERADE\n" =
  { "insert" = "POSTROUTING"
    { "destination" = "192.168.122.0/24"
      { "not" } }
    { "jump" = "MASQUERADE" } }

test add_rule get "-I POSTROUTING -d ! 192.168.122.0/24 -j MASQUERADE\n" =
  { "insert" = "POSTROUTING"
    { "destination" = "! 192.168.122.0/24" }
    { "jump" = "MASQUERADE" } }

test add_rule put "-I POSTROUTING ! -d 192.168.122.0/24 -j MASQUERADE\n"
    after rm "/insert/destination/not" =
  "-I POSTROUTING -d 192.168.122.0/24 -j MASQUERADE\n"

(* I have no idea if iptables will accept double negations, but we
 * allow it syntactically *)
test add_rule put "-I POSTROUTING -d ! 192.168.122.0/24 -j MASQUERADE\n"
    after clear "/insert/destination/not" =
  "-I POSTROUTING ! -d ! 192.168.122.0/24 -j MASQUERADE\n"

test Iptables.chain get ":tcp_packets - [0:0]
" = 
    { "chain" = "tcp_packets" { "policy" = "-" } }
