#SUBDIRS = GWTSplit
SUBDIRS = GWTSplit BubbleSort

all:	subdirs

subdirs:
	for dir in $(SUBDIRS); do \
	$(MAKE) -C $$dir; \
	done
