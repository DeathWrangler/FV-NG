package Widgets.Windows.Beehives
{
   import Classes.BeehiveBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericPopupTitle;
   import Display.UI;
   import Events.GenericPopupEvent;
   import GameMode.GMBeehiveItemPlace;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Beehives.BeehiveMeterFrame;
   import Widgets.Frames.CreditsBuilding.LeaderBoardFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class BeehiveWindow extends FarmWindow
   {
      
      protected var m_toggleManager:ZwToggleManager = null;
      
      protected var m_building:BeehiveBuilding = null;
      
      protected var m_itemToBuy:FarmItem = null;
      
      public function BeehiveWindow(building:BeehiveBuilding)
      {
         super("assets/dialogs/FV_BeeHive_Dialog.swf");
         this.m_building = building;
      }
      
      override protected function release() : void
      {
         if(this.m_toggleManager)
         {
            this.m_toggleManager.release();
            this.m_toggleManager = null;
         }
         super.release();
      }
      
      override protected function postLoadComplete() : void
      {
         var queenBeeFrame:ZwFrame = null;
         var progressBtn:FarmAnimatedTextButton = null;
         var comparisonBtn:FarmAnimatedTextButton = null;
         var beesFrame:ZwFrame = null;
         var leaderBoardFrame:LeaderBoardFrame = null;
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","BeehiveWindow_Beehive")));
         var meterFrame:ZwFrame = new BeehiveMeterFrame(m_window.meter_mc,this.m_building,BeehiveBuilding.BEEHIVE_FEATURE);
         addWidget(meterFrame);
         var hasQueenBee:Boolean = this.m_building.hasQueenBee();
         if(!hasQueenBee)
         {
            queenBeeFrame = new ZwFrame(m_window.buyQueen_mc);
            this.buildQueenBeeFrame(queenBeeFrame);
            addWidget(queenBeeFrame);
            FarmStatsManager.count("beehive","beehive_queen","open_beehive");
         }
         else
         {
            progressBtn = new FarmAnimatedTextButton(m_window.progress_bt,ZLocUtils.t("Dialogs","BeehiveWindow_Progress"),this.showMeterFrame,true);
            addWidget(progressBtn);
            comparisonBtn = new FarmAnimatedTextButton(m_window.comparison_bt,ZLocUtils.t("Dialogs","BeehiveWindow_Comparison"),this.hideMeterFrame,true);
            addWidget(comparisonBtn);
            beesFrame = new ZwFrame(m_window.bees_mc);
            this.buildBeesFrame(beesFrame);
            addWidget(beesFrame,false);
            leaderBoardFrame = new LeaderBoardFrame(m_window.leaderBoard_mc,this.m_building,BeehiveBuilding.BEEHIVE_FEATURE);
            addWidget(leaderBoardFrame,false);
            this.m_toggleManager = new ZwToggleManager();
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(progressBtn,beesFrame),true);
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(comparisonBtn,leaderBoardFrame));
            FarmStatsManager.count("beehive","beehive_swarm","open_beehive");
         }
      }
      
      protected function buildQueenBeeFrame(frame:ZwFrame) : void
      {
         var element:Object = frame.element;
         frame.addWidget(new ZwTextField(element.buildSwarm_tf,ZLocUtils.t("Dialogs","BeehiveWindow_NeedQueen")));
         frame.addWidget(new FarmAnimatedTextButton(element.buyQueen_bt,ZLocUtils.t("Dialogs","BeehiveWindow_BuyQueen"),this.onBuyQueenBee,true));
         frame.addWidget(new FarmAnimatedTextButton(element.returntoFarm_bt,ZLocUtils.t("Dialogs","BeehiveWindow_ReturnToFarm"),this.onReturnToFarm,true));
      }
      
      private function onReturnToFarm(evt:MouseEvent) : void
      {
         this.close();
      }
      
      private function onBuyQueenBee(evt:MouseEvent) : void
      {
         if(this.m_shown)
         {
            this.hide();
         }
         this.m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(BeehiveBuilding.BEEHIVE_QUEEN);
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(this.m_itemToBuy.friendlyName),
            "cashQuantity":this.m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyQueenBeeConfirmation),false);
      }
      
      private function onBuyQueenBeeConfirmation(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT && this.m_itemToBuy != null)
         {
            if(Global.player.canBuyCash(this.m_itemToBuy.cash,true))
            {
               Global.world.addGameMode(new GMBeehiveItemPlace(this.m_itemToBuy.name,false,1,true),false);
            }
            close();
         }
         else if(!this.m_shown)
         {
            this.show();
         }
      }
      
      protected function buildBeesFrame(frame:ZwFrame) : void
      {
         var element:Object = frame.element;
         frame.addWidget(new ZwTextField(element.buildSwarm_tf,ZLocUtils.t("Dialogs","BeehiveWindow_BuildSwarm")));
         frame.addWidget(new ZwTextField(element.tendSwarm_tf,ZLocUtils.t("Dialogs","BeehiveWindow_TendSwarm")));
         frame.addWidget(new FarmAnimatedTextButton(element.askForBees_bt,ZLocUtils.t("Dialogs","BeehiveWindow_AskForBees"),this.onAskForBees,true));
         frame.addWidget(new FarmAnimatedTextButton(element.buyBees_bt,ZLocUtils.t("Dialogs","BeehiveWindow_BuyBees"),this.onBuyBees,true));
      }
      
      private function onAskForBees(evt:MouseEvent) : void
      {
         if(this.m_shown)
         {
            this.hide();
         }
         var dialog:GenericPopupTitle = new GenericPopupTitle("BeehiveBuilding_AskForCreditsTitle","BeehiveBuilding_AskForCreditsText",false,GenericPopup.TYPE_ACCEPTCANCEL,this.onAskForBeesConfirmation);
         dialog.setAcceptTextName("BeehiveBuilding_AskForCreditsAccept");
         var iconUrl:String = Global.getAssetURL(this.m_building.getDialogSideIconUrl());
         dialog.setIcons(iconUrl,iconUrl,null);
         UI.displayPopup(dialog,false);
      }
      
      private function onAskForBeesConfirmation(evt:GenericPopupEvent) : void
      {
         if(GenericPopup.ACCEPT == evt.button)
         {
            BeehiveBuilding.askForBees();
         }
         if(!this.m_shown)
         {
            this.show();
         }
      }
      
      private function onBuyBees(evt:MouseEvent) : void
      {
         if(this.m_shown)
         {
            this.hide();
         }
         this.m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(BeehiveBuilding.BEEHIVE_BEE_5);
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(this.m_itemToBuy.friendlyName),
            "cashQuantity":this.m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyBeesConfirmation),false);
      }
      
      private function onBuyBeesConfirmation(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT && this.m_itemToBuy != null)
         {
            if(Global.player.canBuyCash(this.m_itemToBuy.cash,true))
            {
               Global.world.addGameMode(new GMBeehiveItemPlace(this.m_itemToBuy.name,false,1,true),false);
            }
            close();
         }
         else if(!this.m_shown)
         {
            this.show();
         }
      }
      
      protected function showMeterFrame(event:MouseEvent) : void
      {
         getWidget(m_window.meter_mc).visible = true;
      }
      
      protected function hideMeterFrame(event:MouseEvent) : void
      {
         getWidget(m_window.meter_mc).visible = false;
      }
   }
}

