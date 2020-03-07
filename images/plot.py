#!/usr/bin/env python
import fire
from plotlib import *
from viznet import *
from viznet import parsecircuit as _
import numpy as np
import json

class PLT(object):
    def fig1(self, tp='pdf'):
        data = np.loadtxt("train1.dat")
        data2 = np.loadtxt("train.dat")
        L = len(data)
        with DataPlt(filename="fig1.%s"%tp, figsize=(5,4)) as dp:
            plt.plot(range(1,L+1), data, lw=2)
            plt.plot(range(1,L+1), data2, lw=2)
            plt.legend(["$f_1$", "$f_2$"], fontsize=16)
            plt.ylim(0,6)
            plt.xlim(0,30)
            plt.tight_layout()
            plt.xlabel("training step")
            plt.ylabel("value")
            plt.tight_layout()

    def fig2(self, tp='pdf'):
        setting.node_setting['lw']=1.5
        setting.node_setting['inner_lw']=1.5
        edge = EdgeBrush('-', lw=2)
        node = NodeBrush('box', rotate=np.pi/4,size='small', color='none')
        with DynamicShow((5,3), 'fig2.%s'%tp) as ds:
            a = pin >> (-1, 0)
            b = node >> (0, 0)
            edge >> (a, b)

    def fig3(self, tp='pdf'):
        zydata = np.loadtxt("../codes/zygote.dat")
        nidata = np.loadtxt("../codes/nilang.dat")
        rawdata = np.loadtxt("../codes/forward.dat")
        L = len(zydata)
        tfdata = np.zeros(L)
        torchdata = np.zeros(L)
        with open("../codes/py.json", 'r') as f:
            pydata = json.load(f)
        for i in range(L):
            tfdata[i] = pydata['benchmarks'][i]['stats']['min']*1e9
            torchdata[i] = pydata['benchmarks'][L+i]['stats']['min']*1e9
        with DataPlt(filename="fig3.%s"%tp, figsize=(5,4)) as dp:
            plt.plot(2**np.arange(1,L+1), tfdata, lw=2)
            plt.plot(2**np.arange(1,L+1), torchdata, lw=2)
            plt.plot(2**np.arange(1,L+1), zydata*10, lw=2)
            plt.plot(2**np.arange(1,L+1), nidata*1000, lw=2)
            plt.plot(2**np.arange(1,L+1), rawdata*1000, lw=2)
            plt.legend(["TensorFlow", "PyTorch", r"Zygote $\times 10$", r"NiLang $\times 1000$", r"Forward Only (Julia) $\times 1000$"], fontsize=12)
            plt.xlabel("loop size")
            plt.ylim(0, 5e9)
            plt.xlim(0, 2**(L))
            plt.ylabel("time/ns")
            plt.tight_layout()

    def fig4(self, tp='pdf'):
        SIZE = 12
        LW = 1.75
        setting.node_setting['lw']=LW
        setting.node_setting['inner_lw']=LW
        edge = EdgeBrush('-', lw=LW)
        innode = NodeBrush('basic', color='#FFFF99')
        node = NodeBrush('basic', color='none')
        grid = Grid([1.2, 0.8])
        dashed = NodeBrush('box', size=(0.6, 0.4), ls="--", roundness=0.15)
        gray = NodeBrush('box', size=(0.6, 0.4), lw=0, color="#CCCCCC", roundness=0.15, zorder=-10)
        box = NodeBrush('box', size=(0.6, 0.4), lw=LW, color="none")
        WIDE = NodeBrush("box", size=(0.5,0.3))
        def instr(cum, vs, y0):
            g = WIDE >> grid[vs[0].index, y0]
            g.text(cum, fontsize=12)
            g.index = vs[0].index
            edge >> (vs[0], g)
            c = _.C >> grid[vs[1].index, y0]
            c.index = vs[1].index
            edge >> (vs[1], c)
            if len(vs) == 3:
                nc = _.C >> grid[vs[2].index, y0]
                nc.index = vs[2].index
                nc.text("#2", "right", fontsize=SIZE)
                edge >> (vs[2], nc)

                ss = sorted([g, c, nc], key=lambda x: x.index)
                e = edge >> (ss[0], ss[1])
                e2 = edge >> (ss[1], ss[2])
                return (g, c, nc)
            else:
                e = edge >> (g, c)
                return (g, c)

        def func(op, vs, y0, fontsize=12, text_offset=0.3):
            nodes = []
            edges = []
            ds = []
            for (v, style, txt) in vs:
                g = style >> grid[v.index, y0]
                g.index = v.index
                g.text(txt)
                edge >> (v, g)
                nodes.append(g)
            ss = sorted(nodes, key=lambda x: x.index)
            for si, sj in zip(ss[:-1], ss[1:]):
                edges.append(edge >> (si, sj))
                ds.append(sj.index - si.index)
            if len(ss) == 1:
                ss[0].text(op)
            else:
                edges[np.argmin(ds)].text(op, "top", text_offset=0.3, fontsize=fontsize)

            return nodes

        def uncompute(txt, nodes, y):
            indices = [x.index for x in nodes]
            imin = np.min(indices)
            imax = np.max(indices)
            b = box >> grid[imin:imax, y:y]
            b.text(txt, fontsize=16)
            nnodes = []
            for n in nodes:
                edge >> (n, b.pin("top", align=n))
                nn = b.pin("bottom", align=n)
                nn.index = n.index
                nnodes.append(nn)
            return nnodes

        with DynamicShow((10,10), 'fig4.%s'%tp) as ds:
            nodes = []
            n = 0
            y = 0
            z = innode >> grid[n, 0]
            z.text("z", "top", fontsize=SIZE)
            z.index = n
            n += 1
            hz = node >> grid[n, 0]
            hz.text("hz", "top", fontsize=SIZE)
            hz.text("0", fontsize=SIZE)
            hz.index = n
            n += 1
            halfz_power_2 = node >> grid[n, 0]
            halfz_power_2.text("hz_2", "top", fontsize=SIZE)
            halfz_power_2.text("0", fontsize=SIZE)
            halfz_power_2.index = n
            n += 1
            halfz_power_nu = node >> grid[n, 0]
            halfz_power_nu.text("hz_nu", "top", fontsize=SIZE)
            halfz_power_nu.text("0", fontsize=SIZE)
            halfz_power_nu.index = n
            n += 1
            nu = innode >> grid[n, 0]
            nu.text(r"$\nu$", "top", fontsize=SIZE)
            nu.index = n
            n += 1
            fact_nu = node >> grid[n, 0]
            fact_nu.text("fact_nu", "top", fontsize=SIZE)
            fact_nu.text("0", fontsize=SIZE)
            fact_nu.index = n
            n += 1
            k = node >> grid[n, 0]
            k.text("k", "top", fontsize=SIZE)
            k.text("0", fontsize=SIZE)
            k.index = n
            ancs = []
            for i in range(5):
                n += 1
                if i>0:
                    yanc = -4.5
                else:
                    yanc = 0
                ancs.append(node >> grid[n, yanc])
                ancs[-1].text("anc%d"%(i+1), "top", fontsize=SIZE)
                ancs[-1].text("0", fontsize=SIZE)
                ancs[-1].index = n

            n += 1
            out_anc = node >> grid[n, 0]
            out_anc.text("out_anc", "top", fontsize=SIZE)
            out_anc.text("0", fontsize=SIZE)
            out_anc.index = n

            n += 1
            out = innode >> grid[n, 0]
            out.text("out!", "top", fontsize=SIZE)
            out.text("0", fontsize=SIZE)
            out.index = n

            y -= 1.5
            startA = y
            hz, z = instr(r"$\oplus(/2)$", (hz, z), y)
            y -= 1.0
            (halfz_power_nu, hz, nu) = instr(r"$\oplus$(^)", (halfz_power_nu, hz, nu), y)
            y -= 1.0
            (halfz_power_2, hz) = instr(r"$\oplus$(^2)", (halfz_power_2, hz), y)
            (fact_nu, nu) = func("ifactorial", ((fact_nu, _.GATE, "#1"), (nu, _.C, "")), y, text_offset=0.5)
            y -= 1.0
            (ancs[0], halfz_power_nu, fact_nu) = instr(r"$\oplus(/)$", (ancs[0], halfz_power_nu, fact_nu), y)
            y -= 1.0
            (out_anc, ancs[0]) = instr(r"$\oplus$", (out_anc, ancs[0]), y)
            y -= 2.0
            whilestart = y
            (k, ) = func(r"$+1$", ((k, _.GATE, ""),), y)
            y -= 1.5
            start = y
            (ancs[4], k) = instr(r"$\oplus$", (ancs[4], k), y)
            y -= 1.0
            (ancs[4], nu) = instr(r"$\oplus$", (ancs[4], nu), y)
            y -= 1.0
            (ancs[1], k, ancs[4]) = instr(r"$\ominus(*)$", (ancs[1], k, ancs[4]), y)
            y -= 1.0
            (ancs[2], halfz_power_2, ancs[1]) = instr(r"$\plus(*)$", (ancs[2], halfz_power_2, ancs[1]), y)
            stop = y
            d = dashed >> grid[6:11,start:stop]
            d.text("B", "top", fontsize=16)

            y -= 1.5
            (ancs[0], ancs[2], ancs[3]) = func("imul", ((ancs[0], _.GATE, "#1"), (ancs[2], _.C, ""), (ancs[3], _.GATE, "#3")), y)
            y -= 1.0
            (out_anc, ancs[0]) = instr(r"$\oplus$", (out_anc, ancs[0]), y)
            y -= 1.0
            # uncompute
            nodes = [z, hz, halfz_power_2, halfz_power_nu, nu, fact_nu, k]
            nodes.extend(ancs)
            nodes.extend([out_anc, out])

            nodes[6:12] = uncompute("~B", nodes[6:12], y)
            ancs[:] = nodes[7:12]
            y -= 0.2
            whilestop = y
            stopA = y - 0.2
            d = dashed >> grid[0:12.2,startA:stopA]
            d.text("A", "top", fontsize=16)
            d = gray >> grid[5.8:12,whilestart:whilestop]
            x_, y_ = d.pin("top")
            plt.text(x_, y_+0.3, "pre: abs(anc1) > atol && abs(anc4) < atol", va='center', ha='center', fontsize=12, bbox=dict(facecolor='w', lw=0))
            x_, y_ = d.pin("bottom")
            plt.text(x_, y_-0.3, r"post: k != 0", va='center', ha='center', fontsize=12, bbox=dict(facecolor='w', lw=0))
            y -= 1.8
            nodes[-1], nodes[-2] = instr(r"$\oplus$", (out, out_anc), y)
            for anc in ancs[1:]:
                p = node >> grid[anc.index, y]
                p.text("0", fontsize=SIZE)
                edge >> (anc, p)
            # uncompute all
            y -= 1.2
            nodes = nodes[:8] + nodes[-2:]
            nodes[:-1] = uncompute("~A", nodes[:-1], y)

            # end
            y -= 1.5
            for n in nodes:
                if n.index == 0 or n.index == 4 or n.index == 13:
                    p = innode >> grid[n.index, y]
                else:
                    p = node >> grid[n.index, y]
                    p.text("0", fontsize=SIZE)
                edge >> (n, p)

    def fig5(self, tp='pdf'):
        SIZE = 12
        LW = 1.75
        setting.node_setting['lw']=LW
        setting.node_setting['inner_lw']=LW
        edge = EdgeBrush('-', lw=LW)
        innode = NodeBrush('basic', color='#FFFF99')
        node = NodeBrush('basic', color='none')
        grid = Grid([1.2, 0.8])
        dashed = NodeBrush('box', size=(0.6, 0.4), ls="--", roundness=0.15)
        gray = NodeBrush('box', size=(0.6, 0.4), lw=0, color="#CCCCCC", roundness=0.15, zorder=-10)
        box = NodeBrush('box', size=(0.6, 0.4), lw=LW, color="none")
        WIDE = NodeBrush("box", size=(0.5,0.3))

        def func(op, vs, y0, fontsize=12, text_offset=0.3):
            nodes = []
            edges = []
            ds = []
            for (v, style, txt) in vs:
                g = style >> grid[v, y0]
                if style == _.C:
                    g.text(txt, "bottom")
                else:
                    g.text(txt)
                g.index = v
                nodes.append(g)
            ss = sorted(nodes, key=lambda x: x.index)
            for si, sj in zip(ss[:-1], ss[1:]):
                edges.append(edge >> (si, sj))
                ds.append(sj.index - si.index)
            if len(ss) == 1:
                ss[0].text(op)
            else:
                edges[np.argmin(ds)].text(op, "top", text_offset=0.3, fontsize=fontsize)

            return nodes

        with DynamicShow((3,1.5), 'fig5.%s'%tp) as ds:
            plt.text(*grid[0, 0.6], r"z", ha='center', va='center')
            plt.text(*grid[1, 0.6], r"$\nu$", ha='center', va='center')
            plt.text(*grid[2, 0.6], r"out!", ha='center', va='center')
            func("", ((0, _.C, ""), (1, _.C, r""), (2, WIDE, "ibesselj")), 0)

    def fig4gif(self):
        SIZE = 12
        LW = 1.75
        setting.node_setting['lw']=LW
        setting.node_setting['inner_lw']=LW
        edge = EdgeBrush('-', lw=LW)
        innode = NodeBrush('basic', color='#FFFF99')
        node = NodeBrush('basic', color='none')
        grid = Grid([1.2, 0.8])
        dashed = NodeBrush('box', size=(0.6, 0.4), ls="--", roundness=0.15)
        gray = NodeBrush('box', size=(0.6, 0.4), lw=0, color="#CCCCCC", roundness=0.15, zorder=-10)
        box = NodeBrush('box', size=(0.6, 0.4), lw=LW, color="none")
        WIDE = NodeBrush("box", size=(0.5,0.3))
        nodes = {}
        def instr(cum, vs, y0):
            g = WIDE >> grid[nodes[vs[0]].index, y0]
            g.text(cum, fontsize=12)
            g.index = nodes[vs[0]].index
            edge >> (nodes[vs[0]], g)
            c = _.C >> grid[nodes[vs[1]].index, y0]
            c.index = nodes[vs[1]].index
            edge >> (nodes[vs[1]], c)
            if len(vs) == 3:
                nc = _.C >> grid[nodes[vs[2]].index, y0]
                nc.index = nodes[vs[2]].index
                nc.text("#2", "right", fontsize=SIZE)
                edge >> (nodes[vs[2]], nc)

                ss = sorted([g, c, nc], key=lambda x: x.index)
                e = edge >> (ss[0], ss[1])
                e2 = edge >> (ss[1], ss[2])
                nodes[vs[0]] = g
                nodes[vs[1]] = c
                nodes[vs[2]] = nc
            else:
                e = edge >> (g, c)
                nodes[vs[0]] = g
                nodes[vs[1]] = c

        def func(op, vs, y0, fontsize=12, text_offset=0.3):
            edges = []
            ds = []
            for (v, style, txt) in vs:
                g = style >> grid[nodes[v].index, y0]
                g.index = nodes[v].index
                g.text(txt)
                edge >> (nodes[v], g)
                nodes[v] = g
            ss = sorted([nodes[v[0]] for v in vs], key=lambda x: x.index)
            for si, sj in zip(ss[:-1], ss[1:]):
                edges.append(edge >> (si, sj))
                ds.append(sj.index - si.index)
            if len(ss) == 1:
                ss[0].text(op)
            else:
                edges[np.argmin(ds)].text(op, "top", text_offset=0.3, fontsize=fontsize)


        def uncompute(txt, vs, y):
            indices = [nodes[x].index for x in vs]
            imin = np.min(indices)
            imax = np.max(indices)
            b = box >> grid[imin:imax, y:y]
            b.text(txt, fontsize=16)
            for n in vs:
                edge >> (nodes[n], b.pin("top", align=nodes[n]))
                nn = b.pin("bottom", align=nodes[n])
                nn.index = nodes[n].index
                nodes[n] = nn

        with DynamicShow((10,10), 'fig4.gif') as ds:
            y = 0
            inv >> grid[-0.5,-20.7]
            inv >> grid[13.5,-20.7]
            inv >> grid[-0.5,-0.5]
            inv >> grid[13.5,-0.5]
            syms = np.array(['z', 'hz', 'hz_2', 'hz_nu', 'nu', 'fact_nu', 'k', 'anc1', 'anc2', 'anc3', 'anc4', 'anc5', 'out_anc', 'out'])
            for n in [0,1,2,3,4,5,6,7,12,13]:
                s = syms[n]
                if n in [0, 4, 13]:
                    nodes[s] = innode >> grid[n, 0]
                else:
                    nodes[s] = node >> grid[n, 0]
                if not n in [0, 4]:
                    nodes[s].text("0", fontsize=SIZE)
                nodes[s].text(s, "top", fontsize=SIZE)
                nodes[s].index = n
            whilest = [0, 0]
            Ast = [0, 0]
            Bst = [0, 0]
            y = [0]

            def f1():
                y[0] -= 1.5
                Ast[0] = y[0]
                instr(r"$\oplus(/2)$", ('hz', 'z'), y[0])
                y[0] -= 1.0
                instr(r"$\oplus$(^)", ('hz_nu', 'hz','nu'), y[0])
                y[0] -= 1.0
                instr(r"$\oplus$(^2)", ('hz_2', 'hz'), y[0])
                func("ifactorial", (('fact_nu', _.GATE, "#1"), ('nu', _.C, "")), y[0], text_offset=0.5)
                y[0] -= 1.0

                instr(r"$\oplus(/)$", ('anc1', 'hz_nu', 'fact_nu'), y[0])
                for i in [8,9,10,11]:
                    s = syms[i]
                    nodes[s] = node >> grid[i, y[0]]
                    nodes[s].text(s, "top", fontsize=SIZE)
                    nodes[s].text("0", fontsize=SIZE)
                    nodes[s].index = i

                y[0] -= 1.0
                instr(r"$\oplus$", ('out_anc', 'anc1'), y[0])

            def f2():
                y[0] -= 2.0
                whilest[0] = y[0]
                func(r"$+1$", (('k', _.GATE, ""),), y[0])
                y[0] -= 1.5
            def f3():
                Bst[0] = y[0]
                instr(r"$\oplus$", ('anc5', 'k'), y[0])
                y[0] -= 1.0
                instr(r"$\oplus$", ('anc5', 'nu'), y[0])
                y[0] -= 1.0
                instr(r"$\ominus(*)$", ("anc2", 'k', "anc5"), y[0])
                y[0] -= 1.0
                instr(r"$\plus(*)$", ("anc3", 'hz_2', "anc2"), y[0])
                Bst[1] = y[0]

            def f4():
                d = dashed >> grid[6:11,Bst[0]:Bst[1]]
                d.text("B", "top", fontsize=16)

            def f41():
                y[0] -= 1.5
                func("imul", (("anc1", _.GATE, "#1"), ('anc3', _.C, ""), ('anc4', _.GATE, "#3")), y[0])
                y[0] -= 1.0
                instr(r"$\oplus$", ('out_anc', 'anc1'), y[0])

            def f5():
                y[0] -= 1.0
                # uncompute
                uncompute("~B", ['k', 'anc1', 'anc2', 'anc3', 'anc4', 'anc5'], y[0])
                y[0] -= 0.2
                whilest[1] = y[0]

            def f6():
                d = gray >> grid[5.8:12,whilest[0]:whilest[1]]
                x_, y_ = d.pin("top")
                plt.text(x_, y_+0.3, "pre: abs(anc1) > atol && abs(anc4) < atol", va='center', ha='center', fontsize=12, bbox=dict(facecolor='w', lw=0))
                x_, y_ = d.pin("bottom")
                plt.text(x_, y_-0.3, r"post: k != 0", va='center', ha='center', fontsize=12, bbox=dict(facecolor='w', lw=0))
            def f62():
                y[0] -= 1.8
                instr(r"$\oplus$", ('out', 'out_anc'), y[0])
                for anc in ['anc2', 'anc3', 'anc4', 'anc5']:
                    p = node >> grid[nodes[anc].index, y[0]]
                    p.text("0", fontsize=SIZE)
                    edge >> (nodes[anc], p)

            def f61():
                Ast[1] = y[0] - 0.2
                d = dashed >> grid[0:13,Ast[0]:Ast[1]]
                d.text("A", "top", fontsize=16)

            def f7():
                # uncompute all
                y[0] -= 1.2
                uncompute("~A", syms[[0,1,2,3,4,5,6,7,12]], y[0])

            def f8():
                # end
                y[0] -= 1.5
                for n in nodes.values():
                    if n.index == 0 or n.index == 4 or n.index == 13:
                        p = innode >> grid[n.index, y[0]]
                        edge >> (n, p)
                    elif n.index>=8 and n.index<=11:
                        pass
                    else:
                        p = node >> grid[n.index, y[0]]
                        p.text("0", fontsize=SIZE)
                        edge >> (n, p)
                print(y[0])

            #f1()
            #f2()
            #f3()
            #f4()
            #f41()
            #f5()
            #f6()
            #f61()
            #f62()
            #f7()
            #f8()
            ds.steps = [f1, f2, f3, f4, f41, f5, f6, f61, f62, f7, f8]

    def fig6(self, tp="pdf"):
        SIZE = 12
        LW = 1.75
        setting.node_setting['lw']=LW
        setting.node_setting['inner_lw']=LW
        setting.edge_setting['doubleline_space']=0.03
        edge = EdgeBrush('-', lw=LW)
        edge2 = EdgeBrush('=', lw=1.25)
        innode = NodeBrush('basic', color='#FFFF99')
        node = NodeBrush('basic', color='none')
        graynode = NodeBrush('tn.mpo', color='#999999')
        grid = Grid([1.2, 0.8])
        dashed = NodeBrush('box', size=(0.6, 0.4), ls="--", roundness=0.15)
        gray = NodeBrush('box', size=(0.6, 0.4), lw=0, color="#CCCCCC", roundness=0.15, zorder=-10)
        box = NodeBrush('box', size=(0.6, 0.4), lw=LW, color="none")
        WIDE = NodeBrush("box", size=(0.5,0.3))
        inv = NodeBrush("invisible")
        nodes = {}
        doubleline=[False, False, False, False]
        def instr(cum, vs, y0):
            g = WIDE >> grid[nodes[vs[0]].index, y0]
            g.text(cum, fontsize=12)
            g.index = nodes[vs[0]].index
            edge >> (nodes[vs[0]], g)
            c = _.C >> grid[nodes[vs[1]].index, y0]
            c.index = nodes[vs[1]].index
            edge >> (nodes[vs[1]], c)
            if len(vs) == 3:
                nc = _.C >> grid[nodes[vs[2]].index, y0]
                nc.index = nodes[vs[2]].index
                nc.text("#2", "right", fontsize=SIZE)
                edge >> (nodes[vs[2]], nc)

                ss = sorted([g, c, nc], key=lambda x: x.index)
                e = edge >> (ss[0], ss[1])
                e2 = edge >> (ss[1], ss[2])
                nodes[vs[0]] = g
                nodes[vs[1]] = c
                nodes[vs[2]] = nc
            else:
                e = edge >> (g, c)
                nodes[vs[0]] = g
                nodes[vs[1]] = c

        def func(op, vs, y0, fontsize=12, text_offset=0.3, node=node):
            edges = []
            ds = []
            for (v, style, txt) in vs:
                g = style >> grid[nodes[v].index, y0]
                g.index = nodes[v].index
                g.text(txt)
                (edge2 if doubleline[nodes[v].index] else edge) >> (nodes[v], g)
                nodes[v] = g
            ss = sorted([nodes[v[0]] for v in vs], key=lambda x: x.index)
            for si, sj in zip(ss[:-1], ss[1:]):
                edges.append(edge >> (si, sj))
                ds.append(sj.index - si.index)
            if len(ss) == 1:
                ss[0].text(op)
            else:
                edges[np.argmin(ds)].text(op, "top", text_offset=0.3, fontsize=fontsize)


        def uncompute(txt, vs, y):
            indices = [nodes[x].index for x in vs]
            imin = np.min(indices)
            imax = np.max(indices)
            b = box >> grid[imin:imax, y:y]
            b.text(txt, fontsize=16)
            for n in vs:
                edge >> (nodes[n], b.pin("top", align=nodes[n]))
                nn = b.pin("bottom", align=nodes[n])
                nn.index = nodes[n].index
                nodes[n] = nn

        with DynamicShow((7,5), 'fig6.%s'%tp) as ds:
            grid.offset = (0, -1)
            syms = np.array(['x1', 'x2', 'x3', 'x4'])
            for n in range(4):
                s = syms[n]
                nodes[s] = node >> grid[n, 0]
                nodes[s].text(r"$x_{%d}$"%(n+1), fontsize=SIZE)
                nodes[s].index = n
            whilest = [0, 0]
            Ast = [0, 0]
            Bst = [0, 0]
            y = [0]

            y[0] -= 1.2
            Ast[0] = y[0]
            func("", (("x1", _.C, ""), ('x2', _.GATE, "A")), y[0])
            func("", (('x3', _.GATE, "B"),), y[0])

            y[0] -= 1.0
            func("", (("x2", _.GATE, "C"), ('x3', _.GATE, "")), y[0])
            Ast[1] = y[0]
            d = dashed >> grid[0.2:2,Ast[0]:Ast[1]]
            d.text("X", "left", fontsize=16)

            y[0] -= 1.0
            func("", (("x3", _.C, ""), ('x4', _.GATE, r"$\oplus$")), y[0])

            y[0] -= 1.0
            Bst[0] = y[0]
            func(r"", (("x2", _.GATE, "~C"), ('x3', _.GATE, "")), y[0])

            y[0] -= 1.0
            func("", (("x1", _.C, ""), ('x2', _.GATE, "~A")), y[0])
            func("", (('x3', _.GATE, "~B"),), y[0])
            Bst[1] = y[0]
            d = dashed >> grid[0.2:2,Bst[0]:Bst[1]]
            d.text("~X", "left", fontsize=16)

            y[0] -= 1.2
            for n in range(4):
                ni = node >> grid[n, y[0]]
                edge >> (ni, nodes[syms[n]])

            doubleline[:]=[True, False, True]
            grid.offset = (6, 0)
            y[0] = 0
            syms = np.array(['x1t3', 'x4', 'x5tn'])
            texts = np.array([r'$x_{1\colon 3}$', r'$x_{4}$', r'$x_{5\colon n}$'])
            for n in range(3):
                s = syms[n]
                nodes[s] = node >> grid[n, 0]
                nodes[s].text(texts[n], fontsize=12 if n==1 else 10)
                nodes[s].index = n
            whilest = [0, 0]
            Ast = [0, 0]
            Bst = [0, 0]
            y = [0]

            y[0] -= 1.2
            Ast[0] = y[0]
            func("", (('x1t3', _.GATE, "X"),), y[0])

            y[0] -= 1.0
            func("", (("x1t3", _.C, ""), ('x4', _.GATE, r"$\oplus$")), y[0])

            y[0] -= 1.0
            func("", (('x1t3', graynode, "~X"),), y[0])
            Ast[1] = y[0]
            d = dashed >> grid[0:1,Ast[0]:Ast[1]]
            d.text("Y", "left", fontsize=16)

            y[0] -= 1.0
            func(r"", (("x4", _.C, ""), ('x5tn', _.WIDE, "$f(x_4)$")), y[0])

            y[0] -= 1.0
            Bst[0] = y[0]
            func("", (('x1t3', graynode, "X"),), y[0])

            y[0] -= 1.0
            func("", (("x1t3", _.C, ""), ('x4', _.GATE, r"$\oplus$")), y[0])

            y[0] -= 1.0
            func("", (('x1t3', _.GATE, "~X"),), y[0])
            Bst[1] = y[0]
            d = dashed >> grid[0:1,Bst[0]:Bst[1]]
            d.text("~Y", "left", fontsize=16)

            y[0] -= 1.2
            for n in range(3):
                ni = node >> grid[n, y[0]]
                (edge if n==1 else edge2) >> (ni, nodes[syms[n]])
            plt.text(-1.3, 0, "(a)", fontsize=14)
            plt.text(4.7, 0, "(b)", fontsize=14)

    def fig7(self, tp='pdf'):
        data = np.loadtxt("../codes/bench_graphembedding.dat")/1000
        plt.rcParams['xtick.labelsize'] = 12
        plt.rcParams['ytick.labelsize'] = 12
        with DataPlt(filename="fig7.%s"%tp, figsize=(8,4)) as dp:
            ax = plt.subplot(131)
            xs = np.arange(1,11)
            plt.ylabel(r"time/$\mu$s")
            cornertex("(a)", ax)
            plt.plot(xs, data[:,0])
            plt.plot(xs, data[:,1])
            plt.plot(xs, data[:,4])
            plt.xlim(1, 10)
            plt.ylim(0, 30)
            plt.legend(["NiLang (Call)", "NiLang (UnCall)", "Julia"], fontsize=12, loc="upper right")
            plt.xlabel("dimension")
            ax = plt.subplot(132)
            cornertex("(b)", ax)
            plt.plot(xs, data[:,2])
            plt.plot(xs, data[:,5])
            plt.xlim(1, 10)
            plt.legend(["NiLang", "ForwardDiff"], fontsize=12, loc="upper right")

            plt.ylim(0, 200)
            plt.xlabel("dimension")
            plt.ticklabel_format(axis="y", style="sci", scilimits=(0,0))

            ax = plt.subplot(133)
            cornertex("(c)", ax)
            plt.plot(xs, data[:,3])
            plt.plot(xs, data[:,6])
            plt.legend(["NiLang", "ForwardDiff"], fontsize=12, loc="upper right")
            plt.xlim(1, 10)
            plt.ylim(0, 50000)
            plt.xlabel("dimension")
            #plt.yticks([1e4*i for i in range(1,6)], [r"$%s \times 10^4$"%i for i in range(1,6)], fontsize=12)
            plt.ticklabel_format(axis="y", style="sci", scilimits=(0,0))
            plt.tight_layout()

    def fig8(self, tp='pdf'):
        data = np.loadtxt("../codes/bench_graphembedding.dat")/1000
        with DataPlt(filename="fig7.%s"%tp, figsize=(6,6)) as dp:
            ax1 = plt.subplot(311)
            xs = np.arange(1,11)
            plt.ylabel(r"time/$\mu$s")
            cornertex("(a)", ax1)
            plt.plot(xs, data[:,0])
            plt.plot(xs, data[:,1])
            plt.plot(xs, data[:,4])
            plt.xlim(1, 10)
            plt.ylim(0, 20)
            plt.xticks([])
            plt.legend(["NiLang (Call)", "NiLang (UnCall)", "Julia"], fontsize=12, loc="upper left", bbox_to_anchor=(1, 1), frameon=False)
            ax2 = plt.subplot(312, sharex=ax1)
            cornertex("(b)", ax2)
            plt.plot(xs, data[:,2])
            plt.plot(xs, data[:,5])
            plt.legend(["NiLang", "ForwardDiff"], fontsize=12, loc="upper left", bbox_to_anchor=(1, 1), frameon=False)
            plt.xticks([])
            plt.ylabel(r"time/$\mu$s")

            plt.ylim(0, 200)

            ax3 = plt.subplot(313)
            cornertex("(c)", ax3)
            plt.plot(xs, data[:,3]/1000)
            plt.plot(xs, data[:,6]/1000)
            plt.legend(["NiLang", "ForwardDiff"], fontsize=12, loc="upper left", bbox_to_anchor=(1, 1), frameon=False)
            plt.ylim(0, 50)
            plt.xlim(1, 10)
            plt.ylabel(r"time/ms")
            plt.xlabel("dimension")
            plt.xticks([1, 5, 10])
            #plt.yticks([1e4*i for i in range(1,6)], [r"$%s \times 10^4$"%i for i in range(1,6)], fontsize=12)
            #plt.ticklabel_format(axis="y", style="sci", scilimits=(0,0))
            plt.tight_layout(w_pad=-0.1)


fire.Fire(PLT())
