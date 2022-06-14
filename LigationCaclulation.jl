cd(raw"C:\Users\Ben\Documents\GitHub\LabToolKit")

using Pkg
Pkg.activate(".")

# Ligation caclulation

using DataFrames

"""
    LigationCalc(VecConc, InsConc, VecMass, VecLength, InsLength, Ratio, TotalVolume)
    
    Returns a DataFrame of the reaction volumes in μl
"""
function LigationCalc(VecConc, InsConc, VecLength, InsLength, Ratio = 5, TotalVolume = 10)
    
    InsVecRatio = (VecConc/InsConc)*(InsLength/VecLength)*Ratio

    BufferVol = TotalVolume/5
    LigaseVol = TotalVolume/20

    LeftVol = TotalVolume - BufferVol - LigaseVol

    VecVol = round(LeftVol/(InsVecRatio+1),digits = 1)
    InsVol = round(InsVecRatio*VecVol, digits = 1)

    ReactionPrep = DataFrame(Substence = ["Insert", "Vector", "Buffer", "Ligase"],
                             Volume = [InsVol, VecVol, BufferVol, LigaseVol])

    return ReactionPrep
end


# Cucumber Cas9 SP1 + eYGFPuv
LigationCalc(12, 29, 14916, 2051, 5, 10)