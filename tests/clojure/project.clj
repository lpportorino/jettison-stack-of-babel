(defproject jon-babylon-clojure-test "0.1.0"
  :description "Clojure test suite for jon-babylon Docker image"
  :dependencies [[org.clojure/clojure "1.12.0"]
                 [metosin/jsonista "0.3.12"]
                 [ring/ring-core "1.13.0"]
                 [metosin/malli "0.19.1"]]
  :main jon-babylon.test
  :profiles {:dev {:dependencies [[org.clojure/test.check "1.1.1"]]
                   :global-vars {*warn-on-reflection* true}}
             :uberjar {:aot :all}})