;; Copyright 2016, Chau Pham

globals
[
  gini-index-reserve
  lorenz-points
]

patches-own
[
  money-here
]

turtles-own
[
  age
  wealth
  life-expectancy
  spending
  vision
]

to setup
  clear-all
  setup-patches
  setup-turtles
  update-lorenz-and-gini
  reset-ticks
end

to setup-patches
  ask patches
    [ let x random-float 1.0
      if x <= (0.059 + 0.067 + 0.068 + 0.071 + 0.072 + 0.076 + 0.077 + 0.082 + 0.091 + 0.133 + 0.204) [set money-here 14383]
      if x <= (0.059 + 0.067 + 0.068 + 0.071 + 0.072 + 0.076 + 0.077 + 0.082 + 0.091 + 0.133) [set money-here 16254]
      if x <= (0.059 + 0.067 + 0.068 + 0.071 + 0.072 + 0.076 + 0.077 + 0.082 + 0.091) [set money-here 16481]
      if x <= (0.059 + 0.067 + 0.068 + 0.071 + 0.072 + 0.076 + 0.077 + 0.082) [set money-here 17096]
      if x <= (0.059 + 0.067 + 0.068 + 0.071 + 0.072 + 0.076 + 0.077) [set money-here 17121]
      if x <= (0.059 + 0.067 + 0.068 + 0.071 + 0.072 + 0.076) [set money-here 18388]
      if x <= (0.059 + 0.067 + 0.068 + 0.071 + 0.072) [set money-here 18517]
      if x <= (0.059 + 0.067 + 0.068 + 0.071) [set money-here 19217]
      if x <= (0.059 + 0.067 + 0.068) [set money-here 21640]
      if x <= (0.059 + 0.067) [set money-here 31891]
      if x <= 0.059 [set money-here 48906]
  ]
  repeat 10
    [diffuse money-here 0.25]
  ask patches
    [ recolor-patch ]
end

to recolor-patch
  set pcolor scale-color yellow money-here 12000 49000
end


to setup-turtles
  set-default-shape turtles "person"
  create-turtles num-people
    [ move-to one-of patches
      set size 2
      set-initial-turtle-vars
      set age random life-expectancy
      set wealth (wealth + money-here) ]
  recolor-turtles
end

to set-initial-turtle-vars
  set age 0
  face one-of neighbors4
  set life-expectancy ((wealth / 1000) + (random (life-expectancy-max - life-expectancy-min)))
  set wealth spending + random 50000
  set spending random 5000
  set vision 1 + random max-vision
end

to recolor-turtles
  let max-wealth max [wealth] of turtles
  ask turtles
    [ ifelse (wealth <= max-wealth / 3)
        [ set color red ]
        [ ifelse (wealth <= (max-wealth * 2 / 3))
            [ set color green ]
            [ set color blue ] ] ]
end


to go
  ask turtles
    [ turn-towards-money ]
  pay-money
  make-money
  ask turtles
    [ move-spend-age-die ]
  recolor-turtles

  if ticks mod 1 = 0
  [ask patches [grow-money] ]

  update-lorenz-and-gini
  tick
end

to turn-towards-money
  set heading 0
  let best-direction 0
  let best-amount money-ahead
  set heading 90
  if (money-ahead > best-amount)
    [ set best-direction 90
      set best-amount money-ahead ]
  set heading 180
  if (money-ahead > best-amount)
    [ set best-direction 180
      set best-amount money-ahead ]
  set heading 270
  if (money-ahead > best-amount)
    [ set best-direction 270
      set best-amount money-ahead ]
  set heading best-direction
end

to-report money-ahead
  let total 0
  let how-far 1
  repeat vision
    [ set total total + [money-here] of patch-ahead how-far
      set how-far how-far + 1 ]
  report total
end

to pay-money
  ask turtles
    [ if money-here <= 30000 [set wealth (wealth - (money-here * 0.111))]
      if money-here <= 20000 [set wealth (wealth - (money-here * 0.085))]
      if money-here <= 16000 [set wealth (wealth - (money-here * 0.076))]
      ]
  ask turtles
    [ if money-here <= 30000 [set money-here (money-here + (money-here * 0.111))]
      if money-here <= 20000 [set money-here (money-here + (money-here * 0.085))]
      if money-here <= 16000 [set money-here (money-here + (money-here * 0.076))]
      recolor-patch ]
end

to make-money
  ask turtles
    [ set wealth floor (wealth + (money-here / (count turtles-here))) ]
  ask turtles
    [ set money-here 0
      recolor-patch ]
end

to move-spend-age-die
  if wealth >= money-ahead
   [fd 1]

  if money-here <= 30000 [set wealth (wealth - (spending * 1.11))]
  if money-here <= 20000 [set wealth (wealth - (spending * 0.85))]
  if money-here <= 16000 [set wealth (wealth - (spending * 0.76))]

  set age (age + 1)

  if (wealth <= 0)
    [ set wealth spending ]

  if (age >= life-expectancy)
    [ set age 10
      set wealth (wealth * 0.75)]

end

to grow-money
  if (money-here <= 10000)
  [set money-here (money-here + 10000)
    recolor-patch]
end

;; This procedure for the Lorenz curve and Gini index was taken from the Wealth Distribution model by J. Li and U. Wilensky
;; this procedure recomputes the value of gini-index-reserve
;; and the points in lorenz-points for the Lorenz and Gini-Index plots
to update-lorenz-and-gini
  let sorted-wealths sort [wealth] of turtles
  let total-wealth sum sorted-wealths
  let wealth-sum-so-far 0
  let index 0
  set gini-index-reserve 0
  set lorenz-points []

  repeat num-people [
    set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
    set lorenz-points lput ((wealth-sum-so-far / total-wealth) * 100) lorenz-points
    set index (index + 1)
    set gini-index-reserve
    gini-index-reserve +
    (index / num-people) -
    (wealth-sum-so-far / total-wealth)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
287
10
705
449
25
25
8.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
201
10
277
43
setup
setup
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
201
48
277
81
go
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

SLIDER
21
44
189
77
max-vision
max-vision
1
15
5
1
1
NIL
HORIZONTAL

SLIDER
21
10
189
43
num-people
num-people
2
250
115
1
1
NIL
HORIZONTAL

SLIDER
21
114
189
147
life-expectancy-max
life-expectancy-max
1
100
75
1
1
NIL
HORIZONTAL

PLOT
20
334
272
514
Class Plot
Time
Turtles
0.0
50.0
0.0
250.0
true
true
"set-plot-y-range 0 num-people" ""
PENS
"low" 1.0 0 -2674135 true "" "plot count turtles with [color = red]"
"mid" 1.0 0 -10899396 true "" "plot count turtles with [color = green]"
"up" 1.0 0 -13345367 true "" "plot count turtles with [color = blue]"

SLIDER
21
80
189
113
life-expectancy-min
life-expectancy-min
1
100
1
1
1
NIL
HORIZONTAL

PLOT
20
151
271
331
Class Histogram
Classes
Turtles
0.0
3.0
0.0
250.0
false
false
"set-plot-y-range 0 num-people" ""
PENS
"default" 1.0 1 -2674135 true "" "plot-pen-reset\nset-plot-pen-color red\nplot count turtles with [color = red]\nset-plot-pen-color green\nplot count turtles with [color = green]\nset-plot-pen-color blue\nplot count turtles with [color = blue]"

PLOT
716
211
976
401
Lorenz Curve
Pop %
Wealth %
0.0
100.0
0.0
100.0
false
true
"" ""
PENS
"lorenz" 1.0 0 -2674135 true "" "plot-pen-reset\nset-plot-pen-interval 100 / num-people\nplot 0\nforeach lorenz-points plot"
"equal" 100.0 0 -16777216 true "plot 0\nplot 100" ""

PLOT
716
10
975
204
Gini-Index v. Time
Time
Gini
0.0
50.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" "plot (gini-index-reserve / num-people) / 0.5"

@#$#@#$#@
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
NetLogo 5.3
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
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

@#$#@#$#@
0
@#$#@#$#@
