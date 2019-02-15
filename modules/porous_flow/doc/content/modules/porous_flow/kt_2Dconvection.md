# Worked example of Kuzmin-Turek stabilization: 2D thermal convection

This page is part of a set of pages devoted to discussions of numerical stabilization in PorousFlow.  See:

- [Numerical stabilization lead page](stabilization.md)
- [Mass lumping](mass_lumping.md)
- [Full upwinding](upwinding.md)
- [Kuzmin-Turek stabilization](kt.md)
- [Numerical diffusion](numerical_diffusion.md)
- [A worked example of Kuzmin-Turek stabilization: 1D transport](kt_worked.md)

The Kuzmin-Turek (KT) stabilisation scheme is described elsewhere (see [Kuzmin-Turek stabilization](kt.md) and [A worked example of Kuzmin-Turek stabilization: 1D transport](kt_worked.md)). It is recommended to read those pages before studying this 2D example.

## Problem setup

This page describes a 2D free thermal convection scenario, where fluid flow is driven by buoyancy forces arising from the variation in fluid density with temperature. The scale and properties of the modelled system are representative of a 5 km section of porous rock saturated with pure water. The mesh occupies the domain $0\leq x \leq 8000$ m and $-5000\leq y \leq 0$ m, and is meshed with 30 elements in each direction.

The initial temperature represents a thermal gradient of $30^\textrm{ o}\textrm{C}$ per km (increasing from top to bottom), with a small horizontal gradient to hasten the onset of free thermal convection:

$T(x,y,t=0)=T_0-0.03(y+0.001x)$

with $T_0=20^\textrm{ o}\textrm{C}$

Temperature is fixed at the top and base:

$T(y=0)=T_0$

$T(y=-5000)=170^\textrm{ o}\textrm{C}$

The initial fluid pressure is hydrostatic:

$P(x,y,t=0) = P_0 + \rho_f g y$

with $P_0=10^5 \textrm{ Pa}$, 
$\rho_f = 1000 \textrm{ kg m}^\textrm{-3}$ 
and $g = -10 \textrm{ m s}^\textrm{-2}$

Fluid pressure is fixed at the top:

$P(y=0)=P_0$

The PorousFlowFullySaturated action is used to provide the kernels and many of the materials, resulting in the following input file:

!listing modules/porous_flow/examples/2D_thermal_convection/convect_2D_KT.i

Free thermal convection is expected to occur if the Rayleigh number $Ra$ exceeds a critical value $Ra_c$, the value of which depends on the boundary conditions of the system [citep!Nield1968]. For the properties and boundary conditions used here, $Ra_c=27.1$ and $Ra=454$. Thus, we expect to see vigorous free thermal convection in this system.

## Comparison of stabilisation schemes

[temp_contours] shows the temperature field after 4E11 seconds for the following scenarios:

- No stabilisation
- Full upwinding (achieved using the PorousFlowUnsaturated action in place of PorousFlowFullySaturated)
- KT stabilisation with 5 different flux limiter options (None, Superbee, MC, MinMod and VanLeer)

!media media/porous_flow/convection2D_temp_contours_4E11.png style=width:60%;margin-left:10px caption=Temperature contours after 4E11 seconds of free thermal convection.  id=temp_contours

[temp_upwelling] shows temperature vs. depth in the convective upwelling located at x ~ 5000 m.

!media media/porous_flow/convection2D_temp_upwelling_4E11.png style=width:60%;margin-left:10px caption=Temperature versus depth in a convective upwelling after 4E11 seconds of free thermal convection.  id=temp_upwelling

From these figures it can be seen that:

- The system establishes vigorous free thermal convection, as expected. Note the steep temperature gradient at the top of the convective upwellings. This steep gradient drives the need for numerical stabilisation.
- In the absence of stabilisation, an instability develops near the top boundary in the convective upwellings.
- Full upwinding removes the instability, but at the expense of introducing significant numerical diffusion (reflected in smoothing of the temperature field across the width and height of the convective upwelling).
- KT stabilisation provides a stable solution, with varying degrees of numerical diffusion depending on the choice of flux limiter (compare the various KT curves in [temp_upwelling]).
- KT stabilisation with no flux limiter is similar to full upwinding.

[num_nli] shows the number of non-linear iterations per timestep for each of the 5 flux limiter scenarios. Superbee is the most expensive in terms of number of iterations, however it is also the least diffusive (see [temp_upwelling]). Therefore the choice of flux limiter involves a trade-off between speed and accuracy, with Superbee being the slowest but most accurate, whereas MinMod is the fastest but least accurate (but still considerably better than no flux limiter or full upwinding).

!media media/porous_flow/convection2D_num_nli.png style=width:60%;margin-left:10px caption=Number of non-linear iterations with different flux limiters.  id=num_nli



