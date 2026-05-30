
## Versions

### v0.1.0 - Negamax
- Negamax algorithm with alpha-beta pruning
- Iterative deepening (for now only useful for uci)

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.386s         13.868us ± 1.778us     (12.804us ... 135.954us)     13.978us   16.31us    18.856us
Perft4 startpos        375      2.005s         5.347ms ± 126.765us    (5.162ms ... 6.389ms)        5.329ms    6.05ms     6.298ms
Perft6 startpos        1        3.243s         3.243s ± 0ns           (3.243s ... 3.243s)          3.243s     3.243s     3.243s
Perft2 kiwipete        36006    1.996s         55.442us ± 2.148us     (52.627us ... 177.251us)     55.931us   61.488us   63.543us
Perft4 kiwipete        18       1.943s         107.986ms ± 789.205us  (107.268ms ... 110.812ms)    108.05ms   110.812ms  110.812ms
Eval2 startpos         100000   1.806s         18.068us ± 9.707us     (16.521us ... 529.469us)     17.623us   22.809us   29.573us
Eval4 startpos         348      2.005s         5.764ms ± 118.271us    (5.642ms ... 6.57ms)         5.761ms    6.317ms    6.382ms
Eval2 kiwipete         100000   1.803s         18.037us ± 10.969us    (16.551us ... 544.108us)     17.612us   20.698us   26.718us
Eval4 kiwipete         330      2s             6.061ms ± 148.079us    (5.909ms ... 7.167ms)        6.054ms    6.781ms    7.066ms
```

### v0.1.1 - Move ordering
- MVV_LVA move ordering

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.565s         15.651us ± 3.36us      (13.473us ... 88.674us)      15.932us   26.895us   29.246us
Perft4 startpos        331      1.994s         6.027ms ± 761.297us    (5.482ms ... 10.216ms)       6.022ms    9.501ms    10.17ms
Perft6 startpos        1        3.609s         3.609s ± 0ns           (3.609s ... 3.609s)          3.609s     3.609s     3.609s
Perft2 kiwipete        32516    2.013s         61.914us ± 10.774us    (54.569us ... 324.468us)     64.143us   95.134us   99.837us
Perft4 kiwipete        16       1.963s         122.743ms ± 11.044ms   (113.596ms ... 155.854ms)    128.013ms  155.854ms  155.854ms
Eval2 startpos         70797    1.995s         28.185us ± 19.248us    (23.321us ... 624.121us)     28.025us   43.067us   48.899us
Eval4 startpos         302      1.984s         6.571ms ± 681.546us    (6.023ms ... 10.033ms)       6.608ms    9.448ms    9.671ms
Eval2 kiwipete         70930    1.989s         28.045us ± 19.156us    (23.288us ... 724.452us)     27.798us   43.315us   51.033us
Eval4 kiwipete         1884     2.01s          1.067ms ± 141.472us    (940.521us ... 2.056ms)      1.091ms    1.648ms    1.745ms
```

### v0.1.2 - Transpositions
- Implement transposition tables

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.327s         13.275us ± 1.109us     (12.487us ... 89.109us)      13.391us   15.407us   15.934us
Perft4 startpos        381      2s             5.249ms ± 140.431us    (5.123ms ... 6.393ms)        5.243ms    5.99ms     6.123ms
Perft6 startpos        1        4.461s         4.461s ± 0ns           (4.461s ... 4.461s)          4.461s     4.461s     4.461s
Perft2 kiwipete        37713    1.999s         53.014us ± 2.504us     (50.4us ... 302.574us)       53.306us   60.203us   61.88us
Perft4 kiwipete        19       1.996s         105.082ms ± 1.22ms     (104.395ms ... 108.879ms)    104.679ms  108.879ms  108.879ms
Eval2 startpos         100000   1.255s         12.557us ± 20.539us    (10.534us ... 1.108ms)       11.78us    14.711us   17.73us
Eval4 startpos         100000   1.411s         14.117us ± 18.936us    (12.022us ... 833.025us)     13.352us   17.205us   21.877us
Eval2 kiwipete         100000   1.254s         12.549us ± 20.728us    (10.582us ... 1.006ms)       11.799us   14.267us   17.165us
Eval4 kiwipete         100000   1.893s         18.935us ± 16.353us    (16.428us ... 730.198us)     18.184us   22.619us   30.267us
```

### v0.2.0 - Quiescence
- Quiescence search on captures
- Improved function for determining if a square is attacked

```
Perft2 startpos        100000   1.378s         13.78us ± 894ns        (12.901us ... 56.463us)      13.984us   15.808us   16.351us
Perft4 startpos        371      1.994s         5.376ms ± 112.334us    (5.292ms ... 6.122ms)        5.363ms    6.057ms    6.107ms
Perft6 startpos        1        3.245s         3.245s ± 0ns           (3.245s ... 3.245s)          3.245s     3.245s     3.245s
Perft2 kiwipete        36321    2.002s         55.145us ± 3.771us     (52.258us ... 249.801us)     55.2us     64.056us   66.022us
Perft4 kiwipete        18       1.931s         107.279ms ± 1.809ms    (106.325ms ... 112.267ms)    107.165ms  112.267ms  112.267ms
Eval2 startpos         100000   1.758s         17.58us ± 21.944us     (15.335us ... 1.141ms)       16.718us   20.381us   25.66us
Eval4 startpos         10185    1.986s         195.04us ± 11.195us    (186.138us ... 544.66us)     194.269us  230.471us  234.857us
Eval2 kiwipete         100000   1.742s         17.426us ± 20.521us    (15.347us ... 773.712us)     16.662us   19.754us   23.386us
Eval4 kiwipete         156      1.99s          12.76ms ± 356.573us    (12.5ms ... 15.431ms)        12.82ms    14.218ms   15.431ms
```

```
v0.2.0 vs v0.1.1 - 100 games 40/60
Elo difference: 7.5 +/- 27.4, LOS: 70.4 %, DrawRatio: 84.9 %
```

### v0.2.1 - TT Quiescence
- Quiescence and Transpositions

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.393s         13.93us ± 1.513us      (12.804us ... 82.146us)      14.101us   16.228us   17.447us
Perft4 startpos        369      2.003s         5.43ms ± 129.093us     (5.259ms ... 6.33ms)         5.422ms    6.13ms     6.295ms
Perft6 startpos        1        3.291s         3.291s ± 0ns           (3.291s ... 3.291s)          3.291s     3.291s     3.291s
Perft2 kiwipete        34351    2.001s         58.264us ± 2.967us     (53.883us ... 268.072us)     58.697us   66.398us   67.877us
Perft4 kiwipete        17       1.925s         113.263ms ± 890.739us  (112.838ms ... 116.651ms)    113.141ms  116.651ms  116.651ms
Eval2 startpos         100000   1.774s         17.744us ± 20.606us    (15.345us ... 763.789us)     16.957us   22.008us   26.957us
Eval4 startpos         86210    1.998s         23.18us ± 18.09us      (19.968us ... 614.272us)     22.322us   29.112us   37.528us
Eval2 kiwipete         100000   1.585s         15.858us ± 21.629us    (13.445us ... 849.824us)     15.036us   19.909us   26.487us
Eval4 kiwipete         26515    2.017s         76.106us ± 11.502us    (67.907us ... 335.921us)     76.01us    132.72us   188.779us
```

```
v0.2.1 vs v0.1.1 - 100 games 40/60
Elo difference: 52.5 +/- 38.7, LOS: 99.5 %, DrawRatio: 67.0 %
```

### v0.2.2 - Piece Square Values
- Add PeSTO tables and use them in the heuristic

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.568s         15.682us ± 1.092us     (14.96us ... 123.478us)      15.744us   18.034us   18.518us
Perft4 startpos        382      1.996s         5.227ms ± 136.068us    (5.144ms ... 6.115ms)        5.209ms    5.907ms    5.998ms
Perft6 startpos        1        3.16s          3.16s ± 0ns            (3.16s ... 3.16s)            3.16s      3.16s      3.16s
Perft2 kiwipete        30235    1.998s         66.096us ± 2.791us     (64.034us ... 248.637us)     66.183us   76.831us   79.455us
Perft4 kiwipete        18       1.957s         108.737ms ± 1.734ms    (107.707ms ... 113.493ms)    108.359ms  113.493ms  113.493ms
Eval2 startpos         100000   1.704s         17.043us ± 22.176us    (14.8us ... 992.864us)       16.245us   19.882us   24.209us
Eval4 startpos         7234     1.999s         276.404us ± 11.829us   (262.813us ... 665.51us)     277.538us  316.802us  324.291us
Eval2 kiwipete         100000   1.714s         17.145us ± 21.624us    (14.844us ... 1.569ms)       16.347us   19.929us   23.412us
Eval4 kiwipete         14119    1.9s           134.572us ± 10.599us   (122.167us ... 394.819us)    135.088us  197.55us   206.613us
```

```
v0.2.2 vs v0.2.1 - 100 games 40/60
Elo difference: 85.0 +/- 61.2, LOS: 99.7 %, DrawRatio: 24.0 %
```

### v0.2.3 - SIMD optimization for Piece Square Values
- Use `@Vector` to optimize the piece value heuristic

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.344s         13.446us ± 1.323us     (12.738us ... 155.723us)     13.507us   16.029us   17.099us
Perft4 startpos        386      1.999s         5.178ms ± 138.97us     (5.102ms ... 6.093ms)        5.168ms    5.968ms    6.065ms
Perft6 startpos        1        3.154s         3.154s ± 0ns           (3.154s ... 3.154s)          3.154s     3.154s     3.154s
Perft2 kiwipete        36610    1.997s         54.567us ± 3.104us     (52.62us ... 322.232us)      54.69us    63.854us   65.727us
Perft4 kiwipete        18       1.917s         106.501ms ± 2.141ms    (105.629ms ... 113.502ms)    105.885ms  113.502ms  113.502ms
Eval2 startpos         100000   1.841s         18.41us ± 20.746us     (16.383us ... 767.189us)     17.588us   21.634us   26.527us
Eval4 startpos         31103    1.996s         64.192us ± 11.417us    (60.521us ... 537.143us)     63.61us    81.516us   173.546us
Eval2 kiwipete         100000   1.77s          17.701us ± 21.628us    (15.63us ... 922.618us)      16.92us    20.034us   24.463us
Eval4 kiwipete         31319    1.914s         61.115us ± 12.7us      (56.005us ... 642.25us)      60.868us   101.107us  149.763us
```

```
v0.2.3 vs v0.2.2 - 100 games 40/60
Elo difference: 127.0 +/- 65.3, LOS: 100.0 %, DrawRatio: 19.0 %
```

### v0.2.4 - Hash move first
- Fix a bug where the hash move was not evaluated first

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.41s          14.102us ± 1.089us     (12.823us ... 111.869us)     14.331us   15.76us    16.429us
Perft4 startpos        362      1.997s         5.518ms ± 72.766us     (5.356ms ... 6.149ms)        5.527ms    5.921ms    6.034ms
Perft6 startpos        1        3.361s         3.361s ± 0ns           (3.361s ... 3.361s)          3.361s     3.361s     3.361s
Perft2 kiwipete        34201    2.001s         58.53us ± 2.427us      (54.255us ... 238.708us)     59.057us   64.756us   66.591us
Perft4 kiwipete        17       1.942s         114.235ms ± 658.97us   (113.681ms ... 116.303ms)    114.137ms  116.303ms  116.303ms
Eval2 startpos         100000   1.96s          19.605us ± 18.88us     (16.627us ... 632.529us)     18.903us   22.171us   25.995us
Eval4 startpos         28466    1.996s         70.144us ± 11.07us     (63.704us ... 270.771us)     69.303us   103.427us  185.571us
Eval6 startpos         1048     1.877s         1.791ms ± 33.226us     (1.691ms ... 2.205ms)        1.801ms    1.942ms    1.999ms
Eval8 startpos         1        1.008s         1.008s ± 0ns           (1.008s ... 1.008s)          1.008s     1.008s     1.008s
Eval2 kiwipete         100000   1.772s         17.723us ± 21.821us    (14.911us ... 904.338us)     16.912us   21.651us   27.754us
Eval4 kiwipete         32322    1.952s         60.397us ± 15.241us    (53.238us ... 610.314us)     60.088us   98.787us   194.518us
Eval6 kiwipete         21022    1.826s         86.865us ± 10.223us    (78.625us ... 326.229us)     85.992us   142.883us  180.881us
Eval8 kiwipete         1        1.4s           1.4s ± 0ns             (1.4s ... 1.4s)              1.4s       1.4s       1.4s
```

### v0.3.0 - PVS
- Implement principal variation search
- Retroactively added eval 6/8 benches to show difference in performace
  at higher depths

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.41s          14.106us ± 1.481us     (12.894us ... 111.284us)     14.211us   16.38us    18.245us
Perft4 startpos        360      1.998s         5.55ms ± 92.013us      (5.378ms ... 6.147ms)        5.566ms    6.031ms    6.056ms
Perft6 startpos        1        3.357s         3.357s ± 0ns           (3.357s ... 3.357s)          3.357s     3.357s     3.357s
Perft2 kiwipete        34231    2.007s         58.652us ± 5.581us     (54.441us ... 323.87us)      58.886us   65.81us    68.808us
Perft4 kiwipete        17       1.946s         114.523ms ± 980.08us   (113.873ms ... 118.069ms)    114.422ms  118.069ms  118.069ms
Eval2 startpos         94185    1.995s         21.189us ± 21.075us    (18.04us ... 770.482us)      20.282us   26.476us   34.685us
Eval4 startpos         11242    2s             177.989us ± 10.558us   (161.84us ... 665.529us)     178.473us  223.224us  227.317us
Eval6 startpos         523      1.946s         3.721ms ± 56.695us     (3.613ms ... 4.515ms)        3.736ms    3.963ms    4.067ms
Eval8 startpos         2        144.408ms      72.204ms ± 43.229ms    (41.636ms ... 102.771ms)     102.771ms  102.771ms  102.771ms
Eval2 kiwipete         98554    2.012s         20.416us ± 19.097us    (17.427us ... 675.431us)     19.609us   25.132us   33.07us
Eval4 kiwipete         34488    1.973s         57.231us ± 11.957us    (50.859us ... 341.59us)      56.348us   80.762us   165.046us
Eval6 kiwipete         23530    1.778s         75.582us ± 10.018us    (71.426us ... 306.004us)     75.085us   116.03us   175.12us
Eval8 kiwipete         1        830.231ms      830.231ms ± 0ns        (830.231ms ... 830.231ms)    830.231ms  830.231ms  830.231ms
```

```
v0.3.0 vs v0.2.4 - 100 games 40/60
Elo difference: 338.0 +/- 91.6, LOS: 100.0 %, DrawRatio: 13.0 %
```

### v0.3.1 - Check Extension
- Add check extension with max_extension = 4
- Use zig v0.14.0

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.355s         13.556us ± 5.352us     (12.725us ... 952.406us)     13.704us   15.725us   16.564us
Perft4 startpos        376      1.999s         5.318ms ± 191.893us    (5.189ms ... 7.407ms)        5.295ms    6.225ms    6.438ms
Perft6 startpos        1        3.226s         3.226s ± 0ns           (3.226s ... 3.226s)          3.226s     3.226s     3.226s
Perft2 kiwipete        36315    1.999s         55.064us ± 8.5us       (52.459us ... 927.308us)     54.974us   65.926us   67.869us
Perft4 kiwipete        18       1.937s         107.627ms ± 1.585ms    (106.568ms ... 112.067ms)    107.511ms  112.067ms  112.067ms
Eval2 startpos         82289    1.997s         24.27us ± 19.164us     (21.599us ... 886.474us)     23.283us   28.811us   34.906us
Eval4 startpos         10698    1.991s         186.197us ± 17.03us    (175.224us ... 1.054ms)      185.506us  231.382us  235.869us
Eval6 startpos         526      1.941s         3.691ms ± 156.889us    (3.547ms ... 6.555ms)        3.682ms    4.17ms     4.298ms
Eval8 startpos         2        152.114ms      76.057ms ± 41.7ms      (46.57ms ... 105.543ms)      105.543ms  105.543ms  105.543ms
Eval2 kiwipete         82257    1.936s         23.547us ± 20.097us    (20.809us ... 1.261ms)       22.544us   28.294us   35.766us
Eval4 kiwipete         33948    2.019s         59.478us ± 14.348us    (52.304us ... 957.746us)     58.865us   101.203us  150.676us
Eval6 kiwipete         21201    1.804s         85.097us ± 16.451us    (75.695us ... 1.129ms)       84.358us   145.574us  195.051us
Eval8 kiwipete         1        1.254s         1.254s ± 0ns           (1.254s ... 1.254s)          1.254s     1.254s     1.254s
```

```
v0.3.1 vs v0.3.0 - 100 games 40/60
Elo difference: 6.9 +/- 58.2, LOS: 59.3 %, DrawRatio: 28.0 %
```

### v0.4.0 - Null Move Pruning
- Add simple null move pruning

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.476s         14.764us ± 5.713us     (12.966us ... 941.739us)     15.081us   25.033us   28.536us
Perft4 startpos        330      1.993s         6.039ms ± 351.304us    (5.612ms ... 8.633ms)        6.152ms    7.194ms    7.505ms
Perft6 startpos        1        3.53s          3.53s ± 0ns            (3.53s ... 3.53s)            3.53s      3.53s      3.53s
Perft2 kiwipete        33481    2.012s         60.111us ± 13.283us    (53.389us ... 977.389us)     60.75us    79.283us   84.677us
Perft4 kiwipete        16       1.96s          122.549ms ± 1.614ms    (120.46ms ... 126.496ms)     123.421ms  126.496ms  126.496ms
Eval2 startpos         64324    2.015s         31.332us ± 29.54us     (25.032us ... 1.26ms)        29.638us   64.313us   160.136us
Eval4 startpos         6450     2.048s         317.537us ± 52.261us   (272.547us ... 1.305ms)      321.254us  560.75us   655.563us
Eval6 startpos         309      1.902s         6.156ms ± 436.474us    (5.48ms ... 8.385ms)         6.372ms    7.643ms    7.714ms
Eval8 startpos         4        477.878ms      119.469ms ± 739.927us  (118.738ms ... 120.485ms)    120.485ms  120.485ms  120.485ms
Eval2 kiwipete         64330    2.016s         31.346us ± 31.564us    (24.442us ... 1.107ms)       30.197us   51.63us    148.476us
Eval4 kiwipete         2074     1.932s         931.689us ± 123.878us  (842.096us ... 3.392ms)      942.956us  1.297ms    1.469ms
Eval6 kiwipete         238      1.694s         7.119ms ± 387.372us    (6.791ms ... 10.187ms)       7.203ms    8.271ms    9.024ms
Eval8 kiwipete         1        658.766ms      658.766ms ± 0ns        (658.766ms ... 658.766ms)    658.766ms  658.766ms  658.766ms
```

```
v0.4.0 vs v0.3.1 - 100 games 40/60
Elo difference: 52.5 +/- 58.3, LOS: 96.2 %, DrawRatio: 29.0 %
```

### v0.5.0 - King Safety
- Implement king safety evaluation

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.361s         13.617us ± 4.812us     (12.447us ... 893.766us)     13.704us   15.981us   17.384us
Perft4 startpos        369      1.985s         5.381ms ± 193.783us    (5.176ms ... 8.132ms)        5.376ms    6.166ms    6.516ms
Perft6 startpos        1        3.281s         3.281s ± 0ns           (3.281s ... 3.281s)          3.281s     3.281s     3.281s
Perft2 kiwipete        35414    2.002s         56.539us ± 8.605us     (51.787us ... 966.2us)       56.532us   66.427us   68.814us
Perft4 kiwipete        18       1.991s         110.64ms ± 1.189ms     (109.861ms ... 113.536ms)    110.434ms  113.536ms  113.536ms
Eval2 startpos         61581    1.995s         32.409us ± 18.826us    (28.33us ... 1.225ms)        31.319us   43.502us   88.754us
Eval4 startpos         5443     1.992s         366.018us ± 25.606us   (336.018us ... 1.362ms)      366.121us  420.784us  425.926us
Eval6 startpos         341      1.933s         5.67ms ± 196.189us     (5.486ms ... 8.382ms)        5.679ms    6.252ms    6.577ms
Eval8 startpos         2        375.11ms       187.555ms ± 34.616ms   (163.077ms ... 212.032ms)    212.032ms  212.032ms  212.032ms
Eval2 kiwipete         64792    1.997s         30.829us ± 18.085us    (27.134us ... 1.263ms)       29.745us   41.783us   54.372us
Eval4 kiwipete         2145     1.987s         926.747us ± 41.493us   (860.311us ... 1.923ms)      932.902us  1.019ms    1.046ms
Eval6 kiwipete         383      1.733s         4.526ms ± 142.065us    (4.302ms ... 6.44ms)         4.539ms    4.993ms    5.35ms
Eval8 kiwipete         1        849.29ms       849.29ms ± 0ns         (849.29ms ... 849.29ms)      849.29ms   849.29ms   849.29ms
```

```
v0.5.0 vs v0.4.0 - 100 games 40/60
Elo difference: 17.4 +/- 57.9, LOS: 72.4 %, DrawRatio: 29.0 %
```
### v0.5.1
- Fixed a bug in the conditions of the pvs re-search
- Increase benchmark times,
- - Note that there seems to be some problems in the
    reset of the TT or something else, times are getting too low

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.538s         15.387us ± 5.689us     (13.339us ... 928.709us)     15.526us   24.328us   27.224us
Perft4 startpos        832      4.933s         5.929ms ± 705.232us    (5.422ms ... 9.777ms)        5.875ms    8.597ms    8.98ms
Perft6 startpos        1        3.598s         3.598s ± 0ns           (3.598s ... 3.598s)          3.598s     3.598s     3.598s
Perft2 kiwipete        80575    4.961s         61.577us ± 12.865us    (55.519us ... 1.028ms)       62.011us   92.837us   96.526us
Perft4 kiwipete        41       4.92s          120.017ms ± 8.24ms     (114.327ms ... 146.019ms)    120.611ms  146.019ms  146.019ms
Eval2 startpos         100000   3.38s          33.805us ± 18.991us    (28.537us ... 1.255ms)       33.346us   50.647us   137.726us
Eval4 startpos         15312    4.981s         325.359us ± 46.569us   (289.923us ... 1.41ms)       330.152us  484.989us  504.393us
Eval6 startpos         988      4.861s         4.92ms ± 580.367us     (4.473ms ... 7.728ms)        4.91ms     7.205ms    7.361ms
Eval8 startpos         21       3.007s         143.227ms ± 15.838ms   (126.828ms ... 178.54ms)     149.794ms  178.54ms   178.54ms
Eval2 kiwipete         100000   3.194s         31.941us ± 19.352us    (26.892us ... 1.004ms)       31.446us   47.779us   67.833us
Eval4 kiwipete         15118    4.976s         329.186us ± 45.801us   (289.815us ... 1.471ms)      334.591us  492.338us  513.014us
Eval6 kiwipete         3362     4.661s         1.386ms ± 156.224us    (1.265ms ... 2.829ms)        1.39ms     2.052ms    2.128ms
Eval8 kiwipete         18       990.449ms      55.024ms ± 7.039ms     (50.561ms ... 76.12ms)       56.813ms   76.12ms    76.12ms
```

### v0.6.0 - LMR
- Implement late move reduction based on product of logarithms of depth
  and number of move
- Reduce depth by 1 if the main move is a capture and this one is not

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.381s         13.817us ± 1.803us     (12.49us ... 137.204us)      13.952us   17.136us   19.344us
Perft4 startpos        921      5.019s         5.45ms ± 557.966us     (5.104ms ... 20.1ms)         5.403ms    6.468ms    6.954ms
Perft6 startpos        1        3.3s           3.3s ± 0ns             (3.3s ... 3.3s)              3.3s       3.3s       3.3s
Perft2 kiwipete        86877    5.002s         57.584us ± 8.402us     (52.357us ... 973.097us)     57.603us   69.626us   72.424us
Perft4 kiwipete        46       4.983s         108.341ms ± 2.123ms    (106.972ms ... 115.191ms)    108.099ms  115.191ms  115.191ms
Eval2 startpos         100000   2.843s         28.432us ± 17.429us    (25.235us ... 991.986us)     27.474us   35.804us   43.857us
Eval4 startpos         26825    5.002s         186.481us ± 21.601us   (173us ... 1.263ms)          185.644us  242.231us  247.778us
Eval6 startpos         8419     5.004s         594.371us ± 43.808us   (552.178us ... 1.629ms)      595.061us  727.718us  774.507us
Eval8 startpos         608      4.912s         8.079ms ± 425.703us    (7.719ms ... 11.126ms)       7.973ms    9.851ms    9.896ms
Eval2 kiwipete         100000   2.764s         27.644us ± 18.514us    (24.333us ... 1.255ms)       26.557us   34.925us   43.551us
Eval4 kiwipete         14649    4.995s         341.004us ± 28.431us   (311.256us ... 1.347ms)      342.047us  412.801us  426.881us
Eval6 kiwipete         10199    4.941s         484.531us ± 36.277us   (444.733us ... 1.562ms)      486.607us  581.849us  603.759us
Eval8 kiwipete         672      4.52s          6.726ms ± 312.808us    (6.428ms ... 9.985ms)        6.672ms    8.103ms    8.165ms
```

```
v0.6.0 vs v0.5.1 - 100 games 10/10
Elo difference: 49.0 +/- 58.6, LOS: 95.1 %, DrawRatio: 28.0 %
```
### v0.6.1
- Fix king safety evalution using the wrong tables

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.463s         14.631us ± 4.872us     (12.183us ... 234.694us)     15.025us   27.628us   41.403us
Perft4 startpos        899      5.441s         6.053ms ± 744.737us    (4.965ms ... 9.699ms)        6.462ms    8.46ms     9.041ms
Perft6 startpos        1        3.484s         3.484s ± 0ns           (3.484s ... 3.484s)          3.484s     3.484s     3.484s
Perft2 kiwipete        83185    4.971s         59.767us ± 15.401us    (50.646us ... 1.027ms)       62.095us   80.488us   93.925us
Perft4 kiwipete        42       4.93s          117.4ms ± 3.46ms       (113.698ms ... 126.388ms)    119.442ms  126.388ms  126.388ms
Eval2 startpos         100000   2.743s         27.432us ± 34.168us    (20.185us ... 1.229ms)       26.623us   45.651us   123.306us
Eval4 startpos         28798    4.949s         171.86us ± 36.947us    (142.25us ... 1.308ms)       177.517us  327.256us  403.865us
Eval6 startpos         1296     4.703s         3.629ms ± 379.5us      (3.078ms ... 7.318ms)        3.851ms    4.743ms    4.958ms
Eval8 startpos         26       670.371ms      25.783ms ± 14.069ms    (16.858ms ... 79.89ms)       22.23ms    79.89ms    79.89ms
Eval2 kiwipete         100000   2.682s         26.824us ± 35.59us     (19.326us ... 1.63ms)        25.535us   51.366us   117.379us
Eval4 kiwipete         11425    4.856s         425.035us ± 74.271us   (351.599us ... 2.023ms)      442.965us  762.753us  875.195us
Eval6 kiwipete         2641     4.861s         1.84ms ± 200.686us     (1.603ms ... 4.447ms)        1.921ms    2.491ms    2.613ms
Eval8 kiwipete         285      2.217s         7.781ms ± 633.464us    (6.583ms ... 10.771ms)       8.139ms    9.306ms    9.479ms
```

```
v0.6.1 vs v0.5.0 - 100 games 10/10
Elo difference: 13.9 +/- 52.2, LOS: 70.0 %, DrawRatio: 42.0 %
```

### v0.6.2
- Improve move generation and heurisitc with data-oriented design

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.455s         14.556us ± 4.77us      (12.957us ... 879.965us)     14.552us   21.355us   25.836us
Perft4 startpos        882      4.991s         5.659ms ± 271.042us    (5.348ms ... 8.685ms)        5.658ms    6.631ms    7.795ms
Perft6 startpos        1        3.417s         3.417s ± 0ns           (3.417s ... 3.417s)          3.417s     3.417s     3.417s
Perft2 kiwipete        88062    4.992s         56.695us ± 9.871us     (50.361us ... 980.214us)     56.646us   67.712us   70.645us
Perft4 kiwipete        44       4.891s         111.172ms ± 1.741ms    (109.697ms ... 117.932ms)    111.952ms  117.932ms  117.932ms
Eval2 startpos         100000   3.361s         33.614us ± 12.004us    (29.467us ... 1.075ms)       33.448us   49.98us    92.488us
Eval4 startpos         21489    5.029s         234.052us ± 27.721us   (211.219us ... 1.148ms)      233.042us  291.004us  309.387us
Eval6 startpos         6341     4.958s         781.906us ± 52.609us   (718.94us ... 1.842ms)       778.025us  947.98us   1.042ms
Eval8 startpos         485      4.988s         10.285ms ± 736.689us   (9.648ms ... 14.361ms)       10.2ms     13.181ms   13.853ms
Eval2 kiwipete         100000   3.304s         33.048us ± 9.732us     (28.345us ... 986.635us)     32.649us   49.475us   91.755us
Eval4 kiwipete         10571    4.965s         469.702us ± 38.323us   (423.056us ... 1.452ms)      470.255us  572.274us  624.702us
Eval6 kiwipete         4279     4.927s         1.151ms ± 56.368us     (1.079ms ... 2.165ms)        1.153ms    1.35ms     1.395ms
Eval8 kiwipete         606      4.283s         7.068ms ± 305.79us     (6.749ms ... 10.425ms)       7.085ms    8.114ms    8.474ms
```

### v0.6.3
- Better design for pieces bitboard enumeration

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.243s         12.439us ± 4.97us      (11.618us ... 924.963us)     12.588us   15.404us   16.055us
Perft4 startpos        988      5.053s         5.115ms ± 383.298us    (4.781ms ... 8.539ms)        5.054ms    7.055ms    7.118ms
Perft6 startpos        1        3.114s         3.114s ± 0ns           (3.114s ... 3.114s)          3.114s     3.114s     3.114s
Perft2 kiwipete        94714    5.014s         52.944us ± 7.649us     (47.23us ... 990.94us)       52.798us   62.397us   64.599us
Perft4 kiwipete        47       4.93s          104.902ms ± 3.188ms    (102.552ms ... 119.284ms)    105.634ms  119.284ms  119.284ms
Eval2 startpos         100000   2.741s         27.417us ± 8.515us     (25.044us ... 1.044ms)       27.084us   34.862us   63.304us
Eval4 startpos         27334    5.022s         183.753us ± 19.687us   (170.63us ... 1.165ms)       183.045us  226.412us  234.151us
Eval6 startpos         8244     5.042s         611.688us ± 55.106us   (563.411us ... 1.592ms)      608.148us  801.972us  962.805us
Eval8 startpos         591      4.845s         8.198ms ± 919.238us    (7.399ms ... 11.793ms)       8.712ms    11.041ms   11.514ms
Eval2 kiwipete         100000   2.713s         27.132us ± 11.331us    (24.047us ... 929.269us)     26.507us   37.374us   80.141us
Eval4 kiwipete         14225    4.948s         347.885us ± 27.701us   (319.325us ... 1.36ms)       350.123us  408.475us  422.861us
Eval6 kiwipete         5443     4.961s         911.618us ± 61.278us   (849.999us ... 2.136ms)      909.849us  1.099ms    1.232ms
Eval8 kiwipete         807      4.4s           5.453ms ± 273.1us      (5.161ms ... 8.657ms)        5.406ms    6.542ms    6.654ms
```

### v0.6.4
- Upgrade to zig 0.15.1

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.353s         13.538us ± 6.728us    (11.993us ... 1.214ms)       13.584us   21.57us    24.33us
Perft4 startpos        992      5.001s         5.041ms ± 619.783us   (4.715ms ... 10.538ms)       4.998ms    7.601ms    7.844ms
Perft6 startpos        1        3.06s          3.06s ± 0ns           (3.06s ... 3.06s)            3.06s      3.06s      3.06s
Perft2 kiwipete        93281    5.005s         53.665us ± 13.74us    (49.262us ... 1.321ms)       54.045us   82.184us   84.997us
Perft4 kiwipete        48       4.997s         104.104ms ± 6.774ms   (98.701ms ... 126.766ms)     106.449ms  126.766ms  126.766ms
Eval2 startpos         100000   2.779s         27.798us ± 10.22us    (24.473us ... 1.15ms)        27.886us   43.426us   83.969us
Eval4 startpos         30822    5.002s         162.301us ± 28.875us  (147.08us ... 1.392ms)       163.741us  244.509us  258.296us
Eval6 startpos         9724     4.962s         510.333us ± 68.352us  (462.984us ... 1.908ms)      513.854us  777.875us  817.687us
Eval8 startpos         747      4.925s         6.593ms ± 699.854us   (6.056ms ... 10.01ms)        6.523ms    9.519ms    9.765ms
Eval2 kiwipete         100000   2.776s         27.764us ± 10.769us   (24.227us ... 1.165ms)       27.789us   43.345us   82.568us
Eval4 kiwipete         15846    4.988s         314.807us ± 48.741us  (279.33us ... 1.703ms)       318.919us  474.066us  496.898us
Eval6 kiwipete         5925     4.95s          835.529us ± 111.702us (753.839us ... 2.363ms)      839.979us  1.269ms    1.338ms
Eval8 kiwipete         841      4.429s         5.267ms ± 565.305us   (4.866ms ... 9.825ms)        5.251ms    7.742ms    7.908ms
```

### v0.6.5
- Remove variables from board
- Use precomputed zobrist values

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.202s         12.021us ± 5.321us    (10.738us ... 948.03us)      12.123us   18.932us   21.323us
Perft4 startpos        1005     4.991s         4.966ms ± 595.496us   (4.637ms ... 9.164ms)        4.969ms    7.563ms    8.388ms
Perft6 startpos        1        2.989s         2.989s ± 0ns          (2.989s ... 2.989s)          2.989s     2.989s     2.989s
Perft2 kiwipete        97465    4.976s         51.061us ± 10.253us   (46.992us ... 1.001ms)       51.416us   78.408us   81.678us
Perft4 kiwipete        49       4.973s         101.504ms ± 7.471ms   (96.733ms ... 125.211ms)     101.848ms  125.211ms  125.211ms
Eval2 startpos         100000   2.759s         27.596us ± 10.353us   (23.78us ... 1.216ms)        27.799us   44.047us   86.728us
Eval4 startpos         30771    4.992s         162.262us ± 28.037us  (145.832us ... 1.197ms)      163.94us   247.223us  264.076us
Eval6 startpos         9761     4.979s         510.112us ± 70.849us  (458.187us ... 1.667ms)      514.06us   774.542us  831.567us
Eval8 startpos         748      4.946s         6.612ms ± 786.274us   (6.036ms ... 11.127ms)       6.576ms    9.825ms    10.632ms
Eval2 kiwipete         100000   2.733s         27.331us ± 11.605us   (23.368us ... 1.073ms)       27.558us   42.744us   86.541us
Eval4 kiwipete         16185    5.166s         319.217us ± 61.4us    (271.244us ... 1.399ms)      322.523us  523.746us  667.974us
Eval6 kiwipete         5767     4.838s         839.067us ± 110.443us (750.695us ... 2.632ms)      844.987us  1.275ms    1.362ms
Eval8 kiwipete         862      4.448s         5.16ms ± 583.575us    (4.711ms ... 8.984ms)        5.136ms    7.443ms    7.486ms
```

```
v0.6.5 vs v0.6.1 - 100 games 10/10
Elo difference: 24.4 +/- 49.9, LOS: 83.2 %, DrawRatio: 47.0 %
```

### v0.6.6
- Fix error in search loop

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.153s         11.538us ± 5.741us    (10.167us ... 904.286us)     11.603us   22.235us   26.497us
Perft4 startpos        1048     5s             4.771ms ± 400.86us    (4.414ms ... 9.916ms)        4.881ms    5.89ms     6.07ms
Perft6 startpos        1        2.934s         2.934s ± 0ns          (2.934s ... 2.934s)          2.934s     2.934s     2.934s
Perft2 kiwipete        100000   4.901s         49.016us ± 11.87us    (44.676us ... 982.054us)     49.284us   63.321us   70.43us
Perft4 kiwipete        51       4.98s          97.658ms ± 1.782ms    (95.524ms ... 103.801ms)     98.098ms   103.801ms  103.801ms
Eval6 startpos         96581    5.042s         52.212us ± 14.826us   (43.874us ... 1.078ms)       52.127us   97.295us   153.192us
Eval8 startpos         2653     5.036s         1.898ms ± 199.868us   (1.69ms ... 3.874ms)         1.951ms    2.67ms     2.791ms
Eval10 startpos        115      4.949s         43.036ms ± 3.927ms    (36.695ms ... 55.615ms)      46.363ms   51.206ms   55.615ms
Eval12 startpos        5        2.284s         456.986ms ± 12.86ms   (441.471ms ... 475.113ms)    463.831ms  475.113ms  475.113ms
Eval6 kiwipete         72988    5.213s         71.433us ± 21.862us   (56.961us ... 1.011ms)       72.768us   155.18us   198.504us
Eval8 kiwipete         4271     4.622s         1.082ms ± 96.368us    (939.964us ... 2.125ms)      1.106ms    1.42ms     1.535ms
Eval10 startpos        198      3.341s         16.875ms ± 780.079us  (15.263ms ... 20.486ms)      17.089ms   20.18ms    20.486ms
Eval12 startpos        1        2.288s         2.288s ± 0ns          (2.288s ... 2.288s)          2.288s     2.288s     2.288s
```

```
v0.6.6 vs v0.6.5 - 100 games 10/10
Elo difference: 74.1 +/- 50.0, LOS: 99.8 %, DrawRatio: 47.0 %
```

### v0.7.0
- Killer Heuristic

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.141s         11.41us ± 2.796us     (10.398us ... 152.006us)     11.439us   17.547us   22.585us
Perft4 startpos        1035     4.951s         4.783ms ± 277.798us   (4.531ms ... 8.339ms)        4.795ms    5.7ms      5.912ms
Perft6 startpos        1        2.971s         2.971s ± 0ns          (2.971s ... 2.971s)          2.971s     2.971s     2.971s
Perft2 kiwipete        95409    4.833s         50.662us ± 12.525us   (45.689us ... 960.561us)     51.701us   67.059us   76.529us
Perft4 kiwipete        49       4.911s         100.231ms ± 3.121ms   (97.629ms ... 115.382ms)     100.096ms  115.382ms  115.382ms
Eval6 startpos         89463    5.085s         56.842us ± 18.198us   (47.542us ... 1.138ms)       57.384us   124.166us  178.433us
Eval8 startpos         2372     5.02s          2.116ms ± 311.341us   (1.771ms ... 5.681ms)        2.197ms    3.18ms     3.905ms
Eval10 startpos        103      4.726s         45.891ms ± 2.897ms    (42.507ms ... 53.894ms)      47.969ms   53.719ms   53.894ms
Eval12 startpos        6        2.876s         479.373ms ± 9.194ms   (466.576ms ... 490.39ms)     484.378ms  490.39ms   490.39ms
Eval6 kiwipete         66965    4.91s          73.323us ± 17.96us    (60.402us ... 1.09ms)        73.912us   143.601us  177.474us
Eval8 kiwipete         3777     4.657s         1.233ms ± 99.83us     (1.088ms ... 2.475ms)        1.247ms    1.634ms    1.735ms
Eval10 startpos        170      3.017s         17.751ms ± 705.725us  (16.708ms ... 21.084ms)      17.979ms   20.778ms   21.084ms
Eval12 startpos        1        2.947s         2.947s ± 0ns          (2.947s ... 2.947s)          2.947s     2.947s     2.947s
```

```
v0.7.0 vs v0.6.6 - 100 games 10/10
Elo difference: 42.6 +/- 48.5, LOS: 95.7 %, DrawRatio: 58.5 %
```

### v0.7.1
- Fix late move reduction

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.253s         12.533us ± 1.526us    (11.663us ... 94.454us)      12.638us   17.591us   19.751us
Perft4 startpos        947      4.998s         5.278ms ± 210.63us    (5.072ms ... 8.03ms)         5.276ms    6.07ms     6.989ms
Perft6 startpos        1        3.138s         3.138s ± 0ns          (3.138s ... 3.138s)          3.138s     3.138s     3.138s
Perft2 kiwipete        94145    5.018s         53.305us ± 7.133us    (50.239us ... 908.099us)     53.663us   60.335us   63.619us
Perft4 kiwipete        47       4.984s         106.048ms ± 1.3ms     (104.419ms ... 109.767ms)    106.665ms  109.767ms  109.767ms
Eval6 startpos         100000   3.451s         34.515us ± 10.279us   (30.523us ... 1.016ms)       34.431us   48.193us   90.01us
Eval8 startpos         51561    4.984s         96.666us ± 12.715us   (91.564us ... 1.039ms)       96.792us   126.526us  140.663us
Eval10 startpos        7066     4.978s         704.564us ± 34.118us  (665.028us ... 1.748ms)      710.517us  734.087us  744.312us
Eval12 startpos        701      4.905s         6.997ms ± 236.881us   (6.818ms ... 9.677ms)        7.01ms     7.94ms     8.513ms
Eval6 kiwipete         67327    5.012s         74.445us ± 11.986us   (68.223us ... 994.947us)     73.959us   107.928us  127.861us
Eval8 kiwipete         15803    4.9s           310.095us ± 18.522us  (290.928us ... 1.235ms)      314.057us  331.99us   337.735us
Eval10 startpos        1695     4.664s         2.751ms ± 70.607us    (2.673ms ... 4.507ms)        2.757ms    2.844ms    2.863ms
Eval12 startpos        220      3.398s         15.448ms ± 346.365us  (15.216ms ... 17.873ms)      15.414ms   16.81ms    17.202ms
```

Note: changed bookdepth to 2.

```
v0.7.1 vs v0.7.0 - 1000 games 40/1
Elo difference: 20.9 +/- 16.4, LOS: 99.4 %, DrawRatio: 42.0 %

v0.7.1 vs v0.7.0 - 100 games 10/10
Elo difference: 3.6 +/- 47.8, LOS: 55.9 %, DrawRatio: 53.1 %
```

### v0.7.2
- Increase null move reduction to 4

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.61s          16.101us ± 5.413us    (15.174us ... 909.295us)     16.161us   18.038us   18.603us
Perft4 startpos        1021     4.959s         4.857ms ± 137.772us   (4.673ms ... 7.616ms)        4.86ms     5.133ms    5.388ms
Perft6 startpos        1        2.921s         2.921s ± 0ns          (2.921s ... 2.921s)          2.921s     2.921s     2.921s
Perft2 kiwipete        68397    4.977s         72.767us ± 9.329us    (70.174us ... 960.086us)     72.682us   80.936us   83.103us
Perft4 kiwipete        50       4.947s         98.953ms ± 1.214ms    (98.168ms ... 106.264ms)     99.04ms    106.264ms  106.264ms
Eval6 startpos         100000   3.526s         35.266us ± 10.132us   (31.586us ... 1.007ms)       35.115us   41.875us   86.891us
Eval8 startpos         60270    4.992s         82.829us ± 13.492us   (76.551us ... 1.122ms)       82.931us   110.787us  127.998us
Eval10 startpos        2700     4.971s         1.841ms ± 128.719us   (1.759ms ... 5.606ms)        1.845ms    1.942ms    1.994ms
Eval12 startpos        247      4.789s         19.391ms ± 945.64us   (18.966ms ... 24.359ms)      19.114ms   23.04ms    24.058ms
Eval6 kiwipete         70703    4.965s         70.235us ± 12.807us   (64.374us ... 1.191ms)       70.11us    100.479us  123.072us
Eval8 kiwipete         30704    4.901s         159.638us ± 19.079us  (145.743us ... 1.27ms)       160.285us  183.064us  187.839us
Eval10 startpos        2451     4.705s         1.919ms ± 67.396us    (1.838ms ... 3.712ms)        1.924ms    2.048ms    2.126ms
Eval12 startpos        138      2.278s         16.508ms ± 537.392us  (16.201ms ... 19.181ms)      16.396ms   18.883ms   19.181ms
```

```
v0.7.2 vs v0.7.1 - 1000 games 40/1
Elo difference: 14.9 +/- 15.4, LOS: 97.1 %, DrawRatio: 48.9 %
```

### v0.7.3
- Increase extension limit to 24
- Improve move generation

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.116s         11.165us ± 2.283us    (10.35us ... 560.186us)      11.282us   12.735us   13.595us
Perft4 startpos        1066     5.013s         4.703ms ± 138.359us   (4.554ms ... 7.462ms)        4.704ms    5.112ms    5.214ms
Perft6 startpos        1        2.871s         2.871s ± 0ns          (2.871s ... 2.871s)          2.871s     2.871s     2.871s
Perft2 kiwipete        100000   4.887s         48.877us ± 9.525us    (46.204us ... 950.08us)      49.095us   53.477us   54.876us
Perft4 kiwipete        51       4.959s         97.24ms ± 782.762us   (96.554ms ... 99.439ms)      97.366ms   99.439ms   99.439ms
Eval6 startpos         100000   3.385s         33.85us ± 9.537us     (30.71us ... 1.002ms)        33.498us   42.614us   87.66us
Eval8 startpos         59127    5.108s         86.401us ± 10.278us   (81.665us ... 976.892us)     86.486us   114.386us  132.376us
Eval10 startpos        2537     4.951s         1.951ms ± 68.158us    (1.892ms ... 4.16ms)         1.967ms    2.04ms     2.05ms
Eval12 startpos        232      4.8s           20.69ms ± 809.608us   (20.073ms ... 23.757ms)      20.51ms    23.464ms   23.471ms
Eval6 kiwipete         68824    4.984s         72.427us ± 11.36us    (67.793us ... 995.899us)     72.133us   102.238us  120.418us
Eval8 kiwipete         29338    4.903s         167.146us ± 15.696us  (156.631us ... 1.073ms)      168.395us  191.522us  194.91us
Eval10 startpos        2302     4.7s           2.041ms ± 76.511us    (1.971ms ... 3.871ms)        2.06ms     2.106ms    2.139ms
Eval12 startpos        122      2.163s         17.733ms ± 654.677us  (17.237ms ... 20.694ms)      17.609ms   20.011ms   20.694ms
```

```
v0.7.3 vs v0.7.2 - 1000 games 40/1
Elo difference: 2.1 +/- 15.6, LOS: 60.3 %, DrawRatio: 47.6 %
```

### v0.7.4
- Add mobility evaluation

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.164s         11.642us ± 4.945us    (10.46us ... 888.097us)      11.617us   15.619us   20.49us
Perft4 startpos        1025     5.005s         4.883ms ± 206.687us   (4.664ms ... 7.538ms)        4.861ms    6.133ms    6.389ms
Perft6 startpos        1        3.008s         3.008s ± 0ns          (3.008s ... 3.008s)          3.008s     3.008s     3.008s
Perft2 kiwipete        99399    5.009s         50.398us ± 6.778us    (47.952us ... 931.999us)     50.716us   56.474us   61.585us
Perft4 kiwipete        49       4.969s         101.425ms ± 1.01ms    (100.414ms ... 104.759ms)    101.974ms  104.759ms  104.759ms
Eval6 startpos         100000   3.434s         34.341us ± 9.699us    (29.563us ... 915.515us)     34.625us   43.921us   86.496us
Eval8 startpos         58014    4.988s         85.985us ± 11.947us   (81.451us ... 1.034ms)       86.211us   114.241us  131.974us
Eval10 startpos        2497     4.973s         1.991ms ± 64.366us    (1.925ms ... 3.767ms)        1.999ms    2.106ms    2.137ms
Eval12 startpos        228      4.795s         21.033ms ± 820.53us   (20.212ms ... 24.517ms)      20.823ms   24.284ms   24.292ms
Eval6 kiwipete         67588    4.882s         72.243us ± 11.927us   (61.943us ... 1.027ms)       73.123us   102.535us  116.739us
Eval8 kiwipete         31118    4.914s         157.921us ± 15.666us  (143.943us ... 1.075ms)      158.94us   180.564us  184.323us
Eval10 startpos        2476     4.72s          1.906ms ± 58.841us    (1.821ms ... 3.889ms)        1.914ms    2.025ms    2.091ms
Eval12 startpos        138      2.29s          16.599ms ± 520.766us  (16.253ms ... 18.469ms)      16.488ms   18.377ms   18.469ms
```

```
v0.7.4 vs v0.7.3 - 1000 games 40/1
Elo difference: 4.5 +/- 15.4, LOS: 71.8 %, DrawRatio: 49.1 %
```

### v0.8.0
- Zig upgrade and various fixes

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.028s         10.282us ± 2.353us    (9.196us ... 107.062us)      10.069us   14.242us   15.546us
Perft4 startpos        1352     5.028s         3.719ms ± 120.56us    (3.533ms ... 6.372ms)        3.745ms    3.971ms    4.269ms
Perft6 startpos        2        4.609s         2.304s ± 3.758ms      (2.302s ... 2.307s)          2.307s     2.307s     2.307s
Perft2 kiwipete        100000   4.148s         41.481us ± 8.015us    (36.19us ... 962.684us)      41.284us   63.208us   68.138us
Perft4 kiwipete        63       4.954s         78.649ms ± 880.734us  (77.927ms ... 82.312ms)      78.62ms    82.312ms   82.312ms
Eval6 startpos         688      5.225s         7.595ms ± 1.002ms     (6.785ms ... 14.817ms)       7.664ms    12.103ms   12.922ms
Eval8 startpos         321      4.892s         15.241ms ± 1.345ms    (14.431ms ... 22.314ms)      15.091ms   21.168ms   21.67ms
Eval10 startpos        100      4.978s         49.783ms ± 3.831ms    (46.969ms ... 65.414ms)      50.599ms   65.414ms   65.414ms
Eval12 startpos        13       5s             384.641ms ± 16.115ms  (358.109ms ... 406.593ms)    396.803ms  406.593ms  406.593ms
Eval6 kiwipete         174      4.921s         28.286ms ± 526.563us  (27.859ms ... 30.912ms)      28.246ms   30.827ms   30.912ms
Eval8 kiwipete         47       5.108s         108.691ms ± 4.755ms   (102.699ms ... 123.657ms)    111.563ms  123.657ms  123.657ms
Eval10 startpos        6        4.09s          681.713ms ± 13.004ms  (668.393ms ... 700.959ms)    692.744ms  700.959ms  700.959ms
Eval12 startpos        1        3.982s         3.982s ± 0ns          (3.982s ... 3.982s)          3.982s     3.982s     3.982s
```

```
v0.8.0 vs v0.7.4 - 100 games 40/1
Elo difference: 6.9 +/- 50.3, LOS: 60.7 %, DrawRatio: 46.0 %
```

### v0.8.1
- Fix transposition item probe

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   1.029s         10.293us ± 5.575us    (9.234us ... 969.686us)      10.051us   14.748us   16.878us
Perft4 startpos        1363     5.034s         3.693ms ± 147.54us    (3.55ms ... 6.492ms)         3.695ms    3.986ms    4.573ms
Perft6 startpos        2        4.559s         2.279s ± 3.58ms       (2.277s ... 2.282s)          2.282s     2.282s     2.282s
Perft2 kiwipete        100000   4.093s         40.93us ± 6.954us     (36.243us ... 917.142us)     41.147us   48.813us   54.367us
Perft4 kiwipete        64       4.999s         78.114ms ± 730us      (77.386ms ... 81.683ms)      78.055ms   81.683ms   81.683ms
Eval6 startpos         677      4.994s         7.376ms ± 465.846us   (6.912ms ... 11.412ms)       7.379ms    9.762ms    9.934ms
Eval8 startpos         382      5.007s         13.108ms ± 817.269us  (12.58ms ... 19.938ms)       12.985ms   17.109ms   17.486ms
Eval10 startpos        137      5.028s         36.705ms ± 2.655ms    (34.769ms ... 50.378ms)      36.975ms   47.375ms   50.378ms
Eval12 startpos        22       4.983s         226.52ms ± 8.407ms    (215.359ms ... 246.471ms)    229.285ms  246.471ms  246.471ms
Eval6 kiwipete         255      4.976s         19.516ms ± 703.468us  (19.018ms ... 23.614ms)      19.445ms   23.102ms   23.31ms
Eval8 kiwipete         86       4.972s         57.814ms ± 2.184ms    (55.959ms ... 66.615ms)      59.286ms   66.615ms   66.615ms
Eval10 startpos        9        4.523s         502.652ms ± 4.79ms    (495.422ms ... 508.98ms)     505.795ms  508.98ms   508.98ms
Eval12 startpos        1        4.015s         4.015s ± 0ns          (4.015s ... 4.015s)          4.015s     4.015s     4.015s
```

```
v0.8.1 vs v0.8.0 - 500 games 40/1
Elo difference: 91.7 +/- 24.0, LOS: 100.0 %, DrawRatio: 39.4 %
```

### v0.8.2
- Fix and use pawn structure

```
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Perft2 startpos        100000   944.011ms      9.44us ± 1.201us      (8.8us ... 108.888us)        9.437us    12.228us   12.678us
Perft4 startpos        1318     5.004s         3.797ms ± 223.152us   (3.614ms ... 6.257ms)        3.77ms     4.939ms    4.971ms
Perft6 startpos        2        4.164s         2.082s ± 921.396us    (2.081s ... 2.083s)          2.083s     2.083s     2.083s
Perft2 kiwipete        100000   3.666s         36.664us ± 6.662us    (34.01us ... 928.351us)      36.924us   40.665us   42.465us
Perft4 kiwipete        63       4.962s         78.763ms ± 705.612us  (78.107ms ... 80.986ms)      78.776ms   80.986ms   80.986ms
Eval6 startpos         680      4.995s         7.346ms ± 307.264us   (7.033ms ... 10.025ms)       7.376ms    9.178ms    9.584ms
Eval8 startpos         264      4.989s         18.899ms ± 956.922us  (18.324ms ... 24.953ms)      18.74ms    23.153ms   23.155ms
Eval10 startpos        47       5.106s         108.643ms ± 6.285ms   (100.091ms ... 127.444ms)    112.473ms  127.444ms  127.444ms
Eval12 startpos        5        4.369s         873.973ms ± 8.459ms   (861.774ms ... 881.429ms)    879.98ms   881.429ms  881.429ms
Eval6 kiwipete         199      4.981s         25.033ms ± 1.004ms    (24.34ms ... 31.715ms)       24.852ms   29.616ms   31.715ms
Eval8 kiwipete         65       4.947s         76.12ms ± 3.313ms     (73.545ms ... 88.583ms)      77.268ms   88.583ms   88.583ms
Eval10 startpos        14       4.816s         344.07ms ± 4.618ms    (336.466ms ... 351.788ms)    347.782ms  351.788ms  351.788ms
Eval12 startpos        1        2.641s         2.641s ± 0ns          (2.641s ... 2.641s)          2.641s     2.641s     2.641s
```

### v0.8.3
- Fix bugs and update zig to 0.17

```
benchmark         runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
------------------------------------------------------------------------------------------------------------------------------
Perft2 startpos   100000   1.145s         11.458us ± 4.631us    (10.18us ... 307.682us)      11.344us   14.831us   18.971us
Perft4 startpos   1286     5.009s         3.895ms ± 47.825us    (3.808ms ... 4.816ms)        3.917ms    4.019ms    4.029ms
Perft6 startpos   2        4.702s         2.351s ± 2.868ms      (2.349s ... 2.353s)          2.353s     2.353s     2.353s
Perft2 kiwipete   100000   4.163s         41.63us ± 3.398us     (39.627us ... 147.598us)     41.527us   57.287us   63.886us
Perft4 kiwipete   63       4.968s         78.871ms ± 438.435us  (78.425ms ... 80.409ms)      78.914ms   80.409ms   80.409ms
Eval6 startpos    457      4.986s         10.911ms ± 311.467us  (10.743ms ... 12.496ms)      10.847ms   12.277ms   12.303ms
Eval8 startpos    231      4.997s         21.634ms ± 969.2us    (21.127ms ... 27.51ms)       21.432ms   26.525ms   26.671ms
Eval10 startpos   50       4.993s         99.867ms ± 4.299ms    (96.606ms ... 111.851ms)     102.671ms  111.851ms  111.851ms
Eval12 startpos   6        4.371s         728.535ms ± 6.436ms   (720.421ms ... 736.274ms)    732.553ms  736.274ms  736.274ms
Eval6 kiwipete    168      4.978s         29.635ms ± 814.71us   (29.176ms ... 33.587ms)      29.533ms   33.272ms   33.587ms
Eval8 kiwipete    59       4.951s         83.92ms ± 3.239ms     (81.793ms ... 94.658ms)      84.788ms   94.658ms   94.658ms
Eval10 startpos   13       4.699s         361.492ms ± 5.187ms   (356.594ms ... 369.184ms)    366.399ms  369.184ms  369.184ms
Eval12 startpos   1        2.579s         2.579s ± 0ns          (2.579s ... 2.579s)          2.579s     2.579s     2.579s
```
