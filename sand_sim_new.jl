using GLMakie

GLMakie.activate!(inline=false)

data = Observable(fill!(Matrix{Bool}(undef,30,30),true)) 

f, ax, im = heatmap(data, colormap = [:black, :white]; axis = (; aspect = 1,xzoomlock=true,yzoomlock=true), ) 

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


hlines!(0.5:30.5, color = :gray50)
vlines!(0.5:30.5, color = :gray50)

hidedecorations!(ax)
hidexdecorations!(ax, ticks = false)
hideydecorations!(ax, ticks = false)

## The following is for highlighting the pixels you want

#x1,x2 = 2.06, 3.06
#y1,y2 = 1.06,1.06

#lines!([x1,x2],[y1,y2], color = :green)

#a,b = 6,7

#xs = [a-1.47,a-0.47,a-0.47,a-1.47,a-1.47]
#ys = [b-1.47,b-1.47, b-0.47 ,b-0.47,b-1.47]


#lines!(xs,ys, color = :green)

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

function update_rule(dat_matx)
    dat_matx = rotr90(dat_matx) #Makie takes input as rotated matrix...hence transformation to usual matrix notation
    n = size(dat_matx)[1]
    for i=n:-1:1
        for j=n:-1:1
            if dat_matx[i,j] == false
                continue
            end

            if i<n && dat_matx[i+1,j] == false #if down empty, move below
                dat_matx[i+1,j] = true; dat_matx[i,j] = false ; continue
            
            elseif j<n && i<n && j>1 && dat_matx[i+1,j] == true && dat_matx[i+1,j-1] == true && dat_matx[i+1,j+1] == false #move down right
                dat_matx[i+1,j+1] = true; dat_matx[i,j] = false; continue
            
            elseif j>1 && j<n && i<n && dat_matx[i+1,j] == true && dat_matx[i+1,j+1] == true && dat_matx[i+1,j-1] == false #move down left
                dat_matx[i+1,j-1] = true; dat_matx[i,j] = false; continue

            elseif i<n && j>1 && j<n && dat_matx[i,j]*dat_matx[i+1,j] == true && (1-dat_matx[i+1,j-1])*(1-dat_matx[i+1,j+1]) == true #both sides below are empty, move randomly
                dat_matx[i+1,rand([j-1,j+1])] = true; dat_matx[i,j] = false ; continue

            end
        end
    end
    
    return rotl90(dat_matx) #transform back to makie's way of handling
end


function update_rule_new(dat_matx)
    dat_matx = rotr90(dat_matx) #Makie takes input as rotated matrix...hence transformation to usual matrix notation
    n = size(dat_matx)[1]
    #n = size(dat_matx)[2]
    for i=1:n#n:-1:1
        for j=1:n#n:-1:1
            if dat_matx[i,j] == false
                continue
            end
            
            if i<n && dat_matx[i+1,j] == false #if down empty, move below
                dat_matx[i+1,j] = true; dat_matx[i,j] = false; continue
            
            
            # if i<n && j>1 && j<n && dat_matx[i,j]*dat_matx[i+1,j] == true && (1-dat_matx[i+1,j-1])*(1-dat_matx[i+1,j+1]) == true #both sides below are empty, move randomly
            #     l = rand((j-1,j+1))
            #     dat_matx[i+1,l] = true; dat_matx[i,j] = false; println("Yes")
            # end

            elseif i<n && j>1 && j<n && dat_matx[i+1,j] == true && dat_matx[i+1,j-1] == false && dat_matx[i+1,j+1] == false #both sides below are empty, move randomly
                l = rand((j-1,j+1))
                dat_matx[i+1,l] = true; dat_matx[i,j] = false; println("Yes"); continue
            end


        end
    end

    # for i=n:-1:1
    #     for j=n:-1:1
    #         # if i<n && dat_matx[i,j] == true && dat_matx[i+1,j] == false #if down empty, move below
    #         #     dat_matx[i+1,j] = true; dat_matx[i,j] = false #; break
            
    #         if j<n && i<n && dat_matx[i+1,j+1] == false #move down right
    #             dat_matx[i+1,j+1] = true; dat_matx[i,j] = false; break
            
    #         elseif j>1 && i<n && dat_matx[i+1,j-1] == false #move down left
    #             dat_matx[i+1,j-1] = true; dat_matx[i,j] = false; break

    #         # elseif i<n && j>1 && j<n && dat_matx[i,j]*dat_matx[i+1,j] == true && (1-dat_matx[i+1,j-1])*(1-dat_matx[i+1,j+1]) == true #both sides below are empty, move randomly
    #         #     dat_matx[i+1,rand([j-1,j+1])] = true; dat_matx[i,j] = false; break

    #         end
    #     end
    # end


    return rotl90(dat_matx) #transform back to makie's way of handling
end

# update rules
# data[] .= fn(...)
# notify(data)

print(1)

screen = display(f)

while isopen(screen)#Bool(stop_butn[])==true
    data[] = update_rule(data[])
    notify(data)

    sleep(1)       
end

# Problem in the control flow. Need to fix the way each particle is handled. And show one update of that pixel per turn.


display(f)

##to see all the interactions of ax (axis)

#interactions(ax) 