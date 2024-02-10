(require '[clojure.string :as str])

(defn slugify [text]
  (-> text
      (clojure.string/lower-case)
      (clojure.string/replace " " "-")
      (clojure.string/replace #"[^a-z0-9\-_]" "")))

(defn remove-code-blocks [content]
  (let [code-block-regex #"(?s)```.*?```"]
    (clojure.string/replace content code-block-regex "")))

(defn process-line [line]
  (when-let [[_ hashes title] (re-find #"^(\#{2,}) (.+)" line)]
    (let [link (slugify title)]
      {:level (count hashes) :title title :link link})))

(defn create-index [content]
  (let [processed-content (remove-code-blocks content)
        processed-lines (->> processed-content
                             clojure.string/split-lines
                             (map process-line)
                             (remove nil?))]
    (->> processed-lines
         (map (fn [{:keys [level title link]}]
                (str (apply str (repeat (* 2 (- level 2)) " "))
                     "- ["
                     title
                     "](#"
                     link
                     ")")))
         (clojure.string/join "\n"))))


(let [content         (slurp "template.md")
      index           (create-index content)
      updated-content (clojure.string/replace content "{index}" index)]
  (spit "README.md" updated-content)
  (println "README.md successfully generated."))
