script.on_event(defines.events.on_built_entity, function(event)
  if not event.entity then return end
  inventory = game.players[event.player_index].get_main_inventory()
  if not inventory then return end
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
end)