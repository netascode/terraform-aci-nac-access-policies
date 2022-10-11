locals {
  defaults        = lookup(var.model, "defaults", {})
  modules         = lookup(var.model, "modules", {})
  apic            = lookup(var.model, "apic", {})
  access_policies = lookup(local.apic, "access_policies", {})
  node_policies   = lookup(local.apic, "node_policies", {})
  leaf_interface_selectors = flatten([
    for profile in lookup(local.access_policies, "leaf_interface_profiles", []) : [
      for selector in lookup(profile, "selectors", []) : {
        key = "${profile.name}/${selector.name}"
        value = {
          name              = "${selector.name}${local.defaults.apic.access_policies.leaf_interface_profiles.selectors.name_suffix}"
          profile_name      = "${profile.name}${local.defaults.apic.access_policies.leaf_interface_profiles.name_suffix}"
          fex_id            = lookup(selector, "fex_id", 0)
          fex_profile       = lookup(selector, "fex_profile", null) != null ? "${selector.fex_profile}${local.defaults.apic.access_policies.fex_interface_profiles.name_suffix}" : ""
          policy_group      = lookup(selector, "policy_group", null) != null ? "${selector.policy_group}${local.defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix}" : ""
          policy_group_type = lookup(selector, "policy_group", null) != null ? [for pg in local.access_policies.leaf_interface_policy_groups : pg.type if pg.name == selector.policy_group][0] : "access"
          port_blocks = [for block in lookup(selector, "port_blocks", []) : {
            description = lookup(block, "description", "")
            name        = "${block.name}${local.defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.name_suffix}"
            from_module = lookup(block, "from_module", local.defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.from_module)
            from_port   = block.from_port
            to_module   = lookup(block, "to_module", lookup(block, "from_module", local.defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.from_module))
            to_port     = lookup(block, "to_port", block.from_port)
          }]
          sub_port_blocks = [for block in lookup(selector, "sub_port_blocks", []) : {
            description   = lookup(block, "description", "")
            name          = "${block.name}${local.defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.name_suffix}"
            from_module   = lookup(block, "from_module", local.defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.from_module)
            from_port     = block.from_port
            to_module     = lookup(block, "to_module", lookup(block, "from_module", local.defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.from_module))
            to_port       = lookup(block, "to_port", block.from_port)
            from_sub_port = block.from_sub_port
            to_sub_port   = lookup(block, "to_sub_port", block.from_sub_port)
          }]
        }
      }
    ]
  ])

  fex_interface_selectors = flatten([
    for profile in lookup(local.access_policies, "fex_interface_profiles", []) : [
      for selector in lookup(profile, "selectors", []) : {
        key = "${profile.name}/${selector.name}"
        value = {
          name              = "${selector.name}${local.defaults.apic.access_policies.fex_interface_profiles.selectors.name_suffix}"
          profile_name      = "${profile.name}${local.defaults.apic.access_policies.fex_interface_profiles.name_suffix}"
          policy_group      = lookup(selector, "policy_group", null) != null ? "${selector.policy_group}${local.defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix}" : ""
          policy_group_type = lookup(selector, "policy_group", null) != null ? [for pg in local.access_policies.leaf_interface_policy_groups : pg.type if pg.name == selector.policy_group][0] : "access"
          port_blocks = [for block in lookup(selector, "port_blocks", []) : {
            description = lookup(block, "description", "")
            name        = "${block.name}${local.defaults.apic.access_policies.fex_interface_profiles.selectors.port_blocks.name_suffix}"
            from_module = lookup(block, "from_module", local.defaults.apic.access_policies.fex_interface_profiles.selectors.port_blocks.from_module)
            from_port   = block.from_port
            to_module   = lookup(block, "to_module", lookup(block, "from_module", local.defaults.apic.access_policies.fex_interface_profiles.selectors.port_blocks.from_module))
            to_port     = lookup(block, "to_port", block.from_port)
          }]
        }
      }
    ]
  ])

  spine_interface_selectors = flatten([
    for profile in lookup(local.access_policies, "spine_interface_profiles", []) : [
      for selector in lookup(profile, "selectors", []) : {
        key = "${profile.name}/${selector.name}"
        value = {
          name         = "${selector.name}${local.defaults.apic.access_policies.spine_interface_profiles.selectors.name_suffix}"
          profile_name = "${profile.name}${local.defaults.apic.access_policies.spine_interface_profiles.name_suffix}"
          policy_group = lookup(selector, "policy_group", null) != null ? "${selector.policy_group}${local.defaults.apic.access_policies.spine_interface_policy_groups.name_suffix}" : null
          port_blocks = [for block in lookup(selector, "port_blocks", []) : {
            description = lookup(block, "description", "")
            name        = "${block.name}${local.defaults.apic.access_policies.spine_interface_profiles.selectors.port_blocks.name_suffix}"
            from_module = lookup(block, "from_module", local.defaults.apic.access_policies.spine_interface_profiles.selectors.port_blocks.from_module)
            from_port   = block.from_port
            to_module   = lookup(block, "to_module", lookup(block, "from_module", local.defaults.apic.access_policies.spine_interface_profiles.selectors.port_blocks.from_module))
            to_port     = lookup(block, "to_port", block.from_port)
          }]
        }
      }
    ]
  ])

  span_access_source_groups = [for group in lookup(lookup(local.access_policies, "span", {}), "source_groups", []) : {
    name        = "${each.value.name}${local.defaults.apic.access_policies.span.source_groups.name_suffix}"
    description = lookup(each.value, "description", "")
    admin_state = lookup(each.value, "admin_state", local.defaults.apic.access_policies.span.source_groups.admin_state)
    sources = [
      for source in lookup(each.value, "source_groups", []) : {
        name                = "${source.name}${local.defaults.apic.access_policies.span.source_groups.sources.name_suffix}"
        description         = lookup(source, "description", "")
        direction           = lookup(source, "direction", local.defaults.apic.access_policies.span.source_groups.sources.direction)
        span_drop           = lookup(source, "span_drop", local.defaults.apic.access_policies.span.source_groups.sources.span_drop)
        tenant              = lookup(source, "tenant", null) != null ? "${source.tenant}${local.defaults.apic.tenants.name_suffix}" : null
        application_profile = lookup(source, "application_profile", null) != null ? "${source.application_profile}${local.defaults.apic.tenants.application_profiles.name_suffix}" : null
        endpoint_group      = lookup(source, "endpoint_group", null) != null ? "${source.endpoint_group}${local.defaults.apic.tenants.application_profiles.endpoint_groups.name_suffix}" : null
        access_paths = [
          for path in lookup(source, "access_paths", []) : {
            node_id = lookup(path, "node_id", lookup(path, "channel", null) != null ? try([for pg in local.leaf_interface_policy_group_mapping : lookup(pg, "node_ids", []) if pg.name == lookup(path, "channel", null)][0][0], null) : null)
            # set node2_id to "vpc" if channel IPG is vPC, otherwise "null"
            node2_id = lookup(path, "node2_id", lookup(path, "channel", null) != null ? try([for pg in local.leaf_interface_policy_group_mapping : pg.type if pg.name == lookup(path, "channel", null) && pg.type == "vpc"][0], null) : null)
            pod_id   = lookup(path, "pod_id", try([for node in lookup(local.node_policies, "nodes", []) : node.pod if node.id == path.node_id][0], local.defaults.apic.node_policies.nodes.pod))
            fex_id   = lookup(path, "fex_id", null)
            fex2_id  = lookup(path, "fex_id", null)
            module   = lookup(path, "module", null)
            port     = lookup(path, "port", null)
            channel  = lookup(path, "channel", null) != null ? "${path.channel}${local.defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix}" : null
          }
        ]
      }
    ]
    filter_group            = "${each.value.filter_group}${local.defaults.apic.access_policies.span.filter_groups.name_suffix}"
    destination_name        = "${each.value.destination.name}${local.defaults.apic.access_policies.span.destination_groups.name_suffix}"
    destination_description = lookup(each.value.destination, "description")
    }

  ]
}

module "aci_vlan_pool" {
  source  = "netascode/vlan-pool/aci"
  version = ">= 0.2.0"

  for_each   = { for vp in lookup(local.access_policies, "vlan_pools", []) : vp.name => vp if lookup(local.modules, "aci_vlan_pool", true) }
  name       = "${each.value.name}${local.defaults.apic.access_policies.vlan_pools.name_suffix}"
  allocation = lookup(each.value, "allocation", local.defaults.apic.access_policies.vlan_pools.allocation)
  ranges = [for range in lookup(each.value, "ranges", []) : {
    from       = range.from
    to         = lookup(range, "to", range.from)
    allocation = lookup(range, "allocation", local.defaults.apic.access_policies.vlan_pools.ranges.allocation)
    role       = lookup(range, "role", local.defaults.apic.access_policies.vlan_pools.ranges.role)
  }]
}

module "aci_physical_domain" {
  source  = "netascode/physical-domain/aci"
  version = ">= 0.1.0"

  for_each             = { for pd in lookup(local.access_policies, "physical_domains", []) : pd.name => pd if lookup(local.modules, "aci_physical_domain", true) }
  name                 = "${each.value.name}${local.defaults.apic.access_policies.physical_domains.name_suffix}"
  vlan_pool            = "${each.value.vlan_pool}${local.defaults.apic.access_policies.vlan_pools.name_suffix}"
  vlan_pool_allocation = [for k, v in lookup(local.access_policies, "vlan_pools", {}) : lookup(v, "allocation", local.defaults.apic.access_policies.vlan_pools.allocation) if v.name == each.value.vlan_pool][0]

  depends_on = [
    module.aci_vlan_pool,
  ]
}

module "aci_routed_domain" {
  source  = "netascode/routed-domain/aci"
  version = ">= 0.1.0"

  for_each             = { for rd in lookup(local.access_policies, "routed_domains", []) : rd.name => rd if lookup(local.modules, "aci_routed_domain", true) }
  name                 = "${each.value.name}${local.defaults.apic.access_policies.routed_domains.name_suffix}"
  vlan_pool            = "${each.value.vlan_pool}${local.defaults.apic.access_policies.vlan_pools.name_suffix}"
  vlan_pool_allocation = [for vp in lookup(local.access_policies, "vlan_pools", {}) : lookup(vp, "allocation", local.defaults.apic.access_policies.vlan_pools.allocation) if vp.name == each.value.vlan_pool][0]

  depends_on = [
    module.aci_vlan_pool,
  ]
}

module "aci_aaep" {
  source  = "netascode/aaep/aci"
  version = ">= 0.2.0"

  for_each           = { for aaep in lookup(local.access_policies, "aaeps", []) : aaep.name => aaep if lookup(local.modules, "aci_aaep", true) }
  name               = "${each.value.name}${local.defaults.apic.access_policies.aaeps.name_suffix}"
  infra_vlan         = lookup(each.value, "infra_vlan", local.defaults.apic.access_policies.aaeps.infra_vlan) == true ? lookup(local.access_policies, "infra_vlan", 0) : 0
  physical_domains   = [for dom in lookup(each.value, "physical_domains", []) : "${dom}${local.defaults.apic.access_policies.physical_domains.name_suffix}"]
  routed_domains     = [for dom in lookup(each.value, "routed_domains", []) : "${dom}${local.defaults.apic.access_policies.routed_domains.name_suffix}"]
  vmware_vmm_domains = lookup(each.value, "vmware_vmm_domains", [])
  endpoint_groups    = lookup(each.value, "endpoint_groups", [])

  depends_on = [
    module.aci_physical_domain,
    module.aci_routed_domain,
  ]
}

module "aci_mst_policy" {
  source  = "netascode/mst-policy/aci"
  version = ">= 0.2.0"

  for_each = { for mst in lookup(lookup(local.access_policies, "switch_policies", {}), "mst_policies", []) : mst.name => mst if lookup(local.modules, "aci_mst_policy", true) }
  name     = "${each.value.name}${local.defaults.apic.access_policies.switch_policies.mst_policies.name_suffix}"
  region   = each.value.region
  revision = each.value.revision
  instances = [for instance in lookup(each.value, "instances", []) : {
    name = instance.name
    id   = instance.id
    vlan_ranges = [for range in lookup(instance, "vlan_ranges", []) : {
      from = range.from
      to   = lookup(range, "to", range.from)
    }]
  }]
}

module "aci_vpc_policy" {
  source  = "netascode/vpc-policy/aci"
  version = ">= 0.1.0"

  for_each           = { for vpc in lookup(lookup(local.access_policies, "switch_policies", {}), "vpc_policies", []) : vpc.name => vpc if lookup(local.modules, "aci_vpc_policy", true) }
  name               = "${each.value.name}${local.defaults.apic.access_policies.switch_policies.vpc_policies.name_suffix}"
  peer_dead_interval = lookup(each.value, "peer_dead_interval", local.defaults.apic.access_policies.switch_policies.vpc_policies.peer_dead_interval)
}

module "aci_forwarding_scale_policy" {
  source  = "netascode/forwarding-scale-policy/aci"
  version = ">= 0.1.0"

  for_each = { for fs in lookup(lookup(local.access_policies, "switch_policies", {}), "forwarding_scale_policies", []) : fs.name => fs if lookup(local.modules, "aci_forwarding_scale_policy", true) }
  name     = "${each.value.name}${local.defaults.apic.access_policies.switch_policies.forwarding_scale_policies.name_suffix}"
  profile  = lookup(each.value, "profile", local.defaults.apic.access_policies.switch_policies.forwarding_scale_policies.profile)
}

module "aci_access_leaf_switch_policy_group" {
  source  = "netascode/access-leaf-switch-policy-group/aci"
  version = ">= 0.1.0"

  for_each                = { for pg in lookup(local.access_policies, "leaf_switch_policy_groups", []) : pg.name => pg if lookup(local.modules, "aci_access_leaf_switch_policy_group", true) }
  name                    = "${each.value.name}${local.defaults.apic.access_policies.leaf_switch_policy_groups.name_suffix}"
  forwarding_scale_policy = lookup(each.value, "forwarding_scale_policy", null) != null ? "${each.value.forwarding_scale_policy}${local.defaults.apic.access_policies.switch_policies.forwarding_scale_policies.name_suffix}" : ""

  depends_on = [
    module.aci_forwarding_scale_policy,
  ]
}

module "aci_access_leaf_switch_profile_auto" {
  source  = "netascode/access-leaf-switch-profile/aci"
  version = ">= 0.2.0"

  for_each           = { for node in lookup(local.node_policies, "nodes", []) : node.id => node if node.role == "leaf" && lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) && lookup(local.modules, "aci_access_leaf_switch_profile", true) }
  name               = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.access_policies, "leaf_switch_profile_name", local.defaults.apic.access_policies.leaf_switch_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
  interface_profiles = [replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.access_policies, "leaf_interface_profile_name", local.defaults.apic.access_policies.leaf_interface_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))]
  selectors = [{
    name         = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.access_policies, "leaf_switch_selector_name", local.defaults.apic.access_policies.leaf_switch_selector_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
    policy_group = lookup(each.value, "access_policy_group", null) != null ? "${each.value.access_policy_group}${local.defaults.apic.access_policies.leaf_switch_policy_groups.name_suffix}" : null
    node_blocks = [{
      name = each.value.id
      from = each.value.id
      to   = each.value.id
    }]
  }]

  depends_on = [
    module.aci_access_leaf_interface_profile_manual,
    module.aci_access_leaf_interface_profile_auto,
    module.aci_access_leaf_switch_policy_group,
  ]
}

module "aci_access_leaf_switch_profile_manual" {
  source  = "netascode/access-leaf-switch-profile/aci"
  version = ">= 0.2.0"

  for_each = { for prof in lookup(local.access_policies, "leaf_switch_profiles", []) : prof.name => prof if lookup(local.modules, "aci_access_leaf_switch_profile", true) }
  name     = "${each.value.name}${local.defaults.apic.access_policies.leaf_switch_profiles.name_suffix}"
  selectors = [for selector in lookup(each.value, "selectors", []) : {
    name         = "${selector.name}${local.defaults.apic.access_policies.leaf_switch_profiles.selectors.name_suffix}"
    policy_group = lookup(selector, "policy", null) != null ? "${selector.policy}${local.defaults.apic.access_policies.leaf_switch_policy_groups.name_suffix}" : null
    node_blocks = [for block in lookup(selector, "node_blocks", []) : {
      name = "${block.name}${local.defaults.apic.access_policies.leaf_switch_profiles.selectors.node_blocks.name_suffix}"
      from = block.from
      to   = lookup(block, "to", block.from)
    }]
  }]
  interface_profiles = [for profile in lookup(each.value, "interface_profiles", []) : "${profile}${local.defaults.apic.access_policies.leaf_interface_profiles.name_suffix}"]

  depends_on = [
    module.aci_access_leaf_interface_profile_manual,
    module.aci_access_leaf_interface_profile_auto,
    module.aci_access_leaf_switch_policy_group,
  ]
}

module "aci_access_spine_switch_profile_auto" {
  source  = "netascode/access-spine-switch-profile/aci"
  version = ">= 0.2.0"

  for_each           = { for node in lookup(local.node_policies, "nodes", []) : node.id => node if node.role == "spine" && lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) && lookup(local.modules, "aci_access_spine_switch_profile", true) }
  name               = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.access_policies, "spine_switch_profile_name", local.defaults.apic.access_policies.spine_switch_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
  interface_profiles = [replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.access_policies, "spine_interface_profile_name", local.defaults.apic.access_policies.spine_interface_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))]
  selectors = [{
    name = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.access_policies, "spine_switch_selector_name", local.defaults.apic.access_policies.spine_switch_selector_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
    node_blocks = [{
      name = each.value.id
      from = each.value.id
      to   = each.value.id
    }]
  }]

  depends_on = [
    module.aci_access_spine_interface_profile_manual,
    module.aci_access_spine_interface_profile_auto,
  ]
}

module "aci_access_spine_switch_profile_manual" {
  source  = "netascode/access-spine-switch-profile/aci"
  version = ">= 0.2.0"

  for_each = { for prof in lookup(local.access_policies, "spine_switch_profiles", []) : prof.name => prof if lookup(local.modules, "aci_access_spine_switch_profile", true) }
  name     = each.value.name
  selectors = [for selector in lookup(each.value, "selectors", []) : {
    name = "${selector.name}${local.defaults.apic.access_policies.spine_switch_profiles.selectors.name_suffix}"
    node_blocks = [for block in lookup(selector, "node_blocks", []) : {
      name = "${block.name}${local.defaults.apic.access_policies.spine_switch_profiles.selectors.node_blocks.name_suffix}"
      from = block.from
      to   = lookup(block, "to", block.from)
    }]
  }]
  interface_profiles = [for profile in lookup(each.value, "interface_profiles", []) : "${profile}${local.defaults.apic.access_policies.spine_interface_profiles.name_suffix}"]

  depends_on = [
    module.aci_access_spine_interface_profile_manual,
    module.aci_access_spine_interface_profile_auto,
  ]
}

module "aci_cdp_policy" {
  source  = "netascode/cdp-policy/aci"
  version = ">= 0.1.0"

  for_each    = { for cdp in lookup(lookup(local.access_policies, "interface_policies", {}), "cdp_policies", []) : cdp.name => cdp if lookup(local.modules, "aci_cdp_policy", true) }
  name        = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.cdp_policies.name_suffix}"
  admin_state = each.value.admin_state
}

module "aci_lldp_policy" {
  source  = "netascode/lldp-policy/aci"
  version = ">= 0.1.0"

  for_each       = { for lldp in lookup(lookup(local.access_policies, "interface_policies", {}), "lldp_policies", []) : lldp.name => lldp if lookup(local.modules, "aci_lldp_policy", true) }
  name           = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.lldp_policies.name_suffix}"
  admin_rx_state = each.value.admin_rx_state
  admin_tx_state = each.value.admin_tx_state
}

module "aci_link_level_policy" {
  source  = "netascode/link-level-policy/aci"
  version = ">= 0.1.0"

  for_each = { for llp in lookup(lookup(local.access_policies, "interface_policies", {}), "link_level_policies", []) : llp.name => llp if lookup(local.modules, "aci_link_level_policy", true) }
  name     = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.link_level_policies.name_suffix}"
  speed    = lookup(each.value, "speed", local.defaults.apic.access_policies.interface_policies.link_level_policies.speed)
  auto     = lookup(each.value, "auto", local.defaults.apic.access_policies.interface_policies.link_level_policies.auto)
  fec_mode = lookup(each.value, "fec_mode", local.defaults.apic.access_policies.interface_policies.link_level_policies.fec_mode)
}

module "aci_port_channel_policy" {
  source  = "netascode/port-channel-policy/aci"
  version = ">= 0.1.0"

  for_each             = { for pc in lookup(lookup(local.access_policies, "interface_policies", {}), "port_channel_policies", []) : pc.name => pc if lookup(local.modules, "aci_port_channel_policy", true) }
  name                 = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.port_channel_policies.name_suffix}"
  mode                 = each.value.mode
  min_links            = lookup(each.value, "min_links", local.defaults.apic.access_policies.interface_policies.port_channel_policies.min_links)
  max_links            = lookup(each.value, "max_links", local.defaults.apic.access_policies.interface_policies.port_channel_policies.max_links)
  suspend_individual   = lookup(each.value, "suspend_individual", local.defaults.apic.access_policies.interface_policies.port_channel_policies.suspend_individual)
  graceful_convergence = lookup(each.value, "graceful_convergence", local.defaults.apic.access_policies.interface_policies.port_channel_policies.graceful_convergence)
  fast_select_standby  = lookup(each.value, "fast_select_standby", local.defaults.apic.access_policies.interface_policies.port_channel_policies.fast_select_standby)
  load_defer           = lookup(each.value, "load_defer", local.defaults.apic.access_policies.interface_policies.port_channel_policies.load_defer)
  symmetric_hash       = lookup(each.value, "symmetric_hash", local.defaults.apic.access_policies.interface_policies.port_channel_policies.symmetric_hash)
  hash_key             = lookup(each.value, "hash_key", "")
}

module "aci_port_channel_member_policy" {
  source  = "netascode/port-channel-member-policy/aci"
  version = ">= 0.1.0"

  for_each = { for pcm in lookup(lookup(local.access_policies, "interface_policies", {}), "port_channel_member_policies", []) : pcm.name => pcm if lookup(local.modules, "aci_port_channel_member_policy", true) }
  name     = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.port_channel_member_policies.name_suffix}"
  priority = lookup(each.value, "priority", local.defaults.apic.access_policies.interface_policies.port_channel_member_policies.priority)
  rate     = lookup(each.value, "rate", local.defaults.apic.access_policies.interface_policies.port_channel_member_policies.rate)
}

module "aci_spanning_tree_policy" {
  source  = "netascode/spanning-tree-policy/aci"
  version = ">= 0.1.0"

  for_each    = { for stp in lookup(lookup(local.access_policies, "interface_policies", {}), "spanning_tree_policies", []) : stp.name => stp if lookup(local.modules, "aci_spanning_tree_policy", true) }
  name        = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.spanning_tree_policies.name_suffix}"
  bpdu_filter = lookup(each.value, "bpdu_filter", local.defaults.apic.access_policies.interface_policies.spanning_tree_policies.bpdu_filter)
  bpdu_guard  = lookup(each.value, "bpdu_guard", local.defaults.apic.access_policies.interface_policies.spanning_tree_policies.bpdu_guard)
}

module "aci_mcp_policy" {
  source  = "netascode/mcp-policy/aci"
  version = ">= 0.1.0"

  for_each    = { for mcp in lookup(lookup(local.access_policies, "interface_policies", {}), "mcp_policies", []) : mcp.name => mcp if lookup(local.modules, "aci_mcp_policy", true) }
  name        = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.mcp_policies.name_suffix}"
  admin_state = each.value.admin_state
}

module "aci_l2_policy" {
  source  = "netascode/l2-policy/aci"
  version = ">= 0.1.0"

  for_each   = { for l2 in lookup(lookup(local.access_policies, "interface_policies", {}), "l2_policies", []) : l2.name => l2 if lookup(local.modules, "aci_l2_policy", true) }
  name       = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.l2_policies.name_suffix}"
  vlan_scope = lookup(each.value, "vlan_scope", local.defaults.apic.access_policies.interface_policies.l2_policies.vlan_scope)
  qinq       = lookup(each.value, "qinq", local.defaults.apic.access_policies.interface_policies.l2_policies.qinq)
}

module "aci_storm_control_policy" {
  source  = "netascode/storm-control-policy/aci"
  version = ">= 0.1.0"

  for_each                   = { for sc in lookup(lookup(local.access_policies, "interface_policies", {}), "storm_control_policies", []) : sc.name => sc if lookup(local.modules, "aci_storm_control_policy", true) }
  name                       = "${each.value.name}${local.defaults.apic.access_policies.interface_policies.storm_control_policies.name_suffix}"
  alias                      = lookup(each.value, "alias", "")
  description                = lookup(each.value, "description", "")
  action                     = lookup(each.value, "action", local.defaults.apic.access_policies.interface_policies.storm_control_policies.action)
  broadcast_burst_pps        = lookup(each.value, "broadcast_burst_pps", local.defaults.apic.access_policies.interface_policies.storm_control_policies.broadcast_burst_pps)
  broadcast_burst_rate       = lookup(each.value, "broadcast_burst_rate", local.defaults.apic.access_policies.interface_policies.storm_control_policies.broadcast_burst_rate)
  broadcast_pps              = lookup(each.value, "broadcast_pps", local.defaults.apic.access_policies.interface_policies.storm_control_policies.broadcast_pps)
  broadcast_rate             = lookup(each.value, "broadcast_rate", local.defaults.apic.access_policies.interface_policies.storm_control_policies.broadcast_rate)
  multicast_burst_pps        = lookup(each.value, "multicast_burst_pps", local.defaults.apic.access_policies.interface_policies.storm_control_policies.multicast_burst_pps)
  multicast_burst_rate       = lookup(each.value, "multicast_burst_rate", local.defaults.apic.access_policies.interface_policies.storm_control_policies.multicast_burst_rate)
  multicast_pps              = lookup(each.value, "multicast_pps", local.defaults.apic.access_policies.interface_policies.storm_control_policies.multicast_pps)
  multicast_rate             = lookup(each.value, "multicast_rate", local.defaults.apic.access_policies.interface_policies.storm_control_policies.multicast_rate)
  unknown_unicast_burst_pps  = lookup(each.value, "unknown_unicast_burst_pps", local.defaults.apic.access_policies.interface_policies.storm_control_policies.unknown_unicast_burst_pps)
  unknown_unicast_burst_rate = lookup(each.value, "unknown_unicast_burst_rate", local.defaults.apic.access_policies.interface_policies.storm_control_policies.unknown_unicast_burst_rate)
  unknown_unicast_pps        = lookup(each.value, "unknown_unicast_pps", local.defaults.apic.access_policies.interface_policies.storm_control_policies.unknown_unicast_pps)
  unknown_unicast_rate       = lookup(each.value, "unknown_unicast_rate", local.defaults.apic.access_policies.interface_policies.storm_control_policies.unknown_unicast_rate)
}

module "aci_access_leaf_interface_policy_group" {
  source  = "netascode/access-leaf-interface-policy-group/aci"
  version = ">= 0.1.2"

  for_each                   = { for pg in lookup(local.access_policies, "leaf_interface_policy_groups", []) : pg.name => pg if lookup(local.modules, "aci_access_leaf_interface_policy_group", true) }
  name                       = "${each.value.name}${local.defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix}"
  type                       = each.value.type
  map                        = lookup(each.value, "map", local.defaults.apic.access_policies.leaf_interface_policy_groups.map)
  link_level_policy          = lookup(each.value, "link_level_policy", null) != null ? "${each.value.link_level_policy}${local.defaults.apic.access_policies.interface_policies.link_level_policies.name_suffix}" : ""
  cdp_policy                 = lookup(each.value, "cdp_policy", null) != null ? "${each.value.cdp_policy}${local.defaults.apic.access_policies.interface_policies.cdp_policies.name_suffix}" : ""
  lldp_policy                = lookup(each.value, "lldp_policy", null) != null ? "${each.value.lldp_policy}${local.defaults.apic.access_policies.interface_policies.lldp_policies.name_suffix}" : ""
  spanning_tree_policy       = lookup(each.value, "spanning_tree_policy", null) != null ? "${each.value.spanning_tree_policy}${local.defaults.apic.access_policies.interface_policies.spanning_tree_policies.name_suffix}" : ""
  mcp_policy                 = lookup(each.value, "mcp_policy", null) != null ? "${each.value.mcp_policy}${local.defaults.apic.access_policies.interface_policies.mcp_policies.name_suffix}" : ""
  l2_policy                  = lookup(each.value, "l2_policy", null) != null ? "${each.value.l2_policy}${local.defaults.apic.access_policies.interface_policies.l2_policies.name_suffix}" : ""
  storm_control_policy       = lookup(each.value, "storm_control_policy", null) != null ? "${each.value.storm_control_policy}${local.defaults.apic.access_policies.interface_policies.storm_control_policies.name_suffix}" : ""
  port_channel_policy        = lookup(each.value, "port_channel_policy", null) != null ? "${each.value.port_channel_policy}${local.defaults.apic.access_policies.interface_policies.port_channel_policies.name_suffix}" : ""
  port_channel_member_policy = lookup(each.value, "port_channel_member_policy", null) != null ? "${each.value.port_channel_member_policy}${local.defaults.apic.access_policies.interface_policies.port_channel_member_policies.name_suffix}" : ""
  aaep                       = lookup(each.value, "aaep", null) != null ? "${each.value.aaep}${local.defaults.apic.access_policies.aaeps.name_suffix}" : ""

  depends_on = [
    module.aci_link_level_policy,
    module.aci_cdp_policy,
    module.aci_lldp_policy,
    module.aci_spanning_tree_policy,
    module.aci_mcp_policy,
    module.aci_l2_policy,
    module.aci_storm_control_policy,
    module.aci_port_channel_policy,
    module.aci_port_channel_member_policy,
    module.aci_aaep,
  ]
}

module "aci_access_spine_interface_policy_group" {
  source  = "netascode/access-spine-interface-policy-group/aci"
  version = ">= 0.1.0"

  for_each          = { for pg in lookup(local.access_policies, "spine_interface_policy_groups", []) : pg.name => pg if lookup(local.modules, "aci_access_spine_interface_policy_group", true) }
  name              = "${each.value.name}${local.defaults.apic.access_policies.spine_interface_policy_groups.name_suffix}"
  link_level_policy = lookup(each.value, "link_level_policy", null) != null ? "${each.value.link_level_policy}${local.defaults.apic.access_policies.interface_policies.link_level_policies.name_suffix}" : ""
  cdp_policy        = lookup(each.value, "cdp_policy", null) != null ? "${each.value.cdp_policy}${local.defaults.apic.access_policies.interface_policies.cdp_policies.name_suffix}" : ""
  aaep              = lookup(each.value, "aaep", null) != null ? "${each.value.aaep}${local.defaults.apic.access_policies.aaeps.name_suffix}" : ""

  depends_on = [
    module.aci_link_level_policy,
    module.aci_cdp_policy,
    module.aci_aaep,
  ]
}

module "aci_access_leaf_interface_profile_auto" {
  source  = "netascode/access-leaf-interface-profile/aci"
  version = ">= 0.1.0"

  for_each = { for node in lookup(local.node_policies, "nodes", []) : node.id => node if node.role == "leaf" && lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) && lookup(local.modules, "aci_access_leaf_interface_profile", true) }
  name     = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.access_policies, "leaf_interface_profile_name", local.defaults.apic.access_policies.leaf_interface_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
}

module "aci_access_leaf_interface_profile_manual" {
  source  = "netascode/access-leaf-interface-profile/aci"
  version = ">= 0.1.0"

  for_each = { for prof in lookup(local.access_policies, "leaf_interface_profiles", []) : prof.name => prof if lookup(local.modules, "aci_access_leaf_interface_profile", true) }
  name     = "${each.value.name}${local.defaults.apic.access_policies.leaf_interface_profiles.name_suffix}"
}

module "aci_access_leaf_interface_selector_manual" {
  source  = "netascode/access-leaf-interface-selector/aci"
  version = ">= 0.2.0"

  for_each              = { for selector in local.leaf_interface_selectors : selector.key => selector.value if lookup(local.modules, "aci_access_leaf_interface_selector", true) }
  interface_profile     = each.value.profile_name
  name                  = each.value.name
  fex_id                = each.value.fex_id
  fex_interface_profile = each.value.fex_profile
  policy_group          = each.value.policy_group
  policy_group_type     = each.value.policy_group_type
  port_blocks           = each.value.port_blocks
  sub_port_blocks       = each.value.sub_port_blocks

  depends_on = [
    module.aci_access_leaf_interface_policy_group,
    module.aci_access_leaf_interface_profile_manual,
    module.aci_access_leaf_interface_profile_auto,
  ]
}

module "aci_access_fex_interface_profile_manual" {
  source  = "netascode/access-fex-interface-profile/aci"
  version = ">= 0.1.0"

  for_each = toset([for fex in lookup(local.access_policies, "fex_interface_profiles", []) : fex.name if lookup(local.modules, "aci_access_fex_interface_profile", true)])
  name     = "${each.value}${local.defaults.apic.access_policies.fex_interface_profiles.name_suffix}"
}

module "aci_access_fex_interface_selector_manual" {
  source  = "netascode/access-fex-interface-selector/aci"
  version = ">= 0.2.0"

  for_each          = { for selector in local.fex_interface_selectors : selector.key => selector.value if lookup(local.modules, "aci_access_fex_interface_selector", true) }
  interface_profile = each.value.profile_name
  name              = each.value.name
  policy_group      = each.value.policy_group
  policy_group_type = each.value.policy_group_type
  port_blocks       = each.value.port_blocks

  depends_on = [
    module.aci_access_leaf_interface_policy_group,
    module.aci_access_fex_interface_profile_manual,
  ]
}

module "aci_access_spine_interface_profile_auto" {
  source  = "netascode/access-spine-interface-profile/aci"
  version = ">= 0.1.0"

  for_each = { for node in lookup(local.node_policies, "nodes", []) : node.id => node if node.role == "spine" && lookup(local.apic, "auto_generate_switch_pod_profiles", local.defaults.apic.auto_generate_switch_pod_profiles) && lookup(local.modules, "aci_access_spine_interface_profile", true) }
  name     = replace("${each.value.id}:${each.value.name}", "/^(?P<id>.+):(?P<name>.+)$/", replace(replace(lookup(local.access_policies, "spine_interface_profile_name", local.defaults.apic.access_policies.spine_interface_profile_name), "\\g<id>", "$id"), "\\g<name>", "$name"))
}

module "aci_access_spine_interface_profile_manual" {
  source  = "netascode/access-spine-interface-profile/aci"
  version = ">= 0.1.0"

  for_each = { for prof in lookup(local.access_policies, "spine_interface_profiles", []) : prof.name => prof if lookup(local.modules, "aci_access_spine_interface_profile", true) }
  name     = "${each.value.name}${local.defaults.apic.access_policies.spine_interface_profiles.name_suffix}"
}

module "aci_access_spine_interface_selector_manual" {
  source  = "netascode/access-spine-interface-selector/aci"
  version = ">= 0.2.0"

  for_each          = { for selector in local.spine_interface_selectors : selector.key => selector.value if lookup(local.modules, "aci_access_spine_interface_selector", true) }
  interface_profile = each.value.profile_name
  name              = each.value.name
  policy_group      = each.value.policy_group
  port_blocks       = each.value.port_blocks

  depends_on = [
    module.aci_access_spine_interface_policy_group,
    module.aci_access_spine_interface_profile_manual,
    module.aci_access_spine_interface_profile_auto,
  ]
}

module "aci_mcp" {
  source  = "netascode/mcp/aci"
  version = ">= 0.1.0"

  count               = lookup(local.modules, "aci_mcp", true) == false ? 0 : 1
  admin_state         = lookup(lookup(local.access_policies, "mcp", {}), "admin_state", local.defaults.apic.access_policies.mcp.admin_state)
  per_vlan            = lookup(lookup(local.access_policies, "mcp", {}), "per_vlan", local.defaults.apic.access_policies.mcp.per_vlan)
  initial_delay       = lookup(lookup(local.access_policies, "mcp", {}), "initial_delay", local.defaults.apic.access_policies.mcp.initial_delay)
  key                 = lookup(lookup(local.access_policies, "mcp", {}), "key", "")
  loop_detection      = lookup(lookup(local.access_policies, "mcp", {}), "loop_detection", local.defaults.apic.access_policies.mcp.loop_detection)
  disable_port_action = lookup(lookup(local.access_policies, "mcp", {}), "action", local.defaults.apic.access_policies.mcp.action)
  frequency_sec       = lookup(lookup(local.access_policies, "mcp", {}), "frequency_sec", local.defaults.apic.access_policies.mcp.frequency_sec)
  frequency_msec      = lookup(lookup(local.access_policies, "mcp", {}), "frequency_msec", local.defaults.apic.access_policies.mcp.frequency_msec)
}

module "aci_qos" {
  source  = "netascode/qos/aci"
  version = ">= 0.2.1"

  count        = lookup(local.modules, "aci_qos", true) == false ? 0 : 1
  preserve_cos = lookup(lookup(local.access_policies, "qos", {}), "preserve_cos", local.defaults.apic.access_policies.qos.preserve_cos)
  qos_classes = [
    for class in lookup(lookup(local.access_policies, "qos", {}), "qos_classes", []) : {
      level                = class.level
      admin_state          = lookup(class, "admin_state", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.admin_state if qclass.level == class.level][0])
      mtu                  = lookup(class, "mtu", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.mtu if qclass.level == class.level][0])
      bandwidth_percent    = lookup(class, "bandwidth_percent", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.bandwidth_percent if qclass.level == class.level][0])
      scheduling           = lookup(class, "scheduling", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.scheduling if qclass.level == class.level][0])
      congestion_algorithm = lookup(class, "congestion_algorithm", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.congestion_algorithm if qclass.level == class.level][0])
      minimum_buffer       = lookup(class, "minimum_buffer", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.minimum_buffer if qclass.level == class.level][0])
      pfc_state            = lookup(class, "pfc_state", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.pfc_state if qclass.level == class.level][0])
      no_drop_cos          = lookup(class, "no_drop_cos", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.no_drop_cos if qclass.level == class.level][0])
      pfc_scope            = lookup(class, "pfc_scope", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.pfc_scope if qclass.level == class.level][0])
      ecn                  = lookup(class, "ecn", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.ecn if qclass.level == class.level][0])
      forward_non_ecn      = lookup(class, "forward_non_ecn", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.forward_non_ecn if qclass.level == class.level][0])
      wred_max_threshold   = lookup(class, "wred_max_threshold", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.wred_max_threshold if qclass.level == class.level][0])
      wred_min_threshold   = lookup(class, "wred_min_threshold", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.wred_min_threshold if qclass.level == class.level][0])
      wred_probability     = lookup(class, "wred_probability", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.wred_probability if qclass.level == class.level][0])
      weight               = lookup(class, "weight", [for qclass in local.defaults.apic.access_policies.qos.qos_classes : qclass.weight if qclass.level == class.level][0])
    }
  ]
}

module "aci_access_span_source_group" {
  source  = "netascode/access-span-source-group/aci"
  version = ">= 0.1.0"

  for_each    = { for group in local.span_access_source_groups : span.name => span if lookup(local.modules, "aci_access_span_source_group", true) }
  name        = each.value.name
  description = each.value.description
  admin_state = each.value.admin_state
  sources = [
    for source in lookup(each.value, "source_groups", []) : {
      name                = "${source.name}${local.defaults.apic.access_policies.span.source_groups.sources.name_suffix}"
      description         = source.description
      direction           = source.direction
      span_drop           = source.span_drop
      tenant              = source.tenant
      application_profile = source.application_profile
      endpoint_group      = source.endpoint_group
      access_paths = [
        for path in lookup(source, "access_paths", []) : {
          node_id  = path.node_id
          node2_id = path.node2_id == "vpc" ? [for pg in local.leaf_interface_policy_group_mapping : lookup(pg, "node_ids", []) if pg.name == path.channel][0][1] : path.node2_id
          pod_id   = path.pod_id
          fex_id   = path.fex_id
          fex2_id  = path.fex2_id
          module   = path.module
          port     = path.port
          channel  = path.channel
        }
      ]
    }
  ]
  filter_group            = "${each.value.filter_group}${local.defaults.apic.access_policies.span.filter_groups.name_suffix}"
  destination_name        = "${each.value.destination.name}${local.defaults.apic.access_policies.span.destination_groups.name_suffix}"
  destination_description = lookup(each.value.destination, "description")
}
