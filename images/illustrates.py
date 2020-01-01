import fire
from viznet import *
import matplotlib.pyplot as plt

setting.node_setting['lw']=2

class Plt():
    def ad(self, tp="pdf"):
        FSIZE = 14
        FSIZE2 = 14
        node = NodeBrush("basic", size="small")
        hnode = NodeBrush("basic", size="normal")
        invisible = NodeBrush("invisible", size="small")
        edge1 = EdgeBrush('->-', lw=2)
        edge2 = EdgeBrush('-.', lw=2)
        edge3 = EdgeBrush('.-', lw=2)
        with DynamicShow(figsize=(7,4), filename="ad.%s"%tp) as dp:
            x = 0
            n1 = pin >> (x,1.5)
            n2 = invisible >> (x,0.5)
            e1 = edge1 >> (n1, n2)
            e1.text(r"$x$", 'right', fontsize=FSIZE)
            n2.text(r"$f$", fontsize=FSIZE)

            p2 = pin >> (x,-0.6)
            n3 = pin >> (x,-1.5)
            e2 = edge1 >> (n2, p2)
            e2.text(r"$y$", 'right', fontsize=FSIZE)
            e = edge3 >> (p2, n3)
            e.head().text("$O$", "bottom", fontsize=FSIZE)
            plt.text(x, -2.0, "call", fontsize=FSIZE2, va='center', ha='center')

            # inverse
            x += 1.0
            n1 = pin >> (x,1.5)
            n2 = invisible >> (x,0.5)
            e1 = edge1 >> (n2, n1)
            e1.text(r"$x$", 'right', fontsize=FSIZE)
            n2.text(r"$f^{-1}$", fontsize=FSIZE)

            p2 = pin >> (x,-0.6)
            n3 = pin >> (x,-1.5)
            e2 = edge1 >> (p2,n2)
            e2.text(r"$y$", 'right', fontsize=FSIZE)
            e = edge3 >> (p2, n3)
            e.head().text("$O$", "bottom", fontsize=FSIZE)
            plt.text(x, -2.0, "uncall", fontsize=FSIZE2, va='center', ha='center')

            # jacobian
            x += 2.0
            n0 = pin >> (x,-1.5)
            n1 = node >> (x,-0.5)
            e = edge1 >> (n0, n1)
            e.text("$O$", "right", fontsize=FSIZE)
            n1.text(r"$J_{O}^{y}$", fontsize=FSIZE)
            n2 = node >> (x,0.5)
            e = edge1 >> (n1, n2)
            e.text("$y$", "right", fontsize=FSIZE)
            n2.text(r"$J^{y}_x$", fontsize=FSIZE)
            n3 = pin >> (x,1.5)
            e = edge1 >> (n2, n3)
            e.text("$x$", "right", fontsize=FSIZE)
            plt.text(x, -2.0, "jacobian", fontsize=FSIZE2, va='center', ha='center')

            # Hessian A
            x += 2.0
            n0 = pin >> (x,-1.5)
            n1 = hnode >> (x,-0.5)
            n1.text(r"$H^O_{y,y'}$", fontsize=FSIZE)
            e = edge1 >> (n0, n1)
            e.text("$O$", "right", fontsize=FSIZE)

            n2 = node >> (x-0.5,0.5)
            n2.text(r"$J^y_x$", fontsize=FSIZE)
            n3 = node >> (x+0.5,0.5)
            n3.text(r"$J^{y'}_{x'}$", fontsize=FSIZE)
            e = edge1 >> (n1, n2)
            e.text("$y$", "right", fontsize=FSIZE)
            e = edge1 >> (n1, n3)
            e.text("$y'$", "right", fontsize=FSIZE)
            n4 = pin >> (x-0.5,1.5)
            n5 = pin >> (x+0.5,1.5)

            e = edge1 >> (n2, n4)
            e.text("$x$", "right", fontsize=FSIZE)
            e = edge1 >> (n3, n5)
            e.text(r"$x'$", "right", fontsize=FSIZE)

            x += 0.75
            plt.text(x, 0.0, r"$+$", fontsize=16)
            plt.text(x, -2.0, "hessian", fontsize=FSIZE2, va='center', ha='center')

            # Hessian B
            x += 0.75
            n0 = pin >> (x,-1.5)
            n1 = node >> (x,-0.5)
            n1.text(r"$J^O_y$", fontsize=FSIZE)
            e = edge1 >> (n0, n1)
            e.text("$O$", "right", fontsize=FSIZE)

            n2 = hnode >> (x,0.5)
            n2.text(r"$H^y_{x,x'}$", fontsize=FSIZE)
            e = edge1 >> (n1, n2)
            e.text("$y$", "right", fontsize=FSIZE)

            n4 = pin >> (x-0.5,1.5)
            n5 = pin >> (x+0.5,1.5)

            e = edge1 >> (n2, n4)
            e.text("$x$", "right", fontsize=FSIZE)
            e = edge1 >> (n2, n5)
            e.text("$x'$", "right", fontsize=FSIZE)
       
fire.Fire(Plt)
