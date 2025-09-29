(ns jon-babylon.test
  (:require [clojure.string :as str]
            [malli.core :as m]
            [jsonista.core :as json])
  (:gen-class))

(defn test-malli []
  (println "Testing Malli schemas...")
  (let [schema [:map
                [:name :string]
                [:age [:int {:min 0 :max 150}]]]
        valid {:name "Alice" :age 30}
        invalid {:name "Bob" :age "thirty"}]
    (println "Valid data:" (m/validate schema valid))
    (println "Invalid data:" (not (m/validate schema invalid)))
    (println "✓ Malli validation works")))

(defn test-json []
  (println "Testing JSON serialization...")
  (let [data {:message "Hello from Leiningen project!"
              :numbers [1 2 3 4 5]}
        json-str (json/write-value-as-string data)
        parsed (json/read-value json-str)]
    (println "JSON:" json-str)
    (println "Parsed equals original:" (= data parsed))
    (println "✓ JSON serialization works")))

(defn -main []
  (println "=== Jon-Babylon Clojure Test (Leiningen) ===")
  (println "Clojure version:" (clojure-version))
  (test-malli)
  (test-json)
  (println "✓ All Leiningen tests passed!"))