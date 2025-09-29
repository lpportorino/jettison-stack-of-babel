# Stage 05: Python via pyenv
ARG BASE_IMAGE=jon-babylon:04-clojure
FROM ${BASE_IMAGE}

LABEL stage="05-python"
LABEL description="Python 3.13 and 3.12 via pyenv"

# Copy and run installation script
COPY tools/python/install/install.sh /tmp/install-python.sh
RUN chmod +x /tmp/install-python.sh && \
    /tmp/install-python.sh && \
    rm /tmp/install-python.sh

# Install Nuitka
COPY tools/python/install/nuitka.sh /tmp/install-nuitka.sh
RUN chmod +x /tmp/install-nuitka.sh && \
    /tmp/install-nuitka.sh && \
    rm /tmp/install-nuitka.sh

# Copy and test Python script
COPY tools/python/test/hello.py /tmp/hello.py
RUN python3 /tmp/hello.py && \
    rm /tmp/hello.py

# Test Nuitka compilation
RUN echo 'print("Nuitka compiled successfully!")' > /tmp/test.py && \
    python3 -m nuitka --onefile --assume-yes-for-downloads /tmp/test.py && \
    ./test.bin && \
    rm /tmp/test.py test.bin

HEALTHCHECK --interval=30s --timeout=3s \
    CMD python3 --version && pip3 --version

CMD ["/bin/bash"]