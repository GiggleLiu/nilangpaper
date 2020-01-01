#!/usr/bin/env python
import fire
from plotlib import *

class PLT(object):
    def fig1(self, tp='pdf'):
        data = np.loadtxt("../../../data/exp_train1.dat")
        data2 = np.loadtxt("../../../data/exp_train2.dat")
        L = len(data)
        with DataPlt(filename="fig1.%s"%tp, figsize=(5,4)) as dp:
            plt.plot(range(1,L+1), data, lw=2)
            plt.plot(range(1,L+1), data2, lw=2)
            plt.legend(["$y_1$", "$f_1$", "$y_2$", "$f_2$"])
            plt.ylim(0,4)
            plt.xlim(0,30)
            plt.tight_layout()

fire.Fire(PLT())
