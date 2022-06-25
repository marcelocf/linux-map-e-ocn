# Using MAP-E (OCN) on a Linux router

This repository contains docs and scripts to aid configuring the MAP-E in Linux.

> **WARNING:** This is for MAP-E provided by OCN only! You can check if that is
> your case by going to [this website](https://v6test.ocn.ne.jp/) with IPv6 
> enabled in the connection you want to setup.

Also, disclaimer: I am a software engineer, NOT a network or infra engineer.
There is a huge chance information I share here is wrong or I didn't interpret
something in the right way. For that I highly recommend you look up other sources.

I tried my best to link my own sources and tried to keep them as reputable as
possible.

Also note that according to [this article)[https://arxiv.org/pdf/1612.00309.pdf],
`both MAP-E or MAP-T are still IETF’s drafts and still aren’t implemented in large scale`.
So it could be that the implementation is not exactly standard right now. I 
highly doubt that so I am moving forward.

Hopefully, once this is approved by IEFT then it might make its way into systemd-networkd
nativelly.

## Intro

I finally decided it was time to stop using the crappy routers you can buy with
out-of-the-box MAP-E support, so I got a mini PC with an extra USB NIC and got to
work.

First I had to learn the basics of IPv6. Then I had to understand what the hell
MAP-E is and later I had to figure out how to get the values from my environment.

To get you started I would first recommend you see (unless you know these topics
well):

* [IPv6 Basics for Beginners](https://www.youtube.com/watch?v=z7Al3P8ShM8).
* Juniper Network's [doc on MAP-E](https://www.juniper.net/documentation/en_US/junos/topics/topic-map/map-e-configuring.html).
* Fortigate's [doc on setting up a customer edge](https://docs.fortinet.com/document/fortigate/6.4.0/new-features/322815/map-e-support-6-4-1)
* [MAP-E IETF's draft](https://datatracker.ietf.org/doc/html/rfc7597)

With that out of the way you can start digging into the Japanese websites:

* https://vector.hateblo.jp/entry/2021/02/17/142458
* https://qiita.com/kakinaguru_zo/items/2764dd8e83e54a6605f2
* https://gato.intaa.net/archives/25972

The resource with more useful information for me, personally, was the post in
in qiita, but they all make for an interesting read (even if google translate
is necessary).

In this article I will be guiding you on my adventure on setting up a Linux box
as a router for MAP-E connections (NTT Hikari, through OCN). To keep things
simple I will be:

1. assuming a IPv4 only lan (will disable IPv6 support in the NIC).
1. not covering DHCP and DNS servers - I recommend the [Arch wiki](https://wiki.archlinux.org),
   even if you are not on Arch, for that.
1. systemd-networkd based configuration (works on most distros and it is easy
   to understand so you configure any other thing you want).

I am using Arch Linux, but it should work on any modern debian distro based on
systemd such as Ubuntu and its variants.

## Out of the box support

There has been some activity in the [Linux Kernel](https://lore.kernel.org/lkml/20210726143729.GN9904@breakpoint.cc/T/)
and [OpenWrt](https://openwrt.org/packages/pkgdata/map) (
[source code](https://github.com/openwrt/openwrt/tree/openwrt-21.02/package/network/ipv6/map))
to make MAP-E something that is supported out of the box.

So I am hopeful we can someday configure like it is just another connection in the
future, and then just tunnel everything there.

## What we want to do

First step is, of course, to get a valid IPv6 connection. Luckily you can just
use auto configuration on internet facing NIC for that to work. Yay!

Next you need to get information to configure your tunnel. As you should remember
from the documentations linked from here, we are trying to setup:

```
Client => Router (MAP-E CE) => IPv6 Network (MAP-E Domain) => MAP-E BR => IPv4 Internet
```

Also, in MAP-E we need to map ports in the router level. So the information required is:

1. Get CE address here: https://v6test.ocn.ne.jp/
1. With that in hands go here to get the rest of the info: http://ipv4.web.fc2.com/map-e.html

Take note of the following info:

* CE
* IPv4 (IPv4　アドレス)
* Ports (ポート番号)
* BR (option peeraddr)

On the Japanese websites they calculated the ports from the PSID value. Looking
at the website this seems to be exactly what they are doing as well; however, the
script provided by tose sites left out some of the ports.

Also, both Fortigate's and Juniper Network's configration failed to mention any
port mapping configuration. So I separated configuration of both.


## Setup

With this info in our hands we can continue! This is heavily based on the information
on the Japanese websites linked here, but with a fundamental difference.

Instead of making a script that runs directly changing the firewalls, I am building
a script to build configuration and firewall scripts we will actually run.

This is to make things more readable, reusable and to make sure you can double
check what the script is doing before it actually runs.

I am not doing something that directly change your system for a couple of reasons:

1. I don't want to break stuff.
1. I currently don't have time to maintain something like that.
1. I hope that when MAP-E is approved as a standard, then it will work out of the box.


Anyway, let's move on.

### sysctl

We need sysctl to be enable `ip_forward` for our tunnel interface in order to
automagically share our connection. However, since we are using `networkd` this
is taken care for us so no need to mess with sysctl.conf files here.

### systemd-networkd

Now we need to generate the systemd-networkd configuration files. There are 3, actually.

* LAN: configure your LAN as you wish.
* WAN: Enable DHCP (easier way) and RA, but then add the CE address as an aditional
  address. Also it is good to use other DNS servers than the one from the ISP:
  * Cloud Flare servers:
    * 2606:4700:4700::1111 
    * 2606:4700:4700::1001
  * Google servers;
    * 2001:4860:4860::8888
    * 2001:4860:4860::8844
* Tunnel: now you need to add the tunnel interface and configuration.

For the tunnel, it is important to link it to your WAN configuration and you
need to make it your main route. Also, make sure you are terminating in the BR.

### iptables

Lastly you need to forward all your IPv4 packets to that tunnel, remapping to
the ports that are available to you and it should work.

## Helper Script

> NOTE: this is how it should work after I finish working on this.

This is the TL;DR for configuring your network with the scripts on this page.

You can use the `generat.sh` script to generate basic configuration. However, 
in order to use it you must know how to configure:

1. systemd-networkd
1. iptables (specially how to load iptables rules when booting)

1. checkout this repository to the machine you want to configure as router.
1. rename `env.sh.template` do `env.sh` and fill in the information found 
   previously on this page.
1. open the `./generate.sh` file to see available options.

All the information being output should then be copied to your configuration files
in /etc/. We do not overwrite files there because we don't wait to break people's
systems by doing something we shouldn't at this stage.

## Useful tools for troubleshooting

You should know all that already, but it is nice to have those tools installed
before you start playing with the configuration:

* traceroute
* tcpdump
* mtr


## Results

Those are the speedtest comparing the standard direct IPv4 connection to the 
ones using MAP-E around 19:50 in a Saturday in a residential area in the Tokyo
suburbs (doesn't get worst thatn that for me).

I wanted to use the command line to run it multiple times but I was getting
very inconclusive results. The more I ran the command, even with the same server,
the slower it got. In the browser I got more consistency so I copied the results
here manually (5 per connection type), all against ID3.net Tokyo server.

Also note my connection was through my of-the-shelve router doing NAT between
my desktop and my router. I'll update these results later once I am connecting
directly to the Linux router without a NAT in between.

> **EDIT:** I ran the test a couple of times without the NAT, no relevant change.

### Direct connection via IPv4 (failed to find the server 2 times)

| Ping | Upload Mbps | Download Mbps |
| ---- | ----------- | ------------- |
| 7    | 289.09      | 216.27        |
| 6    | 233.71      | 338.02        |
| 6    | 296.23      | 356.15        |
| 6    | 269.82      | 375.47        |
| 6    | 270.82      | 382.45        |


### MAP-E enabled with `./generate.sh iptables` (15 mappings):

| Ping | Upload Mbps | Download Mbps |
| ---- | ----------- | ------------- |
| 5    | 486.95      | 439.20        |
| 5    | 479.04      | 471.66        |
| 6    | 438.71      | 443.19        |
| 5    | 466.19      | 454.57        |
| 5    | 444.66      | 463.57        |

### MAP-E enabled with `./generate.sh iptables-from-table` (63 mappings):

| Ping | Upload Mbps | Download Mbps |
| ---- | ----------- | ------------- |
| 6    | 460.18      | 450.05        |
| 6    | 482.35      | 454.17        |
| 6    | 465.48      | 463.75        |
| 5    | 496.80      | 464.84        |
| 5    | 541.80      | 439.52        |

## Conclusion

Both speed and consistency were a lot better in MAP-E mode, although CPU consumption
(not shared here) in the router as a bit higher. 

Enabling more ports didn't do much, with slightly better speeds only. But that
can also be attributed to me running the larger tests first, or even to pure
luck.
