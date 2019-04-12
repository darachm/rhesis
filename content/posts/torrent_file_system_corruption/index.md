---
title: "Torrent file system corruption"
date: 2019-04-11
draft: true
tags: bugs
---

I've had a problem where `rtorrent` and `transmission` both try to download a
torrent, but find that the chunks of the file fail to check properly. 
Specifically, this is the ubuntu install iso (because straight download from
their servers is horrifically slow from where I am, could be ISP throttling
but I doubt it). 

This is also going onto a btrfs filesystem. I'd seen on github that someone
reported changing the filesystem fixes it. I was able to get around this using
a ramdisk:

    sudo mount -t tmpfs -o size=2056m tmpfs ./ramdisk

Then, I moved into the `ramdisk` folder, did the torrent thing, then copied
the file out of the ramdisk and onto the hard-drive. Not a sustainable
solution for honest torrenting (hosting for uploads), but if you absolutely
need to download something, it'll work.

Why does this do this? Perhaps there's some latency between write and reads
that's asynchronous on the way I've set this up? Strange.
