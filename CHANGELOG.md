
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
