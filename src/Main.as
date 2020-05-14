/*
 * ランダムっぽいけどまとまりがある感じを出したかった。
 * 点の動き自体は気に入っている。
 * けど、この作り方だと重くなってしまって、
 * 密度や写真の枚数を上げられない。
 * 
 * ↓これくらい軽くしたかった。考え方を根本から変えないと。
 * Flickr Tricks For Aurora Crowley!!
 * http://wonderfl.net/c/9Mk8
 * 
 * */
package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.text.TextField;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.ITween;

    /**
     * ...
     * @author umhr
     */
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=60)]
    public class Main extends Sprite {
        private var _mulitiLoader:MultiLoader;
        private var _bitmap:Bitmap;
        private const FADE:ColorTransform = new ColorTransform(0.8, 0.8, 0.9, 0.9);
        private var _dots:Vector.<int>;
        private var _particlesXY:Vector.<Object>;
        private var _bgBitmap:Bitmap;
        private var _stageWidth:int;
        private var _stageHeight:int;
        private var _easeInOut:Array = [Sine.easeInOut, Quad.easeInOut, Cubic.easeInOut, Quart.easeInOut, Quint.easeInOut, Expo.easeInOut, Circ.easeInOut, Back.easeInOut];
        private var _easeOut:Array = [Sine.easeOut, Quad.easeOut, Cubic.easeOut, Quart.easeOut, Quint.easeOut, Expo.easeOut, Circ.easeOut, Back.easeOut];
        private var _photoURLs:Array = [];
        private var _pitch:int = 8;

        public function Main():void {
            stage.scaleMode = "noScale";
            stage.align = "TL";
            _stageWidth = stage.stageWidth;
            _stageHeight = stage.stageHeight;

            _bgBitmap = new Bitmap(new BitmapData(_stageWidth, _stageHeight, false, 0x00000000));
            this.addChild(_bgBitmap);
            _bitmap = new Bitmap(new BitmapData(_stageWidth, _stageHeight, false, 0xFF000000));
            _bitmap.blendMode = "lighten";
            this.addChild(_bitmap);
            _dots = new Vector.<int>(_stageWidth/_pitch * _stageHeight/_pitch);
            _particlesXY = new Vector.<Object>(_stageWidth / _pitch * _stageHeight / _pitch);
            loadXML();
        }

        private function loadXML():void {
            
            var xmlURL:String = "data.xml";
            _mulitiLoader = new MultiLoader("main");
            _mulitiLoader.add(xmlURL,{id:"xml",type:"text"});
            _mulitiLoader.addEventListener(Event.COMPLETE, loadIMG);
            _mulitiLoader.start();
        }
        private function loadIMG(event:Event):void {
            var myXML:XML = _mulitiLoader.getXML("xml");
            var n:int = myXML.item.length();
            for (var i:int = 0; i < n; i++) {
				var url:String = myXML.item[i];
                _photoURLs.push(url);
                _mulitiLoader.add(url,{context:new LoaderContext(true)});
            }
            _mulitiLoader.addEventListener(Event.COMPLETE, atComp);
            _mulitiLoader.start();
        }

        private var rgbs:Array;

        private function atComp(event:Event):void {
            
            rgbs = [];
            var p:int = _photoURLs.length;
            for (var k:int = 0; k < p; k++){
                rgbs[k] = [];
                var bitmap:Bitmap = _mulitiLoader.getBitmap(_photoURLs[k]);
                var bi:Number = Math.max(_stageHeight / bitmap.height, _stageWidth / bitmap.width);
                
                var dx:int = bitmap.width;
                var dy:int = bitmap.height;
                var n:int = _stageWidth / _pitch;
                var m:int = _stageHeight / _pitch;
                for (var i:int = 0; i < n; i++){
                    rgbs[k][i] = [];
                    for (var j:int = 0; j < m; j++){
                        rgbs[k][i][j] = bitmap.bitmapData.getPixel(i * _pitch/bi, j * _pitch/bi);
                    }
                }
            }
            n = _stageWidth / _pitch;
            m = _stageHeight / _pitch;
            var tw:Array = [];
            for (i = 0; i < n; i++){
                for (j = 0; j < m; j++){

                    var point:Object = { x:0, y:0 };
                    var tweens:Array = [];

                    for (k = 0; k < p; k++){
                        var rgb:int = rgbs[k][i][j];
                        var brightness:Number = (rgb >> 16) + (rgb >> 8 & 0xFF) + (rgb & 0xFF);
                        brightness = brightness * _easeOut.length / (0xFF * 3);
                        var ran:Number = Math.random() + new Date().getSeconds();
                        var tx:int = Math.min(_stageWidth + 60, Math.max(-60, Math.cos(brightness + ran) * _stageWidth + _stageWidth / 2));
                        var ty:int = Math.min(_stageHeight + 60, Math.max(-60, Math.sin(brightness + ran) * _stageHeight + _stageHeight / 2));
                        brightness = Math.floor(brightness);
                        
                        if (brightness < 1) {
                            if (i == 0 && j == 0) {
                                tweens[k * 3] = BetweenAS3.func(colors, [n, i, j, k]);
                            }else {
                                tweens[k * 3] = BetweenAS3.func(function():void{});
                            }
                            tweens[k * 3 + 1] = BetweenAS3.delay(BetweenAS3.func(function():void{}),10);
                            tweens[k * 3 + 2] = BetweenAS3.func(function():void{});
                            continue;
                        }
                        
                        tweens[k * 3] = BetweenAS3.func(colors, [n, i, j, k]);
                        tweens[k * 3 + 1] = BetweenAS3.parallel(
                            BetweenAS3.tween(point, { x: i * _pitch }, { x: tx }, 4, _easeOut[brightness]),
                            BetweenAS3.tween(point, { y: j * _pitch }, { y: ty }, 4, _easeOut[Math.floor(_easeOut.length * Math.random())])
                            );
                        tweens[k * 3 + 2] = BetweenAS3.delay(
                            BetweenAS3.parallel(
                                BetweenAS3.tween(point, { x: ty }, { x: i * _pitch }, 4, _easeInOut[Math.floor(_easeOut.length * Math.random())]), 
                                BetweenAS3.tween(point, { y: tx }, { y: j * _pitch }, 4, _easeInOut[brightness])
                            )
                            , 2);
                    }

                    tw.push(BetweenAS3.serial.apply(this, tweens));
                    _particlesXY[i * m + j] = point;
                }
            }
            
            var t:ITween = BetweenAS3.parallel.apply(this, tw);
            t = BetweenAS3.delay(t, 1.5);
            t.stopOnComplete = false;
            t.play();
            this.addEventListener(Event.ENTER_FRAME, atEnter);
        }

        private function addPhoto(i:int, j:int, c:int):void {
            var bitmapData:BitmapData = _mulitiLoader.getBitmapData(_photoURLs[c]);
            var bi:Number = Math.max(_stageHeight / bitmapData.height, _stageWidth / bitmapData.width);
            _bgBitmap.bitmapData.draw(bitmapData, new Matrix(bi, 0, 0, bi), null, null, null, true);
            
            var t:ITween = BetweenAS3.serial(
                BetweenAS3.tween(_bgBitmap, { alpha: 0.7 }, { alpha: 0 }, 1, Sine.easeOut),
                BetweenAS3.delay(BetweenAS3.tween(_bgBitmap, {alpha: 0}, null, 1, Sine.easeIn), 2));
            t = BetweenAS3.delay(t, 3);
            t.play();
        }
        
        private function colors(n:int, i:int, j:int, c:int):void {
            _dots[i * n + j] = rgbs[c][i][j];
            if (i == 0 && j == 0) {
                addPhoto(i, j, c);
            };
        }

        private function atEnter(event:Event):void {
            var bitmapData:BitmapData = _bitmap.bitmapData;
            bitmapData.lock();
            bitmapData.colorTransform(_bitmap.bitmapData.rect, FADE);
            var n:int = _stageWidth / _pitch;
            var m:int = _stageHeight / _pitch;
            for (var i:int = 0; i < n; i++){
                for (var j:int = 0; j < m; j++){
                    bitmapData.setPixel(_particlesXY[i * m + j].x, _particlesXY[i * m + j].y, _dots[i * m + j]);
                }
            }
            bitmapData.unlock();
        }

    }

}


/**
 * Fileローダー
 * ...
 * @author umhr
 */

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

class MultiLoader {
    public static var IMAGE_EXTENSIONS:Array = ["swf", "jpg", "jpeg", "gif", "png"];
    public static var TEXT_EXTENSIONS:Array = ["txt", "js", "xml", "php", "asp"];
    public static const COMPLETE:String = "complete";
    private var _listener:Function = function(event:Event):void {
    };
    private var _loads:Dictionary;
    private var _keyFromId:Dictionary;
    private var _loadCount:int;
    private var _itemsLoaded:int;
    public var items:Array;

    public function MultiLoader(name:String){
        _loads = new Dictionary();
        _keyFromId = new Dictionary();
        _itemsLoaded = 0;
        items = [];
    }

    public function add(url:String, props:Object = null):void {
        var loadingItem:LoadingItem = new LoadingItem();
        loadingItem.url = new URLRequest(url);
        loadingItem.type = getType(url, props);
        if (props){
            if (props.context){
                loadingItem.context = props.context;
            }
            if (props.id){
                _keyFromId[props.id] = url;
            }
        }
        items.push(loadingItem);
    }

    private function getType(url:String, props:Object = null):String {
        var result:String = "";
        if (props && props.type){
            return props.type;
        }
        var i:int;
        var extension:String;
        var n:int = IMAGE_EXTENSIONS.length;
        for (i = 0; i < n; i++){
            extension = IMAGE_EXTENSIONS[i];
            if (extension == url.substr(-extension.length).toLowerCase()){
                result = "image";
                break;
            }
        }
        if (result == ""){
            n = TEXT_EXTENSIONS.length;
            for (i = 0; i < n; i++){
                extension = TEXT_EXTENSIONS[i];
                if (extension == url.substr(-extension.length).toLowerCase()){
                    result = "text";
                    break;
                }
            }
        }
        return result;
    }

    public function start():void {
        var n:int = items.length;
        for (var i:int = 0; i < n; i++){
            var type:String = items[i].type;
            if (type == "image"){
                _loads[items[i].url.url] = loadImage(items[i].url, items[i].context);
            }
            if (type == "text"){
                _loads[items[i].url.url] = loadText(items[i].url);
            }
        }
    }

    public function addEventListener(type:String, listener:Function):void {
        _listener = listener;
    }

    public function getBitmap(key:String):Bitmap {
        key = keyMatching(key);
        var bitmap:Bitmap = _loads[key].content;
        return bitmap;
    }

    public function getBitmapData(key:String):BitmapData {
        key = keyMatching(key);
        var bitmap:Bitmap = getBitmap(key);
        var bitmapData:BitmapData = new BitmapData(bitmap.width, bitmap.height);
        bitmapData.draw(bitmap);
        return bitmapData;
    }

    private function loadImage(url:URLRequest, context:LoaderContext = null):Loader {
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComp);
        loader.load(url, context);
        return loader;
    }

    public function getText(key:String):String {
        key = keyMatching(key);
        return key ? _loads[key].data : key;
    }

    public function getXML(key:String):XML {
        return XML(getText(key));
    }

    private function keyMatching(key:String):String {
        return _loads[key] ? key : _keyFromId[key];
    }

    private function loadText(url:URLRequest):URLLoader {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onComp);
        loader.load(url);
        return loader;
    }

    private function onComp(event:Event):void {
        _itemsLoaded++;
        if (_itemsLoaded == items.length){
            _itemsLoaded = 0;
            _listener(event);
        }
    }

    public function get itemsTotal():int {
        return items.length;
    }

    public function get itemsLoaded():int {
        return _itemsLoaded;
    }

    public function get loadedRatio():Number {
        return _itemsLoaded / items.length;
    }
}


class LoadingItem {
    public var url:URLRequest;
    public var type:String;
    public var status:String;
    public var context:LoaderContext;

    public function LoadingItem(){
    }
    ;
}