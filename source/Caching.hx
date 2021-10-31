package;

import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class Caching extends MusicBeatState
{
    var toBeDone = 0;
    var done = 0;

    var text:FlxText;
    var lolBeuty:FlxSprite;

	override function create()
	{
        FlxG.mouse.visible = false;

        FlxG.worldBounds.set(0,0);

        text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Loading...");
        text.size = 34;
        text.alignment = FlxTextAlign.CENTER;
        text.alpha = 0;

        lolBeuty = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('maxIsTooGood', 'drowned'));
        lolBeuty.screenCenter();
        text.y -= lolBeuty.height / 2 - 125;
        text.x -= 370;
        lolBeuty.setGraphicSize(Std.int(lolBeuty.width * 0.6));
        lolBeuty.scale.set(0.4,0.4);

        lolBeuty.alpha = 0;

        add(lolBeuty);
        add(text);

        trace('starting caching..');
        
        sys.thread.Thread.create(() -> {
            cache();
        });


        super.create();
    }

    var calledDone = false;

    override function update(elapsed) 
    {

        if (toBeDone != 0 && done != toBeDone)
        {
            var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
            lolBeuty.alpha = alpha;
            text.alpha = alpha;
            text.text = "Loading... (" + done + "/" + toBeDone + ")";
        }

        super.update(elapsed);
    }


    function cache()
    {

        var images = [];
        var music = [];
        var drownedshit = [];
        var drownedChar = [];
        var preload = [];

        trace("caching images...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
        {
            if (!i.endsWith(".png"))
                continue;
            images.push(i);
        }

        trace("caching ben drowned shit...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/drowned/images")))
            {
                if (!i.endsWith(".png"))
                    continue;
                drownedshit.push(i);
            }
          
        trace("caching ben drowned characters...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/drowned/images/characters")))
            {
                if (!i.endsWith(".png"))
                    continue;
                drownedChar.push(i);
            }

        trace("caching music...");

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
        {
            music.push(i);
        }

        toBeDone = Lambda.count(images) + Lambda.count(music) +  Lambda.count(drownedshit);

        trace("CACHING: " + toBeDone + " ITEMS.");

        for (i in images)
        {
            var replaced = i.replace(".png","");
            FlxG.bitmap.add(Paths.image("characters/" + replaced,"shared"));
            trace("cached " + replaced);
            done++;
        }
            
        for (i in drownedshit)
            {
                var replaced = i.replace(".png","");
                FlxG.bitmap.add(Paths.image(replaced,"drowned"));
                trace("cached " + replaced);
                done++;
            }

        for (i in drownedChar)
            {
                var replaced = i.replace(".png","");
                FlxG.bitmap.add(Paths.image(replaced,"drowned"));
                trace("cached " + replaced);
                done++;
            }

        for (i in music)
        {
            FlxG.sound.cache(Paths.inst(i));
            FlxG.sound.cache(Paths.voices(i));
            trace("cached " + i);
            done++;
        }

        trace("Finished caching...");

        FlxG.switchState(new TitleState());
    }

}