#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.7

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8


ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION 3.6.5
ENV INSTALL_PATH /software/python


RUN set -ex \
    && apk add --no-cache ca-certificates vim bash lftp vsftpd gnupg \  
    && apk add --no-cache --virtual=.fetch-deps build-base \
       zlib-dev readline-dev bzip2-dev ncurses-dev sqlite-dev gdbm-dev xz-dev tk-dev \  
       linux-headers libffi-dev expat-dev  libbz2  dpkg dpkg-dev \ 
    && apk add --no-cache --virtual=.build-deps libressl-dev python3-dev \
    && mkdir -p ${INSTALL_PATH} \
    && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
    && tar -xJC ${INSTALL_PATH} --strip-components=1 -f python.tar.xz \
    && rm python.tar.xz \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && cd ${INSTALL_PATH} && ./configure \
        --build="$gnuArch" \
        --enable-loadable-sqlite-extensions \
        --enable-shared \
        --with-system-expat \
        --with-system-ffi \
        --with-ssl\
    && make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" \
    && make install \
    \
    && find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' + \
    && rm -rf ${INSTALL_PATH}
    
# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
    && ln -s idle3 idle \
    && ln -s pydoc3 pydoc \
    && ln -s python3 python \
    && ln -s pip3 pip \
    && ln -s python3-config python-config

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 10.0.1

RUN python -m pip install --upgrade pip \
    && pip install Django==2.0.5 \
    && pip install Cython \
    && pip install jieba \
    && pip install fasttext \
    && pip install gensim \
    && pip install pyLDAvis \
    && pip install xlrd \
    && pip install pymysql \
    && pip install datetime \
    && pip install os \
    && pip install sys \
    && pip logging \
    && pip json \
    && pip libs \
    && pip pandas \
    && pip gensiom

EXPOSE 19000
CMD ["python"]
