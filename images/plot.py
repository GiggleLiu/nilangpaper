#!/usr/bin/env python
import fire
from plotlib import *
from viznet import *
import numpy as np

class PLT(object):
    def fig1(self, tp='pdf'):
        data = np.loadtxt("train1.dat")
        data2 = np.loadtxt("train.dat")
        L = len(data)
        with DataPlt(filename="fig1.%s"%tp, figsize=(5,4)) as dp:
            plt.plot(range(1,L+1), data, lw=2)
            plt.plot(range(1,L+1), data2, lw=2)
            plt.legend(["$y_1$", "$f_1$", "$y_2$", "$f_2$"], fontsize=16)
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

fire.Fire(PLT())
