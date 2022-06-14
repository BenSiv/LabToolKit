using Pkg
Pkg.activate("C:/Users/Ben/Documents/GitHub/LabToolKit")

using Gtk

Window = GtkWindow("Ligation calculator", 400, 600)

vBox = GtkBox(:v)
push!(Window, vBox)

Inputs = GtkLabel("Parameter inputs")
push!(vBox, Inputs)


# Concentrations Input

# Vector concentration
VecConcBox = GtkBox(:h)
push!(vBox, VecConcBox)

VecConcBoxLabel = GtkLabel("Vector concentration (ng/μl)")
push!(VecConcBox, VecConcBoxLabel)

VecConc = GtkEntry()
push!(VecConcBox, VecConc)

# Insert concentration
InsConcBox = GtkBox(:h)
push!(vBox, InsConcBox)

InsConcLabel = GtkLabel("Insert concentration (ng/μl)")
push!(InsConcBox, InsConcLabel)

InsConc = GtkEntry()
push!(InsConcBox, InsConc)


# Lengths Input

# Vector length
VecLengthBox = GtkBox(:h)
push!(vBox, VecLengthBox)

VecLengthLabel = GtkLabel("Vector length (bp)")
push!(VecLengthBox, VecLengthLabel)

VecLength = GtkEntry()
push!(VecLengthBox, VecLength)

# Vector length
InsLengthBox = GtkBox(:h)
push!(vBox, InsLengthBox)

InsLengthLabel = GtkLabel("Insert length (bp)")
push!(InsLengthBox, InsLengthLabel)

InsLength = GtkEntry()
push!(InsLengthBox, InsLength)

# Insert/Vector ratio
RatioBox = GtkBox(:h)
push!(vBox, RatioBox)

RatioLabel = GtkLabel("Insert/Vector ratio")
push!(RatioBox, RatioLabel)

Ratio = GtkEntry()
push!(RatioBox, Ratio)


# Submit button
Button = GtkButton("Submit")
push!(vBox, Button)


# Ligation caclulation

using DataFrames, CSV

"""
    LigationCalc(VecConc, InsConc, VecMass, VecLength, InsLength, Ratio, TotalVolume)
    
    Returns a DataFrame of the reaction volumes in μl
"""
function LigationCalc(VecConc, InsConc, VecLength, InsLength, Ratio, TotalVolume = 10)
    
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


using YAML
function on_button_clicked(w)
    # println("The button has been clicked")
    Input = Dict(
        "VecConc" => parse(Int64, get_gtk_property(VecConc, :text, String) ),
        "InsConc" => parse(Int64, get_gtk_property(InsConc, :text, String) ),
        "VecLength" => parse(Int64, get_gtk_property(VecLength, :text, String) ),
        "InsLength" => parse(Int64, get_gtk_property(InsLength, :text, String) ),
        "Ratio" => parse(Int64, get_gtk_property(Ratio, :text, String) )
    )

    YAML.write_file("Input.yml", Input)
    Input = YAML.load_file("Input.yml")
    
    Results = LigationCalc(Input["VecConc"], Input["InsConc"], Input["VecLength"], Input["InsLength"], Input["Ratio"], 10)

    # Export output results as a CSV file
    CSV.write("Results.csv", Results)
end

signal_connect(on_button_clicked, Button, "clicked")  

Window = @Window(tv, "Results")
showall(Window)

if !isinteractive()
    c = Condition()
    signal_connect(Window, :destroy) do widget
        notify(c)
    end
    @async Gtk.gtk_main()
    wait(c)
end