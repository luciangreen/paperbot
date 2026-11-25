% paperbot: plan a research paper. Sections have a weight and may depend on other sections;
% plan/4 puts every section after the ones it depends on and shares a word budget out in
% proportion to the weights by Balinski and Young's quota method, so the words add up exactly, each
% section gets its fair share rounded up or down, and a larger budget never shrinks a section. Claims without a citation are flagged.
% Sections: sec(Name, Weight, DependsOn).
%?- allocate([3, 1], 10, A).    % A = [8, 2]  (7.5 and 2.5; the tie goes to the first)
%?- plan([sec(results, 2, [method]), sec(method, 1, [])], 300, P).   % P = [method-100, results-200]
:- module(paperbot, [allocate/3, plan/3, uncited/2, dep_order/2]).
:- use_module(library(lists)).
:- use_module(library(apply)).

% allocate(+Weights, +Total, -Shares): Balinski and Young's quota method. Words are handed
% out one at a time; each goes to the section with the largest Weight/(Share+1) among those
% still below their upper quota for the new total (ties to earlier entries). So every share is
% its exact proportion rounded down or up, the shares add up exactly, and a larger total never
% gives any section fewer words (no Alabama paradox, which largest remainders can show).
allocate(Ws, T, As) :- sum_list(Ws, S), ( S =:= 0 -> maplist([_, 0]>>true, Ws, As) ; maplist([_, 0]>>true, Ws, A0), quota_steps(0, T, Ws, S, A0, As) ).
quota_steps(T, T, _, _, As, As) :- !.
quota_steps(K, T, Ws, S, A0, As) :-
    K1 is K + 1,
    findall(I-W-A, ( nth1(I, Ws, W), nth1(I, A0, A), A * S < W * K1 ), [C|Cs]),
    foldl([I-W-A, Ib-Wb-Ab, B]>>( W * (Ab + 1) > Wb * (A + 1) -> B = I-W-A ; B = Ib-Wb-Ab ), Cs, C, Best-_-_),
    nth1(Best, A0, Old, Rest), New is Old + 1, nth1(Best, A1, New, Rest),
    quota_steps(K1, T, Ws, S, A1, As).

% dep_order(+Sections, -Names): dependencies first; among ready sections, the earliest listed.
dep_order(Ss, Ns) :- dep_(Ss, [], Ns).
dep_([], _, []) :- !.
dep_(Ss, Done, [N|Ns]) :- member(sec(N, W, Ds), Ss), subtract(Ds, Done, []), !, selectchk(sec(N, W, Ds), Ss, Rest), dep_(Rest, [N|Done], Ns).

plan(Ss, T, P) :- dep_order(Ss, Ns), maplist([N, W]>>memberchk(sec(N, W, _), Ss), Ns, Ws), allocate(Ws, T, As), pairs_keys_values(P, Ns, As).

% uncited(+Claims, -Names): claims are claim(Name, Citations).
uncited(Cs, Ns) :- findall(N, member(claim(N, []), Cs), Ns).
