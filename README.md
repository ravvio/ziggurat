# Ziggurat


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

# Credits
- https://github.com/SnowballSH/Avalanche
