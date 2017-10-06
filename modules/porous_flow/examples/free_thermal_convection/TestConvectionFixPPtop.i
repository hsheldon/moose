# Simple porous flow convection in MOOSE PorousFlow module
# BCs are impermeable and fixed temperature at base, fixed 
# fluid pressure and fixed temperature at top
# Heather Sheldon, CSIRO, April 2017

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 27
  ny = 1
  nz = 10
  xmin = 0
  xmax = 2.69528E3 # width of 2 convection cells for these BCs
  ymin = 0
  ymax = 100
  zmin = -1000
  zmax = 0
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 -10'
[]

[Modules]
  [./FluidProperties]
    [./simple_fluid]
      type = SimpleFluidProperties
      thermal_expansion = 2E-4
      cv = 4180
      cp = 4180
      bulk_modulus = 2E9
      density0 = 1000
      viscosity = 1E-3
    [../]
  [../]
[]

[Variables]
  [./pp]
    [./InitialCondition]
      type = FunctionIC
      function = ini_pp
    [../]
  [../]
  [./temp]
    [./InitialCondition]
      #type = FunctionIC
      #function = ini_temp
      type = RandomIC
      min = 44
      max = 46
    [../]
  [../]
[]

[Functions]
  [./ini_pp]
    type = ParsedFunction
    vars = 'g rho_f'
    vals = '-10 1000' # grav, fluid dens
    value = 'g*z*rho_f+1E5'
  [../]
  [./ini_temp]
    type = ParsedFunction
    vars = 't_0 t_grad'
    vals = '30 -3e-2' # temp at top, temp gradient
    value = 't_0+t_grad*z'
  [../]
[]

[Kernels]
  #active = 'mass_dot flux_full_upwind energy_dot convection_full_upwind heat_conduction'
  active = 'mass_dot flux_no_upwind energy_dot convection_no_upwind heat_conduction'
  [./mass_dot]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = pp
  [../]
  [./flux_no_upwind]
    type = PorousFlowFullySaturatedDarcyBase
    variable = pp
  [../]
  [./flux_full_upwind]
    type = PorousFlowAdvectiveFlux
    variable = pp
  [../]
  [./energy_dot]
    type = PorousFlowEnergyTimeDerivative
    variable = temp
  [../]
  [./convection_no_upwind]
    type = PorousFlowFullySaturatedHeatAdvection
    variable = temp
  [../]
  [./convection_full_upwind]
    type = PorousFlowHeatAdvection
    variable = temp
  [../]
  [./heat_conduction]
    type = PorousFlowHeatConduction
    variable = temp
  [../]
[]

[BCs]
  active = 'p_top t_fixed'
  [./p_top]
    type = FunctionPresetBC
    variable = pp
    boundary = front
    function = ini_pp
  [../]
  [./t_fixed]
    type = FunctionPresetBC
    variable = temp
    boundary = 'front back'
    function = ini_temp
  [../]
[]

[AuxVariables]
  [./darcy_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./darcy_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./darcy_z]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./darcy_x]
    type = PorousFlowDarcyVelocityComponent
    component = 'x'
    variable = darcy_x
  [../]
  [./darcy_y]
    type = PorousFlowDarcyVelocityComponent
    component = 'y'
    variable = darcy_y
  [../]
  [./darcy_z]
    type = PorousFlowDarcyVelocityComponent
    component = 'z'
    variable = darcy_z
  [../]
[]

[Postprocessors]
  [./darcy_z_1]
    point = '0 0 -500'
    type = PointValue
    variable = darcy_z
    execute_on = 'initial timestep_end'
  [../]
  [./temp_1]
    point = '0 0 -500'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
  [../]

  [./darcy_z_2]
    point = '1.35E3 0 -500'
    type = PointValue
    variable = darcy_z
    execute_on = 'initial timestep_end'
  [../]
  [./temp_2]
    point = '1.35E3 0 -500'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
  [../]

  [./darcy_z_3]
    point = '2.69528E3 0 -500'
    type = PointValue
    variable = darcy_z
    execute_on = 'initial timestep_end'
  [../]
  [./temp_3]
    point = '2.69528E3 0 -500'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
  [../]

  [./dt]
    type = TimestepSize
  [../]
  [./num_li]
    type = NumLinearIterations
  [../]
  [./num_nli]
    type = NumNonlinearIterations
  [../]
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pp temp'
    number_fluid_phases = 1
    number_fluid_components = 1
  [../]
[]

[Materials]
  [./temperature_nodal]
    type = PorousFlowTemperature
    at_nodes = true
    temperature = temp
  [../]
  [./temperature_qp]
    type = PorousFlowTemperature
    temperature = temp
  [../]
  
  [./massfrac_nodal]
    type = PorousFlowMassFraction
    at_nodes = true
  [../]

  [./simple_fluid_qp]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
  [../]
  [./simple_fluid_nodal]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    at_nodes = true
    phase = 0
  [../]

  # Fluid pressure
  [./eff_fluid_pressure_nodal]
    type = PorousFlowEffectiveFluidPressure # Calculate effective fluid pressure from fluid phase pressures and saturations
    at_nodes = true
  [../]  
  [./eff_fluid_pressure_qp]
    type = PorousFlowEffectiveFluidPressure # Calculate effective fluid pressure from fluid phase pressures and saturations
  [../]  

  [./ppss_qp]
    type = PorousFlow1PhaseP # Calculate fluid pressure and saturation for 1-phase case
    porepressure = pp
  [../]
  [./ppss_nodal]
    type = PorousFlow1PhaseP # Calculate fluid pressure and saturation for 1-phase case
    at_nodes = true
    porepressure = pp
  [../]

  # Fluid density
  [./dens_all_nodal]
    type = PorousFlowJoiner
    at_nodes = true
    include_old = true
    material_property = PorousFlow_fluid_phase_density_nodal
  [../]
  [./dens_all_qp]
    type = PorousFlowJoiner
    material_property = PorousFlow_fluid_phase_density_qp
  [../]
  
  # Thermal conductivity
  [./thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '3 0 0  0 3 0  0 0 3' # irrelevant in fully saturated case
    wet_thermal_conductivity = '3 0 0  0 3 0  0 0 3'
    exponent = 1.0 # irrelevant in fully saturated case
    aqueous_phase_number = 0
  [../]  
  
  # Specific heat capacity
  [./rock_heat]
    type = PorousFlowMatrixInternalEnergy
    at_nodes = true
    specific_heat_capacity = 850
    density = 3000
  [../]
  [./internal_energy_fluids]
    type = PorousFlowJoiner
    at_nodes = true
    material_property = PorousFlow_fluid_phase_internal_energy_nodal
  [../]

  [./enthalpy_all_qp]
    type = PorousFlowJoiner
    material_property = PorousFlow_fluid_phase_enthalpy_qp
  [../]
  [./enthalpy_all_nodal]
    type = PorousFlowJoiner
    at_nodes = true
    material_property = PorousFlow_fluid_phase_enthalpy_nodal
  [../]

  # Fluid viscosity
  [./visc_all_qp]
    type = PorousFlowJoiner
    material_property = PorousFlow_viscosity_qp
  [../]
  [./visc_all_nodal]
    type = PorousFlowJoiner
    at_nodes = true
    material_property = PorousFlow_viscosity_nodal
  [../]

  # Permeability
  [./permeability]
    type = PorousFlowPermeabilityConst
    permeability = '3.4E-13 0 0  0 3.4E-13 0  0 0 3.4E-13'
    block = '0'
  [../]
  
  # needed by Darcy Aux
  [./relperm_qp]
    type = PorousFlowRelativePermeabilityCorey
    n = 0 # unimportant in this fully-saturated situation
    phase = 0
  [../]
  [./relperm_nodal]
    type = PorousFlowRelativePermeabilityCorey
    at_nodes = true
    n = 0 # unimportant in this fully-saturated situation
    phase = 0
  [../]
  [./relperm_all_qp]
    type = PorousFlowJoiner
    material_property = PorousFlow_relative_permeability_qp
  [../]  
  [./relperm_all_nodal]
    type = PorousFlowJoiner
    at_nodes = true
    material_property = PorousFlow_relative_permeability_nodal
  [../]  

  # Porosity
  [./porosity_nodal]
    type = PorousFlowPorosityConst
    at_nodes = true
    porosity = 0.1
    block = '0'
  [../]
  [./porosity_qp]
    type = PorousFlowPorosityConst
    porosity = 0.1
    block = '0'
  [../]
[]

[Preconditioning]
  [./andy]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  solve_type = Newton
  type = Transient
  line_search = bt
  
  dt = 1E12
  end_time = 1E14
  
  l_tol = 1E-5
  nl_abs_tol = 1E-4
  nl_rel_tol = 1E-8
  l_max_its = 200
  nl_max_its = 10
  
  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  petsc_options_value = ' asm      2              lu            gmres     200'
[]


[Outputs]
  file_base = TestConvection_fixedPPtop
  exodus = true
  csv = true
  execute_on = 'initial timestep_end'
  print_perf_log = true
[]