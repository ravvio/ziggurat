
## Versions

### v0.1.0 - Negamax
- Negamax algorithm with alpha-beta pruning
- Iterative deepening (for now only useful for uci)

```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Movelist Swap          100000   25.681ms       256ns ± 45ns           (237ns ... 3.139us)          251ns      340ns      357ns
Board From FEN 1       100000   103.177ms      1.031us ± 85ns         (965ns ... 4.093us)          1.03us     1.198us    1.204us
Board From FEN 2       100000   102.661ms      1.026us ± 74ns         (987ns ... 10.919us)         1.035us    1.07us     1.082us
Subtract usize         100000   11.944ms       119ns ± 16ns           (118ns ... 1.506us)          119ns      122ns      123ns
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
Movelist Swap          100000   26.994ms       269ns ± 102ns          (223ns ... 9.422us)          280ns      446ns      1.26us
Board From FEN 1       100000   116.026ms      1.16us ± 266ns         (1.032us ... 17.897us)       1.194us    1.667us    1.697us
Board From FEN 2       100000   111.912ms      1.119us ± 107ns        (1.04us ... 10.032us)        1.147us    1.455us    1.475us
Subtract usize         100000   13.811ms       138ns ± 46ns           (125ns ... 9.788us)          141ns      172ns      172ns
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
Movelist Swap          100000   22.815ms       228ns ± 55ns           (207ns ... 9.373us)          234ns      277ns      333ns
Board From FEN 1       100000   98.615ms       986ns ± 60ns           (957ns ... 7.286us)          986ns      1.026us    1.035us
Board From FEN 2       100000   99.3ms         993ns ± 61ns           (967ns ... 7.252us)          993ns      1.031us    1.04us
Subtract usize         100000   11.964ms       119ns ± 19ns           (111ns ... 1.928us)          120ns      123ns      123ns
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
