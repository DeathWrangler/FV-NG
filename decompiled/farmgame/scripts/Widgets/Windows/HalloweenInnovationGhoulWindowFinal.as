package Widgets.Windows
{
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HalloweenInnovationGhoulWindowFinal extends FarmWindowWithTutorial
   {
      
      private const FEATURE_NAME:String = "HalloweenInnovationGhoul";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const REWARD_MC:String = "reward_mc";
      
      private const FINISH1_MC:String = "finish1_mc";
      
      private const FINISH2_MC:String = "finish2_mc";
      
      private const FINISH3_MC:String = "finish3_mc";
      
      private const FINISH4_MC:String = "finish4_mc";
      
      private const SIZE_MC:String = "size_mc";
      
      private const ACCEPT_BT:String = "accept_bt";
      
      private const NPC_MC:String = "npc_mc";
      
      private var m_rewardMc:MovieClip;
      
      private var m_finish1Mc:MovieClip;
      
      private var m_finish2Mc:MovieClip;
      
      private var m_finish3Mc:MovieClip;
      
      private var m_finish4Mc:MovieClip;
      
      private var m_sizeMc:MovieClip;
      
      private var m_npcMc:MovieClip;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      public function HalloweenInnovationGhoulWindowFinal()
      {
         var dialogURL:String = this.manager.getFinalFeatureUrl();
         super(this.FEATURE_NAME,dialogURL,totalScenes);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var inventionData:Object = this.manager.getActiveGameData();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window[this.TITLE_TF],""));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window[this.BODY_TF],""));
         }
         if(m_window.hasOwnProperty(this.REWARD_MC))
         {
            this.m_rewardMc = m_window[this.REWARD_MC] as MovieClip;
            if(this.m_rewardMc[this.FINISH1_MC])
            {
               this.m_finish1Mc = this.m_rewardMc[this.FINISH1_MC] as MovieClip;
               this.m_finish1Mc.visible = false;
            }
            if(this.m_rewardMc[this.FINISH2_MC])
            {
               this.m_finish2Mc = this.m_rewardMc[this.FINISH2_MC] as MovieClip;
               this.m_finish2Mc.visible = false;
            }
            if(this.m_rewardMc[this.FINISH3_MC])
            {
               this.m_finish3Mc = this.m_rewardMc[this.FINISH3_MC] as MovieClip;
               this.m_finish3Mc.visible = false;
            }
            if(this.m_rewardMc[this.FINISH4_MC])
            {
               this.m_finish4Mc = this.m_rewardMc[this.FINISH4_MC] as MovieClip;
               this.m_finish4Mc.visible = false;
            }
            this.m_rewardMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.NPC_MC))
         {
            this.m_npcMc = m_window[this.NPC_MC] as MovieClip;
            this.m_npcMc.visible = false;
         }
         this.m_titleTf.text = "An Inventive End!";
         this.m_bodyTf.text = "You are an invention master! Harvest your invention until 10th December, 2018.";
         if(0 == inventionData.activeInvention)
         {
            this.m_finish1Mc.visible = false;
            this.m_finish2Mc.visible = false;
            this.m_finish3Mc.visible = false;
            this.m_finish4Mc.visible = false;
            this.m_npcMc.visible = true;
            this.m_rewardMc.visible = false;
            this.m_titleTf.text = "Time’s Up!";
            this.m_bodyTf.text = "We couldn’t finish our inventions. But, that’s okay. Let’s try again next time!";
         }
         else if(1 == inventionData.activeInvention)
         {
            this.m_finish1Mc.visible = true;
            this.m_finish2Mc.visible = false;
            this.m_finish3Mc.visible = false;
            this.m_finish4Mc.visible = false;
         }
         else if(2 == inventionData.activeInvention)
         {
            this.m_finish1Mc.visible = true;
            this.m_finish2Mc.visible = true;
            this.m_finish3Mc.visible = false;
            this.m_finish4Mc.visible = false;
         }
         else if(3 == inventionData.activeInvention)
         {
            this.m_finish1Mc.visible = true;
            this.m_finish2Mc.visible = true;
            this.m_finish3Mc.visible = true;
            this.m_finish4Mc.visible = false;
         }
         else if(4 == inventionData.activeInvention)
         {
            this.m_finish1Mc.visible = true;
            this.m_finish2Mc.visible = true;
            this.m_finish3Mc.visible = true;
            this.m_finish4Mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.ACCEPT_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.ACCEPT_BT],"Okay",this.onAcceptButtonClick));
         }
         if(m_window.hasOwnProperty(this.SIZE_MC))
         {
            this.m_sizeMc = m_window[this.SIZE_MC] as MovieClip;
         }
      }
      
      private function get manager() : HalloweenInnovationGhoulManager
      {
         return HalloweenInnovationGhoulManager.getInstance(this.FEATURE_NAME);
      }
      
      private function onAcceptButtonClick(event:MouseEvent) : void
      {
         super.close();
      }
   }
}

