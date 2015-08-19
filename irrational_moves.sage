# Make sure current directory is in path.  
# That's not true while doctesting (sage -t).
if '' not in sys.path:
    sys.path = [''] + sys.path

from igp import *

def generate_polytope(f, components, additive_vertices, field=None):
    """
    `components` takes care of symmetry conditions.
    By putting the intevals which must have the same slope value in the same component, we optimize the degree of the polytope. 
    The provided arguments should have nice_field_elements, if we use RNF coercion.

    EXAMPLES::

        sage: logging.disable(logging.INFO) # to disable output in automatic tests.
        sage: [f] = nice_field_values([2^(1/3)/2])
        sage: p = generate_polytope(f, [[[0,f]],[[f, 1]]], [], field=None)
        sage: p.Vrepresentation()
        (A vertex at (RNF1.587401051968199?, RNF-2.702414383919315?),)
    """
    fn_sym = generate_symbolic_continuous(None, components, field)
    bkpt = fn_sym.end_points()
    bkpt2 = bkpt[:-1] + [ x+1 for x in bkpt ]
    subadditive_vertices = set( [ (x, y) for x in bkpt for y in bkpt if x <= y ] + \
                                [ (x, z-x) for x in bkpt for z in bkpt2 if x < z < 1+x ] ) \
                         - set( additive_vertices )
    ieqdic = {}
    eqndic = {}
    if field is None:
        field = bkpt[0].parent().fraction_field()
    for x in bkpt:
        v = fn_sym(x)
        ieq = tuple([field(0)]) + tuple(v)  # fn(x) >= 0
        if not ieq in ieqdic:
            ieqdic[ieq]=set([])
        ieq = tuple([field(1)]) + tuple([-w for w in v]) #fn(x) <=1
        if not ieq in ieqdic:
            ieqdic[ieq]=set([])
    # fn(0) = 0
    eqn = tuple([field(0)]) + tuple(fn_sym(0))
    if not eqn in eqndic:
        eqndic[eqn] = set([]) # or = [(0,0)]?
    # fn(1) = 0
    eqn = tuple([field(0)]) + tuple(fn_sym(1))
    if not eqn in eqndic:
        eqndic[eqn] = set([])
    # fn(f) = 1
    eqn = tuple([field(-1)]) + tuple(fn_sym(f))
    if not eqn in eqndic:
        eqndic[eqn] = set([])
    for (x, y) in additive_vertices:
        v = tuple([field(0)]) + tuple(delta_pi(fn_sym, x, y))
        if v in eqndic:
            eqndic[v].add((x, y))
        else:
            eqndic[v] = set([(x, y)])
    for (x, y) in subadditive_vertices:
        v = tuple([field(0)]) + tuple(delta_pi(fn_sym, x, y))
        if v in eqndic:
            eqndic[v].add((x, y)) # equality holds, no need in ieqdic.
        elif v in ieqdic:
            ieqdic[v].add((x, y))
        else:
            ieqdic[v] = set([(x, y)])
    #return ieqdic, eqndic
    p = Polyhedron(ieqs = ieqdic.keys(), eqns = eqndic.keys())
    return p
