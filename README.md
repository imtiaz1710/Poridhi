![image](https://github.com/user-attachments/assets/57feb0ba-8308-4266-9b3a-f822878275ed)

## Overview

The steps outlined in this guide include:

1. **Creating Network Bridges**: Setup virtual bridges for network communication.
2. **Creating Network Namespaces**: Simulate different network environments.
3. **Creating Virtual Interfaces**: Configure veth interfaces for communication between namespaces and bridges.
4. **Assigning IP Addresses**: Setup IP addresses on namespaces and bridges.
5. **Configuring Routing and Forwarding Rules**: Allow traffic forwarding between the namespaces.
6. **Setting up IP Tables**: Apply firewall and forwarding rules.

---

## Table of Contents

1. [Create Network Bridges](#create-network-bridges)
2. [Create Network Namespaces](#create-network-namespaces)
3. [Create Virtual Interfaces and Connections](#create-virtual-interfaces-and-connections)
4. [Configure IP Addresses](#configure-ip-addresses)
5. [Configure IP Tables for Forwarding](#configure-ip-tables-for-forwarding)
6. [Configure Default Routes](#configure-default-routes)

---

## Create Network Bridges

First, create two network bridges to simulate networking between namespaces.

```bash
# Create Network Bridges
sudo ip link add br0 type bridge
sudo ip link add br1 type bridge

# Bring up the network bridges
sudo ip link set br0 up
sudo ip link set br1 up
```

- `br0` and `br1` are the two network bridges. These will facilitate the network communication between the namespaces and route network traffic.

---

## Create Network Namespaces

Now, create three network namespaces: `ns1`, `ns2`, and `route-ns`. 

```bash
# Create Network Namespaces
sudo ip netns add ns1
sudo ip netns add ns2
sudo ip netns add route-ns
```

- `ns1` and `ns2`: These namespaces represent isolated networking environments where you will assign virtual network interfaces.
- `route-ns`: This namespace will handle the routing between `ns1` and `ns2`.

---

## Create Virtual Interfaces and Connections

Next, create virtual Ethernet (veth) interfaces that will connect the namespaces and bridges.

```bash
# Create Virtual Interfaces and Connections
sudo ip link add veth-ns1 type veth peer veth-br0
sudo ip link add veth-ns2 type veth peer veth-br1
sudo ip link add veth-rns-0 type veth peer veth-rns-br0
sudo ip link add veth-rns-1 type veth peer veth-rns-br1

# Assign interfaces to namespaces and bridges
sudo ip link set veth-ns1 netns ns1
sudo ip link set veth-br0 master br0
sudo ip link set veth-ns2 netns ns2
sudo ip link set veth-br1 master br1
sudo ip link set veth-rns-0 netns route-ns
sudo ip link set veth-rns-br0 master br0
sudo ip link set veth-rns-1 netns route-ns
sudo ip link set veth-rns-br1 master br1
```

- `veth-ns1`, `veth-ns2`: These interfaces will connect the `ns1` and `ns2` namespaces to the bridges `br0` and `br1`.
- `veth-rns-0`, `veth-rns-1`: These interfaces connect the `route-ns` namespace to the bridges for routing purposes.

---

## Configure IP Addresses

Assign IP addresses to the network interfaces for communication within and between namespaces.

```bash
# Assign IP addresses to network bridges
ip addr add 10.10.1.1/16 dev br0
ip addr add 10.11.1.1/16 dev br1

# Assign IP addresses to virtual interfaces within namespaces
sudo ip netns exec ns1 ip addr add 10.10.1.2/16 dev veth-ns1
sudo ip netns exec ns2 ip addr add 10.11.1.2/16 dev veth-ns2

# Assign IP addresses to virtual interfaces in route-ns
sudo ip netns exec route-ns ip addr add 10.10.1.3/16 dev veth-rns-0
sudo ip netns exec route-ns ip addr add 10.11.1.3/16 dev veth-rns-1
```

- `br0` is assigned IP `10.10.1.1/16`, and `br1` is assigned IP `10.11.1.1/16`.
- `ns1` and `ns2` have IP addresses `10.10.1.2/16` and `10.11.1.2/16`, respectively.
- The `route-ns` namespace gets `10.10.1.3/16` and `10.11.1.3/16` IPs for routing.

---

## Configure IP Tables for Forwarding

Set up the firewall rules to allow packet forwarding between the network interfaces and bridges.

```bash
# Enable forwarding for the bridges
sudo iptables --append FORWARD --in-interface br0 --jump ACCEPT
sudo iptables --append FORWARD --out-interface br0 --jump ACCEPT
sudo iptables --append FORWARD --in-interface br1 --jump ACCEPT
sudo iptables --append FORWARD --out-interface br1 --jump ACCEPT
```

- These rules enable communication between the namespaces and the network bridges (`br0` and `br1`).

---

## Configure Default Routes

Finally, set the default routes for the namespaces so they can route traffic to the correct gateway.

```bash
# Set the default route for ns1 and ns2
sudo ip netns exec ns1 ip route add default via 10.10.1.1
sudo ip netns exec ns2 ip route add default via 10.11.1.1
```

- The `ns1` namespace uses `10.10.1.1` as its default gateway.
- The `ns2` namespace uses `10.11.1.1` as its default gateway.

---
