## 0.3.3 (unreleased)

- Add `reflective_relay` attribute to L2 policy

## 0.3.2

- Add colon to allowed characters of leaf interface selector names
- Normalize access SPAN filter `protocol` and `port` values
- Add support for `auto_generate_access_leaf_switch_interface_profiles` and `auto_generate_access_spine_switch_interface_profiles` flags

## 0.3.1

- Add description attribute to vlan pool module
- Add description attribute to interface policy group module
- Add `policy_group` attribute to access spine switch profiles
- Add `description` attribute to vlan pool ranges
- Add spine switch policy group module

## 0.3.0

- Add SPAN filter group module
- Add SPAN destination group module
- Add SPAN source group module
- Pin module dependencies

## 0.2.1

- Add `minimum_buffer`, `pfc_state`, `no_drop_cos`, `pfc_scope`, `ecn`, `forward_non_ecn`, `wred_max_threshold`, `wred_min_threshold`, `wred_probability`, `weight` attributes to QoS class

## 0.2.0

- Use Terraform 1.3 compatible modules

## 0.1.3

- Add option to configure EPG mappings

## 0.1.2

- Update readme and add link to Nexus-as-Code project documentation

## 0.1.1

- Fix AAEP infra vlan config (incorrectly enabled even if `false`)

## 0.1.0

- Initial release
