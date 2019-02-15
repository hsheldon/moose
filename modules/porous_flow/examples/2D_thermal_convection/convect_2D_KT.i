# 2D thermal convection
# PorousFlowFullySaturated action, KT stabilisation, superbee flux limiter

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 30
  ny = 30
  xmin = 0
  xmax = 8000
  ymin = -5000
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
      thermal_conductivity = 0.6
      bulk_modulus = 2E9
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
  stabilization = KT
  flux_limiter_type = superbee
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
      function = ini_temp
    [../]
  [../]
[]

[Functions]
  [./ini_pp]
    type = ParsedFunction
    vars = 'g rho_f'
    vals = '-10 1000' # grav, fluid dens
    value = 'g*y*rho_f+1E5'
  [../]
  [./ini_temp]
    type = ParsedFunction
    vars = 't_0 t_grad'
    vals = '20 -3e-2' # temp at top, temp gradient
    value = 't_0+t_grad*y+t_grad*0.001*x'
  [../]
[]

[BCs]
  [./p_top]
    type = FunctionPresetBC
    boundary = 'top'
    variable = pp
    function = ini_pp
  [../]
  [./t_top]
    type = PresetBC
    boundary = 'top'
    variable = temp
    value = 20
  [../]
  [./t_base]
    type = PresetBC
    boundary = 'bottom'
    variable = temp
    value = 170
  [../]
[]

[Postprocessors]
  [./dt]
    type = TimestepSize
  [../]
  [./num_li]
    type = NumLinearIterations
  [../]
  [./num_nli]
    type = NumNonlinearIterations
  [../]
  [./temp_1]
    type = PointValue
    point = '4800 -166.667 0'
    variable = temp
  [../]
  [./temp_2]
    type = PointValue
    point = '4800 -333.333 0'
    variable = temp
  [../]
  [./delta_T] # negative value implies instability at top boundary
    type = DifferencePostprocessor
    value1 = temp_2
    value2 = temp_1
  [../]
[]

[Materials]
  # Thermal conductivity
  [./thermal_conductivity]
    type = PorousFlowThermalConductivityFromPorosity
    lambda_s = '3 0 0  0 3 0  0 0 3'
    lambda_f = '0.6 0 0  0 0.6 0  0 0 0.6'
  [../]

  # Specific heat capacity
  [./rock_heat]
    type = PorousFlowMatrixInternalEnergy
    at_nodes = true
    specific_heat_capacity = 850
    density = 2700
  [../]

  # Permeability
  [./permeability]
    type = PorousFlowPermeabilityConst
    permeability = '2E-13 0 0  0 2E-13 0  0 0 2E-13'
  [../]

  # Porosity
  [./porosity_nodal]
    type = PorousFlowPorosityConst
    porosity = 0.1
    at_nodes = true
  [../]

  [./porosity_qp]
    type = PorousFlowPorosityConst
    porosity = 0.1
  [../]

  # Density of saturated rock
  [./density]
    type = PorousFlowTotalGravitationalDensityFullySaturatedFromPorosity
    rho_s = 2700
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

  dt = 5E10
  end_time = 1E12

  l_tol = 1E-5
  nl_abs_tol = 1E-3
  nl_rel_tol = 1E-8
  l_max_its = 200
  nl_max_its = 30

  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  petsc_options_value = ' asm      2              lu            gmres     200'
[]

[Outputs]
  file_base = convect_2D_KT_superbee
  sync_times = '1E11 2E11 3E11 4E11 5E11 6E11 7E11 8E11 9E11 1E12'
  exodus = true
  csv = true
  execute_on = 'initial timestep_end'
[]
