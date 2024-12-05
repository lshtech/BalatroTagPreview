--- STEAMODDED HEADER
--- MOD_NAME: Tag Preview
--- MOD_ID: TagPreview
--- MOD_AUTHOR: [JK]
--- MOD_DESCRIPTION: Preview the Jokers you will get with Tags

----------------------------------------------
------------MOD CODE -------------------------

local current_tags = {}
local obj_type = type
function joker_for_tag(rarity, forced_key, key_append, edition, eternal, perishable, rental, load_sticker, legendary)
  local type = 'Joker'
  local center = G.P_CENTERS.j_joker
  local center_key = 'j_joker'

  if forced_key and not G.GAME.banned_keys[forced_key] then
    center = G.P_CENTERS[forced_key]
    type = center.set or type
  else
    local _pool, _pool_key = get_current_pool(type, rarity, legendary, key_append)
    center_key = tostring(pseudorandom_element(_pool, pseudoseed(_pool_key)))
    local it = 1
    while center_key == 'UNAVAILABLE' do
      it = it + 1
      center_key = tostring(pseudorandom_element(_pool, pseudoseed(_pool_key .. '_resample' .. it)))
    end

    center = G.P_CENTERS[center_key]
  end

  local card = Card(
    0, 0, G.CARD_W, G.CARD_H, nil, center,
    {
      bypass_discovery_center = true,
      bypass_discovery_ui = true,
    }
  )

  card.states.collide.can = false
  card.states.hover.can = false
  card.states.drag.can = false
  card.states.click.can = false
  card.states.visible = false

  if load_sticker then
    if eternal then
      card:set_eternal(true)
    end
    if perishable then
      card:set_perishable(true)
    end
    if rental then
      card:set_rental(true)
    end
  else
    if G.GAME.modifiers.all_eternal then
      card:set_eternal(true)
    else
      if G.GAME.modifiers.enable_eternals_in_shop and pseudorandom('stake_shop_joker_eternal' .. G.GAME.round_resets.ante) > 0.7 then
        card:set_eternal(true)
      elseif G.GAME.modifiers.enable_perishables_in_shop and pseudorandom('ssjp' .. G.GAME.round_resets.ante) / 0.7 > 0.7 then
        card:set_perishable(true)
      end
    end
    if G.GAME.modifiers.enable_rentals_in_shop and pseudorandom('ssjr' .. G.GAME.round_resets.ante) > 0.7 then
      card:set_rental(true)
    end
  end
  
  if edition and G.P_CENTERS[edition] then
    card:set_edition(edition, true, true)
  elseif edition and obj_type(edition) == 'table' then
    if edition.key then
      card:set_edition(edition.key, true, true)
    end
  elseif edition and G.P_CENTERS["e_" .. edition] then
    card:set_edition("e_" .. edition, true, true)
  elseif G.GAME.modifiers.cry_force_random_edition then
    local cry_edition = cry_poll_random_edition()
    card:set_edition(cry_edition, true, true)
  else
    local new_edition = poll_edition('edi' .. (key_append or '') .. G.GAME.round_resets.ante)
    card:set_edition(new_edition, true, true)
  end
  return card
end

function add_card_to_tag(tag)
  local card = nil
  --  Base game tags
  if tag.name == 'Uncommon Tag' then
    card = joker_for_tag(0.9, nil, 'utag')
  elseif tag.name == 'Rare Tag' then
    card = joker_for_tag(0.99, nil, 'rtag')
  elseif tag.name == 'Negative Tag' then
    card = joker_for_tag(nil, nil, 'etag', "e_negative")
  elseif tag.name == 'Foil Tag' then
    card = joker_for_tag(nil, nil, 'etag', "e_foil")
  elseif tag.name == 'Holographic Tag' then
    card = joker_for_tag(nil, nil, 'etag', "e_holo")
  elseif tag.name == 'Polychrome Tag' then
    card = joker_for_tag(nil, nil, 'etag', "e_polychrome")

  -- Ortalab tags
  elseif tag.key == 'tag_ortalab_common' then
    card = joker_for_tag(0, nil, 'ctag')
  elseif tag.key == 'tag_ortalab_anaglyphic' then
    card = joker_for_tag(nil, nil, 'etag', "e_ortalab_anaglyphic")
  elseif tag.key == 'tag_ortalab_fluorescent' then
    card = joker_for_tag(nil, nil, 'etag', "e_ortalab_fluorescent")
  elseif tag.key == 'tag_ortalab_greyscale' then
    card = joker_for_tag(nil, nil, 'etag', "e_ortalab_greyscale")
  elseif tag.key == 'tag_ortalab_overexposed' then
    card = joker_for_tag(nil, nil, 'etag', "e_ortalab_overexposed")
  elseif tag.key == 'tag_ortalab_soul' then
    card = joker_for_tag(1, nil, 'etag', nil, nil, nil, nil, true)

  -- Bonus Blinds
  elseif tag.key == 'tag_bb_poly_negative' then
    card = joker_for_tag(nil, nil, 'etag', "e_bb_bb_antichrome")

  -- Bunco
  elseif tag.key == 'tag_bunc_glitter' then
    card = joker_for_tag(nil, nil, 'etag', "e_bunc_glitter")
  elseif tag.key == 'tag_bunc_fluorescent' then
    card = joker_for_tag(nil, nil, 'etag', "e_bunc_fluorescent")
  elseif tag.key == 'tag_bunc_eternal' then
    card = joker_for_tag(nil, nil, 'etag', nil, true)
  elseif tag.key == 'tag_bunc_perishable' then
    card = joker_for_tag(nil, nil, 'etag', nil, nil, true)
  elseif tag.key == 'tag_bunc_scattering' then
    card = joker_for_tag(nil, nil, 'etag')
    SMODS.Stickers['bunc_scattering']:apply(card, true)
  elseif tag.key == 'tag_bunc_hindered' then
    card = joker_for_tag(nil, nil, 'etag')
    SMODS.Stickers['bunc_hindered']:apply(card, true)
  elseif tag.key == 'tag_bunc_reactive' then
    card = joker_for_tag(nil, nil, 'etag')
    SMODS.Stickers['bunc_reactive']:apply(card, true)
  elseif tag.key == 'tag_bunc_rental' then
    card = joker_for_tag(nil, nil, 'etag', nil, nil, nil, true)

  -- Familiar
  elseif tag.key == 'tag_fam_aureate' then
    card = joker_for_tag(nil, nil, 'etag', "e_fam_aureate")
  elseif tag.key == 'tag_fam_speckle' then
    card = joker_for_tag(nil, nil, 'etag', "e_fam_speckle")
  elseif tag.key == 'tag_fam_statics' then
    card = joker_for_tag(nil, nil, 'etag', "e_fam_statics")

  -- Cryptid
  elseif tag.key == 'tag_cry_epic' then
    card = joker_for_tag(1, nil, 'rtag', nil, nil, nil, nil, nil, nil)
  elseif tag.key == 'tag_cry_glitched' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_glitched")
  elseif tag.key == 'tag_cry_mosaic' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_mosaic")
  elseif tag.key == 'tag_cry_oversat' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_oversat")
  elseif tag.key == 'tag_cry_oversat' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_oversat")
  elseif tag.key == 'tag_cry_glass' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_glass")
  elseif tag.key == 'tag_cry_gold' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_gold")
  elseif tag.key == 'tag_cry_blur' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_blur")
  elseif tag.key == 'tag_cry_astral' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_astral")
  elseif tag.key == 'tag_cry_m' then
    card = joker_for_tag(nil, nil, 'etag', "e_cry_m")
  elseif tag.key == 'tag_cry_double_m' then
			local option = {}
			for k, _ in pairs(Cryptid.M_jokers) do
				if G.P_CENTERS[k] then
					option[#option + 1] = k
				end
			end
    card = joker_for_tag(nil, pseudorandom_element(option, pseudoseed("M_is_love_M_is_life")), 'etag', "e_cry_m")
  elseif tag.key == 'tag_cry_gourmand' then
    card = joker_for_tag(nil, pseudorandom_element(Cryptid.food, pseudoseed("cry_gourmand_tag")), 'rtag')
  elseif tag.key == 'tag_cry_rework' then
    card = joker_for_tag(nil, (tag.ability.rework_key or "j_scholar"), 'rtag', "e_foil")
  elseif tag.key == 'tag_cry_schematic' then
    card = joker_for_tag(nil, "j_brainstorm", 'etag')


  else
    card = joker_for_tag(nil, nil, 'etag', tag.config.edition)
  end

  tag.replace_card = card

  return tag
end

local tag_save_ref = Tag.save
function Tag:save()
  local save = tag_save_ref(self)

  if self.replace_card then
    save.replace_card_table = {
      center_key = self.replace_card.config.center_key or 'j_joker',
      edition = self.replace_card.edition or {},
      eternal = self.replace_card.ability.eternal,
      perishable = self.replace_card.ability.perishable,
      rental = self.replace_card.ability.rental,
    }
  end

  return save
end

local tag_load_ref = Tag.load
function Tag:load(tag_savetable)
  tag_load_ref(self, tag_savetable)

  if tag_savetable.replace_card_table then
    local table = tag_savetable.replace_card_table
    local card = joker_for_tag(nil, table.center_key, nil,
      table.edition,
      true,
      table.eternal,
      table.perishable,
      table.rental,
      true
    )

    self.replace_card = card
  end
end

local create_UIBox_blind_tag_ref = create_UIBox_blind_tag
function create_UIBox_blind_tag(blind_choice, run_info)
  local tag_UIBox = create_UIBox_blind_tag_ref(blind_choice, run_info)
  local tag = tag_UIBox.config.ref_table
  if (tag.config.type == 'store_joker_create' or tag.config.type == 'store_joker_modify') and (not current_tags[blind_choice] or current_tags[blind_choice].key ~= tag.key) then
    tag = add_card_to_tag(tag)
    tag_UIBox.config.ref_table = tag
    current_tags[blind_choice] = tag
  elseif (tag.config.type == 'store_joker_create' or tag.config.type == 'store_joker_modify') and current_tags[blind_choice].key == tag.key then
    tag_UIBox.config.ref_table = current_tags[blind_choice]
  end

  return tag_UIBox
end

local add_tag_ref = add_tag
function add_tag(_tag)
  add_tag_ref(_tag)

  if (_tag.config.edition) then
    G.tag_joker_edition_count = (G.tag_joker_edition_count or 0) + 1
  end
end

local reset_blinds_ref = reset_blinds
function reset_blinds()
  reset_blinds_ref()
  if G.GAME.round_resets.blind_states.Boss == 'Defeated' then
    current_tags = {}
  end
end

local tag_apply_to_run_ref = Tag.apply_to_run
function Tag:apply_to_run(_context)
  if not self.triggered and self.config.type == _context.type then
    if _context.type == 'tag_add' then
      if self.name == 'Double Tag' and _context.tag.key ~= 'tag_double' then
        local lock = self.ID
        G.CONTROLLER.locks[lock] = true
        self:yep('+', G.C.BLUE, function()
          if _context.tag.ability and _context.tag.ability.orbital_hand then
            G.orbital_hand = _context.tag.ability.orbital_hand
          end
          local tag = Tag(_context.tag.key)
          if tag.config.type == 'store_joker_create' or tag.config.type == 'store_joker_modify' then
            tag = add_card_to_tag(tag)
          end
          add_tag(tag)
          G.orbital_hand = nil
          G.CONTROLLER.locks[lock] = nil
          return true
        end)
        self.triggered = true
      end
    elseif _context.type == 'store_joker_create' then
      local lock = self.ID
      G.CONTROLLER.locks[lock] = true

      local card = nil
      local card_properties = {
        edition = nil,
        eternal = nil,
        perishable = nil,
        rental = nil,
      }
      --if (self.name == 'Rare Tag' or self.name == 'Uncommon Tag' or self.key == 'tag_ortalab_anaglyphic') then
      if not self.replace_card then
        self = add_card_to_tag(self)
      end
      card_properties.edition = self.replace_card.edition
      card_properties.eternal = self.replace_card.ability.eternal
      card_properties.perishable = self.replace_card.ability.perishable
      card_properties.rental = self.replace_card.ability.rental

      card = create_card(nil, _context.area, nil, nil, nil, nil, self.replace_card.config.center_key, nil)

      card.edition = nil
      card.ability.eternal = nil
      card.ability.perishable = nil
      card.ability.rental = nil

      card.ability.tag_joker = true

      if card_properties.eternal then
        card:set_eternal(card_properties.eternal)
      end
      if card_properties.perishable then
        card:set_perishable(card_properties.perishable)
      end
      if card_properties.rental then
        card:set_rental(card_properties.rental)
      end

      create_shop_card_ui(card, 'Joker', _context.area)
      card.states.visible = false
      self:yep('+', self.name == 'Rare Tag' and G.C.RED or G.C.GREEN, function()
        card:start_materialize({ self.name == 'Rare Tag' and G.C.RED or G.C.GREEN })
        if card_properties.edition then
          card:set_edition(card_properties.edition)
        end

        card.ability.couponed = true
        local cost = card.cost * 0.5
        card:set_cost()
        if self.key == "tag_cry_epic" then
          card.cost = cost
        end
        G.CONTROLLER.locks[lock] = nil
        return true
      end)
      --end

      self.triggered = true
      
      G.CONTROLLER.locks[lock] = nil
      return card
    elseif _context.type == 'store_joker_modify' then
      local _applied = nil
      if not _context.card.ability.tag_joker and _context.card.edition then
        _context.card.ability.j_has_edition = true
      end
      if not _context.card.ability.tag_joker and not _context.card.edition and not _context.card.temp_edition and _context.card.ability.set == 'Joker' then
        local lock = self.ID
        G.CONTROLLER.locks[lock] = true

        _context.card.states.visible = false

        local card_properties = {
          eternal = nil,
          perishable = nil,
          rental = nil,
        }

        if self.config.edition then
          if not self.replace_card then
            self = add_card_to_tag(self)
          end
          card_properties.eternal = self.replace_card.ability.eternal
          card_properties.perishable = self.replace_card.ability.perishable
          card_properties.rental = self.replace_card.ability.rental

          _context.card.temp_edition = true

          _context.card.config = {
            card = {},
            center = self.replace_card.config.center
          }
          _context.card.ability = {}

          _context.card:set_ability(self.replace_card.config.center, true)
          _context.card:set_base(nil, true)

          if card_properties.eternal then
            _context.card:set_eternal(card_properties.eternal)
          end
          if card_properties.perishable then
            _context.card:set_perishable(card_properties.perishable)
          end
          if card_properties.rental then
            _context.card:set_rental(card_properties.rental)
          end

          self:yep('+', G.C.DARK_EDITION, function()
            _context.card:start_materialize({ G.C.DARK_EDITION })

            if G.P_CENTERS[self.config.edition] then
              _context.card:set_edition(self.config.edition, true)
            elseif G.P_CENTERS["e_" .. self.config.edition] then
              _context.card:set_edition("e_" .. self.config.edition, true)
            end

            _context.card.ability.couponed = true
            _context.card:set_cost()
            _context.card.temp_edition = nil
            G.CONTROLLER.locks[lock] = nil
            return true
          end)
          _applied = true
          _context.card.ability.j_has_edition = nil
        end
        self.triggered = true
        G.CONTROLLER.locks[lock] = nil
      end
      return _applied
    end
  end
  return tag_apply_to_run_ref(self, _context)
end

local card_h_popup_ref = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
  local popup = card_h_popup_ref(card)

  if card.ability_UIBox_table and card.ability_UIBox_table.table_card then
    local AUT = card.ability_UIBox_table.table_card

    local card_type_colour = get_type_colour(AUT.card.config.center or AUT.card.config, AUT.card)
    local card_type_background = (card_type_colour and darken(G.C.BLACK, 0.1)) or
        G.C.SET[AUT.card_type] or
        { 0, 1, 1, 1 }

    local outer_padding = 0.05
    local card_type = localize('k_' .. string.lower(AUT.card_type))

    if (AUT.card_type == 'Joker' or (AUT.badges and AUT.badges.force_rarity)) then
      card_type = ({localize('k_common'), localize('k_uncommon'), localize('k_rare'), localize('k_legendary'), localize('k_fusion'),
        ['cry_epic'] = 'Epic', ['cry_exotic'] = 'Exotic', ['cere_divine'] = 'Divine', ['evo'] = 'Evolved', ['poke_safari'] = 'Safari'})[AUT.card.config.center.rarity]
    end

    local main_right = {}
    local info_boxes = {}
    local badges = {}

    if AUT.badges.card_type or AUT.badges.force_rarity then
      badges[#badges + 1] = create_badge(card_type, card_type_colour, nil, 1.2)
    end
    if AUT.badges then
      for k, v in ipairs(AUT.badges) do
        if v == 'negative_consumable' then v = 'negative' end
        badges[#badges + 1] = create_badge(localize(v, "labels"), get_badge_colour(v))
      end
    end

    if AUT.info then
      for k, v in ipairs(AUT.info) do
        info_boxes[#info_boxes + 1] =
        {
          n = G.UIT.R,
          config = { align = "cr" },
          nodes = {
            {
              n = G.UIT.R,
              config = { align = "cm", colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, padding = 0.05, emboss = 0.05 },
              nodes = {
                info_tip_from_rows(v, v.name),
              }
            }
          }
        }
      end
    end

    if popup.nodes and popup.nodes[1].nodes then
      info_boxes[#info_boxes + 1] = popup.nodes[1].nodes[1]
      info_boxes[#info_boxes].config.align = "cr"
    end

    if AUT.main then
      main_right =
      {
        n = G.UIT.ROOT,
        config = { align = 'cl', colour = G.C.CLEAR },
        nodes = {
          {
            n = G.UIT.C,
            config = { align = "cl", func = 'show_infotip', object = Moveable(), ref_table = next(info_boxes) and info_boxes or nil },
            nodes = {
              {
                n = G.UIT.R,
                config = { padding = outer_padding, r = 0.12, colour = lighten(G.C.JOKER_GREY, 0.5), emboss = 0.07 },
                nodes = {
                  {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.07, r = 0.1, colour = adjust_alpha(card_type_background, 0.8) },
                    nodes = {
                      name_from_rows(AUT.name),
                      {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1, no_fill = true },
                        nodes = {
                          { n = G.UIT.O, config = { object = AUT.card } }
                        }
                      },
                      desc_from_rows(AUT.main),
                      badges[1] and { n = G.UIT.R, config = { align = "cm", padding = 0.03 }, nodes = badges } or nil,
                    }
                  }
                }
              }
            }
          },
        }
      }
    end

    AUT.card.states.visible = true

    return main_right
  end

  return popup
end

local tag_get_uibox_table_ref = Tag.get_uibox_table
function Tag:get_uibox_table(tag_sprite)
  local tag_sprite = tag_get_uibox_table_ref(self, tag_sprite)

  if tag_sprite.ability_UIBox_table then
    if (self.config.type == 'store_joker_create' or self.config.type == 'store_joker_modify') and not self.replace_card and current_tags[self.ability.blind_type] and current_tags[self.ability.blind_type].key == self.key then
      self.replace_card = current_tags[self.ability.blind_type].replace_card
    end
    if self.replace_card then
      local tag_ability_UIBox_table_card = nil

      local card = nil

      if self.replace_card then
        card = self.replace_card
      end

      if card then
        tag_ability_UIBox_table_card = {
          main = {},
          info = {},
          type = {},
          name = nil,
          badges = {},
          card = nil,
        }
        tag_ability_UIBox_table_card = card:generate_UIBox_ability_table()
        tag_ability_UIBox_table_card.card = card

        tag_sprite.ability_UIBox_table.table_card = tag_ability_UIBox_table_card
      end
    end
  end

  return tag_sprite
end

local tag_generate_UI_ref = Tag.generate_UI
function Tag:generate_UI(_size)
  local tag_sprite_tab, tag_sprite = tag_generate_UI_ref(self, _size)

  local tag_sprite_hover_ref = tag_sprite.hover

  tag_sprite.hover = function(_self)
    --tag_sprite_hover_ref(self)
    if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
      if not _self.hovering and _self.states.visible then
        _self.hovering = true
        if _self == tag_sprite then
          _self.hover_tilt = 3
          _self:juice_up(0.05, 0.02)
          play_sound('paper1', math.random() * 0.1 + 0.55, 0.42)
          play_sound('tarot2', math.random() * 0.1 + 0.55, 0.09)
        end

        self:get_uibox_table(tag_sprite)
        _self.config.h_popup = G.UIDEF.card_h_popup(_self)
        _self.config.h_popup_config = {
          align = not (G.STATE == G.STATES.MENU or G.SETTINGS.paused) and 'tl' or 'cl',
          offset = { x = -0.1, y = not (G.STATE == G.STATES.MENU or G.SETTINGS.paused) and _self.T.h or 0 },
          parent = _self
        }
        Node.hover(_self)
        if _self.children.alert then
          _self.children.alert:remove()
          _self.children.alert = nil
          if self.key and G.P_TAGS[self.key] then G.P_TAGS[self.key].alerted = true end
          G:save_progress()
        end
      end
    end

    local card = nil
    if self.replace_card then
      card = self.replace_card
    end
    if card then
      card.states.visible = true
    end
  end

  local tag_sprite_stop_hover_ref = tag_sprite.stop_hover

  tag_sprite.stop_hover = function(_self)
    tag_sprite_stop_hover_ref(_self)
    local card = nil
    if self.replace_card then
      card = self.replace_card
    end
    if card then
      card.states.visible = false
    end
  end

  return tag_sprite_tab, tag_sprite
end
--[[
local create_card_for_shop_ref = create_card_for_shop
function create_card_for_shop(area)
  if not (area == G.shop_jokers and G.SETTINGS.tutorial_progress and G.SETTINGS.tutorial_progress.forced_shop and G.SETTINGS.tutorial_progress.forced_shop[#G.SETTINGS.tutorial_progress.forced_shop]) then
    local forced_tag = nil
    for _, v in ipairs(G.GAME.tags) do
      if not forced_tag then
        forced_tag = v:apply_to_run({ type = 'store_joker_create', area = area })
        if forced_tag then
          return forced_tag
        end
      end
    end

    G.tag_joker_edition_count = G.tag_joker_edition_count or 0

    if G.tag_joker_edition_count > 0 then
      local other_area = CardArea(
        G.hand.T.x + 0,
        G.hand.T.y + G.ROOM.T.y + 9,
        G.CARD_W,
        G.CARD_H,
        { card_limit = 1, type = 'shop', highlight_limit = 0 }
      )

      other_area.states.visible = false

      local card = create_card_for_shop_ref(other_area)

      card.states.visible = false

      card:set_card_area(area)
      delay(0.2)

      if card.ability.set == 'Joker' and not card.ability.tag_joker and not card.ability.j_has_edition and not card.edition then
        G.tag_joker_edition_count = G.tag_joker_edition_count - 1
      end

      if G.tag_joker_edition_count <= 0 and G.state_just_loaded then
        card:start_materialize()
      end

      return card
    end
  end
  return create_card_for_shop_ref(area)
end]]

local game_start_run_ref = Game.start_run
function Game:start_run(args)
  game_start_run_ref(self, args)

  args = args or {}

  local saveTable = args.savetext or nil

  if saveTable then
    G.state_just_loaded = true
  end
end

local temp_state = nil
local cor = Card.open
function Card:open()
  temp_state = G.hand.states.visible
  if temp_state then
   -- G.hand.states.visible = false
  end
  cor(self)
end

local G_FUNCS_end_consumeable_ref=G.FUNCS.end_consumeable
G.FUNCS.end_consumeable = function(e, delayfac)
  G_FUNCS_end_consumeable_ref(e, delayfac)
  if G.hand.states.visible ~= temp_state then
   -- G.hand.states.visible = temp_state
   -- temp_state = nil
  end
end

----------------------------------------------
------------MOD CODE END----------------------