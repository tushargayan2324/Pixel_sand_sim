using GLMakie

GLMakie.activate!(inline=false)

# data = Observable(fill!(Matrix{Bool}(undef,30,30),true)) 

mat_size = 10

H = rand((0,1), mat_size,mat_size)

#rotr90(H)

data = Observable(H) 

#rotl90(H)


f, ax, im = heatmap(data, colormap = [:white,:black]; axis = (; aspect = 1,xzoomlock=true,yzoomlock=true), ) 

# added zoomlock for no scroll zooms in heatmap

########################################################
# define buttons 
########################################################

f[2, 1] = buttongrid = GridLayout(tellwidth = false)

button = buttongrid[1,1] = Button(f, label="reset")


on(button.clicks) do click
    data[] .= true
    #data[][1,1] = false
    notify(data)
end


########################################################
# styling
########################################################


hlines!(0.5:mat_size+0.5, color = :gray50)
vlines!(0.5:mat_size+0.5, color = :gray50)

hidedecorations!(ax)
hidexdecorations!(ax, ticks = false)
hideydecorations!(ax, ticks = false)


################################################################
# Axis interactions with mouse
################################################################
interacted_with = Set{Point2{Int}}()

register_interaction!(ax, :toggler) do event::MouseEvent, ax
    if event.type === MouseEventTypes.leftdown
        empty!(interacted_with)
    elseif event.type in (MouseEventTypes.leftclick, MouseEventTypes.leftdrag)
        index = round.(Int, event.data)
        #print(index)
        if typeof(index[1]) != Int 
            return
        end
        index in interacted_with && return
        push!(interacted_with, index)
        data[][index...] = !data[][index...]
        notify(data)
    end
end

## deactivate interaction for drag zoom
deactivate_interaction!(ax, :rectanglezoom,)

typeof(error) == NaN

# update rules
# data[] .= fn(...)
# notify(data)

# The following function is written for matrix in normal way// The makie takes input in weird way...
function update_rule(dat_matx)
    dat_matx = rotr90(dat_matx)
    n = size(dat_matx)[1]
    for i=n:-1:1
        for j=n:-1:1
            if i<n && dat_matx[i,j] == true && dat_matx[i+1,j] == false #if down empty, move below
                dat_matx[i+1,j] = true; dat_matx[i,j] = false #; break
            
            # elseif j<n && i<n && dat_matx[i+1,j+1] == false #move down right
            #     dat_matx[i+1,j+1] = true; dat_matx[i,j] = false; break
            
            # elseif j>1 && i<n && dat_matx[i+1,j-1] == false #move down left
            #     dat_matx[i+1,j-1] = true; dat_matx[i,j] = false; break

            elseif i<n && j>1 && j<n && dat_matx[i,j]*dat_matx[i+1,j] == true && (1-dat_matx[i+1,j-1])*(1-dat_matx[i+1,j+1]) == true #both sides below are empty, move randomly
                dat_matx[i+1,rand([j-1,j+1])] = true; dat_matx[i,j] = false; break

            end
        end
    end
    
    return rotl90(dat_matx)    
end

M = rand((0,1), 3,3)

update_rule(M)


screen = display(f)

while isopen(screen)#Bool(stop_butn[])==true
    data[] = update_rule(data[])
    notify(data)

    sleep(1)       
end

while true #Bool(stop_butn[])==true
    data[] = update_rule(data[])
    notify(data)

    sleep(1)       
end




display(f)





##to see all the interactions of ax (axis)
#interactions(ax) 