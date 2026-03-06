
# Installation
sudo apt install yosys

___

# Run
yosys expose.ys

___

I also committed the output file [here](https://github.com/LukeAnger1/vicoco/blob/Example/Port_exposing/example/exposed_design.v) so no code needs to be run.

Configure the [expose.ys](https://github.com/LukeAnger1/vicoco/blob/Example/Port_exposing/example/expose.ys).

___

# Proof of concept

The lines in recursive_modules.v L253-L259 [here](https://github.com/LukeAnger1/vicoco/blob/Example/Port_exposing/example/recursive_modules.v#L253-L259), shows the parameters to the modules.

The exposed_design.v L482 [here](https://github.com/LukeAnger1/vicoco/blob/Example/Port_exposing/example/exposed_design.v#L482) shows how internal signals were exposed.

___

# TODO

1. Do this recursively
2. Figure out naming conventions for the ports. We will be generating new ones and need to make sure they don't intersect with client-named ports. I would suggest limiting the port names the client can use for simplicity. 
