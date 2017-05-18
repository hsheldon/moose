# Free thermal convection using the PorousFlow module
# BCs are impermeable and fixed temperature at top and base

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 40
  xmin = 0
  xmax = 2695 # width of 2 convection cells for these BCs
  ymin = -1000
  ymax = 0
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -10 0'
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
      #type = BoundingBoxIC
      #inside = 31
      #outside = 30
      #x1 = 0
      #x2 = 100
      #y1 = -1000
      #y2 = -900
    [../]
  [../]
[]

[Functions]
  [./ini_pp]
    type = ParsedFunction
    vars = 'g rho_f'
    vals = '-10 1000' # gravity, fluid density
    value = 'g*y*rho_f'
  [../]
  [./ini_temp]
    type = ParsedFunction
    vars = 't_0 t_grad'
    vals = '30 -3e-2' # temperature at top, temperature gradient
    value = 't_0+t_grad*y'
  [../]
[]

[Kernels]
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
  [./energy_dot]
    type = PorousFlowEnergyTimeDerivative
    variable = temp
  [../]
  [./convection_no_upwind]
    type = PorousFlowFullySaturatedHeatAdvection
    variable = temp
  [../]
  [./heat_conduction]
    type = PorousFlowHeatConduction
    variable = temp
  [../]
[]

[BCs]
  active = 't_fixed p_top'
  [./p_top]
    type = FunctionPresetBC
    variable = pp
    boundary = top
    function = ini_pp
  [../]
  [./t_fixed]
    type = FunctionPresetBC
    variable = temp
    boundary = 'top bottom'
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
[]

[Postprocessors]
  [./darcy_y_1]
    point = '0 -500 0'
    type = PointValue
    variable = darcy_y
    execute_on = 'initial timestep_end'
  [../]
  [./temp_1]
    point = '0 -500 0'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
  [../]

  [./darcy_y_2]
    point = '1E3 -500 0'
    type = PointValue
    variable = darcy_y
    execute_on = 'initial timestep_end'
  [../]
  [./temp_2]
    point = '1E3 -500 0'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
  [../]

  [./darcy_y_3]
    point = '2E3 -500 0'
    type = PointValue
    variable = darcy_y
    execute_on = 'initial timestep_end'
  [../]
  [./temp_3]
    point = '2E3 -500 0'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
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

  [./eff_fluid_pressure_nodal]
    type = PorousFlowEffectiveFluidPressure
    at_nodes = true
  [../]
  [./eff_fluid_pressure_qp]
    type = PorousFlowEffectiveFluidPressure
  [../]

  [./ppss_qp]
    type = PorousFlow1PhaseP
    porepressure = pp
  [../]
  [./ppss_nodal]
    type = PorousFlow1PhaseP
    at_nodes = true
    porepressure = pp
  [../]

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

  [./thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '3 0 0  0 3 0  0 0 3' # irrelevant in fully saturated case
    wet_thermal_conductivity = '3 0 0  0 3 0  0 0 3'
    exponent = 1.0 # irrelevant in fully saturated case
    aqueous_phase_number = 0
  [../]

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

  [./visc_all_qp]
    type = PorousFlowJoiner
    material_property = PorousFlow_viscosity_qp
  [../]
  [./visc_all_nodal]
    type = PorousFlowJoiner
    at_nodes = true
    material_property = PorousFlow_viscosity_nodal
  [../]

  [./permeability]
    type = PorousFlowPermeabilityConst
    permeability = '3.4E-13 0 0  0 3.4E-13 0  0 0 3.4E-13'
  [../]

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

  [./porosity_nodal]
    type = PorousFlowPorosityConst
    at_nodes = true
    porosity = 0.1
  [../]
  [./porosity_qp]
    type = PorousFlowPorosityConst
    porosity = 0.1
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

  dt = 1E13
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
  file_base = Convection01
  exodus = true
  csv = true
  execute_on = 'initial timestep_end'
[]
