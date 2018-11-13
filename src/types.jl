abstract type Node  end

mutable struct EnergySystem
    model
    solver
    buses::Dict{String,Node}
    function Bus(solver)
        buses=Dict{String,Node}()
        if solver
            model=JuMP.model(solver=solver)
        else
            solver=GLPKMathMIP()
            model=JuMP.model(solver)
        new(model,solver,buses)
    end
end

addbus!(es::EnergySystem,bus::Bus)=push!(es.buses,Pair(bus.label,bus))


function addbus!(es::EnergySystem,buses...)
    for bus in buses
        push!(es.buses,Pair(bus.label,bus))
    end
end

mutable struct Bus<:Node
    label::String
    bustype::Symbol
    input::Dict{String,Node}
    output::Dict{String,Node}
    function Bus(label)
        input=Dict{String,Node}()
        output=Dict{String,Node}()
        Bus(label,bustype)=new(label,bustype,input,output)
    end
end

function addnode!(bus::Bus;input::Node=nothing,output::Node=nothing)
    if input!=nothing
        push!(bus.input,Pair(input.label,input))

    end
    if output!=nothing
        push!(bus,output,Pair(input.label,output))
    end
end


struct Source{} <: Node
    label::String
    bus::Bus
    energytype::Symbol
    price
    quantity
    
    function Source(label,bus,energytype)=new(label,bus,energytype,nothing,nothing)
end

struct Sink <:Node
    label::String
    bus::Bus
    energytype::Symbol
    price
    quantity
    function Sink(label,bus,energytype)=new(label,bus,energytype,nothing,nothing)
end

abstract Transformer <: Node end

struct GasTurbine <: Transformer
    label::String
    pwl::Function
    gas::Bus
    ht::Bus
    lt::Bus
    elec
    hienergy
    loenergy
    function GasTurbine(label;input=nothing,output1=nothing,output2=nothing)
        label=label
        gas=input
        ht=output1
        lt=output2
    end
end
    
