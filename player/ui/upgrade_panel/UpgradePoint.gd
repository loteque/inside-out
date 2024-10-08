extends TextureRect
class_name UpgradePointUI

@export var type: UpgradeData.PointType
@export var value_max: int = 3
@export var value: int = 1
@export var wing_type: UpgradeData.WingType
@export var ship_section: UpgradeData.ShipSection

@onready var editor_control: Control = %ShipEditorControl

func set_neighbor_values(new_value):
    
    await get_parent().ready
    for point in get_parent().get_children():
        
        if point == self:
        
            continue

        await point.ready
        point.value = new_value
        print("set value on: ", self.name, value)


func validate_upgrade_point(data) -> bool:

    var type_match: bool = false
    if data[&"type"] == type:
        
        type_match = true

    else:

        print("wrong value rect type for mount point rect")

    var point_match: bool = false
    if data[&"cost"] <= value:

        point_match = true

    else:

        print("cost exceeds available mount points: ", data[&"cost"], value)


    var section_match: bool = false
    if data[&"ship_section"] == ship_section:
        
        section_match = true

    else:

        print(
        
            "part cannot be applied to " 
            + UpgradeData.ship_section[data[&"ship_section"]] 
            + " section of ship"
        
        )
    
    return type_match and point_match and section_match


func upgrade_points(id):
    
    print("upgraded points on: ", id)
    match id:
        UpgradeData.Validator.ValidPartName.WING_PORT_MED:
            await editor_control.show_points(
                editor_control.port_wing_upgrade_1
            )
        
        UpgradeData.Validator.ValidPartName.WING_STARBOARD_MED:
            await editor_control.show_points(
                editor_control.star_wing_upgrade_1
            )
        
        UpgradeData.Validator.ValidPartName.CANNON_PORT:
            await editor_control.show_points(
                editor_control.port_fuselage_upgrade
            )

        UpgradeData.Validator.ValidPartName.CANNON_STARBOARD:
            await editor_control.show_points(
                editor_control.star_fuselage_upgrade
            )

        UpgradeData.Validator.ValidPartName.LAUNCH_TUBE_SMALL:
            await editor_control.show_points(
                editor_control.stern_upgrade
            )

        UpgradeData.Validator.ValidPartName.LAZER_BOW:
            await editor_control.show_points(
                editor_control.bow_upgrade
            )

        UpgradeData.Validator.ValidPartName.LAZER_STERN:
            await editor_control.show_points(
                editor_control.stern_upgrade
            )

        _:
            return