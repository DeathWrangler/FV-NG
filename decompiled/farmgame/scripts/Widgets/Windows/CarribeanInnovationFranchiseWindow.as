package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CarribeanInnovationFranchiseTaskFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class CarribeanInnovationFranchiseWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      private var m_bonusMc:MovieClip;
      
      private var m_FranchiseFrame:CarribeanInnovationFranchiseTaskFrame;
      
      private var NO_OF_BUILDINGS:Number = 8;
      
      private var m_npcMc:MovieClip;
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_ownerWindow:CarribeanInnovationWindow = null;
      
      private var m_marketItems:Array = new Array();
      
      private const FIRST_TIME_FRANCHISE_VIEW:String = "first_time_franchise_view";
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_hitWidget1:ZwFrame;
      
      private var m_bundleBt:FarmAnimatedTextButton;
      
      private var m_unlockBtn:FarmAnimatedTextButton;
      
      public function CarribeanInnovationFranchiseWindow(featureName:String, featureBuiilding:FeatureBuilding = null)
      {
         this.m_featureName = featureName;
         var dialogPath:String = this.manager.getFranchiseDialogUrl();
         if(dialogPath != "")
         {
            super(dialogPath);
         }
         this.m_marketItems.push(CarribeanInnovationManager.BRAZIL_TILE_LIST);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Franchise"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],"Unlock land to get friendly locals to work for you and earn fame." + "\n" + "You have unlocked " + this.manager.getTileUnlockCount() + " land tiles."));
         }
         if(m_window.hasOwnProperty("bundle_bt"))
         {
            addWidget(this.m_bundleBt = new FarmAnimatedTextButton(m_window["bundle_bt"],"Show me!",this.onButtonClick));
            this.m_bundleBt.visible = !this.manager.isLandBundleUnlocked() && this.manager.isLandbundleActive();
         }
         if(m_window.hasOwnProperty("bonus_mc") && (this.manager.isLandbundleActive() || this.manager.isLandBundleUnlocked()))
         {
            this.m_bonusMc = m_window.bonus_mc as MovieClip;
            this.m_bonusMc.visible = true;
            if(this.m_bonusMc.hasOwnProperty("bonus_tf"))
            {
               addWidget(new ZwTextField(this.m_bonusMc["bonus_tf"],"The Beach Cafe"));
            }
            this.m_hitWidget1 = new ZwFrame(this.m_bonusMc);
            this.m_hitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver());
            this.m_hitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            if(this.m_bonusMc.hasOwnProperty("checkmark_mc"))
            {
               this.m_checkmarkMc = this.m_bonusMc.checkmark_mc as MovieClip;
               this.m_checkmarkMc.visible = !this.m_bundleBt.visible;
            }
         }
         if(m_window.hasOwnProperty("slots_mc"))
         {
            this.m_FranchiseFrame = new CarribeanInnovationFranchiseTaskFrame(m_window["slots_mc"],this,this.m_featureName);
            this.m_FranchiseFrame.visible = true;
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npcMc = m_window.npc_mc as MovieClip;
            this.m_npcMc.visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
            addWidget(this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1"));
            addWidget(this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"Default NPC Text"));
         }
         if(m_window.hasOwnProperty("generic_bt"))
         {
            addWidget(this.m_unlockBtn = new FarmAnimatedTextButton(m_window["generic_bt"],"Unlock Land",this.onUnlockButtonClick));
            if(this.manager.getTileUnlockCount() >= 8)
            {
               this.m_unlockBtn.visible = false;
            }
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window.talk_auto_mc as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = false;
               if(this.m_autoTalkMc.hasOwnProperty("npc1_tf"))
               {
                  this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]);
               }
               if(this.m_autoTalkMc.hasOwnProperty("npc2_tf"))
               {
                  this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"]);
               }
            }
         }
         if(!Global.player.getSeenFlag(this.FIRST_TIME_FRANCHISE_VIEW))
         {
            Global.player.setSeenFlag(this.FIRST_TIME_FRANCHISE_VIEW);
            this.setNPCAutoHideText();
         }
      }
      
      private function onMouseOver() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(m_checkmarkMc.visible)
            {
               setNPCText(m_checkmarkMc.visible,"The Beach Cafe!","The fancy folk of Starfish island eat at our premium cafe! We get double the fame for a single Franchise.");
            }
         };
      }
      
      private function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            hideNpcText();
         };
      }
      
      private function onUnlockButtonClick(event:MouseEvent) : void
      {
         StatsManager.count(this.m_featureName,"FranchiseUI","unlock");
         if(this.m_ownerWindow)
         {
            this.m_ownerWindow.untintWindow();
            this.m_ownerWindow.enableInput = true;
            this.m_ownerWindow.close();
         }
         close();
         UI.displayMiniMarketDialog(this.m_marketItems[0],null,"seed",null,true,false,false,true);
         this.manager.closeMainWindow();
      }
      
      private function onButtonClick(event:MouseEvent) : void
      {
         close();
         StatsManager.count(this.m_featureName,"FranchiseUI","ShowBundle");
         UI.displayPopup(new CaribbeanLandBundleWindow(this.m_featureName),false);
      }
      
      private function onCloseButtonClick(event:MouseEvent) : void
      {
         if(this.m_ownerWindow)
         {
            this.m_ownerWindow.untintWindow();
            this.m_ownerWindow.enableInput = true;
         }
         StatsManager.count(this.m_featureName,"FranchiseUI","close");
         close();
      }
      
      private function get manager() : CarribeanInnovationManager
      {
         return CarribeanInnovationManager.getInstance(this.m_featureName);
      }
      
      public function setNPCAutoHideText() : void
      {
         this.m_autoTalkMc.visible = true;
         this.m_talkAutoMc.visible = true;
         this.m_autoNpc1Tf.text = "Franchises give fame";
         this.m_autoNpc2Tf.text = "Unlock land to open franchises in the area. This will give you fame every 12 hours. More land gives you more fame. Fame harvest maxes out at 8 tiles.";
      }
      
      public function setNPCText(isFranchiseUnlocked:Boolean, title:String = "", text:String = "") : void
      {
         this.m_talkMc.visible = true;
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
      }
      
      public function hideNpcText() : void
      {
         this.m_talkMc.visible = false;
      }
   }
}

