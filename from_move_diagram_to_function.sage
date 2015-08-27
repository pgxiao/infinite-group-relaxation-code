def moves_to_faces(fn, show_plots=False):
    f = fn
    faces = set()
    bkpts = set()
    potential_bkpts = set()
    uncovered_intervals = generate_uncovered_intervals(f)
    for interval in uncovered_intervals:
        bkpts.add(interval[0])
        bkpts.add(interval[1])
    moves = generate_functional_directed_moves(f)
    # print moves
    # print moves[0]
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
            z1 = x1 + y1
            z2 = x2 + y2
        
            #(-1, t), diagonal case:
            sign = mv[0]
            c = mv[1]
            if sign == -1: 
                faces.add(Face((normal_interval(x1, x2), normal_interval(y1, y2), normal_interval(c, c))))
                bkpts.add(c)
            
            # (1, t)
            if sign == 1:
                if c >= 0:
                    # horizontal case 
                        faces.add(Face((normal_interval(x1, x2), normal_interval(y1-x1, y2-x2), normal_interval(y1, y2))))
                        bkpts.add(c)
                        # potential_bkpts.add(x1)
                        # potential_bkpts.add(x2)
                    # vertical case
                        # faces.add(Face((normal_interval(x1-y1+1, x2-y2+1), normal_interval(y1, y2), normal_interval(x1+1, x2+1))))
                        #comment: it seems like the vertical face is not correct as well as the horizontal face on the following
                        # potential_bkpts.add(y1)
                        # potential_bkpts.add(y2)
                else:
                    # horizontal case
                        # faces.add(Face((normal_interval(x1, x2), normal_interval(y1-x1+1, y2-x2+1), normal_interval(y1+1, y2+1))))
                        bkpts.add(-c)
                        # potential_bkpts.add(x1)
                        # potential_bkpts.add(x2)
                    # vertical case
                        faces.add(Face((normal_interval(x1-y1, x2-y2), normal_interval(y1, y2), normal_interval(x1, x2))))
                        # potential_bkpts.add(y1)
                        # potential_bkpts.add(y2)
    if show_plots == True:
        show(plot_faces(faces))
    bkpts.add(1)
    bkpts = list(bkpts)
    bkpts.sort()
    return bkpts

def normal_interval(a, b):
    if a > b:
        raise ValueError("the right end point should b equal or largner than the left end point")
    elif a == b:
        return [a]
    else:
        return [a, b]

def generate_components(f, bkpts):
    n = len(bkpts)
    f_index = bkpts.index(f)
    left_components = [[bkpts[i], bkpts[f_index-i]] for i in range (0, (f_index+1)/2)]
    right_components =  [[bkpts[f_index + i], bkpts[n-1-i]] for i in range (0, (n-f_index)/2)]
    return left_components + right_components

def proof_only_bkpts_from_uncovered_interval_gives_empty_polytope():
    """
    EXAMPLES::
    Use bhk_irrational as an example to show only bkpts from uncovered interval will give empty polytope

        sage: p = proof_only_bkpts_from_uncovered_interval_gives_empty_polytope()
        ... some logging info ...
        sage: p
        sage: The empty polyhedron in (Number Field in a with defining polynomial y^2 - 2)^1
    """
    bhk = bhk_irrational()
    bkpts = moves_to_faces(bhk)
    f = 4/5
    components = generate_components(f, bkpts)
    p = generate_polytope(f, [components],[], field=None)
    return p

p = proof_only_bkpts_from_uncovered_interval_gives_empty_polytope()
