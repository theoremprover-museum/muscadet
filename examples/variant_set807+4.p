%--variant of TPTP problem SET807+4
theorem(pre_order,![E]:pre_order(subset,power_set(E))).
%------------------------------------------------------------------------------
definition(![A,B]:(subset(A,B) <=> ![X]:(member(X,A) => member(X,B)))).
definition(![X,A]:(member(X,power_set(A)) <=> subset(X,A))).
definition(![R,E]:(pre_order(R,E) <=> 
              ( ![X]:(member(X,E) => ..[R,X,X] )
              & ![X,Y,Z]:(member(X,E) & member(Y,E) & member(Z,E)
                         => (..[R,X,Y] & ..[R,Y,Z] => ..[R,X,Z]))))).
%--------------------------------------------------------------------------
