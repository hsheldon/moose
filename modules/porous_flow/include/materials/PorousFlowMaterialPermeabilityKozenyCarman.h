/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/

#ifndef POROUSFLOWMATERIALPERMEABILITYKOZENYCARMAN_H
#define POROUSFLOWMATERIALPERMEABILITYKOZENYCARMAN_H

#include "DerivativeMaterialInterface.h"
#include "Material.h"

#include "PorousFlowDictator.h"

//Forward Declarations
class PorousFlowMaterialPermeabilityKozenyCarman;

template<>
InputParameters validParams<PorousFlowMaterialPermeabilityKozenyCarman>();

/**
 * Material designed to provide the permeability tensor which is calculated 
 * from porosity using a form of the Kozeny-Carman equation (e.g. Oelkers 
 * 1996: Reviews in Mineralogy v. 34, p. 131-192):
 * k = k_ijk * A * phi^n / (1 - phi)^m
 * where k_ijk is a tensor providing the anisotropy, phi is porosity, 
 * n and m are positive scalar constants and A is given in one of the
 * following forms:
 * A = k0 * (1 - phi0)^m / phi0^n
 * where k0 and phi0 are a reference permeability and porosity,
 * or
 * A = f * d^2
 * where f is a scalar constant and d is grain diameter.
 */
class PorousFlowMaterialPermeabilityKozenyCarman : public DerivativeMaterialInterface<Material>
{
public:
  PorousFlowMaterialPermeabilityKozenyCarman(const InputParameters & parameters);

protected:
  // parameters for poroperm equation
  
  /// Reference scalar permeability in A = k0 * (1 - phi0)^m / phi0^n
  const Real _k0;
  
  /// Reference porosity in A = k0 * (1 - phi0)^m / phi0^n
  const Real _phi0;
  
  /// Multiplying factor in A = f * d^2
  const Real _f;
  
  /// Grain diameter A = f * d^2
  const Real _d;
  
  /// Exponent in k = k_ijk * A * phi^n / (1 - phi)^m
  const Real _m;

  /// Exponent in k = k_ijk * A * phi^n / (1 - phi)^m
  const Real _n;  

  /// Tensor multiplier k_ijk in k = k_ijk * A * phi^n / (1 - phi)^m
  const RealTensorValue _k_anisotropy;

  /// quadpoint porosity
  const MaterialProperty<Real> & _porosity_qp;
  
  /// d(quadpoint porosity)/d(PorousFlow variable)
  const MaterialProperty<std::vector<Real> > & _dporosity_qp_dvar;

  /// Name of porosity-permeability relationship
  const MooseEnum _poroperm_function;

  /// The variable names UserObject for the Porous-Flow variables
  const PorousFlowDictator & _PorousFlow_name_UO;
  
  /// Number of variables
  const unsigned _num_var;

  /// quadpoint permeability
  MaterialProperty<RealTensorValue> & _permeability;

  /// d(quadpoint permeability)/d(PorousFlow variable)
  MaterialProperty<std::vector<RealTensorValue> > & _dpermeability_dvar;

  /// Multiplying factor in k = k_ijk * A * phi^n / (1 - phi)^m
  Real _A;

  virtual void computeQpProperties();
};

#endif //POROUSFLOWMATERIALPERMEABILITYKOZENYCARMAN_H
