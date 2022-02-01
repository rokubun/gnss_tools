FROM debian:11-slim as builder

ARG TEQC_URL=https://www.unavco.org/software/data-processing/teqc/development/teqc_CentOSLx86_64s.zip
ARG GFZRNX_URL=http://semisys.gfz-potsdam.de/semisys/software/gfzrnx/1.13/gfzrnx_lx
ARG HATANAKA_URL=https://terras.gsi.go.jp/ja/crx2rnx/RNXCMP_4.0.8_Linux_x86_64bit.tar.gz
ARG RTKLIB_EXPLORER_URL=https://github.com/rtklibexplorer/RTKLIB.git

ARG RTKLIB_EXPLORER_TAG=b34c

WORKDIR /tmp
COPY external .

RUN apt-get update && apt-get install -y \
        bash \
        build-essential  \
        gcc \
        git \
        wget \
        gfortran \
        unzip \
        curl  \ 
        bzip2  && \
    rm -rf /var/lib/apt/lists/* && \
    unzip teqc_CentOSLx86_64s.zip -d /usr/local/bin && rm -rf teqc_CentOSLx86_64s.zip && \
    cp gfzrnx_lx /usr/local/bin/gfzrnx_lx && chmod ugo+x /usr/local/bin/gfzrnx_lx && \
    tar xvfz RNXCMP_4.0.8_Linux_x86_64bit.tar.gz && mv RNXCMP_*/bin/* /usr/local/bin && rm -rf RNXCMP_* && \ 
    unzip rtklib-${RTKLIB_EXPLORER_TAG}.zip && \
    (cd RTKLIB-${RTKLIB_EXPLORER_TAG}/lib/iers/gcc/; make -j 16)  && \
    (cd RTKLIB-${RTKLIB_EXPLORER_TAG}/app/consapp/convbin/gcc/; make -j 16; make install)  && \
    (cd RTKLIB-${RTKLIB_EXPLORER_TAG}/app/consapp/rnx2rtkp/gcc/; make -j 16; cp rnx2rtkp /usr/local/bin/rnx2rtkp_e)  && \
    (cd RTKLIB-${RTKLIB_EXPLORER_TAG}/app/consapp/pos2kml/gcc/; make -j 16; make install) && \
    (cd RTKLIB-${RTKLIB_EXPLORER_TAG}/app/consapp/rtkrcv/gcc/; make -j 16; make install) && \
    (cd RTKLIB-${RTKLIB_EXPLORER_TAG}/app/consapp/str2str/gcc/; make -j 16; make install) && \
    rm -rf RTKLIB-${RTKLIB_EXPLORER_TAG}
    

FROM debian:11-slim as debian

RUN apt-get update && apt-get install -y csh gfortran && \
     rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/* /usr/local/bin/


FROM python:3.9-slim-bullseye as python

RUN apt-get update && apt-get install -y csh gfortran && \
     rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/* /usr/local/bin/