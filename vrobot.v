module main
 
import math
import time

#include "windows.h"

const (
  MOUSE_STEPS = 500
)

struct Point {
  x int
  y int
}

fn do_mouse_event(x int) {
  C.mouse_event(x, 0, 0, 0, 0)
}

fn mouse_down(button string) {
  match button {
    'left' => do_mouse_event(C.MOUSEEVENTF_LEFTDOWN)
    'right' => do_mouse_event(C.MOUSEEVENTF_RIGHTDOWN)
    'middle' => do_mouse_event(C.MOUSEEVENTF_MIDDLEDOWN)
    else => panic('Invalid mouse button')
  }
}

fn mouse_up(button string) {
  match button {
    'left' => do_mouse_event(C.MOUSEEVENTF_LEFTUP)
    'right' => do_mouse_event(C.MOUSEEVENTF_RIGHTUP)
    'middle' => do_mouse_event(C.MOUSEEVENTF_MIDDLEUP)
    else => panic('Invalid mouse button')
  }
}

pub fn click(button string) {
  mouse_down(button)
  mouse_up(button)
}

pub fn double_click(button string) {
  click(button)
  click(button)
}

pub fn drag(x, y int) {
  mouse_down('left')
  move_mouse(x, y)
  mouse_up('left')
}

pub fn drag_rel(offset_x, offset_y int) {
  start_pos := get_mouse_pos()
  dest_x := start_pos.x + offset_x
  dest_y := start_pos.y + offset_y

  mouse_down('left')
  move_mouse(dest_x, dest_y)
  mouse_up('left')
}

pub fn move_mouse(x, y int) {
  C.SetCursorPos(x, y)
}

pub fn move_mouse_rel(offset_x, offset_y, duration_ms int) {
  start_pos := get_mouse_pos()
  dest_x := start_pos.x + offset_x
  dest_y := start_pos.y + offset_y

  if duration_ms == 0 {
    move_mouse(dest_x, dest_y)
  } else {
    move_mouse_smooth(dest_x, dest_y, duration_ms)
  }
}

pub fn move_mouse_smooth(dest_x, dest_y, duration_ms int) {
  start_pos := get_mouse_pos()

  dx := (f32(dest_x) - start_pos.x) / MOUSE_STEPS
  dy := (f32(dest_y) - start_pos.y) / MOUSE_STEPS
  dt := int(f32(duration_ms) / f32(MOUSE_STEPS))

  mut i := 0
  
  for i < MOUSE_STEPS {
    x := int(f32(start_pos.x) + dx * i)
    y := int(f32(start_pos.y) + dy * i)

    move_mouse(x, y)
    time.sleep_ms(dt)
    i++
  }
}

pub fn get_mouse_pos() Point {
  p := Point{}
  cursor := C.GetCursorPos(&p)

  if !cursor {
    panic('No cursor found')
  }

  return p
}

fn main() {
  $if !windows {
    panic('You need windows machine')
  }

  // Test code
  p := get_mouse_pos()
  println('Mouse position: $p.x, $p.y')
  drag_rel(50, 234)
}