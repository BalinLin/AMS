;; Allows the model to use primitives from the extensions
extensions [ matrix ]

;; Declare variables and attributes
breed [exits exit]
breed [signals signal]
breed [ people person ]
directed-link-breed [ people-route person-route ]

exits-own [
  node-id
]

signals-own [
  node-id
  target
]

people-own [
  location
  node-id
  target
  step
  speed
  vision
  hearing
  age
  goTrought
  reaction-time
  speak-prob

  dest
  flood-index
  last-move
  ]

patches-own [
  exit?
  signal?
  inside?
  flood
  floods
]

;; Global variables
globals [ m patch-data cw
          goal-x goal-y
          signals-x
          signals-y
          exits-x
          exits-y

          population
          swaps

          knowledge-control

          ;; ===== Modified =====
          num_neighbors_0 ;; number of people around patch 34 45
          num_neighbors_1 ;; number of people around patch 49 19
          ;; ====================
        ]

;; Initialize the simulation.
to setup
  set patch-data [] ;; Initialize patch with empty array.
  ;; clear-all
  init-workspace ;; Set the infrastructure with boundary.
  create-workspace
  init-elements
end

;; Set the infrastructure with boundary.
to init-workspace
  set m matrix:from-row-list [
                              [ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]

                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]

                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]

                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]

                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]

                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]

                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 ]
                              [ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ]
                           ]
end

;; Set the patches according to their value.
to create-workspace
  clear-patches

  ask patches [
                 if ( pxcor < 70 and pycor < 70 ) ;; if inside the world.
                 [
                   ifelse ( matrix:get m pycor pxcor ) = 1     ;; Walls.
                   [ set pcolor blue ]
                   [ ifelse ( matrix:get m pycor pxcor ) = 2   ;; Secure areas.
                     [ set pcolor green ]
                     [ ifelse ( matrix:get m pycor pxcor ) = 3 ;; Signals.
                       [ set pcolor yellow ]
                       [ set pcolor black ]                    ;; Floor.
                     ]
                   ]
                 ]
               ]
end

;; When "Setup elements" button is clicked.
;; Store each object type and coordination according to their color.
to init-elements

  ;; Declare empty array for coordination of signal and exits.
  set signals-x ( list -1 )
  set signals-y ( list -1 )
  set exits-x ( list -1 )
  set exits-y ( list -1 )

  ;; Set icon
  set-default-shape exits "x"
  set-default-shape signals "triangle"
  set-default-shape people "person"
  set knowledge-control 0

  clear-plot

  ask patches [
    set exit? false
    set signal? false
    set inside? ( ( abs pycor < ( max-pycor ) ) and ( abs pycor > ( min-pycor ) ) and ( abs pxcor > ( min-pxcor ) ) and ( abs pxcor < ( max-pycor ) ) )

    ifelse ( pcolor = yellow ) ;; signals
    [
      set signal? true
      set signals-x lput pxcor signals-x
      set signals-y lput pycor signals-y
    ]
    [
      ifelse ( pcolor = green ) ;; exits
      [
        set exit? true
        set goal-x pxcor
        set goal-y pycor

        set exits-x lput pxcor exits-x
        set exits-y lput pycor exits-y
      ]
      [
        if ( pcolor = 102 ) ;; Defining obstacles inside, they are walls.
        [
          set inside? false
        ]
      ]
    ]
  ]

  ask patches [ set floods [] ]
  foreach sort get-signals-exits [ ?1 -> flood-fill ?1 ask patches [ set floods lput flood floods ] ]

  clear-turtles

  create-exits ( ( length exits-x ) - 1 ) ;; Give exits label number.
  [
    let i 1
    ask exits
    [
      set color black
      setxy ( item i exits-x ) ( item i exits-y )
      set node-id i
      set i (i + 1)
      set label node-id
    ]
  ]

  create-signals ( ( length signals-x ) - 1 ) ;; Give singals label number.
  [
    let i 1
    ask signals
    [
      set color black
      setxy ( item i signals-x ) ( item i signals-y )
      set node-id i
      set i (i + 1)
      set label node-id
    ]
  ]

  ;import-links
  ;import-exits

  ;; Randomly select number of "agents" with black color (nothing on the patch) to be people, with no repeats.
  ask n-of agents (patches with [pcolor = black])
  [
    sprout-people 1
    [
      set color white
      set dest nobody

      ;; Let number of "knowledge" people know where is the nearest exit.
      if( knowledge-control < knowledge ) [
        set dest min-one-of exits [distance myself]
        set knowledge-control knowledge-control + 1
      ]


      init-people
    ]
  ]
end

;; Initialize people's properties with some range of value.
to init-people
  let i 1
  ask people [
    set node-id i
    set i (i + 1)
    set age min-age + random max-age ;; age = min-age + [0, max-age)
    if ( age >= max-speak-prob ) [
      set age max-age
    ]

    ;; Younger people get lower speed value.
    ifelse( age >= 20 AND age <= 40 ) [
      set speed 0
    ]
    [
      ifelse( age >= 40 AND age <= 50 ) [
        set speed 1
      ]
      [
        set speed 2
      ]
    ]

    set step 0
    ;; set age random-float (85 - 15 + 1)
    set vision ( random-float ( 10 - 50 ) ) / age
    set hearing ( random-float ( 10 - 50 ) ) / age

    set reaction-time min-reaction-time + random max-reaction-time ;; reaction-time = min-reaction-time + [0, max-reaction-time)
    if ( reaction-time >= max-reaction-time ) [
      set reaction-time max-reaction-time
    ]

    set speak-prob min-speak-prob + random max-speak-prob ;; speak-prob = min-speak-prob + [0, max-speak-prob)
    if ( speak-prob >= max-speak-prob ) [
      set speak-prob max-speak-prob
    ]
  ]
end

;; Import links from txt file.
to import-links
  let directory ""
  let strFile "./inputs/links.txt"

  if( input-links != "" ) [
    set directory ".\\inputs\\"
    set strFile word directory input-links
    set strFile word strFile ".in"
  ]

  file-open strfile

  let x1 0
  let y1 0
  let x2 0
  let y2 0

  while [ not file-at-end? ]
  [
    let items read-from-string ( word "[" file-read-line "]" )

    ask get-sign-node ( item 0 items ) [ set x1 xcor set y1 ycor ]
    ask get-sign-node ( item 1 items ) [ set x2 xcor set y2 ycor ]

    ask get-sign-node ( item 0 items )
    [
      create-person-route-to get-sign-node( item 1 items )
      [
        set label ( abs ( x2 - x1 ) + abs ( y2 - y1 ) )
      ]
    ]
  ]
  file-close
end

;; Find a sign by id
to-report get-sign-node [ id ]
  report one-of signals with [ node-id = id ]
end

;; Import exits from txt file.
to import-exits
  let directory ""
  let strFile "./inputs/exits.txt"

  if( input-exits != "" ) [
    set directory ".\\inputs\\"
    set strFile word directory input-exits
    set strFile word strFile ".in"
  ]

  file-open strfile

  let x1 0
  let y1 0
  let x2 0
  let y2 0

  while [ not file-at-end? ]
  [
    let items read-from-string ( word "[" file-read-line "]" )

    ask get-sign-node ( item 0 items ) [ set x1 xcor set y1 ycor ]
    ask get-exit-node ( item 1 items ) [ set x2 xcor set y2 ycor ]

    ask get-sign-node ( item 0 items )
    [
      create-person-route-to get-exit-node( item 1 items )
      [
        set label ( abs ( x2 - x1 ) + abs ( y2 - y1 ) )
      ]
    ]
  ]
  file-close
end

;; Find a exit by id
to-report get-exit-node [ id ]
  report one-of exits with [ node-id = id ]
end

;; Import signals and exits from file.
to import-signals-exits
  let directory ".\\inputs\\"
  let strFile word directory fileSignsExits
  set strFile word strFile ".in"
  file-open strFile

  while [ not file-at-end? ]
  [
    let i1 file-read
    let i2 file-read
    let i3 file-read
    let i4 file-read

    ifelse ( i1 = "signal" )
    [
      ask signals with [ xcor = i3 AND ycor = i4 ]
      [
        set node-id i2
        set label node-id
      ]
    ]
    [
      ask exits with [ xcor = i3 AND ycor = i4 ]
      [
        set node-id i2
        set label node-id
      ]
    ]
  ]
  file-close

  clear-links
  ;import-links
  ;import-exits
end

;; Find a exit by id
to-report get-signal-exit-node [ id ]
  report one-of exits with [ node-id = id ]
end

;; When "go" button is clicked. Start the simulation.
to go
  reset-ticks ;; reset step of simulation.
  tick ;; Count step by one.

  ;; ===== Modified =====
  ;; Set the global variables to the number of neighbors around the entrance.
  ask patch 34 45[
    set num_neighbors_0 count turtles-on neighbors
  ]
  ask patch 49 16[
    set num_neighbors_1 count turtles-on neighbors
  ]
  ;; ====================

  move-people ;; Move all people
  set population count turtles with [inside? AND color != green AND color != red] ;; Calculate how many people don't know where's the nearest exit.
  plot population ;; Plot a line that y-axis is population and x-axis is tick.

  ;; If every people know where's the nearest exit.
  if ( ( not any? people ) OR ( all? people [ ( color = green OR color = red ) ] ) ) [
    ;;set-plot-x-range 0 ticks ;; Make x-axis to be zero.
    stop ;; Stop simulation
  ]
end

;; Define the color of people.
to move-people
  ask people [

    ;; Reports the single patch that is the given distance "ahead" of the person and with green color.
    ifelse( [pcolor] of patch-ahead 0 = green )
    [
      set color green
      if( not standOnExit? ) [
        exit-management
      ]
    ]
    [
      ;; With yellow color.
      ifelse ( [pcolor] of patch-ahead 0 = yellow )
      [
        let answers-points []
        let new-point 0

        ask signals-here [
          set new-point signal who
        ]

        ask [out-link-neighbors] of new-point [
          set answers-points fput self answers-points
        ]

        if not empty? answers-points [
          ifelse ( color = lime ) [
            set color blue
          ]
          [
            set color red
          ]
          let pos 0 ;; PENDIENTE!!!
          let new-location item pos answers-points
          face new-location
          fd 1

          set dest new-location
          set flood-index position 0 [floods] of new-location

          set location new-location
        ]
      ]
      [
        ;; Doesn't run into anyone with color.
        ;fd 1
        move-person
      ]
    ]
]
end

;; Define how the people move according to the color.
to move-person
  let new-dest nobody
  let self-speak speak-prob
  ask people-on neighbors [
    if( ( self-speak + speak-prob ) > speak-prob-threshold ) [ ;; If the sum of the near people's speak-prob is bigger than threshold.
      ifelse( ( dest != nobody ) AND ( member? dest exits  ) ) [ ;; If neighbors know the nearest exit.
        ;; Let the guy know the nearest exit and be green.
        set new-dest dest
        set color green
      ]
      [
        if( ( dest != nobody ) AND ( member? dest signals ) ) [
          ;; Let the guy know the nearest exit and be yellow.
          set new-dest dest
          set color yellow
        ]
      ]
    ]
  ]
  if ( new-dest != nobody ) [
    ;set dest new-dest
    set location new-dest
    set dest new-dest
    set flood-index position 0 [floods] of new-dest ;; First "0" in the list.
    ;;set color brown
  ]

   ifelse dest != nobody [
     ifelse inside?
     [
      ;; ===== Modified =====
      ;; If someone around the entrance of building, keep walking.
      ifelse ( pycor >= 45 and num_neighbors_0 != 0)[ ;; The building on top.
        ;set color red
        move-no-dest
      ]
      [
        ifelse ( pxcor >= 49 and pycor <= 19 and num_neighbors_1 != 0)[ ;; The building in the corner.
          ;set color red
          move-no-dest
        ]
        [
          let i flood-index
          ;;let n0 neighbors with [ (inside? or exit?) and (item i floods < item i [floods] of myself) ]
          let n0 neighbors with [ (inside?) and (item i floods < item i [floods] of myself) ]
          let n n0 with [ (not any? people-here) ]
          let frust (turtle-set [people-here with [frustrated?]] of n0)
          set frust frust with [ item flood-index [floods] of myself < item flood-index floods ]
          ifelse any? n [go-to one-of n] [if frustrated? and any? frust [swap one-of frust]]
        ]
      ]
      ;; ====================
     ]
     [
      ifelse patch-ahead 1 = nobody [
         die
       ]
       [
         ;;move-to patch-ahead 1
         ifelse ( step >= speed ) [
           set step 0
           move-to patch-ahead 1
         ]
         [
           set step ( step + 1 )
         ]
       ]
     ]
   ]
   [
     move-no-dest
   ]
end

;; Randomly move until meet any wall then change the direction.
to move-no-dest
  ifelse( reaction-time <= 0 ) ;; People can move only when reaction-time is equal or less than zero.
  [
    ;; ask people-on neighbors with [ inside? ] [
    ;; patch-ahead means distance along the person's current heading.
    ;; If there is a wall in front of it, just follow the neighbors's heading.
      if( ( ( [pcolor] of patch-ahead 0 = blue ) OR ( [pcolor] of patch-ahead 0 = 102 ) ) OR
             ( ( [pcolor] of patch-ahead 1 = blue ) OR ( [pcolor] of patch-ahead 1 = 102 ) ) ) [
      face one-of neighbors with[ inside? ]
      ]
      ;;fd 1
      ;;fd speed
      ifelse ( step >= speed ) [
        set step 0
        fd 1 ;; Move forward
      ]
      [
        set step ( step + 1 )
      ]
    ;;]
  ]
  [ reduce-reaction-time ]
end

;; Reduce reaction-time
to reduce-reaction-time
  set reaction-time reaction-time - 1
end

;; Kill people.
to exit-management
  die
end

;; Draw walls (building).
to patch-draw
  if ( cw != 1 )
  [
    init-workspace;
    create-workspace;
    set cw 1;
  ]
  if mouse-down?
    [
      ask patch mouse-xcor mouse-ycor [
        if( pcolor != blue )
          [ set pcolor 102 ]
      ]
    ]
end

;; Draw signals.
to signal-draw
  if ( cw != 1 )
  [
    init-workspace;
    create-workspace;
    set cw 1;
  ]
  if mouse-down?
    [
      ask patch mouse-xcor mouse-ycor [
        if( ( pcolor != blue )  )
          [ set pcolor yellow ]
      ]
    ]
end

;; Draw exits.
to exit-draw
  if ( cw != 1 )
  [
    init-workspace;
    create-workspace;
    set cw 1;
  ]
  if mouse-down?
    [
      ask patch mouse-xcor mouse-ycor [
        if( ( pcolor != blue )  )
          [ set pcolor green ]
      ]
    ]
end

;; Erase all kind of objects.
to patch-erase
  if mouse-down?
    [
      ask patch mouse-xcor mouse-ycor
      [
        if( pcolor != black )
          [ set pcolor black ]
      ]
    ]
end

;; Erase walls (building).
to erase-walls
 ask patches [
   if( pcolor = 102 )
   [ set pcolor black ]
 ]
end

;; Erase signals.
to erase-signals
 ask patches [
   if( pcolor = yellow )
   [ set pcolor black ]
 ]
end

;; Erase exits.
to erase-exits
 ask patches [
   if( pcolor = green )
   [ set pcolor black ]
 ]
end

;; Save a ".mdl" file.
to save-to-file
  let directory ".\\inputs\\"
  let strFile word directory fileInput
  set strFile word strFile ".mdl"
  file-open strFile
  ask patches [
    file-write pxcor file-write pycor file-write pcolor
  ]
  file-close
end

;; Save singals and exit to a file.
to save-signs-exits
  let directory ".\\inputs\\"
  let strFile word directory fileSignsExits
  set strFile word strFile ".in"
  file-open strFile

  ask signals [
    file-write"signal" file-write node-id file-write pxcor file-write pycor
    file-print""
  ]

  ask exits [
    file-write "exit" file-write node-id file-write pxcor file-write pycor
    file-print""
  ]

  file-close
end

;; Load patches from a file.
to load-patch-data

  ifelse ( file-exists? "File IO Patch Data.txt" )
  [
    set patch-data []

    file-open "File IO Patch Data.txt"

    ;; Read in all the data in the file
    while [ not file-at-end? ]
    [
      set patch-data sentence patch-data (list (list file-read file-read file-read))
    ]

    user-message "File loading complete!"

    ;; Done reading in patch information.  Close the file.
    file-close
  ]
  [ user-message "There is no File IO Patch Data.txt file in current directory!" ]
end

;; Load a ".mdl" file, which is how we get the infrastructure.
to load-own-patch-data
  let file user-new-file

  if ( file != false )
  [
    set patch-data []
    file-open file

    while [ not file-at-end? ]
      [ set patch-data sentence patch-data (list (list file-read file-read file-read)) ]

    user-message "File loading complete!"
    file-close
  ]
end

;; Show infrastructure.
to show-patch-data
  cp ct ;; clear-patches, clear-turtles
  ifelse ( is-list? patch-data )
    [ foreach patch-data [ ?1 -> ask patch first ?1 item 1 ?1 [ set pcolor last ?1 ] ] ]
    [ user-message "You need to load in patch data first!" ]
end

to-report inside report patches with [inside?] end
to-report get-exits  report patches with [exit?]   end
to-report get-signals  report patches with [signal?]   end
to-report get-signals-exits  report patches with [ signal? OR exit? ]   end
to-report frustrated? report (ticks - last-move) > 5 end
to go-to [a] face a move-to patch-ahead 1 set last-move ticks end
to swap [t] let p1 patch-here go-to t ask t [go-to p1] set swaps swaps + 1 end

to flood-fill [pset]
  set pset patch-set pset
  ask patches [set flood 3333]
  ask pset [set flood 0]
  while [count pset > 0]
  [ set pset patch-set [neighbors with [flood = 3333 and inside?]] of pset
    ask pset [set flood min [flood + distance myself] of neighbors] ]
end
@#$#@#$#@
GRAPHICS-WINDOW
222
12
720
511
-1
-1
7.0
1
10
1
1
1
0
0
0
1
0
69
0
69
1
1
1
ticks
30.0

BUTTON
17
10
80
43
Go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
103
10
166
43
Go...
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
751
96
860
129
PATCH DRAW
patch-draw
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
752
137
878
170
 ERASE ELEMENT
patch-erase
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
750
180
874
213
ERASE WALLS
erase-walls
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
748
254
983
314
fileInput
example1
1
0
String

BUTTON
1016
254
1122
287
SAVE DESIGN
save-to-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
753
12
925
45
Load New Infrastructure
load-own-patch-data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
939
12
1079
45
Show Infrastructure
show-patch-data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1090
12
1207
45
Setup elements
init-elements
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
43
184
76
agents
agents
1
1000
1000.0
1
1
NIL
HORIZONTAL

BUTTON
880
95
992
128
SIGN DRAW
signal-draw
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
883
179
1003
212
ERASE SIGNS
erase-signals
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1015
178
1119
211
ERASE EXITS
erase-exits
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1013
96
1109
129
EXIT DRAW
exit-draw
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
748
320
983
380
fileSignsExits
signs-exits-ex-0-1
1
0
String

BUTTON
1015
295
1189
328
SAVE SIGNS & EXITS
save-signs-exits
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1015
347
1190
380
IMPORT SIGNS & EXITS
import-signals-exits
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
3
392
203
542
population
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SWITCH
40
361
169
394
standOnExit?
standOnExit?
0
1
-1000

SLIDER
13
165
185
198
min-speak-prob
min-speak-prob
0
100
35.0
1
1
NIL
HORIZONTAL

SLIDER
13
231
185
264
min-reaction-time
min-reaction-time
0
50
0.0
1
1
NIL
HORIZONTAL

SLIDER
13
264
185
297
max-reaction-time
max-reaction-time
0
50
0.0
1
1
NIL
HORIZONTAL

SLIDER
13
198
185
231
max-speak-prob
max-speak-prob
0
100
50.0
1
1
NIL
HORIZONTAL

INPUTBOX
13
105
168
165
speak-prob-threshold
75.0
1
0
Number

SLIDER
13
297
185
330
min-age
min-age
20
80
20.0
1
1
NIL
HORIZONTAL

SLIDER
13
329
185
362
max-age
max-age
20
80
20.0
1
1
NIL
HORIZONTAL

INPUTBOX
748
385
983
445
input-links
links-ex-0-1
1
0
String

INPUTBOX
748
450
984
510
input-exits
exits-ex-0-1
1
0
String

BUTTON
1015
385
1127
418
IMPORT LINKS
import-links
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1015
423
1127
456
IMPORT EXITS
import-exits
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
886
139
1056
172
KILL DINAMIC ELEMENTS
clear-turtles
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
76
185
109
knowledge
knowledge
0
1000
248.0
1
1
NIL
HORIZONTAL

TEXTBOX
754
49
1208
67
____________________________________________________________________________
12
5.0
1

@#$#@#$#@
## WHAT IS IT?

This model is an attempt to model evacuation scenarios. 

## HOW TO USE IT

Select the parameters for the simulation (left buttons).
Load the infrastructure in Load New Infrastructure
Show Infraestructure with Show Infrastructure
Distribute random people in the scenario with Setup Elements
Use Go for single simulation step or Go|< for continuous simulation cicles.

## CREDITS AND REFERENCES

Antonio González Cuevas, Remo Suppi - 2015-2022 
CCBYSA - UAB - Computer Architecture & Operating System Department.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
