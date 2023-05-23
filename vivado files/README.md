# Router_1-3


Router : A router is a networking device that forwards data packets between computer networks.

Routers are used to connect multiple networks together and to direct network traffic between them. They operate at the network layer of the OSI model, which means they use IP addresses to identify and route packets.

When a router receives a data packet, it examines the packet's header to determine its destination network address. The router then uses a routing table, which contains information about the topology of the connected networks, to determine the best path to forward the packet. The router then sends the packet on to the next router or destination device on the selected path.

Routers can be used in a variety of settings, including homes, businesses, and large-scale enterprise networks. They are essential components of the internet and other wide-area networks, where they are used to connect different geographic regions together. Routers can also be used in wireless networks, where they connect wireless devices to a wired network or to other wireless networks.

Here we implemented a Router design having one source and three destinations using verilog HDL.

In this design, the router top module contains mainly 4 individual sub-block modules :

1. FIFOs - 3 required 
2. FSM 
3. Synchronizer 
4. Register
