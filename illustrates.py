import fire
from viznet import *
import matplotlib.pyplot as plt
plt.rcParams['mathtext.fontset'] = 'dejavuserif'
#plt.rcParams['font.family'] = 'serif'

setting.node_setting['lw']=2

class Plt():
    def ad(self, tp="pdf"):
        FSIZE = 14
        FSIZE2 = 14
        #GRAY = "#AAAAAA"
        GRAY = "none"
        node = NodeBrush("basic", color=GRAY, size="small")
        hnode = NodeBrush("basic", color=GRAY, size="normal")
        local_node = NodeBrush("basic", color='w', size="small")
        local_hnode = NodeBrush("basic", color='w', size="normal")
        invisible = NodeBrush("invisible", size="small")
        edge1 = EdgeBrush('->-', lw=2)
        edge2 = EdgeBrush('-.', lw=2)
        edge3 = EdgeBrush('.-', lw=2)
        with DynamicShow(figsize=(7,4), filename="ad.%s"%tp) as dp:
            x = 0
            n1 = pin >> (x,1.5)
            n2 = invisible >> (x,0.5)
            e1 = edge1 >> (n1, n2)
            e1.text(r"$\mathbf{x}^{i-1}$", 'right', fontsize=FSIZE)
            n2.text(r"$f_i$", fontsize=FSIZE)

            p2 = pin >> (x,-0.6)
            n3 = pin >> (x,-1.5)
            e2 = edge1 >> (n2, p2)
            e2.text(r"$\mathbf{x}^i$", 'right', fontsize=FSIZE)
            e = edge3 >> (p2, n3)
            e.head().text("$\mathbf{x}^L$", "bottom", fontsize=FSIZE)
            plt.text(x, -2.0, "call", fontsize=FSIZE2, va='center', ha='center')

            # inverse
            x += 1.0
            n1 = pin >> (x,1.5)
            n2 = invisible >> (x,0.5)
            e1 = edge1 >> (n2, n1)
            e1.text(r"$\mathbf{x}^{i-1}$", 'right', fontsize=FSIZE)
            n2.text(r"$f_i^{-1}$", fontsize=FSIZE)

            p2 = pin >> (x,-0.6)
            n3 = pin >> (x,-1.5)
            e2 = edge1 >> (p2,n2)
            e2.text(r"$\mathbf{x}^i$", 'right', fontsize=FSIZE)
            e = edge3 >> (p2, n3)
            e.head().text("$\mathbf{x}^L$", "bottom", fontsize=FSIZE)
            plt.text(x, -2.0, "uncall", fontsize=FSIZE2, va='center', ha='center')

            # Jacobian
            x += 2.0
            n0 = pin >> (x,-1.5)
            n1 = node >> (x,-0.5)
            e = edge1 >> (n0, n1)
            e.text("$\mathbf{x}^L$", "right", fontsize=FSIZE)
            #n1.text(r"$J_{\mathbf{x}^L}^{\mathbf{x}^i}$", fontsize=FSIZE)
            n2 = local_node >> (x,0.5)
            e = edge1 >> (n1, n2)
            e.text("$\mathbf{x}^i$", "right", fontsize=FSIZE)
            #n2.text(r"$J^{\mathbf{x}^i}_x$", fontsize=FSIZE)
            n3 = pin >> (x,1.5)
            e = edge1 >> (n2, n3)
            e.text("$\mathbf{x}^{i-1}$", "right", fontsize=FSIZE)
            plt.text(x, -2.0, "Jacobian", fontsize=FSIZE2, va='center', ha='center')

            # Hessian A
            x += 2.2
            n0 = pin >> (x,-1.5)
            n1 = hnode >> (x,-0.5)
            #n1.text(r"$H^{\mathbf{x}^L}_{\mathbf{x}^i,\mathbf{x}^{i\prime}}$", fontsize=FSIZE)
            e = edge1 >> (n0, n1)
            e.text("$\mathbf{x}^L$", "right", fontsize=FSIZE)

            n2 = local_node >> (x-0.5,0.5)
            #n2.text(r"$J^y_x$", fontsize=FSIZE)
            n3 = local_node >> (x+0.5,0.5)
            #n3.text(r"$J^{\mathbf{x}^{i\prime}}_{\mathbf{x}^{i-1\prime}}$", fontsize=FSIZE)
            e = edge1 >> (n1, n2)
            e.text("$\mathbf{x}^i$", "right", fontsize=FSIZE)
            e = edge1 >> (n1, n3)
            e.text("$\mathbf{x}^{i'}$", "right", fontsize=FSIZE)
            n4 = pin >> (x-0.5,1.5)
            n5 = pin >> (x+0.5,1.5)

            e = edge1 >> (n2, n4)
            e.text("$\mathbf{x}^{i-1}$", "right", fontsize=FSIZE)
            e = edge1 >> (n3, n5)
            e.text(r"$\mathbf{x}^{i-1'}$", "right", fontsize=FSIZE)

            x += 0.85
            plt.text(x, 0.0, r"$+$", fontsize=16)
            plt.text(x, -2.0, "Hessian", fontsize=FSIZE2, va='center', ha='center')

            # Hessian B
            x += 0.85
            n0 = pin >> (x,-1.5)
            n1 = node >> (x,-0.5)
            #n1.text(r"$J^{\mathbf{x}^L}_y$", fontsize=FSIZE)
            e = edge1 >> (n0, n1)
            e.text("$\mathbf{x}^L$", "right", fontsize=FSIZE)

            n2 = local_hnode >> (x,0.5)
            #n2.text(r"$H^y_{\mathbf{x}^{i-1},\mathbf{x}^{i-1\prime}}$", fontsize=FSIZE)
            e = edge1 >> (n1, n2)
            e.text("$\mathbf{x}^i$", "right", fontsize=FSIZE)

            n4 = pin >> (x-0.5,1.5)
            n5 = pin >> (x+0.5,1.5)

            e = edge1 >> (n2, n4)
            e.text("$\mathbf{x}^{i-1}$", "right", fontsize=FSIZE)
            e = edge1 >> (n2, n5)
            e.text("$\mathbf{x}^{i-1'}$", "right", fontsize=FSIZE)
       
fire.Fire(Plt)
