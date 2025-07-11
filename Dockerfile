FROM python:3.13-bookworm

RUN apt-get update && apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    g++-10 cmake ninja-build ccache \
    # python3 python3-dev
    # GNU Scientific Library
    gsl-bin libgsl-dev libgslcblas0 \
    # openflow
    libboost-all-dev \
    # GTK-based config store
    libgtk-3-dev \
    libfl-dev \
    # XML config store
    libxml2 libxml2-dev \
    libopenmpi-dev openmpi-bin openmpi-common openmpi-doc \
    libsqlite3-dev sqlite3 \
    # Eigen
    libeigen3-dev \
    # NetAnim animator
    qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
    ssh git \
    # DPDK
    # ns-3 requires DPDK v19.11
    # but debian doesn't have that version
    # dpdk dpdk-dev libdpdk-dev dpdk-igb-uio-dkms \
    # Emulation with virtual machines and tap bridge
    lxc \
    lxc-templates \
    iproute2 \
    iptables \
    # PyViz visualizer
    gir1.2-goocanvas-2.0 \
    python3-gi \
    python3-gi-cairo \
    python3-pygraphviz \
    gir1.2-gtk-3.0 \
    ipython3 \
    && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN python3 -m pip install --user cppyy==3.1.2

WORKDIR /workspace

# https://www.nsnam.org/docs/models/html/openflow-switch.html
RUN git clone https://gitlab.com/nsnam/openflow && \
    cd openflow && \
    cmake -B build && \
    cmake --build build && \
    cmake --install build

# https://gitlab.com/nsnam/BRITE
RUN git clone https://gitlab.com/nsnam/BRITE && \
    cd BRITE && \
    make

# https://www.nsnam.org/docs/models/html/click.html#building-click
# RUN git clone https://github.com/kohler/click && \
#     cd click && \
#     ./configure --disable-linuxmodule --enable-nsclick --enable-wifi && \
#     make

# https://www.nsnam.org/docs/release/3.45/installation/singlehtml/index.html#download
RUN git clone https://gitlab.com/nsnam/ns-3-dev.git && \
    cd ns-3-dev && \
    git checkout -b ns-3.45-release ns-3.45 \
    && \
    ./ns3 configure \
    --enable-examples \
    --enable-tests \
    --enable-build-version \
    # --enable-dpdk \
    --enable-des-metrics \
    --enable-python-bindings \
    # MPI conflicts with Python bindings
    --disable-mpi \
    # --with-brite=/workspace/BRITE \
    --with-openflow=/usr/local/lib/libopenflow.a \
    && \
    ./ns3 build \
    && \
    ./test.py

WORKDIR /workspace/ns-3-dev

ENTRYPOINT ["/usr/bin/bash"]
