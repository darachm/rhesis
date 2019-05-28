---
title: "MTP papers on a Fire"
date: 2019-01-13
tags: 
    - MTP
    - issues
    - how-to
page: true
---

It's important to have a good system for grabbing the literature, pre or post
print, prioritizing it, reading, and keeping notes. Reading is an essential
part, and can be made easier by being made more portable. The best format is
good old paper from a color printer, but those costs can rack up if you don't
have a good institutionally provided printer and a way of organizing paper.
Here's how I'm using a used Amazon Fire tablet to do my reading.

In 2012, I looked into e-readers and got whatever barnes and noble were selling
at the time. It didn't work for science PDFs, as the formatting was re-formatted
for smaller than 8.5x11, and figures got mangled. I wished for a small tablet
to display papers as images, but didn't want to get entanged in an ipad.

In 2018, I picked up someone's amazon fire. It did what I wanted (show PDFs),
and on ebay it turned out to be real cheap (~$30 after shipping). Once you can
get PDFs on there (mine came with a SD card slot, thankfully), it displays just
fine on the adobe pdf application. I'm sure there are alternatives. Since I take
my notes on paper (high DPI, low power, lightweight, cheap, drop-proofed), I
don't care about highlighting or comments or notes or interacting with the text.

# How to get files sync'd onto the device?

How do I most easily get PDFs onto the device? I've got a big folder of PDFs on
my laptop. 
I could entangle myself in all sorts of boutiquey specialty corporate methods of
emailing through the clouds[^amazon], 
but I want something stable, open source, that I can launch with a `make sync`.
`rsync` would be nice, but The Bastards are only using MTP now for USB 
transfers, so it gets a bit weird in transferring since you can't mount the
SD card like a filesystem.

Hence MTP, a protocol that is, well, pretty darn shitty to use. It really sucks
to have to use it. It feels like my system is trying to talk to a cheapo 
2003-era mp3 player. I don't really do computers, so maybe this is the best 
they could come up with. Maybe with a shitty enough USB transfer system (MTP), 
that forces users to go to the Cloud.

So how to avoid that dependency? Below I describe some troubleshooting and
solutions to using `libmtp` tools (for which I am very thankful) to synchronize
files through this buffon of a protocol.

## MTP on ubuntu to a fire

For the below, I'm going to put `-->` to denote a shell command:

    --> echo "this is a shell command"

Other monospace text are responses, except for the shell script at the 
end[^script]:

### Listing files

Anyways, I'm using Ubuntu 18.04 for this. I used

    --> sudo apt install "libmtp*"

to grab all the `libmtp` packages. First here I need to know what's on each
device, so I made a shell script that could grab
all of my local files and PDFs on the device, using commands like these:

    --> find ~/pdf_library/*pdf -print0 | \
        sed 's/[[:blank:]]/ASPACE/g' | \
        xargs -0 -I'{}' basename '{}' \
        > .tmp.pdf_here
    
    --> mtp-files | \
        grep "Filename:" | sed 's/^\s\+Filename: //' | \
        sed 's/[[:blank:]]/ASPACE/g' \
        > .tmp.pdf_on_mtp

So these are listing the files, munging out spaces with `ASPACE`, then spitting
them out as a temporary file. That works fine.

### What files to send?

I want to know what files aren't on the MTP device. I don't really care about
date modified, since I'm really not updating these PDFs (I usually just rename).
I can use `grep` to get a list of files that are in the local but not the MTP:

    --> grep --file=.tmp.pdf_on_mtp -xv .tmp.pdf_here | grep -v "^Binary file"

That's something I can iterate over with a `for` loop or `xarg`, but how the
hell do I send the file? 

### How the hell do you send a file?

If I try to test this with a text file

    --> mtp-sendfile test test

Then it spends _forever_ bullshitting with itself and then replies: 

    libmtp version: 1.1.13
    
    Device 0 (VID=1949 and PID=0221) is a Amazon Kindle Fire 7.
    Android device detected, assigning default bug flags
    Sending test.pdf to test.pdf
    type: pdf, 44
    Sending file...
    
    Error sending file.
    Error 2: PTP Layer error 201a: send_file_object_info(): Could not send object info.
    Error 2: Error 201a: PTP Invalid Parent Object

After digging around in the github repo (actually usable by the way), I
ended up trying to specify a parent folder in the command. This has to be in
quotes because they used spaces (heresy) in the directory on the Fire, so:

    --> mtp-sendfile test "Storage\ device/test"  

That worked once! And then I did changed something else and did it again, and 
failure! Strange! :

    libmtp version: 1.1.13                       
     
    Device 0 (VID=1949 and PID=0221) is a Amazon Kindle Fire 7.
    Android device detected, assigning default bug flags
    Sending test to Storage\ device/test
    type: , 44
    Sending file...
    
    Error sending file.
    Error 2: PTP Layer error 2002: get_suggested_storage_id(): could not get storage id from parent id.
    Error 2: Error 2002: PTP General Error
    Error 2: PTP Layer error 2002: send_file_object_info(): Could not send object info.
    Error 2: Error 2002: PTP General Error

Maybe it can't handle overwrites? So we delete the original file

    --> mtp-delfile -f "Storage\ device/test"

(as other operations, this takes about a minute to even pop up an argument
error message, that's kinda funky implementation but I'll take whatever they
give me) ...

    libmtp version: 1.1.13
    
    Device 0 (VID=1949 and PID=0221) is a Amazon Kindle Fire 7.
    Android device detected, assigning default bug flags

and there is no response because, why confirm a thing if it's hard? What if
we try to delete it twice? Same lack of response. So are the files still there?

    --> mtp-files | less

Of course they're still there! It reports a file number, so I can use that
and it deletes the file, and that actually confirms:

    --> mtp-delfile -n 51200
    libmtp version: 1.1.13
    
    Device 0 (VID=1949 and PID=0221) is a Amazon Kindle Fire 7.
    Android device detected, assigning default bug flags
    Deleting 51200

Aha! Weird. So it doesn't confirm deletions.

How about deleting files below the storage "folders", so in sub-folders?
After poking it a bit, it seems that the top level "folders"
are just trappings to lull you into a sense of familiarity without actually 
offering any of the protections of directory. These are actually storage
devices. Folders below this don't do anything for deletion, at least as far as
I saw in testing. You can specify a bare file name if it's at the top level of
a storage device, but not for lower.

    --> mtp-delfile -f 0311039.pdf
    libmtp version: 1.1.13
    
    Device 0 (VID=1949 and PID=0221) is a Amazon Kindle Fire 7.
    Android device detected, assigning default bug flags
    Deleting 0311039.pdf
    Failed to delete file:0311039.pdf
    Error 2: PTP Layer error 2009: LIBMTP_Delete_Object(): could not delete object.
    Error 2: Error 2009: PTP Invalid Object Handle

If you specify either the parent folder with or without the storage device
"folder", then it just doesn't delete it and fails silently.

So the `-f` filename argument doesn't really work? The number does. If you
give it `-n 1234` it'll go ahead and delete 1234 and tell you it did so.
How do we get the number? It's in the list of files, but not in a single-record
per line paradigm. So...

Caching the file list (because it's so so so slow), we can now turn it into
a index to grep into:

    --> tail -n +6 .tmp.mtp_files | head -n -1 | paste -s | \                            
        sed 's/File ID: /\n/g' | sed 's/ Filename: /\t/g' | \                        
        sed 's/File size.*//' \                                                      
        > .tmp.mtp_index                                                             

So we'll do that, but notice the tab in the file query! Important. Maybe should
be a comma? YMMV.

    --> mtp-delfile -n $(grep "    botlab_fish.pdf$" .tmp.mtp_index | sed 's/\s\+.*//')
    libmtp version: 1.1.13
    
    Device 0 (VID=1949 and PID=0221) is a Amazon Kindle Fire 7.
    Android device detected, assigning default bug flags
    Deleting 49032

Applying that to the test files, we can delete everything and retry a test
transfer like so

    --> mtp-sendfile test.pdf "Storage\ device/asubfolder/test.pdf"
    libmtp version: 1.1.13
    
    Device 0 (VID=1949 and PID=0221) is a Amazon Kindle Fire 7.
    Android device detected, assigning default bug flags
    Sending test.pdf to Storage\ device/asubfolder/test.pdf
    type: pdf, 44
    Sending file...
    Progress: 302 of 302 (100%)
    New file ID: 51202

Finally! So now we can put this into xargs:

    --> grep --file=.tmp.pdf_on_mtp -xv .tmp.pdf_here | \
        grep -v "^Binary file" | \       
        xargs -I '{}' mtp-sendfile ~/pdf_library/"{}" '"Storage\ device/pdf_library/{}"'

Note the quotes, they're a bit weird, but that's what it is. 

When we wrap this
together in one script[^script] it runs, but it is so goddamn slow. But it's 
automated, so this can sit in the background and it'll just take 10 minutes to
finish talking back and forth with the MTP device. Good enough.

## Summary

Sending a file, you've got to specify "folders" from the storage device and
then any other paths. It doesn't handle overwrites gracefully, or even let you
know what's up. 

To talk MTP for deleting, you gotta talk file IDs, which means 
you've got to wait a minute for it to hand you a list. 
Then you munge it into a filename to ID index, and
then you can compare lists and send what you want (each transfer takes a few
minutes). 
Maybe you can send multiple at a time, but I don't want to have to deal with
the debugging on that, so let me know if it's a possibility?

Other than MTP, the Amazon Fire Kindling Kindle thing works good for PDF
papers.

# Other notes

[^amazon]: The part where it's an amazon device is weird, but to help moderate 
    that you can make an account with any old disposable email address and then
    just turn it on airplane mode. Every few months you'll have to connect to 
    wifi so the adobe reader can talk to the mothership and renew the license, 
    but other than that it seems like it tolerates disconnect from the Hive 
    well.

[^script]: This is slightly munged, as your mileage will vary, and I've changed
    the directory names to protect the innocent. It may be inconsistent from
    above.

        #!/usr/bin/env bash
        
        echo "Building local PDF list..."
        find ~/pdf_library/*pdf -print0 | \
            sed 's/[[:blank:]]/ASPACE/g' | \
            xargs -0 -I'{}' basename '{}' \
            > .tmp.pdf_here
        
        echo "Asking nicely for MTP list..."
        mtp-files > .tmp.mtp_files
        cat .tmp.mtp_files | \
            grep "Filename:" | sed 's/^\s\+Filename: //' | \
            sed 's/[[:blank:]]/ASPACE/g' \
            > .tmp.pdf_on_mtp
        
        echo "Making filename to MTP ID index..."
        tail -n +6 .tmp.mtp_files | head -n -1 | paste -s | \
            sed 's/File ID: /\n/g' | sed 's/ Filename: /\t/g' | \
            sed 's/\s\+File size.*//' \
            > .tmp.mtp_index
        
        echo "Transferring things that are here but not there..."
        grep --file=.tmp.pdf_on_mtp -xv .tmp.pdf_here | grep -v "^Binary file" | \
            xargs -I '{}' mtp-sendfile ~/pdf_library/"{}" '"Storage\ device/pdf_library/{}"'
        
        echo "Fin de la programa."
        
        # Snippet to delete a troublesome-file.pdf, remember the tab in front of the
        # search pattern:
        #
        # mtp-delfile -n $(grep "   troublesome-file.pdf$" .tmp.mtp_index | sed 's/\s\+.*//')
        
