import pdb, pytest
import torch

def btorch(n):
    ts0 = torch.zeros(1, dtype=torch.float64, requires_grad=True)
    one = torch.ones(1, dtype=torch.float64, requires_grad=True)

    ts = ts0
    for i in range(n):
        ts = ts + one
    ts.sum().backward()

@pytest.mark.parametrize('i', range(1,21))
def test_torch(benchmark, i):
    benchmark(btorch, i)
