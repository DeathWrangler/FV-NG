package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BoraBoraInnovationCycleEndWindow extends FarmWindow
   {
      
      private var m_cycleCompleteMc:MovieClip;
      
      private var m_npcHolderMc:MovieClip;
      
      private var m_okatBt:FarmAnimatedTextButton;
      
      private var m_featureName:String;
      
      private var m_decoCountMc:MovieClip;
      
      private var m_npcIcon:FarmIcon;
      
      private var m_starReceivedMc:MovieClip;
      
      private var m_chairIcon:FarmIcon;
      
      private var m_npcIcon0:FarmIcon;
      
      private var m_lastShow:Boolean;
      
      public function BoraBoraInnovationCycleEndWindow(featureName:String, windowAssetRelUrl:String, lastShown:Boolean)
      {
         this.m_featureName = featureName;
         this.m_lastShow = lastShown;
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var totalDecosGrant:int = 0;
         var item:FarmItem = null;
         var starRating:String = null;
         var m_receivedStreakMc:MovieClip = null;
         var ratings:Array = null;
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("cycle_complete_mc"))
         {
            this.m_cycleCompleteMc = m_window["cycle_complete_mc"] as MovieClip;
            this.m_cycleCompleteMc.visible = true;
            if(this.m_cycleCompleteMc.hasOwnProperty("header_tf"))
            {
            }
            if(this.m_cycleCompleteMc.hasOwnProperty("cycle_end_subtext_tf"))
            {
               addWidget(new ZwTextField(this.m_cycleCompleteMc["cycle_end_subtext_tf"],this.manager.getCycleEndSubtext()));
            }
            if(this.m_cycleCompleteMc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_okatBt = new FarmAnimatedTextButton(this.m_cycleCompleteMc["okay_bt"],"Okay!",this.onOkayClick));
            }
            if(this.m_cycleCompleteMc.hasOwnProperty("deco_count_mc"))
            {
               this.m_decoCountMc = this.m_cycleCompleteMc["deco_count_mc"] as MovieClip;
               totalDecosGrant = this.manager.getTotalUniqueDecoGranted();
               this.m_decoCountMc.visible = totalDecosGrant != 0;
               if(this.m_decoCountMc.hasOwnProperty("deco_count_tf"))
               {
                  addWidget(new ZwTextField(this.m_decoCountMc["deco_count_tf"],totalDecosGrant.toString()));
               }
               if(this.m_decoCountMc.hasOwnProperty("each_chair_mc"))
               {
                  addWidget(this.m_chairIcon = new FarmIcon(this.m_decoCountMc["each_chair_mc"]));
                  item = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.getCycleEndChairCode());
                  this.m_chairIcon.loadIcon(item.iconUrl);
                  this.m_chairIcon.setIconSize(50,50);
                  this.m_chairIcon.visible = true;
               }
            }
            if(this.m_cycleCompleteMc.hasOwnProperty("npcholder_mc"))
            {
               this.m_npcHolderMc = this.m_cycleCompleteMc["npcholder_mc"] as MovieClip;
               this.m_npcHolderMc.visible = true;
               if(this.m_npcHolderMc.hasOwnProperty("npc_icon"))
               {
                  addWidget(this.m_npcIcon = new FarmIcon(this.m_npcHolderMc["npc_icon"]));
                  this.m_npcIcon.loadIcon(this.manager.getCycleNPCBrideImage());
                  this.m_npcIcon.visible = true;
               }
               if(this.m_npcHolderMc.hasOwnProperty("npc_icon_0"))
               {
                  addWidget(this.m_npcIcon0 = new FarmIcon(this.m_npcHolderMc["npc_icon_0"]));
                  this.m_npcIcon0.loadIcon(this.manager.getCycleNPCGroomImage());
                  this.m_npcIcon0.visible = true;
               }
            }
            if(this.m_cycleCompleteMc.hasOwnProperty("stars_recieved_mc"))
            {
               this.m_starReceivedMc = this.m_cycleCompleteMc["stars_recieved_mc"] as MovieClip;
               if(this.m_starReceivedMc.hasOwnProperty("couple_rating_tf"))
               {
                  addWidget(new ZwTextField(this.m_starReceivedMc["couple_rating_tf"],this.manager.getCycleNPCNames() + "\'s Wedding"));
               }
               starRating = this.manager.getStarRating();
               if(this.m_starReceivedMc.hasOwnProperty("star_rating_tf"))
               {
                  addWidget(new ZwTextField(this.m_starReceivedMc["star_rating_tf"],starRating.toString()));
               }
               if(this.m_starReceivedMc.hasOwnProperty("received_streak_mc"))
               {
                  m_receivedStreakMc = this.m_starReceivedMc["received_streak_mc"] as MovieClip;
                  ratings = starRating.split("/");
                  m_receivedStreakMc.visible = ratings[0] == ratings[1];
               }
            }
         }
      }
      
      private function onOkayClick(e:Event = null) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         if(!this.m_lastShow)
         {
            if(this.manager.mainWindow)
            {
               this.manager.mainWindow.untintWindow();
               this.manager.mainWindow.enableInput = true;
               if(this.manager.getCycleIndex() == 5)
               {
                  Global.player.setSeenFlag("bb_unlimited_cycle");
                  this.manager.showUnlimitedCycleStartPopupWindow();
               }
               else
               {
                  this.manager.showScreenShotWindow();
               }
            }
         }
         super.close();
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(this.m_featureName);
      }
   }
}

