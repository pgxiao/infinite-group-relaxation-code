def moves_to_faces(uncovered_intervals, moves, show_plots=False):
    faces = set()
    bkpts = set()
    potential_bkpts = set()
    for interval in uncovered_intervals:
        bkpts.add(interval[0])
        bkpts.add(interval[1])
    for move in moves:
        domain_list = move.intervals()
        codomain_list = move.range_intervals()
        mv = move.directed_move
        #generate faces:
        for i in range (len(list(domain_list))):
            x1 = domain_list[i][0]
            x2 = domain_list[i][1]
            y1 = codomain_list[i][0]
            y2 = codomain_list[i][1]
        
            #(-1, t), diagonal case:
            sign = mv[0]
            c = mv[1]
            if sign == -1: 
                faces.add(Face([[x1, x2], [y1, y2], [c, c]]))
                bkpts.add(c)
            
            # (1, t)
            if sign == 1:
                #FIXME: As the K projection of the faces in this code is normal_interval(y1, y2)) \subset [0,1], 
                # horizontal and vertical additive faces will never appear above the diagonal x+y = 1
                # mod 1 might be needed
                if c >= 0:
                    # horizontal case 
                        if y1-x1 != y2-x2:
                            raise ValueError("wrong data in horizontal case")
                        faces.add(Face([[x1, x2], [y1-x1], [y1, y2]]))
                        bkpts.add(c)
                        potential_bkpts.add(x1)
                        potential_bkpts.add(x2)
                    # vertical case
                        # faces.add(Face(([x1-y1+1, x2-y2+1], [y1, y2], [x1+1, x2+1])))
                        #comment: it seems like the vertical face is not correct as well as the horizontal face on the following
                        # potential_bkpts.add(y1)
                        # potential_bkpts.add(y2)
                else:
                    # horizontal case
                        # faces.add(Face(([x1, x2], [y1-x1+1, y2-x2+1], [y1+1, y2+1])))
                        bkpts.add(-c)
                        # potential_bkpts.add(x1)
                        # potential_bkpts.add(x2)
                    # vertical case
                        if x1-y1 != x2-y2:
                            raise ValueError("wrong data in vertical case")
                        faces.add(Face([[x1-y1], [y1, y2], [x1, x2]]))
                        potential_bkpts.add(y1)
                        potential_bkpts.add(y2)
    if show_plots == True:
        show(plot_faces(faces))
    bkpts.add(1)
    bkpts = list(bkpts)
    bkpts.sort()
    return bkpts

def generate_components(f, bkpts):
    """
    EXAMPLES::

        sage: c = generate_components(4/5, [0, 15/100, 30/100, 50/100, 65/100, 80/100, 85/100, 95/100, 1])
        sage: c
        [[[0, 3/20], [13/20, 4/5]],
         [[3/20, 3/10], [1/2, 13/20]],
         [[3/10, 1/2]],
         [[4/5, 17/20], [19/20, 1]],
         [[17/20, 19/20]]]
    """
    n = len(bkpts)
    f_index = bkpts.index(f)
    left_components = [[[bkpts[i], bkpts[i+1]], [bkpts[f_index-i-1], bkpts[f_index-i]]] if i != f_index-i-1 else [[bkpts[i], bkpts[i+1]]] for i in range (0, (f_index+1)/2)]
    right_components =  [[[bkpts[f_index + i], bkpts[f_index + i + 1]], [bkpts[n-2-i], bkpts[n-1-i]]] if (f_index + i) != n-2-i else [[bkpts[f_index + i], bkpts[f_index + i + 1]]] for i in range (0, (n-f_index)/2)]
    return left_components + right_components

def proof_only_bkpts_from_uncovered_interval_gives_empty_polytope(show_plots=False):
    """
    EXAMPLES::
    Use bhk_irrational as an example to show only bkpts from uncovered interval will give empty polytope

        sage: p = proof_only_bkpts_from_uncovered_interval_gives_empty_polytope()
        ... some logging info ...
        sage: p
        sage: The empty polyhedron in (Number Field in a with defining polynomial y^2 - 2)^1
    """
    fn = bhk_irrational()
    uncovered_intervals = generate_uncovered_intervals(fn)
    moves = generate_functional_directed_moves(fn)
    bkpts = moves_to_faces(uncovered_intervals, moves, show_plots=show_plots)
    f = 4/5
    components = generate_components(f, bkpts)
    p = generate_polytope(f, components,[], field=None)
    return p

p = proof_only_bkpts_from_uncovered_interval_gives_empty_polytope()
