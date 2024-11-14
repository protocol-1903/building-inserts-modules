local alienlife_buildings = {
  ["antelope-enclosure"] = {"antelope"},
  ["arqad-hive"] = {"arqad", "arqad-mk02", "arqad-mk03", "arqad-mk04"},
  ["arthurian-pen"] = {"arthurian", "arthurian-mk02", "arthurian-mk03", "arthurian-mk04"},
  ["auog-paddock"] = {"auog", "auog-mk02", "auog-mk03", "auog-mk04"},
  ["cridren-enclosure"] = {"cridren"},
  ["dhilmos-pool"] = {"dhilmos", "dhilmos-mk02", "dhilmos-mk03", "dhilmos-mk04"},
  ["dingrits-pack"] = {"dingrits", "dingrits-mk02", "dingrits-mk03", "dingrits-mk04"},
  ["fish-farm"] = {"fish", "fish-mk02", "fish-mk03", "fish-mk04"},
  ["kmauts-enclosure"] = {"kmauts", "kmauts-mk02", "kmauts-mk03", "kmauts-mk04"},
  ["mukmoux-pasture"] = {"mukmoux", "mukmoux-mk02", "mukmoux-mk03", "mukmoux-mk04"},
  ["phadai-enclosure"] = {"phadai", "phadai-mk02", "phadai-mk03", "phadai-mk04"},
  ["phagnot-corral"] = {"phagnot", "phagnot-mk02", "phagnot-mk03", "phagnot-mk04"},
  ["prandium-lab"] = {"cottongut-mk01", "cottongut-mk02", "cottongut-mk03", "cottongut-mk04"},
  ["ez-ranch"] = {"korlex", "korlex-mk02", "korlex-mk03", "korlex-mk04"},
  ["scrondrix-pen"] = {"scrondrix", "scrondrix-mk02", "scrondrix-mk03", "scrondrix-mk04"},
  ["simik-den"] = {"simik", "simik-mk02", "simik-mk03", "simik-mk04"},
  ["trits-reef"] = {"trits", "trits-mk02", "trits-mk03", "trits-mk04"},
  ["ulric-corral"] = {"ulric", "ulric-mk02", "ulric-mk03", "ulric-mk04"},
  ["vonix-den"] = {"vonix", "vonix-mk02", "vonix-mk03", "vonix-mk04"},
  ["vrauks-paddock"] = {"vrauks", "vrauks-mk02", "vrauks-mk03", "vrauks-mk04"},
  ["xenopen"] = {"xeno", "xeno-mk02", "xeno-mk03", "xeno-mk04"},
  ["xyhiphoe-pool"] = {"xyhiphoe", "xyhiphoe-mk02", "xyhiphoe-mk03", "xyhiphoe-mk04"},
  ["zipir-reef"] = {"zipir", "zipir-mk02", "zipir-mk03", "zipir-mk04"},
  ["cadaveric-arum"] = {"cadaveric-arum", "cadaveric-arum-mk02", "cadaveric-arum-mk03", "cadaveric-arum-mk04"},
  ["fwf"] = {"tree-mk01", "tree-mk02", "tree-mk03", "tree-mk04"},
  ["grods-swamp"] = {"grod", "grod-mk02", "grod-mk03", "grod-mk04"},
  ["guar-gum-plantation"] = {"guar-gum", "guar-gum-mk02", "guar-gum-mk03", "guar-gum-mk04"},
  ["kicalk-plantation"] = {"kicalk", "kicalk-mk02", "kicalk-mk03", "kicalk-mk04"},
  ["moondrop-greenhouse"] = {"moondrop", "moondrop-mk02", "moondrop-mk03", "moondrop-mk04"},
  ["moss-farm"] = {"moss", "moss-mk02", "moss-mk03", "moss-mk04"},
  ["ralesia-plantation"] = {"ralesia", "ralesia-mk02", "ralesia-mk03", "ralesia-mk04"},
  ["rennea-plantation"] = {"rennea", "rennea-mk02", "rennea-mk03", "rennea-mk04"},
  ["sap-extractor"] = {"sap-tree", "sap-tree-mk02", "sap-tree-mk03", "sap-tree-mk04"},
  ["seaweed-crop"] = {"seaweed", "seaweed-mk02", "seaweed-mk03", "seaweed-mk04"},
  ["sponge-culture"] = {"sea-sponge-sprouts", "sea-sponge-sprouts-mk02", "sea-sponge-sprouts-mk03", "sea-sponge-sprouts-mk04"},
  -- ["turd-wpu"] = {"py-sawblade-module-mk01", "py-sawblade-module-mk02", "py-sawblade-module-mk03", "py-sawblade-module-mk04"}, -- not workable cause of custom placement from pypp
  ["tuuphra-plantation"] = {"tuuphra", "tuuphra-mk02", "tuuphra-mk03", "tuuphra-mk04"},
  ["yotoi-aloe-orchard"] = {"yotoi", "yotoi-mk02", "yotoi-mk03", "yotoi-mk04"},
  ["bhoddos-culture"] = {"bhoddos", "bhoddos-mk02", "bhoddos-mk03", "bhoddos-mk04"},
  ["fawogae-plantation"] = {"fawogae", "fawogae-mk02", "fawogae-mk03", "fawogae-mk04"},
  ["navens-culture"] = {"navens", "navens-mk02", "navens-mk03", "navens-mk04"},
  ["yaedols-culture"] = {"yaedols", "yaedols-mk02", "yaedols-mk03", "yaedols-mk04"},
}

script.on_event(defines.events.on_built_entity, function(event)
  -- insert modules if applicable
  if not event.entity then return end
  inventory = game.players[event.player_index].get_main_inventory()
  if not inventory then return end
  local module_proxy_exists = false
  -- for each proxy
  for p, proxy in pairs(event.entity.surface.find_entities_filtered{area = event.entity.bounding_box, type = "item-request-proxy"}) do
    local new_requests = {}
    -- for each request (different item types count as different requests)
    for p, plan in pairs(proxy.insert_plan) do
      -- if target inventory is valid
      if event.entity.get_module_inventory().index == plan.items.in_inventory[1].inventory then
        -- amount to insert or amount in players inventory, whichever is greater
        local insert = inventory.get_item_count{name = plan.id.name, quality = plan.id.quality} >= #plan.items.in_inventory and #plan.items.in_inventory or inventory.get_item_count{name = plan.id.name, quality = plan.id.quality}
        -- if player has items in inventory
        if insert > 0 then
          -- add to module inventory and remove from player
          proxy.proxy_target.get_module_inventory().insert{name = plan.id.name, quality = plan.id.quality, count = insert}
          inventory.remove({name = plan.id.name, quality = plan.id.quality, count = insert})
        end
      end
    end
    local total_requests = 0
    -- add missing modules to a new list
    for p, plan in pairs(proxy.insert_plan) do
      -- if target inventory is valid
      if event.entity.get_module_inventory().index == plan.items.in_inventory[1].inventory then
        -- if amount in module slots is less than requested
        if event.entity.get_module_inventory().get_item_count{name = plan.id.name, quality = plan.id.quality} < #plan.items.in_inventory then
          module_proxy_exists = true
          new_requests[#new_requests+1] = {
            id = {
              name = plan.id.name,
              quality = plan.id.quality,
              count = 1
            },
            items = {in_inventory = {}}
          }
          for i=1, #plan.items.in_inventory - event.entity.get_module_inventory().get_item_count{name = plan.id.name, quality = plan.id.quality}, 1 do
            new_requests[#new_requests].items.in_inventory[#new_requests[#new_requests].items.in_inventory+1] = {
              inventory = event.entity.get_module_inventory().index,
              stack = event.entity.get_module_inventory().get_item_count() + total_requests
            }
            total_requests = total_requests + 1
          end
        end
      else
        new_requests[#new_requests+1] = plan
      end
    end
    if proxy.proxy_target.get_module_inventory().get_item_count() ~= 0 then
      proxy.destroy()
      if #new_requests > 0 then
        event.entity.surface.create_entity{
          name = "item-request-proxy",
          position = event.entity.position,
          force = event.entity.force,
          target = event.entity,
          modules = new_requests
        }
      end
    end
  end
  -- if pymods and alienlife building and no modules in building and building is not requesting modules, insert modules
  if script.active_mods["pypostprocessing"] and alienlife_buildings[event.entity.name:sub(1,-6)] ~= nil and event.entity.get_module_inventory().get_item_count() == 0 and not module_proxy_exists then
    local counts = {}
    -- get the number of each module in inventory
    for m, module in pairs(alienlife_buildings[event.entity.name:sub(1,-6)]) do
      counts[#counts+1] = inventory.get_item_count{name = module} >= event.entity.get_module_inventory().count_empty_stacks(true, true) and event.entity.get_module_inventory().count_empty_stacks(true, true) or inventory.get_item_count{name = module}
    end
    -- amount to insert or amount in players inventory, whichever is greater
    for i=#counts, 1, -1 do
      -- if player has correct items in inventory
      if counts[i] > 0 then
        event.entity.get_module_inventory().insert{name = alienlife_buildings[event.entity.name:sub(1,-6)][i], count = counts[i]}
        inventory.remove({name = alienlife_buildings[event.entity.name:sub(1,-6)][i], count = counts[i]})
        goto continue
      end
    end
    ::continue::
  end

  -- todo slaughterhouse

end)