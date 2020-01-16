import pdb, pytest
import tensorflow as tf

def btf(n):
    i = tf.constant(0)
    N = tf.constant(n)
    x = tf.constant(0.0, dtype='float64')
    one = tf.constant(1.0, dtype='float64')

    def while_condition(i, x, one):
        return tf.less(i, N)
    def body(i, x, one):
        return [tf.add(i, 1), tf.add(x, one), one]

    i_, x_, one_ = tf.while_loop(while_condition, body, [i, x, one])
    gx = tf.gradients(x_, x)
    gone = tf.gradients(x_, one)

    with tf.Session() as sess:
        sess.run([gx, gone])

@pytest.mark.parametrize('i', range(1,21))
def test_tf(benchmark, i):
    benchmark(btf,i)
