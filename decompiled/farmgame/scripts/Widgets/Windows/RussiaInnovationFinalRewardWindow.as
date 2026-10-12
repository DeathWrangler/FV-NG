package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.RussiaInnovationManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class RussiaInnovationFinalRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const BODY2_TF:String = "body2_tf";
      
      private var m_featureName:String;
      
      private var m_bonusArray_mc:Array;
      
      public const ProgressLevelTextArray:Array = ["Strong","Stronger","Strongest"];
      
      private var m_progressLevel_mc:MovieClip;
      
      private var m_progressLevel_tf:ZwTextField;
      
      private var m_grantedBonus:FarmItem;
      
      private var m_jumpNPC:MovieClip;
      
      private var m_idleNPC:MovieClip;
      
      public function RussiaInnovationFinalRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         this.m_grantedBonus = this.manager.grantedBonusRewardItem;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var child:MovieClip = null;
         var grandChild:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.TITLE_TF].text = "A Powerful Finish!";
            }
            else
            {
               m_window[this.TITLE_TF].text = "Training Ended";
            }
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.BODY_TF].text = "You are truly a Strongman! You have won the " + this.manager.grantedBonusRewardItem.friendlyTitle + ". Find it in your giftbox.";
            }
            else
            {
               m_window[this.BODY_TF].text = "Your strength training has now come to an end";
            }
         }
         if(m_window.hasOwnProperty(this.BODY2_TF))
         {
            m_window[this.BODY2_TF].visible = true;
            if(this.m_grantedBonus)
            {
               m_window[this.BODY2_TF].text = "Harvest " + this.manager.grantedBonusRewardItem.friendlyTitle + " every 24 hours to get any consumable shown above.";
            }
            else
            {
               m_window[this.BODY2_TF].text = "That was fun. It was great having you around!";
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
         var childIndex:int = 1;
         var grandChildIndex:int = 1;
         if(this.m_grantedBonus != null && this.manager.overAllProgressLevel() >= 0)
         {
            if(m_window.hasOwnProperty("jump_ani_mc"))
            {
               this.m_jumpNPC = m_window["jump_ani_mc"] as MovieClip;
               this.m_jumpNPC.visible = true;
               for(childIndex = 1; childIndex < this.m_jumpNPC.numChildren; childIndex++)
               {
                  child = this.m_jumpNPC.getChildAt(childIndex) as MovieClip;
                  if(child)
                  {
                     child.play();
                     for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
                     {
                        grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                        if(grandChild)
                        {
                           grandChild.play();
                        }
                     }
                  }
               }
               this.m_jumpNPC.play();
            }
         }
         else if(m_window.hasOwnProperty("idle_ani_mc"))
         {
            this.m_idleNPC = m_window["idle_ani_mc"] as MovieClip;
            this.m_idleNPC.visible = true;
            for(childIndex = 1; childIndex < this.m_idleNPC.numChildren; childIndex++)
            {
               child = this.m_idleNPC.getChildAt(childIndex) as MovieClip;
               if(child)
               {
                  child.play();
                  for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
                  {
                     grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                     if(grandChild)
                     {
                        grandChild.play();
                     }
                  }
               }
            }
            this.m_idleNPC.play();
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
      
      private function get manager() : RussiaInnovationManager
      {
         return RussiaInnovationManager.getInstance();
      }
   }
}

