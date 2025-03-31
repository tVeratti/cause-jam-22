extends Node


class_name BlockTypes


enum Shapes { CIRCLE, SQUARE, TRIANGLE, DIAMOND, PENTAGON, STAR }


const COLOR_SHAPE_MAP:Dictionary[Color, Shapes] = {
	BlockColors.BLUE: Shapes.CIRCLE,
	BlockColors.GREEN: Shapes.SQUARE,
	BlockColors.YELLOW: Shapes.TRIANGLE,
	BlockColors.ORANGE: Shapes.DIAMOND,
	BlockColors.RED: Shapes.PENTAGON,
	BlockColors.PURPLE:Shapes.STAR
}


const TEXTURES:Dictionary[Shapes, Texture2D] = {
	Shapes.CIRCLE: preload("uid://bxjo5sa56v28s"),
	Shapes.SQUARE: preload("uid://cq2klifcgfwob"),
	Shapes.TRIANGLE: preload("uid://cvvmjxmobrlns"),
	Shapes.DIAMOND: preload("uid://cy5bspk4dxnhp"),
	Shapes.PENTAGON: preload("uid://8tm0wpmsoafa"),
	Shapes.STAR: preload("uid://h0etqjkgamb2"),
}

const TEXTURES_NORMALS:Dictionary[Shapes, Texture2D] = {
	Shapes.CIRCLE: preload("uid://chxjyrcobl1n6"),
	Shapes.SQUARE: preload("uid://cvb0bt0bt0ogo"),
	Shapes.TRIANGLE: preload("uid://bfyfbjdnn52bf"),
	Shapes.DIAMOND: preload("uid://dlrsp3gvngeyd"),
	Shapes.PENTAGON: preload("uid://cmj47iq7bxvj4"),
	Shapes.STAR: preload("uid://4csl2orr38r0"),
}


static func get_shape_by_color(color:Color) -> Shapes:
	return COLOR_SHAPE_MAP[color]


static func get_normal_texture_by_shape(shape:Shapes) -> Texture2D:
	return TEXTURES_NORMALS[shape]
