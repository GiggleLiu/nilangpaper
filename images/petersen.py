from viznet import theme, NodeBrush, EdgeBrush, DynamicShow
from viznet.utils import rotate
import pdb, fire
import numpy as np

def withcolor(color, edge, pos):
    old_color = edge.color
    edge.color = color
    obj = edge >> pos
    edge.color = old_color
    return obj

class Petersen(object):
    def _petersen(self, colored, tp='pdf'):
        size = 'normal'
        node = NodeBrush('basic', size=size)
        edge = EdgeBrush('---', lw=2.)

        with DynamicShow((4, 4), filename='%spetersen.%s'%('c' if colored else '',tp)) as ds:
            x = [0, 1]
            y = [0, 2]
            ys = []
            xs = []
            for i in range(5):
                xi = node >> rotate(x, np.pi/5*2*i)
                yi = node >> rotate(y, np.pi/5*2*i)
                xi.text("%d"%(i+6))
                yi.text("%d"%(i+1))
                xs.append(xi)
                ys.append(yi)
                c = 'r' if (i==0 and colored) else 'k'
                withcolor(c, edge, (xi, yi))
            for i in range(5):
                c = 'g' if i==0 else ('b' if i==3 else 'k')
                if not colored: c='k'
                withcolor(c, edge, (xs[i], xs[(i+2)%5]))
                edge >> (ys[i], ys[(i+1)%5])

    def petersen(self, tp='pdf'):
        self._petersen(False, tp)

    def cpetersen(self, tp='pdf'):
        self._petersen(True, tp)

    def petersenijk(self, tp='pdf'):
        colored = False
        size = 'normal'
        node = NodeBrush('basic', size=size)
        edge = EdgeBrush('---', lw=2.)
        label_count = [0]
        def assign_label():
            label_count[0] += 1
            return "%c"%(96+label_count[0])

        with DynamicShow((4, 4), filename='_petersenijk.%s'%tp) as ds:
            x = [0, 1]
            y = [0, 2]
            ys = []
            xs = []
            for i in range(5):
                xi = node >> rotate(x, np.pi/5*2*i)
                yi = node >> rotate(y, np.pi/5*2*i)
                xi.text("%d"%(i+1))
                yi.text("%d"%(i+6))
                xs.append(xi)
                ys.append(yi)
                c = 'r' if (i==0 and colored) else 'k'
                withcolor(c, edge, (xi, yi)).text(assign_label())
            for i in range(5):
                c = 'g' if i==0 else ('b' if i==4 else 'k')
                if not colored: c='k'
                withcolor(c, edge, (xs[i], xs[(i+2)%5])).text(assign_label() )
                (edge >> (ys[i], ys[(i+1)%5])).text(assign_label())

if __name__ == '__main__':
    fire.Fire(Petersen)
