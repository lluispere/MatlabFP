function PWW = calcularPWW(fp,stat)

PWW = fp.calculatePrimitivesRelationProb(stat);

if PWW < realmin,
    PWW = realmin;
end