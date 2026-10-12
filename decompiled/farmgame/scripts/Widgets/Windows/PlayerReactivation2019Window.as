package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class PlayerReactivation2019Window extends FarmWindow
   {
      
      private static const FEATURE_NAME:String = "PlayerReactivation2019";
      
      private var m_featureName:String = FEATURE_NAME;
      
      public var m_rewardIndex:int;
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTEXT1_TF:String = "subtext1_tf";
      
      private const ACCEPT_BT:String = "accept_bt";
      
      private var checkMarkMCArray:Array = [];
      
      private var m_acceptdBt:FarmAnimatedTextButton;
      
      private const BODY_TF:String = "body_tf";
      
      private const FC_COUNT_TF:String = "fc_count_tf";
      
      public function PlayerReactivation2019Window(assetPath:String, rewardIndex:int)
      {
         this.m_rewardIndex = rewardIndex;
         super(assetPath);
      }
      
      protected function onClick() : void
      {
      }
      
      override protected function postLoadComplete() : void
      {
         var body_text:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Congrats Farmer!"));
         }
         if(m_window.hasOwnProperty(this.FC_COUNT_TF))
         {
            addWidget(new ZwTextField(m_window[this.FC_COUNT_TF],"x" + (this.m_rewardIndex + 1).toString()));
         }
         if(this.m_rewardIndex == 3)
         {
            body_text = "Hope you\'ll enjoy your gifts. You can find them in your gift box.";
         }
         else
         {
            body_text = "Hope you\'ll enjoy your gifts. You can find them in your gift box.\nCome back every day to unlock your next set of gifts!";
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(new ZwTextField(m_window[this.BODY_TF],body_text));
         }
         if(m_window.hasOwnProperty("today_reward_tf"))
         {
            addWidget(new ZwTextField(m_window["today_reward_tf"],"Day " + (this.m_rewardIndex + 1).toString()));
         }
         if(m_window.hasOwnProperty(this.ACCEPT_BT))
         {
            addWidget(this.m_acceptdBt = new FarmAnimatedTextButton(m_window[this.ACCEPT_BT],"Awesome",onClose));
            this.m_acceptdBt.visible = true;
            this.m_acceptdBt.enabled = true;
         }
         for(var i:int = 0; i < 4; i++)
         {
            this.checkMarkMCArray[i] = m_window["checkmark" + i.toString() + "_mc"] as MovieClip;
            if(this.m_rewardIndex >= i)
            {
               this.checkMarkMCArray[i].visible = true;
            }
            else
            {
               this.checkMarkMCArray[i].visible = false;
            }
         }
      }
   }
}

