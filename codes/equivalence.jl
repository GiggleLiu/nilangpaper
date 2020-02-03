function loss(a, b, c, d)
    y1 = f1(d, c)
    y2 = f2(y1, b)
    f3(y2, a)
end

# y1, y2 zero cleared.
@i function loss(a, b, c, d, y1, y2, loss)
    y1 += f1(d, c)
    y2 += f2(y1, b)
    loss += f3(y2, a)
end
