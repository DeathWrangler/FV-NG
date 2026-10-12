package Classes.Doobers
{
   import Classes.Constants.DooberConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import com.greensock.TimelineLite;
   import com.greensock.TweenAlign;
   import com.greensock.TweenLite;
   import com.greensock.easing.Sine;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.TextFieldView;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class DooberRewardView extends Sprite
   {
      
      public static const CLASS_NAME:String = "DooberRewardView";
      
      private var m_iconUrl:String = "";
      
      private var m_type:String = "";
      
      private var m_amount:Number = 0;
      
      private var m_textFieldView:TextFieldView;
      
      private var m_textFieldViewTargetX:Number = 0;
      
      private var m_textFieldViewTargetXFinal:Number = 0;
      
      private var m_textFieldViewTargetY:Number = 0;
      
      private var m_animationCallback:Function = null;
      
      public function DooberRewardView(type:String, amount:Number, iconUrl:String)
      {
         super();
         this.m_type = type;
         this.m_iconUrl = iconUrl;
         this.m_amount = amount;
      }
      
      public function startLoad() : void
      {
         LoadingManager.load(Global.getAssetURL(this.m_iconUrl),this.onIconLoadComplete,LoadingManager.PRIORITY_HIGH,this.onIconLoadFail);
      }
      
      protected function onIconLoadComplete(event:Event) : void
      {
         var displayObject:DisplayObject = event.target.content as DisplayObject;
         if(displayObject)
         {
            displayObject.x = displayObject.width * -0.5;
            displayObject.y = displayObject.width * -0.5;
            this.addChild(displayObject);
         }
         var labelText:String = ZLocUtils.t("FarmGame",DooberConstants.REWARD_LABEL_STRING_PREFIX + this.type,{"quantity":this.m_amount});
         var textStyle:BaseStyle = MT4DManager.getInstance().getStyle("DooberRewardLabelText");
         this.m_textFieldView = new TextFieldView(textStyle);
         this.m_textFieldView.setAttribute("text",labelText);
         this.m_textFieldView.filters = textStyle.getFilters();
         this.m_textFieldViewTargetX = this.m_textFieldView.width * 1.2 * -0.5;
         this.m_textFieldViewTargetXFinal = this.m_textFieldView.width * -0.5;
         this.m_textFieldViewTargetY = displayObject.y + displayObject.height + this.m_textFieldView.height * -0.5;
         this.m_textFieldView.scaleX = 0;
         this.m_textFieldView.scaleY = 0;
         addChild(this.m_textFieldView);
         this.graphics.beginFill(16711680);
         this.graphics.drawCircle(0,0,4);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function startTextAnimation() : void
      {
         var timeline:TimelineLite = new TimelineLite();
         timeline.appendMultiple([new TweenLite(this.m_textFieldView,0.5,{
            "scaleX":1.2,
            "scaleY":1.2,
            "x":this.m_textFieldViewTargetX,
            "y":this.m_textFieldViewTargetY
         }),new TweenLite(this.m_textFieldView,0.5,{
            "scaleX":1,
            "scaleY":1,
            "x":this.m_textFieldViewTargetXFinal
         })],0,TweenAlign.SEQUENCE);
      }
      
      private function cleanupText() : void
      {
         if(this.m_textFieldView != null)
         {
            this.m_textFieldView.destroy();
            this.m_textFieldView = null;
         }
      }
      
      private function onIconLoadFail(event:Event) : void
      {
         GlobalEngine.log(CLASS_NAME,"Error loading " + this.m_iconUrl);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function tweenRewardView(xDistance:Number, callback:Function = null) : void
      {
         this.m_animationCallback = callback;
         var rand:Number = Math.random();
         var travelTime:Number = rand * DooberConstants.ANIM_TRAVEL_TIME_SCALE_FACTOR + DooberConstants.ANIM_TRAVEL_TIME_MIN;
         var origin:Point = new Point(this.x,this.y);
         var arcPeakY:Number = origin.y + Math.floor(rand * DooberConstants.ANIM_ARC_PEAK_SCALE_FACTOR + DooberConstants.ANIM_ARC_PEAK_MIN);
         var arcLandingY:Number = origin.y - this.height;
         TweenLite.to(this,travelTime,{
            "x":xDistance,
            "rotation":0,
            "ease":Sine.easeOut
         });
         var timeLineParams:Object = {
            "travelTime":travelTime,
            "arcPeakY":arcPeakY,
            "arcLandingY":arcLandingY,
            "xDistance":xDistance
         };
         var timeline:TimelineLite = new TimelineLite();
         timeline.appendMultiple(this.getTimelineArray(timeLineParams),0,TweenAlign.SEQUENCE);
      }
      
      protected function getTimelineArray(params:Object) : Array
      {
         return [new TweenLite(this,params.travelTime * 0.5,{
            "y":params.arcPeakY,
            "scaleX":DooberConstants.ANIM_REWARD_SCALE_END,
            "scaleY":DooberConstants.ANIM_REWARD_SCALE_END,
            "ease":Sine.easeOut
         }),new TweenLite(this,params.travelTime * 0.5,{
            "y":params.arcLandingY,
            "ease":Sine.easeInOut,
            "onComplete":this.startTextAnimation
         }),new TweenLite(this,4,{
            "y":DooberConstants.ANIM_REWARD_RISE_Y,
            "delay":DooberConstants.ANIM_REWARD_RISE_DELAY,
            "alpha":0,
            "ease":Sine.easeOut,
            "onComplete":this.bounceComplete
         })];
      }
      
      protected function bounceComplete() : void
      {
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         this.cleanupText();
         if(this.m_animationCallback != null)
         {
            this.m_animationCallback();
         }
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get amount() : int
      {
         return this.m_amount;
      }
      
      public function set amount(amount:int) : void
      {
         this.m_amount = amount;
      }
   }
}

