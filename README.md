# paperbot

plan a research paper. Sections have a weight and may depend on other sections; plan/4 puts every section after the ones it depends on and shares a word budget out in proportion to the weights by Balinski and Young's quota method, so the words add up exactly, each section gets its fair share rounded up or down, and a larger budget never gives any section fewer words. (The largest-remainder method used before could: with weights 3, 3 and 1, 10 words gave [4, 4, 2] but 11 gave [5, 5, 1].) Claims without a citation are flagged. Sections: sec(Name, Weight, DependsOn).

## Use

```prolog
?- use_module(prolog/paperbot).
?- allocate([3, 1], 10, A).    % A = [8, 2]  (7.5 and 2.5; the tie goes to the first)
?- allocate([3, 3, 1], 10, A), allocate([3, 3, 1], 11, B).   % A = [5, 4, 1], B = [5, 5, 1]
?- plan([sec(results, 2, [method]), sec(method, 1, [])], 300, P).   % P = [method-100, results-200]
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. 1..3 weights from 0..4 and totals 0..20; section sets over x, y, z with every dependency set.

1. The shares add up exactly to the total (when any weight is positive).
2. Each share is its exact proportion rounded down or up.
3. A heavier weight never gets fewer words.
4. Plans list every section after its dependencies when the dependencies have no loop.
5. A larger budget never gives any section fewer words (no Alabama paradox).

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
