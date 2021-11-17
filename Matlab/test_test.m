x = [1 2];
y = [4 4];
plot(x,y);
xlim([0 100])
ylim([2.5 4])
xlabel('Iteration')
ylabel('Approximation for \pi')

linkdata on

denom = 1;
k = -1;
for t = 3:1000
    denom = denom + 2;
    x(t) = t;
    y(t) = 4*(y(t-1)/4 + k/denom);
    k = -k;
end