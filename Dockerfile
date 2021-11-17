FROM debian:10-slim as builder


ARG TEQC_URL=https://www.unavco.org/software/data-processing/teqc/development/teqc_CentOSLx86_64s.zip
ARG GFZRNX_URL=http://semisys.gfz-potsdam.de/semisys/software/gfzrnx/1.13/gfzrnx_lx
ARG HATANAKA_URL=https://terras.gsi.go.jp/ja/crx2rnx/RNXCMP_4.0.8_Linux_x86_64bit.tar.gz
ARG RTKLIB_URL=https://github.com/tomojitakasu/RTKLIB.git
ARG RTKLIB_TAG=rtklib_2.4.3
ARG RTKLIB_SHA=c6e6c03143c5b397a9217fae2f6423ccf9c03fb7
ARG RTKLIB_EXPLORER_URL=https://github.com/rtklibexplorer/RTKLIB.git
ARG RTKLIB_EXPLORER_TAG=demo5
ARG RTKLIB_EXPLORER_SHA=fc556677165a3be7b3886fba68f42dbec7fb363e

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
    rm -rf /var/lib/apt/lists/* 
# Get RTKLIB and compile only required components

WORKDIR /tmp
COPY external .

RUN unzip teqc_CentOSLx86_64s.zip -d /usr/local/bin && rm -rf teqc_CentOSLx86_64s.zip && \
    cp gfzrnx_lx /usr/local/bin/gfzrnx_lx && chmod ugo+x /usr/local/bin/gfzrnx_lx && \
    tar xvfz RNXCMP_4.0.8_Linux_x86_64bit.tar.gz && mv RNXCMP_*/bin/* /usr/local/bin && rm -rf RNXCMP_* && \ 
    git clone --branch ${RTKLIB_TAG} ${RTKLIB_URL} && \ 
    (cd RTKLIB && git checkout ${RTKLIB_SHA}) && \
    (cd RTKLIB/lib/iers/gcc/; make -j 16)  && \
    (cd RTKLIB/app/convbin/gcc/; make -j 16; make install)  && \
    (cd RTKLIB/app/rnx2rtkp/gcc/; make -j 16; make install)  && \
    (cd RTKLIB/app/pos2kml/gcc/; make -j 16; make install) && \
    (cd RTKLIB/app/rtkrcv/gcc/; make -j 16; make install) && \
    (cd RTKLIB/app/str2str/gcc/; make -j 16; make install) && \
    rm -rf RTKLIB && \
    git clone --branch ${RTKLIB_EXPLORER_TAG} ${RTKLIB_EXPLORER_URL}  && \ 
    (cd RTKLIB && git checkout ${RTKLIB_EXPLORER_SHA}) && \
    (cd RTKLIB/app/consapp/rnx2rtkp/gcc/; make -j 16; cp rnx2rtkp /usr/local/bin/rnx2rtkp_e)  && \
    rm -rf RTKLIB
    

FROM debian:10-slim as debian

RUN apt-get update && apt-get install -y csh gfortran && \
     rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/* /usr/local/bin/


FROM python:3.7-slim-buster as python

RUN apt-get update && apt-get install -y csh gfortran && \
     rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/* /usr/local/bin/