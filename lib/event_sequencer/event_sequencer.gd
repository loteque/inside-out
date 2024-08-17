extends Node
class_name EventSequencer
#plugin name: DEP; DEP is not a Dialog Editor Plugin


@export var dialog_box: PackedScene
@export var characters: Array[Character]
@export var sequence: Array[Event]


@onready var backdrop_display: TextureRect = TextureRect.new()
@onready var wait_timer: Timer = Timer.new()


var dialog_display: DialogBox
var is_awaiting_user_input: bool = true

var current_event_idx: int = 0:
    set(value):
        
        if value >= sequence.size(): 
            
            status = Status.DONE

        current_event_idx = value


signal done()
var status = Status.OK
enum Status {
    OK = 0,
    INPUT_PAUSED = 1,
    DONE = 2,
    ERROR = 10,
}


func execute_event(event_idx: int):
        
        if status == Status.DONE: return

        status = Status.INPUT_PAUSED
        sequence[event_idx].done.connect(_on_event_done)
        sequence[event_idx].execute()
        
        if sequence[event_idx].done.is_connected(_on_event_done):
            
            sequence[event_idx].done.disconnect(_on_event_done)
        
        var next_event_idx = event_idx + 1
        current_event_idx = next_event_idx

        if status == Status.DONE:
            
            return

        
        if sequence[current_event_idx].autostart:
            
            if sequence[event_idx].status == Event.Status.BUSY:
                await sequence[event_idx].done
                
            execute_event(current_event_idx)
        
        status = Status.OK


func _unhandled_input(event):
    
    if !(event is InputEventKey):
        
        return

    if status == Status.INPUT_PAUSED:
        
        return

    # refactor hardcoded keycode to use event_input
    if event.pressed and event.keycode == KEY_SPACE:
        
        if status == Status.DONE:

            done.emit()
            return

        execute_event(current_event_idx)

        
func _on_event_done():

    status = Status.OK        


func _ready():
    
    add_child(wait_timer)
    add_child(backdrop_display)
    dialog_display = dialog_box.instantiate()
    add_child(dialog_display)

    for event in sequence:
        
        event.event_sequencer = self        

    if !sequence.is_empty():

        status = Status.INPUT_PAUSED
    
    if sequence[current_event_idx].autostart:

        execute_event(current_event_idx)