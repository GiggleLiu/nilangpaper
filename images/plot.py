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
        setting.node_setting['lw']=2
        setting.node_setting['inner_lw']=2
        edge = EdgeBrush('-', lw=2)
        innode = NodeBrush('basic', color='#FFFF99')
        node = NodeBrush('basic', color='none')
        grid = Grid([1.2, 0.8])
        dashed = NodeBrush('box', size=(0.6, 0.4), ls="--", roundness=0.15)
        gray = NodeBrush('box', size=(0.6, 0.4), lw=0, color="#CCCCCC", roundness=0.15, zorder=-10)
        box = NodeBrush('box', size=(0.6, 0.4), lw=2, color="none")
        WIDE = NodeBrush("box", size=(0.6,0.3))
        def instr(cum, vs, y0):
            g = WIDE >> grid[vs[0].index, y0]
            g.text(cum, fontsize=12)
            g.index = vs[0].index
            edge >> (vs[0], g)
            c = _.C >> grid[vs[1].index, y0]
            c.index = vs[1].index
            edge >> (vs[1], c)
            if len(vs) == 3:
                nc = _.NC >> grid[vs[2].index, y0]
                nc.index = vs[2].index
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
            out = node >> grid[n, 0]
            out.text("out", "top", fontsize=SIZE)
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
            y -= 0.2
            whilestop = y
            stopA = y - 0.2
            d = dashed >> grid[0:13,startA:stopA]
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

fire.Fire(PLT())
