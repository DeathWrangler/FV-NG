package Classes.Doobers
{
   import Classes.Constants.DooberConstants;
   import Engine.Helpers.Vector2;
   import com.greensock.TimelineLite;
   import com.greensock.TweenAlign;
   import com.greensock.TweenLite;
   import com.greensock.easing.Circ;
   import com.greensock.easing.Sine;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FishingRewardView extends DooberRewardView
   {
      
      private var m_screenCoords:Vector2;
      
      public function FishingRewardView(type:String, amount:Number, iconUrl:String, screenCoords:Vector2)
      {
         super(type,amount,iconUrl);
         this.m_screenCoords = screenCoords;
      }
      
      override protected function onIconLoadComplete(event:Event) : void
      {
         var displayObject:DisplayObject = event.target.content as DisplayObject;
         if(displayObject)
         {
            displayObject.x = displayObject.width * -0.5;
            displayObject.y = displayObject.width * -0.5;
            this.addChild(displayObject);
         }
         var xDistance:Number = this.m_screenCoords.x + Math.random() * 200 - 100;
         tweenRewardView(xDistance);
      }
      
      override protected function getTimelineArray(params:Object) : Array
      {
         return [new TweenLite(this,params.travelTime * 0.5,{
            "y":params.arcPeakY,
            "scaleX":DooberConstants.ANIM_REWARD_SCALE_END,
            "scaleY":DooberConstants.ANIM_REWARD_SCALE_END,
            "ease":Sine.easeOut
         }),new TweenLite(this,params.travelTime * 0.5,{
            "y":params.arcLandingY,
            "ease":Sine.easeInOut
         }),new TweenLite(this,0.2,{
            "scaleX":1.3 * DooberConstants.ANIM_REWARD_SCALE_END,
            "scaleY":0.6 * DooberConstants.ANIM_REWARD_SCALE_END,
            "ease":Circ.easeOut
         }),new TweenLite(this,0.25,{
            "y":params.arcPeakY,
            "ease":Sine.easeOut,
            "scaleX":0.9 * DooberConstants.ANIM_REWARD_SCALE_END,
            "scaleY":1.2 * DooberConstants.ANIM_REWARD_SCALE_END
         }),new TweenLite(this,0.25,{
            "y":params.arcLandingY,
            "ease":Sine.easeInOut,
            "scaleX":DooberConstants.ANIM_REWARD_SCALE_END,
            "scaleY":DooberConstants.ANIM_REWARD_SCALE_END,
            "onComplete":this.arcDone
         })];
      }
      
      private function arcDone() : void
      {
         var timeline:TimelineLite = new TimelineLite();
         timeline.appendMultiple([new TweenLite(this,0.25,{
            "scaleX":1.5 * DooberConstants.ANIM_REWARD_SCALE_END,
            "scaleY":1.5 * DooberConstants.ANIM_REWARD_SCALE_END
         }),new TweenLite(this,0.25,{
            "scaleX":0,
            "scaleY":0,
            "onComplete":bounceComplete
         })],0,TweenAlign.SEQUENCE);
      }
   }
}

