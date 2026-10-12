package Widgets.Windows
{
   import Managers.IsraelInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.IsraelInnovationRewardsMarketFrame;
   import flash.display.MovieClip;
   
   public class IsraelInnovationRewardsMarketWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      private var m_bonusMc:MovieClip;
      
      private var m_MarketFrame:IsraelInnovationRewardsMarketFrame;
      
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
      
      private var m_owner:IsraelInnovationMainWindow;
      
      private var m_idleAniMc:MovieClip;
      
      private var m_inventoryMc:MovieClip;
      
      private var m_countTf:ZwTextField;
      
      private var m_nameTf:ZwTextField;
      
      private const REWARD_MARKET_WELCOME_SEEN_FLAG:String = "Reward_Market_Welcome_flag2";
      
      private var m_resultObject:Object;
      
      public function IsraelInnovationRewardsMarketWindow(featureName:String, ownerWindow:IsraelInnovationMainWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = ownerWindow;
         var dialogPath:String = this.manager.getRewardsMarketDialogUrl();
         if(dialogPath != "")
         {
            super(dialogPath);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"THE FARM-OFF MARKET"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],"Redeem your Farm-Off Chips on rewards you like"));
         }
         if(m_window.hasOwnProperty("slots_mc"))
         {
            this.m_MarketFrame = new IsraelInnovationRewardsMarketFrame(m_window["slots_mc"],this,this.m_featureName);
            this.m_MarketFrame.visible = true;
         }
         if(m_window.hasOwnProperty("idle_ani_mc"))
         {
            this.m_idleAniMc = m_window.idle_ani_mc as MovieClip;
            this.m_idleAniMc.visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
            if(this.m_talkMc.hasOwnProperty("npc1_tf"))
            {
               this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1 mc");
               this.m_npc1Tf.visible = false;
            }
            if(this.m_talkMc.hasOwnProperty("npc2_tf"))
            {
               this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"npc2 mc");
               this.m_npc2Tf.visible = false;
            }
         }
         var chipCountLeft:int = this.manager.chipCount;
         if(m_window.hasOwnProperty("inventory_mc"))
         {
            this.m_inventoryMc = m_window.inventory_mc as MovieClip;
            this.m_inventoryMc.visible = true;
            if(this.m_inventoryMc.hasOwnProperty("count_tf"))
            {
               if(this.m_inventoryMc.hasOwnProperty("count_tf"))
               {
                  this.m_countTf = new ZwTextField(this.m_inventoryMc["count_tf"],"x" + chipCountLeft.toString());
                  this.m_countTf.visible = true;
               }
               if(this.m_inventoryMc.hasOwnProperty("name_tf"))
               {
                  this.m_nameTf = new ZwTextField(this.m_inventoryMc["name_tf"],"Farm-Off Chips");
                  this.m_nameTf.visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window.talk_auto_mc as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = true;
               this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]," Auto npc1");
               this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.REWARD_MARKET_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("Chips for Goodies","Redeem your Farm-Off chips for great rewards. New rewards every week.");
         }
         if(this.manager.isFeatureInRedeemPeriod())
         {
            this.showAutoHideNPCCallouts("Redeem your rewards!","The Farm-Off market closes 9th Oct. Redeem your Farm-Off Chips soon!");
         }
      }
      
      private function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_autoNpc2Tf.text = text;
         this.m_autoNpc1Tf.text = title;
         this.m_talkAutoMc.visible = true;
         this.m_talkAutoMc.gotoAndPlay(1);
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.REWARD_MARKET_WELCOME_SEEN_FLAG);
      }
      
      public function updateChipCount(chipCount:String) : void
      {
         this.m_countTf.text = "x" + chipCount;
      }
      
      public function refreshMarketWindow() : void
      {
         return this.m_MarketFrame.refresh();
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance(this.m_featureName);
      }
      
      override public function close() : void
      {
         if(this.m_owner)
         {
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
         super.close();
      }
   }
}

