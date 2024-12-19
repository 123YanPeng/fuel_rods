#这一步的目的是计算燃料棒的应力分布
#根据前一步生成的网格文件Oconee_Rod_15309.e，现在给包壳与芯块内外一个压力，计算燃料棒的应力分布
pellet_density=10431.0#10431.0*0.85#kg⋅m-3
pellet_elastic_constants=2.2e11#Pa
pellet_nu = 0.345
pellet_specific_heat=300
pellet_thermal_conductivity = 5

clad_density=6.59e3#kg⋅m-3
clad_elastic_constants=7.52e10#Pa
clad_nu = 0.33
clad_specific_heat=264.5
clad_thermal_conductivity = 16

[Mesh]
    file = 'Oconee_Rod_15309.e'
[]
[GlobalParams]
    displacements = 'disp_x disp_y disp_z'
[]
[AuxVariables]
  [./hoop_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./hoop_stress]
    type = ADRankTwoScalarAux
    variable = hoop_stress
    rank_two_tensor = stress
    scalar_type = HoopStress
    point1 = '0 0 0'        # 圆心坐标
    point2 = '0 0 -1'        # 定义旋转轴方向（z轴）
    execute_on = 'TIMESTEP_END'
  [../]
[]

[Variables]
    [disp_x]
    []
    [disp_y]
    []
    [disp_z]
    []
[]
[Kernels]
    [solid_x]
        type = ADStressDivergenceTensors
        variable = disp_x
        component = 0
    []
    [solid_y]
        type = ADStressDivergenceTensors
        variable = disp_y
        component = 1
    []
    [solid_z]
        type = ADStressDivergenceTensors
        variable = disp_z
        component = 2
    []
[]
[BCs]
  [x_zero_on_y_axis]
    type = DirichletBC
    variable = disp_y
    boundary = 'yplane'
    value = 0
  []
  [y_zero_on_x_axis]
    type = DirichletBC
    variable = disp_x
    boundary = 'xplane'
    value = 0
  []
  # [x_zero_on_y_axis2]
  #   type = DirichletBC
  #   variable = disp_z
  #   boundary = bottom
  #   value = 0
  # []
  [displacementsInBottom]
    type = Pressure
    variable = disp_x
    boundary = 'clad_inner pellet_outer'
    factor = 1e6
    function = gap_pressure
    use_displaced_mesh = true
  []
  [displacementsInBottom2]
    type = Pressure
    variable = disp_y
    boundary = 'clad_inner pellet_outer'
    factor = 1e6
    function = gap_pressure
    use_displaced_mesh = true
  []
[]
[Materials]

    [pellet_strain]
        type = ADComputeSmallStrain 
        block = pellet
    []
    [pellet_elasticity_tensor]
      type = ADComputeIsotropicElasticityTensor
      youngs_modulus = ${pellet_elastic_constants}
      poissons_ratio = ${pellet_nu}
      block = pellet
    []

    [clad_strain]
      type = ADComputeSmallStrain 
      block = clad
    []
    [clad_elasticity_tensor]
        type = ADComputeIsotropicElasticityTensor
        youngs_modulus = ${clad_elastic_constants}
        poissons_ratio = ${clad_nu}
        block = clad
    []
    [clad_stress]
        type = ADComputeLinearElasticStress
    []

[]
[Functions]
  [gap_pressure]
    type = ParsedFunction
    expression = 't'
  []
[]
[Executioner]
    type = Transient
    solve_type = 'NEWTON'
    dt = 1
    end_time = 5
  []
[Outputs]
  exodus = true
[]