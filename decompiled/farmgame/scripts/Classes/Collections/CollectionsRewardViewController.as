package Classes.Collections
{
   import Classes.Constants.CollectionsConstants;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import com.greensock.TimelineLite;
   import com.greensock.TweenAlign;
   import com.greensock.TweenLite;
   import com.greensock.easing.Sine;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class CollectionsRewardViewController extends EventDispatcher
   {
      
      private static var m_direction:int = 0;
      
      private var m_rewardViews:Vector.<DisplayObject>;
      
      private var m_collectible:Collectible;
      
      private var m_collectibleDisplayObj:Sprite;
      
      private var m_position:Vector3;
      
      private var m_loadingCount:int = 0;
      
      private var m_tweeningCount:int = 0;
      
      public function CollectionsRewardViewController(collectible:Collectible, position:Vector3)
      {
         super();
         this.m_collectible = collectible;
         if(position)
         {
            this.m_position = position;
         }
         this.m_collectibleDisplayObj = new Sprite();
         this.loadRewardViews();
      }
      
      public function loadRewardViews() : void
      {
         LoadingManager.load(this.m_collectible.item.icon,this.onIconLoadComplete,LoadingManager.PRIORITY_HIGH,this.onIconLoadFail);
      }
      
      private function onIconLoadComplete(event:Event) : void
      {
         var xDistance:Number = NaN;
         var displayObj:DisplayObject = event.target.content as DisplayObject;
         displayObj.x = displayObj.width * -0.5;
         displayObj.y = displayObj.width * -0.5;
         this.m_collectibleDisplayObj.addChild(displayObj);
         var screen:Vector2 = IsoMath.tilePosToPixelPos(this.m_position.x,this.m_position.y,this.m_position.z);
         var randomNumber:Number = Math.floor(Math.random() * 100 + 20);
         this.m_collectibleDisplayObj.x = screen.x;
         this.m_collectibleDisplayObj.y = screen.y;
         this.m_collectibleDisplayObj.scaleX = this.m_collectibleDisplayObj.scaleY = 0;
         this.m_collectibleDisplayObj.rotation -= randomNumber;
         if(m_direction % 2 == 0)
         {
            xDistance = screen.x + randomNumber;
         }
         else
         {
            xDistance = screen.x - randomNumber;
         }
         ++m_direction;
         this.m_collectibleDisplayObj.rotation -= randomNumber;
         this.tweenRewardView(xDistance);
         GlobalEngine.viewport.uiBase.addChild(this.m_collectibleDisplayObj);
         if(this.m_collectible.rarityNumber > 0)
         {
            SoundManager.addOrPlaySound("sfx_collectible",Global.getAssetURL(CollectionsConstants.SFX_RARE_COLLECTIBLE));
         }
         else
         {
            SoundManager.addOrPlaySound("sfx_collectible",Global.getAssetURL(CollectionsConstants.SFX_COLLECTIBLE));
         }
      }
      
      private function onIconLoadFail(event:Event) : void
      {
         GlobalEngine.log("CollectionsRewardViewController","Error loading " + this.m_collectible.item.icon);
      }
      
      private function tweenRewardView(xDistance:Number) : void
      {
         var stageCoords:Point;
         var objCoords:Point;
         var stageDestination:Point;
         var travelX:Number;
         var travelY:Number;
         var timeline:TimelineLite;
         var rand:Number = Math.random();
         var travelTime:Number = rand * 0.5 + 0.25;
         var origin:Point = new Point(this.m_collectibleDisplayObj.x,this.m_collectibleDisplayObj.y);
         var arcPeakY:Number = origin.y + Math.floor(rand * -50 + -30);
         var arcLandingY:Number = origin.y - this.m_collectibleDisplayObj.height;
         TweenLite.to(this.m_collectibleDisplayObj,travelTime,{
            "x":xDistance,
            "rotation":0,
            "ease":Sine.easeOut
         });
         stageCoords = GlobalEngine.viewport.uiBase.localToGlobal(new Point(this.m_collectibleDisplayObj.x,this.m_collectibleDisplayObj.y));
         objCoords = this.m_collectibleDisplayObj.localToGlobal(new Point(this.m_position.x,this.m_position.y));
         stageDestination = new Point(Global.stage.stageWidth / 2,Global.stage.stageHeight - 90);
         travelX = stageDestination.x - stageCoords.x;
         travelY = stageDestination.y - stageCoords.y;
         timeline = new TimelineLite();
         timeline.appendMultiple([new TweenLite(this.m_collectibleDisplayObj,travelTime * 0.5,{
            "y":arcPeakY,
            "scaleX":0.5,
            "scaleY":0.5,
            "ease":Sine.easeOut
         }),new TweenLite(this.m_collectibleDisplayObj,travelTime * 0.5,{
            "y":arcLandingY,
            "ease":Sine.easeInOut,
            "onComplete":function():void
            {
            }
         }),new TweenLite(this.m_collectibleDisplayObj,0.75,{
            "y":arcPeakY,
            "delay":0,
            "ease":Sine.easeOut
         }),new TweenLite(this.m_collectibleDisplayObj,1.5,{
            "x":origin.x + travelX,
            "y":origin.y + travelY - 80,
            "alpha":0,
            "ease":Sine.easeIn,
            "onComplete":this.clearDisplayObject
         })],0,TweenAlign.SEQUENCE);
         TweenLite.to(this.m_collectibleDisplayObj,1.5,{
            "scaleX":0.25,
            "scaleY":0.25,
            "delay":travelTime + 0.75,
            "ease":Sine.easeOut
         });
      }
      
      private function clearDisplayObject() : void
      {
         GlobalEngine.viewport.uiBase.removeChild(this.m_collectibleDisplayObj);
      }
   }
}

