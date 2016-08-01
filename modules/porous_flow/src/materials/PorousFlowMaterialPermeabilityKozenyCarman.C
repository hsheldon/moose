/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/

#include "PorousFlowMaterialPermeabilityKozenyCarman.h"

template<>
InputParameters validParams<PorousFlowMaterialPermeabilityKozenyCarman>()
{
  InputParameters params = validParams<Material>();

  MooseEnum poroperm_function("kozeny_carman_fd2=0 kozeny_carman_phi0=1", "kozeny_carman_fd2");
  params.addParam<MooseEnum>("poroperm_function", poroperm_function, "Function relating porosity and permeability. The options are: kozeny_carman_fd2 = f d^2 phi^n/(1-phi)^m (where phi is porosity, f is a scalar constant with typical values 0.01-0.001, and d is grain size). kozeny_carman_phi0 = k0 (1-phi0)^m/phi0^n * phi^n/(1-phi)^m (where phi is porosity, and k0 is the permeability at porosity phi0)");
  params.addParam<Real>("k0", "The permeability scalar value (usually in m^2) at the reference porosity, required for kozeny_carman_phi0");
  params.addParam<RealTensorValue>("k_anisotropy", "A tensor to multiply the calculated scalar permeability, in order to obtain anisotropy if required. Defaults to isotropic permeability if not specified.");
  params.addParam<Real>("phi0", "The reference porosity, required for kozeny_carman_phi0");
  params.addParam<Real>("f", "The multiplying factor, required for kozeny_carman_fd2");
  params.addParam<Real>("d", "The grain diameter, required for kozeny_carman_fd2");
  params.addRequiredParam<Real>("n", "Porosity exponent (numerator)");
  params.addRequiredParam<Real>("m", "(1-porosity) exponent (denominator)");
  params.addRequiredParam<UserObjectName>("PorousFlowDictator_UO", "The UserObject that holds the list of Porous-Flow variable names.");
  params.addClassDescription("This Material calculates the permeability tensor from a form of the Kozeny-Carman equation");
  return params;
}

PorousFlowMaterialPermeabilityKozenyCarman::PorousFlowMaterialPermeabilityKozenyCarman(const InputParameters & parameters) :
    DerivativeMaterialInterface<Material>(parameters),
    _k0( parameters.isParamValid("k0") ? getParam<Real>("k0") : -1 ),
    _phi0( parameters.isParamValid("phi0") ? getParam<Real>("phi0") : -1 ),
    _f( parameters.isParamValid("f") ? getParam<Real>("f") : -1 ),
    _d( parameters.isParamValid("d") ? getParam<Real>("d") : -1 ),
    _m(getParam<Real>("m")),
    _n(getParam<Real>("n")),
    _k_anisotropy( parameters.isParamValid("k_anisotropy") ? getParam<RealTensorValue>("k_anisotropy") : getParam<RealTensorValue>("1 0 0  0 1 0  0 0 1")),
    _porosity_qp(getMaterialProperty<Real>("PorousFlow_porosity_qp")),
    _dporosity_qp_dvar(getMaterialProperty<std::vector<Real> >("dPorousFlow_porosity_qp_dvar")),
    _poroperm_function(getParam<MooseEnum>("poroperm_function")),
    _PorousFlow_name_UO(getUserObject<PorousFlowDictator>("PorousFlowDictator_UO")),
    _num_var(_PorousFlow_name_UO.numVariables()),
    _permeability(declareProperty<RealTensorValue>("PorousFlow_permeability")),
    _dpermeability_dvar(declareProperty<std::vector<RealTensorValue> >("dPorousFlow_permeability_dvar"))
{
  switch (_poroperm_function)
  {
    case 0: // kozeny_carman_fd2
      if (!(parameters.isParamValid("f") && parameters.isParamValid("d")))
        mooseError("You must specify f and d in order to use kozeny_carman_fd2 in PorousFlowMaterialPermeabilityKozenyCarman");
      _A = _f * _d * _d;
      break;
    case 1: // kozeny_carman_phi0
      if (!(parameters.isParamValid("k0") && parameters.isParamValid("phi0")))
        mooseError("You must specify k0 and phi0 in order to use kozeny_carman_phi0 in PorousFlowMaterialPermeabilityKozenyCarman");
      _A = _k0 * std::pow(1.0 - _phi0,_m)/std::pow(_phi0,_n);
      break;
  }
}

void
PorousFlowMaterialPermeabilityKozenyCarman::computeQpProperties()
{
  _permeability[_qp] = _k_anisotropy * _A * std::pow(_porosity_qp[_qp],_n)/std::pow(1.0 - _porosity_qp[_qp],_m);

  _dpermeability_dvar[_qp].resize(_num_var, RealTensorValue());
  for (unsigned v = 0; v < _num_var; ++v)
    _dpermeability_dvar[_qp][v] = _dporosity_qp_dvar[_qp][v] * _permeability[_qp] * (_n / _porosity_qp[_qp] + _m / (1.0 - _porosity_qp[_qp]));
}

