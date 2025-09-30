(ns jettison.core
  (:require [clojure.string :as str]
            [clojure.data.json :as json]
            [clojure.core.async :as async :refer [go chan <! >! <!! timeout]]
            [clojure.tools.cli :refer [parse-opts]])
  (:gen-class))

;; Test basic Clojure features
(defn test-data-structures []
  (println "Testing Clojure data structures...")

  ;; Persistent vectors
  (let [v1 [1 2 3 4 5]
        v2 (conj v1 6)]
    (println "Original vector:" v1)
    (println "After conj:" v2))

  ;; Persistent maps
  (let [person {:name "Alice" :age 30 :city "Boston"}
        updated (assoc person :age 31 :hobby "reading")]
    (println "Original map:" person)
    (println "Updated map:" updated))

  ;; Sets
  (let [s1 #{1 2 3 4 5}
        s2 #{4 5 6 7 8}
        union (clojure.set/union s1 s2)
        intersection (clojure.set/intersection s1 s2)]
    (println "Set union:" union)
    (println "Set intersection:" intersection)))

;; Test functional programming
(defn test-functional []
  (println "\nTesting functional programming...")

  ;; Map, filter, reduce
  (let [numbers (range 1 11)
        evens (filter even? numbers)
        squares (map #(* % %) evens)
        sum (reduce + squares)]
    (println "Even numbers:" evens)
    (println "Squares of evens:" squares)
    (println "Sum of squares:" sum))

  ;; Composition
  (let [process (comp
                 (partial reduce +)
                 (partial map #(* % %))
                 (partial filter even?))]
    (println "Composed function result:" (process (range 1 11))))

  ;; Threading macros
  (let [result (->> (range 1 11)
                    (filter odd?)
                    (map #(* % 2))
                    (reduce +))]
    (println "Thread-last result:" result)))

;; Test macros
(defmacro unless [test then]
  `(if (not ~test) ~then))

(defn test-macros []
  (println "\nTesting macros...")
  (unless false (println "Unless macro works!"))
  (unless true (println "This shouldn't print")))

;; Test async/concurrency
(defn test-async []
  (println "\nTesting core.async...")
  (let [c (chan)]
    (go (>! c "Hello from async!"))
    (println "Async message:" (<!! c)))

  ;; Multiple channels
  (let [c1 (chan)
        c2 (chan)]
    (go (do (<! (timeout 100))
            (>! c1 "First")))
    (go (do (<! (timeout 200))
            (>! c2 "Second")))
    (println "First channel:" (<!! c1))
    (println "Second channel:" (<!! c2))))

;; Test protocols and records
(defprotocol Shape
  (area [this])
  (perimeter [this]))

(defrecord Rectangle [width height]
  Shape
  (area [this] (* width height))
  (perimeter [this] (* 2 (+ width height))))

(defrecord Circle [radius]
  Shape
  (area [this] (* Math/PI radius radius))
  (perimeter [this] (* 2 Math/PI radius)))

(defn test-protocols []
  (println "\nTesting protocols and records...")
  (let [rect (->Rectangle 10 5)
        circle (->Circle 7)]
    (println "Rectangle area:" (area rect))
    (println "Rectangle perimeter:" (perimeter rect))
    (println "Circle area:" (area circle))
    (println "Circle perimeter:" (perimeter circle))))

;; Test transducers
(defn test-transducers []
  (println "\nTesting transducers...")
  (let [xf (comp (filter even?)
                 (map #(* % %))
                 (take 5))
        result (transduce xf + (range 100))]
    (println "Transducer result:" result))

  (let [xf (comp (map inc)
                 (filter even?)
                 (map #(* % 2)))
        result (into [] xf (range 10))]
    (println "Transduced vector:" result)))

;; Test JSON handling
(defn test-json []
  (println "\nTesting JSON...")
  (let [data {:name "Jon-Babylon"
              :version "1.0.0"
              :languages ["Clojure" "Java" "Python" "Rust"]
              :features {:async true :macros true :lazy true}}
        json-str (json/write-str data)
        parsed (json/read-str json-str :key-fn keyword)]
    (println "Original:" data)
    (println "JSON:" json-str)
    (println "Parsed:" parsed)
    (println "Match:" (= data parsed))))

;; CLI argument handling
(def cli-options
  [["-v" "--verbose" "Verbose output"]
   ["-h" "--help" "Show help"]])

(defn -main [& args]
  (println "=== Jon-Babylon Clojure Test ===")
  (println "Clojure version:" (clojure-version))
  (println)

  (let [{:keys [options arguments errors summary]}
        (parse-opts args cli-options)]
    (when (:help options)
      (println "Usage: clojure -M:run [options]")
      (println summary)
      (System/exit 0))

    (when (:verbose options)
      (println "Running in verbose mode...")))

  ;; Run all tests
  (test-data-structures)
  (test-functional)
  (test-macros)
  (test-async)
  (test-protocols)
  (test-transducers)
  (test-json)

  (println "\n✓ All Clojure tests passed!"))