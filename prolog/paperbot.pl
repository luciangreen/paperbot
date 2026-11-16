% paperbot: plan a research paper. Sections have a weight and may depend on other sections;
% plan/4 puts every section after the ones it depends on and shares a word budget out in
% proportion to the weights by largest remainders, so the words add up exactly and each section
% gets its fair share rounded up or down. Claims without a citation are flagged.
% Sections: sec(Name, Weight, DependsOn).
%?- allocate([3, 1], 10, A).    % A = [8, 2]  (7.5 and 2.5; the tie goes to the first)
%?- plan([sec(results, 2, [method]), sec(method, 1, [])], 300, P).   % P = [method-100, results-200]
:- module(paperbot, [allocate/3, plan/3, uncited/2, dep_order/2]).
:- use_module(library(lists)).
:- use_module(library(apply)).

% allocate(+Weights, +Total, -Shares): largest-remainder apportionment (ties to earlier entries).
allocate(Ws, T, As) :- sum_list(Ws, S), ( S =:= 0 -> maplist([_, 0]>>true, Ws, As) ; length(Ws, N), numlist(1, N, Is), maplist([W, F]>>( F is W * T // S ), Ws, Fs), sum_list(Fs, Given), Left is T - Given, maplist([I, W, F, K]>>( R is W * T - F * S, K = R-I ), Is, Ws, Fs, Ks), sort(1, @>=, Ks, Sorted), length(Top, Left), append(Top, _, Sorted), pairs_values(Top, Extra), maplist([I, F, A]>>( memberchk(I, Extra) -> A is F + 1 ; A = F ), Is, Fs, As) ).

% dep_order(+Sections, -Names): dependencies first; among ready sections, the earliest listed.
dep_order(Ss, Ns) :- dep_(Ss, [], Ns).
dep_([], _, []) :- !.
dep_(Ss, Done, [N|Ns]) :- member(sec(N, W, Ds), Ss), subtract(Ds, Done, []), !, selectchk(sec(N, W, Ds), Ss, Rest), dep_(Rest, [N|Done], Ns).

plan(Ss, T, P) :- dep_order(Ss, Ns), maplist([N, W]>>memberchk(sec(N, W, _), Ss), Ns, Ws), allocate(Ws, T, As), pairs_keys_values(P, Ns, As).

% uncited(+Claims, -Names): claims are claim(Name, Citations).
uncited(Cs, Ns) :- findall(N, member(claim(N, []), Cs), Ns).
