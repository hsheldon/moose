# Free thermal convection using the PorousFlow module
# BCs are impermeable and fixed temperature at top and base

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 20
  ny = 1
  nz = 10
  xmin = 0
  xmax = 2000 # width of 2 convection cells for these BCs
  ymin = 0
  ymax = 50
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
      bulk_modulus = 2E12
      density0 = 1000
      viscosity = 1E-3
    [../]
  [../]
[]

[PorousFlowFullySaturated]
  coupling_type = ThermoHydro
  porepressure = pp
  temperature = temp
  dictator_name = dictator
  fp = simple_fluid
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
      type = FunctionIC
      function = ini_temp_perturb
    [../]
  [../]
[]

[Functions]
  [./ini_pp]
    type = ParsedFunction
    vars = 'g rho_f'
    vals = '-10 1000' # gravity, fluid density
    value = 'g*z*rho_f+1e5'
  [../]
  [./ini_temp]
    type = ParsedFunction
    vars = 't_0 t_grad'
    vals = '30 -3e-2' # temperature at top, temperature gradient
    value = 't_0+t_grad*z'
  [../]
  [./ini_temp_perturb]
    type = ParsedFunction
    vars = 't_0 t_grad'
    vals = '30 -3e-2' # temperature at top, temperature gradient
    value = 't_0+t_grad*z+sin(x/10)'
  [../]
[]

[BCs]
  #active = 't_fixed'
  active = 'fix_t_at_top fix_t_at_bot'
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
  [./fix_t_at_top]
    type = PorousFlowPiecewiseLinearSink
    boundary = front
    # zero flux at T=30, a outwards flux of 1E5J/s/m^2 at T=1E4
    multipliers = '-1E5 0 1E5'
    pt_vals = '-1E4 30 1E4'
    variable = temp
  [../]
  [./fix_t_at_bot]
    type = PorousFlowPiecewiseLinearSink
    boundary = back
    # zero flux at T=60, a outwards flux of 1E5J/s/m^2 at T=1E4
    multipliers = '-1E5 0 1E5'
    pt_vals = '-1E4 60 1E4'
    variable = temp
  [../]
[]

[Postprocessors]
  [./darcy_z_1]
    point = '0 0 -500'
    type = PointValue
    variable = darcy_vel_z
    execute_on = 'initial timestep_end'
  [../]
  [./temp_1]
    point = '0 0 -500'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
  [../]

  [./darcy_z_2]
    point = '1E3 0 -500'
    type = PointValue
    variable = darcy_vel_z
    execute_on = 'initial timestep_end'
  [../]
  [./temp_2]
    point = '1E3 0 -500'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
  [../]

  [./darcy_z_3]
    point = '2E3 0 -500'
    type = PointValue
    variable = darcy_vel_z
    execute_on = 'initial timestep_end'
  [../]
  [./temp_3]
    point = '2E3 0 -500'
    type = PointValue
    variable = temp
    execute_on = 'initial timestep_end'
  [../]
[]

[UserObjects]
[]

[Materials]
  [./thermal_conductivity]
    type = PorousFlowThermalConductivityFromPorosity
    lambda_s = '3 0 0  0 3 0  0 0 3'
    lambda_f = '3 0 0  0 3 0  0 0 3'
  [../]
  [./rock_heat]
    type = PorousFlowMatrixInternalEnergy
    at_nodes = true
    specific_heat_capacity = 850
    density = 3000
  [../]
  [./permeability]
    type = PorousFlowPermeabilityConst
    permeability = '4.75E-13 0 0  0 4.75E-13 0  0 0 4.75E-13'
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
  #line_search = bt

  dt = 1E11
  end_time = 1E13

  l_tol = 1E-5
  nl_abs_tol = 1E-4
  nl_rel_tol = 1E-8
  l_max_its = 200
  nl_max_its = 10

  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  petsc_options_value = ' asm      2              lu            gmres     200'
[]


[Outputs]
  file_base = ActionConvection01
  exodus = true
  csv = true
  execute_on = 'initial timestep_end'
[]
