# Stage 04: Clojure and Leiningen
ARG BASE_IMAGE=jon-babylon:03-kotlin
FROM ${BASE_IMAGE}

LABEL stage="04-clojure"
LABEL description="Clojure and Leiningen"

# Copy and run installation script
COPY tools/clojure/install/install.sh /tmp/install-clojure.sh
RUN chmod +x /tmp/install-clojure.sh && \
    /tmp/install-clojure.sh && \
    rm /tmp/install-clojure.sh

# Test Clojure
RUN echo '(println "Hello from Clojure!")' | clojure -

# Test Leiningen
RUN lein version

HEALTHCHECK --interval=30s --timeout=3s \
    CMD clojure --version && lein version

CMD ["/bin/bash"]