
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
Perft2 startpos        100000   1.399s         13.99us ± 2.757us      (12.759us ... 159.245us)     13.981us   23.207us   26.102us
Perft4 startpos        368      1.997s         5.428ms ± 322.773us    (5.125ms ... 8.103ms)        5.498ms    6.667ms    6.78ms
Perft6 startpos        1        3.262s         3.262s ± 0ns           (3.262s ... 3.262s)          3.262s     3.262s     3.262s
Perft2 kiwipete        34313    1.988s         57.96us ± 3.306us      (54.598us ... 234.55us)      58.099us   69.318us   75.013us
Perft4 kiwipete        18       2.022s         112.373ms ± 3.357ms    (109.607ms ... 123.531ms)    112.854ms  123.531ms  123.531ms
Eval2 startpos         100000   1.778s         17.785us ± 18.639us    (15.255us ... 933.761us)     16.937us   21.956us   30.614us
Eval4 startpos         32158    2.007s         62.439us ± 13.212us    (55.721us ... 388.612us)     63.211us   111.076us  175.147us
Eval2 kiwipete         100000   1.899s         18.999us ± 23.677us    (15.398us ... 908.25us)      17.81us    30.667us   34.303us
Eval4 kiwipete         34162    1.974s         57.804us ± 13.664us    (51.52us ... 498.797us)      56.779us   106.5us    151.401us
```
