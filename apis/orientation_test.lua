-- test orientation API

assert(orientation.calibrate('north'))

assert(turtle.turnRight() and orientation.tostring() == 'east')
assert(turtle.turnRight() and orientation.tostring() == 'south')
assert(turtle.turnRight() and orientation.tostring() == 'west')
assert(turtle.turnRight() and orientation.tostring() == 'north')

assert(orientation.turnAround() and orientation.tostring() == 'south')
assert(orientation.turnAround() and orientation.tostring() == 'north')

assert(turtle.turnLeft() and orientation.tostring() == 'west')
assert(turtle.turnLeft() and orientation.tostring() == 'south')
assert(turtle.turnLeft() and orientation.tostring() == 'east')
assert(turtle.turnLeft() and orientation.tostring() == 'north')


assert(orientation.turnNorth() and orientation.turnWest() and orientation.tostring() == 'west')
assert(orientation.turnEast()  and orientation.turnWest() and orientation.tostring() == 'west')
assert(orientation.turnSouth() and orientation.turnWest() and orientation.tostring() == 'west')
assert(orientation.turnWest()  and orientation.turnWest() and orientation.tostring() == 'west')

assert(orientation.turnNorth() and orientation.turnEast() and orientation.tostring() == 'east')
assert(orientation.turnEast()  and orientation.turnEast() and orientation.tostring() == 'east')
assert(orientation.turnSouth() and orientation.turnEast() and orientation.tostring() == 'east')
assert(orientation.turnWest()  and orientation.turnEast() and orientation.tostring() == 'east')

assert(orientation.turnNorth() and orientation.turnNorth() and orientation.tostring() == 'north')
assert(orientation.turnEast()  and orientation.turnNorth() and orientation.tostring() == 'north')
assert(orientation.turnSouth() and orientation.turnNorth() and orientation.tostring() == 'north')
assert(orientation.turnWest()  and orientation.turnNorth() and orientation.tostring() == 'north')

assert(orientation.turnNorth() and orientation.turnSouth() and orientation.tostring() == 'south')
assert(orientation.turnEast()  and orientation.turnSouth() and orientation.tostring() == 'south')
assert(orientation.turnSouth() and orientation.turnSouth() and orientation.tostring() == 'south')
assert(orientation.turnWest()  and orientation.turnSouth() and orientation.tostring() == 'south')

print('PASS')
