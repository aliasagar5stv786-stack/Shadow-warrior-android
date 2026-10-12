extends Node2D

const LEVELS = [
    # Chapter 1 — 10
    {"ch":1,"n":1,"name":"Whispering Village","diff":1,"theme":0},
    {"ch":1,"n":2,"name":"Moonlit Forest","diff":1,"theme":0},
    {"ch":1,"n":3,"name":"Broken Bridge","diff":1,"theme":0},
    {"ch":1,"n":4,"name":"Bandit Camp","diff":2,"theme":0},
    {"ch":1,"n":5,"name":"Hidden Shrine","diff":2,"theme":0},
    {"ch":1,"n":6,"name":"Cursed River","diff":2,"theme":0},
    {"ch":1,"n":7,"name":"Silent Graveyard","diff":2,"theme":0},
    {"ch":1,"n":8,"name":"Night Watch","diff":3,"theme":0},
    {"ch":1,"n":9,"name":"Shadow Pass","diff":3,"theme":0},
    {"ch":1,"n":10,"name":"Fortress Gate","diff":3,"theme":0},
    # Chapter 2 — 10
    {"ch":2,"n":1,"name":"Frozen Valley","diff":2,"theme":1},
    {"ch":2,"n":2,"name":"Ice Cavern","diff":2,"theme":1},
    {"ch":2,"n":3,"name":"Storm Cliffs","diff":2,"theme":1},
    {"ch":2,"n":4,"name":"Frost Village","diff":2,"theme":1},
    {"ch":2,"n":5,"name":"Ancient Temple","diff":3,"theme":1},
    {"ch":2,"n":6,"name":"Crystal Halls","diff":3,"theme":1},
    {"ch":2,"n":7,"name":"Wind Fortress","diff":3,"theme":1},
    {"ch":2,"n":8,"name":"Frozen Prison","diff":3,"theme":1},
    {"ch":2,"n":9,"name":"Dragon Bridge","diff":4,"theme":1},
    {"ch":2,"n":10,"name":"Ice Warden","diff":4,"theme":1},
    # Chapter 3 — 10
    {"ch":3,"n":1,"name":"Fallen Outpost","diff":2,"theme":2},
    {"ch":3,"n":2,"name":"Burning Steps","diff":2,"theme":2},
    {"ch":3,"n":3,"name":"Lost Library","diff":3,"theme":2},
    {"ch":3,"n":4,"name":"Lava Bridge","diff":4,"theme":2},
    {"ch":3,"n":5,"name":"Demon Gates","diff":3,"theme":2},
    {"ch":3,"n":6,"name":"Hellish Tower","diff":4,"theme":2},
    {"ch":3,"n":7,"name":"Demon Forge","diff":4,"theme":2},
    {"ch":3,"n":8,"name":"Dark Cathedral","diff":4,"theme":2},
    {"ch":3,"n":9,"name":"Blood Courtyard","diff":4,"theme":2},
    {"ch":3,"n":10,"name":"Demon Throne","diff":5,"theme":2},
    # Chapter 4 — final boss
    {"ch":4,"n":1,"name":"Final Realm — Shadow Emperor","diff":5,"theme":3}
]

var level_index := 0
var player := Vector2(120, 500)
var velocity := Vector2.ZERO
var hp := 7
var stars := 0
var coins := 0
var attack_timer := 0.0
var power_timer := 0.0
var shield_timer := 0.0
var level_stars := 0
var enemy_hp := 3
var boss_hp := 30
var won := false
var level_complete := false
var pressed := {"left":false,"right":false}
var anim_time := 0.0
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var music_time := 0.0

var title: Label
var info: Label
var message: Label
var chapter_buttons: VBoxContainer
var left_btn: Button
var right_btn: Button
var jump_btn: Button
var attack_btn: Button
var dash_btn: Button
var strike_btn: Button
var shield_btn: Button

func _ready():
    _setup_audio()
    _build_ui()
    _start_level(0)
    queue_redraw()

func _setup_audio():
    sfx_player = AudioStreamPlayer.new()
    add_child(sfx_player)
    music_player = AudioStreamPlayer.new()
    add_child(music_player)
    _start_music()

func _start_music():
    # Short original synthesized loop; restarted automatically at the end.
    var stream = AudioStreamWAV.load_from_file("res://audio/music.wav")
    if stream:
        music_player.stream = stream
        music_player.volume_db = -19.0
        music_player.finished.connect(_start_music)
        music_player.play()

func _play_sfx(file_name:String):
    var stream = AudioStreamWAV.load_from_file("res://audio/" + file_name)
    if stream:
        sfx_player.stream = stream
        sfx_player.volume_db = -5.0
        sfx_player.play()

func _build_ui():
    title = Label.new()
    title.position = Vector2(30,20)
    title.add_theme_font_size_override("font_size", 30)
    add_child(title)
    info = Label.new()
    info.position = Vector2(30,65)
    info.add_theme_font_size_override("font_size", 18)
    add_child(info)
    message = Label.new()
    message.position = Vector2(330, 90)
    message.size = Vector2(620,100)
    message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message.add_theme_font_size_override("font_size", 24)
    add_child(message)

    chapter_buttons = VBoxContainer.new()
    chapter_buttons.position = Vector2(35,120)
    chapter_buttons.size = Vector2(230,500)
    add_child(chapter_buttons)
    for c in range(1,5):
        var b=Button.new()
        b.text="Chapter %d"%c
        b.custom_minimum_size=Vector2(210,48)
        b.pressed.connect(func(): _show_chapter(c))
        chapter_buttons.add_child(b)

    left_btn=_make_button("◀",Vector2(40,625),func(): pressed["left"]=true)
    right_btn=_make_button("▶",Vector2(125,625),func(): pressed["right"]=true)
    jump_btn=_make_button("JUMP",Vector2(210,625),func(): _jump())
    attack_btn=_make_button("ATTACK",Vector2(1010,610),func(): _attack())
    dash_btn=_make_button("DASH",Vector2(895,610),func(): _dash())
    strike_btn=_make_button("STRIKE",Vector2(780,610),func(): _strike())
    shield_btn=_make_button("SHIELD",Vector2(665,610),func(): _shield())

func _make_button(t:String,pos:Vector2,cb:Callable)->Button:
    var b=Button.new()
    b.text=t; b.position=pos; b.custom_minimum_size=Vector2(100,58)
    b.button_down.connect(cb)
    b.button_up.connect(func(): pressed["left"]=false; pressed["right"]=false)
    add_child(b)
    return b

func _show_chapter(c:int):
    var first=0
    for i in range(LEVELS.size()):
        if LEVELS[i].ch==c: first=i; break
    _start_level(first)

func _start_level(i:int):
    level_index=clamp(i,0,LEVELS.size()-1)
    player=Vector2(330,480); velocity=Vector2.ZERO; level_stars=0
    enemy_hp=2+LEVELS[level_index].diff
    boss_hp=30 if level_index==30 else 0
    won=false; level_complete=false; message.text=""
    queue_redraw()

func _jump():
    if player.y>=510: velocity.y=-500; _play_sfx("jump.wav")

func _attack():
    attack_timer=0.25
    _play_sfx("attack.wav")
    if level_index==30:
        boss_hp=max(0,boss_hp-2)
        if boss_hp<=0: _complete_level()
    else:
        enemy_hp-=1
        if enemy_hp<=0: _complete_level()

func _dash():
    power_timer=0.35
    _play_sfx("dash.wav")
    velocity.x=850

func _strike():
    power_timer=0.5
    _play_sfx("strike.wav")
    if level_index==30:
        boss_hp=max(0,boss_hp-4)
        if boss_hp<=0: _complete_level()
    else:
        enemy_hp=max(0,enemy_hp-3)
        if enemy_hp<=0: _complete_level()

func _shield():
    shield_timer=3.0
    _play_sfx("shield.wav")

func _complete_level():
    if level_complete:return
    level_complete=true
    var earned=3 if level_index==30 else 3
    level_stars=earned
    stars += earned
    _play_sfx("victory.wav")
    message.text="LEVEL COMPLETE!\n+%d ★   Tap NEXT to continue"%earned
    var next=Button.new()
    next.name="NextLevel"
    next.text="NEXT LEVEL ▶"
    next.position=Vector2(500,360)
    next.custom_minimum_size=Vector2(260,70)
    next.add_theme_font_size_override("font_size",24)
    next.pressed.connect(func():
        next.queue_free()
        if level_index<LEVELS.size()-1:_start_level(level_index+1)
        else: message.text="🎉 ALL 31 LEVELS COMPLETE! 🎉")
    add_child(next)

func _physics_process(delta):
    anim_time += delta
    if level_complete:
        queue_redraw()
        return
    var dir=float(int(pressed["right"])-int(pressed["left"]))
    if abs(velocity.x)<100 or dir!=0: velocity.x=dir*260
    if power_timer>0: power_timer-=delta
    else: velocity.x=move_toward(velocity.x,0,900*delta)
    velocity.y+=1100*delta
    player+=velocity*delta
    if player.y>510: player.y=510; velocity.y=0
    player.x=clamp(player.x,300,1180)
    attack_timer=max(0.0,attack_timer-delta)
    shield_timer=max(0.0,shield_timer-delta)
    if player.x>1120 and level_index<30: _complete_level()
    info.text="HP ♥ %d     Stars ★ %d/90     Coins %d     Level %d/31"%(hp,stars,coins,level_index+1)
    title.text="SHADOW WARRIOR — Chapter %d"%LEVELS[level_index].ch
    queue_redraw()

func _draw():
    var theme=LEVELS[level_index].theme
    var bg=[Color("#10162c"),Color("#10233a"),Color("#2a101c"),Color("#160d2d")][theme]
    draw_rect(Rect2(0,0,1280,720),bg)
    # atmospheric layers
    for i in range(8):
        draw_circle(Vector2(330+i*135,180+(i%3)*45),90,Color(0.18,0.12,0.25,0.18))
    draw_rect(Rect2(290,560,950,160),Color("#17141d"))
    draw_rect(Rect2(290,545,950,18),Color("#5d4b73"))
    # stars
    for s in range(3):
        var sx=520+s*190
        draw_circle(Vector2(sx,470-(s%2)*90),10,Color("#ffd75a"))
        draw_line(Vector2(sx-14,470-(s%2)*90),Vector2(sx+14,470-(s%2)*90),Color("#ffd75a"),3)
    # animated ninja: bobbing head, alternating legs/arms and scarf flutter
    var bob = sin(anim_time * (8.0 if abs(velocity.x)>10 else 2.2)) * (4.0 if abs(velocity.x)>10 else 1.5)
    var px = player.x
    var py = player.y + bob
    var run_swing = sin(anim_time * 10.0) * (13.0 if abs(velocity.x)>10 else 3.0)
    # legs and boots
    draw_line(Vector2(px+13,py+43),Vector2(px+10+run_swing,py+57),Color("#080a10"),8)
    draw_line(Vector2(px+26,py+43),Vector2(px+29-run_swing,py+57),Color("#080a10"),8)
    draw_line(Vector2(px+8+run_swing,py+58),Vector2(px+17+run_swing,py+58),Color("#c7c6d4"),5)
    draw_line(Vector2(px+27-run_swing,py+58),Vector2(px+36-run_swing,py+58),Color("#c7c6d4"),5)
    # body, sash, head and mask
    draw_rect(Rect2(px+7,py+21,25,26),Color("#171b26"))
    draw_rect(Rect2(px+4,py+27,31,6),Color("#c62e4c"))
    draw_circle(Vector2(px+19,py+16),14,Color("#20242d"))
    draw_rect(Rect2(px+7,py+14,25,7),Color("#34394a"))
    draw_line(Vector2(px+10,py+19),Vector2(px+27,py+19),Color("#f3e8f0"),2)
    # fluttering scarf tail
    draw_colored_polygon(PackedVector2Array([Vector2(px+4,py+28),Vector2(px-13-sin(anim_time*8)*8,py+33),Vector2(px+2,py+38)]),Color("#d33350"))
    # animated arm
    draw_line(Vector2(px+11,py+28),Vector2(px+2+run_swing*0.4,py+40),Color("#171b26"),7)
    draw_line(Vector2(px+29,py+28),Vector2(px+38,py+35),Color("#171b26"),7)
    if attack_timer>0:
        draw_line(Vector2(px+35,py+31),Vector2(px+105,py+8),Color("#e7eaf3"),8)
        draw_arc(Vector2(px+53,py+31),45,-0.8,0.8,18,Color("#a7d7ff"),3)
    if shield_timer>0:
        draw_arc(player+Vector2(19,30),45,0,TAU,48,Color("#63a7ff"),5)
    # enemy/boss
    if level_index==30:
        draw_rect(Rect2(1010,390,100,155),Color("#241827"))
        draw_circle(Vector2(1060,380),58,Color("#5b1e58"))
        draw_circle(Vector2(1042,370),8,Color("#ff4b7d"))
        draw_circle(Vector2(1078,370),8,Color("#ff4b7d"))
        draw_string(ThemeDB.fallback_font,Vector2(940,300),"SHADOW EMPEROR",HORIZONTAL_ALIGNMENT_LEFT,260,24,Color("#f0b5ff"))
        draw_string(ThemeDB.fallback_font,Vector2(940,330),"BOSS HP: %d / 30"%boss_hp,HORIZONTAL_ALIGNMENT_LEFT,260,20,Color("#ff7a9b"))
    else:
        var enemy_bob = sin(anim_time*4.0)*3.0
        draw_rect(Rect2(880,490+enemy_bob,45,70),Color("#8d234a"))
        draw_circle(Vector2(902,480+enemy_bob),18,Color("#4c263e"))
        draw_line(Vector2(888,520+enemy_bob),Vector2(872,540+enemy_bob+sin(anim_time*5)*4),Color("#8d234a"),7)
        draw_string(ThemeDB.fallback_font,Vector2(850,450),"Enemy HP %d"%enemy_hp,HORIZONTAL_ALIGNMENT_LEFT,180,18,Color("#ff829b"))
    # portal
    draw_rect(Rect2(1150,475,45,70),Color("#6d4bb2"))
    draw_arc(Vector2(1172,475),35,PI,TAU,24,Color("#c28cff"),5)
    draw_string(ThemeDB.fallback_font,Vector2(340,590),LEVELS[level_index].name,HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("#d9d0ea"))
