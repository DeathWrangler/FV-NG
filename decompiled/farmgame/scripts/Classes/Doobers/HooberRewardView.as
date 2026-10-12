package Classes.Doobers
{
   import Classes.Constants.DooberConstants;
   import com.greensock.TimelineLite;
   import com.greensock.TweenAlign;
   import com.greensock.TweenLite;
   import com.greensock.easing.Circ;
   import com.greensock.easing.Sine;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class HooberRewardView extends DooberRewardView
   {
      
      private static const HOOBER_EXPIRE_MS:int = 5000;
      
      private var m_timer:Timer = null;
      
      public function HooberRewardView(type:String, amount:Number, iconUrl:String)
      {
         super(type,amount,iconUrl);
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
         startTextAnimation();
         addEventListener(MouseEvent.MOUSE_OVER,this.onDooberOver);
         this.m_timer = new Timer(HOOBER_EXPIRE_MS);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onDooberOver);
         this.m_timer.start();
      }
      
      private function onDooberOver(event:Event) : void
      {
         removeEventListener(MouseEvent.MOUSE_OVER,this.onDooberOver);
         if(this.m_timer != null)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onDooberOver);
            this.m_timer.stop();
            this.m_timer = null;
         }
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

