#!/usr/bin/env python
import fire
from plotlib import *
from viznet import *
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


fire.Fire(PLT())
