package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Managers.SouthindiaInnovationManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class SouthindiaInnovationFinalRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const BODY2_TF:String = "body2_tf";
      
      private var m_featureName:String;
      
      private var m_bonusArray_mc:Array;
      
      private var m_idleNpc_mc:Array = [];
      
      private var m_activeNpc_mc:Array = [];
      
      public const ProgressLevelTextArray:Array = ["EXPERT","PROFESSIONAL","CHAMPION"];
      
      private var m_progressLevel_mc:MovieClip;
      
      private var m_progressLevel_tf:ZwTextField;
      
      private var m_grantedBonus:FarmItem;
      
      private var m_jumpNPC:MovieClip;
      
      private var m_idleNPC:MovieClip;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      public function SouthindiaInnovationFinalRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         this.m_grantedBonus = this.manager.grantedBonusRewardItem;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.TITLE_TF].text = "THE COMPETITION IS OVER!";
            }
            else
            {
               m_window[this.TITLE_TF].text = "THE COMPETITION IS OVER!";
            }
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.BODY_TF].text = "You played amazingly well!";
            }
            else
            {
               m_window[this.BODY_TF].text = "You’ve not scored enough to be eligible for the bonus prize";
            }
         }
         if(m_window.hasOwnProperty(this.BODY2_TF))
         {
            m_window[this.BODY2_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.BODY2_TF].text = "Enjoy your " + this.manager.grantedBonusRewardItem.friendlyTitle + " and remember to harvest it everyday till April 21,2019";
            }
            else
            {
               m_window[this.BODY2_TF].text = "Keep playing Farmville for more fun features and win cool rewards!";
            }
         }
         if(m_window.hasOwnProperty("giftbox_mc"))
         {
            this.m_gift_mc = m_window.giftbox_mc;
            if(this.m_grantedBonus)
            {
               this.m_gift_mc.visible = true;
            }
            else
            {
               this.m_gift_mc.visible = false;
            }
         }
         this.m_bonusArray_mc = new Array();
         for(var i:int = 0; i < 3; i++)
         {
            this.m_bonusArray_mc[i] = m_window["Bonus_" + (i + 1).toString()] as MovieClip;
            this.m_bonusArray_mc[i].visible = false;
         }
         this.m_progressLevel_mc = m_window["level_mc"] as MovieClip;
         this.m_progressLevel_mc.visible = true;
         this.m_progressLevel_tf = new ZwTextField(this.m_progressLevel_mc["level_tf"],"");
         this.showBonusReward();
         if(this.m_grantedBonus != null && this.manager.overAllProgressLevel() >= 0)
         {
            for(i = 0; i < 3; i++)
            {
               if(m_window.hasOwnProperty("active" + (i + 1).toString() + "_ani_mc"))
               {
                  this.m_activeNpc_mc[i] = m_window["active" + (i + 1).toString() + "_ani_mc"] as MovieClip;
                  this.m_activeNpc_mc[i].visible = false;
               }
            }
            this.showActiveNPCForCurrentLeague();
         }
         else
         {
            for(i = 0; i < 3; i++)
            {
               if(m_window.hasOwnProperty("idle" + (i + 1).toString() + "_ani_mc"))
               {
                  this.m_idleNpc_mc[i] = m_window["idle" + (i + 1).toString() + "_ani_mc"] as MovieClip;
                  this.m_idleNpc_mc[i].visible = this.manager.getCurrentLeague() == i;
               }
            }
         }
      }
      
      private function showBonusReward() : void
      {
         for(var i:int = 0; i < 3; i++)
         {
            if(i == this.manager.overAllProgressLevel())
            {
               this.m_bonusArray_mc[i].visible = true;
               (this.m_bonusArray_mc[i]["highlighter_mc"] as MovieClip).visible = true;
            }
         }
         if(this.manager.overAllProgressLevel() >= 0)
         {
            this.m_progressLevel_tf.text = this.ProgressLevelTextArray[this.manager.overAllProgressLevel()];
         }
         else
         {
            this.m_progressLevel_mc.visible = false;
         }
      }
      
      public function showActiveNPCForCurrentLeague() : void
      {
         var league:int = this.manager.getCurrentLeague();
         var activeNPC:MovieClip = this.m_activeNpc_mc[league];
         if(activeNPC)
         {
            activeNPC.visible = true;
            activeNPC.play();
         }
      }
      
      private function onActiveNPCAnimationComplete(activeNPC:MovieClip) : Function
      {
         return function(event:Event):void
         {
            if(activeNPC.currentFrame == 120)
            {
               activeNPC.stop();
               activeNPC.visible = false;
               activeNPC.removeEventListener(Event.ENTER_FRAME,onActiveNPCAnimationComplete(activeNPC));
               showIdleNPC();
            }
         };
      }
      
      private function showIdleNPC() : void
      {
         var league:int = 0;
         league = this.manager.getCurrentLeague();
         var idleNPC:MovieClip = this.m_idleNpc_mc[league];
         if(idleNPC)
         {
            idleNPC.visible = true;
            MovieClipUtils.recursivePlay(idleNPC);
         }
      }
      
      private function get manager() : SouthindiaInnovationManager
      {
         return SouthindiaInnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         if(this.manager.m_leaderboardWindow)
         {
            this.manager.m_leaderboardWindow.untintWindow();
            this.manager.m_leaderboardWindow.enableInput = true;
         }
         super.close();
      }
   }
}

