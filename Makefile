

# This part finds and scrubs image files by converting to png and back
quality := 75
INPUT_JPG := $(shell find content/ -type f -regextype sed -regex '.*/.*.JPG')
INPUT_jpg := $(shell find content/ -type f -regextype sed -regex '.*/.*.jpg')
INPUT_png := $(shell find content/ -type f -regextype sed -regex '.*/.*.png')
SCRUBED_JPG_FILES := $(patsubst %.JPG, %.jpeg, $(INPUT_JPG)) 
SCRUBED_jpg_FILES := $(patsubst %.jpg, %.jpeg, $(INPUT_jpg)) 
SCRUBED_png_FILES := $(patsubst %.png, %.jpeg, $(INPUT_png)) 
SCRUBED_FILES = $(SCRUBED_JPG_FILES) $(SCRUBED_jpg_FILES) $(SCRUBED_png_FILES)
$(SCRUBED_JPG_FILES): %.jpeg : %.JPG
	convert -quality $(quality) $< tmp.png && convert -quality $(quality) tmp.png $@ && rm tmp.png
$(SCRUBED_jpg_FILES): %.jpeg : %.jpg
	convert -quality $(quality) $< tmp.png && convert -quality $(quality) tmp.png $@ && rm tmp.png
$(SCRUBED_png_FILES): %.jpeg : %.png
	convert -quality $(quality) $< tmp.png && convert -quality $(quality) tmp.png $@ && rm tmp.png


.PHONY: all
all: $(SCRUBED_FILES)
	@echo $(SCRUBED_FILES)
