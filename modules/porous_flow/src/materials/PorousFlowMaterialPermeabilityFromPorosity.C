/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/

#include "PorousFlowMaterialPermeabilityFromPorosity.h"

template<>
InputParameters validParams<PorousFlowMaterialPermeabilityFromPorosity>()
{
  InputParameters params = validParams<Material>();

  MooseEnum poroperm_function("kozeny_carman_fd2=0 kozeny_carman_phi0=1", "kozeny_carman_fd2");
  params.addParam<MooseEnum>("poroperm_function", poroperm_function, "Function relating porosity and permeability. The options are: kozeny_carman_fd2 = f d^2 phi^n/(1-phi)^m (where f is a scalar constant with typical values 0.01-0.001, and d is grain size). kozeny_carman_phi0 = k0 (1-phi0)^m/phi0^n * phi^n/(1-phi)^m (where k0 is the permeability at porosity phi0)");
  params.addParam<Real>("k0", "The permeability scalar value (usually in m^2) at the reference porosity, required for kozeny_carman_phi0");
  params.addParam<RealTensorValue>("k_anisotropy", "A tensor to multiply the calculated scalar permeability, in order to obtain anisotropy if required");
  params.addParam<Real>("phi0", "The reference porosity, required for kozeny_carman_phi0");
  params.addParam<Real>("f", "The multiplying factor, required for kozeny_carman_fd2");
  params.addParam<Real>("d", "The grain diameter, required for kozeny_carman_fd2");
  params.addRequiredParam<Real>("n", "Porosity exponent (numerator)");
  params.addRequiredParam<Real>("m", "(1-porosity) exponent (denominator)");
  params.addRequiredParam<UserObjectName>("PorousFlowDictator_UO", "The UserObject that holds the list of Porous-Flow variable names.");
  params.addClassDescription("This Material calculates the permeability tensor from a specified function of porosity");
  return params;
}

PorousFlowMaterialPermeabilityFromPorosity::PorousFlowMaterialPermeabilityFromPorosity(const InputParameters & parameters) :
    DerivativeMaterialInterface<Material>(parameters),
    _k0_set( parameters.isParamValid("k0") ),
    _phi0_set( parameters.isParamValid("phi0") ),
    _f_set( parameters.isParamValid("f") ),
    _d_set( parameters.isParamValid("d") ),
    _k_anisotropy_set( parameters.isParamValid("k_anisotropy") ),
    _k0( _k0_set ? getParam<Real>("k0") : -1 ),
    _phi0( _phi0_set ? getParam<Real>("phi0") : -1 ),
    _f( _f_set ? getParam<Real>("f") : -1 ),
    _d( _d_set ? getParam<Real>("d") : -1 ),
    _m(getParam<Real>("m")),
    _n(getParam<Real>("n")),
    _k_anisotropy( _k_anisotropy_set ? getParam<RealTensorValue>("k_anisotropy") : getParam<RealTensorValue>("1 0 0  0 1 0  0 0 1")),
    _porosity_qp(getMaterialProperty<Real>("PorousFlow_porosity_qp")),
    _poroperm_function(getParam<MooseEnum>("poroperm_function")),
    _PorousFlow_name_UO(getUserObject<PorousFlowDictator>("PorousFlowDictator_UO")),
    _permeability(declareProperty<RealTensorValue>("PorousFlow_permeability_qp")),
    _dpermeability_dvar(declareProperty<std::vector<RealTensorValue> >("dPorousFlow_permeability_dvar"))
{
  switch (_poroperm_function)
  {
    case 0: // kozeny_carman_fd2
      if (!(_f_set && _d_set))
        mooseError("You must specify f and d in order to use kozeny_carman_fd2 in PorousFlowMaterialPermeabilityFromPorosity");
      _mult = _f*_d*_d;
      break;
    case 1: // kozeny_carman_phi0
      if (!(_k0_set && _phi0_set))
        mooseError("You must specify k0 and phi0 in order to use kozeny_carman_phi0 in PorousFlowMaterialPermeabilityFromPorosity");
      _mult = _k0*pow(1.0-_phi0,_m)/pow(_phi0,_n);
      break;
  }
}

void
PorousFlowMaterialPermeabilityFromPorosity::initQpStatefulProperties()
{
  // **********  Not sure if this is the right thing or even possible! If not need to figure out an alternative for initialising perm.
  _permeability[_qp] = _k_anisotropy*_mult*pow(_porosity_qp[_qp],_n)/pow(1.0-_porosity_qp[_qp],_m);
}

void
PorousFlowMaterialPermeabilityFromPorosity::computeQpProperties()
{
  _permeability[_qp] = _k_anisotropy*_mult*pow(_porosity_qp[_qp],_n)/pow(1.0-_porosity_qp[_qp],_m);

  const unsigned int num_var = _PorousFlow_name_UO.numVariables();
  // ************ Need to fix this, the derivatives won't be zero!!!!
  _dpermeability_dvar[_qp].resize(num_var, RealTensorValue());
}

