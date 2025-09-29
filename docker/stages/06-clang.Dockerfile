# Stage 06: LLVM/Clang
ARG BASE_IMAGE=jon-babylon:05-python
FROM ${BASE_IMAGE}

LABEL stage="06-clang"
LABEL description="LLVM/Clang 21 compiler suite"

# Copy and run installation script
COPY tools/clang/install/install.sh /tmp/install-clang.sh
RUN chmod +x /tmp/install-clang.sh && \
    /tmp/install-clang.sh && \
    rm /tmp/install-clang.sh

# Test C compilation
RUN echo '#include <stdio.h>\nint main() { printf("Hello from C!\\n"); return 0; }' > /tmp/test.c && \
    clang /tmp/test.c -o /tmp/test && \
    /tmp/test && \
    rm /tmp/test.c /tmp/test

# Test C++ compilation
RUN echo '#include <iostream>\nint main() { std::cout << "Hello from C++!" << std::endl; return 0; }' > /tmp/test.cpp && \
    clang++ /tmp/test.cpp -o /tmp/test && \
    /tmp/test && \
    rm /tmp/test.cpp /tmp/test

HEALTHCHECK --interval=30s --timeout=3s \
    CMD clang --version && clang++ --version

CMD ["/bin/bash"]