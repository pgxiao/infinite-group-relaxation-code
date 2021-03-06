# Make sure current directory is in path.  
# That's not true while doctesting (sage -t).
if '' not in sys.path:
    sys.path = [''] + sys.path

from igp import *

## FIXME: Its __name__ is "Fast..." but nobody so far has timed
## its performance against the other options. --Matthias
class FastLinearFunction :

    def __init__(self, slope, intercept):
        self._slope = slope
        self._intercept = intercept

    def __call__(self, x):
        if type(x) == float:
            # FIXME: There must be a better way.
            return float(self._slope) * x + float(self._intercept)
        else:
            return self._slope * x + self._intercept


    def __float__(self):
        return self

    def __add__(self, other):
        return FastLinearFunction(self._slope + other._slope,
                                  self._intercept + other._intercept)

    def __mul__(self, other):
        # scalar multiplication
        return FastLinearFunction(self._slope * other,
                                  self._intercept * other)


    def __neg__(self):
        return FastLinearFunction(-self._slope,
                                  -self._intercept)

    __rmul__ = __mul__

    def __eq__(self, other):
        if not isinstance(other, FastLinearFunction):
            return False
        return self._slope == other._slope and self._intercept == other._intercept

    def __ne__(self, other):
        return not (self == other)

    def __repr__(self):
        # Following the Sage convention of returning a pretty-printed
        # expression in __repr__ (rather than __str__).
        try:
            return '<FastLinearFunction ' + sage.misc.misc.repr_lincomb([('x', self._slope), (1, self._intercept)], strip_one = True) + '>'
        except TypeError:
            return '<FastLinearFunction (%s)*x + (%s)>' % (self._slope, self._intercept)

    def _sage_input_(self, sib, coerced):
        """
        Produce an expression which will reproduce this value when evaluated.
        """
        return sib.name('FastLinearFunction')(sib(self._slope), sib(self._intercept))

    ## FIXME: To be continued.

fast_linear_function = FastLinearFunction

def linear_function_through_points(p, q):
    slope = (q[1] - p[1]) / (q[0] - p[0])
    intercept = p[1] - slope * p[0]
    return FastLinearFunction(slope, intercept) 

