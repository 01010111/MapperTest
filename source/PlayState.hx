package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		var m:ZMapper = new ZMapper(Math.floor(FlxG.width * 0.5), Math.floor(FlxG.height * 0.5), 4, 24, 8);
		var s:FlxSprite;
		s = new FlxSprite(FlxG.width * 0.5 - FlxG.width * 0.25, FlxG.height * 0.5 - FlxG.height * 0.25);
		s.pixels = m.returnMap();
		s.scale.set(2, 2);
		add(s);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		if (FlxG.keys.justPressed.R) FlxG.switchState(new PlayState());
	}	
}