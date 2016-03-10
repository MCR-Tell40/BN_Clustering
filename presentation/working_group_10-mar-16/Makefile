SRC = main.tex
PDF = main.pdf
AUX = main.aux
TEXC := xelatex
TEXC_OPTS += -shell-escape
TEXMFHOME = $(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR = $(TEXMFHOME)/tex/latex/mtheme
DOCKER_IMAGE = latex-image
DOCKER_CONTAINER = latex-container

.PHONY: clean install docker-run docker-rm $(PDF)

all: $(PDF)

$(AUX):
	$(TEXC) $(TEXC_OPTS) $(SRC)

$(PDF): beamerthemem.sty $(AUX) $(SRC)
	$(TEXC) $(TEXC_OPTS) $(SRC)

clean:
	@rm -f $(PDF)

install:
	mkdir -p $(INSTALL_DIR)
	cp *.sty $(INSTALL_DIR)

docker-run: docker-build
	docker run --rm=true --name $(DOCKER_CONTAINER) -i -t -v `pwd`:/data $(DOCKER_IMAGE) /data/build.sh

docker-build:
	docker build -t $(DOCKER_IMAGE) .

docker-rm:
	docker rm $(DOCKER_CONTAINER)
