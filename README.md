# Alignment Wheel Maker
Generates optimal Rock-Paper-Scissors wheels based on lists of justifications.

Often in Brikwars games with lots of people I'll want to create an alignment wheel with rivalries/allies so that you only have to defeat 2 enemies instead of all n-1 opponents. This led to me creating alignment wheels where I would manually place and justify each leap in the graph. Then I would rearrange and pick at it for hours until I was happy with it. Adding in a new team basically meant starting over.

So I made a wheel-maker program in Processing that allows me to just input a list of rivalries (and their relative hatred) and the program will auto-create a wheel for me. Basically you have a collection of unorganized nodes in a graph. Fill in as many edges as you can, then the program does the rest. Here's a silly example:

![](https://imgur.com/delL76X.png)

And the relevant "edges" that I put in:
- Fire -> Plant, 10, "Burns"
- Fire -> Lisa Frank, 10, "Burns"
- Plant -> Stone, 10, "Erodes"
- Plant -> Lisa Frank, 3, "Dirty"
- Plant -> Vacuum, 5, "Fills it"
- Plant -> Electricity, 8, "Draws Power"
- Plant -> Water, 10, "Drinks"
- Stone -> Fire, 8, "Unburnable"
- Stone -> Lisa Frank, 3, "Drab"
- Stone -> Vacuum, 10, "Fills it"
- Stone -> Electricity, 10, "Nonconductive"
- Lisa Frank -> Plant,  3, "Use as paper"
- Lisa Frank -> Stone,  10, "Prettier"
- Lisa Frank -> Vacuum, 10, "Antithesis"
- Lisa Frank -> Electricity,  3, "Better Art"
- Vacuum -> Fire, 10, "Extinguishes"
- Vacuum -> Plant, 8, "Strangles"
- Vacuum -> Lisa Frank, 10, "Antithesis"
- Vacuum -> Electricity, 8, "Nonconductive"
- Electricity -> Plant, 6, "High Water Content"
- Electricity -> Lisa Frank, 6, "Lightning's cooler"
- Electricity -> Water, 10, "Classic Zap-Zap"
- Water -> Fire, 10, "Extinguishes"
- Water -> Stone, 10, "Erodes"
- Water -> Lisa Frank, 6, "Ruins colors"
- Water -> Vacuum, 5, "Fills it"

With those values a theoretical optimal score would be 136, so the best real score of 125 is pretty good. This program does run through every possible permutation of the wheel, including number of hops, using a heavily modified Steinhaus–Johnson–Trotter algorithm. Then it sorts all the results and displays the optimal layout. You can scroll through the other layouts, which is helpful when you want to see other near-optimal solutions that may be more aesthetically pleasing.
