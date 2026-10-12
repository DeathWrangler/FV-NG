package Widgets.Windows
{
   import Managers.Dec19InnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class Dec19InnovationChristmasSurpriseWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_callback:Function;
      
      private var m_subFeatureName:String;
      
      private var m_showGift:Boolean;
      
      private var m_bonus_mc:MovieClip;
      
      private var m_size_mc:MovieClip;
      
      private var m_accept_bt:FarmAnimatedButton;
      
      private var m_close_bt:FarmButton;
      
      private var m_body_tf:ZwTextField;
      
      private var m_body2_tf:ZwTextField;
      
      private var m_title_tf:ZwTextField;
      
      private var m_anim_mc:MovieClip;
      
      private var manager:Dec19InnovationManager = Dec19InnovationManager.getInstance();
      
      public function Dec19InnovationChristmasSurpriseWindow(assetPath:String = "", featureName:String = null, subFeatureName:String = null, callBack:Function = null, showGift:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_callback = callBack;
         this.m_subFeatureName = subFeatureName;
         this.m_showGift = showGift;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var daysLeft:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("bonus_mc"))
         {
            this.m_bonus_mc = m_window["bonus_mc"] as MovieClip;
            this.m_bonus_mc.visible = true;
            if(this.m_bonus_mc.hasOwnProperty("anim_mc"))
            {
               this.m_anim_mc = this.m_bonus_mc["anim_mc"] as MovieClip;
               this.m_anim_mc.stop();
            }
            if(this.m_bonus_mc.hasOwnProperty("accept_bt"))
            {
               this.m_accept_bt = new FarmAnimatedTextButton(this.m_bonus_mc["accept_bt"],"Shake the Tree!",this.onClickAcceptBonusButton);
               if(this.manager.isDailyChristmasRewardHarvested())
               {
                  this.m_accept_bt.enabled = false;
               }
               this.m_accept_bt.visible = true;
            }
            if(this.m_bonus_mc.hasOwnProperty("body_tf"))
            {
               this.m_body_tf = new ZwTextField(this.m_bonus_mc["body_tf"]);
               addWidget(this.m_body_tf);
               this.m_body_tf.text = "Come back everyday to win surprise gifts!";
               if(this.manager.isDailyChristmasRewardHarvested())
               {
                  this.m_body_tf.text = "You\'ve claimed your gift for the day! Come back tomorrow for more!";
               }
               this.m_body_tf.visible = true;
            }
            if(this.m_bonus_mc.hasOwnProperty("body2_tf"))
            {
               this.m_body2_tf = new ZwTextField(this.m_bonus_mc["body2_tf"]);
               addWidget(this.m_body2_tf);
               daysLeft = this.manager.getDaysLeftInChristmasWeek();
               this.m_body2_tf.text = "Only " + daysLeft.toString() + " days left! Claim all the gifts!";
               this.m_body2_tf.visible = true;
            }
            if(this.m_bonus_mc.hasOwnProperty("close_bt"))
            {
               this.m_close_bt = addWidget(new FarmButton(this.m_bonus_mc["close_bt"],onClose)) as FarmButton;
            }
            if(this.m_bonus_mc.hasOwnProperty("title_tf"))
            {
               this.m_title_tf = new ZwTextField(this.m_bonus_mc["title_tf"]);
               addWidget(this.m_title_tf);
               this.m_title_tf.text = "Christmas Week!";
               this.m_title_tf.visible = true;
            }
         }
      }
      
      private function onClickAcceptBonusButton(event:Event) : void
      {
         this.m_accept_bt.enabled = false;
         if(this.manager.isDailyChristmasRewardHarvested())
         {
            super.close();
         }
         else
         {
            if(this.m_anim_mc)
            {
               this.m_anim_mc.gotoAndStop(63);
            }
            this.manager.harvestChristmasReward();
         }
         this.m_body_tf.text = "You\'ve claimed your gift for the day! Come back tomorrow for more!";
      }
   }
}

