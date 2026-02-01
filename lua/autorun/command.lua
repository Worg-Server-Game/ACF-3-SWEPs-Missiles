local PrintWhiteList = {
    Caliber         = true,
    ProjMass        = true,
    FillerMass	    = true,
    Type            = true,
    MuzzleVel       = true,
    ProjLen	        = true,
    Tracer          = true,

    DetAngle	    = true,
    Standoff	    = true,
    LinerMass	    = true,
    CartMass	    = true,
    PropMass	    = true,
    CasingMass	    = true,
    JetMass		    = true,
    JetMinVel       = true,
    JetMaxVel       = true,
    BoomFillerMass  = true,
    RoundVolume 	= true,	
    BreakupDist 	= true,	
    BreakupTime 	= true,
    LimitVel        = true,
}

local AdditionalString = {
    Caliber         = "",
    ProjMass        = "ACF",
    FillerMass	    = "",
    Type            = "ACF",
    MuzzleVel       = "ACF",
    ProjLen	        = "ACF",
    Tracer          = "",
    LimitVel        = "",

    DetAngle	    = "ACFHEAT",
    Standoff	    = "ACFHEAT",
    LinerMass	    = "ACFHEAT",
    CartMass	    = "ACFHEAT",
    PropMass	    = "ACFHEAT",
    CasingMass	    = "ACFHEAT",
    JetMass		    = "ACFHEAT",
    JetMinVel       = "ACFHEAT",
    JetMaxVel       = "ACFHEAT",
    BoomFillerMass  = "ACFHEAT",
    RoundVolume 	= "ACFHEAT",	
    BreakupDist 	= "ACFHEAT",	
    BreakupTime 	= "ACFHEAT",
}

function getDataFromAmmo(ply)
    Ammo = ply:GetEyeTrace().Entity

    if not Ammo:IsValid() then
        print("Youre not looking at a valid entity")
        return
    end

    if Ammo:GetClass() != "acf_ammo" then
        print("Youre not looking at an ACF Ammo box")
        return
    end


    print("Data of your ammo box:")
    for i, v in pairs(Ammo.BulletData) do
        if (!PrintWhiteList[i]) then continue end

        local Print = AdditionalString[i] .. i

        local value = v


        if i == "Caliber" then value = value * 10 end // missile caliber is in cm for some reason
        if i == "Type" then value = '"' .. value .. '"' end // add "" so it can just be copy pasted into the code

        print("SWEP." ..  Print .. " = " .. value)
    end
end

concommand.Add( "acf_sweps_getDataFromAmmo", getDataFromAmmo, true, "Gets Data from an ammo crate to be imported for ACF Sweps")
