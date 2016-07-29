/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/

#ifndef POROUSFLOWMATERIALPERMEABILITYFROMPOROSITY_H
#define POROUSFLOWMATERIALPERMEABILITYFROMPOROSITY_H

#include "DerivativeMaterialInterface.h"
#include "Material.h"

#include "PorousFlowDictator.h"

//Forward Declarations
class PorousFlowMaterialPermeabilityFromPorosity;

template<>
InputParameters validParams<PorousFlowMaterialPermeabilityFromPorosity>();

/**
 * Material designed to provide the permeability tensor
 * which is a function of porosity
 */
class PorousFlowMaterialPermeabilityFromPorosity : public DerivativeMaterialInterface<Material>
{
public:
  PorousFlowMaterialPermeabilityFromPorosity(const InputParameters & parameters);

protected:
  bool _k0_set;
  bool _phi0_set;
  bool _f_set;
  bool _d_set;
  bool _k_anisotropy_set;
  
  /// parameters for poroperm equation
  const Real _k0;
  const Real _phi0;
  const Real _f;
  const Real _d;
  const Real _m;
  const Real _n;
  
  const RealTensorValue _k_anisotropy;

  /// quadpoint porosity
  const MaterialProperty<Real> & _porosity_qp;
  
  /// name of porosity-permeability relationship
  const MooseEnum _poroperm_function;

  /// The variable names UserObject for the Porous-Flow variables
  const PorousFlowDictator & _PorousFlow_name_UO;
  
  /// Number of variables
  const unsigned _num_var;

  /// permeability
  MaterialProperty<RealTensorValue> & _permeability;

  /// d(permeability)/d(PorousFlow variable) which are all zero in this case
  MaterialProperty<std::vector<RealTensorValue> > & _dpermeability_dvar;

  /// multiplying factor used in the poroperm equation
  Real _mult;

  virtual void initQpStatefulProperties();
  virtual void computeQpProperties();
};

#endif //POROUSFLOWMATERIALPERMEABILITYFROMPOROSITY_H
