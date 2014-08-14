package ;
import flash.display.BitmapData;
import flixel.FlxG;
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
	
	private var _colorVoid:Int = 0xff333333;
	private var _colorFloor:Int = 0xffabb5b2;
	private var _colorWall:Int = 0xff000000;
	private var _colorDoor:Int = 0xff924530;
	
	private var _mapArray:Array<Int>;
	private var _rooms:Array<Array<Int>>;
	private var _doors:Array<Array<Int>>;
	private var _mapBitmapData:BitmapData;
	
	private var _w:Int;				  //MAP WIDTH
	private var _h:Int;				  //MAP HEIGHT
	private var _rsMax:Int;			  //MAX ROOM SIZE
	private var _rsMin:Int;			  //MAX ROOM SIZE
	private var _mrNum:Int;			  //MAX NUMBER OF ROOMS
	private var _curNumRooms:Int = 0; //CURRENT NUMBER OF ROOMS
	
	public function new(Width:Int, Height:Int, MinRoomSize:Int, MaxRoomSize:Int, MaxRooms:Int = -1) 
	{
		_w = Width; _h = Height; _rsMin = MinRoomSize; _rsMax = MaxRoomSize; _mrNum = MaxRooms;
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
		colorMap();
	}
	
	function initMap() 
	{
		_rooms = new Array();
		_doors = new Array();
		_mapBitmapData = new BitmapData(_w, _h, true, 0xff000000);
		_mapArray = new Array();
		for (i in 0...(_w * _h)) _mapArray.push(0);
	}
	
	function makeFirstRoom() 
	{
		var w:Int = randomRangeInt(_rsMin + 2, _rsMax + 2);
		var h:Int = randomRangeInt(_rsMin + 2, _rsMax + 2);
		var x:Int = randomRangeInt(0, _w - w);
		var y:Int = randomRangeInt(0, _h - h);
		
		writeRoom(x, y, w, h, 0);
		
		makeRoom(new Point(x + w - 1, randomRangeInt(y + 2, y + h - 2)), 0);
		makeRoom(new Point(randomRangeInt(x + 2, x + w - 2), y + h - 1), 1);
		makeRoom(new Point(x, randomRangeInt(y + 2, y + h - 2)), 2);
		makeRoom(new Point(randomRangeInt(x + 2, x + w - 2), y), 3);
	}
	
	/**
	 * 
	 * @param	e Point Entrance
	 * @param	d Int Entrance direction - 0:West, 1:South, 2:East, 3:North
	 * @param	g Int Generation for difficulty scaling/key placement
	 */
	function makeRoom(e:Point, d:Int, g:Int = 1)
	{
		//INIT ROOM VARIABLES, SET WIDTH AND HEIGHT
		var w:Int = randomRangeInt(_rsMin + 2, _rsMax + 2);
		var h:Int = randomRangeInt(_rsMin + 2, _rsMax + 2);
		var x:Int;
		var y:Int;
		
		//GET X AND Y
		if (d == 0) {			//WEST GOING EAST
			x = Math.floor(e.x); y = randomRangeInt(e.y - h + 2, e.y - 2);
		} else if (d == 1) {	//SOUTH GOING NORTH
			x = randomRangeInt(e.x - w + 2, e.x - 2); y = Math.floor(e.y);
		} else if (d == 2) {	//EAST GOING WEST
			x = Math.floor(e.x) - w + 1; y = randomRangeInt(e.y - h + 2, e.y - 2);
		} else if (d == 3) {	//NORTH GOING SOUTH
			x = randomRangeInt(e.x - w + 2, e.x - 2); y = Math.floor(e.y) - h + 1;
		} else {
			x = y = -1;
		}
		
		//CHECK ROOM IF COOL, WRITE ROOM, STORE ENTRANCE AS G++, MAKE THREE MORE ROOMS
		var check:Bool = true;
		if (x + w > _w || y + h > _h || x < 0 || y < 0 || _curNumRooms == _mrNum) check = false;
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
			_doors.push([Math.floor(e.x), Math.floor(e.y), g++]);
			makeRoom(new Point(x + w - 1, randomRangeInt(y + 2, y + h - 2)), 0, g+1);
			makeRoom(new Point(randomRangeInt(x + 2, x + w - 2), y + h - 1), 1, g+1);
			makeRoom(new Point(x, randomRangeInt(y + 2, y + h - 2)), 2, g+1);
			makeRoom(new Point(randomRangeInt(x + 2, x + w - 2), y), 3, g+1);
		}
	}
	
	/**
	 * 
	 * @param	x Int X Pos
	 * @param	y Int Y Pos
	 * @param	w Int Width
	 * @param	h Int Height
	 * @param	g Int Generation for difficulty scaling/key placement
	 */
	function writeRoom(x:Int, y:Int, w:Int, h:Int, g:Int) 
	{
		_curNumRooms++;
		for (n in 0...h) {
			for (i in 0...w) {
				(n == 0 || n == h - 1 || i == 0 || i == w - 1)? _mapArray[x + y * _w + n * _w + i] = 1: _mapArray[x + y * _w + n * _w + i] = g + 3;
			}
		}
		_rooms.push([x, y, w, h, g]);
	}
	
	function colorMap()
	{
		for (i in 0..._doors.length) {
			_mapArray[_doors[i][0] + _doors[i][1] * _w] = 2;
		}
		
		for (i in 0..._mapArray.length) {
			if (_mapArray[i] == 0) _mapBitmapData.setPixel(i % _w, Math.floor(i / _w), _colorVoid);
			else if (_mapArray[i] == 1) _mapBitmapData.setPixel(i % _w, Math.floor(i / _w), _colorWall);
			else if (_mapArray[i] == 2) _mapBitmapData.setPixel(i % _w, Math.floor(i / _w), _colorDoor);
			else if (_mapArray[i] == 3) _mapBitmapData.setPixel(i % _w, Math.floor(i / _w), 0xffffffff);
			else if (_mapArray[i] > 3) _mapBitmapData.setPixel(i % _w, Math.floor(i / _w), _colorFloor);
		}
		
	}
	
	/**
	 * 
	 * @param	MIN Float Minimum number to return
	 * @param	MAX Float Maximum number to return
	 * @return Int Random Integer between the minimum and maximum numbers
	 */
	function randomRangeInt(?MIN:Float = -1, ?MAX:Float = 1):Int
	{
		return Math.round(MIN + Math.random() * (MAX - MIN));
	}
	
}