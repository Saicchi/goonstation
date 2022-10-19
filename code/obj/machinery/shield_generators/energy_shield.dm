// buncha funky vars going on here. have some defines

/// Block gases, both atmospheric and chemsmoke
#define SHIELD_BLOCK_GAS 1
/// Block liquids and gases
#define SHIELD_BLOCK_FLUID 2
/// Block everything; functionally a wall of energy
#define SHIELD_BLOCK_ALL 3

// For the orientation
#define VERTICAL 0
#define HORIZONTAL 1
/obj/machinery/shieldgenerator/energy_shield
	name = "Energy-Shield Generator"
	desc = "Solid matter can pass through the shields generated by this generator."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "energyShield"
	density = FALSE
	var/orientation = HORIZONTAL  //shield extend direction 0 = north/south, 1 = east/west
	power_level = SHIELD_BLOCK_GAS //1 for atmos shield, 2 for liquid, 3 for solid material
	var/max_power = SHIELD_BLOCK_ALL
	var/min_power = SHIELD_BLOCK_GAS
	min_range = 1
	max_range = 4
	direction = "dir"
	layer = OBJ_LAYER

	nocell
		starts_with_cell = FALSE

	New()
		..()
		display_active.icon_state = "energyShieldOn"
		src.power_usage = 5

	ui_static_data(mob/user)
		. = ..()
		. += list(
			"power_min" = src.min_power,
			"power_max" = src.max_power,
			"power_description" = list("Blocks gases", "Blocks liquids and gases", "Blocks everything")
		)

	ui_data(mob/user)
		. = ..()
		. += list(
			"power_current" = src.power_level
		)

	ui_act(action, params, datum/tgui/ui)
		. = ..()
		if (.)
			return
		switch(action)
			if("toggle")
				attack_hand(ui.user)
				. = TRUE
			if("anchor")
				if (!ui.user.equipped() || !iswrenchingtool(ui.user.equipped()))
					boutput(ui.user,"You need a wrench for that!")
					return
				else
					attackby(ui.user.equipped(), ui.user)
					. = TRUE
			if("range")
				var/selected_range = clamp(params["range"], src.min_range, src.max_range)
				range = selected_range
				. = TRUE
			if("power")
				var/selected_power = clamp(params["power"], src.min_power, src.max_power)
				power_level = selected_power
				. = TRUE

	get_desc(dist, mob/user)
		..()
		var/charge_percentage = 0
		if (PCEL?.charge > 0 && PCEL.maxcharge > 0)
			charge_percentage = round((PCEL.charge/PCEL.maxcharge)*100)
			. += "It has [PCEL.charge]/[PCEL.maxcharge] ([charge_percentage]%) battery power left."
		else
			. += "It seems to be missing a usable battery."
		. += "The unit will consume [get_draw()] power a second."
		. += "The range setting is set to [src.range]."
		. += "The power setting is set to [src.power_level]."

	shield_on()
		if (PCEL && PCEL.charge > 0) //first, try to activate off cell power
			generate_shield()
		else //no cell power? attempt to grid boot
			if (!line_powered()) //no cell, no grid, no activation
				src.power_usage = 0
			else //activate off line power
				generate_shield()
				src.power_usage = get_draw()


	pulse(var/mob/user)
		ui_interact(user)
		return
		if(active)
			boutput(user, "<span class='alert'>You can't change the power level or range while the generator is active.</span>")
			return
		var/list/choices = list("Set Range")
		if(max_power != min_power)
			choices += "Set Power Level"
		var/input
		if(length(choices) == 1)
			input = choices[1]
		else
			input = input("Select a config to modify!", "Config", null) as null|anything in choices
		if(input && (user in range(1,src)))
			switch(input)
				if("Set Range")
					src.set_range(user)
				if("Set Power Level")
					var/the_level = input("Enter a power level from [src.min_power]-[src.max_power]. Higher levels use more power.","[src.name]",1) as null|num
					if(!the_level)
						return
					if(BOUNDS_DIST(user, src) > 0)
						boutput(user, "<span class='alert'>You flail your arms at [src] from across the room like a complete muppet. Move closer, genius!</span>")
						return
					the_level = clamp(the_level, min_power, max_power)
					src.power_level = the_level
					boutput(user, "<span class='notice'>You set the power level to [src.power_level].</span>")

	//Code for placing the shields and adding them to the generator's shield list
	proc/generate_shield()
		update_orientation()
		var/xa= -range-1
		var/ya= -range-1
		var/turf/T
		if (range == 0)
			var/obj/forcefield/energyshield/S = new /obj/forcefield/energyshield(get_turf(src))
			S.icon_state = "enshieldw"
			src.deployed_shields += S
		else
			for (var/i = 0-range, i <= range, i++)
				if (orientation)
					T = locate((src.x+i),(src.y),src.z)
					xa++
					ya = 0
				else
					T = locate((src.x),(src.y+i), src.z)
					ya++
					xa = 0

				if (src.checkForcefieldAllowed(T))
					createForcefieldObject(xa, ya);

		src.anchored = TRUE
		src.active = TRUE

		// update_nearby_tiles()
		playsound(src.loc, src.sound_on, 50, 1)
		if (src.power_level == 1)
			display_active.color = "#0000FA"
		else if (src.power_level == 2)
			display_active.color = "#00FF00"
		else
			display_active.color = "#FA0000"
		build_icon()

	//Changes shield orientation based on direction the generator is facing
	proc/update_orientation()
		if (src.dir == NORTH || src.dir == SOUTH)
			orientation = VERTICAL
		else
			orientation = HORIZONTAL

	proc/createForcefieldObject(xa, ya, turf/T)
		if(isnull(T))
			T = locate((src.x + xa), (src.y + ya), src.z)
		var/obj/forcefield/energyshield/S = new /obj/forcefield/energyshield(T, src, TRUE)
		S.layer = 2
		src.deployed_shields += S
		return S

	/// Proc to check if it's valid to place a force field on a given tile.
	/// Checks for turf density, then blocking objects; however, we ignore ON_BORDER objects such as railings
	/// Mobs are not considered.
	proc/checkForcefieldAllowed(var/turf/T)
		. = FALSE
		if (T.density)
			return
		for (var/obj/O in T) // don't care about mobs
			if (!O.Cross())
				if (O.flags & ON_BORDER) // it's a railing or some shit, we can ignore
					continue
				return // something dense or otherwise uncrossable, no dice
		return TRUE



/obj/machinery/shieldgenerator/energy_shield/doorlink
	name = "Door-Shield Generator"
	desc = "Interfaces with nearby doors, generating linked atmospheric or liquid shielding for them."
	icon_state = "doorShield"
	direction = ""
	max_power = SHIELD_BLOCK_FLUID
	max_range = 3
	var/emagged = FALSE

	nocell
		starts_with_cell = FALSE

	New()
		..()
		display_active.icon_state = "doorShieldOn"

	emag_act(var/mob/user) //blow out the limiter. max power increases to 3 (total blocking), but it loses the ability to throttle its operation
		if (!src.emagged)
			if (user)
				user.show_text("You short out the integrated limiting circuits.", "blue")
			src.desc += " Smells faintly of burnt electronics."
			src.emagged = 1
			src.max_power = SHIELD_BLOCK_ALL
			return 1
		else
			if (user)
				user.show_text("This has already been tampered with.", "red")
			return 0

	generate_shield()
		if (range < 1)
			return
		for (var/obj/machinery/door/D in orange(src.range,src))
			if(!D.linked_forcefield && !istype(D,/obj/machinery/door/firedoor))
				createDoorForcefield(D)

		src.anchored = 1
		src.active = 1

		// update_nearby_tiles()
		playsound(src.loc, src.sound_on, 50, 1)
		if (src.power_level == 1)
			display_active.color = "#0000FA"
		else if (src.power_level == 2)
			display_active.color = "#00FF00"
		else
			display_active.color = "#FA0000"
		build_icon()

	get_draw()
		var/shield_draw = 0
		for(var/obj/forcefield/energyshield/S in src.deployed_shields)
			shield_draw += 1 //small maintenance draw per shielded door, and full power if shield is active
			if(S.isactive) shield_draw += 15 //overall cost slightly higher per shield compared to standard generators
		return shield_draw * (src.power_level * src.power_level)

	process()
		if(src.active)
			src.get_draw()
		. = ..()

	proc/createDoorForcefield(var/obj/machinery/door/D)
		var/obj/forcefield/energyshield/S = new /obj/forcefield/energyshield (get_turf(D), src, 1) //1 update tiles

		S.layer = 2
		S.set_dir(D.dir)
		if(!src.emagged)
			S.linked_door = D
			D.linked_forcefield = S

			if(D.density != 0)
				S.setactive(0)

		src.deployed_shields += S

		return S

/obj/machinery/shieldgenerator/energy_shield/botany
	name = "smoke shield generator"
	icon_state = "botanygen"
	desc = "For all your hotboxing needs."
	density = FALSE
	min_power = SHIELD_BLOCK_GAS
	max_power = SHIELD_BLOCK_GAS

	update_orientation()
		orientation = VERTICAL

	generate_shield()
		for(var/turf/T in orange(src, range))
			if(GET_DIST(T, src) != range)
				continue
			if (!T.density && !T.gas_impermeable)
				var/obj/forcefield/energyshield/shield = createForcefieldObject(T=T)
				animate(shield, time=5 SECONDS, loop=-1, easing=SINE_EASING, color="#88FF00")
				animate(time=5 SECONDS, loop=-1, easing=SINE_EASING, color="#0088FF")

		src.anchored = TRUE
		src.active = TRUE

		playsound(src.loc, src.sound_on, 50, 1)
		display_active.color = "#00FF00"
		build_icon()

#undef SHIELD_BLOCK_GAS
#undef SHIELD_BLOCK_FLUID
#undef SHIELD_BLOCK_ALL

#undef VERTICAL
#undef HORIZONTAL
