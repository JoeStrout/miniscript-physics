# miniscript-physics
### 2D physics package for MiniScript (especially Mini Micro)

This is a very early project to create a 2D physics package for [MiniScript](https://miniscript.org).  Initially we are targeting [Mini Micro](https://miniscript.org/MiniMicro/), though it should work with [Soda](https://github.com/JoeStrout/soda) too.

The goal is to produce enough of a physics engine to support games like _Angry Birds_ and _Crush the Castle_.

## Current State

A very basic foundation has been laid, including calculating linear and angular momentum.  Collisions can be detected between simple (rectangular) physics bodies, but we do not yet have any collision response.  (Colliding physics bodies are tinted red for now.)

The test program shows two dynamic blocks falling onto one giant static block (the ground).  But because there is no collision response, the smaller blocks just fall right through the ground and keep on accelerating downward forever.

## Help Wanted

Help in this project is very much appreciated!  Please see the [open issues](https://github.com/JoeStrout/miniscript-physics/issues) and pitch in where you can.