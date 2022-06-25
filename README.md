# Using MAP-E (OCN) on a Linux router

**STATUS: WORK IN PROGRESS**

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

Ideally I would setup something like ansible or puppet with gitops, but since this
seems to be a problem people are constantly facing I figured it would be better
to do something a bit simpler so we can all learn together.

## Install

> NOTE: this is how it should work after I finish working on this.

This is the TL;DR for configuring your network with the scripts on this page.

1. checkout this repository to the machine you want to configure as router.
1. rename `env.sh.template` do `env.sh` and fill in the information found 
   previously on this page.
1. make a new file called `env.ports` with the contents of the ports textarea.
1. `./setup.sh sysctl` to generate the sysctl configuration.
1. `./setup.sh systemd` to generate the systemd-networkd configuration.
1. `./setup.sh tunnel-forward` to generate the tunnel forwarding scripts
1. `./setup.sh tunnel-ports` to generate the tunnel ports forwarding script.

All the information being output should then be copied to your configuration files
in /etc/. We do not overwrite files there because we don't wait to break people's
systems by doing something we shouldn't at this stage.

After this reboot and it `should` work? Idk.. I am still developing this.
