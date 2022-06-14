cd(raw"C:\Users\Ben\Documents\GitHub\LabToolKit")

using Pkg
Pkg.activate(".")

using Genie, Genie.Router

Genie.newapp_webservice("LabToolKitApp")

cd("..")

Genie.newapp_mvc("LabToolKitMVC")

