#Create Network Bridges
sudo ip link add br0 type bridge
sudo ip link add br1 type bridge

sudo ip link set br0 up
sudo ip link set br1 up

#Create Network Namespaces
sudo ip netns add ns1
sudo ip netns add ns2
sudo ip netns add route-ns

#Create Virtual Interfaces and Connections
sudo ip link add veth-ns1 type veth peer veth-br0
sudo ip link add veth-ns2 type veth peer veth-br1
sudo ip link add veth-rns-0 type veth peer veth-rns-br0
sudo ip link add veth-rns-1 type veth peer veth-rns-br1

sudo ip link set veth-ns1 netns ns1
sudo ip link set veth-br0 master br0
sudo ip link set veth-ns2 netns ns2
sudo ip link set veth-br1 master br1
sudo ip link set veth-rns-0 netns route-ns
sudo ip link set veth-rns-br0 master br0
sudo ip link set veth-rns-1 netns route-ns
sudo ip link set veth-rns-br1 master br1

sudo ip netns exec ns1 ip link set veth-ns1 up
sudo ip netns exec ns2 ip link set veth-ns2 up
sudo ip netns exec route-ns ip link set veth-rns-0  up
sudo ip netns exec route-ns ip link set veth-rns-1  up
sudo ip link set veth-rns-br0 up
sudo ip link set veth-rns-br1 up
sudo ip link set veth-br0 up
sudo ip link set veth-br1 up


#⁠Configure IP Addresses
ip addr add 10.10.1.1/16 dev br0
ip addr add 10.11.1.1/16 dev br1

sudo ip netns exec ns1 ip addr add 10.10.1.2/16 dev veth-ns1
sudo ip netns exec ns2 ip addr  add 10.11.1.2/16 dev  veth-ns2

sudo ip netns exec route-ns ip addr add 10.10.1.3/16 dev veth-rns-0
sudo ip netns exec route-ns ip addr add 10.11.1.3/16 dev veth-rns-1

#ip table forward and masquerade rules
sudo iptables --append FORWARD --in-interface br0 --jump ACCEPT
sudo iptables --append FORWARD --out-interface br0 --jump ACCEPT
sudo iptables --append FORWARD --in-interface br1 --jump ACCEPT
sudo iptables --append FORWARD --out-interface br1 --jump ACCEPT

#⁠Configure Default Routes
sudo ip netns exec ns1 ip route add default via 10.10.1.1
sudo ip netns exec ns2 ip route add default via 10.11.1.1
