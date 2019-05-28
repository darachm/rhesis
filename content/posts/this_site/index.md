---
title: "How this site is put together : hugo + git + nearlyfreespeech.com "
date: 2018-07-13
page: true
tags:
    - how-to
    - git
    - hugo
    - makefile
---

This site is typeset by [Hugo](https://gohugo.io/documentation/),
hosted on [NearlyFreeSpeech](https://http://nearlyfreespeech.net/).

It's all setup using the [guide here](
  https://www.penwatch.net/cms/get_started_plain_blog/), 
written by Li-aung “Lewis” Yip.
"A good citizen of the internet" indeed!

The above should work for you if you're setting up your own.
When I first set it up (using a theme, this latest version doesn't
theme), I made an informative mistake in omitting the part of the 
hook that pulls down the theme, thinking I was being clever, 
but had a chance to learn about git repos not double-tracking 
theme files.

The below sites were also useful in understanding what all the 
pieces in Li-uang's guide (above) were doing:

- https://andytaylor.me/2012/11/03/nfs-git/
- https://webschneider.org/post/hugo-workflow-git/

I've also got a little Makefile that converts various flat files to
a jpeg format in the appropriate place.

    quality := 75
    INPUT_JPG := $(shell find content/ -type f -regextype sed -regex '.*/.*.JPG')
    INPUT_jpg := $(shell find content/ -type f -regextype sed -regex '.*/.*.jpg')
    INPUT_png := $(shell find content/ -type f -regextype sed -regex '.*/.*.png')
    SCRUBED_JPG_FILES := $(patsubst %.JPG, %.jpeg, $(INPUT_JPG)) 
    SCRUBED_jpg_FILES := $(patsubst %.jpg, %.jpeg, $(INPUT_jpg)) 
    SCRUBED_png_FILES := $(patsubst %.png, %.jpeg, $(INPUT_png)) 
    SCRUBED_FILES = $(SCRUBED_JPG_FILES) $(SCRUBED_jpg_FILES) $(SCRUBED_png_FILES)
    $(SCRUBED_JPG_FILES): %.jpeg : %.JPG
    	convert -quality $(quality) $< tmp.png && convert tmp.png $@ && rm tmp.png
    $(SCRUBED_jpg_FILES): %.jpeg : %.jpg
    	convert -quality $(quality) $< tmp.png && convert tmp.png $@ && rm tmp.png
    $(SCRUBED_png_FILES): %.jpeg : %.png
    	convert -quality $(quality) $< tmp.png && convert tmp.png $@ && rm tmp.png

Then I'm using git to track these to make the upload easier, although
it's a tool designed for versioning images. I don't plan to update 
these, so we'll see how large the repo can get.

Here's [the repo](https://bitbucket.org/darachm/rhesis) where the
code and content is hosted.

