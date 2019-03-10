// Does not work with RemoteTech because SAS control is used.
// Decouplers tagged with "entry" will be decoupled when entering the atmosphere
// Decouplers/Fairings tagged with "descend" will deploy during descend.
// Decouplers, Antennas, Solar Panels tagged with "landed" will deploy after touchdown.
// Decouplers + SRBs tagged with "drop" will deploy 2m above ground.

runoncepath("lib/lib_ui.ks").
runoncepath("lib/lib_parts.ks").
runoncepath("lib/lib_staging.ks").

print("Hideki 1 rover script").

if ship:body:name = "Eve" and ship:status <> "LANDED" {

sas off.
rcs on.

if ship:status = "ORBITING" or ship:status = "ESCAPING" {
  print("Deorbit").
  lock steering to retrograde.
  wait 10.
  set thr to 1.
  lock throttle to thr.
  local t is time:seconds.
  local lock dt to time:seconds - t.
  wait until orbit:periapsis < 38000 or dt > 120 or ship:altitude < body:atm:height.
  set thr to 0.
  wait 1.
}

lock steering to srfretrograde.
wait 5.

if ship:altitude > body:atm:height + 10000 {
  set warp to 5.
  wait until ship:altitude < body:atm:height + 10000.
  set warp to 0.
  wait 1.
}

print("Decouple for reentry").
lock steering to up.
wait 10.
partsDoEvent("ModuleDecouple", "decouple", "entry").
wait 5.
lock steering to srfretrograde.

wait until ship:altitude < body:atm:height.

partsRetractAntennas().
partsRetractSolarPanels().
wait 1.

if ship:status = "FLYING" {
  print("Science flying high").
  ag1 on.
  ag1 off.
  lock steering to srfretrograde.
  // don't make me wait for so long...
  set warpMode to "PHYSICS".
  wait 1.
  set warp to 3.
  wait until alt:radar < 6000.
  set warp to 0.
  wait 3.
  // deploy whatever fairings we have
  print("Fairings").
  partsDeployFairings("descend").
  wait 3.
  set warp to 3.
  wait until alt:radar < 5000.
  set warp to 0.
  wait 1.
  print("Science flying low").
  ag1 on.
  ag1 off.
  chutes on.
  wait until alt:radar < 4000.
  partsDoEvent("ModuleDecouple", "decouple", "descend").
  wait 1.
  
  wait until alt:radar < 1000.
  lights on.
  brakes on.

  wait until alt:radar < 3.
  // TODO: fire "drop" SRBs here
  partsDoEvent("ModuleDecouple", "decouple", "drop").

  wait until ship:status <> "FLYING".
  unlock all.

  wait 5.
  partsDoEvent("ModuleDecouple", "decouple", "landed").
  wait 30.
  partsExtendAntennas("landed").
  partsExtendSolarPanels("landed").
  ag1 on.
  ag1 off.
}

}
