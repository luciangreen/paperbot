:- module(cases, [title/1, case/3]).
:- use_module('../prolog/paperbot').
:- use_module(engine).
title('paperbot').
case(allocate, [Ws, T], allocate) :- rnd_int(1, 6, N), length(Ws, N), maplist([W]>>rnd_int(0, 9, W), Ws), rnd_int(0, 5000, T).
case(plan, [Ss, T], plan) :- Ns = [intro, background, method, results, discussion], maplist([N, sec(N, W, Ds)]>>( rnd_int(1, 5, W), nth1(I, Ns, N), I0 is I - 1, length(Pre, I0), append(Pre, _, Ns), include([_]>>rnd_chance(40), Pre, Ds) ), Ns, Ss0), reverse(Ss0, Ss), rnd_int(500, 8000, T).
case(uncited, [Cs], uncited) :- rnd_int(0, 6, K), numlist(1, 6, All), length(Is, K), append(Is, _, All), maplist([I, claim(N, C)]>>( atom_concat(claim, I, N), ( rnd_chance(60) -> C = [ref(I)] ; C = [] ) ), Is, Cs).
