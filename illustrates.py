import fire
from viznet import *
import matplotlib.pyplot as plt

setting.node_setting['lw']=2

class Plt():
    def ad(self, tp="pdf"):
        FSIZE = 16
        node = NodeBrush("basic", size="small")
        invisible = NodeBrush("invisible", size="small")
        edge1 = EdgeBrush('->-', lw=2)
        edge2 = EdgeBrush('-.', lw=2)
        edge3 = EdgeBrush('.-', lw=2)
        with DynamicShow(filename="ad.%s"%tp) as dp:
            x = 0
            n1 = invisible >> (x,1.5)
            n1.text(r"$\vec{I}$", fontsize=FSIZE)
            p1 = pin >> (x,0.6)
            n2 = node >> (x,0)
            edge2 >> (n1, p1)
            e1 = edge1 >> (p1, n2)
            e1.text(r"$\vec{x}$", 'right', fontsize=FSIZE)
            n2.text(r"$f$", fontsize=FSIZE)

            p2 = pin >> (x,-0.6)
            n3 = invisible >> (x,-1.5)
            n3.text(r"$\vec{O}$", fontsize=FSIZE)
            e2 = edge1 >> (n2, p2)
            e2.text(r"$\vec{y}$", 'right', fontsize=FSIZE)
            edge3 >> (p2, n3)

            # inverse
            x += 1.0
            n1 = invisible >> (x,1.5)
            n1.text(r"$\vec{I}$", fontsize=FSIZE)
            p1 = pin >> (x,0.6)
            n2 = node >> (x,0)
            edge2 >> (n1, p1)
            e1 = edge1 >> (n2, p1)
            e1.text(r"$\vec{x}$", 'right', fontsize=FSIZE)
            n2.text(r"$f^{-1}$", fontsize=FSIZE)

            p2 = pin >> (x,-0.6)
            n3 = invisible >> (x,-1.5)
            n3.text(r"$\vec{O}$", fontsize=FSIZE)
            e2 = edge1 >> (p2,n2)
            e2.text(r"$\vec{y}$", 'right', fontsize=FSIZE)
            edge3 >> (p2, n3)

            # jacobian
            x += 1.0
            n1 = invisible >> (x,1.5)
            n1.text(r"$\vec{I}$", fontsize=FSIZE)
            p1 = pin >> (x,0.6)
            n2 = node >> (x,0)
            edge2 >> (n1, p1)
            e1 = edge1 >> (n2, p1)
            e1.text(r"$\vec{x}$", 'right', fontsize=FSIZE)
            n2.text(r"$f^{-1}$", fontsize=FSIZE)

            p2 = pin >> (x,-0.6)
            n3 = invisible >> (x,-1.5)
            n3.text(r"$\vec{O}$", fontsize=FSIZE)
            e2 = edge1 >> (p2,n2)
            e2.text(r"$\vec{y}$", 'right', fontsize=FSIZE)
            edge3 >> (p2, n3)



        
fire.Fire(Plt)
