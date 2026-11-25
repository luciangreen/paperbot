% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/paperbot').

% Domain: 1..3 weights from 0..4 and totals 0..20; section sets over x, y, z with every dependency set.
weights(Ws) :- between(1, 3, N), length(Ws, N), maplist([W]>>between(0, 4, W), Ws).

% 1. The shares add up exactly to the total (when any weight is positive).
theorem(shares_add_up) :- forall(( weights(Ws), sum_list(Ws, S), S > 0, between(0, 20, T) ), ( allocate(Ws, T, As), sum_list(As, T) )).

% 2. Each share is its exact proportion rounded down or up.
theorem(quota_rule) :- forall(( weights(Ws), sum_list(Ws, S), S > 0, between(0, 20, T) ), ( allocate(Ws, T, As), maplist([W, A]>>( Lo is W * T // S, Hi is (W * T + S - 1) // S, between(Lo, Hi, A) ), Ws, As) )).

% 3. A heavier weight never gets fewer words.
theorem(fair_order) :- forall(( weights(Ws), sum_list(Ws, S), S > 0, between(0, 20, T) ), ( allocate(Ws, T, As), forall(( nth1(I, Ws, Wi), nth1(J, Ws, Wj), Wi > Wj ), ( nth1(I, As, Ai), nth1(J, As, Aj), Ai >= Aj )) )).

% 4. Plans list every section after its dependencies when the dependencies have no loop.
sections(Ss) :- maplist([N, sec(N, 1, Ds)]>>( member(Ds, [[], [x], [y], [z], [x, y], [x, z], [y, z]]), \+ memberchk(N, Ds) ), [x, y, z], Ss).
theorem(dependencies_first) :- forall(( sections(Ss), dep_order(Ss, Ns) ), ( msort(Ns, [x, y, z]), forall(( member(sec(N, _, Ds), Ss), member(D, Ds) ), ( nth1(I, Ns, D), nth1(J, Ns, N), I < J )) )).

% 5. A larger budget never gives any section fewer words (no Alabama paradox).
theorem(house_monotone) :- forall(( weights(Ws), sum_list(Ws, S), S > 0, between(0, 19, T) ), ( T1 is T + 1, allocate(Ws, T, As), allocate(Ws, T1, Bs), maplist([A, B]>>( B >= A ), As, Bs) )).
