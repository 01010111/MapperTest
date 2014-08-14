package ;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.util.FlxPoint;
import haxe.Timer;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;

/**
 * ...
 * @author x01010111
 */
class ZMapper
{
	
	var _colorVoid:Int = 0xff333333;
	var _colorFloor:Int = 0xffabb5b2;
	var _colorWall:Int = 0xff000000;
	var _colorDoor:Int = 0xff924530;
	
	var _mapArray:Array<Int>;
	var _rooms:Array<Array<Array<Int>>>;
	var _doorQueue:Array<Array<Int>>;
	var _doors:Array<Array<Array<Int>>>;
	var _mapBitmapData:BitmapData;
	
	var _lockableDoors:Array<Array<Array<Int>>>;
	var _keyRooms:Array<Array<Array<Int>>>;
	
	var _w:Int;
	var _h:Int;
	var _rsMax:Int;
	var _rsMin:Int;
	var _iterations:Int;
	var _curNumRooms:Int = 0;
	
	public function new(Width:Int, Height:Int, MinRoomSize:Int, MaxRoomSize:Int, Iterations:Int = 3) 
	{
		_w = Width; _h = Height; _rsMin = MinRoomSize; _rsMax = MaxRoomSize; _iterations = Iterations;
	}
	
	public function returnMap():BitmapData
	{
		var timer:Int = Lib.getTimer();
		makeMap();
		trace(Lib.getTimer() - timer);
		return _mapBitmapData;
	}
	
	function makeMap()
	{
		initMap();
		makeFirstRoom();
		for (i in 0..._iterations) iterate();
		_keyRooms = _rooms;
		_lockableDoors = _doors;
		colorMap();
		for (i in 0..._iterations - 1) addKey(i + 2);
	}
	
	function iterate()
	{
		var n:Int = _doorQueue.length;
		for (i in 0...n) {
			makeRoom(new Point(_doorQueue[i][0], _doorQueue[i][1]), _doorQueue[i][2], _doorQueue[i][3]);
		}
		for (i in 0...n) {
			_doorQueue = _doorQueue.slice(1);
		}
	}
	
	function initMap() 
	{
		_rooms = new Array();
		_doors = new Array();
		for (i in 0..._iterations + 1) {
			_rooms.push(new Array());
			_doors.push(new Array());
		}
		_doorQueue = new Array();
		_mapBitmapData = new BitmapData(_w, _h, true, 0xff000000);
		_mapArray = new Array();
		for (i in 0...(_w * _h)) _mapArray.push(0);
	}
	
	function makeFirstRoom() 
	{
		var w:Int = random(_rsMin + 2, _rsMax + 2);
		var h:Int = random(_rsMin + 2, _rsMax + 2);
		var x:Int = random(0, _w - w);
		var y:Int = random(0, _h - h);
		
		writeRoom(x, y, w, h, 0);
		
		addDoorToQueue(x + w - 1, random(y + 2, y + h - 2), 0, 1);
		addDoorToQueue(random(x + 2, x + w - 2), y + h - 1, 1, 1);
		addDoorToQueue(x, random(y + 2, y + h - 2), 2, 1);
		addDoorToQueue(random(x + 2, x + w - 2), y, 3, 1);
	}
	
	function addDoorToQueue(x:Int, y:Int, d:Int, g:Int)
	{
		_doorQueue.push([x, y, d, g]);
	}
	
	function makeRoom(e:Point, d:Int, g:Int = 1)
	{
		var w:Int = random(_rsMin + 2, _rsMax + 2);
		var h:Int = random(_rsMin + 2, _rsMax + 2);
		var x:Int;
		var y:Int;
		
		if (d == 0) {
			x = Math.floor(e.x); y = random(e.y - h + 2, e.y - 2);
		} else if (d == 1) {
			x = random(e.x - w + 2, e.x - 2); y = Math.floor(e.y);
		} else if (d == 2) {
			x = Math.floor(e.x) - w + 1; y = random(e.y - h + 2, e.y - 2);
		} else if (d == 3) {
			x = random(e.x - w + 2, e.x - 2); y = Math.floor(e.y) - h + 1;
		} else {
			x = y = -1;
		}
		
		var check:Bool = true;
		if (x + w > _w || y + h > _h || x < 0 || y < 0) check = false;
		else {
			for (n in 0...h) {
				for (i in 0...w) {
					if (check && _mapArray[x + y * _w + n * _w + i] >= 3) {
						check = false;
					}
					if (!check) break;
				}
				if (!check) break;
			}
		}
		
		if (check) {
			writeRoom(x, y, w, h, g);
			_doors[g].push([Math.floor(e.x), Math.floor(e.y)]);
			
			addDoorToQueue(x + w - 1, random(y + 2, y + h - 2), 0, g+1);
			addDoorToQueue(random(x + 2, x + w - 2), y + h - 1, 1, g+1);
			addDoorToQueue(x, random(y + 2, y + h - 2), 2, g+1);
			addDoorToQueue(random(x + 2, x + w - 2), y, 3, g+1);
		}
	}
	
	function writeRoom(x:Int, y:Int, w:Int, h:Int, g:Int) 
	{
		_curNumRooms++;
		for (n in 0...h) {
			for (i in 0...w) {
				(n == 0 || n == h - 1 || i == 0 || i == w - 1)? _mapArray[x + y * _w + n * _w + i] = 1: _mapArray[x + y * _w + n * _w + i] = g + 3;
			}
		}
		_rooms[g].push([x, y, w, h]);
	}
	
	function colorMap()
	{
		for (n in 0..._doors.length) {
			for (i in 0..._doors[n].length) {
				_mapArray[_doors[n][i][0] + _doors[n][i][1] * _w] = 2;
			}
		}
		
		for (i in 0..._mapArray.length) {
			if (_mapArray[i] == 0) _mapBitmapData.setPixel(i % _w, Math.floor(i / _w), _colorVoid);
			else if (_mapArray[i] == 1) _mapBitmapData.setPixel(i % _w, Math.floor(i / _w), _colorWall);
			else if (_mapArray[i] == 2) _mapBitmapData.setPixel(i % _w, Math.floor(i / _w), _colorDoor);
		}
		
		for (g in 0..._rooms.length) {
			for (r in 0..._rooms[g].length) {
				for (n in 0..._rooms[g][r][3] - 2) {
					for (i in 0..._rooms[g][r][2] - 2) {
						var c:Int = (Std.int(255) & 0xFF) << 24 | (Math.floor(255 - g * (255 / (_iterations + 4))) & 0xFF) << 16 | (Math.floor(255 - g * (255 / (_iterations + 4))) & 0xFF) << 8 | (Math.floor(255 - g * (255 / (_iterations + 4))) & 0xFF); 
						_mapBitmapData.setPixel(_rooms[g][r][0] + i + 1, _rooms[g][r][1] + n + 1, c);
					}
				}
			}
		}
		
	}
	
	function addKey(inKeyLevel:Int = -1)
	{
		var keyLevel:Int;
		inKeyLevel == -1? keyLevel = random(2, _iterations): keyLevel = inKeyLevel;
		var i:Int = 0;
		
		while (_lockableDoors[keyLevel].length == 0 && i < 8 || _keyRooms[keyLevel - 1].length == 0 && i < 8) {
			keyLevel = random(1, _iterations);
			i++;
		}
		
		if (i < 8) {
			var lockedDoorNum:Int = random(0, _lockableDoors[keyLevel].length - 1);
			var roomWithKeyNum:Int = random(0, _keyRooms[keyLevel - 1].length - 1);
			
			trace("KEYLEVEL:" + keyLevel + " ROOMS:" + _keyRooms[keyLevel] + " DOORS:" + _lockableDoors[keyLevel - 1]);
			
			var lockedDoor:Array<Int> = _lockableDoors[keyLevel][lockedDoorNum];
			var roomWithKey:Array<Int> = _keyRooms[keyLevel - 1][roomWithKeyNum];
			_keyRooms[keyLevel].slice(roomWithKeyNum);
			_lockableDoors[keyLevel - 1].slice(lockedDoorNum);
			
			trace(lockedDoor + " / " + roomWithKey);
			
			var keyColor:Int = (Std.int(255) & 0xFF) << 24 | (random(100,225) & 0xFF) << 16 | (random(100,225) & 0xFF) << 8 | (random(100,225) & 0xFF);
			
			_mapBitmapData.setPixel(lockedDoor[0], lockedDoor[1], keyColor);
			_mapBitmapData.setPixel(roomWithKey[0] + Math.floor(roomWithKey[2] * 0.5), roomWithKey[1] + Math.floor(roomWithKey[3] * 0.5), keyColor);
		}
	}
	
	function random(?MIN:Float = -1, ?MAX:Float = 1):Int
	{
		return Math.round(MIN + Math.random() * (MAX - MIN));
	}
	
}