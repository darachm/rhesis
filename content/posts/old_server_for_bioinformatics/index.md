---
title: "Old server for bioinformatics"
date: 2019-04-12
draft: true
tags: [science,computers]
---

On the tin, I should have access to some pretty sweet computational resources
at my job. But, we don't pay into the cluster, so we don't have priority.
I don't have the cred to get a 16 or 20 core node for 2 days, and I kinda have
a job that needs it. Also, I'm sick of waiting in line for 8 cores 30GB of RAM
node that has permission to run 4 days, only to have it bug out and have to
wait a half-week to attempt another run.

So I bought an old server on craigslist.

I'm blessed with being in the south bay, as there's so many wasteful companies 
who dump this crap into destruction or craigslist. One guy told me that 
companies will take a hammer to the computers so that they can declare it as a 
loss for accounting purposes. 

I got a Dell R710, so ten years old, from a liquidation guy in south SF.
It's got 2xquad-core Xeon 2.93Ghz processors,
48GB RAM with 4 slots empty (so 64GB with 4GB modules each, DDR3 of course).
No hard-drive, so I had to find another guy on craigslist selling hard drives.
This hard-drive guy was between jobs and started parting out the recycled 
electronics from a side-gig. He's the one who told me about the extensive waste
from the tech industry, smashing gear to satisfy the balance sheets.

Anyways, I eventually got the parts to make it sorta work (cords, free monitor
from the liquidation guy, some half-working screws for the drives), and set it
up. This thing is huge.

# Configuring

Here's how to get it running sufficient to do `nextflow`-launched 
`singularity`-contained bioinformatics pipelines.

## RAID

First, boot the darn thing. It howls with the wind of some serious fans.
Kinda cool, a little scary, but it calms down.

When prompted after the first DELL screen, hit Ctrl+r to access the RAID 
interface. This is a hardware chip that handles your RAID, which is pretty
sweet. Tell it to delete any devices there, then make new devices however
you want. I did a RAID1 of two hard drives, so they're redundant. 
Once you do that, then select them to do "Fast Init". The regular initialize
will take forever.

Then reboot.

## Installing OS

I'm putting ubuntu on here, as it's pretty darn stable and kind of the lingua
franca of linux distributions (and I've forgiven them for Unity).

The first problem is getting it to boot from USB. For this R710, and apparently
other Dell PowerEdge servers, you need to do the following (roughly):

    - boot the server
    - stick a USB key in the back (I think the front works too, but not tested)
    - go to F2 settings
    - go to boot settings
    - make sure to change the Hard Drive Emulation settings to emulate the USB
        as a Hard Drive
    - reboot
    - go to F11 boot options
    - select the C: drive, and you'll see one option for the hard disk drive,
        and one option for the USB key if you did it right
    - select that USB key in the C: drive to boot it up

Which OS?

Ubuntu is still a bloated beast.
Ubuntu gives you easy canned options on their downloads, and they don't work
here. It's a little difficult to find the option to get the "MinimalCD" ISO,
but they do keep it current, so bless their hearts. This is what you want.

Why? When I tried the 18.04 LTS "server" ISO, it hung with a black screen and
a mouse. Some folks online claimed to see a similar thing when that evil
`lightdm` was at play, and suggested ways to go to terminal to kill it. That
didn't work here.

So, I used `dd` to flash a minimal CD ISO to a USB key, and that worked fine.
It's a `ncurses`-like easy to navigate install wizard, pretty great.

So minimal CD ubuntu is A+ works great 10/10 would install again.

## Setting up software

Just after logging in, I installed `vim` `git` `default-jdk`, then 
`git clone`'d my pipeline repo down, `sftp` to download the data to the `data`
directory in the repo, then hit `make all`.

# Conclusion, money, alternatives

So a setup of 2xquad-core Xeon 2.93Ghz, 48GB RAM, and 900GB RAD1 ready to run
pipelines set me back $250. 

I was also pricing out other options. I could've built a computer, probably
based on the Ryzen 5 2600. That would give me 12 cores at ~3.5Ghz after 
overclocking for about $150. Then, a motherboard for another $150, 32GB RAM 
for ~$140. Power-supply would cost another ~$50, then a GPU to run the display
for $30 or so. This is assuming no costs for case (I was thinking about 
screwing it into a plastic tupperware with holes cut in it), and no other
costs. Oh, and a drive would cost about the same, $100.

So for a bit more, I could have less RAM, 50% more cores at a faster speed.
However, this is together set package. So long as you can get a server that's
actually just being retired (and not broken), it might be a good idea for
getting bioinformatics done with no wait.
